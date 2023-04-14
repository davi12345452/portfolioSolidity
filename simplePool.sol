// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Pool {
    address public manager;
    mapping(address => uint256) public balances;
    uint256 public totalBalance;

    constructor() {
        manager = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        totalBalance += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        totalBalance -= amount;
        payable(msg.sender).transfer(amount);
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function getTotalBalance() public view returns (uint256) {
        return totalBalance;
    }

    function transfer(address recipient, uint256 amount) public {
        require(amount <= balances[msg.sender], "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }

    modifier restricted() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }
}
