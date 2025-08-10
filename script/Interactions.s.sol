// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {console} from "forge-std/console.sol";

contract FundFundMe is Script {
    uint256 public constant SEND_VALUE = 0.1 ether;

    function fund(address fundMeAddress) public {
        vm.startBroadcast();
        FundMe(payable(fundMeAddress)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        fund(0x2F308f776Bf654e3E068801925a8dc3C9830390A);
    }
}

contract WithdrawFundMe is Script {
    function withdraw(address fundMeAddress) public {
        vm.startBroadcast();
        FundMe(payable(fundMeAddress)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrew FundMe balance!");
    }

    function run() external {
        withdraw(0x2F308f776Bf654e3E068801925a8dc3C9830390A);
    }
}
