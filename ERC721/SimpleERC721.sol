// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Contrato simples, que permite o mint por qualquer usuário e tem um max_supply
 */
contract TokenCollection is ERC721{
    uint256 private _nextTokenId;
    uint256 quantityMinted;
    uint256 maxSupply;

    constructor(uint256 maxSupply_)
        ERC721("TokenCollection", "TCL")
    {
        maxSupply = maxSupply_;
        quantityMinted = 0;
    }

    function safeMint() public {
        require(quantityMinted + 1 <= maxSupply, 'Will exceeds max supply token');
        uint256 tokenId = _nextTokenId++;
        quantityMinted++;
        _safeMint(msg.sender, tokenId);
    }
}