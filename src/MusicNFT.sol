// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import "./MusicNFTPermit.sol";

contract MusicNFT is MusicNFTPermit {

    uint256 counter;

    constructor(string memory _name, string memory _symbol) 
        ERC721(_name, _symbol) MusicNFTPermit(_name) {
    }


    function mint(
        address sender,
        string memory tokenURI
    ) public returns (uint256) {
        counter++;
        uint256 newItemId = counter;
        _mint(sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }
}