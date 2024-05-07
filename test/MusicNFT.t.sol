// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Test, console} from "forge-std/Test.sol";
import {IERC20Errors, IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {SigUtils} from "./SigUtils.sol";
import "../src/MusicNFT.sol";
import "../src/NFTMarket.sol";
import "../src/MusicNFTPermit.sol";
contract MusicNFTTest is Test {
    SigUtils sigUtils;
    MusicNFT nft;
    BaseERC20 baseERC20;
    
    uint256 internal nftOwnerPrivateKey;
    uint256 internal spenderPrivateKey;
    uint256 internal otherPrivateKey;

    address nftOwner ;
    address spender;
    address other;
    function setUp() public {
        nftOwnerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;
        otherPrivateKey = 0x1122FE;
        
        nftOwner = vm.addr(nftOwnerPrivateKey);
        spender = vm.addr(spenderPrivateKey);
        other = vm.addr(otherPrivateKey);

        vm.prank(nftOwner);
        nft = new MusicNFT("Music NFT","MFT");

        sigUtils = new SigUtils(nft.DOMAIN_SEPARATOR());
    }


    function testPermit() public {
        vm.startPrank(nftOwner);
        (uint8 v, bytes32 r, bytes32 s) = sign(nftOwner, nftOwnerPrivateKey, spender, 1, 1000, 1 days);
        console.log(nftOwner);
        console.log(spender);
        console.log(other);

        nft.permit(nftOwner, spender,1, 1000, 1 days, v, r, s);

        vm.expectRevert(abi.encodeWithSelector(MusicNFTPermit.ERC2612InvalidSigner.selector));
        nft.permit(nftOwner, other,1, 1000, 1 days, v, r, s);

        vm.expectRevert(abi.encodeWithSelector(MusicNFTPermit.ERC2612InvalidSigner.selector));
        nft.permit(nftOwner,spender,2, 1000, 1 days, v, r, s);

        vm.expectRevert(abi.encodeWithSelector(MusicNFTPermit.ERC2612InvalidSigner.selector));
        nft.permit(nftOwner,spender,1, 10000, 1 days, v, r, s);

        vm.expectRevert(abi.encodeWithSelector(MusicNFTPermit.ERC2612InvalidSigner.selector));
        nft.permit(nftOwner,spender,1, 1000, 5 days, v, r, s);
        vm.stopPrank();
    }


    function sign(
        address owner, // transaction owner
        uint256 ownerPrivateKey,
        address spender, // authorize target
        uint tokenId,
        uint256 value, // authorize value
        uint256 deadline
    ) internal returns (uint8 v, bytes32 r, bytes32 s) {
        // Create Permit struct
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            tokenId: tokenId,
            value: value,
            nonce: 0,
            deadline: deadline
        });

        // Computes the hash of the fully encoded EIP-712 message for the domain
        bytes32 digest = sigUtils.getTypedDataHash(permit);

        return vm.sign(ownerPrivateKey, digest);
    }
}