// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {BaseScript} from "./BaseScript.s.sol";
import {BaseERC20} from "../src/BaseERC20.sol";
import {Upgrades, Options} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {console} from "forge-std/Test.sol";

contract BaseERC20Script is BaseScript {
    function run() public broadcaster {
       BaseERC20 baseERC20 = new BaseERC20("Base ERC20","BSC");
       console.log(address(baseERC20));
    }
}
