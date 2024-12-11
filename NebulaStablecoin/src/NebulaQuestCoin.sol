// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

/////////////
///Imports///
/////////////
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

////////////
///Errors///
////////////

///////////////////////////
///Interfaces, Libraries///
///////////////////////////
/**
    * @title Nebula Quest Stablecoin
    * @author i3arba - 77 Educational Labs
    * @custom:purpose this is an educational content and it's not audited. Do not use in production.
    * @notice in case of any security breach please contact us at:
    * @custom:security-contact security@77innovationlabs.com
*/
contract NebulaQuestCoin is ERC20, AccessControl, ERC20Permit {

    ///////////////////////
    ///Type declarations///
    ///////////////////////

    /////////////////////
    ///State variables///
    /////////////////////

    ///Constant & Immutable///
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    ////////////
    ///Events///
    ////////////
    ///@notice Event emitted when an amount of token is minted
    event NebulaQuestCoin_TokenMinted(address _to, uint256 _amount);
    ///@notice Event emitted when an amount of token is burned
    event NebulaQuestCoin_TokenBurned(uint256 _amount);

    ///////////////
    ///Modifiers///
    ///////////////

    ///////////////
    ///Functions///
    ///////////////

    /////////////////
    ///constructor///
    /////////////////
    /**
        * @notice Constructor to initialize inherited storage variables
        * @param _name The ERC20 token name
        * @param _symbol The ERC20 token symbol 
    */
    constructor(
        string memory _name, 
        string memory _symbol,
        address _admin,
        address _minter
    ) ERC20(_name, _symbol) ERC20Permit(_name){
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MINTER_ROLE, _minter);
    }

    ///////////////////////
    ///receive function ///
    ///fallback function///
    ///////////////////////

    //////////////
    ///external///
    //////////////
    /**
        * @notice External Function to mint controlled amount of tokens
        * @param _to The user address who will receive the amount
        * @param _amount The amount of tokens to be minted
        * @dev This function must only be accessed by authorized actors.
    */
    function mint(address _to, uint256 _amount) external onlyRole(MINTER_ROLE){
        emit NebulaQuestCoin_TokenMinted(_to, _amount);

        _mint(_to, _amount);
    }

    /**
        * @notice External function to burn controlled amount of tokens
        * @param _amount The amount of tokens to be burned
        * @dev This functions must only accessed by authorized actors.
    */
    function burn(uint256 _amount) external onlyRole(MINTER_ROLE){
        emit NebulaQuestCoin_TokenBurned(_amount);

        _burn(msg.sender, _amount);
    }

    ////////////
    ///public///
    ////////////

    //////////////
    ///internal///
    //////////////

    /////////////
    ///private///
    /////////////

    /////////////////
    ///view & pure///
    /////////////////
}