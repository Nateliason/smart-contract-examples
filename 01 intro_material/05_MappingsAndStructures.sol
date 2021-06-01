// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

// How to do mappings as well as structures

pragma solidity ^0.8.1;

contract MappingStructExample {
    // Create a new payments structure with Amounts and Timestamps
    struct Payment {
        uint256 amount;
        uint256 timestamps;
    }

    // Create a new Balance structure with the "total balance," "number of payments," and payments history as a mapping using the Payment struct
    struct Balance {
        uint256 totalBalance;
        uint256 numPayments;
        mapping(uint256 => Payment) payments;
    }

    // Create a new mapping of addresses to a Balance struct
    mapping(address => Balance) public balanceReceived;

    // Get the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Send in money to the contract and have it be tracked in your balance
    function sendMoney() public payable {
        balanceReceived[msg.sender].totalBalance += msg.value;

        Payment memory payment = Payment(msg.value, block.timestamp);
        balanceReceived[msg.sender].payments[
            balanceReceived[msg.sender].numPayments
        ] = payment;
        balanceReceived[msg.sender].numPayments++;
    }

    // Send all the money in the contract to someone
    function sendAllMoney(address payable _to) public {
        uint256 sendAmount = balanceReceived[msg.sender].totalBalance;
        balanceReceived[msg.sender].totalBalance = 0;
        _to.transfer(sendAmount);
    }

    // Send some of the money in the contract to someone
    function sendSomeMoney(address payable _to, uint256 amount) public {
        require(
            balanceReceived[msg.sender].totalBalance >= amount,
            "you don't have enough funds"
        );
        balanceReceived[msg.sender].totalBalance -= amount;
        _to.transfer(amount);
    }

    // Withdraw all the money in the contract
    function withdrawAllMoney() public {
        uint256 sendAmount = balanceReceived[msg.sender].totalBalance;
        balanceReceived[msg.sender].totalBalance = 0;
        address payable _to = payable(msg.sender);
        _to.transfer(sendAmount);
    }
}
