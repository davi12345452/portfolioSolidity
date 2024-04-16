// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * Token ERC20 básico, com deploy e mintagem automática ao owner do contrato.
 */
contract BasicToken is ERC20 {
    constructor() ERC20("BasicToken", "BTK") {
        _mint(msg.sender, 200000 * 10 ** decimals());
    }
}