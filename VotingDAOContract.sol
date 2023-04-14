// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/access/Ownable.sol";

contract Voting is Ownable {
    struct Proposal {
        string description;
        uint256 voteCount;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public numProposals;

    mapping(address => bool) public voters;
    uint256 public numVoters;

    event NewProposal(uint256 indexed proposalId, string description);
    event VoteCast(uint256 indexed proposalId, address indexed voter);

    function addVoter(address voter) external onlyOwner {
        require(!voters[voter], "Address is already a voter");
        voters[voter] = true;
        numVoters++;
    }

    function addProposal(string memory description) external onlyOwner {
        proposals[numProposals] = Proposal({
            description: description,
            voteCount: 0
        });
        numProposals++;
        emit NewProposal(numProposals - 1, description);
    }

    function castVote(uint256 proposalId) external {
        require(voters[msg.sender], "Address is not a voter");
        require(!proposals[proposalId].hasVoted[msg.sender], "Address has already voted");
        proposals[proposalId].hasVoted[msg.sender] = true;
        proposals[proposalId].voteCount++;
        emit VoteCast(proposalId, msg.sender);
    }

    function getProposalVoteCount(uint256 proposalId) public view returns (uint256) {
        return proposals[proposalId].voteCount;
    }

    function hasVoted(address voter, uint256 proposalId) public view returns (bool) {
        return proposals[proposalId].hasVoted[voter];
    }
}