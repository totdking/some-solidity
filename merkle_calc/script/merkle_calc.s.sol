// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MerkleCalc} from "../src/merkle_calc.sol";

contract MerkleCalcScript is Script {
    function run() public {
        vm.startBroadcast();
        new MerkleCalc();
        vm.stopBroadcast();
    }
}
