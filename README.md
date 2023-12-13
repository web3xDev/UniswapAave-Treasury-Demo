# Treasury Smart Contract

This is a Solidity smart contract for managing a treasury that handles deposits, withdrawals, token swaps, and interaction with Aave and Uniswap V2 Router. The contract allows users to deposit various tokens, manages allocation ratios for token swaps, and provides functions to interact with Aave and Uniswap for optimizing token holdings.

## Smart Contract Details

- Solidity Version: 0.8.20
- Dependencies: OpenZeppelin, Uniswap V2 Periphery, Aave Core v3
- License: MIT

## Smart Contract Address (Mumbai Testnet)

The smart contract address on the Mumbai testnet is:

```bash
0xC1f5c56A821B8DCD7aA8a7a40c27919003cB14Bf
```

You can view the smart contract on the testnet using [Mumbai PolygonScan](https://mumbai.polygonscan.com/address/0xC1f5c56A821B8DCD7aA8a7a40c27919003cB14Bf#code)

## Functions

### 1. Constructor

- Initializes the contract with the necessary addresses.
- Parameters:
  - `_usdcTokenAddress`: Address of the USDC token.
  - `_usdtTokenAddress`: Address of the USDT token.
  - `_daiTokenAddress`: Address of the DAI token.
  - `_uniswapRouterAddress`: Address of the Uniswap V2 Router.
  - `_aavePoolAddress`: Address of the Aave Pool.

### 2. `setTokenAddresses`

- Allows the owner to set token addresses.
- Parameters:
  - `_usdcTokenAddress`: Address of the USDC token.
  - `_usdtTokenAddress`: Address of the USDT token.
  - `_daiTokenAddress`: Address of the DAI token.

### 3. `setUniswapRouterAddress`

- Allows the owner to set the Uniswap Router address.
- Parameters:
  - `_uniswapRouterAddress`: Address of the Uniswap Router.

### 4. `setAavePoolAddress`

- Allows the owner to set the Aave Pool address.
- Parameters:
  - `_aavePoolAddress`: Address of the Aave Pool.

### 5. `deposit`

- Allows users to deposit tokens into the Treasury.
- Parameters:
  - `amount`: Amount of tokens to deposit.
  - `tokenAddress`: Address of the token to deposit.

### 6. `withdraw`

- Allows the owner to withdraw tokens from the Treasury.
- Parameters:
  - `amount`: Amount of tokens to withdraw.
  - `tokenAddress`: Address of the token to withdraw.

### 7. `setAllocationRatios`

- Allows the owner to set allocation ratios for token swaps.
- Parameters:
  - `_usdcAllocationRatio`: Allocation ratio for USDC.
  - `_usdtAllocationRatio`: Allocation ratio for USDT.
  - `_daiAllocationRatio`: Allocation ratio for DAI.

### 8. `swapTokens`

- Allows the owner to swap tokens using Uniswap.
- Parameters:
  - `amountOutMin`: Minimum amount of tokens to receive in the swap.

### 9. `supplyUsdcToAave`

- Allows the owner to supply USDC to Aave.

### 10. `withdrawUsdcFromAave`

- Allows the owner to withdraw USDC from Aave.

### 11. `calculateTotalAaveYield`

- Calculates the total yield from Aave.

## Events

- `Deposit`: Triggered when a user deposits tokens into the Treasury.
- `Withdrawal`: Triggered when the owner withdraws tokens from the Treasury.

## Diagram

![Treasury Contract Diagram](/whim.png)

## License

This smart contract is released under the MIT License.

## Dependencies

This smart contract depends on the following packages:

- OpenZeppelin Contracts: [GitHub](https://github.com/OpenZeppelin/openzeppelin-contracts)
- Uniswap V2 Periphery: [GitHub](https://github.com/Uniswap/v2-periphery)
- Aave Core v3: [GitHub](https://github.com/aave/aave-v3-core)

## Clone the Repository && Install Dependencies

To get started with this project, you can clone the repository to your local machine using the following command:

```bash
git clone https://github.com/web3xDev/UniswapAave-Treasury-Demo
```

```bash
cd UniswapAave-Treasury-Demo
```

```bash
npm install
```

## Usage (Hardhat)

To work with this smart contract using Hardhat, you can follow these commands:

1. **Compile Smart Contracts:**

```bash
   npx hardhat compile
```

2. **Test Smart Contrat:**

```bash
   npx hardhat test
```

3. **Start a Local Hardhat Node:**

```bash
   npx hardhat node
```

4. **Deploy Contract:**

```bash
   npx hardhat deploy
```

## Development on Testnets or Mainnets

If you want to develop and test your smart contract on testnets or mainnets, you can follow these steps:

1. **Set Up .env File:**
   In your project directory, you will find a `.env` file. This file contains the necessary configuration for connecting to different networks. You can open this file and fill in the required information:

2. **Compile and Deploy:**
   You can now use the Hardhat commands to compile and deploy your smart contracts to the specified networks. For example:

```bash
    npx hardhat compile
    npx hardhat run scripts/deploy.js --network mumbai
```
