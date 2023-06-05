// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "./shibaattack.sol";
import "./erc721.sol";

/** 
 * @title ShibaOwnership contract
 * @author Augustin Bracco
 * @notice This contract manages ownership of the Shiba NFTs
 */
contract ShibaOwnership is ShibaAttack, ERC721 {

  mapping (uint => address) shibaApprovals;

  /**
   * @notice Get the balance of the owner
   * @param _owner Address of the owner
   * @return uint256 The number of NFTs owned by the given address
   */
  function balanceOf(address _owner) external view override returns (uint256) {
    return ownerShibaCount[_owner];
  }

  /**
   * @notice Get the owner of the Shiba NFT
   * @param _tokenId The ID of the Shiba NFT
   * @return address The address of the owner of the NFT
   */
  function ownerOf(uint256 _tokenId) external view override returns (address) {
    return shibaToOwner[_tokenId];
  }

  /**
   * @dev Transfer a Shiba NFT from one address to another
   * @param _from Address transferring the NFT
   * @param _to Address receiving the NFT
   * @param _shibaId The ID of the Shiba NFT being transferred
   */
  function _transfer(address _from, address _to, uint256 _shibaId) private {
    ownerShibaCount[_to]++;
    ownerShibaCount[_from]--;
    shibaToOwner[_shibaId] = _to;
    emit Transfer(_from, _to, _shibaId);
  }

  /**
   * @notice Transfer a Shiba NFT from one address to another
   * @dev Checks that the caller is the owner or approved
   * @param _from Address transferring the NFT
   * @param _to Address receiving the NFT
   * @param _shibaId The ID of the Shiba NFT being transferred
   */
  function transferFrom(address _from, address _to, uint256 _shibaId) external payable override {
    require(shibaToOwner[_shibaId] == msg.sender || shibaApprovals[_shibaId] == msg.sender, "Caller is not the owner nor approved");
    _transfer(_from, _to, _shibaId);
  }

  /**
   * @notice Approve an address to manage a Shiba NFT
   * @dev Only the owner can call this function
   * @param _approved The address to be approved
   * @param _shibaId The ID of the Shiba NFT
   */
  function approve(address _approved, uint256 _shibaId) external payable override onlyOwnerOf(_shibaId) {
    shibaApprovals[_shibaId] = _approved;
    emit Approval(msg.sender, _approved, _shibaId);
  }
}
