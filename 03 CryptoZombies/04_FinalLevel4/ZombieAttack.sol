// The rest of the contracts are the same except for refactoring in the "ownerOf" modifier

pragma solidity >=0.5.0 <0.6.0;

import "./zombiehelper.sol";

contract ZombieAttack is ZombieHelper {
  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  // This gives us an insecure way of generating a random number. 
  // Should be fine in most use cases unless there are huge amounts of money on the line since this is open to attack.
  function randMod(uint _modulus) internal returns(uint) {
    randNonce++;
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
  }


  function attack(uint _zombieId, uint _targetId) external ownerOf(_zombieId) {
    // create pointers for our zombie and the zombie we're attacking
    Zombie storage myZombie = zombies[_zombieId];
    Zombie storage enemyZombie = zombies[_targetId];
    
    // Get a random number 1-100
    uint rand = randMod(100);
    
    // If it wins, do all the things
    if (rand <= attackVictoryProbability) {
      myZombie.winCount++;
      myZombie.level++;
      enemyZombie.lossCount++;
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
    } else { // if it loses, do the other things
      myZombie.lossCount++;
      enemyZombie.winCount++;
      _triggerCooldown(myZombie);
    }
  }
}
