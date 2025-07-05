// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ChromaMind.sol";

contract ChromaMindTest is Test {
    ChromaMind public chromaMind;
    address public owner = makeAddr("owner");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    // This function runs before each test
    function setUp() public {
        // Deploy the contract as the 'owner'
        vm.startPrank(owner);
        chromaMind = new ChromaMind(
            "ChromaMind Trips",
            "TRIP",
            "https://api.chromamind.io/trips/",
            owner,
            500 // 5% royalty
        );
        vm.stopPrank();
    }

    // Test 1: Can a user mint a trip?
    function test_MintTrip() public {
        vm.startPrank(user1);
        bytes32 tripHash = keccak256("trip1");
        chromaMind.mintTrip(tripHash);
        vm.stopPrank();

        assertEq(chromaMind.ownerOf(0), user1, "User1 should own the new token");
        assertEq(chromaMind.balanceOf(user1), 1, "User1 balance should be 1");
    }

    // Test 2: Does the contract prevent duplicate trips?
    function test_FailOnDuplicateMint() public {
        bytes32 tripHash = keccak256("unique_trip");

        // First mint should succeed
        vm.prank(user1);
        chromaMind.mintTrip(tripHash);

        // Second mint with the same hash should fail
        vm.expectRevert("ChromaMind: This trip already exists.");
        vm.prank(user2);
        chromaMind.mintTrip(tripHash);
    }

    // Test 3: Can a user donate to a creator?
    function test_Donation() public {
        bytes32 tripHash = keccak256("donation_trip");
        
        // User1 mints the trip
        vm.prank(user1);
        chromaMind.mintTrip(tripHash); // Mints tokenId 0

        uint256 creatorInitialBalance = user1.balance;
        uint256 donationAmount = 1 ether;

        // User2 donates 1 ETH to the trip
        vm.deal(user2, donationAmount); // Give user2 1 ETH to donate
        vm.startPrank(user2);
        chromaMind.donate{value: donationAmount}(0);
        vm.stopPrank();

        // Check if creator's balance increased
        assertEq(user1.balance, creatorInitialBalance + donationAmount, "Creator balance should increase by donation amount");
    }
}