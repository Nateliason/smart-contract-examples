// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

// This is a simple example of how we can build controls into a contract.

pragma solidity ^0.8.1;

contract StartStop {
    address public owner;
    bool public paused;

    // Set the owner of the contract as the person sending it
    constructor() {
        owner = msg.sender;
    }

    // Set the contract to paused
    function setPaused(bool _paused) public {
        require(msg.sender == owner, "You are not the owner");
        paused = _paused;
    }

    // Send money in to the contract
    function sendMoney() public payable {}

    // Withdraw all the money in the contract to someone
    function withdrawAllMoney(address payable _to) public {
        require(msg.sender == owner, "You are not the owner");
        require(paused == false, "Contract is paused");
        _to.transfer(address(this).balance);
    }

    // Destroy the smart contract
    function destroySmartContract(address payable _to) public {
        require(msg.sender == owner, "You are not the owner");
        require(paused == false, "Contract is paused");
        selfdestruct(_to);
    }
}
