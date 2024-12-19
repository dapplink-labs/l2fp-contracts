// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {BN254} from "../libraries/BN254.sol";

interface IBLSApkRegistry {
    struct FinalityNonSingerAndSignature {
        uint32[] nonSignerQuorumBitmapIndices;
        BN254.G1Point[] nonSignerPubkeys;
        BN254.G1Point[] quorumApks;
        BN254.G2Point apkG2;
        BN254.G1Point sigma;
        uint32[] quorumApkIndices;
        uint256 totalBtcStake;
        uint256 totalMantaStake;
        uint32[][] nonSignerStakeIndices;
    }

    struct ApkUpdate {
        bytes24 apkHash;
        uint32 updateBlockNumber;
        uint32 nextUpdateBlockNumber;
    }

    struct PubkeyRegistrationParams {
        BN254.G1Point pubkeyRegistrationSignature;
        BN254.G1Point pubkeyG1;
        BN254.G2Point pubkeyG2;
    }

    event NewPubkeyRegistration(
        address indexed operator,
        BN254.G1Point pubkeyG1,
        BN254.G2Point pubkeyG2
    );

    event OperatorAdded(
        address operator,
        bytes32 operatorId
    );

    event OperatorRemoved(
        address operator,
        bytes32 operatorId
    );

    function registerOperator(
        address operator,
        bytes memory quorumNumbers
    ) public virtual;

    function deregisterOperator(
        address operator,
        bytes memory quorumNumbers
    ) public virtual;

    function registerBLSPublicKey(
        address operator,
        PubkeyRegistrationParams calldata params,
        BN254.G1Point memory msgHash
    ) external returns (bytes32);

    function checkSignatures(
        bytes32 msgHash,
        uint32 referenceBlockNumber,
        FinalityNonSingerAndSignature memory params
    ) external view returns (bool);


    function getRegisteredPubkey(address operator) external view returns (BN254.G1Point memory, bytes32);

    function getOperatorFromPubkeyHash(bytes32 pubkeyHash) external view returns (address);

    function getOperatorId(address operator) external view returns (bytes32);

    function getOperators() external view returns (address[] memory);

}
