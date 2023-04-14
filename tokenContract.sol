// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    uint256 private _maxSupply;
    uint256 private _totalMinted;
    uint256 private _tokenPrice;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(uint256 initialSupply, uint256 maxSupply, uint256 tokenPrice) ERC20("MyToken", "MTK") {
        require(initialSupply <= maxSupply, "Initial supply cannot exceed max supply");
        _maxSupply = maxSupply;
        _totalMinted = initialSupply;
        _tokenPrice = tokenPrice;
        _mint(msg.sender, initialSupply);
    }

    function mint(address account, uint256 amount) external onlyOwner {
        require(_totalMinted + amount <= _maxSupply, "Minting would exceed max supply");
        _totalMinted += amount;
        _mint(account, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function buyTokens() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        uint256 amount = msg.value / _tokenPrice;
        require(_totalMinted + amount <= _maxSupply, "Minting would exceed max supply");
        _totalMinted += amount;
        _balances[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function sellTokens(uint256 amount) external {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _totalMinted -= amount;
        uint256 etherAmount = amount * _tokenPrice;
        payable(msg.sender).transfer(etherAmount);
        emit Transfer(msg.sender, address(0), amount);
    }

    function setTokenPrice(uint256 newPrice) external onlyOwner {
        _tokenPrice = newPrice;
    }

    function totalMinted() external view returns (uint256) {
        return _totalMinted;
    }

    function maxSupply() external view returns (uint256) {
        return _maxSupply;
    }

    function tokenPrice() external view returns (uint256) {
        return _tokenPrice;
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