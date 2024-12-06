// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

/////////////
///Imports///
/////////////
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

////////////
///Errors///
////////////

///////////////////////////
///Interfaces, Libraries///
///////////////////////////

contract NebulaQuestCoin is ERC20 {

    ///////////////////////
    ///Type declarations///
    ///////////////////////

    /////////////////////
    ///State variables///
    /////////////////////

    ////////////
    ///Events///
    ////////////
    event NebulaQuestCoin_TokenMinted(address _to, uint256 _amount);

    ///////////////
    ///Modifiers///
    ///////////////

    ///////////////
    ///Functions///
    ///////////////

    /////////////////
    ///constructor///
    /////////////////
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol){}

    ///////////////////////
    ///receive function ///
    ///fallback function///
    ///////////////////////

    //////////////
    ///external///
    //////////////
    function mint(address _to, uint256 _amount) external {
        emit NebulaQuestCoin_TokenMinted(_to, _amount);

        _mint(_to, _amount);
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