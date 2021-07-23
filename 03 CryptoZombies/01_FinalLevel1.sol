// This is the final contract for the first level of CryptoZombies! https://cryptozombies.io/

pragma solidity >=0.5.0 <0.6.0;

contract ZombieFactory {

  // Make an event for when a new Zombie is created
  event NewZombie(uint zombieId, string name, uint dna);

  // Basic variable declarations
  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;

  // Create our Zombie structure
  struct Zombie {
    string name;
    uint dna;
  }

  // Create an empty public array of all the zombies
  Zombie[] public zombies;

  // Private function for creating a new zombie based on a name and dna number
  function _createZombie(string memory _name, uint _dna) private {
    uint id = zombies.push(Zombie(_name, _dna)) - 1;
    emit NewZombie(id, _name, _dna);
  }

  // Pseudorandom insecure!! number generation for the DNA
  function _generateRandomDna(string memory _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

  // Create the zombie! This one is public
  function createRandomZombie(string memory _name) public {
    uint randDna = _generateRandomDna(_name);
    _createZombie(_name, randDna);
  }

}
