// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

//Foundry Tools
import {Test, console2} from "forge-std/Test.sol";

//Protocol Contracts
import {NebulaQuestCoin} from "../../src/NebulaQuestCoin.sol";
import {NebulaQuest} from "../../src/NebulaQuest.sol";

abstract contract Helper is Test {

    //Contracts Instances
    NebulaQuestCoin stablecoin;
    NebulaQuest quest;

    //NebulaQuest variables
    NebulaQuestCoin coin;

    //Stablecoin variables
    bytes32 ADMIN_ROLE;
    bytes32 MINTER_ROLE;

    //State Variables ~ Utils
    address s_admin = makeAddr("s_admin");
    address s_minter = makeAddr("s_minter");
    address s_user01 = address(1);
    address s_user02 = address(2);
    address s_user03 = address(3);
    address s_user04 = address(4);
    
    //Token Amounts
    uint256 constant AMOUNT_TO_MINT = 10*10**18;
    uint256 constant SCORE_TEN_OF_TEN = 1000 *10**18;

    //Events
    event NebulaQuestCoin_TokenMinted(address _to, uint256 _amount);
    event NebulaQuestCoin_TokenBurned(uint256 _amount);
    event NebulaQuest_AnswersUpdated(uint8 examIndex);
    event NebulaQuest_ExamFailed(address user, uint8 examIndex, uint16 score);
    event NebulaQuest_ExamPassed(address user, uint8 examIndex, uint16 score);

    // Errors
    error AccessControlUnauthorizedAccount(address account, bytes32 role);
    error OwnableUnauthorizedAccount(address caller);
    error NebulaQuest_WrongAmountOfAnswers(uint256 numberOfAnswers, uint8 expectedNumberOfAnswers);
    error NebulaQuest_MustAnswerAllQuestions(uint256,uint256);
    error NebulaQuest_NonExistentExam(uint8);

    function setUp() external {
        stablecoin = new NebulaQuestCoin("NebulaQuestCoin","NQC", s_admin, s_minter);
        quest = new NebulaQuest("NebulaQuestCoin","NQC", s_admin);
        coin = quest.i_coin();

        ADMIN_ROLE = stablecoin.DEFAULT_ADMIN_ROLE();
        MINTER_ROLE = stablecoin.MINTER_ROLE();
    }

    modifier mintTokens(){
        //Mint tokens
        vm.prank(s_minter);
        vm.expectEmit();
        emit NebulaQuestCoin_TokenMinted(s_user01, AMOUNT_TO_MINT);
        stablecoin.mint(s_user01, AMOUNT_TO_MINT);
        _;
    }

    modifier setAnswers(){
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

        //Test
        vm.prank(s_admin);
        vm.expectEmit();
        emit NebulaQuest_AnswersUpdated(examNumber);
        quest.answerSetter(examNumber, correctAnswers);
        _;
    }
}
