pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
contract Voting {

    using SafeERC20 for IERC20;
    address public chairperson;
    //  mapping(address => mapping(uint256 => uint256)) public myMapping;

   struct MyStruct {
        string name;
        uint256 voteCount;
        IERC20 token;
        uint256 totalTokenVoted;
    }
    struct userInfo {
        uint256 votePower;
        bool isVoted;
    }

    mapping(uint256 =>mapping(address => userInfo)) public voters;
    mapping(uint256 => MyStruct) public proposala;

    uint256 public count;
    event ProposalAdded(uint256 proposalID);
    event Voted(address voter, uint256 proposalID);
    event WinnerAnnounced(string proposalName);

    constructor() {
        chairperson = msg.sender;
    }

    function addProposal(string memory _name,address _token) external {
        require(msg.sender == chairperson, "Only the chairperson can add proposals");
        MyStruct memory newStruct = MyStruct({
           name: _name,
           voteCount:0,
           token:IERC20(_token),
           totalTokenVoted:0
        });
    proposala[count] = newStruct;
    count++;
        emit ProposalAdded(count);
    }

    function vote(uint256 _proposalID,uint256 _amount) public {
        require(!voters[_proposalID][msg.sender].isVoted, "You have already voted");
        require(_proposalID < count, "Invalid proposal ID");
        MyStruct memory data = proposala[_proposalID];
        data.token.safeTransferFrom(msg.sender, address(this), _amount);
        userInfo memory newUser = userInfo({
            votePower:_amount,
            isVoted:true
        });
        voters[_proposalID][msg.sender]  = newUser;
        proposala[_proposalID].totalTokenVoted += _amount;
        proposala[_proposalID].voteCount++;
        emit Voted(msg.sender, _proposalID);
    }

    function getWinner() public view returns (string memory) {
        uint256 winningVoteCount = 0;
        uint256 winningProposalID = 0;

        for (uint256 i = 0; i < count; i++) {
            if (proposala[i].voteCount > winningVoteCount) {
                winningVoteCount = proposala[i].totalTokenVoted;
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
