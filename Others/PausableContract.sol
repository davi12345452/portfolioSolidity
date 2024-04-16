// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * Simples Contrato de ERC20 para dar uma utilidade ao Pausable apenas, para entender melhor seu funcionamento
 */
contract PausableERC20 is ERC20, Pausable, Ownable {
    constructor()
        ERC20("PausableToken", "PTK")
        Ownable(msg.sender)
    {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public whenNotPaused{
        _mint(to, amount);
    }
}