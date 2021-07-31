pragma solidity ^0.7.6;
pragma abicoder v2;

import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import './UniswapLib.sol';

/*
  Demo Contract, given the time constraint, edge cases and balance/security checks are not implemented.
  It's for demo purposes only.
*/
contract Reserve {
  uint256 MAX_INT = 2**256 - 1;
  ISwapRouter public immutable _uniswapRouter;

  constructor() public {
    _uniswapRouter = ISwapRouter(UniswapLib.UNISWAP_V3_ROUTER);
    IERC20(UniswapLib.WETH).approve(UniswapLib.UNISWAP_V3_ROUTER, MAX_INT); //  Set Max Approval for neccessary tokens;
    IERC20(UniswapLib.USDC).approve(UniswapLib.UNISWAP_V3_ROUTER, MAX_INT); //  Set Max Approval for neccessary tokens;
  }

  event CurrentBalance(uint256 wETHAmount);
  function rebalance(int256 delta) external {
    _rebalance(delta);
    emit CurrentBalance(IWETH9(UniswapLib.WETH).balanceOf(address(this)));
  }

  function buyOptions(uint amountOptions, int256 delta) external payable {
    _rebalance(int256(amountOptions) * delta);
  }

  function _rebalance(int256 delta) internal {
    if (delta == 0) return;
    uint256 absoluateDelta = uint256(delta < 0 ? -delta : delta);

    if (delta > 0) {
      // for the sake of this demo, we set the maximum USDC we spend to MAX_INT.
      UniswapLib.swapTokensExactOutput(
        IERC20(UniswapLib.USDC), MAX_INT, IWETH9(UniswapLib.WETH), absoluateDelta, _uniswapRouter);
    } else if (delta < 0) {
      // for the sake of this demo, we set the minimum USDC we get to 0.
      UniswapLib.swapTokensExactInput(
        IWETH9(UniswapLib.WETH), absoluateDelta, IERC20(UniswapLib.USDC), 0, _uniswapRouter);
    }
  }

  // Following functions are for demo purposes
  function injectETHToContract() external payable {
    IWETH9(UniswapLib.WETH).deposit{value : msg.value}();
    emit CurrentBalance(IWETH9(UniswapLib.WETH).balanceOf(address(this)));
  }

  //await instance.convertWEthToUSDC(ethers.utils.parseEther('1.0'), 0)
  function convertWEthToUSDC(uint256 inAmount, uint256 out) external {
    UniswapLib.swapTokensExactInput(
      IWETH9(UniswapLib.WETH), inAmount, IERC20(UniswapLib.USDC), out, _uniswapRouter);
  }

  function getUSDCBalance() external view returns (uint256) {
    return IERC20(UniswapLib.USDC).balanceOf(address(this));
  }

  function getWETHBalance() external view returns (uint256) {
    return IWETH9(UniswapLib.WETH).balanceOf(address(this));
  }

  // await instance.convertUSDCToWETH(MAX_INT, ethers.utils.parseEther('1.0'));
  function convertUSDCToWETH(uint256 inAmount, uint256 out) external {
    UniswapLib.swapTokensExactOutput(
      IERC20(UniswapLib.USDC), inAmount, IWETH9(UniswapLib.WETH), out, _uniswapRouter);
  }
}