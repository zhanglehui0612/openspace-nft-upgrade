// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseScript} from "./BaseScript.s.sol";
import {MusicNFT} from "../src/MusicNFT.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {console} from "forge-std/Test.sol";

contract MusicNFTScript is BaseScript {
    function run() public broadcaster {
       MusicNFT nft = new MusicNFT("Moon NFT","MNFT");
        address sender = 0xC3b0FAafeB7a80D9E3Bfde134972026B61c1F127;
        nft.mint(sender, "ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/1.json");
        nft.mint(sender, "ipfs://QmSaZjmSBZM557jsB6MtE6MMxwZTR7PBCLkJABEUTbRzLH/2.json");
        console.log(address(nft));
    }
}
