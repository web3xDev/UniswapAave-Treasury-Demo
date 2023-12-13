const hre = require("hardhat");

// Only for Mumbai testnet
const usdcTokenAddress = "0x52D800ca262522580CeBAD275395ca6e7598C014";
const usdtTokenAddress = "0x1fdE0eCc619726f4cD597887C9F3b4c8740e19e2";
const daiTokenAddress = "0xc8c0Cf9436F4862a8F60Ce680Ca5a9f0f99b5ded";
const uniswapRouterAddress = "0x8954AfA98594b838bda56FE4C12a09D7739D179b";
const aavePoolAddress = "0xcC6114B983E4Ed2737E9BD3961c9924e6216c704";

async function main() {
  const treasury = await hre.ethers.deployContract("Treasury", [
    usdcTokenAddress,
    usdtTokenAddress,
    daiTokenAddress,
    uniswapRouterAddress,
    aavePoolAddress,
  ]);

  await treasury.waitForDeployment();

  console.log("Treasury contract deployed to:", treasury.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
