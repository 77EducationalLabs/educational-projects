//SPDX-License Identifier: MIT

pragma solidity 0.8.26;

///Imports///
///@notice stablecoin contract
import {NebulaQuestCoin} from "./NebulaQuestCoin.sol";

///@notice OpenZeppelin tools
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

///Errors///
///@notice error emitted when an user don't answer all questions
error NebulaQuest_MustAnswerAllQuestions(uint256 numberOfAnswers, uint256 expectedNumberOfAnswers);
///@notice error emitted when an admin input the wrong amount of answers
error NebulaQuest_WrongAmountOfAnswers(uint256 numberOfAnswers, uint8 expectedNumberOfAnswers);
///@notice error emitted when the score input is invalid
error NebulaQuest_InvalidScore(uint16 scoreInput, uint16 minScore, uint16 maxScore);
///@notice error emitted when an invalid examIndex is used
error NebulaQuest_NonExistentExam(uint8 examIndex);

///Interfaces, Libraries///

contract NebulaQuest is Ownable {

    ///Custom Types///
    ///@notice struct to organize exams data
    struct ExamResult{
        uint8 stageNumber;
        uint16 score;
    }

    ///Instances///
    ///@notice immutable variable to store the contract instance
    NebulaQuestCoin public immutable i_coin;

    ///Variables///
    ///@notice the minimum value a user must score to  graduate
    uint16 constant MIN_SCORE = 800;
    ///@notice the maximum value a user can score
    uint16 constant MAX_SCORE = 1_000;
    ///@notice the score per correct answer
    uint16 constant POINTS_ANSWER = 100;
    ///@notice the allowed number of answers
    uint8 constant NUM_ANSWERS = 10;
    ///@notice token standard decimals
    uint256 constant DECIMALS = 10**18;
    ///@notice the number to check against to check for empty arrays
    uint256 constant ONE = 1;

    ///Storage///
    ///@notice mapping to store the answers for each exam
    mapping(uint8 examNumber => bytes32[] answers) s_examAnswers;
    ///@notice mapping to store the student's records
    mapping(address student => ExamResult) public s_studentsScore;

    ///Events///
    ///@notice event emitted when the user scores more than or equal to the `MIN_SCORE` threshold
    event NebulaQuest_ExamPassed(address user, uint8 examIndex, uint16 score);
    ///@notice event emitted when the user scores less than the `MIN_SCORE` threshold
    event NebulaQuest_ExamFailed(address user, uint8 examIndex, uint16 score);
    ///@notice event emitted when an admin update the answers
    event NebulaQuest_AnswersUpdated(uint8 examIndex);

    ///Modifiers///

    ///Functions///

    ///constructor///
    /**
        * @notice constructor function to initialize contract variables and deploy the stablecoin
        * @param _name Stablecoin's name
        * @param _symbol Stablecoin's symbol
        * @param _admin Multi-sig wallet
        * @dev none of the params should be empty or invalid.
    */
    constructor (
        string memory _name, 
        string memory _symbol,
        address _admin
    ) Ownable(_admin) {
        i_coin = new NebulaQuestCoin(_name, _symbol, _admin, address(this));
    }

    ///external///
    /**
        * @notice function to receive encrypted answers and process the request against correct answers stored
        * @param _examIndex Exam's stage number
        * @param _encryptedAnswers User encrypted answer's array
        * @dev It should revert if the number of user answers is less than the number os stored answers
    */
    function submitAnswers(uint8 _examIndex, bytes32[] memory _encryptedAnswers) external {
        bytes32[] memory examAnswers = s_examAnswers[_examIndex];

        if(examAnswers.length < ONE) revert NebulaQuest_NonExistentExam(_examIndex);
        if(examAnswers.length != _encryptedAnswers.length) revert NebulaQuest_MustAnswerAllQuestions(_encryptedAnswers.length, examAnswers.length);

        uint16 score;

        for (uint256 i; i < examAnswers.length; ++i){
            if(_encryptedAnswers[i] == examAnswers[i]){
                score = score + POINTS_ANSWER;
            }
        }

        if(score >= MIN_SCORE){
            s_studentsScore[msg.sender] = ExamResult({
                stageNumber: _examIndex,
                score: score
            });

            emit NebulaQuest_ExamPassed(msg.sender, _examIndex, score);

            _distributeRewards(score);
        } else {
            emit NebulaQuest_ExamFailed(msg.sender, _examIndex, score);
        }

    }

    /**
        * @notice Setter function to define the correct answers
        * @param _examIndex The Stage ID
        * @param _correctAnswers An array with the correct answers
        * @dev this function should only be called by the Owner
        * @dev this function must not accept an amount of answers different than NUM_ANSWERS
    */
    function answerSetter(uint8 _examIndex, bytes32[] memory _correctAnswers) external onlyOwner {
        uint256 numberOfAnswers = _correctAnswers.length;
        if(numberOfAnswers != NUM_ANSWERS) revert NebulaQuest_WrongAmountOfAnswers(numberOfAnswers, NUM_ANSWERS);

        s_examAnswers[_examIndex] = _correctAnswers;

        emit NebulaQuest_AnswersUpdated(_examIndex);
    }
    ///public///

    ///internal///

    ///private///
    function _distributeRewards(uint16 _score) private {
        i_coin.mint(msg.sender, _score * DECIMALS);
    }

    ///view & pure///

}