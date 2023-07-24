// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract TicketingContract {

    struct Ticket {
        uint eventId;
        address owner;
        bool isValid;
    }

    event TicketTransfer(uint indexed ticketid, address indexed from, address indexed to);

    mapping(uint => Ticket) public tickets;
    mapping(address => bool) public veri_owners;

    constructor(address[] memory owners) {
        for (uint i = 0; i < owners.length; i++) {
            veri_owners[owners[i]] = true;
        }
    }

    modifier onlyverified_owner() {
        require(veri_owners[msg.sender], "You are not a verified owner");
        _;
    }

    modifier onlyTicketOwner(uint ticketId) {
        require(tickets[ticketId].owner == msg.sender, "Only ticket owner can perform this action");
        _;
    }

    function createTickets(uint ticketId, uint eventId) external onlyverified_owner {
        require(tickets[ticketId].owner == address(0), "Ticket Id already exists");
        require(tickets[ticketId].isValid == false, "Ticket Id already exists");
        tickets[ticketId] = Ticket(eventId, address(0), true);
    }

    function purchaseTicket(uint eventId) external payable {
        uint ticketId = uint(keccak256(abi.encodePacked(eventId, msg.sender)));
        require(tickets[ticketId].owner == address(0), "Ticket Id already exists");
        require(tickets[ticketId].isValid == true, "Ticket not available for purchase");
        tickets[ticketId].eventId = eventId;
        tickets[ticketId].owner = msg.sender;
    }

    function transferTicket(uint ticketId, address to) external onlyTicketOwner(ticketId) {
        require(tickets[ticketId].isValid == true, "Invalid ticket Id");
        require(to != address(0), "Invalid recipient address");
        tickets[ticketId].owner = to;
        emit TicketTransfer(ticketId, msg.sender, to);
    }

    function invalidateTickets(uint ticketId) external onlyTicketOwner(ticketId) {
        tickets[ticketId].isValid = false;
    }
}
