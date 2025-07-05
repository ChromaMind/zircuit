// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/ChromaMind.sol"; // <-- Make sure this points to your contract

contract DeployChromaMind is Script {
    function run() external returns (ChromaMind) {
        // These are the constructor arguments for your ChromaMind contract
        string memory name = "ChromaMind Trips";
        string memory symbol = "TRIP";
        string memory baseURI = "https://api.chromamind.io/trips/";
        
        // The address that runs this script (your wallet) will become the owner
        address initialOwner = msg.sender; 
        
        // Royalty fee in basis points (500 = 5%)
        uint96 royaltyFee = 500; 

        // This command tells Foundry to start broadcasting transactions to the live network
        vm.startBroadcast();

        // Deploy the contract with the arguments defined above
        ChromaMind chromaMind = new ChromaMind(
            name,
            symbol,
            baseURI,
            initialOwner,
            royaltyFee
        );

        // Stop broadcasting
        vm.stopBroadcast();
        
        return chromaMind;
    }
}