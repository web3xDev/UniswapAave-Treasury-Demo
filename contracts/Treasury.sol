// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importing necessary OpenZeppelin contracts
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Importing Uniswap V2 Router interface
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// Importing Aave Pool interface
import "@aave/core-v3/contracts/interfaces/IPool.sol";

// Treasury contract definition
contract Treasury is ReentrancyGuard, Ownable {
    // Token addresses for USDC, USDT, and DAI
    address public usdcTokenAddress;
    address public usdtTokenAddress;
    address public daiTokenAddress;

    // Allocation ratios for USDC, USDT, and DAI
    uint256 private usdcAllocationRatio;
    uint256 private usdtAllocationRatio;
    uint256 private daiAllocationRatio;

    // Global variables to store initial balances
    uint256 public initialUsdcBalance = 0;
    uint256 public initialUsdtBalance = 0;
    uint256 public initialDaiBalance = 0;

    // Token interfaces for USDC, USDT, and DAI
    IERC20 usdcToken;
    IERC20 usdtToken;
    IERC20 daiToken;

    // Address of the Aave Pool
    IPool public aavePool;

    // Uniswap V2 Router interface
    IUniswapV2Router02 public uniswapRouter;

    // Tracks total investment in the Aave pool
    uint256 private totalDepositedToAave;

    // Events for deposit and withdrawal
    event Deposit(address indexed from, uint256 amount, address token);
    event Withdrawal(address indexed to, uint256 amount, address token);

    // Constructor to set initial values
    constructor(
        address _usdcTokenAddress,
        address _usdtTokenAddress,
        address _daiTokenAddress,
        address _uniswapRouterAddress,
        address _aavePoolAddress
    ) Ownable(msg.sender) {
        setTokenAddresses(_usdcTokenAddress, _usdtTokenAddress, _daiTokenAddress);
        setUniswapRouterAddress(_uniswapRouterAddress);
        setAavePoolAddress(_aavePoolAddress);
    }

    // Function to set token addresses
    function setTokenAddresses(address _usdcTokenAddress, address _usdtTokenAddress, address _daiTokenAddress) public onlyOwner {
        usdcTokenAddress = _usdcTokenAddress;
        usdtTokenAddress = _usdtTokenAddress;
        daiTokenAddress = _daiTokenAddress;

        usdcToken = IERC20(usdcTokenAddress);
        usdtToken = IERC20(usdtTokenAddress);
        daiToken = IERC20(daiTokenAddress);
    }

    // Function to set the Uniswap router address
    function setUniswapRouterAddress(address _uniswapRouterAddress) public onlyOwner {
        require(_uniswapRouterAddress != address(0), "Invalid Uniswap v2 Router address");
        uniswapRouter = IUniswapV2Router02(_uniswapRouterAddress);
    }

    // Function to set the Aave Pool address
    function setAavePoolAddress(address _aavePoolAddress) public onlyOwner {
        require(_aavePoolAddress != address(0), "Invalid Aave pool address");
        aavePool = IPool(_aavePoolAddress);
    }

    // Function to deposit tokens into the Treasury
    function deposit(uint256 amount, address tokenAddress) external nonReentrant {
        require(tokenAddress == usdcTokenAddress || tokenAddress == usdtTokenAddress || tokenAddress == daiTokenAddress, "Invalid token address");
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(msg.sender, address(this), amount), "Failed to transfer tokens");

        // Update initial balances based on the token
        if (tokenAddress == usdcTokenAddress) {
            if (initialUsdcBalance == 0) {
                initialUsdcBalance = usdcToken.balanceOf(address(this));
            }
        } else if (tokenAddress == usdtTokenAddress) {
            if (initialUsdtBalance == 0) {
                initialUsdtBalance = usdtToken.balanceOf(address(this));
            }
        } else if (tokenAddress == daiTokenAddress) {
            if (initialDaiBalance == 0) {
                initialDaiBalance = daiToken.balanceOf(address(this));
            }
        }

        emit Deposit(msg.sender, amount, tokenAddress);
    }

    // Function to withdraw tokens from the Treasury
    function withdraw(uint256 amount, address tokenAddress) external onlyOwner nonReentrant {
        require(tokenAddress == usdtTokenAddress || tokenAddress == daiTokenAddress, "Invalid token address");
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        require(token.transfer(msg.sender, amount), "Failed to transfer tokens");
        emit Withdrawal(msg.sender, amount, tokenAddress);
    }

    // Function to set allocation ratios for token swaps
    function setAllocationRatios(uint256 _usdcAllocationRatio, uint256 _usdtAllocationRatio, uint256 _daiAllocationRatio) external onlyOwner {
        require(_usdcAllocationRatio + _usdtAllocationRatio + _daiAllocationRatio == 100, "Allocation ratios must add up to 100");
        usdcAllocationRatio = _usdcAllocationRatio;
        usdtAllocationRatio = _usdtAllocationRatio;
        daiAllocationRatio = _daiAllocationRatio;
    }

    // Function to swap tokens using Uniswap
    function swapTokens(uint256 amountOutMin) external onlyOwner {
        uint256 usdcBalance = usdcToken.balanceOf(address(this));
        uint256 usdtBalance = usdtToken.balanceOf(address(this));
        uint256 daiBalance = daiToken.balanceOf(address(this));

        // Swap USDC to USDT
        if (usdcAllocationRatio > 0 && usdcBalance > 0) {
            usdcToken.approve(address(uniswapRouter), usdcBalance);
            uniswapRouter.swapExactTokensForTokens(
                (usdcBalance * usdcAllocationRatio) / 100,
                amountOutMin,
                getPath(address(usdcToken), address(usdtToken)),
                address(this),
                block.timestamp + 600
            );
        }

        // Swap USDT to DAI
        if (usdtAllocationRatio > 0 && usdtBalance > 0) {
            usdtToken.approve(address(uniswapRouter), usdtBalance);
            uniswapRouter.swapExactTokensForTokens(
                (usdtBalance * usdtAllocationRatio) / 100,
                amountOutMin,
                getPath(address(usdtToken), address(daiToken)),
                address(this),
                block.timestamp + 600
            );
        }

        // Swap DAI to USDT
        if (daiAllocationRatio > 0 && daiBalance > 0) {
            daiToken.approve(address(uniswapRouter), daiBalance);
            uniswapRouter.swapExactTokensForTokens(
                (daiBalance * daiAllocationRatio) / 100,
                amountOutMin,
                getPath(address(daiToken), address(usdtToken)),
                address(this),
                block.timestamp + 600
            );
        }
    }

    // Function to record deposits to and withdrawals from Aave
    function recordDepositToAave(uint256 amount, bool isDeposit) internal {
        if (isDeposit) {
            totalDepositedToAave += amount;
        } else {
            totalDepositedToAave -= amount;
        }
    }

    // Function to supply USDC to Aave
    function supplyUsdcToAave(uint256 amount) external onlyOwner nonReentrant {
        require(usdcToken.balanceOf(address(this)) >= amount, "Insufficient USDC balance in Treasury");
    
        usdcToken.approve(address(aavePool), amount);
        aavePool.supply(usdcTokenAddress, amount, address(this), 0);
        recordDepositToAave(amount, true); // Update total investment
    }

    // Function to withdraw USDC from Aave
    function withdrawUsdcFromAave(uint256 amount) external onlyOwner nonReentrant {
        aavePool.withdraw(usdcTokenAddress, amount, address(this));
        recordDepositToAave(amount, false); // Record withdrawn amount
    }

    // Function to calculate total yield from Aave
    function calculateTotalAaveYield() public view returns (uint256) {
        IERC20 aaveUsdcToken = IERC20(usdcTokenAddress); // Define USDC token in Aave
        uint256 currentBalance = aaveUsdcToken.balanceOf(address(this)); // Get current balance

        if (currentBalance > totalDepositedToAave) {
            return currentBalance - totalDepositedToAave; // Calculate total yield
        } else {
            return 0; // Return 0 if no yield
        }
    }

    // Helper function to get the path for token swapping
    function getPath(
        address fromToken,
        address toToken
    ) private pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = fromToken;
        path[1] = toToken;
        return path;
    }
}