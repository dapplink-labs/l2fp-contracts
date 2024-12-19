// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../interfaces/IBLSApkRegistry.sol";

import {BLSApkRegistryStorage} from "./BLSApkRegistryStorage.sol";
import {BN254} from "../libraries/BN254.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {OwnableUpgradeable} from "@openzeppelin-upgrades/contracts/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin-upgrades/contracts/proxy/utils/Initializable.sol";


contract BLSApkRegistry is Initializable, EIP712, OwnableUpgradeable, IBLSApkRegistry, BLSApkRegistryStorage {
    using BN254 for BN254.G1Point;

    /// @notice when applied to a function, only allows the RegistryCoordinator to call it
    modifier onlyFinalityRelayerManager() {
        require(
            msg.sender == address(finalityRelayerManager),
            "BLSApkRegistry.onlyFinalityRelayerManager: caller is not finality relayer manager contracts "
        );
        _;
    }

    modifier onlyRelayerManager() {
        require(
            msg.sender == address(relayerManager),
            "BLSApkRegistry.onlyRelayerManager: caller is not the relayer manager address"
        );
        _;
    }


    constructor(
        address relayerManager_
    ) BLSApkRegistryStorage(relayerManager_) EIP712("BLSApkRegistry", "1") {
        _disableInitializers();
    }

    /*******************************************************************************
                      EXTERNAL FUNCTIONS - REGISTRY COORDINATOR
    *******************************************************************************/
    function registerOperator(
        address operator,
        bytes memory quorumNumbers
    ) public virtual onlyFinalityRelayerManager {
        (BN254.G1Point memory pubkey, ) = getRegisteredPubkey(operator);

        _processQuorumApkUpdate(pubkey);

        emit OperatorAdded(operator, getOperatorId(operator));
    }

    function deregisterOperator(
        address operator,
        bytes memory quorumNumbers
    ) public virtual onlyFinalityRelayerManager {
        (BN254.G1Point memory pubkey, ) = getRegisteredPubkey(operator);

        _processQuorumApkUpdate(pubkey.negate());
        emit OperatorRemoved(operator, getOperatorId(operator));
    }

    function registerBLSPublicKey(
        address operator,
        PubkeyRegistrationParams calldata params,
        BN254.G1Point calldata pubkeyRegistrationMessageHash
    ) external onlyRelayerManager returns (bytes32) {
        bytes32 pubkeyHash = BN254.hashG1Point(params.pubkeyG1);
        require(
            pubkeyHash != ZERO_PK_HASH,
            "BLSApkRegistry.registerBLSPublicKey: cannot register zero pubkey"
        );
        require(
            operatorToPubkeyHash[operator] == bytes32(0),
            "BLSApkRegistry.registerBLSPublicKey: operator already registered pubkey"
        );

        require(
            pubkeyHashToOperator[pubkeyHash] == address(0),
            "BLSApkRegistry.registerBLSPublicKey: public key already registered"
        );

        // gamma = h(sigma, P, P', H(m))
        uint256 gamma = uint256(keccak256(abi.encodePacked(
            params.pubkeyRegistrationSignature.X,
            params.pubkeyRegistrationSignature.Y,
            params.pubkeyG1.X,
            params.pubkeyG1.Y,
            params.pubkeyG2.X,
            params.pubkeyG2.Y,
            pubkeyRegistrationMessageHash.X,
            pubkeyRegistrationMessageHash.Y
        ))) % BN254.FR_MODULUS;

        // e(sigma + P * gamma, [-1]_2) = e(H(m) + [1]_1 * gamma, P')
        require(BN254.pairing(
            params.pubkeyRegistrationSignature.plus(params.pubkeyG1.scalar_mul(gamma)),
            BN254.negGeneratorG2(),
            pubkeyRegistrationMessageHash.plus(BN254.generatorG1().scalar_mul(gamma)),
            params.pubkeyG2
        ), "BLSApkRegistry.registerBLSPublicKey: either the G1 signature is wrong, or G1 and G2 private key do not match");


        operatorToPubkey[operator] = params.pubkeyG1;
        operatorToPubkeyHash[operator] = pubkeyHash;
        pubkeyHashToOperator[pubkeyHash] = operator;

        emit NewPubkeyRegistration(operator, params.pubkeyG1, params.pubkeyG2);

        return pubkeyHash;
    }

    function checkSignatures(
        bytes32 msgHash,
        uint32 referenceBlockNumber,
        FinalityNonSingerAndSignature memory params
    ) external view returns (bool) {
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

    /*******************************************************************************
                           INTERNAL FUNCTIONS
    *******************************************************************************/
    function _processApkUpdate(BN254.G1Point memory point) internal {
        BN254.G1Point memory newApk;

        uint256 historyLength = apkHistory.length;
        require(historyLength != 0, "BLSApkRegistry._processQuorumApkUpdate: quorum does not exist");

        currentApk = currentApk.plus(point);

        bytes24 newApkHash = bytes24(BN254.hashG1Point(newApk));

        ApkUpdate storage lastUpdate = apkHistory[historyLength - 1];
        if (lastUpdate.updateBlockNumber == uint32(block.number)) {
            lastUpdate.apkHash = newApkHash;
        } else {
            lastUpdate.nextUpdateBlockNumber = uint32(block.number);
            apkHistory.push(ApkUpdate({
                apkHash: newApkHash,
                updateBlockNumber: uint32(block.number),
                nextUpdateBlockNumber: 0
            }));
        }
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


    /*******************************************************************************
                            VIEW FUNCTIONS
    *******************************************************************************/
    function getRegisteredPubkey(address operator) public view returns (BN254.G1Point memory, bytes32) {
        BN254.G1Point memory pubkey = operatorToPubkey[operator];
        bytes32 pubkeyHash = operatorToPubkeyHash[operator];

        require(
            pubkeyHash != bytes32(0),
            "BLSApkRegistry.getRegisteredPubkey: operator is not registered"
        );

        return (pubkey, pubkeyHash);
    }

    function getOperatorFromPubkeyHash(bytes32 pubkeyHash) public view returns (address) {
        return pubkeyHashToOperator[pubkeyHash];
    }

    function getOperatorId(address operator) public view returns (bytes32) {
        return operatorToPubkeyHash[operator];
    }


    function getOperators() external view returns (address[] memory) {
        return operators;
    }
}
