const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Treasury Contract", function () {
  let treasury, owner, addr1;
  let usdcToken, usdtToken, daiToken, uniswapRouter, aavePool;

  // Only for Mumbai testnet, will not work on local Hardhat node
  const USDC_ADDRESS = "0x52D800ca262522580CeBAD275395ca6e7598C014";
  const USDT_ADDRESS = "0x1fdE0eCc619726f4cD597887C9F3b4c8740e19e2";
  const DAI_ADDRESS = "0xc8c0Cf9436F4862a8F60Ce680Ca5a9f0f99b5ded";
  const UNISWAP_ROUTER_ADDRESS = "0x8954AfA98594b838bda56FE4C12a09D7739D179b";
  const AAVE_POOL_ADDRESS = "0xcC6114B983E4Ed2737E9BD3961c9924e6216c704";

  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();

    // Deploy the Treasury contract
    treasury = await hre.ethers.deployContract("Treasury", [
      USDC_ADDRESS,
      USDT_ADDRESS,
      DAI_ADDRESS,
      UNISWAP_ROUTER_ADDRESS,
      AAVE_POOL_ADDRESS,
    ]);

    await treasury.waitForDeployment();

    // Initialize token and other contract instances
    usdcToken = await ethers.getContractAt("IERC20", USDC_ADDRESS);
    usdtToken = await ethers.getContractAt("IERC20", USDT_ADDRESS);
    daiToken = await ethers.getContractAt("IERC20", DAI_ADDRESS);
    uniswapRouter = await ethers.getContractAt(
      "IUniswapV2Router02",
      UNISWAP_ROUTER_ADDRESS
    );
    aavePool = await ethers.getContractAt("IPool", AAVE_POOL_ADDRESS);
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await treasury.owner()).to.equal(owner.address);
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await usdcToken.balanceOf(owner.address);
      expect(await usdcToken.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      // Transfer some tokens to addr1
      await usdcToken.transfer(addr1.address, 50);
      const addr1Balance = await usdcToken.balanceOf(addr1.address);
      expect(addr1Balance).to.equal(50);
    });

    it("Should fail if sender doesn’t have enough tokens", async function () {
      const initialOwnerBalance = await usdcToken.balanceOf(owner.address);

      // Try to send 1 token from addr1 (0 tokens) to owner (10000 tokens).
      // `require` will evaluate false and revert the transaction.
      await expect(usdcToken.connect(addr1).transfer(owner.address, 1)).to.be
        .reverted;

      // Owner balance shouldn't have changed.
      expect(await usdcToken.balanceOf(owner.address)).to.equal(
        initialOwnerBalance
      );
    });
  });

  describe("Treasury Functions", function () {
    it("Should deposit tokens correctly", async function () {
      const depositAmount = 100;

      // Owner deposits tokens to the Treasury
      await usdcToken.approve(treasury.address, depositAmount);
      await treasury.deposit(depositAmount, USDC_ADDRESS);

      // Check Treasury balance
      const treasuryBalance = await usdcToken.balanceOf(treasury.address);
      expect(treasuryBalance).to.equal(depositAmount);
    });

    it("Should withdraw tokens correctly", async function () {
      const depositAmount = 100;
      const withdrawAmount = 50;

      // Owner deposits tokens to the Treasury
      await usdcToken.approve(treasury.address, depositAmount);
      await treasury.deposit(depositAmount, USDC_ADDRESS);

      // Owner withdraws some tokens from the Treasury
      await treasury.withdraw(withdrawAmount, USDC_ADDRESS);

      // Check remaining Treasury balance
      const treasuryBalance = await usdcToken.balanceOf(treasury.address);
      expect(treasuryBalance).to.equal(depositAmount - withdrawAmount);
    });

    it("Should handle token swaps correctly", async function () {
      // Logic to test token swap functionality, i'll add this later
    });

    it("Should interact with Aave correctly", async function () {
      // Logic to test interactions with Aave, i'll add this later
    });

    it("Should calculate yield correctly", async function () {
      // Logic to test yield calculation, i'll add this later
    });
  });
});
