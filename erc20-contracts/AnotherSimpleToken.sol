// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AnotherSimpleToken is ERC20, Ownable {

    uint256 public maxSupply;
    ERC20 public stableCoinAddress;
    address taxReceiver;

    constructor(
        string memory name_,
        string memory symbol_,
        address stableCoinAddress_,
        address taxReceiver_,
        uint256 maxSupply_
        )
        ERC20(name_, symbol_) {
        stableCoinAddress = ERC20(stableCoinAddress_);
        maxSupply = maxSupply_;
        taxReceiver = taxReceiver_;
    }

    function setStableCoinAddress(address newStableCoinAddress) public onlyOwner {
        coinLivreAddress = ERC20(newStableCoinAddress);
    }

    function setMaxSupply(uint256 newMaxSupply) public onlyOwner {
        require(newMaxSupply >= totalSupply(), "You cannot enter a value smaller than the one already minted");
        maxSupply = newMaxSupply;
    }


    function buyToken(address account, uint256 amount, uint256 coinLivreAmount)
        public
        onlyOwner
    {
        
        bool sentAmount = coinLivreAddress.transferFrom(account, address(stableCoinAddress), coinLivreAmount);
        require(sentAmount, "Failed to buy the token");
        require(totalSupply() + amount <= maxSupply, "Transaction exceeds max supply");
        _mint(account, amount);
    }

    function mint(address account, uint256 amount)
        public
        onlyOwner
    {
        require(totalSupply() + amount <= maxSupply, "Transaction exceeds max supply");
        _mint(account, amount);
    }

    function transfer(address to, uint256 amount) 
    public
    override 
    returns(bool)
    {
        uint256 transferTax = (amount * transferFee)/100;
        address sender = msg.sender;
        require(balanceOf(sender) >= amount, "0x");
        _transfer(sender, to, amount - transferTax);
        _transfer(sender, addressToCL, transferTax);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount)
    public
    override 
    onlyOwner 
    returns (bool) 
    {
        uint256 transferTax = (amount * transferFee)/100;
        require(balanceOf(from) >= amount, "0x");
        _transfer(from, to, amount - transferTax);
        _transfer(from, addressToCL, transferTax);
        return true;
    }

    function burn(address from, uint256 amount) 
    public 
    onlyOwner 
    {
        _burn(from, amount);
    }

    function burnBatch(address[] memory addresses, uint256[] memory amounts) public onlyOwner{
        require(addresses.length == amounts.length, "Arrays length mismatch");
        for(uint256 i = 0; i < addresses.length; i++){
            _burn(addresses[i], amounts[i]);
        }
    } 
}