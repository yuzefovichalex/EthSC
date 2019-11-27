pragma solidity ^0.4.25;

contract YuzefovichAuction {
    
    struct Auction {
        uint lastBid;
        bool isStarted;
        address lastBidder;
    }
    
    address owner; // address of owner account
    mapping (uint => Auction) auctions;
    uint auctionsCount = 0;
    
    constructor() public {
        owner = msg.sender; // owner is a creator of contract
    }
    
    function startAuction(uint auctionId, uint minBid) public {
        require(msg.sender == owner, "Operation not permitted!"); // only owner can start
        require(auctionsCount < 2, "Only two auctions can be launched at a time."); // there can be not more than two started auctions
        require(!auctions[auctionId].isStarted, "Auction with this id already exists!"); // can't start already started auction
        auctions[auctionId] = Auction({ // add new auction to map
            lastBid: minBid,
            isStarted: true,
            lastBidder: owner
        });
        auctionsCount++;
    }
    
    function bid(uint auctionId) payable public {
        Auction storage selectedAuction = auctions[auctionId];
        uint currentBid = msg.value;
        require(selectedAuction.isStarted, "This auction was finished or not started yet.");
        require(currentBid > selectedAuction.lastBid, "Your bet is less than min value.");
        if (selectedAuction.lastBidder != owner) {
            selectedAuction.lastBidder.transfer(selectedAuction.lastBid); // return bet to participant if he is not an owner
        }
        selectedAuction.lastBid = currentBid;
        selectedAuction.lastBidder = msg.sender;
    }
    
    function finishAuction(uint auctionId) public {
        require(msg.sender == owner, "Operation not permitted!"); // only owner can finish
        require(auctionsCount > 0, "There are no opened acutions.");
        require(auctions[auctionId].isStarted, "Auction with selected ID already finished.");
        auctions[auctionId].isStarted = false;
        auctionsCount--;
    }
    
}