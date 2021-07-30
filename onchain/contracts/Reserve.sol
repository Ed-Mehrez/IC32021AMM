pragma solidity ^0.7.6;
pragma abicoder v2;

import {ISwapRouter} from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {IPeripheryImmutableState} from "@uniswap/v3-periphery/contracts/interfaces/IPeripheryImmutableState.sol";
import {IQuoter} from "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import './interfaces/IWETH9.sol';

contract Reserve {
  address private constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
  address public immutable USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
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

  function buyOptions(uint amountOptionDesired, int256 delta) external payable {
    IWETH9(WETH).deposit{value: msg.value}();
    emit BuyOptionsResult(msg.value, delta, false, "here", IWETH9(WETH).balanceOf(address(this)));
  }

  event RebalanceResult(uint256 wETHAmount);

  function rebalance(int256 delta) external {

  }

  // Add settlement and ERC 20
}