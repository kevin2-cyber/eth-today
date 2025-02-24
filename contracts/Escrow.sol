// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// define the smart contract
contract Escrow {

  // enum to represent the different states of the escrow process
  enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED }

  // public state variable to store the address of the buyer
  address public buyer;

  // public state variable to store the payable address of the seller
  address payable public seller;
  
  // public state variable to store the address of the escrow agent (trusted third party)
  address public escrowAgent;

  // public state variable to track the current state of the escrow
  State public currentState;

  // constructor function to initialize the contract with the buyer, seller, and escrow agent
  constructor(address _buyer, address payable _seller) {
      buyer = _buyer; // Set the buyer's address
      seller = _seller; // Set the seller's payable address
      escrowAgent = msg.sender; // The deployer of the contract becomes the escrow agent
      currentState = State.AWAITING_PAYMENT; // Initialize the escrow state to 'AWAITING_PAYMENT'
  }

  // modifier to restrict access to functions only to the buyer
  modifier onlyBuyer() {
      require(msg.sender == buyer, "Only the buyer can call this function.");
      _;
  }

  // modifier to restrict access to functions only to the escrow agent
  modifier onlyEscrowAgent() {
      require(msg.sender == escrowAgent, "Only the escrow agent can call this function.");
      _;
  }

  // modifier to ensure that the function is called only when the contract is in the expected state
  modifier inState(State expectedState) {
      require(currentState == expectedState, "Invalid state.");
      _;
  }

  // function for the buyer to deposit funds into the escrow
  function deposit() external payable onlyBuyer inState(State.AWAITING_PAYMENT) {
      require(msg.value > 0, "Deposit must be greater than 0."); // Ensure the deposit amount is greater than 0
      currentState = State.AWAITING_DELIVERY; // Update the state to 'AWAITING_DELIVERY'
  }

  // function for the buyer to confirm delivery and release funds to the seller
  function confirmDelivery() external onlyBuyer inState(State.AWAITING_DELIVERY) {
      currentState = State.COMPLETE; // Update the state to 'COMPLETE'
      seller.transfer(address(this).balance); // Transfer the escrowed funds to the seller
  }

  // function for the escrow agent to refund the buyer if conditions are not met
  function refund() external onlyEscrowAgent inState(State.AWAITING_DELIVERY) {
      currentState = State.REFUNDED; // Update the state to 'REFUNDED'
      payable(buyer).transfer(address(this).balance); // Refund the escrowed funds to the buyer
  }
}
