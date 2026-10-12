// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {

    uint256 private counter; // Tracks the IDs of proposals

    struct Proposal {
        string title;              // Brief title of the proposal
        string description;        // Description of the proposal
        uint256 approve;           // Number of approve votes
        uint256 reject;            // Number of reject votes
        uint256 pass;              // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state;        // This shows the current state of the proposal, meaning whether it passes or fails
        bool is_active;            // This shows if others can vote on our contract
    }

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals

    function create(
        string calldata _title,
        string calldata _description,
        uint256 _total_vote_to_end
    ) external {
        counter += 1;
        proposal_history[counter] = Proposal(
            _title,
            _description,
            0,                   // approve
            0,                   // reject
            0,                   // pass
            _total_vote_to_end,
            false,               // current_state
            true                 // is_active
        );
    }
}
