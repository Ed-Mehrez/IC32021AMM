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
  address public immutable USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  uint24 constant FEE = 3000; // 0.3%
  ISwapRouter public immutable _uniswapRouter;
  address public immutable WETH;

  constructor() public {
    _uniswapRouter = ISwapRouter(UNISWAP_V3_ROUTER);
    WETH = IPeripheryImmutableState(UNISWAP_V3_ROUTER).WETH9();
  }

  function currentWETHAddress() external view returns (address)  {
    return WETH;
  }

  event AmountOut(uint256 quoteResult);

  function getWETHToUSDCquote(uint256 amountIn) external {
    amountIn = amountIn * 1000000000000;
    uint256 num = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6).quoteExactInputSingle(WETH, USDC, 3000, amountIn, 0);
    emit AmountOut(num);
  }

  event BuyOptionsResult(uint amountOptionDesired, int256 delta, bool sucess, string msg, uint256 weth_balance);

  event CurrentBalance(uint256 wETHAmount);

  function rebalance(int256 delta) external {

  }

  function buyOptions(uint amountOptionDesired, uint amountInUSDC, int256 delta) external payable {
    emit BuyOptionsResult(IERC20(USDC).balanceOf(address(msg.sender)), 0, IERC20(USDC).balanceOf(address(msg.sender)) >= amountInUSDC, "", 0);
    //require(IERC20(USDC).balanceOf(address(msg.sender)) >= amountInUSDC);
    // Also check if can fulfill delta if have time
  }

  function swapTokensIn(IERC20 tokenIn, uint256 amountIn, IERC20 tokenOut, uint256 amountOut) internal {
    tokenIn.safeIncreaseAllowance(address(_uniswapRouter), amountIn);
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
      address(tokenIn), // tokenIn
      address(tokenOut), // tokenOut
      FEE, // fee
      address(this), // recipient
      block.timestamp + 62, // deadline
      amountIn, // amountIn
      amountOut, // amountOutMinimum
      0 // sqrtPriceLimitX96. Ignore pool price limits
    );
    _uniswapRouter.exactInputSingle(params);
  }

  function swapTokensOut(IERC20 tokenIn, uint256 amountIn, IERC20 tokenOut, uint256 amountOut) internal {
    tokenIn.safeIncreaseAllowance(address(_uniswapRouter), amountIn);
    ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
      address(tokenIn), // tokenIn
      address(tokenOut), // tokenOut
      FEE, // fee
      address(this), // recipient
      block.timestamp + 62, // deadline
      amountOut, // amountOut
      amountIn, // amountInMaximum
      0 // sqrtPriceLimitX96. Ignore pool price limits
    );
    _uniswapRouter.exactOutputSingle(params);
  }

  // ===================================
  // Backdoor functions for demo purposes
  function injectEthToContract() external payable {
    IWETH9(WETH).deposit{value: msg.value}();
    emit CurrentBalance(IWETH9(WETH).balanceOf(address(this)));
  }

  function getUSDCBalance() external view returns (uint256) {
    return IERC20(USDC).balanceOf(address(this));
  }

  function getWETHBalance() external view returns (uint256) {
    return IWETH9(WETH).balanceOf(address(this));
  }

  //await instance.test(ethers.utils.parseEther('1.0'), 0)
  function getUSDC(uint256 inAmount, uint256 out) external {
    swapTokens(IWETH9(WETH), inAmount, IERC20(USDC), out);
  }
  // Add settlement and ERC 20
}