// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Test, console} from "forge-std/Test.sol";
import {IERC20Errors, IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import "../src/BaseERC20.sol";
import "../src/MusicNFT.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {NFTMarketV2} from "../src/NFTMarketV2.sol";
import {MusicNFTPermit} from "../src/MusicNFTPermit.sol";

import {SigUtils} from "./SigUtils.sol";
contract NFTMarketTest is Test {
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

        baseERC20 = new BaseERC20("Base ERC20","BSC");

        vm.startPrank(nftOwner);
        nft = new MusicNFT("Music NFT","MFT");
        nft.mint(nftOwner,"ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/1.json");
        nft.mint(nftOwner,"ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/2.json");
        nft.mint(nftOwner,"ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/3.json");
        vm.stopPrank();
        sigUtils = new SigUtils(nft.DOMAIN_SEPARATOR());
    }


    function testListPriceWithNFTMarket() public {
        NFTMarket market = new NFTMarket();
        market.initialize(address(baseERC20),address(nft));
        // 告诉VM 期望下次调用返回ERC721NonexistentToken错误
        vm.expectRevert(
            abi.encodeWithSignature("ERC721InsufficientApproval(address,uint256)", address(market), 1)
        );
        market.listPrice(1, 10000);

        nft.mint(
            nftOwner,
            "ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/1.json"
        );

        vm.startPrank(other);
        // 告诉VM 期望下次调用返回ERC721NonexistentToken错误
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC721InsufficientApproval(address,uint256)",
                address(market),
                1
            )
        );
        market.listPrice(1, 10000);
        vm.stopPrank();

        vm.startPrank(nftOwner);
        nft.approve(address(market), 1);
        market.listPrice(1, 100000);
    }

    function testPermitListWithNFTMarketV2() public {
        NFTMarketV2 market = new NFTMarketV2();
        market.initialize(address(baseERC20),address(nft));

        vm.startPrank(nftOwner);
        nft.mint(nftOwner,"ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/1.json");
        nft.mint(nftOwner,"ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/2.json");
        nft.mint(nftOwner,"ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/3.json");
        
        console.log("TokenId = 1, current owner is ", nft.ownerOf(1));
        (uint8 v, bytes32 r, bytes32 s) = sign(nftOwner, nftOwnerPrivateKey, address(market), 1, 1000, 1 days);
        market.permitList(1,1000,1 days, v, r, s);
        console.log("TokenId = 1, current owner is ", nft.ownerOf(1));
        console.log("TokenId = 2, current owner is ", nft.ownerOf(2));
        console.log("TokenId = 3, current owner is ", nft.ownerOf(3));
        assertTrue(nft.isApprovedForAll(nftOwner, address(market)));

        // check tokenId is error
        vm.expectRevert(abi.encodeWithSelector(MusicNFTPermit.ERC2612InvalidSigner.selector));
        market.permitList(2,1000,1 days, v, r, s);

        // check amount is error
        vm.expectRevert(abi.encodeWithSelector(MusicNFTPermit.ERC2612InvalidSigner.selector));
        market.permitList(1,10000,1 days, v, r, s);

        // check deadline 
        vm.expectRevert(abi.encodeWithSelector(MusicNFTPermit.ERC2612InvalidSigner.selector));
        market.permitList(1,1000,4 days, v, r, s);
        vm.stopPrank();

        
        
        // vm.startPrank(other);
        // // 告诉VM 期望下次调用返回ERC721NonexistentToken错误
        // vm.expectRevert(
        //     abi.encodeWithSignature(
        //         "ERC721InsufficientApproval(address,uint256)",
        //         address(market),
        //         1
        //     )
        // );
        // market.listPrice(1, 10000);
        // vm.stopPrank();

        // vm.startPrank(nftOwner);
        // nft.approve(address(market), 1);
        // market.listPrice(1, 100000);
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