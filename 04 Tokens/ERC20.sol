//SPDX-License-Identifier: MIT

// Standard ERC20 token contract using the OpenZeppelin template. Yes it's this simple! 

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";


contract NatCoin is ERC20 {
    // Mint the Raider token with a supply of 100,000,000
    constructor () ERC20("Nat Coin", "NAT") {
        _mint(msg.sender, 100000000 * (10 ** uint256(decimals())));
    }
}