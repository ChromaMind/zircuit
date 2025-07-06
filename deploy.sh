source .env && forge script script/DeployChromaMind.s.sol:DeployChromaMind \
--rpc-url $ZIRCUIT_TESTNET_RPC_URL \
--private-key $PRIVATE_KEY \
--broadcast \
--verify \
-vvvv
