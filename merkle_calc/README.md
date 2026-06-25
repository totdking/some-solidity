# MerkleCalc

A Solidity implementation of a binary Merkle tree with proof generation and verification. Deployed on Base Sepolia at [`0xC67a492064d2575aD8Bd8ddb1303aACDF34E9Bd0`](https://sepolia.basescan.org/address/0xC67a492064d2575aD8Bd8ddb1303aACDF34E9Bd0).

## Overview

MerkleCalc builds Merkle trees using a layer-based approach where each layer is allocated exactly the right amount of space. Odd-numbered layers duplicate the last node to form a pair, which is the standard binary Merkle tree convention.

Hashing is sorted: before hashing any pair, the smaller value is always placed first. This means `hash(A, B) == hash(B, A)`, which simplifies proof verification; the verifier does not need to know which side a sibling came from.

## Functions

### `build_tree(bytes32[] memory leaves) → bytes32[][] memory`

Builds the full Merkle tree from a leaf array and returns it as a 2D array of layers.

- `layers[0]` — the original leaves
- `layers[1]` — first level of parent hashes
- `layers[depth - 1]` — the root (single element)

### `calc_root(bytes32[] memory leaves) → bytes32`

Computes and stores the Merkle root from a leaf array without building the full tree. Reduces the array in-place level by level until one value remains. Also writes the result to the public `root_hash` state variable.

### `gen_proof(bytes32 target_leaf_hash, bytes32[][] memory layers) → bytes32[] memory`

Generates a Merkle proof for a given leaf hash against a pre-built tree. The proof is an ordered array of sibling hashes from the leaf level up to (but not including) the root.

Reverts with `"leaf not found"` if the target hash is not in `layers[0]`.

### `verify_merkle(bytes32 root, bytes32 target_hash, bytes32[] calldata proof) → void`

Verifies a Merkle proof by recomputing the hash path from the leaf up to the root and asserting it matches the provided root. Reverts on mismatch.

### `_efficient_hash(bytes32 a, bytes32 b) → bytes32`

Low-level hashing using inline assembly. Writes both values to scratch space and calls `keccak256` directly — cheaper than `abi.encode`.

## Usage

```solidity
// 1. Build the tree
bytes32[] memory leaves = new bytes32[](5);
leaves[0] = keccak256(abi.encodePacked("alice"));
leaves[1] = keccak256(abi.encodePacked("bob"));
// ...

bytes32[][] memory layers = merkleCalc.build_tree(leaves);

// 2. Compute the root
bytes32 root = merkleCalc.calc_root(leaves);

// 3. Generate a proof for leaves[0]
bytes32[] memory proof = merkleCalc.gen_proof(leaves[0], layers);

// 4. Verify
merkleCalc.verify_merkle(root, leaves[0], proof);
```

## Development

```bash
# Run tests
make test

# Dry run deployment (no broadcast)
make deploy-dry

# Deploy and verify on Base Sepolia
make deploy

# Verify an existing deployment
make verify-deploy
```

Built with [Foundry](https://book.getfoundry.sh/).
