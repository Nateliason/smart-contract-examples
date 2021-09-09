//SPDX-License-Identifier: MIT

// This is a version of the ERC20 token contract where you can mint more, burn tokens, and pause all token actions
// Good for an in-gmae currency or something similar where you don't want it completely uncontrolled

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "hardhat/console.sol";


contract GameToken is ERC20PresetMinterPauser {
    // initate the Aurum token and create 1,000,000,000 of it 
    constructor () ERC20PresetMinterPauser("Game Token", "GOLD") {
      _mint(msg.sender, 1000000000 * (10 ** uint256(decimals())));
    }   
}