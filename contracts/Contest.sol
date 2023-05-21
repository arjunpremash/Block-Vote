pragma solidity 0.5.16;

//import "./Ownable.sol";

contract Contest{
	
	struct Contestant{
		uint id;
		string name;
		uint voteCount;
		string party;
		uint age;
		string qualification;
	}

	struct Voter{
		bool hasVoted;
		uint vote;
		bool isRegistered;
	}

	address admin;
	mapping(uint => Contestant) public contestants; 
   // mapping(address => bool) public voters;
    mapping(address => Voter) public voters;
	uint public contestantsCount;
	// uint public counter;
	enum PHASE{reg, voting , done}
	PHASE public state;

	modifier onlyAdmin(){
		require(msg.sender==admin);
		_;
	}
	
	modifier validState(PHASE x){
	    require(state==x);
	    _;
	}

	constructor() public{
		admin=msg.sender;
        state=PHASE.reg;
		// counter = 0;

	}

    function changeState(PHASE x) onlyAdmin public{
		require(x > state);
        state = x;
    }

	// Event for failure when adding a contestant
    event ContestantAdditionFailed(string name, string party);

	function addContestant(string memory _name , string memory _party , uint _age , string memory _qualification) public onlyAdmin validState(PHASE.reg){
		// Check if the contestant already exists
		for (uint i = 1; i <= contestantsCount; i++) {
    		Contestant storage existingContestant = contestants[i];
    		if (keccak256(bytes(existingContestant.name)) == keccak256(bytes(_name)) && keccak256(bytes(existingContestant.party)) == keccak256(bytes(_party))) {
    			emit ContestantAdditionFailed(_name, _party);
                return;
			}
		}

		contestantsCount++;
		contestants[contestantsCount]=Contestant(contestantsCount,_name,0,_party,_age,_qualification);
	}

	function voterRegisteration(address user) public onlyAdmin validState(PHASE.reg){
		voters[user].isRegistered=true;
	}

	event DuplicateVote(address indexed voter);

	function vote(uint _contestantId) public validState(PHASE.voting){
        
		require(voters[msg.sender].isRegistered);
		//require(!voters[msg.sender].hasVoted);
        require(_contestantId > 0 && _contestantId<=contestantsCount);

		if (voters[msg.sender].hasVoted) {
        	emit DuplicateVote(msg.sender);
        	return;
    	}

		contestants[_contestantId].voteCount++;
		voters[msg.sender].hasVoted=true;
		voters[msg.sender].vote=_contestantId;
	}
}