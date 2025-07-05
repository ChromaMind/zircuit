// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/royalty/ERC2981.sol";

/**
 * @title ChromaMind
 * @author Your Name/Company
 * @notice A smart contract for minting "Trip" NFTs for the ChromaMind biohacking project.
 * Each NFT represents a unique meditation experience defined by off-chain metadata.
 * Features: Unique trip minting, creator donations, and secondary sale royalties (ERC2981).
 */
contract ChromaMind is ERC721, ERC721Enumerable, Ownable, ERC2981 {
    // --- State Variables ---

    // Counter for new token IDs
    uint256 private _nextTokenId;

    // The base URI for the metadata. The token ID will be appended to this.
    // Example: "https://api.chromamind.io/trips/"
    string private _baseTokenURI;

    // Royalty percentage in basis points (e.g., 500 = 5%).
    // This is the default royalty for all minted trips.
    uint96 private _royaltyFeeBps; 

    // Mapping from a unique trip hash to the token ID that represents it.
    // This prevents duplicate trips from being minted.
    mapping(bytes32 => uint256) public tripHashToTokenId;

    // Mapping from a token ID to the address of its original creator.
    // This is crucial for the donation mechanism.
    mapping(uint256 => address) public creators;

    // --- Events ---

    /**
     * @notice Emitted when a new Trip NFT is successfully minted.
     * @param creator The address of the user who created the trip.
     * @param tokenId The ID of the newly minted NFT.
     * @param tripHash The unique hash representing the trip's parameters.
     */
    event TripMinted(address indexed creator, uint256 indexed tokenId, bytes32 indexed tripHash);

    /**
     * @notice Emitted when a donation is made to a trip's creator.
     * @param donor The address of the user making the donation.
     * @param tokenId The ID of the trip being supported.
     * @param creator The recipient of the donation.
     * @param amount The value of the donation in WEI.
     */
    event DonationReceived(address indexed donor, uint256 indexed tokenId, address indexed creator, uint256 amount);


    // --- Constructor ---

    /**
     * @param name The name of the NFT collection (e.g., "ChromaMind Trips").
     * @param symbol The symbol for the NFT collection (e.g., "TRIP").
     * @param initialBaseURI The starting URL for your metadata API.
     * @param initialOwner The deployer who will have administrative rights.
     * @param royaltyFeeBps The royalty fee in basis points (1% = 100).
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory initialBaseURI,
        address initialOwner,
        uint96 royaltyFeeBps
    ) ERC721(name, symbol) Ownable(initialOwner) {
        _baseTokenURI = initialBaseURI;
        _royaltyFeeBps = royaltyFeeBps;
    }

    // --- Minting Function ---

    /**
     * @notice Mints a new Trip NFT.
     * @dev The `tripHash` must be a unique keccak256 hash of the trip's defining parameters
     * (e.g., keccak256(abi.encodePacked(frequency, color, pattern, duration))).
     * This uniqueness check is performed off-chain before calling this function.
     * @param _tripHash A unique hash representing the trip's parameters.
     */
    function mintTrip(bytes32 _tripHash) public {
        // Check if a trip with these exact parameters already exists.
        require(tripHashToTokenId[_tripHash] == 0, "ChromaMind: This trip already exists.");

        uint256 tokenId = _nextTokenId;
        
        // Store the creator and the hash-to-token link
        creators[tokenId] = msg.sender;
        tripHashToTokenId[_tripHash] = tokenId;

        // Mint the new NFT to the creator
        _safeMint(msg.sender, tokenId);

        // Set the royalty information for this specific token
        _setTokenRoyalty(tokenId, msg.sender, _royaltyFeeBps);
        
        // Increment the counter for the next mint
        _nextTokenId++;

        emit TripMinted(msg.sender, tokenId, _tripHash);
    }


    // --- Donation Function ---

    /**
     * @notice Allows a user to donate ETH to the creator of a specific trip.
     * @param tokenId The ID of the trip NFT to support.
     */
    function donate(uint256 tokenId) public payable {
        require(_exists(tokenId), "ChromaMind: This trip does not exist.");
        require(msg.value > 0, "ChromaMind: Donation must be greater than zero.");

        address creator = creators[tokenId];
        require(creator != address(0), "ChromaMind: Creator address not set for this token.");

        // Transfer the donated ETH to the creator's address
        (bool success, ) = creator.call{value: msg.value}("");
        require(success, "ChromaMind: Donation transfer failed.");

        emit DonationReceived(msg.sender, tokenId, creator, msg.value);
    }


    // --- URI and Royalty Functions (Overrides) ---

    /**
     * @notice Returns the base URI for all token metadata.
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {ERC721Enumerable-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }


    // --- Admin Functions ---

    /**
     * @notice Allows the owner to update the base URI for the metadata.
     * @param newBaseURI The new URL for the metadata API.
     */
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    /**
     * @notice Allows the owner to update the default royalty fee.
     * @param newRoyaltyFeeBps The new royalty fee in basis points.
     */
    function setRoyaltyFee(uint96 newRoyaltyFeeBps) public onlyOwner {
        _royaltyFeeBps = newRoyaltyFeeBps;
    }
}