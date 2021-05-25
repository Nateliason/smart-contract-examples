// SPDX-License-Identifier: GPL-3.0
// From Ethereum Blockchain Developer Bootcamp: https://www.udemy.com/course/blockchain-developer/

pragma solidity ^0.8.1;

contract ExceptionHandling {
    address payable public owner;
    mapping(address => uint256) public balanceReceived;

    // Constructors are only fired on contract creation, they're not callable afterwards.
    constructor() {
        owner = payable(msg.sender);
    }

    // View functions just let you see some data, they don't interact with other functions like Destroy Contract and they're usually free to run
    function getOwner() public view returns (address) {
        return owner;
    }

    // Pure functions don't interact with variables like "owner" but they're also reading functions
    function convertToWei(uint256 _amount) public pure returns (uint256) {
        return _amount / 1 ether;
    }

    function destroyContract() public {
        require(msg.sender == owner, "You are not the owner");
        selfdestruct(owner);
    }

    // A payable function can receive money to the smart contract
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

    // Receive creates a fallback in case someone just sends the contract money
    receive() external payable {
        receiveMoney();
    }
}
