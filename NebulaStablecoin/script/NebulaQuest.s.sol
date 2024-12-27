// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {NebulaQuest} from "../src/NebulaQuest.sol";

contract NebulaQuestScript is Script {
    NebulaQuest public quest;

    address s_admin = 0x71816E95593d3df3E25537835db659b662B06A10;

    function setUp() public {}

    function run() public returns(NebulaQuest _quest){
        vm.startBroadcast(msg.sender);

        _quest = new NebulaQuest(msg.sender);
        
        vm.stopBroadcast();
    }
}
