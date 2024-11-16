// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/// @title ChainBattles - A dynamic NFT game contract
/// @notice This contract implements upgradable NFT characters with on-chain metadata
contract ChainBattles is ERC721URIStorage {
    using Strings for uint256; // Utility for converting uint256 to strings
    using Counters for Counters.Counter; // Utility for counting tokens

    Counters.Counter private _tokenIds; // Counter to keep track of token IDs
    mapping(uint256 => uint256) public tokenIdToLevels; // Mapping of tokenId to levels

    /// @notice Contract constructor
    /// @dev Sets the token name as "Chain Battles" and symbol as "CBTLS"
    constructor() ERC721("Chain Battles", "CBTLS") {}

    /// @notice Generates an SVG image for the character based on its level
    /// @param tokenId The ID of the token
    /// @return A Base64-encoded SVG image string
    function generateCharacter(uint256 tokenId) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">Warrior</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">Levels: ',
            getLevels(tokenId),
            '</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }

    /// @notice Retrieves the level of a specific token
    /// @param tokenId The ID of the token
    /// @return The level of the token as a string
    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = tokenIdToLevels[tokenId];
        return levels.toString();
    }

    /// @notice Generates the metadata for the token in JSON format
    /// @param tokenId The ID of the token
    /// @return A Base64-encoded JSON metadata string
    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    /// @notice Allows a user to mint a new NFT
    /// @dev Assigns a new token ID, initializes its level to 0, and sets its metadata
    function mint() public {
        _tokenIds.increment(); // Increment token ID counter
        uint256 newItemId = _tokenIds.current(); // Get the current token ID
        _safeMint(msg.sender, newItemId); // Mint the token to the caller
        tokenIdToLevels[newItemId] = 0; // Initialize the token's level to 0
        _setTokenURI(newItemId, getTokenURI(newItemId)); // Set the token's metadata
    }

    /// @notice Allows the owner of an NFT to train it and increase its level
    /// @param tokenId The ID of the token to be trained
    /// @dev Updates the token's level and regenerates its metadata
    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Token does not exist"); // Ensure the token exists
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!"); // Ensure the caller owns the token

        tokenIdToLevels[tokenId] += 1; // Increment the token's level
        _setTokenURI(tokenId, getTokenURI(tokenId)); // Update the token's metadata
    }
}
