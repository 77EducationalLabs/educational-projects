///SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {ForkedHelper} from "../helpers/ForkedHelper.t.sol";

contract NebulaQuestForkedTest is ForkedHelper {

    ///Test if Fork is active
        function test_isForkActive() public view{
            assertEq(vm.activeFork(), polygonFork);
        }

    ///Quest Fork Testing
        function test_setExamAnswers() public {
            //Mock
            uint8 examNumber = 1;
            bytes32[] memory correctAnswers = new bytes32[](10);

            //Should Revert
            vm.prank(s_user01);
            vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, s_user01));
            quest.answerSetter(examNumber, correctAnswers);

            //Mock
            bytes32[] memory wrongAnswers = new bytes32[](1);

            //Should Revert
            vm.prank(s_admin);
            vm.expectRevert(abi.encodeWithSelector(NebulaQuest_WrongAmountOfAnswers.selector, 1, 10));
            quest.answerSetter(examNumber, wrongAnswers);

            //Should Succeed
            vm.prank(s_admin);
            vm.expectEmit();
            emit NebulaQuest_AnswersUpdated(examNumber);
            quest.answerSetter(examNumber, correctAnswers);
        }

        function test_submitAnswers() public setAnswers{
            //Mock Data
            uint8 examNumber = 1;
            bytes32[] memory wrongAnswers = new bytes32[](5);

            //Should Revert
            vm.expectRevert(abi.encodeWithSelector(NebulaQuest_MustAnswerAllQuestions.selector, 5, 10));
            quest.submitAnswers(examNumber, wrongAnswers);

            //Mock Data
            bytes32[] memory correctAnswersWithFailedExam = new bytes32[](10);
            correctAnswersWithFailedExam[0] = keccak256(abi.encodePacked("test1"));
            correctAnswersWithFailedExam[1] = keccak256(abi.encodePacked("test2"));
            correctAnswersWithFailedExam[2] = keccak256(abi.encodePacked("test3"));
            correctAnswersWithFailedExam[3] = keccak256(abi.encodePacked("test4"));
            correctAnswersWithFailedExam[4] = keccak256(abi.encodePacked("test5"));
            correctAnswersWithFailedExam[5] = keccak256(abi.encodePacked("test6"));
            correctAnswersWithFailedExam[6] = keccak256(abi.encodePacked("test7"));
            correctAnswersWithFailedExam[7] = keccak256(abi.encodePacked("test"));
            correctAnswersWithFailedExam[8] = keccak256(abi.encodePacked("test"));
            correctAnswersWithFailedExam[9] = keccak256(abi.encodePacked("test"));

            //Should Succeed but user didn't score enough points.
            vm.expectEmit();
            emit NebulaQuest_ExamFailed(address(this), examNumber, 700);
            quest.submitAnswers(examNumber, correctAnswersWithFailedExam);

            //Mock Data
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

            //Should succeed and be approved
            vm.prank(s_user01);
            vm.expectEmit();
            emit NebulaQuest_ExamPassed(s_user01, examNumber, 1000);
            quest.submitAnswers(examNumber, correctAnswers);

            //Query data
            student = quest.getStudentInfo(s_user01);

            //Assertions
            assertEq(quest.s_studentsScore(s_user01, examNumber), 1000);
            assertEq(coin.balanceOf(s_user01), SCORE_TEN_OF_TEN);
            assertEq(nft.balanceOf(s_user01), 1);
            assertEq(nft.ownerOf(0), s_user01);
            assertEq(student.nftId, 0);
            assertEq(student.certificates.length, 0);
        }

    //NFT Updates
        function test_updateNFT() public setLevels{
            //Initiate Two Exams
            multipleExams();

            //First Submission
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

            vm.prank(s_user01);
            vm.expectEmit();
            emit NebulaQuest_ExamPassed(s_user01, firstExam, 1000);
            quest.submitAnswers(firstExam, firstAnswers);

            //Second Submission
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

            //New NFT data
            string memory finalURI = helperURI(
                "Principal Sequence",
                "https://bafybeihdkzwuyfhjicomsyuwz2dmdqxhsp2dm3a5p6jootg6dymlb6hju4.ipfs.nftstorage.link/PrincipalSequence.png",
                LEVEL_THREE,
                EXP_THREE
            );

            //NFT emitted
            uint256 tokenId = 0;

            vm.prank(s_user01);
            vm.expectEmit();
            emit NebulaEvolution_NFTUpdated(tokenId, finalURI);
            quest.submitAnswers(secondExam, secondAnswers);
        }

    /// SupportsInterface
        function test_interfaceReturnsTrue() external view {
            assertEq(interfaceReturnsTrue(), false);
        }
}