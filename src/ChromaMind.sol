// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Context.sol"; // Required for _msgSender() in v5

/**
 * @title ChromaMind
 * @author Your Name/Company
 * @notice A smart contract for minting "Trip" NFTs for the ChromaMind biohacking project.
 * Each NFT represents a unique meditation experience defined by off-chain metadata.
 * Features: Unique trip minting, creator donations, and secondary sale royalties (ERC2981).
 */
contract ChromaMind is ERC721, ERC721Enumerable, Ownable, ERC2981 {
    // --- State Variables ---
    uint256 private _nextTokenId;
    string private _baseTokenURI;
    uint96 private _royaltyFeeBps; 
    mapping(bytes32 => uint256) public tripHashToTokenId;
    mapping(uint256 => address) public creators;

    // --- Events ---
    event TripMinted(address indexed creator, uint256 indexed tokenId, bytes32 indexed tripHash);
    event DonationReceived(address indexed donor, uint256 indexed tokenId, address indexed creator, uint256 amount);

    // --- Constructor ---
    constructor(
        string memory name,
        string memory symbol,
        string memory initialBaseURI,
        address initialOwner,
        uint96 royaltyFeeBps
    ) ERC721(name, symbol) Ownable(initialOwner) {
        _baseTokenURI = initialBaseURI;
        _royaltyFeeBps = royaltyFeeBps;
        _nextTokenId = 1; 
    }

    // --- Minting Function ---
    function mintTrip(bytes32 _tripHash) public {
        require(tripHashToTokenId[_tripHash] == 0, "ChromaMind: This trip already exists.");
        uint256 tokenId = _nextTokenId;
        
        creators[tokenId] = _msgSender();
        tripHashToTokenId[_tripHash] = tokenId;

        _safeMint(_msgSender(), tokenId);
        _setTokenRoyalty(tokenId, _msgSender(), _royaltyFeeBps);
        
        _nextTokenId++;
        emit TripMinted(_msgSender(), tokenId, _tripHash);
    }

    // --- Donation Function ---
    function donate(uint256 tokenId) public payable {
        address creator = creators[tokenId];
        require(creator != address(0), "ChromaMind: This trip does not exist or has no creator.");
        require(msg.value > 0, "ChromaMind: Donation must be greater than zero.");

        (bool success, ) = creator.call{value: msg.value}("");
        require(success, "ChromaMind: Donation transfer failed.");

        emit DonationReceived(_msgSender(), tokenId, creator, msg.value);
    }

    // --- URI and Royalty Functions (Overrides) ---
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    // --- REQUIRED OVERRIDES FOR OPENZEPPELIN v5.x ---

    /**
     * @dev This is a new required function in OZ v5 when using ERC721Enumerable.
     * It resolves the conflict between the `_update` functions in ERC721 and ERC721Enumerable.
     * We must call both parent functions.
     */
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    /**
     * @dev This is a new required function in OZ v5 when using ERC721Enumerable.
     * It resolves the conflict between the `_increaseBalance` functions in ERC721 and ERC721Enumerable.
     */
    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    
    // --- Admin Functions ---
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    function setRoyaltyFee(uint96 newRoyaltyFeeBps) public onlyOwner {
        _royaltyFeeBps = newRoyaltyFeeBps;
    }
}