 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {BN254} from "../libraries/BN254.sol";

interface IBLSSignatureChecker {
    struct SignatureParams {
        bytes32 msgHash;           // Message hash
        bytes signature;           // Aggregated signature
        uint32 blockNumber;        // Block number at the time of signing
    }

    function verifySignature(SignatureParams calldata params) external view returns (bool);
}
