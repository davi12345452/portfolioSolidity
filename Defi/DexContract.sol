// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleDEX {
    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }

    mapping(bytes32 => Token) public tokens;
    bytes32[] public tokenList;

    mapping(address => mapping(bytes32 => uint256)) public balances;

    event Deposit(address indexed account, bytes32 indexed ticker, uint256 amount);
    event Withdraw(address indexed account, bytes32 indexed ticker, uint256 amount);
    event Buy(address indexed buyer, bytes32 indexed ticker, uint256 amount);
    event Sell(address indexed seller, bytes32 indexed ticker, uint256 amount);

    function addToken(bytes32 _ticker, address _tokenAddress) external {
        tokens[_ticker] = Token(_ticker, _tokenAddress);
        tokenList.push(_ticker);
    }

    function deposit(bytes32 _ticker, uint256 _amount) external {
        require(tokens[_ticker].tokenAddress != address(0), "Token does not exist");
        IERC20 token = IERC20(tokens[_ticker].tokenAddress);
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        balances[msg.sender][_ticker] += _amount;
        emit Deposit(msg.sender, _ticker, _amount);
    }

    function withdraw(bytes32 _ticker, uint256 _amount) external {
        require(balances[msg.sender][_ticker] >= _amount, "Insufficient balance");
        IERC20 token = IERC20(tokens[_ticker].tokenAddress);
        require(token.transfer(msg.sender, _amount), "Transfer failed");
        balances[msg.sender][_ticker] -= _amount;
        emit Withdraw(msg.sender, _ticker, _amount);
    }

    function buy(bytes32 _ticker, uint256 _amount) external {
        require(tokens[_ticker].tokenAddress != address(0), "Token does not exist");
        require(balances[msg.sender][_ticker] >= _amount, "Insufficient balance");
        uint256 etherAmount = _amount * 1 ether / getLatestPrice(_ticker);
        require(address(this).balance >= etherAmount, "Insufficient liquidity");
        balances[msg.sender][_ticker] -= _amount;
        payable(msg.sender).transfer(etherAmount);
        emit Buy(msg.sender, _ticker, _amount);
    }

    function sell(bytes32 _ticker, uint256 _amount) external {
        require(tokens[_ticker].tokenAddress != address(0), "Token does not exist");
        uint256 etherAmount = _amount * 1 ether / getLatestPrice(_ticker);
        require(address(this).balance >= etherAmount, "Insufficient liquidity");
        IERC20 token = IERC20(tokens[_ticker].tokenAddress);
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        balances[msg.sender][_ticker] += _amount;
        emit Sell(msg.sender, _ticker, _amount);
    }

    function getLatestPrice(bytes32 _ticker) public view returns (uint256) {
        // TODO: Implement function to get latest price from an oracle
        return 1 ether;
    }

    fallback() external payable {}
}