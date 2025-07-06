# ChromaMind Smart Contracts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Harnessing web3 to mint, share, and experience personalized biohacking meditation trips. This repository contains the official Solidity smart contracts for the ChromaMind project, built with the [Foundry](https://getfoundry.sh/) development framework.

## Table of Contents

- [The Vision](#the-vision)
- [Core Features](#core-features)
- [Tech Stack](#tech-stack)
- [Architectural Notes](#architectural-notes)
  - [Metadata Storage](#metadata-storage)
  - [Discoverability & Trending](#discoverability--trending)
- [Getting Started: Local Development](#getting-started-local-development)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Compile](#compile)
  - [Test](#test)
- [Deployment](#deployment)
- [Core Contract Functions](#core-contract-functions)
  - [`mintTrip(bytes32 _tripHash)`](#minttripbytes32-_triphash)
  - [`donate(uint256 tokenId)`](#donateuint256-tokenid)
- [Contributing](#contributing)

## The Vision

ChromaMind is a biohacking project centered around smart glasses that use synchronized light strobes and binaural beats to guide users into deep meditative states. The web3 component allows users to create, customize, and own their unique meditation sessions—or "Trips"—as NFTs.

By tokenizing these Trips, creators can establish ownership, share their creations with the community, and earn rewards, fostering a vibrant ecosystem of shared consciousness experiences.

## Core Features

The `ChromaMind.sol` smart contract provides the on-chain foundation for our ecosystem:

- **Mint Unique Trip NFTs:** Users can mint an ERC721 NFT representing a unique combination of light and sound parameters. The contract ensures no two identical Trips can be minted.
- **Creator Donations:** The community can directly support their favorite creators by donating ETH to any Trip NFT.
- **Creator Royalties (ERC-2981):** Creators automatically receive a percentage of every secondary sale of their Trip NFTs on compatible marketplaces like OpenSea.
- **Secure Admin Controls (Ownable):** The project team can securely manage core contract settings like the metadata URI and royalty fees.
- **Enumerable:** All minted NFTs are discoverable on-chain, allowing for easy integration with dApps and frontends.

## Tech Stack

- **Solidity:** Smart contract language.
- **Foundry:** The blazing-fast smart contract development toolchain.
- **OpenZeppelin Contracts:** For secure, battle-tested implementations of standards like ERC721, ERC2981, and Ownable.

## Architectural Notes

### Metadata Storage

Currently, the NFT metadata (which includes the large data stream for the glasses) is stored on a centralized server. The `tokenURI` function points to an API endpoint managed by the ChromaMind project (e.g., `https://api.chromamind.io/trips/{tokenId}`).

- **Pros:** Allows for a subscription-based business model and easy updates.
- **Cons:** This approach creates a dependency on the ChromaMind project's servers.

A future roadmap item is to explore decentralized storage solutions like **IPFS** to give users an option for creating truly permanent, censorship-resistant Trip NFTs.

### Discoverability & Trending

Features like "trending trips" or "top creators" are best handled off-chain. Our smart contract emits events for key actions (`TripMinted`, `DonationReceived`). A backend indexing service (like The Graph or a custom service) can listen for these events, aggregate the data, and provide a rich API for our app's frontend.

## Getting Started: Local Development

Follow these steps to set up the project on your local machine for development and testing.

### Prerequisites

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Foundry](https://getfoundry.sh/): Install with `curl -L https://foundry.paradigm.xyz | bash` followed by `foundryup`.

### Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/chromamind-foundry.git
    cd chromamind-foundry
    ```

2.  **Install dependencies:**
    This will download the OpenZeppelin contracts library.
    ```bash
    forge install
    ```

3.  **Configure environment variables:**
    Create a `.env` file by copying the example file. This will store your private keys and API keys, and it is ignored by Git.
    ```bash
    cp .env.example .env
    ```
    Now, open the `.env` file and fill in the required values.

### Compile

Compile the smart contracts to ensure everything is set up correctly.
```bash
forge build
```

### Test

Run the full test suite to verify the contract's logic.
```bash
forge test
```
You should see all tests passing.

## Deployment

To deploy the contract to a live testnet (e.g., Zircuit's Garfield Testnet), follow these steps:

1.  **Get Testnet ETH:** Obtain funds for the target testnet from its official faucet to cover gas fees.
2.  **Fill `.env`:** Ensure your `.env` file contains the correct RPC URL, your wallet's private key, and a block explorer API key for contract verification.
3.  **Run the deployment script:**
    This command will deploy the contract and automatically attempt to verify it on the block explorer.

    ```bash
    # Make sure to source your .env file
    source .env && forge script script/DeployChromaMind.s.sol:DeployChromaMind \
    --rpc-url $ZIRCUIT_TESTNET_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ZIRCUITSCAN_API_KEY \
    -vvvv
    ```

## Core Contract Functions

### `mintTrip(bytes32 _tripHash)`

Mints a new Trip NFT.

-   **`_tripHash`**: This is a `keccak256` hash generated off-chain from the trip's unique parameters (e.g., light frequency, color, audio file hash, duration). Your application's backend is responsible for creating this hash before calling the function.
-   The contract will revert if a trip with the same hash has already been minted.

### `donate(uint256 tokenId)`

Allows any user to send ETH to the original creator of a specific Trip NFT.

-   **`tokenId`**: The ID of the NFT you wish to support.
-   This function is `payable`, so the donation amount is sent as the `value` of the transaction.

## Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request.

---
You should also create a file named `.env.example` to guide other developers.

**File: `.env.example`**
```
# Zircuit Garfield Testnet RPC URL
ZIRCUIT_TESTNET_RPC_URL="https://garfield-testnet.zircuit.com"

# Your wallet's private key (MUST start with 0x)
# Used for signing deployment transactions.
# ⚠️ NEVER COMMIT A FILE WITH A REAL PRIVATE KEY ⚠️
PRIVATE_KEY="0x..."

# Zircuit Garfield Block Explorer API Key
# Used for automatically verifying the contract source code upon deployment.
ZIRCUITSCAN_API_KEY="..."
```