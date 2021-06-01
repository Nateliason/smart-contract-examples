// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

pragma solidity ^0.8.1;

// You can also just put this in its own file, and then use "import ./Owned.sol"
contract Owned {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    // The _; represents the rest of the contract that follows after this modifier is used
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not allowed");
        _;
    }
}

contract Modifier is Owned {
    mapping(address => uint256) tokenBalance;
    uint256 tokenPrice = 1 ether;

    // Give the owner 100 tokens
    constructor() {
        tokenBalance[owner] = 100;
    }

    // Let the owner add more tokens to their wallet. Notice the "onlyOwner" modifier call.
    function createNewToken() public onlyOwner {
        tokenBalance[owner]++;
    }

    // Let the owner delete tokens
    function burnToken() public onlyOwner {
        tokenBalance[owner]--;
    }
}
