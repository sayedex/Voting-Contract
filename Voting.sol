pragma solidity ^0.8.0;

contract Voting {


    address public chairperson;
    //  mapping(address => mapping(uint256 => uint256)) public myMapping;

   struct MyStruct {
        string name;
        uint256 voteCount;
    }

    mapping(uint256 =>mapping(address => bool)) public voters;
    mapping(uint256 => MyStruct) public proposala;

    uint256 public count;
    event ProposalAdded(uint256 proposalID);
    event Voted(address voter, uint256 proposalID);
    event WinnerAnnounced(string proposalName);

    constructor() {
        chairperson = msg.sender;
    }

    function addProposal(string memory _name) external {
        require(msg.sender == chairperson, "Only the chairperson can add proposals");
        MyStruct memory newStruct = MyStruct({
           name: _name,
           voteCount:0
        });
    proposala[count] = newStruct;
    count++;
        emit ProposalAdded(count);
    }

    function vote(uint256 _proposalID) public {
        require(!voters[_proposalID][msg.sender], "You have already voted");
        require(_proposalID < count, "Invalid proposal ID");

        voters[_proposalID][msg.sender]=true;
        proposala[_proposalID].voteCount++;

        emit Voted(msg.sender, _proposalID);
    }

    function getWinner() public view returns (string memory) {
        uint256 winningVoteCount = 0;
        uint256 winningProposalID = 0;

        for (uint256 i = 0; i < count; i++) {
            if (proposala[i].voteCount > winningVoteCount) {
                winningVoteCount = proposala[i].voteCount;
                winningProposalID = i;
            }
        }

        return proposala[winningProposalID].name;
    }

    function announceWinner() public {
        require(msg.sender == chairperson, "Only the chairperson can announce the winner");

        string memory winningProposal = getWinner();

        emit WinnerAnnounced(winningProposal);
    }
}
