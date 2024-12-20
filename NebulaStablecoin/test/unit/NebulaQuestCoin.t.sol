// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Helper} from "../helpers/Helper.t.sol";

contract NebulaQuestCoinTest is Helper {
    
    //// Deploy Check ////
        function test_stablecoinDeploy() public view {
            assertTrue(address(stablecoin) != address(0));
        }

    //// Stablecoin Basic Info's ////
        //Stablecoin's name check
        function test_stablecoinName() public view {
            assertEq(keccak256(abi.encodePacked("Nebula Stablecoin")), keccak256(abi.encodePacked(stablecoin.name())));
        }

        //Stablecoin's symbol check
        function test_stablecoinSymbol() public view {
            assertEq(keccak256(abi.encodePacked("NSN")), keccak256(abi.encodePacked(stablecoin.symbol())));
        }

        //// Access Control Roles ////
        //Default Admin Check
        function test_givenAdminRole() public view {
            assertEq(true, stablecoin.hasRole(ADMIN_ROLE, s_admin));
        }

        //Minter Check
        function test_givenMinterRole() public view {
            assertEq(true, stablecoin.hasRole(MINTER_ROLE, s_minter));
        }

    //// Mint functionalities ////
        ///Mint Function Revert
        function test_accessControlRevertMint() public {
            vm.prank(s_user01);
            vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, s_user01, MINTER_ROLE));
            stablecoin.mint(s_user01, AMOUNT_TO_MINT);
        }

        ///Mint Function Performs Successfully
        function test_minterSuccessfullyMint() public {
            vm.prank(s_minter);
            vm.expectEmit();
            emit NebulaQuestCoin_TokenMinted(s_user01, AMOUNT_TO_MINT);
            stablecoin.mint(s_user01, AMOUNT_TO_MINT);
        }

    //// Burn Functionalities ////
        ///Burn Function Revert
        function test_accessControlRevertBurn() public mintTokens {
            vm.prank(s_user01);
            vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, s_user01, MINTER_ROLE));
            stablecoin.burn(AMOUNT_TO_MINT);
        }

        ///Burn Function Succeed
        function test_minterSuccessfullyBurn() public mintTokens {
            //Transfer the token to `s_minter`
            vm.prank(s_user01);
            stablecoin.transfer(s_minter, AMOUNT_TO_MINT);

            assertEq(stablecoin.balanceOf(s_minter), AMOUNT_TO_MINT);

            //Burns the token
            vm.prank(s_minter);
            vm.expectEmit();
            emit NebulaQuestCoin_TokenBurned(AMOUNT_TO_MINT);
            stablecoin.burn(AMOUNT_TO_MINT);

            assertEq(stablecoin.balanceOf(s_minter), 0);
        }




}
