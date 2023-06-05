// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "./shibafeeding.sol";

/**
 * @title ShibaHelper
 * @dev Contract module which provides utility functions to interact with Shiba entities.
 * @author Augustin Bracco
 */
contract ShibaHelper is ShibaFeeding {

  uint levelUpFee = 0.001 ether;

  /**
   * @dev Modifier to check if the Shiba's level is above a certain level
   */
  modifier aboveLevel(uint _level, uint _shibaId) {
    require(shibas[_shibaId].level >= _level, "The shiba level is lower than required");
    _;
  }

  /**
   * @dev Allows the owner to withdraw contract's balance.
   */
  function withdraw() external onlyOwner {
    address payable _owner = payable(owner());
    _owner.transfer(address(this).balance);
  }

  /**
   * @dev Allows the owner to set the fee for leveling up a Shiba.
   */
  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  /**
   * @dev Allows user to level up a Shiba.
   */
  function levelUp(uint _shibaId) external payable {
    require(msg.value == levelUpFee, "Incorrect value sent");
    shibas[_shibaId].level++;
  }

  /**
   * @dev Allows Shiba's owner to change its name, if it's level 2 or above.
   */
  function changeName(uint _shibaId, string calldata _newName) external aboveLevel(2, _shibaId) onlyOwnerOf(_shibaId) {
    shibas[_shibaId].name = _newName;
  }

  /**
   * @dev Allows Shiba's owner to change its DNA, if it's level 20 or above.
   */
  function changeDna(uint _shibaId, uint _newDna) external aboveLevel(20, _shibaId) onlyOwnerOf(_shibaId) {
    shibas[_shibaId].dna = _newDna;
  }

  /**
   * @dev Gets the IDs of all Shibas owned by a given address.
   */
  function getShibasByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerShibaCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < shibas.length; i++) {
      if (shibaToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
}
