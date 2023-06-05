// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "./shibahelper.sol";

/** 
 * @title A contract for Shiba Inu battles
 * @author Augustin Bracco
 */
contract ShibaAttack is ShibaHelper {
    uint randNonce = 0;
    uint attackVictoryProbability = 70;

    /**
     * @notice Event that is emitted when a battle occurs
     */
    event AttackResult(uint indexed _shibaId, uint indexed _targetId, bool victory);

    /**
     * @notice Generates a random number
     * @param _modulus The upper limit for the random number
     * @return The random number
     */
    function randMod(uint _modulus) internal returns(uint) {
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
    }

    /**
     * @notice Conduct a Shiba battle
     * @dev Shiba owners can initiate a battle with another Shiba
     * @param _shibaId The ID of the Shiba initiating the attack
     * @param _targetId The ID of the Shiba being attacked
     */
    function attack(uint _shibaId, uint _targetId) external onlyOwnerOf(_shibaId) {
        Shiba storage myShiba = shibas[_shibaId];
        Shiba storage enemyShiba = shibas[_targetId];
        uint rand = randMod(100);
        if (rand <= attackVictoryProbability) {
            myShiba.winCount++;
            myShiba.level++;
            enemyShiba.lossCount++;
            feedAndMultiply(_shibaId, enemyShiba.dna, "shiba");
            emit AttackResult(_shibaId, _targetId, true);
        } else {
            myShiba.lossCount++;
            enemyShiba.winCount++;
            _triggerCooldown(myShiba);
            emit AttackResult(_shibaId, _targetId, false);
        }
    }
}
