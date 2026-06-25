// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MerkleCalc {
    bytes32 public root_hash;
    // Calculate root

    // 1. build tree
    // 2. gen proof
    // 3. verify leaf

    // efficient calculation of hash
    function _efficient_hash(bytes32 a, bytes32 b) public pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

    /// this was a wrong shit
    function former_calc_root(bytes32[] memory leaves) public returns(bytes32){
        uint256 len = leaves.length;
        for (uint256 i; i < len; i += 2){
            bytes32 left = leaves[i];
            bytes32 right = (i + 1) < len 
                                ? leaves[i + 1]
                                : leaves[i];
            if (left < right) {
                leaves[i/2] = _efficient_hash(left, right);
            } else {
                leaves[i/2] = _efficient_hash(right, left);
            }
        }
        root_hash = leaves[0];
        return root_hash;
    }

    function calc_root(bytes32[] memory leaves) public returns(bytes32) {
        uint256 len = leaves.length;
        while (len > 1) {
            // for next layer length 
            uint256 next_len = (len + 1) / 2;
            for (uint256 i; i < next_len; i++) {
                bytes32 left = leaves[2*i];
                bytes32 right = ((2 * i) + 1) < len
                                    ? leaves[(2 * i) + 1]
                                    : leaves[2 * i];
                leaves[i] = left < right
                                ? _efficient_hash(left, right)
                                : _efficient_hash(right, left);
            }
            len = next_len;
        }
        root_hash = leaves[0];
        return root_hash;
    }

    /// To return exact tree depth for any amount of leaves
    function _exact_tree_depth(uint256 leaf_count) internal pure returns(uint256) {
        uint256 total = leaf_count; // starts by counting the leaves themselves
        uint256 level = leaf_count; // shrinks level by leveling upward
        while (level > 1) {
            level = (level + 1) / 2; // next level up (ceil division for sake of odd numbers because of the +1)
            total += level; // add that level's node count
        }
        return total ;
    }

    function build_tree(bytes32[] memory leaves) public pure returns(bytes32[][] memory) {
        uint256 leaf_len = leaves.length;
        uint256 depth = 1;
        // this is to get the fiscal num of depth a tree
        // depth starts from the root and it's starting point is always zero
        while (leaf_len > 1) {
            leaf_len = (leaf_len + 1) /2;
            depth +=1;
        }

        // full tree depth = (2 * depth) - 1 works for any tree of depth of power by 2.
        // bytes32[] memory tree = new bytes32[]((2 * depth) -1);
        // An arrayy that holds `depth` number of inner arrays, each inner array is a bytes32[]
        bytes32[][] memory layers = new bytes32[][](depth);
        // layers.length = depth
        // The value of layer[0] / height 0 is the leaves array.
        layers[0] = leaves;

        for (uint256 d = 1; d < depth; d++){
            // This is to calculate the length of each layer array
            uint256 prev_len = layers[d-1].length;
            // this follows the calculation of depth from above in the code.
            uint256 next_len = (prev_len + 1) / 2;
            layers[d] = new bytes32[](next_len);

            // This to populate each layer arr after getting the exact layer array size
            for (uint256 i = 0; i < next_len; i++) {
                // for first iteration(an example) if layers[0].length = 7
                // left = layers[1-1][2*0] == layers[0][0]
                bytes32 left = layers[d - 1][2 * i];
                // duplicate if last node is odd(same tactic employed in calc_root())
                // if ((2 * 0) + 1) < prev_len, right = layers[1-1][(2 * 0) + 1] -> layers[0][1]
                // else right = layers[1-1][2*0] -> layers[0][0] THIS IS DUPLICATED if the last node is a left node
                bytes32 right = (2*i + 1 < prev_len) 
                                    ? layers[d-1][2*i + 1]
                                    : layers[d-1][2*i];

                layers[d][i] = left < right 
                                    ? _efficient_hash(left, right)
                                    : _efficient_hash(right, left);
            }
        }
        return layers;
    }

    // One needs access to the entire tree to gen a proof for a target_hash which onchain might be infeasible
    // But offchian, has to be stored.
    function gen_proof(bytes32 target_leaf_hash , bytes32[][] memory layers) public pure returns (bytes32 [] memory) {
        // 1. find leaf/target hash in layer[0] / height 0
        uint256 current_idx = type(uint256).max;
        for (uint256 i; i < layers[0].length; i++) {
            if (layers[0][i] == target_leaf_hash){
                current_idx = i;
                break;
            }
        }
        require(current_idx != type(uint256).max, "leaf not found");
        
        //2. calculate size of proof array
        // layers.length is == depth 
        // proof array length = depth - 1 OR height - 1
        bytes32[] memory proof = new bytes32[](layers.length - 1);

        //3. Fill the proof array dynamically
        for (uint256 d = 0; d < layers.length - 1; d++){
            uint256 sibling_idx;
            if (current_idx % 2 == 0) {
                // its a left node, sibling is on the right
                sibling_idx = current_idx + 1;
                proof[d] =  sibling_idx < layers[d].length 
                                ? layers[d][sibling_idx]
                                : layers[d][current_idx]; // duplicate for odd layer
            } else {
                // it's a right node, sibling is on the left
                proof[d] = layers[d][current_idx - 1];
            }
            current_idx /= 2;
        }
        return proof;
    }

    // before this is called, we have to generate the proof with this target hash from gen_proof()
    function verify_merkle(bytes32 root, bytes32 target_hash, bytes32[] calldata proof) public pure {
        bytes32 _root = root;
        bytes32 computed_hash = target_hash;

        uint256 len = proof.length;
        for (uint256 i = 0; i < len; i++ ) {
            if (computed_hash < proof[i]) {
                computed_hash = _efficient_hash(computed_hash, proof[i]);
            } else {
                computed_hash = _efficient_hash(proof[i], computed_hash);
            }
        }
        assert(computed_hash == _root);
    }
}
