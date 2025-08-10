// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol"; // Added WithdrawFundMe import

/**
 * @title Integration Tests
 * @notice These tests verify end-to-end interactions between contracts
 * @dev Tests script execution flows and contract integrations
 *
 * WHY NEEDED:
 * - Verifies multi-contract workflows (deploy -> fund -> withdraw)
 * - Ensures scripts work as expected (not just isolated units)
 * - Catches integration issues that unit tests might miss
 *
 * NOT MANDATORY BUT RECOMMENDED:
 * - Unit tests test individual components
 * - Integration tests verify how components work together
 * - Production projects should have both
 */

// Key points:

// Purpose: Tests how contracts interact in real scenarios
// Difference from unit tests: Unit tests check single contracts, these check workflows
// Importance: Catches issues that only appear when contracts interact
// Optional but valuable: Not strictly required, but highly recommended for production code

contract InteractionsTest is Test {
    FundMe fundMe;
    FundFundMe fundFundMe;
    WithdrawFundMe withdrawFundMe;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        fundFundMe = new FundFundMe();
        withdrawFundMe = new WithdrawFundMe();
        vm.deal(address(this), STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        // Directly fund without prank
        fundFundMe.fund(address(fundMe));

        // Verify funding
        address firstFunder = fundMe.getFunder(0);
        uint256 fundedAmount = fundMe.getAddressToAmountFunded(firstFunder);

        assertEq(fundedAmount, SEND_VALUE, "Funding amount mismatch");
    }

    function testWithdrawWorks() public {
        // Fund first
        fundFundMe.fund(address(fundMe));

        // Then withdraw
        withdrawFundMe.withdraw(address(fundMe));

        // Verify balance
        assertEq(address(fundMe).balance, 0, "Balance should be zero");
    }
}
