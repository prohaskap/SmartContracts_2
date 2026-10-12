// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {

    // ****************** Data ***********************

    address owner;
    uint256 private counter;

    struct Proposal {
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool current_state;
        bool is_active;
    }

    mapping(uint256 => Proposal) proposal_history;
    address[] private voted_addresses;

    // ****************** Constructor ***********************

    constructor() {
        owner = msg.sender;
        voted_addresses.push(msg.sender);
    }

    // ****************** Modifiers ***********************

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true);
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has already voted");
        _;
    }

    // ****************** Execute Functions ***********************

    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    function create(
        string calldata _title,
        string calldata _description,
        uint256 _total_vote_to_end
    ) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(
            _title, _description, 0, 0, 0, _total_vote_to_end, false, true
        );
    }

    function vote(uint8 choice) external active newVoter(msg.sender) {
        Proposal storage proposal = proposal_history[counter];
        uint256 totalvote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if (choice == 1) {
            proposal.approve += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 2) {
            proposal.reject += 1;
            proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
            proposal.pass += 1;
            proposal.current_state = calculateCurrentState();
        }

        if ((proposal.total_vote_to_end - totalvote == 1) && (choice == 1 || choice == 2 || choice == 0)) {
            proposal.is_active = false;
            voted_addresses = [owner];
        }
    }

    // ****************** Helper Functions ***********************

    // Checks if the current proposal is passing.
    // Rules:
    //   1. At least half of the planned votes must be cast (quorum).
    //   2. Approve votes must be at least two-thirds of all votes cast.
    //   3. Pass votes count toward the totalvote but act like a soft "no".
    function calculateCurrentState() private view returns(bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;
        uint256 totalvote = approve + reject + pass;

        if (totalvote * 2 < proposal.total_vote_to_end) {
            return false;
        }

        return approve * 3 >= totalvote * 2;
    }

    // Checks whether an address has already voted on the current proposal.
    // Loops through all addresses that have voted so far.
    function isVoted(address _address) public view returns (bool) {
        for (uint256 i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == _address) {
                return true;
            }
        }
        return false;
    }
}
