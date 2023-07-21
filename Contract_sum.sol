// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketingContract {

    struct Ticket {
        uint eventId;
        address owner;
        bool isValid;
    }

  
    mapping(uint => Ticket) public tickets;
    mapping(address=>bool) public veri_owners;
    

    
    event TicketTransfer(uint indexed ticketId, address indexed from, address indexed to);

    modifier onlyverified_owner(){
        require(veri_owners[msg.sender],"You are not a verified owner");
        _;
    }
    modifier onlyTicketOwner(uint ticketId) {
        require(tickets[ticketId].owner == msg.sender, "Only ticket owner can perform this action");
        _;
    }
    
    constructor(address[] memory owners){
        for(uint i=0;i<owners.length;i++){
            veri_owners[owners[i]]=true;
        }

    }

    
    function createTicket(uint ticketId, uint eventId) external onlyverified_owner {
        require(tickets[ticketId].owner == address(0), "Ticket ID already exists");
        tickets[ticketId] = Ticket(eventId, address(0), true);
    }

    
    function purchaseTicket(uint ticketId) external payable {
        require(tickets[ticketId].isValid, "Invalid ticket ID");
        require(tickets[ticketId].owner == address(0), "Ticket is already owned");
        tickets[ticketId].owner = msg.sender;
    }

    
    function transferTicket(uint ticketId, address to) external onlyTicketOwner(ticketId) {
        require(tickets[ticketId].isValid, "Invalid ticket ID");
        require(to != address(0), "Invalid recipient address");
        tickets[ticketId].owner = to;
        emit TicketTransfer(ticketId, msg.sender, to);
    }
    
    function invalidateTicket(uint ticketId) external onlyTicketOwner(ticketId) {
        tickets[ticketId].isValid = false;
    }
}
