// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Anything before startBroadcast is not sent to the chain and is gasless

        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        // Anything after startBroadcast is sent to the chain and costs gas
        FundMe fundMe = new FundMe(ethUsdPriceFeed); // Sepolia ETH/USD Price Feed Address
        vm.stopBroadcast();
        return fundMe;
    }
}
