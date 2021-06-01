// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

// This is a very simple contract for doing payments.

pragma solidity ^0.8.1;

contract Payments {
    uint256 public balanceReceived;

    // Send money in to the contract
    function receivePayment() public payable {
        balanceReceived += msg.value;
    }

    // Get the balance of the contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Withdraw the balance in the contract to your address
    function withdrawBalance() public {
        address payable to = payable(msg.sender);

        to.transfer(getBalance());
    }

    // Send money in the contract to someone else
    function withdrawMoneyTo(address payable _to) public {
        _to.transfer(getBalance());
    }
}
