// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

// This gives a basic example of how to do mappings

pragma solidity ^0.8.1;

contract SimpleMapping {
    // Create two example mappings
    mapping(uint256 => bool) public myInts;
    mapping(address => bool) public whitelist;

    // add integers to the "myInts" mapping
    function storeInt(uint256 _index) public {
        myInts[_index] = true;
    }

    // Add addresses to the whitelist mapping
    function addWhitelist() public {
        whitelist[msg.sender] = true;
    }
}
