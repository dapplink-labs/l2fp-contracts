// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/BN254.sol";
import "./IBLSApkRegistry.sol";

contract IFinalityRelayerManager {
    struct FinalityBatch {
        bytes32 stateRoot;
        uint256 l2BlockNumber;
        bytes32 l1BlockHash;
        uint256 l1BlockNumber;
        bytes quorumNumbers;
        bytes signedStakeForQuorums;
        uint32 referenceBlockNumber;
    }

    struct PubkeyRegistrationParams {
        BN254.G1Point pubkeyRegistrationSignature;
        BN254.G1Point pubkeyG1;
        BN254.G2Point pubkeyG2;
    }


    function registerOperator( PubkeyRegistrationParams calldata params, BN254.G1Point calldata pubkeyRegistrationMessageHash, string calldata nodeUrl) external;

    function deRegisterOperator() external;

    function VerifyFinalitySignature(
        FinalityBatch calldata finalityBatch,
        FinalityNonSingerAndSignature memory finalityNonSingerAndSignature
    ) external;

}
