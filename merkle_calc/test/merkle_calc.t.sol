// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MerkleCalc} from "../src/merkle_calc.sol";

contract MerkleCalcTest is Test {
    MerkleCalc merkle_calc;
    function setUp() public {
        merkle_calc = new MerkleCalc();
    }
    
    function test_merkle_proof() public {
        ( , uint256 private_key1) = makeAddrAndKey("alice");
        string memory message = "hello world";
        bytes32 msg_hash = keccak256(abi.encodePacked(message));
        bytes32 eth_msg_hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msg_hash));

        // Populate leaves before using in tree, root & proof generation
        bytes32[] memory leaves = new bytes32[](5);
            (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(private_key1, eth_msg_hash);
            bytes32 leaf1 = keccak256(abi.encodePacked(v1, r1, s1));
            leaves[0] = leaf1;
            leaves[1] = keccak256(abi.encodePacked("2"));
            leaves[2] = keccak256(abi.encodePacked("3"));
            leaves[3] = keccak256(abi.encodePacked("4"));
            leaves[4] = keccak256(abi.encodePacked("5"));

            // THE BUILDING OF THE TREE AND ROOT AND PROOFS SHOULD BE AFTER THE LEAVES ARE POPULATED
            // build the tree
            bytes32[][] memory layers = merkle_calc.build_tree(leaves);
            // calculate the root
            bytes32 root = merkle_calc.calc_root(leaves);
            // build the proof for proof 1
            bytes32[] memory proof1 = merkle_calc.gen_proof(leaf1, layers);
            // verify the leaf in the layered tree
            merkle_calc.verify_merkle(root, leaf1, proof1);

        

        // gen proof

        // bytes32[] memory proof2 = merkle_calc.gen_proof(leaf2, leaf_arr);
        // bytes32[] memory proof3 = merkle_calc.gen_proof(leaf3, leaf_arr);
        // bytes32[] memory proof4 = merkle_calc.gen_proof(leaf4, leaf_arr);
        // bytes32[] memory proof5 = merkle_calc.gen_proof(leaf5, leaf_arr);

        // verify leaf
        
        

    }
}
