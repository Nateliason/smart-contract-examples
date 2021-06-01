// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

pragma solidity ^0.8.1;

// We can import the SafeMath functions from Zeppelin to make sure we don't accidentally wrap around in our functions
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";

contract LibrariesExample {
    mapping(address => uint256) public tokenBalance;

    using SafeMath for uint256;

    constructor() {
        tokenBalance[msg.sender] = 1;
    }

    function sendToken(address _to, uint256 _amount) public returns (bool) {
        tokenBalance[msg.sender] = tokenBalance[msg.sender].sub(_amount); // this is using SafeMath for subtraction
        tokenBalance[_to] = tokenBalance[_to].add(_amount); // this is using SafeMath for addition

        return true;
    }
}
