// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin-upgrades/contracts/access/OwnableUpgradeable.sol";

import "../libraries/SafeCall.sol";

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

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _initialOwner,
        bool _isDisputeGameFactory,
        address _blsApkRegistry,
        address _l2OutputOracle,
        address _disputeGameFactory,
        address _operatorWhitelistManager
    ) external initializer {
        _transferOwnership(_initialOwner);
        blsApkRegistry = IBLSApkRegistry(_blsApkRegistry);
        l2OutputOracle = _l2OutputOracle;
        disputeGameFactory = _disputeGameFactory;
        isDisputeGameFactory = _isDisputeGameFactory;
        operatorWhitelistManager = _operatorWhitelistManager;
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
        IBLSApkRegistry.FinalityNonSingerAndSignature memory finalityNonSingerAndSignature,
        uint256 minGas
    ) external {
        (
            IBLSApkRegistry.StakeTotals memory stakeTotals,
            bytes32 signatoryRecordHash
        ) = blsApkRegistry.checkSignatures(finalityBatch.msgHash, finalityBatch.l2BlockNumber, finalityNonSingerAndSignature);

        // call l2output oracle contacts
        if (!isDisputeGameFactory) {
            bool success = SafeCall.callWithMinGas(
                l2OutputOracle,
                minGas,
                0,
                abi.encodeWithSignature("proposeL2Output(bytes32,uint256,bytes32,uint256)", finalityBatch.stateRoot, finalityBatch.l2BlockNumber, finalityBatch.l1BlockHash, finalityBatch.l1BlockNumber)
            );
            require(success, "StrategyBase.VerifyFinalitySignature: proposeL2Output stateroot failed");
        } else {
            bool success = SafeCall.callWithMinGas(
                disputeGameFactory,
                minGas,
                0,
                abi.encodeWithSignature("create(uint32,bytes32,bytes)", finalityBatch.disputeGameType, finalityBatch.stateRoot, '0x')
            );
            require(success, "StrategyBase.VerifyFinalitySignature: create game failed");
        }
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
