// SPDX-License-Idenfitier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
// Make sure the DeployFundMe.s.sol file exists at the correct path.
// If the file is missing, create it or update the import path accordingly.
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user"); // Create a new address for testing
    address OWNER = makeAddr("owner"); // Create a new address for testing
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000 wei

    function setUp() external {
        // 👇 Avoids hardcoding the price feed (handled by HelperConfig inside the script)
        DeployFundMe deployFundMe = new DeployFundMe();
        // 👇 Also tests that DeployFundMe runs correctly (script is covered by this line)
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18, "Minimum USD should be 5");
    }

    function testOwnerIsMsgSender() public {
        // 👇 In Foundry tests, msg.sender is address(this), same as who deployed in setUp()
        address expectedOwner = msg.sender;
        assertEq(
            fundMe.getOwner(),
            expectedOwner,
            "Owner should be the message sender"
        );
    }

    function testPriceFeedVersion() public {
        uint256 version = fundMe.getVersion();
        console.log("Price Feed Version:", version);
        assertEq(
            version,
            4,
            "Price Feed Version should be 4 (Sepolia ETH/USD)"
        );
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // Hey, the next line, should revert! (Even if actually it won't)
        fundMe.fund(); // Sending exactly the minimum USD in ETH
    }

    function testFundUpdatesFundDataStructure() public {
        vm.prank(USER); // Simulate USER as the sender
        vm.deal(USER, 10e18); // Give USER 10 ETH

        fundMe.fund{value: SEND_VALUE}(); // Sending 0.1 ETH

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArraysOfFunders() public funded {
        vm.prank(USER); // Simulate USER as the sender
        vm.deal(USER, 10e18); // Give USER 10 ETH

        fundMe.fund{value: SEND_VALUE}(); // Sending 0.1 ETH

        address funder = fundMe.getFunder(0); // Get the first funder from the array

        // Each function is executed after setUp, so USER is the first funder

        assertEq(funder, USER);
    }

    modifier funded() {
        // Modifier to fund the contract before running the test
        // This modifier will be used to ensure the contract is funded before running tests
        vm.prank(USER); // Simulate USER as the sender
        vm.deal(USER, 10e18); // Give USER 10 ETH
        fundMe.fund{value: SEND_VALUE}(); // USER funds the contract
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); // Simulate USER as the sender

        vm.expectRevert(); // Expect revert with custom error
        // expertRevert -> Hey, I expect the next call to revert — if it doesn't, that's a test failure
        fundMe.withdraw(); // USER tries to withdraw
    }

    function testWithdrawWithSingleFunder() public funded {
        // ARRANGE
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // Get the owner's balance before withdrawal
        uint256 startingFundMeBalance = address(fundMe).balance; // Get the FundMe contract's balance before withdrawal

        // ACT
        vm.prank(fundMe.getOwner()); // Simulate the owner as the sender
        fundMe.withdraw(); // Owner withdraws funds

        // ASSERT
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // Get the owner's balance after withdrawal
        uint256 endingFundMeBalance = address(fundMe).balance; // Get the FundMe contract's balance after withdrawal

        assertEq(
            endingFundMeBalance,
            0,
            "FundMe balance should be 0 after withdrawal"
        );
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance,
            "Owner's balance should be increased by FundMe balance"
        );
    }

    function testWithdrawWithMultipleFunders() public funded {
        // ARRANGE
        // This test simulates multiple funders funding the contract and then the owner withdrawing the funds
        // We will create 10 funders, each funding the contract with SEND_VALUE
        // The owner should be able to withdraw all funds, and the contract balance should be 0 after withdrawal
        uint256 numberOfFunders = 10; // Number of funders to simulate
        address[] memory funders = new address[](numberOfFunders); // Array to store funders
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // Get the owner's balance

        // Fund multiple users
        for (uint256 i = 0; i < numberOfFunders; i++) {
            funders[i] = address(uint160(i + 1)); // Create unique addresses for each funder
            // We are using uint160 to convert the index to a valid address type
            // This is a simple way to create unique addresses for testing purposes.
            // In a real-world scenario, you would use actual user addresses.
            vm.deal(funders[i], SEND_VALUE); // Give each funder some ETH
            vm.prank(funders[i]); // Simulate each funder as the sender
            fundMe.fund{value: SEND_VALUE}(); // Each funder funds the contract
        }

        uint256 startingFundMeBalance = address(fundMe).balance; // Get the FundMe contract's balance
        // We place startingFundMeBalance here AFTER the loop to accurately capture
        // the total contract balance after all 10 funders have contributed.
        // If placed before the loop, it would only include the fixture funding (from the `funded` modifier),
        // not the additional contributions from the simulated funders, causing an incorrect assertion.

        // ACT
        vm.prank(fundMe.getOwner()); // Simulate the owner as the sender
        fundMe.withdraw(); // Owner withdraws funds

        // ASSERT
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // Get the owner's balance after withdrawal
        uint256 endingFundMeBalance = address(fundMe).balance; // Get the FundMe contract's balance after withdrawal

        assertEq(
            endingFundMeBalance,
            0,
            "FundMe balance should be 0 after withdrawal"
        );

        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance,
            "Owner's balance should be increased by FundMe balance"
        );
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        // ARRANGE
        // This test simulates multiple funders funding the contract and then the owner withdrawing the funds
        // We will create 10 funders, each funding the contract with SEND_VALUE
        // The owner should be able to withdraw all funds, and the contract balance should be 0 after withdrawal
        uint256 numberOfFunders = 10; // Number of funders to simulate
        address[] memory funders = new address[](numberOfFunders); // Array to store funders
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // Get the owner's balance

        // Fund multiple users
        for (uint256 i = 0; i < numberOfFunders; i++) {
            funders[i] = address(uint160(i + 1)); // Create unique addresses for each funder
            // We are using uint160 to convert the index to a valid address type
            // This is a simple way to create unique addresses for testing purposes.
            // In a real-world scenario, you would use actual user addresses.
            vm.deal(funders[i], SEND_VALUE); // Give each funder some ETH
            vm.prank(funders[i]); // Simulate each funder as the sender
            fundMe.fund{value: SEND_VALUE}(); // Each funder funds the contract
        }

        uint256 startingFundMeBalance = address(fundMe).balance; // Get the FundMe contract's balance
        // We place startingFundMeBalance here AFTER the loop to accurately capture
        // the total contract balance after all 10 funders have contributed.
        // If placed before the loop, it would only include the fixture funding (from the `funded` modifier),
        // not the additional contributions from the simulated funders, causing an incorrect assertion.

        // ACT
        vm.prank(fundMe.getOwner()); // Simulate the owner as the sender
        fundMe.cheaperWithdraw(); // Owner withdraws funds

        // ASSERT
        uint256 endingOwnerBalance = fundMe.getOwner().balance; // Get the owner's balance after withdrawal
        uint256 endingFundMeBalance = address(fundMe).balance; // Get the FundMe contract's balance after withdrawal

        assertEq(
            endingFundMeBalance,
            0,
            "FundMe balance should be 0 after withdrawal"
        );

        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance,
            "Owner's balance should be increased by FundMe balance"
        );
    }
}
