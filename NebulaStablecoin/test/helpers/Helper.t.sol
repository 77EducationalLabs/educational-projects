// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

import {NebulaQuestCoin} from "../../src/NebulaQuestCoin.sol";

contract Helper is Test {

    //Contracts Instances
    NebulaQuestCoin stablecoin;

    //State Variables ~ Utils
    address s_admin = makeAddr("s_admin");
    address s_minter = makeAddr("s_minter");
    address s_user01 = address(1);
    address s_user02 = address(2);
    address s_user03 = address(3);
    address s_user04 = address(4);

    function setUp() public {
        stablecoin = new NebulaQuestCoin("NebulaQuestCoin","NQC", s_admin, s_minter);
    }
}
