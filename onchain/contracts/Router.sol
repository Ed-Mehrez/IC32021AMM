pragma solidity ^0.7.6;
pragma abicoder v2;

import "./Reserve.sol";
import "./Verifier.sol";

contract Router {
  Reserve public immutable _reserve;
  Verifier public immutable _verifier;

  constructor(address reserveAddress, address verifierAddress) public {
    _reserve = Reserve(reserveAddress);
    _verifier = Verifier(verifierAddress);
  }


  function rebalance(int256 delta, bytes memory signature) external {
    // We are suppose to verify this rebalance processes. However, due to
    // off-chain enclave implementation is not fully ready yet. We commented the
    // logic out for this demo.
    // byte32 hash = keccak256(abi.encodePacked(delta));
    // if (_verifier.enclave() != _verifier.retrieveAddressFromSignature(hash, signature)) return;

    _reserve.rebalance(delta);
  }

  function buyOptions(uint optionPrice, uint amountOptions, int256 delta, bytes memory signature) external {
    // For the purpose of this demo, optionPrice will only be used for verification.
    bytes32 hash = keccak256(abi.encodePacked(optionPrice));
    _verifier.retrieveAddressFromSignature(hash, signature);
    // uncomment once the following is ready
    // if (_verifier.enclave() != _verifier.retrieveAddressFromSignature(hash, signature)) return;
    _reserve.buyOptions(amountOptions, delta);
  }
}