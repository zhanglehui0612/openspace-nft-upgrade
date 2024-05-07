// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseScript} from "./BaseScript.s.sol";
import {NFTMarket} from "../src/NFTMarket.sol";
import {BaseERC20} from "../src/BaseERC20.sol";
import {MusicNFT} from "../src/MusicNFT.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {console} from "forge-std/Test.sol";

contract NFTMarketV1Script is BaseScript {
    function run() public broadcaster {
        Options memory opts;
        opts.unsafeSkipAllChecks = true;
        BaseERC20 baseERC20 = new BaseERC20("Base ERC20","BSC");
        MusicNFT nft = new MusicNFT("Moon NFT","MNFT");
        address proxy = Upgrades.deployTransparentProxy(
            "/Users/nickyzhang/Workbench/App/openspace-nft-upgrade/src/NFTMarket.sol:NFTMarket",
            deployer,   // INITIAL_OWNER_ADDRESS_FOR_PROXY_ADMIN,
            abi.encodeCall(NFTMarket.initialize, (address(baseERC20), address(nft))),      // abi.encodeCall(MyContract.initialize, ("arguments for the initialize function")
            opts
        );
        console.log("NFTMarket(v1) deployed on %s", address(proxy));
    }
}
