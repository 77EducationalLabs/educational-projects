// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
 
/**
    *@title KipuBank
    *@author Barba - 77 Innovation Labs
    *@dev Do not use it in production
    *@notice This is an example contract used as a parameter for the second module of the Ethereum Developer Pack - São Paulo / Brazil
    *@custom:contact anySocial/i3arba
*/
contract KipuBank {

    /*///////////////////////
           VARIABLES
    ///////////////////////*/
    ///@notice immutable variable to hold the max amount the vault can store
    uint256 immutable i_bankCap;

    ///@notice constant variable to limit the withdrawal 
    uint256 constant AMOUNT_PER_WITHDRAW = 1*10**16;

    ///@notice public variable to hold the number of deposits completed
    uint256 public s_depositsCounter;
    ///@notice public variable to hold the number of withdrawals completed
    uint256 public s_withdrawsCounter;

    ///@notice mapping to keep track of deposits
    mapping(address user => uint256 amount) public s_vault;

    /*///////////////////////
           EVENTS
    ///////////////////////*/
    ///@notice event emitted when a deposit is successfully completed
    event KipuBank_SuccessfullyDeposited(address user, uint256 amount);
    ///@notice event emitted when a withdrawal is successfully completed
    event KipuBank_SuccessfullyWithdrawn(address user, uint256 amount);

    /*///////////////////////
            ERRORS
    ///////////////////////*/
    ///@notice error emitted when the amount to be deposited plus the contract balance exceeds the bankCap
    error KipuBank_BankCapReached(uint256 depositCap);
    ///@notice error emitted when the amount to be withdrawn is bigger than the user's balance
    error KipuBank_AmountExceedBalance(uint256 amount, uint256 balance);
    ///@notice error emitted when the native transfer fails
    error KipuBank_TransferFailed(bytes reason);

    /*///////////////////////
           FUNCTIONS
    ///////////////////////*/
    constructor(uint256 _bankCap){
        i_bankCap = _bankCap;
    }

    /**
        *@notice modifier to check if the amount follows some conditions
        *@param _amount eth amount to withdraw
        *@dev must revert if the amount is bigger than the user balance or is bigger than the AMOUNT_PER_WITHDRAW threshold.
    */
    modifier amountCheck(uint256 _amount){
        uint256 userBalance = s_vault[msg.sender];
        if(_amount > userBalance || _amount > AMOUNT_PER_WITHDRAW) revert KipuBank_AmountExceedBalance(_amount, userBalance);
        _;
    }

    /**
        *@notice external function to receive native deposits
        *@notice Emit an event when deposits succeed.
        *@dev after the transaction contract balance should not be bigger than the bank cap
    */
    function deposit() external payable {
        if(address(this).balance > i_bankCap) revert KipuBank_BankCapReached(i_bankCap);

        s_depositsCounter = s_depositsCounter + 1;
        s_vault[msg.sender] += msg.value;

        emit KipuBank_SuccessfullyDeposited(msg.sender, msg.value);
    }

    /**
        *@notice external function to process withdrawals
        *@param _amount is the amount to be withdrawn
        *@dev User must not be able to withdraw more than deposited
        *@dev User must not be able to withdraw more than the threshold per withdraw
    */
    function withdraw(uint256 _amount) external amountCheck(_amount){
        s_withdrawsCounter = s_withdrawsCounter +1;
        s_vault[msg.sender] -= _amount;

        _processTransfer(_amount);
    }

    /**
        *@notice internal function to process the ETH transfer from: contract -> to: user
        *@dev emits an event if success
    */
    function _processTransfer(uint256 _amount) private {

        emit KipuBank_SuccessfullyWithdrawn(msg.sender, _amount);

        (bool success, bytes memory data) = msg.sender.call{value: _amount}("");
        if(!success) revert KipuBank_TransferFailed(data);
    }

    /**
        *@notice external view function to return the contract's balance
        *@return _balance the amount of ETH in the contract
    */
    function contractBalance() external view returns(uint256 _balance){
        _balance = address(this).balance;
    }
}
