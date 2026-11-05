// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract YachtRental {

    // state variables
    address payable public owner;
    bool public available;
    uint public ratePerDay;

    event Log(address indexed sender, string message);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = payable(msg.sender);
        available = true;
        ratePerDay = 1 ether;
    }

    // Caller must be the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Must be the contract owner to use this function.");
        _;
    }

    // Yacht must be available to book
    modifier whenAvailable() {
        require(available, "Yacht not available.");
        _;
    }

    // Must book at least one day
    modifier validDays(uint numDay) {
        require(numDay > 0, "Must book at least one day.");
        _;
    }

    // Address can't be the zero address
    modifier validAddress(address addr) {
        require(addr != address(0), "Invalid address.");
        _;
    }

    function bookYacht(uint numDay) public payable whenAvailable validDays(numDay) {
        // Check payment
        uint minOffer = ratePerDay * numDay;
        require(msg.value >= minOffer, "Insufficient payment.");

        // Update state before sending ETH
        available = false;

        // Receive payment
        (bool sent, ) = owner.call{value: msg.value}("");
        require(sent, "Transaction failed. Try again.");

        emit Log(msg.sender, "Yacht is booked.");
    }

    function makeYachtAvailable() public onlyOwner {
        available = true;
        emit Log(msg.sender, "Yacht is now available.");
    }

    function updateRate(uint newRate) public onlyOwner {
        ratePerDay = newRate;
        emit Log(msg.sender, "Rate updated.");
    }

    function transferYachtOwnership(address payable newOwner) public onlyOwner validAddress(newOwner) {
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}