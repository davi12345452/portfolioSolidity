// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Este é um contrato um pouco mais complexo de ERC20 que permite maior arbitragem do Owner do contrato, além
 * de compras do token por outros usuários.
 */
contract SimpleToken is ERC20, Ownable {
    uint256 private maxSupply;
    uint256 private totalMinted;
    uint256 private tokenPrice;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(
        uint256 initialSupply_,
        uint256 maxSupply_,
        uint256 tokenPrice_
    ) ERC20("MyToken", "MTK")
      Ownable(msg.sender) 
    {
        maxSupply = maxSupply_;
        require(initialSupply_ <= maxSupply, "Initial supply cannot exceed max supply");
        totalMinted = initialSupply_;
        tokenPrice = tokenPrice_;
        _mint(msg.sender, initialSupply_);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        require(totalMinted + amount <= maxSupply, "Minting would exceed max supply");
        totalMinted += amount;
        _mint(account, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function buyTokens() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        uint256 amount = msg.value / tokenPrice;
        require(totalMinted + amount <= maxSupply, "Minting would exceed max supply");
        totalMinted += amount;
        _balances[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function setTokenPrice(uint256 newPrice) external onlyOwner {
        tokenPrice = newPrice;
    }

    function findTotalMinted() external view returns (uint256) {
        return totalMinted;
    }

    function findMaxSupply() external view returns (uint256) {
        return maxSupply;
    }

    function findTokenPrice() external view returns (uint256) {
        return tokenPrice;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }
}