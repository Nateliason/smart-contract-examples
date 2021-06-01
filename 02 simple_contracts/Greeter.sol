//SPDX-License-Identifier: Unlicense
// This is a very simple contract to set a greeting, and retrieve a greeting, from https://dev.to/dabit3/the-complete-guide-to-full-stack-ethereum-development-3j13

pragma solidity ^0.8.3;

import "hardhat/console.sol";

contract Greeter {
    string greeting;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
}
