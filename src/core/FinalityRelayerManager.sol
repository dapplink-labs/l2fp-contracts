// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../interfaces/IFinalityRelayerManager.sol";

contract FinalityRelayerManager is IFinalityRelayerManager {

    function registerOperator(
        PubkeyRegistrationParams calldata params,
        BN254.G1Point calldata pubkeyRegistrationMessageHash,
        string calldata nodeUrl
    ) external {

    }

    function deRegisterOperator() external {

    }

    function VerifyFinalitySignature(
        FinalityBatch calldata finalityBatch,
        FinalityNonSingerAndSignature memory finalityNonSingerAndSignature
    ) external {

    }
}
