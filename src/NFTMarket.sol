// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import {console} from "forge-std/Test.sol";

import "./MusicNFT.sol";
import "./BaseERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NFTMarket is IERC721Receiver, Initializable {
    address token;
    address nft;
    mapping(uint => uint256) prices;
    mapping(uint => address) sellers;

    // constructor() {
    //     _disableInitializers();
    // }

    function initialize(address _token, address _nft) public initializer {
        token = _token;//sets owner to msg.sender
        nft = _nft;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /*
     * List the NFT
     * @param tokenId
     * @param amount
     */
    function listPrice(uint8 tokenId, uint256 amount) external {
        // transfer nft ownership to this contract
        MusicNFT(nft).safeTransferFrom(msg.sender, address(this), tokenId);
        // set up nft price
        prices[tokenId] = amount;

        // update the nft seller address
        sellers[tokenId] = msg.sender;
    }

    /*
     * Buy NFT
     * @param tokenId
     * @param amount
     */
    function buy(uint tokenId, uint256 amount) public {
        require(
            MusicNFT(nft).ownerOf(tokenId) == address(this),
            "Music NFT have aleady been selled out"
        );
        require(
            amount > 0 && amount >= prices[tokenId],
            "Music NFT cann not be buyed since price is lower"
        );

        // transfer token to seller based the listed price
        BaseERC20(token).transferFrom(
            msg.sender,
            sellers[tokenId],
            prices[tokenId]
        );
        // transfer nft ownership to buyer
        MusicNFT(nft).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    // function _authorizeUpgrade(address newImplementation) internal virtual override {}
}
