pragma solidity ^0.7.6;
pragma abicoder v2;

import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import './UniswapLib.sol';

// quick and dirty Proxy contract used in demo to swap WETH/USDC pair in parallel to the reserve
// Given the time constraint, we directly copy the existing code to make it work.
contract SimulationProxy {
  uint256 MAX_INT = 2**256 - 1;
  ISwapRouter public immutable _uniswapRouter;

  constructor() public {
    _uniswapRouter = ISwapRouter(UniswapLib.UNISWAP_V3_ROUTER);
    IERC20(UniswapLib.WETH).approve(UniswapLib.UNISWAP_V3_ROUTER, MAX_INT); //  Set Max Approval for neccessary tokens;
    IERC20(UniswapLib.USDC).approve(UniswapLib.UNISWAP_V3_ROUTER, MAX_INT); //  Set Max Approval for neccessary tokens;
  }

  // Following functions are for demo purposes
  function injectETHToContract() external payable {
    IWETH9(UniswapLib.WETH).deposit{value : msg.value}();
  }

  //await instance.convertWEthToUSDC(ethers.utils.parseEther('1.0'), 0)
  function convertWEthToUSDC(uint256 ethAmount) external {
    UniswapLib.swapTokensExactInput(
      IWETH9(UniswapLib.WETH), ethAmount, IERC20(UniswapLib.USDC), 0, _uniswapRouter);
  }

  function convertUSDCToWETHC(uint256 ethAmount) external {
    UniswapLib.swapTokensExactOutput(
      IERC20(UniswapLib.USDC), MAX_INT, IWETH9(UniswapLib.WETH), ethAmount, _uniswapRouter);
  }

  function getUSDCBalance() external view returns (uint256) {
    return IERC20(UniswapLib.USDC).balanceOf(address(this));
  }

  function getWETHBalance() external view returns (uint256) {
    return IWETH9(UniswapLib.WETH).balanceOf(address(this));
  }

  event Price(uint256 usdc);
  function getWETHPrice() external {
    uint256 price = UniswapLib.getWETHToUSDCquote(1 ether);
    emit Price(price);
  }
}