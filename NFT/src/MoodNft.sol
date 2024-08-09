// // SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    error MoodNft__CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    string private s_sadSvgUri;
    string private s_happySvgUri;

    enum Mood {
        HAPPY,
        SAD
    }

    mapping(uint256 => Mood) private s_tokenIdToMood;

    constructor(string memory sadSvgUri, string memory happySvgUri) ERC721("Mood NFT", "MN") {
        s_tokenCounter = 0;
        s_sadSvgUri = sadSvgUri;
        s_happySvgUri = happySvgUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenIdToMood[s_tokenCounter] = Mood.HAPPY;
        s_tokenCounter++;
    }

    function flipMood(uint256 tokenId) public {
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }

        if (s_tokenIdToMood[tokenId] == Mood.SAD) {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        } else {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageURI;

        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageURI = s_happySvgUri;
        } else {
            imageURI = s_sadSvgUri;
        }

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes( // bytes casting actually unnecessary as 'abi.encodePacked()' returns a bytes
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description":"An NFT that reflects the mood of the owner.", ',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}
