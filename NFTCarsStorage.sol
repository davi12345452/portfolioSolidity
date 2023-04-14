// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/utils/Strings.sol";

contract CarNFT is ERC721 {
    using Strings for uint256;

    struct Car {
        string make;
        string model;
        uint256 year;
        string color;
    }

    Car[] private cars;

    constructor() ERC721("CarNFT", "CAR") {}

    function mint(string memory make, string memory model, uint256 year, string memory color) external {
        cars.push(Car({
            make: make,
            model: model,
            year: year,
            color: color
        }));
        uint256 tokenId = cars.length - 1;
        _mint(msg.sender, tokenId);
    }

    function getCar(uint256 tokenId) external view returns (string memory make, string memory model, uint256 year, string memory color) {
        require(_exists(tokenId), "Token does not exist");
        Car storage car = cars[tokenId];
        return (car.make, car.model, car.year, car.color);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        Car memory car = cars[tokenId];
        string memory json = string(abi.encodePacked(
            '{"name": "', car.make, ' ', car.model, '", ',
            '"description": "', car.year.toString(), ' ', car.color, '", ',
            '"image": "ipfs://Qm...', '", ',
            '"attributes": [',
            '{"trait_type": "Make", "value": "', car.make, '"},',
            '{"trait_type": "Model", "value": "', car.model, '"},',
            '{"trait_type": "Year", "value": "', car.year.toString(), '"},',
            '{"trait_type": "Color", "value": "', car.color, '"}',
            ']}'
        ));
        string memory baseURI = "https://example.com/nfts/";
        return string(abi.encodePacked(baseURI, tokenId.toString(), "/", json));
    }
}