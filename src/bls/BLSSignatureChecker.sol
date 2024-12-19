// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {BN254} from "../libraries/BN254.sol";
import {BLSApkRegistry} from "./BLSApkRegistry.sol";
import {IBLSSignatureChecker} from "../interfaces/IBLSSignatureChecker.sol";

contract BLSSignatureChecker is IBLSSignatureChecker {
    using BN254 for BN254.G1Point;

    uint256 internal constant PAIRING_EQUALITY_CHECK_GAS = 120000;

    BLSApkRegistry internal immutable registry;

    constructor(address registry_) {
        registry = BLSApkRegistry(registry_);
    }

    function verifySignature(SignatureParams calldata params) external view returns (bool) {
        require(params.signature.length == 64, "BLSSignatureChecker.verifySignature: Invalid signature length");

        address[] memory operators = registry.getOperators();
        require(operators.length > 0, "BLSSignatureChecker.verifySignature: No registered operators");

        for(uint i = 0; i < operators.length; i++) {
            require(
                registry.getOperatorId(operators[i]) != bytes32(0),
                "BLSSignatureChecker.verifySignature: Operator not registered"
            );
            require(
                !registry.isNodeJailed(operators[i]),
                "BLSSignatureChecker.verifySignature: Operator is jailed"
            );
        }

        BN254.G1Point memory sigma = _bytesToG1Point(params.signature);

        BN254.G2Point memory aggregatedPubkey = registry.getAggregatedPubkey();

        (bool pairingSuccessful, bool signatureIsValid) = BN254.safePairing(
            sigma,
            BN254.negGeneratorG2(),
            BN254.hashToG1(params.msgHash),
            aggregatedPubkey,
            PAIRING_EQUALITY_CHECK_GAS
        );

        require(pairingSuccessful, "BLSSignatureChecker.verifySignature: pairing precompile call failed");
        return signatureIsValid;
    }

    function _bytesToG1Point(bytes memory sig) internal pure returns (BN254.G1Point memory) {
        require(sig.length == 64, "BLSSignatureChecker._bytesToG1Point: Invalid signature length");

        uint256 x;
        uint256 y;

        assembly {
            x := mload(add(sig, 32))
            y := mload(add(sig, 64))
        }

        return BN254.G1Point(x, y);
    }

}