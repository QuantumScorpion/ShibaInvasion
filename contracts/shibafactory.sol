// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "./ownable.sol";

/**
 * @title ShibaFactory
 * @dev This contract manages the creation of Shiba entities. Each Shiba has unique DNA, a level, win/loss records, and a name.
 * @author Augustin Bracco
 */
contract ShibaFactory is Ownable {

  /**
   * @dev Emitted when a new Shiba is created
   */
  event NewShiba(uint shibaId, string name, uint dna);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint cooldownTime = 1 days;

  /**
   * @dev Struct for Shiba entity
   */
  struct Shiba {
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
  }

  Shiba[] public shibas;

  mapping (uint => address) public shibaToOwner;
  mapping (address => uint) ownerShibaCount;

  /**
   * @dev Internal function to create a new Shiba
   */
  function _createShiba(string memory _name, uint _dna) internal {
    shibas.push(Shiba(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0));
    uint id = shibas.length - 1;
    shibaToOwner[id] = msg.sender;
    ownerShibaCount[msg.sender]++;
    emit NewShiba(id, _name, _dna);
  }

  /**
   * @dev Generate a random number for Shiba's DNA
   */
  function _generateRandomDna(string memory _str) private view returns (uint) {
    uint rand = uint(keccak256(abi.encodePacked(_str)));
    return rand % dnaModulus;
  }

  /**
   * @dev Public function to create a random Shiba
   */
  function createRandomShiba(string memory _name) public {
    require(ownerShibaCount[msg.sender] == 0);
    uint randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 100;
    _createShiba(_name, randDna);
  }
}
