// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseScript} from "./BaseScript.s.sol";
import {NFTMarketV2} from "../src/NFTMarketV2.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {console} from "forge-std/Test.sol";

contract NFTMarketV2Script is BaseScript {
    function run() public broadcaster {
        upgrade();
    }


    function upgrade() internal {
        Options memory opts;
        opts.unsafeSkipAllChecks = true;
        opts.referenceContract = "/Users/nickyzhang/Workbench/App/openspace-nft-upgrade/src/NFTMarket.sol";
        // proxy: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
        Upgrades.upgradeProxy(0x98E758787B7E10C891D240D3279cB7344105E1A6, "/Users/nickyzhang/Workbench/App/openspace-nft-upgrade/src/NFTMarketV2.sol:NFTMarketV2", "", opts);
    }
}
