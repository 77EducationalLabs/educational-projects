//SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Helper} from "../helpers/Helper.t.sol";

contract NebulaQuest is Helper {

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
    
    //Emitting NFT and Updating Storage
        function test_ifMainContractSuccessfullyMintNFT() public setAnswers{
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

            uint256 user01NFT = nft.balanceOf(s_user01);
            assertEq(user01NFT, 1);
            assertEq(nft.ownerOf(0), s_user01);
        }

        function test_ifMainContractSuccessfullyUpdateNFT() public {
            multipleExams();

            //Mock Data
            uint8 firstExam = 1;
            bytes32[] memory firstAnswers = new bytes32[](10);
            firstAnswers[0] = keccak256(abi.encodePacked("test1"));
            firstAnswers[1] = keccak256(abi.encodePacked("test2"));
            firstAnswers[2] = keccak256(abi.encodePacked("test3"));
            firstAnswers[3] = keccak256(abi.encodePacked("test4"));
            firstAnswers[4] = keccak256(abi.encodePacked("test5"));
            firstAnswers[5] = keccak256(abi.encodePacked("test6"));
            firstAnswers[6] = keccak256(abi.encodePacked("test7"));
            firstAnswers[7] = keccak256(abi.encodePacked("test8"));
            firstAnswers[8] = keccak256(abi.encodePacked("test9"));
            firstAnswers[9] = keccak256(abi.encodePacked("test10"));

            //Mock Data
            uint8 secondExam = 2;
            bytes32[] memory secondAnswers = new bytes32[](10);
            secondAnswers[0] = keccak256(abi.encodePacked("secondTest1"));
            secondAnswers[1] = keccak256(abi.encodePacked("secondTest2"));
            secondAnswers[2] = keccak256(abi.encodePacked("secondTest3"));
            secondAnswers[3] = keccak256(abi.encodePacked("secondTest4"));
            secondAnswers[4] = keccak256(abi.encodePacked("secondTest5"));
            secondAnswers[5] = keccak256(abi.encodePacked("secondTest6"));
            secondAnswers[6] = keccak256(abi.encodePacked("secondTest7"));
            secondAnswers[7] = keccak256(abi.encodePacked("secondTest8"));
            secondAnswers[8] = keccak256(abi.encodePacked("secondTest9"));
            secondAnswers[9] = keccak256(abi.encodePacked("secondTest10"));

            vm.startPrank(s_user01);
            quest.submitAnswers(firstExam, firstAnswers);

            quest.submitAnswers(secondExam, secondAnswers);

            vm.stopPrank();

            uint256 user01Balance = coin.balanceOf(s_user01);
            assertEq(user01Balance, 2000*10**18);

            uint256 user01NFT = nft.balanceOf(s_user01);
            assertEq(user01NFT, 1);
            assertEq(nft.ownerOf(0), s_user01);

            assertEq(quest.s_studentsScore(s_user01, firstExam), 1000);
            assertEq(quest.s_studentsScore(s_user01, secondExam), 1000);
        }
}