pragma solidity ^0.7.6;
pragma abicoder v2;

import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IQuoter} from "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import './interfaces/IWETH9.sol';

library UniswapLib {
  using SafeERC20 for IERC20;

  uint24 private constant TRANSACTION_BUFFER_TIME = 60;
  uint24 private constant FEE = 3000; // 0.3%

  address public constant UNISWAP_V3_IQUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
  address public constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
  address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  function getWETHToUSDCquote(uint256 amountIn) public returns (uint256) {
    return IQuoter(UNISWAP_V3_IQUOTER).quoteExactInputSingle(WETH, USDC, FEE, amountIn, 0);
  }

  function swapTokensExactInput(IERC20 tokenIn, uint256 amountIn, IERC20 tokenOut,
                                uint256 amountOut, ISwapRouter router) public {
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
      address(tokenIn),
      address(tokenOut),
      FEE,
      address(this), // recipient
      block.timestamp + TRANSACTION_BUFFER_TIME, // deadline
      amountIn, // amountIn
      amountOut, // amountOutMinimum
      0 // sqrtPriceLimitX96. Ignore pool price limits
    );
    router.exactInputSingle(params);
  }

  function swapTokensExactOutput(IERC20 tokenIn, uint256 amountIn, IERC20 tokenOut,
                                 uint256 amountOut, ISwapRouter router) public {
    // For the sake of demo, setting the allowance to a big number for now.
    ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams(
      address(tokenIn),
      address(tokenOut),
      FEE,
      address(this), // recipient
      block.timestamp + TRANSACTION_BUFFER_TIME, // deadline
      amountOut, // amountOut
      amountIn, // amountInMaximum
      0 // sqrtPriceLimitX96. Ignore pool price limits
    );
    router.exactOutputSingle(params);
  }
}