// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

pragma solidity ^0.8.1;

contract SimpleMapping {
    mapping(uint256 => bool) public myInts;
    mapping(address => bool) public whitelist;

    function storeInt(uint256 _index) public {
        myInts[_index] = true;
    }

    function addWhitelist() public {
        whitelist[msg.sender] = true;
    }
}
