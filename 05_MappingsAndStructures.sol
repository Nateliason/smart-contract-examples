// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

pragma solidity ^0.8.1;

contract MappingStructExample {
    struct Payment {
        uint256 amount;
        uint256 timestamps;
    }

    struct Balance {
        uint256 totalBalance;
        uint256 numPayments;
        mapping(uint256 => Payment) payments;
    }

    mapping(address => Balance) public balanceReceived;

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function sendMoney() public payable {
        balanceReceived[msg.sender].totalBalance += msg.value;

        Payment memory payment = Payment(msg.value, block.timestamp);
        balanceReceived[msg.sender].payments[
            balanceReceived[msg.sender].numPayments
        ] = payment;
        balanceReceived[msg.sender].numPayments++;
    }

    function sendAllMoney(address payable _to) public {
        uint256 sendAmount = balanceReceived[msg.sender].totalBalance;
        balanceReceived[msg.sender].totalBalance = 0;
        _to.transfer(sendAmount);
    }

    function sendSomeMoney(address payable _to, uint256 amount) public {
        require(
            balanceReceived[msg.sender].totalBalance >= amount,
            "you don't have enough funds"
        );
        balanceReceived[msg.sender].totalBalance -= amount;
        _to.transfer(amount);
    }

    function withdrawAllMoney() public {
        uint256 sendAmount = balanceReceived[msg.sender].totalBalance;
        balanceReceived[msg.sender].totalBalance = 0;
        address payable _to = payable(msg.sender);
        _to.transfer(sendAmount);
    }
}
