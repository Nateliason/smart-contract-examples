// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

pragma solidity ^0.8.1;

contract ExceptionHandling {
    mapping(address => uint256) public balanceReceived;

    function receiveMoney() public payable {
        assert(
            balanceReceived[msg.sender] + msg.value >=
                balanceReceived[msg.sender]
        );
        balanceReceived[msg.sender] += msg.value;
    }

    function withdrawMoney(address payable _to, uint256 _amount) public {
        require(
            _amount <= balanceReceived[msg.sender],
            "You don't have enough money"
        );
        assert(
            balanceReceived[msg.sender] - _amount <= balanceReceived[msg.sender]
        );
        balanceReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }
}
