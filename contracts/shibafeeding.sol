// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "./shibafactory.sol";

/**
 * @title Interface for Kitty contract
 */
interface KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

/** 
 * @title ShibaFeeding contract
 * @author Augustin Bracco
 * @notice This contract manages feeding and breeding of the Shiba NFTs
 */
contract ShibaFeeding is ShibaFactory {
  KittyInterface kittyContract;

  /**
   * @notice Ensure the caller is the owner of the given Shiba
   */
  modifier onlyOwnerOf(uint _shibaId) {
    require(msg.sender == shibaToOwner[_shibaId], "Caller is not the owner");
    _;
  }

  /**
   * @notice Set the Kitty Contract address
   * @dev Only the contract owner can call this function
   * @param _address The address of the Kitty contract
   */
  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  /**
   * @dev Triggers a cooldown for a Shiba after breeding
   * @param _shiba A reference to the Shiba struct
   */
  function _triggerCooldown(Shiba storage _shiba) internal {
    _shiba.readyTime = uint32(block.timestamp + cooldownTime);
  }

  /**
   * @notice Check if a Shiba is ready for breeding
   * @param _shiba A reference to the Shiba struct
   * @return bool Whether the Shiba is ready or not
   */
  function _isReady(Shiba storage _shiba) internal view returns (bool) {
    return (_shiba.readyTime <= block.timestamp);
  }

  /**
   * @notice Feed a Shiba and breed a new Shiba
   * @dev Only the owner of the Shiba can call this function
   * @param _shibaId The ID of the Shiba being fed
   * @param _targetDna The DNA of the food
   * @param _species The species of the food
   */
  function feedAndMultiply(uint _shibaId, uint _targetDna, string memory _species) internal onlyOwnerOf(_shibaId) {
    Shiba storage myShiba = shibas[_shibaId];
    require(_isReady(myShiba), "Shiba is not ready");
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myShiba.dna + _targetDna) / 2;
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createShiba("NoName", newDna);
    _triggerCooldown(myShiba);
  }

  /**
   * @notice Feed a Shiba with a Kitty
   * @param _shibaId The ID of the Shiba being fed
   * @param _kittyId The ID of the Kitty being fed to the Shiba
   */
  function feedOnKitty(uint _shibaId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_shibaId, kittyDna, "kitty");
  }
}
