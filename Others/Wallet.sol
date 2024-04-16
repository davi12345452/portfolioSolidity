// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Contrato simples que simula um carteira de ETHER, qualquer moeda base da blockchain que é utilizado.
 */
contract Wallet is Ownable{

    constructor() Ownable(msg.sender){}

    receive() external payable {}

    function withdraw(uint256 _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}