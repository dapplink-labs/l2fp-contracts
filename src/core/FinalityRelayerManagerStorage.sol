// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin-upgrades/contracts/proxy/utils/Initializable.sol";

import "../interfaces/IBLSApkRegistry.sol";

abstract contract FinalityRelayerManagerStorage is Initializable {
    address public operatorWhitelistManager;

    mapping(address => bool) public operatorWhitelist;

    IBLSApkRegistry public blsApkRegistry;

    address public l2OutputOracle;

    address public disputeGameFactory;

    bool public isDisputeGameFactory;

    constructor(IBLSApkRegistry _blsApkRegistry, address _l2OutputOracle, address _disputeGameFactory) {
        blsApkRegistry = _blsApkRegistry;
        l2OutputOracle = _l2OutputOracle;
        disputeGameFactory = _disputeGameFactory;
        _disableInitializers();
    }

}
