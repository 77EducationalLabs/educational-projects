// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/*///////////////////////////////////
            Imports
///////////////////////////////////*/
import { IAnyrand } from "./interfaces/IAnyrand.sol";

/*///////////////////////////////////
            Interfaces
///////////////////////////////////*/
interface IRandomiserCallbackV3 {
    /// @notice Receive random words from a randomiser.
    /// @dev Ensure that proper access control is enforced on this function;
    ///     only the designated randomiser may call this function and the
    ///     requestId should be as expected from the randomness request.
    /// @param requestId The identifier for the original randomness request
    /// @param randomWord Uniform random number in the range [0, 2**256)
    function receiveRandomness(uint256 requestId, uint256 randomWord) external;
}

/**
    *@author i3arba - 77 Innovation Labs
    *@title JokesLottery
    *@notice Example of VRF usage on Scroll
    *@dev do not use this contract in production
*/
contract JokesLottery is IRandomiserCallbackV3{

    /*///////////////////////////////////
            Type declarations
    ///////////////////////////////////*/

    /*///////////////////////////////////
            State variables
    ///////////////////////////////////*/
    ///@notice struct to store Jokes information
    struct JokesInfo{
        string intro;
        string punchline;
        address joker;
        uint256 reward;
    }
    
    ///@notice struct to store the requests infos
    struct Requests{
        bool exists;
        uint256 randomValue;
    }

    ///@notice Anyrand interface to interact with requests
    IAnyrand immutable i_anyrand;

    ///@notice magic numbers removal
    uint256 constant REQUEST_THRESHOLD = 86_400; //1 day in secs.
    uint256 constant ONE = 1;

    ///@notice variable to store the time of last request
    uint256 public s_lastRequestTime;
    ///@notice variable to count the number of jokes registered
    uint256 public s_jokesCounter;
    ///@notice variable to store the most recent select joke Id
    uint256 public s_selectedJoke;

    mapping(uint256 requestId => Requests) public s_randomRequest;
    mapping(uint256 jokeId => JokesInfo) s_jokeStorage;

    /*///////////////////////////////////
                Events
    ///////////////////////////////////*/
    event JokesLottery_NewJokeAdded(uint256 jokeId);
    event JokesLottery_RandomnessReceived(uint256 requestId, uint256 randomWord);
    event JokesLottery_RandomRequestSent(uint256 requestId);
    event JokesLottery_ExcessiveAmountRefunded(uint256 amount);
    event JokesLottery_JokeRewarded(uint256 jokeId, uint256 rewardReceived);
    event JokesLottery_RewardWithdrawal(address joker, uint256 reward);

    /*///////////////////////////////////
                Errors
    ///////////////////////////////////*/
    error JokesLottery_IntroCantBeEmpty(string intro);
    error JokesLottery_PunchlineCantBeEmpty(string punchline);
    error JokesLottery_NotEnoughTimeHasPassed(uint256 timeNow, uint256 nextRequestTime);
    error JokesLottery_NotAllowedCaller(address caller);
    error JokesLottery_NonExistentRequest(uint256 requestId);
    error JokesLottery_InvalidDeadline(uint256 deadline);
    error JokesLottery_InsufficientPayment(uint256 payment, uint256 amountRequired);
    error JokesLottery_InsufficientAmount();
    error JokesLottery_RefundFailed(bytes errorData);
    error JokesLottery_OnlyTheJokerCanWithdraw();
    error JokesLottery_ZeroRewardsToWithdrawal();
    error JokesLottery_ThereIsNoJokeToSelect();

    /*///////////////////////////////////
                Modifiers
    ///////////////////////////////////*/

    /*///////////////////////////////////
                Functions
    ///////////////////////////////////*/

    /*///////////////////////////////////
                constructor
    ///////////////////////////////////*/
    constructor(address _anyrand){
        i_anyrand = IAnyrand(_anyrand);
    }

    /*///////////////////////////////////
            Receive&Fallback
    ///////////////////////////////////*/

    /*///////////////////////////////////
                external
    ///////////////////////////////////*/
    function registerJoke(string memory _intro, string memory _punchline) external returns(uint256 jokeId_){
        if(keccak256(abi.encodePacked(_intro)) == "") revert JokesLottery_IntroCantBeEmpty(_intro);
        if(keccak256(abi.encodePacked(_punchline)) == "") revert JokesLottery_PunchlineCantBeEmpty(_punchline);

        s_jokesCounter = s_jokesCounter + 1;

        s_jokeStorage[s_jokesCounter] = JokesInfo({
            intro: _intro,
            punchline: _punchline,
            joker: msg.sender,
            reward: 0
        });

        jokeId_ = s_jokesCounter;

        emit JokesLottery_NewJokeAdded(jokeId_);
    }

    /**
        *@notice function to reward the most recently selected joke
        *@dev anyone can call and give a reward
    */
    function rewardJoke() external payable {
        if(msg.value < ONE) revert JokesLottery_InsufficientAmount();
        s_jokeStorage[s_selectedJoke].reward = s_jokeStorage[s_selectedJoke].reward + msg.value;

        emit JokesLottery_JokeRewarded(s_selectedJoke, msg.value);
    }

    /**
        *@notice function for joker's to withdraw their reward
        *@param _jokeId the rewarded joke to withdraw from
    */
    function withdrawRewards(uint256 _jokeId) external {
        JokesInfo storage info = s_jokeStorage[_jokeId];
        if(info.joker != msg.sender) revert JokesLottery_OnlyTheJokerCanWithdraw();
        if(info.reward < ONE) revert JokesLottery_ZeroRewardsToWithdrawal();

        uint256 amountToTransfer = info.reward;
        info.reward = 0;

        emit JokesLottery_RewardWithdrawal(msg.sender, amountToTransfer);

        _transferEth(amountToTransfer);
    }

    /**
        *@notice function to call Anyrand services to request a random value
        *@dev Sending 10_000_000_000_000
        *@param _deadline to the request be fulfilled
        *@param _callbackGasLimit the amount of gas you accept to pay for the service requested - I am using 60k
        *@return requestId_ the request's Id
    */
    function requestRandom(uint256 _deadline, uint256 _callbackGasLimit) external payable returns(uint256 requestId_){
        if(block.timestamp < s_lastRequestTime) revert JokesLottery_NotEnoughTimeHasPassed(block.timestamp, s_lastRequestTime);
        if(_deadline <= block.timestamp) revert JokesLottery_InvalidDeadline(_deadline);
        if(s_jokesCounter < ONE) revert JokesLottery_ThereIsNoJokeToSelect();

        (uint256 requestPrice, ) = IAnyrand(i_anyrand).getRequestPrice(_callbackGasLimit);

        if(msg.value < requestPrice) revert JokesLottery_InsufficientPayment(msg.value, requestPrice);

        requestId_ = IAnyrand(i_anyrand).requestRandomness{value: requestPrice}(_deadline, _callbackGasLimit);

        s_randomRequest[requestId_].exists = true;
        s_lastRequestTime = block.timestamp + REQUEST_THRESHOLD;

        emit JokesLottery_RandomRequestSent(requestId_);

        if(msg.value > requestPrice) {
            uint256 amountToRefund = msg.value - requestPrice;
            _transferEth(amountToRefund);
            emit JokesLottery_ExcessiveAmountRefunded(amountToRefund);
        }
    }

    /**
        *@notice function to be called by the Anyrand system to provide the random value
        *@param _requestId the ID of the initialized request
        *@param _randomWord the random value received
        *@dev can only be called by the Anyrand address
    */
    function receiveRandomness(uint256 _requestId, uint256 _randomWord) external {
        if(msg.sender != address(i_anyrand)) revert JokesLottery_NotAllowedCaller(msg.sender);
        if(!s_randomRequest[_requestId].exists) revert JokesLottery_NonExistentRequest(_requestId);

        s_randomRequest[_requestId].randomValue = _randomWord;
        s_selectedJoke = (_randomWord % s_jokesCounter) + 1;

        emit JokesLottery_RandomnessReceived(_requestId, _randomWord);
    }

    /*///////////////////////////////////
                public
    ///////////////////////////////////*/

    /*///////////////////////////////////
                internal
    ///////////////////////////////////*/

    /*///////////////////////////////////
                private
    ///////////////////////////////////*/
    /**
        *@notice function to internally handle ether transfers
        *@param _amount the amount to be refunded
    */
    function _transferEth(uint256 _amount) private {
        (bool success, bytes memory data) = msg.sender.call{value: _amount}("");
        if(!success) revert JokesLottery_RefundFailed(data);
    }

    /*///////////////////////////////////
                View & Pure
    ///////////////////////////////////*/
    function getJokeInfos(uint256 _jokeId) external view returns(JokesInfo memory info_){
        info_ = s_jokeStorage[_jokeId];
    }

}