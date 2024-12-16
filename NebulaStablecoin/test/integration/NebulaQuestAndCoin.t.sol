//SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Helper} from "../helpers/Helper.t.sol";

contract NebulaQuestAndCoin is Helper {

    ///Emitting Stablecoins
        function test_ifMainContractSuccessfullyMintStablecoin() public setAnswers{
            //Mock Data
            uint8 examNumber = 1;
            bytes32[] memory correctAnswers = new bytes32[](10);
            correctAnswers[0] = keccak256(abi.encodePacked("test1"));
            correctAnswers[1] = keccak256(abi.encodePacked("test2"));
            correctAnswers[2] = keccak256(abi.encodePacked("test3"));
            correctAnswers[3] = keccak256(abi.encodePacked("test4"));
            correctAnswers[4] = keccak256(abi.encodePacked("test5"));
            correctAnswers[5] = keccak256(abi.encodePacked("test6"));
            correctAnswers[6] = keccak256(abi.encodePacked("test7"));
            correctAnswers[7] = keccak256(abi.encodePacked("test8"));
            correctAnswers[8] = keccak256(abi.encodePacked("test9"));
            correctAnswers[9] = keccak256(abi.encodePacked("test10"));

            vm.prank(s_user01);
            vm.expectEmit();
            emit NebulaQuestCoin_TokenMinted(s_user01, SCORE_TEN_OF_TEN);
            quest.submitAnswers(examNumber, correctAnswers);

            uint256 user01Balance = coin.balanceOf(s_user01);
            assertEq(user01Balance, SCORE_TEN_OF_TEN);
        }

    //Burning Stablecoins
        function test_user01FailsToBurnTokensBecauseOfRole() public setAnswers{
            //Mock Data
            uint8 examNumber = 1;
            bytes32[] memory correctAnswers = new bytes32[](10);
            correctAnswers[0] = keccak256(abi.encodePacked("test1"));
            correctAnswers[1] = keccak256(abi.encodePacked("test2"));
            correctAnswers[2] = keccak256(abi.encodePacked("test3"));
            correctAnswers[3] = keccak256(abi.encodePacked("test4"));
            correctAnswers[4] = keccak256(abi.encodePacked("test5"));
            correctAnswers[5] = keccak256(abi.encodePacked("test6"));
            correctAnswers[6] = keccak256(abi.encodePacked("test7"));
            correctAnswers[7] = keccak256(abi.encodePacked("test8"));
            correctAnswers[8] = keccak256(abi.encodePacked("test9"));
            correctAnswers[9] = keccak256(abi.encodePacked("test10"));

            vm.prank(s_user01);
            vm.expectEmit();
            emit NebulaQuestCoin_TokenMinted(s_user01, SCORE_TEN_OF_TEN);
            quest.submitAnswers(examNumber, correctAnswers);

            vm.prank(s_user01);
            vm.expectRevert(abi.encodeWithSelector(AccessControlUnauthorizedAccount.selector, s_user01, MINTER_ROLE));
            coin.burn(SCORE_TEN_OF_TEN);
        }
}