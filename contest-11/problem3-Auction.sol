// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Auction {
    address public owner;

    struct AuctionItem {
        uint256 startingPrice;
        uint256 duration;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
        bool active;
    }

    mapping(uint256 => AuctionItem) public auctions;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier auctionActive(uint256 itemNumber) {
        require(auctions[itemNumber].active, "Auction is not active");
        require(
            auctions[itemNumber].endTime > block.timestamp,
            "Auction has ended"
        );
        _;
    }

    modifier auctionNotStartedOrCancelled(uint256 itemNumber) {
        require(!auctions[itemNumber].active, "Auction has already started");
        _;
    }

    modifier highestBidderCheck(uint256 itemNumber) {
        require(
            auctions[itemNumber].active ||
                auctions[itemNumber].endTime <= block.timestamp,
            "Auction is still active"
        );
        _;
    }

    modifier highestBidCheck(uint256 itemNumber) {
        require(auctions[itemNumber].active, "Auction is not active");
        _;
    }

    event AuctionCreated(
        uint256 indexed itemNumber,
        uint256 startingPrice,
        uint256 duration
    );
    event BidPlaced(
        uint256 indexed itemNumber,
        address indexed bidder,
        uint256 bidAmount
    );
    event AuctionCancelled(uint256 indexed itemNumber);
    event AuctionEnded(
        uint256 indexed itemNumber,
        address highestBidder,
        uint256 highestBid
    );

    constructor() {
        owner = msg.sender;
    }

    function createAuction(
        uint256 itemNumber,
        uint256 startingPrice,
        uint256 duration
    ) external onlyOwner auctionNotStartedOrCancelled(itemNumber) {
        require(startingPrice > 0, "Starting price cannot be 0");
        require(duration > 0, "Duration cannot be 0");

        auctions[itemNumber] = AuctionItem({
            startingPrice: startingPrice,
            duration: duration,
            endTime: block.timestamp + duration,
            highestBidder: address(0),
            highestBid: 0,
            active: true
        });

        emit AuctionCreated(itemNumber, startingPrice, duration);
    }

    function bid(
        uint256 itemNumber,
        uint256 bidAmount
    ) external payable auctionActive(itemNumber) {
        require(msg.value == bidAmount, "Sent amount must match bid amount");
        require(
            bidAmount > auctions[itemNumber].highestBid,
            "Bid amount must be higher than current highest bid"
        );

        if (auctions[itemNumber].highestBidder != address(0)) {
            // Refund the previous highest bidder
            payable(auctions[itemNumber].highestBidder).transfer(
                auctions[itemNumber].highestBid
            );
        }

        auctions[itemNumber].highestBidder = msg.sender;
        auctions[itemNumber].highestBid = bidAmount;

        emit BidPlaced(itemNumber, msg.sender, bidAmount);
    }

    function cancelAuction(uint256 itemNumber) external onlyOwner {
        auctions[itemNumber].active = false;
        emit AuctionCancelled(itemNumber);
    }

    function checkAuctionActive(
        uint256 itemNumber
    ) external view returns (bool) {
        return
            auctions[itemNumber].active &&
            auctions[itemNumber].endTime > block.timestamp;
    }

    function timeLeft(
        uint256 itemNumber
    ) external view auctionActive(itemNumber) returns (uint256) {
        return auctions[itemNumber].endTime - block.timestamp;
    }

    function checkHighestBidder(
        uint256 itemNumber
    ) external view highestBidderCheck(itemNumber) returns (address) {
        return auctions[itemNumber].highestBidder;
    }

    function checkActiveBidPrice(
        uint256 itemNumber
    ) external view returns (uint256) {
        require(auctions[itemNumber].active, "Auction is not active");
        return auctions[itemNumber].highestBid;
    }
}
