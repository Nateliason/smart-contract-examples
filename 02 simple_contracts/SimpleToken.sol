//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// This creates a very simple token contract, it is NOT ERC20 compliant. This is from https://dev.to/dabit3/the-complete-guide-to-full-stack-ethereum-development-3j13

import "hardhat/console.sol";

contract Token {
    string public name = "Nader Token";
    string public symbol = "NDT";
    uint256 public totalSupply = 1000000;
    mapping(address => uint256) balances;

    constructor() {
        // Set the balance of the person who creates the contract as the total Supply
        balances[msg.sender] = totalSupply;
    }

    // Simple token transfer
    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    // Get an account's balance
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }
}
