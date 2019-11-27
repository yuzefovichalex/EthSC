pragma solidity ^0.5.11;

//import "./Ownable.sol"; Ownable can be in another file

contract Ownable {
    address payable internal owner;
   
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    function transferOwnership(address payable newOwner) public {
        owner = newOwner;
    }
    
    function kill() 
        external 
        onlyOwner 
    {
        selfdestruct(owner);
    }
}

contract LandSale is Ownable {
    
    struct Land {
        bool exists;
        uint cost;
        bool soldOut;
        Bid bid;
    }
    
    struct Bid {
        address owner;
        bool accepted;
    }
    
    address payable private companyAddress;
    
    mapping (uint => Land) private lands;
    
    event BidProcessed(uint landId, address bidOwner, bool approved);
    
    modifier notSold(uint landId) { 
        require(!_soldOut(landId), "This land has already been sold."); 
        _;
    }
    
    modifier landExists(uint landId) { 
        require(_exists(landId), "Land with this id doesn't exists!"); 
        _;
    }
    
    
    constructor(address payable _companyAddress) public {
        companyAddress = _companyAddress;
    }
    
    
    function _soldOut(uint landId) internal view returns (bool) {
        return lands[landId].soldOut;
    }
    
    function _exists(uint landId) internal view returns (bool) {
        return lands[landId].exists;
    }
    
    function _hasBid(uint landId) internal view returns (bool) {
        return lands[landId].bid.owner != address(0);
    }
    
    
    function addLand(uint id, uint _cost)
        public
        onlyOwner
    {
        require(!_exists(id), "Land with this id already exists.");
        Bid memory _bid = Bid({
            owner: address(0),
            accepted: false
            
        });
        Land memory newLand = Land({
            exists: true,
            cost: _cost,
            soldOut: false,
            bid: _bid
        });
        lands[id] = newLand;
    }
    
    function addBid(uint landId) 
        public
        landExists(landId)
        notSold(landId)
    {
        require(!_hasBid(landId), "There is already a bid for this land.");
        Land storage selectedLand = lands[landId];
        Bid memory newBid = Bid({
            owner: msg.sender,
            accepted: false
        });
        selectedLand.bid = newBid;
    }
    
    function processBid(uint landId, bool approve)
        public
        onlyOwner
        landExists(landId)
        notSold(landId)
    {
        require(_hasBid(landId), "This land doesn't have bid.");
        Bid storage landBid = lands[landId].bid;
        emit BidProcessed(landId, landBid.owner, approve); 
        if (approve) {
            landBid.accepted = true;
        } else {
            landBid.accepted = false;
            landBid.owner = address(0);
        }
    }
    
    function pay(uint landId) 
        public 
        payable
        landExists(landId)
        notSold(landId)
    {
        Land storage selectedLand = lands[landId];
        Bid storage landBid = selectedLand.bid;
        require(landBid.owner == msg.sender, "You can't pay this land, because you don't have a bid for this or your bid was declined.");
        require(landBid.accepted, "You cannot pay land because your bid has not yet been approved");
        require(msg.value == selectedLand.cost, "Incorrect payment amount!");
        selectedLand.soldOut = true;
    }
    
    function kill()
        external
        onlyOwner
    {
        selfdestruct(companyAddress);
    }
    
}