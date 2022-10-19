//SPDX-License-Identifier: Unlicense


// contracts/BuyMeACoffee.sol
pragma solidity ^0.8.0;
// Switch this to your own contract address once deployed, for bookkeeping!
// Example Contract Address on Goerli: 0xDBa03676a2fBb6711CB652beF5B7416A53c1421D

contract BuyMeACoffee {
    // Event to emit when a Memo is created.
    event NewMemo(
        address indexed from,
        uint256 timestamp,
        string name,
        string message
    );
    
    // Memo struct.
    struct Memo {
        address from;
        uint256 timestamp;
        string name;
        string message;
    }
    
    // Address of contract deployer. Marked payable so that
    // we can withdraw to this address later.
    address payable contract_creator;
    address payable withdraw_address;

    // List of all memos received from coffee purchases.
    Memo[] memos;

    constructor(){
        // Store the address of the deployer as a payable address.
        // When we withdraw funds, we'll withdraw here.
        contract_creator = payable(msg.sender);
        withdraw_address = payable(msg.sender);
    }

    /**
     * @dev fetches all stored memos
     */
    function getMemos() public view returns (Memo[] memory) {
        return memos;
    }

    /**
     * @dev buy a coffee for owner (sends an ETH tip and leaves a memo)
     * @param _name name of the coffee purchaser
     * @param _message a nice message from the purchaser
     */
    function buyCoffee(string memory _name, string memory _message) public payable {
        // Must accept more than 0 ETH for a coffee.
        require(msg.value > 0, "can't buy coffee for free!");

        // Add the memo to storage!
        memos.push(Memo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        ));

        // Emit a NewMemo event with details about the memo.
        emit NewMemo(
            msg.sender,
            block.timestamp,
            _name,
            _message
        );
    }

    /**
     * @dev send the entire balance stored in this contract to the owner
     */
    function withdrawTips() public {
        require(contract_creator == msg.sender, "Access denied. Only owner can request this operation");
        require(withdraw_address.send(address(this).balance), "Only owner can request this operation");
    }

    function updateWithdrawAddress(address _address) public {
        require(contract_creator == msg.sender, "Access denied. Only owner can request this operation");
        withdraw_address = payable(_address);
    }
}