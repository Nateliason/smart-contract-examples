// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

pragma solidity ^0.8.1;

contract WorkingWithVariables {
    bool public truthy;
    uint256 public myInt;
    address public myAddress;
    string public myString;

    function setMyInt(uint256 _myInt) public {
        myInt = _myInt;
    }

    function truthyChange(bool _truthy) public {
        truthy = _truthy;
    }

    function incrementMyInt() public {
        myInt++;
    }

    function decrementMyInt() public {
        myInt--;
    }

    function setMyAddress() public {
        myAddress = msg.sender;
    }

    function getMyBalance() public view returns (uint256) {
        return myAddress.balance;
    }

    function setString(string memory newString) public {
        myString = newString;
    }

    function getMyString() public view returns (string memory) {
        return myString;
    }
}
