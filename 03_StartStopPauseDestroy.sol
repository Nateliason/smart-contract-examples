// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

pragma solidity ^0.8.1;

contract StartStop {
    address public owner;
    bool public paused;

    constructor() {
        owner = msg.sender;
    }

    function setPaused(bool _paused) public {
        require(msg.sender == owner, "You are not the owner");
        paused = _paused;
    }

    function sendMoney() public payable {}

    function withdrawAllMoney(address payable _to) public {
        require(msg.sender == owner, "You are not the owner");
        require(paused == false, "Contract is paused");
        _to.transfer(address(this).balance);
    }

    function destroySmartContract(address payable _to) public {
        require(msg.sender == owner, "You are not the owner");
        require(paused == false, "Contract is paused");
        selfdestruct(_to);
    }
}
