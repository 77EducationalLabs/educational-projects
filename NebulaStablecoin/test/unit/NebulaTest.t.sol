// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Helper} from "../helpers/Helper.t.sol";

contract NebulaQuestCoinTest is Helper {

    /// Deploy Check ///
        function test_questDeploy() public {
            assertTrue(address(quest) != address(0));
        }

    /// Answers Setters
        function test_answerSetterRevertForNoOwner() public {
            //Mock Data
            uint8 examNumber = 1;
            bytes32[] memory correctAnswers;
            correctAnswers[0] = keccak256(abi.encodePacked("test"));
            
            //Test
            vm.prank(s_user01);
            vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, s_user01));
            quest.answerSetter(examNumber, correctAnswers);
        }
}