pragma solidity ^0.5.0;

contract Ballot {

    struct Voter {
       
        bool voted;  // if true, that person already voted
        uint vote;   // index of the voted proposal
    }

    // single proposal.
    struct Proposal {
        string name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
        address addr;
    }

    address public chairperson;
    address public winner_address;
    string public WinnerName;
    uint public votingendtime;

    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    constructor (string memory proposals)public {votingendtime= now + 24 hours;
    }
        
    
    
    function create_proposals(address Agreement_add, address Not_In_Agreement_add) public {
        chairperson=msg.sender;
        proposals.push(Proposal({name: 'Agreement',voteCount: 0,addr: Agreement_add}));
        proposals.push(Proposal({name: 'Not_In_Agreement',voteCount: 0,addr: Not_In_Agreement_add}));
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        require(now< votingendtime, "Voting has ended");
        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += 1;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function Announce_winner() public
                {
        WinnerName = proposals[winningProposal()].name;
        winner_address=proposals[winningProposal()].addr;
    }
   
}
