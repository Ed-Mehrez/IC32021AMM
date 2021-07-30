pragma solidity ^0.7.6;
pragma abicoder v2;

import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IPeripheryImmutableState} from "@uniswap/v3-periphery/contracts/interfaces/IPeripheryImmutableState.sol";
import {IQuoter} from "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import './interfaces/IWETH9.sol';

contract Reserve {
  using SafeERC20 for IERC20;

  address private constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
  address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address private constant UNISWAP_V3_IQUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
  uint24 private constant FEE = 3000; // 0.3%
  unit24 private constant TRANSACTION_BUFFER_TIME = 60;
  ISwapRouter public immutable _uniswapRouter;
  address private immutable WETH;

  constructor() public {
    _uniswapRouter = ISwapRouter(UNISWAP_V3_ROUTER);
    WETH = IPeripheryImmutableState(UNISWAP_V3_ROUTER).WETH9();
  }

  event CurrentBalance(uint256 wETHAmount);
  function rebalance(int256 delta) external {
    _rebalance(delta);
    emit CurrentBalance(IWETH9(WETH).balanceOf(address(this)));
  }

  function buyOptions(uint amountOptions, int256 delta) external payable {
    _rebalance(delta);
  }

  function _rebalance(int256 delta) internal {
    if (delta == 0) return;

    uint256 absoluateDelta = uint256(delta < 0 ? -delta : delta);
    uint256 estimateUSDC = _getWETHToUSDCquote(absoluateDelta);

    if (delta > 0) {
      // for the sake of this demo, we set the maximum USDC we can spend to twice of the estimated exchange rate.
      _swapTokensExactOut(IERC20(USDC), estimateUSDC * 2, IWETH9(WETH), absoluateDelta);
    } else if (delta < 0) {
      // for the sake of this demo, we set the minimum USDC we get by selling WETH to half of the estimated exchange
      // rate.
      _swapTokensExactInput(IWETH9(WETH), absoluateDelta, IERC20(USDC), estimateUSDC / 2);
    }
  }

  function _getWETHToUSDCquote(uint256 amountIn) internal returns (uint256) {
    amountIn = amountIn * 1000000000000;
    return IQuoter(UNISWAP_V3_IQUOTER).quoteExactInputSingle(WETH, USDC, FEE, amountIn, 0);
  }

  function _swapTokensExactInput(IERC20 tokenIn, uint256 amountIn, IERC20 tokenOut, uint256 amountOut) internal {
    tokenIn.safeIncreaseAllowance(address(_uniswapRouter), amountIn);
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
    _uniswapRouter.exactInputSingle(params);
  }

  function _swapTokensExactOut(IERC20 tokenIn, uint256 amountIn, IERC20 tokenOut, uint256 amountOut) internal {
    tokenIn.safeIncreaseAllowance(address(_uniswapRouter), amountIn);
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
    _uniswapRouter.exactOutputSingle(params);
  }

  // Following functions are for demo purposes
  function injectETHToContract() external payable {
    IWETH9(WETH).deposit{value : msg.value}();
    emit CurrentBalance(IWETH9(WETH).balanceOf(address(this)));
  }

  //await instance.convertWEthToUSDC(ethers.utils.parseEther('1.0'), 0)
  function convertWEthToUSDC(uint256 inAmount, uint256 out) external {
    _swapTokensExactInput(IWETH9(WETH), inAmount, IERC20(USDC), out);
  }

  function getUSDCBalance() external view returns (uint256) {
    return IERC20(USDC).balanceOf(address(this));
  }

  function getWETHBalance() external view returns (uint256) {
    return IWETH9(WETH).balanceOf(address(this));
  }
}