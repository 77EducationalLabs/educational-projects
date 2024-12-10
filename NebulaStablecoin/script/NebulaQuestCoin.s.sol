// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {NebulaQuestCoin} from "../src/NebulaQuestCoin.sol";

contract NebulaQuestCoinScript is Script {
    NebulaQuestCoin public stablecoin;

    function setUp() public {}

    function run(address _admin, address _minter) public {
        vm.startBroadcast();

        stablecoin = new NebulaQuestCoin("NebulaQuestCoin","NQC", _admin, _minter);

        vm.stopBroadcast();
    }
}
