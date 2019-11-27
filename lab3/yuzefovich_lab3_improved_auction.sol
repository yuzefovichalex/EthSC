pragma solidity ^0.5.11;

contract YuzefovichAuction {
    
    struct Auction {
        uint lastBid;
        bool isStarted;
        address payable lastBidder;
    }
    
    address payable private owner; // address of owner account
    mapping (uint => Auction) private auctions;
    uint private auctionsCount = 0;
    
    event BidUpdated(address lastBidder, uint lastBid);
    event BidReturned(address bidder, uint returnedBid);
    
    modifier onlyOwner() { require(msg.sender == owner, "Operation not permitted!"); _; }
    
    constructor() public {
        owner = msg.sender; // owner is a creator of contract
    }
    
    function() external payable { }
    
    function startAuction(uint auctionId, uint minBid) 
        public
        onlyOwner
        returns(uint) 
    {
        require(auctionsCount < 2, "Only two auctions can be launched at a time."); // there can be not more than two started auctions
        require(!auctions[auctionId].isStarted, "Auction with this id already exists!"); // can't start already started auction
        auctions[auctionId] = Auction({ // add new auction to map
            lastBid: minBid,
            isStarted: true,
            lastBidder: owner
        });
        auctionsCount++;
        return auctionId;
    }
    
    function bid(uint auctionId) payable public {
        Auction storage selectedAuction = auctions[auctionId];
        uint currentBid = msg.value;
        require(selectedAuction.isStarted, "This auction was finished or not started yet.");
        require(currentBid > selectedAuction.lastBid, "Your bet is less than min value.");
        if (selectedAuction.lastBidder != owner) {
            emit BidReturned(selectedAuction.lastBidder, selectedAuction.lastBid);
            selectedAuction.lastBidder.transfer(selectedAuction.lastBid); // return bet to participant if he is not an owner
        }
        selectedAuction.lastBid = currentBid;
        selectedAuction.lastBidder = msg.sender;
        emit BidUpdated(msg.sender, msg.value);
    }
    
    function finishAuction(uint auctionId) 
        public
        onlyOwner
    {
        require(auctionsCount > 0, "There are no opened acutions.");
        require(auctions[auctionId].isStarted, "Auction with selected ID already finished.");
        auctions[auctionId].isStarted = false;
        auctionsCount--;
    }
    
    function kill()
        public
        onlyOwner
    {
        selfdestruct(owner);
    }
    
}