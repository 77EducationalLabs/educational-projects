// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Helper} from "../helpers/Helper.t.sol";
import {console} from "forge-std/Test.sol";

contract NebulaQuestTest is Helper {

    /// Deploy Check ///
        function test_questDeploy() public view {
            assertTrue(address(quest) != address(0));
        }

    /// Answers Setters
        function test_answerSetterRevertBecauseOfOwner() public {
            //Mock Data
            uint8 examNumber = 1;
            bytes32[] memory correctAnswers = new bytes32[](10);
            correctAnswers[0] = keccak256(abi.encodePacked("test"));

            //Test
            vm.prank(s_user01);
            vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, s_user01));
            quest.answerSetter(examNumber, correctAnswers);
        }

        function test_answerSetterRevertBecauseOfNumberOfAnswers() public {
            //Mock Data
            uint8 examNumber = 1;
            bytes32[] memory correctAnswers = new bytes32[](1);
            correctAnswers[0] = keccak256(abi.encodePacked("test"));

            //Test
            vm.prank(s_admin);
            vm.expectRevert(abi.encodeWithSelector(NebulaQuest_WrongAmountOfAnswers.selector, 1, 10));
            quest.answerSetter(examNumber, correctAnswers);
        }

        function test_answerSetterSucceed() public {
            //Mock Data
            uint8 examNumber = 1;
            bytes32[] memory correctAnswers = new bytes32[](10);
            correctAnswers[0] = keccak256(abi.encodePacked("test"));

            //Test
            vm.prank(s_admin);
            vm.expectEmit();
            emit NebulaQuest_AnswersUpdated(examNumber);
            quest.answerSetter(examNumber, correctAnswers);
        }
    
    /// Submit Answers
        function test_submitAnswersFailsDueToArrayLength() public setAnswers{
            //Mock Data
            uint8 examNumber = 1;
            bytes32[] memory correctAnswers = new bytes32[](5);
            correctAnswers[0] = keccak256(abi.encodePacked("test"));

            vm.expectRevert(abi.encodeWithSelector(NebulaQuest_MustAnswerAllQuestions.selector, 5, 10));
            quest.submitAnswers(examNumber, correctAnswers);
        }

        function test_submitAnswersSucceedButUserFailed() public setAnswers{
            uint8 examNumber = 1;
            bytes32[] memory correctAnswers = new bytes32[](10);
            correctAnswers[0] = keccak256(abi.encodePacked("test1"));
            correctAnswers[1] = keccak256(abi.encodePacked("test2"));
            correctAnswers[2] = keccak256(abi.encodePacked("test3"));
            correctAnswers[3] = keccak256(abi.encodePacked("test4"));
            correctAnswers[4] = keccak256(abi.encodePacked("test5"));
            correctAnswers[5] = keccak256(abi.encodePacked("test6"));
            correctAnswers[6] = keccak256(abi.encodePacked("test7"));
            correctAnswers[7] = keccak256(abi.encodePacked("test"));
            correctAnswers[8] = keccak256(abi.encodePacked("test"));
            correctAnswers[9] = keccak256(abi.encodePacked("test"));

            vm.expectEmit();
            emit NebulaQuest_ExamFailed(address(this), examNumber, 700);
            quest.submitAnswers(examNumber, correctAnswers);
        }

        function test_submitAnswersSucceedAndUserSucceed() public setAnswers{
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
            emit NebulaQuest_ExamPassed(s_user01, examNumber, 1000);
            quest.submitAnswers(examNumber, correctAnswers);

            assertEq(quest.s_studentsScore(s_user01, examNumber), 1000);
        }

        //@Bug Solved
        function test_submitAnswerCatchBugOne() public {
            uint8 examNumber = 2;
            bytes32[] memory correctAnswers;

            vm.expectRevert(abi.encodeWithSelector(NebulaQuest_NonExistentExam.selector, examNumber));
            quest.submitAnswers(examNumber, correctAnswers);
        }
}