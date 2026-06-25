.PHONY: test, deploy, deploy-dry, verify-deploy, check

test:
	@forge test --mt test_merkle_proof -vvvv

deploy:
	@ source .env && forge script script/merkle_calc.s.sol:MerkleCalcScript --rpc-url base_sepolia --chain base-sepolia --private-key $$PRIVATE_KEY --broadcast --verify --etherscan-api-key $$BASESCAN_API_KEY -vvvv

deploy-dry:
	@ source .env && forge script script/merkle_calc.s.sol:MerkleCalcScript --rpc-url base_sepolia --private-key $$PRIVATE_KEY -vvvv

verify-deploy:
	@ source .env && forge verify-contract 0xC67a492064d2575aD8Bd8ddb1303aACDF34E9Bd0 \
  src/merkle_calc.sol:MerkleCalc \
  --rpc-url base_sepolia \
  --chain base-sepolia \
  --etherscan-api-key $$BASESCAN_API_KEY \
  --watch

check: 
	@ cast code 0xC67a492064d2575aD8Bd8ddb1303aACDF34E9Bd0 --rpc-url https://sepolia.base.org -vvvv