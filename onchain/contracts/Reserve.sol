pragma solidity ^0.7.0;
pragma abicoder v2;

contract Reservse {
  event BuyOptionsResult(uint amountOptionDesired, int256 delta, bool sucess, string msg);
  event RebalanceResult(uint256 wETHAmount);

  function buyOptions(uint amountOptionDesired, int256 delta) external {
  }

  function rebalance(int256 delta) external {

  }
}