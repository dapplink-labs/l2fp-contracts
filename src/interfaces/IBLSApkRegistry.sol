// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {BN254} from "../libraries/BN254.sol";

interface IBLSApkRegistry {
    struct FinalityNodeInfo {
        BN254.G1Point pubkey;         // BLS public key
        bool isJailed;                // Jail status
        uint256 registeredTime;       // Registration timestamp
    }

    struct PubkeyRegistrationParams {
        BN254.G1Point pubkeyRegistrationSignature;
        BN254.G1Point pubkeyG1;
        BN254.G2Point pubkeyG2;
    }

    event FinalityNodeRegistered(
        address indexed operator,
        bytes32 pubkeyHash,
        uint256 registeredTime
    );

    event FinalityNodeDeregistered(
        address indexed operator,
        uint256 deregisteredTime
    );

    event FinalityNodeJailed(
        address indexed operator,
        uint256 jailedTime
    );

    event FinalityNodeUnjailed(
        address indexed operator,
        uint256 unjailedTime
    );

    function registerOperator(
        address operator,
        PubkeyRegistrationParams calldata params,
        BN254.G1Point memory msgHash
    ) external returns (bytes32);

    function deRegisterOperator(address operator) external returns (bytes32);

    function jailOperator(address operator) external;

    function unJailOperator(address operator) external;

    function getRegisteredPubkey(address operator) external view returns (BN254.G1Point memory, bytes32);

    function getOperatorFromPubkeyHash(bytes32 pubkeyHash) external view returns (address);

    function getOperatorId(address operator) external view returns (bytes32);

    function isNodeJailed(address operator) external view returns (bool);

    function getOperators() external view returns (address[] memory);

    function getAggregatedPubkey() external view returns (BN254.G2Point memory);

    function pubkeyRegistrationMessageHash(address operator) external view returns (BN254.G1Point memory);
}
