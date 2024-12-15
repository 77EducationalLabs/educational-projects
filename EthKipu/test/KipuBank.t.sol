// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {KipuBank} from "../src/KipuBank.sol";

contract KipuBankTest is Test {
    //Instances
    KipuBank bank;

    //Variables ~ Users
    address Barba = makeAddr("Barba");
    address student1 = makeAddr("student1");
    address student2 = makeAddr("student2");

    //Variables ~ Utils
    uint256 constant BANK_CAP = 10*10**18;
    uint256 constant INITIAL_BALANCE = 100*10**18;

    function setUp() public {
        bank = new KipuBank(BANK_CAP);

        vm.deal(Barba, INITIAL_BALANCE);
        vm.deal(student1, INITIAL_BALANCE);
        vm.deal(student2, INITIAL_BALANCE);
    }

    modifier processDeposit() {
        uint256 amount = 1*10**18;
        vm.prank(Barba);
        bank.deposit{value: amount}();
        _;
    }

    /// Testing functions ///
    error KipuBank_BankCapReached(uint256);
    function test_depositFailsBecauseOfCap() public {
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(KipuBank_BankCapReached.selector, BANK_CAP));
        bank.deposit{value: INITIAL_BALANCE}();
    }

    event KipuBank_SuccessfullyDeposited(address, uint256);
    function test_depositSucceed() public {
        uint256 amount = 1*10**18;
        vm.prank(student1);
        vm.expectEmit();
        emit KipuBank_SuccessfullyDeposited(student1, amount);
        bank.deposit{value: amount}();

        uint256 contractBalance = bank.contractBalance();

        assertEq(bank.s_depositsCounter(), 1);
        assertEq(bank.s_vault(student1), amount);
        assertEq(contractBalance, amount);
    }

    error KipuBank_AmountExceedBalance(uint256, uint256);
    function test_withdrawFailedBecauseOfUserBalance() public processDeposit {
        uint256 complaintAmount = 1*10**15;
        uint256 exceedingAmount = 1*10**18;

        vm.prank(student1);
        vm.expectRevert(abi.encodeWithSelector(KipuBank_AmountExceedBalance.selector, complaintAmount, 0));
        bank.withdraw(complaintAmount);

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(KipuBank_AmountExceedBalance.selector, exceedingAmount, exceedingAmount));
        bank.withdraw(exceedingAmount);

        assertEq(bank.s_withdrawsCounter(), 0);
        assertEq(bank.s_vault(Barba), exceedingAmount);
        assertEq(bank.contractBalance(), exceedingAmount);
    }

    event KipuBank_SuccessfullyWithdrawn(address, uint256);
    function test_WithdrawSucceed() public processDeposit {
        uint256 complaintAmount = 1*10**15;
        uint256 amountAfterWithdrawal = 1*10**18 - complaintAmount;

        vm.prank(Barba);
        vm.expectEmit();
        emit KipuBank_SuccessfullyWithdrawn(Barba, complaintAmount);
        bank.withdraw(complaintAmount);

        assertEq(bank.s_withdrawsCounter(), 1);
        assertEq(bank.s_vault(Barba), amountAfterWithdrawal);
        assertEq(bank.contractBalance(), amountAfterWithdrawal);
    }
}
