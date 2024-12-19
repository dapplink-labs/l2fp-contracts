// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {OwnableUpgradeable} from "@openzeppelin-upgrades/contracts/access/OwnableUpgradeable.sol";

import "../interfaces/IFinalityRelayerManager.sol";
import "../interfaces/IBLSApkRegistry.sol";
import "./FinalityRelayerManagerStorage.sol";

contract FinalityRelayerManager is OwnableUpgradeable, FinalityRelayerManagerStorage, IFinalityRelayerManager {

    modifier onlyOperatorWhitelistManager() {
        require(
            msg.sender == operatorWhitelistManager,
            "StrategyManager.onlyFinalityWhiteListManager: not the finality whitelist manager"
        );
        _;
    }

    constructor(
        address _blsApkRegistry
    ) FinalityRelayerManagerStorage(IBLSApkRegistry(_blsApkRegistry)) {
        _disableInitializers();
    }

    function initialize(
        address initialOwner
    ) external initializer {
        _transferOwnership(initialOwner);
    }

    function registerOperator(string calldata nodeUrl) external {
        require(
            operatorWhitelist[msg.sender],
            "FinalityRelayerManager.registerOperator: this address have not permission to register "
        );
        blsApkRegistry.registerOperator(msg.sender);
        emit OperatorRegistered(msg.sender, nodeUrl);
    }

    function deRegisterOperator() external {
        require(
            operatorWhitelist[msg.sender],
            "FinalityRelayerManager.registerOperator: this address have not permission to register "
        );
        blsApkRegistry.deregisterOperator(msg.sender);
        emit OperatorDeRegistered(msg.sender);
    }

    function VerifyFinalitySignature(
        FinalityBatch calldata finalityBatch,
        IBLSApkRegistry.FinalityNonSingerAndSignature memory finalityNonSingerAndSignature
    ) external {
        (
            IBLSApkRegistry.StakeTotals memory stakeTotals,
            bytes32 signatoryRecordHash
        ) = blsApkRegistry.checkSignatures(finalityBatch.msgHash, finalityBatch.l2BlockNumber, finalityNonSingerAndSignature);
        emit VerifyFinalitySig(stakeTotals.totalBtcStaking, stakeTotals.totalMantaStaking, signatoryRecordHash);
    }

    function addOrRemoverOperatorWhitelist(address operator, bool isAdd) external onlyOperatorWhitelistManager {
        require(
            operator != address (0),
            "FinalityRelayerManager.addOperatorWhitelist: operator address is zero"
        );
        operatorWhitelist[operator] = isAdd;
    }
}
