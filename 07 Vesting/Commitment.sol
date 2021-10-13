// // SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";

contract Commitment {
    // This should be a decentralized contract for giving someone any asset over time. 
    // Someone can allocate funds to another address for a set amount of time. That address can collect their funds over time. Only the receiver can renounce their funds.
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    address public depositor;
    address public receiver;
    address public token;
    uint public totalAmount;
    uint public paidAmount;
    uint public startTime;
    uint public endTime;
    bool public surrendered;
    bool public active;
    bool public revokable;
    
    address author = address(0xdF88191a81f5F9F39a13f911467EDE0856cEaA88); // this is the polygon address, remember to change if deploying to Ethereum! 
    
    uint bigMultiplier = 1000000000000000000;
    
    constructor(address _receiver, address _token, uint _amount, uint _days, bool _revokable) {
      receiver = _receiver;
      token = _token;
      totalAmount = _amount;
      paidAmount = 0;
      startTime = block.timestamp;
      endTime = block.timestamp + _days.mul(1 days);
      surrendered = false;
      active = false;
      revokable = _revokable;
    }

    modifier depositorOnly() {
      require(msg.sender == depositor, "You did not fund this contract");
      _;
    }

    modifier receiverOnly() {
      require(msg.sender == receiver, "You're not the receiver of these rewards!");
      _;
    }

    modifier revokableOnly() {
      require(revokable == true, "This commitment is non-revokable!");
      _; 
    }
    
    function receiverCut(uint _amount) internal pure returns(uint) {
        return (_amount.div(1000)).mul(997);
    }
    
    function authorCut(uint _amount) internal pure returns(uint) {
        return (_amount.div(1000)).mul(3);
    }
    
    function activate() public {
      active = true;
      depositor = msg.sender;
      IERC20(token).safeTransferFrom(msg.sender, address(this), totalAmount);
    }
    
    function collectRewards() public receiverOnly {
      require(active = true);
      if (block.timestamp > endTime) {
        uint remainingRewards = IERC20(token).balanceOf(address(this)); // since this contract is specific to one person's commitment, we can send them the remaining balance
        paidAmount = totalAmount;
        IERC20(token).safeTransfer(author, authorCut(remainingRewards));
        IERC20(token).safeTransfer(msg.sender, receiverCut(remainingRewards));
      } else if (block.timestamp < endTime) {
        uint unlockedPercent = ((block.timestamp.sub(startTime)).mul(bigMultiplier)).div((endTime.sub(startTime))); // mul by bigMul for decimals
        uint unlockedAmount = (unlockedPercent.mul(totalAmount)).div(bigMultiplier); // divide by bigMul again
        uint collectableAmount = unlockedAmount.sub(paidAmount);
        paidAmount = unlockedAmount;
        IERC20(token).safeTransfer(author, authorCut(collectableAmount));
        IERC20(token).safeTransfer(msg.sender, receiverCut(collectableAmount));
      } 
    }
    
    function surrenderPayment() public receiverOnly {
      surrendered = true;
    }

    function acceleratePayment() public depositorOnly {
      endTime = block.timestamp; // Set the end time to now, jsut in case someone needs to accelerate the commitment for some reason
    }

    function revokePayments() public depositorOnly revokableOnly {
      active = false;
    }

    function reActivatePayments() public depositorOnly revokableOnly {
      active = true;
    }
    
    function removeRewards() public depositorOnly {
      require(surrendered == true || active == false, "The receiver has not surrendered their commitment or the contract is still active!");
      uint remainingRewards = IERC20(token).balanceOf(address(this));
      IERC20(token).safeTransfer(msg.sender, remainingRewards);
    }

    function timeRemaining() public view returns(uint) {
      return endTime.sub(block.timestamp);
    }
}