# FundMe

A simple Ethereum smart contract project that allows users to fund the contract, and only the owner can withdraw the funds.

---

## Overview

This project demonstrates a basic crowdfunding smart contract built with Solidity and tested using Foundry.  
Users can send ETH to the contract as a contribution, and the contract owner can withdraw the collected funds.

---

## Features

- Users can fund the contract with ETH.
- Contract owner can withdraw the total balance.
- Keeps track of the amount funded by each address.
- Uses Chainlink Price Feeds to convert ETH value for additional functionality (optional).
- Written and tested with Foundry.

---

## Contracts

- `FundMe.sol` — Main contract where users fund ETH and owner withdraws.
- `PriceConverter.sol` — Utility library to get ETH price from Chainlink oracles.
- `MockV3Aggregator.sol` — Mock contract for local testing Chainlink price feeds.

---

## Requirements

- [Foundry](https://github.com/foundry-rs/foundry) — Solidity development toolkit
- Solidity 0.8.x

---

## How to use

1. **Clone the repo**

   ```bash
   git clone <repo-url>
   cd FundMe

2. **Install Foundry**
Follow instructions at https://github.com/foundry-rs/foundry#installation

3. **Run tests**
forge test

4. **Format code**
forge fmt

5. **Deploy**
Use Foundry scripting or your preferred deployment method.

How it works
Users call the fund() function and send ETH.
The contract stores the amount funded per address.
Only the owner (deployer) can call withdraw() to transfer funds out.
After withdrawal, funders’ records reset.

Contributing
Feel free to open issues or submit pull requests to improve the contract or tests.

License
MIT License

Contact
If you have questions or suggestions, please open an issue or reach out!