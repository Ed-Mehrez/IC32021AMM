// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

contract Verifier {

    bytes32 private constant enclavepk;

    constructor(bytes32 _enclavepk) {
        enclavepk = _enclavepk;
    }

    function retrieveAddressFromSignature(bytes32 _message, bytes memory _signature) public pure returns(address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        address deliveryAddress;

        // Check the signature length
        if (_signature.length != 65) deliveryAddress = address(0); //return deliveryAddress

        // Divide the signature in r, s and v variables
        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) v += 27;

        // If the version is correct return the signer address
        if (v != 27 && v != 28) deliveryAddress = address(0); //return
        else deliveryAddress = ecrecover(_message, v, r, s); // return

        return deliveryAddress;
    }


    }

}