// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

// This contracts goes over how we can handle exceptions using "require" and "assert"
// They're somewhat similar functions, so this explainer is helpful: https://ethereum.stackexchange.com/questions/15166/difference-between-require-and-assert-and-the-difference-between-revert-and-thro
// You more often want to use require

// Assert is suitable for checking conditions which are not meant to occur but do.
// Require is suitable for checking for unwanted conditions which can occur.

pragma solidity ^0.8.1;

contract ExceptionHandling {
    mapping(address => uint256) public balanceReceived;

    function receiveMoney() public payable {
        // Make sure the balance doesn't "wrap around" at the top of the uint range
        assert(
            balanceReceived[msg.sender] + msg.value >=
                balanceReceived[msg.sender]
        );
        balanceReceived[msg.sender] += msg.value;
    }

    function withdrawMoney(address payable _to, uint256 _amount) public {
        // Make sure they have enough funds
        require(
            _amount <= balanceReceived[msg.sender],
            "You don't have enough money"
        );
        // Make sure the balance doesn't wrap around at 0
        assert(
            balanceReceived[msg.sender] - _amount <= balanceReceived[msg.sender]
        );
        balanceReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
}
