// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

pragma solidity ^0.8.1;

contract EventExample {
    mapping(address => uint256) public tokenBalance;

    // Create the template for the event
    event TokensSent(address _from, address _to, uint256 _amount);

    constructor() {
        tokenBalance[msg.sender] = 100;
    }

    function sendTokens(uint256 _amount, address _to) public returns (bool) {
        require(
            tokenBalance[msg.sender] >= _amount,
            "you don't have enough tokens"
        );
        assert(tokenBalance[msg.sender] - _amount <= tokenBalance[msg.sender]);
        assert(tokenBalance[_to] + _amount >= tokenBalance[_to]);
        tokenBalance[msg.sender] -= _amount;
        tokenBalance[_to] += _amount;

        //This creates a readable event of what happened since the "return true" won't provide much data
        emit TokensSent(msg.sender, _to, _amount);

        return true;
    }
}
