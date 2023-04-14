// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC20/IERC20.sol";

contract StakingContract {
    IERC20 public token;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        bool withdrawn;
    }

    mapping(address => Stake[]) public stakes;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function stake(uint256 _amount, uint256 _duration) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_duration > 0, "Duration must be greater than 0");

        uint256 endTime = block.timestamp + _duration;
        token.transferFrom(msg.sender, address(this), _amount);

        stakes[msg.sender].push(Stake({
            amount: _amount,
            startTime: block.timestamp,
            endTime: endTime,
            withdrawn: false
        }));
    }

    function withdraw(uint256 stakeIndex) external {
        Stake storage s = stakes[msg.sender][stakeIndex];
        require(!s.withdrawn, "Stake already withdrawn");
        require(block.timestamp >= s.endTime, "Stake period not ended");

        s.withdrawn = true;
        token.transfer(msg.sender, s.amount);
    }
}