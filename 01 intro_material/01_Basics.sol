// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

// This contract has a bunch of examples of simple functions, like changing an integer, boolean, etc.

pragma solidity ^0.8.1;

contract WorkingWithVariables {
    // Set our variables
    bool public truthy;
    uint256 public myInt;
    address public myAddress;
    string public myString;

    // Change an integer
    function setMyInt(uint256 _myInt) public {
        myInt = _myInt;
    }

    // Change a boolean
    function truthyChange(bool _truthy) public {
        truthy = _truthy;
    }

    // Increase an integer
    function incrementMyInt() public {
        myInt++;
    }

    // Decrease an integer
    function decrementMyInt() public {
        myInt--;
    }

    // Set the address to the sender of the contract
    function setMyAddress() public {
        myAddress = msg.sender;
    }

    // Get the balance of an address
    function getMyBalance() public view returns (uint256) {
        return myAddress.balance;
    }

    // Change the value of a string
    function setString(string memory newString) public {
        myString = newString;
    }

    // Get the value of the string
    function getMyString() public view returns (string memory) {
        return myString;
    }
}
