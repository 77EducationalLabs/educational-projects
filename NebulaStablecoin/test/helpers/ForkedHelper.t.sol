// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

//Foundry Tools
import {Test, console2} from "forge-std/Test.sol";

//Protocol Contracts
import {NebulaQuestCoin} from "../../src/NebulaQuestCoin.sol";
import {NebulaQuest} from "../../src/NebulaQuest.sol";
import {NebulaEvolution} from "../../src/NebulaEvolution.sol";

//Helpers
import {Strings} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

abstract contract ForkedHelper is Test {

    //Fork Utils
    uint256 polygonFork;
    string POL_RPC = vm.envString("POL_RPC");

    //Type Declarations
    using Strings for uint256;

    NebulaQuest.Student student;

    //Contracts Instances
    NebulaQuest quest;

    //NebulaQuest variables
    NebulaQuestCoin coin;
    NebulaEvolution nft;

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

    //Testing Utils
    uint256 constant LEVEL_ONE = 1;
    uint256 constant LEVEL_TWO = 2;
    uint256 constant LEVEL_THREE = 3;
    uint256 constant LEVEL_FOUR = 4;
    uint256 constant LEVEL_FIVE = 5;
    uint256 constant LEVEL_SIX = 6;
    uint256 constant LEVEL_SEVEN = 7;
    uint256 constant EXP_ONE = 0;
    uint256 constant EXP_TWO = 1000;
    uint256 constant EXP_THREE = 2000;
    uint256 constant EXP_FOUR = 3000;
    uint256 constant EXP_FIVE = 4000;
    uint256 constant EXP_SIX = 5000;
    uint256 constant EXP_SEVEN = 6000;

    //Events
    event NebulaQuestCoin_TokenMinted(address _to, uint256 _amount);
    event NebulaQuestCoin_TokenBurned(uint256 _amount);
    event NebulaQuest_AnswersUpdated(uint8 examIndex);
    event NebulaQuest_ExamFailed(address user, uint8 examIndex, uint16 score);
    event NebulaQuest_ExamPassed(address user, uint8 examIndex, uint16 score);
    event NebulaEvolution_LevelUpdated(uint256 level,  uint256 amountOfExp);
    event NebulaEvolution_TheGasIsFreezingABirthIsOnTheWay(uint256 tokenId);
    event NebulaEvolution_NFTUpdated(uint256 tokenId, string finalURI);

    // Errors
    error AccessControlUnauthorizedAccount(address account, bytes32 role);
    error OwnableUnauthorizedAccount(address caller);
    error NebulaQuest_WrongAmountOfAnswers(uint256 numberOfAnswers, uint8 expectedNumberOfAnswers);
    error NebulaQuest_MustAnswerAllQuestions(uint256,uint256);
    error NebulaQuest_NonExistentExam(uint8);
    error NebulaEvolution_ThereAreOnlySevenLevels(uint256 level);
    error NebulaEvolution_AlreadyHasAnNFT();

    function setUp() external {
        polygonFork = vm.createFork(POL_RPC);
        vm.selectFork(polygonFork);
        quest = new NebulaQuest(s_admin);
        coin = quest.i_coin();
        nft = quest.i_nft();

        ADMIN_ROLE = coin.DEFAULT_ADMIN_ROLE();
        MINTER_ROLE = coin.MINTER_ROLE();
    }

    /// MODIFIERS
    modifier mintTokens(){
        //Mint tokens
        vm.prank(s_minter);
        vm.expectEmit();
        emit NebulaQuestCoin_TokenMinted(s_user01, AMOUNT_TO_MINT);
        coin.mint(s_user01, AMOUNT_TO_MINT);
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

    modifier setLevels(){
        vm.startPrank(s_admin);
        nft.levelsSetter(LEVEL_ONE, EXP_ONE);
        nft.levelsSetter(LEVEL_TWO, EXP_TWO);
        nft.levelsSetter(LEVEL_THREE, EXP_THREE);
        nft.levelsSetter(LEVEL_FOUR, EXP_FOUR);
        nft.levelsSetter(LEVEL_FIVE, EXP_FIVE);
        nft.levelsSetter(LEVEL_SIX, EXP_SIX);
        nft.levelsSetter(LEVEL_SEVEN, EXP_SEVEN);
        vm.stopPrank();
        _;
    }

    /// HELPER FUNCTIONS
    function helperURI(string memory _name, string memory _image, uint256 _nftLevel, uint256 _exp) public pure returns(string memory finalURI){
        
        string memory uri = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', _name, '",'
                        '"description": "Nebula Evolution",',
                        '"image": "', _image, '",'
                        '"attributes": [',
                            ',{"trait_type": "Level",',
                            '"value": ', _nftLevel.toString(),'}',
                            '{"trait_type": "Exp",',
                            '"value": ', _exp.toString(),'}',
                        ']}'
                    )
                )
            )
        );

        // Create token URI
        finalURI = string(
            abi.encodePacked("data:application/json;base64,", uri)
        );
    }

    function multipleExams() public setAnswers{
        uint8 examNumber = 2;
        bytes32[] memory correctAnswers = new bytes32[](10);
        correctAnswers[0] = keccak256(abi.encodePacked("secondTest1"));
        correctAnswers[1] = keccak256(abi.encodePacked("secondTest2"));
        correctAnswers[2] = keccak256(abi.encodePacked("secondTest3"));
        correctAnswers[3] = keccak256(abi.encodePacked("secondTest4"));
        correctAnswers[4] = keccak256(abi.encodePacked("secondTest5"));
        correctAnswers[5] = keccak256(abi.encodePacked("secondTest6"));
        correctAnswers[6] = keccak256(abi.encodePacked("secondTest7"));
        correctAnswers[7] = keccak256(abi.encodePacked("secondTest8"));
        correctAnswers[8] = keccak256(abi.encodePacked("secondTest9"));
        correctAnswers[9] = keccak256(abi.encodePacked("secondTest10"));

        //Test
        vm.prank(s_admin);
        vm.expectEmit();
        emit NebulaQuest_AnswersUpdated(examNumber);
        quest.answerSetter(examNumber, correctAnswers);
    }

    function interfaceReturnsTrue() public view returns(bool isInterface){
        isInterface = nft.supportsInterface(IERC721Receiver.onERC721Received.selector);
    }
}
