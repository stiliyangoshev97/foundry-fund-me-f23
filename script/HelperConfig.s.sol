// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

// 1. Deploy mock when we are on a local anvil chain
// 2. Keep track of contract addresses accross different chains
// Sepolia ETH/USD
// Mainnet ETH/USD

contract HelperConfig is Script {
    // If we are on a local anvil, we deploy mocks
    // Otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; // 2000 USD with 8 decimals

    struct NetworkConfig {
        address priceFeed; // Eth/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            // block.chainid allows us to check the current chain ID
            // Sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            // ETH Mainnet
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Sepolia ETH/USD Price Feed Address
        // https://docs.chain.link/data-feeds/price-feeds/addresses
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // Mainnet ETH/USD Price Feed Address
        // https://docs.chain.link/data-feeds/price-feeds/addresses
        NetworkConfig memory mainnetConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            // If we already have a price feed for Anvil, return it
            return activeNetworkConfig;
        }
        // Anvil ETH/USD Price Feed Address
        // 1. Deploy the mocs
        // 2. Return the mock address
        // This is a mock address, replace with actual mock address if needed
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); // 2000 USD with 8 decimals
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}
