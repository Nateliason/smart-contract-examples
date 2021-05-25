// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

pragma solidity ^0.8.1;

contract Payments {
    uint256 public balanceReceived;

    function receivePayment() public payable {
        balanceReceived += msg.value;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawBalance() public {
        address payable to = payable(msg.sender);

        to.transfer(getBalance());
    }

    function withdrawMoneyTo(address payable _to) public {
        _to.transfer(getBalance());
    }
}
