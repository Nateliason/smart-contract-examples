//SPDX-License-Identifier: Unlicense

// This HAS NOT BEEN USED IN PRODUCTION. I feel pretty good about it but use at your own risk!! 
// Also you may need a separate database instance for pulling in the sales so you don't risk hitting the gas limit when pulling in data

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Marketplace is ReentrancyGuard, Ownable, Pausable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint bigNum = 10**18;

  // Counters is just an OZ library for making a counter that can only increment or decrement. Good for generating IDs and tracking other info. 
  using Counters for Counters.Counter;
  Counters.Counter private _listingIds;
  Counters.Counter private _offerIds;

  // We can have a list of approved addresses for NFTs, prevents scams
  mapping(address => bool) approvedNFTs;
  address[] nftAddresses;

  // Controlling sale status
  mapping(address => mapping(uint => bool)) tokenSaleStatus;

  // Quicker lookups for different lists
  mapping(address => uint[]) nftContractListings;
  mapping(address => uint[]) userListings;
  mapping(address => uint[]) userOffers;
  // A nested mapping for finding past sales of an item. First address is the NFT contract, second int is the Token ID, then this is the listings for that Address Token
  mapping(address => mapping(uint => uint[])) nftContractItemListings;
  mapping(address => mapping(uint => uint[])) nftContractItemOffers;

  // And then another mapping for the ACTIVE listing for an item
  mapping(address => mapping(uint => uint)) nftContractItemCurrentListing;

  // Let's just do Buy It Now to start, then we can add auction types
  // Will we have them all in the same listings? Or separate ones? 
  // We could create multiple structures, where there's a parent one for items being listed and then sub ones for different types of transactions?

  // Gotta add IERC20
  address aurumAddress;

  function aurum() internal view returns(IERC20) {
    return IERC20(aurumAddress);
  }

  struct Listing {
    uint listingId;
    address nftContract;
    uint tokenId;
    address seller; // useful to distinguish this for historical data, so we can see who sold it at what price
    address owner;
    uint price;
    uint endPrice;
    bool sold;
    bool active;
    uint startTime;
    uint endTime;
  }

  struct Offer {
    uint offerId;
    address nftContract;
    uint tokenId;
    address buyer;
    uint price;
    bool sold;
    bool active;
    uint expiresAt;
  }

  event ListingCreated (
    uint indexed listingId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address seller,
    address owner,
    uint256 price,
    bool sold
  );

  mapping(uint => Listing) private idToListing;
  mapping(uint => Offer) private idToOffer;
  
  constructor(address _aurum) {
      aurumAddress = _aurum;
  }

  // Places an item for sale on the marketplace
  function createListing(address nftContract, uint tokenId, uint price, uint endPrice, uint duration) public nonReentrant whenNotPaused {
    require(price > 0, "Price must be at least 1 wei");
    require(isNFTApproved(nftContract), "This NFT contract is not approved for the marketplace!");
    require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "You don't own this token!");
    require(IERC721(nftContract).isApprovedForAll(msg.sender, address(this)), "You haven't approved the marketplace to transfer your NFTs");
    require(endPrice <= price, "You can't have an end price higher than the start price!");
    require(tokenSaleStatus[nftContract][tokenId] == false, "This token is already for sale!");

    _listingIds.increment();
    uint listingId = _listingIds.current(); // sale ID might be a better name here 
    
    uint endTime;
    
    if (duration == 0) {
      endTime = 0;
    } else {
      endTime = block.timestamp.add(duration);
    }
    
    nftContractListings[nftContract].push(listingId);
    userListings[msg.sender].push(listingId);
    nftContractItemListings[nftContract][tokenId].push(listingId);
    nftContractItemCurrentListing[nftContract][tokenId] = listingId;
    tokenSaleStatus[nftContract][tokenId] = true; // we can use this to make sure things are only for sale once

    idToListing[listingId] =  Listing(
      listingId, // we just generated this
      nftContract, // supplied by the transaction
      tokenId, // supplied by the transaction
      msg.sender, // Both of these as the msg.sender for now, can change owner later after transfer
      msg.sender, // Both of these as the msg.sender for now, can change owner later after transfer
      price, // from the transaction
      endPrice,
      false, // sold
      true, // active
      block.timestamp,
      endTime
    );

    emit ListingCreated(listingId, nftContract, tokenId, msg.sender, msg.sender, price, false);
  }

  function purchaseListing(uint listingId) public nonReentrant whenNotPaused {
    Listing storage listing = idToListing[listingId];
    
    require(listing.sold == false, "This item has already been sold!");
    require(listing.active == true, "This sale has been cancelled.");
    require(listing.endTime == 0 || block.timestamp < listing.endTime, "This listing has expired!");
    uint tokenId = listing.tokenId;
    address nftContract = listing.nftContract;
    address seller = listing.seller;

    uint price;
    if (listing.endTime == 0){
      price = listing.price;
    } else {
      price = getCurrentPrice(listingId);
    }

    idToListing[listingId].owner = msg.sender;
    idToListing[listingId].sold = true;

    tokenSaleStatus[nftContract][tokenId] = false; // we can use this to make sure things are only for sale once

    aurum().safeTransferFrom(msg.sender, seller, price);
    IERC721(nftContract).transferFrom(seller, msg.sender, tokenId);
  }

  function makeOffer(address nftContract, uint tokenId, uint price, uint expiresIn) public nonReentrant whenNotPaused {
    require(price > 0, "Price must be at least 1 wei");
    require(isNFTApproved(nftContract), "This NFT contract is not approved for the marketplace!");
    require(aurum().allowance(msg.sender, address(this)) >= price, "You need to add Aurum Allowance!");
    require(aurum().balanceOf(msg.sender) >= price, "You don't have enough Aurum!");

    uint expiresAt = block.timestamp.add(expiresIn);

    _offerIds.increment();
    uint offerId = _offerIds.current();

    userOffers[msg.sender].push(offerId);
    nftContractItemOffers[nftContract][tokenId].push(offerId);

    idToOffer[offerId] = Offer(
      offerId,
      nftContract,
      tokenId,
      msg.sender,
      price,
      false,
      true,
      expiresAt
    );
  }

  function acceptOffer(uint offerId) public nonReentrant whenNotPaused {
    Offer storage offer = idToOffer[offerId];

    require(offer.active == true, "This offer is no longer valid!");
    require(offer.sold == false, "This offer has already been completed!");
    require(block.timestamp < offer.expiresAt, "This offer has expired");
    require(IERC721(offer.nftContract).ownerOf(offer.tokenId) == msg.sender, "You don't own this token!");
    require(IERC721(offer.nftContract).isApprovedForAll(msg.sender, address(this)), "You haven't approved the marketplace to transfer your NFTs");

    offer.sold = true;
    offer.active = false;
    
    aurum().safeTransferFrom(offer.buyer, msg.sender, offer.price);
    IERC721(offer.nftContract).transferFrom(msg.sender, offer.buyer, offer.tokenId);
  }

  function cancelListing(uint listingId) public {
    Listing storage listing = idToListing[listingId];

    require(listing.active == true, "This listing was already canceled");
    require(listing.sold == false, "This listing was already sold!");
    require(listing.seller == msg.sender, "You're not the one selling this!");

    listing.active = false;
    tokenSaleStatus[listing.nftContract][listing.tokenId] = false;
  }

  function cancelOffer(uint offerId) public {
    Offer storage offer = idToOffer[offerId];

    require(offer.buyer == msg.sender, "You didn't make this offer!");
    require(offer.active == true, "This offer is already cancelled!");
    require(offer.sold == false, "This offer was already accepted!");
    require(block.timestamp < offer.expiresAt, "This offer has already expired!");

    offer.active = false;
  }

  // MANAGING APPROVED NFT CONTRACTS

  function addApprovedNFT(address _address) public onlyOwner {
    approvedNFTs[_address] = true;
    nftAddresses.push(_address);
  }

  function removeApprovedNFT(address _address) public onlyOwner {
    approvedNFTs[_address] = false;
  }

  function isNFTApproved(address _address) public view returns(bool) {
    return approvedNFTs[_address];
  }

  function fetchNFTAddresses() public view returns(address[] memory) {
    return nftAddresses;
  }
  
  // Admin FUNCTIONS
  
  function pause() public onlyOwner {
      _pause();
  }
  
  function unPause() public onlyOwner {
      _unpause();
  }

  // HELPER FUNCTIONS

  function getCurrentPrice(uint listingId) public view returns(uint){
    Listing memory listing = idToListing[listingId];
    uint startPrice = listing.price;
    uint priceDifference = listing.price.sub(listing.endPrice);
    uint totalDuration = listing.endTime.sub(listing.startTime);
    uint durationPassed = block.timestamp.sub(listing.startTime);
    uint bigDurationPassed = durationPassed.mul(bigNum);
    uint bigFraction = bigDurationPassed.div(totalDuration);
    uint bigPriceFraction = bigFraction.mul(priceDifference);
    uint priceFraction = bigPriceFraction.div(bigNum);
    uint currentPrice = startPrice.sub(priceFraction);
    return currentPrice;
  }


  // VIEW FUNCTIONS

  function fetchAllListings() public view returns(Listing[] memory) {
    uint totalListingCount = _listingIds.current();
    uint currentIndex = 0;

    Listing[] memory listings = new Listing[](totalListingCount);

    for (uint i = 0; i < totalListingCount; i++) {
      Listing memory listing = idToListing[i.add(1)];
      listings[currentIndex] = listing;
      currentIndex++;
    }

    return listings;
  }

  function fetchAllNFTContractListings(address _address) public view returns(Listing[] memory) {
    uint totalListingCount = nftContractListings[_address].length;
    uint currentIndex = 0;

    Listing[] memory listings = new Listing[](totalListingCount);

    for (uint i = 0; i < totalListingCount; i++) {
      uint id = nftContractListings[_address][i];
      Listing memory listing = idToListing[id];
      listings[currentIndex] = listing;
      currentIndex++;
    }

    return listings;
  }

  function fetchNFTContractItemListings(address _address, uint tokenId) public view returns(Listing[] memory) {
    uint totalListingCount = nftContractItemListings[_address][tokenId].length;
    uint currentIndex = 0;

    Listing[] memory listings = new Listing[](totalListingCount);

    for (uint i =  0; i < totalListingCount; i++) {
      uint id = nftContractItemListings[_address][tokenId][i];
      Listing memory listing = idToListing[id];
      listings[currentIndex] = listing;
      currentIndex++;
    }

    return listings;
  }

  function fetchOffer(uint offerId) public view returns(Offer memory) {
    return idToOffer[offerId];
  }

  function fetchListing(uint listingId) public view returns(Listing memory) {
    return idToListing[listingId];
  }

  function fetchCurrentListingId() public view returns(uint) {
    return _listingIds.current();
  }

  function fetchCurrentOfferId() public view returns(uint) {
    return _offerIds.current();
  }

  function isTokenForSale(address _address, uint _tokenId) public view returns(bool) {
    return tokenSaleStatus[_address][_tokenId];
  }

  function fetchCurrentItemListing(address _address, uint _tokenId) public view returns(uint) {
    return nftContractItemCurrentListing[_address][_tokenId];
  }
}
