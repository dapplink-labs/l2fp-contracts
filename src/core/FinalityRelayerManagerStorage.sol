// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Initializable} from "@openzeppelin-upgrades/contracts/proxy/utils/Initializable.sol";

import "../interfaces/IBLSApkRegistry.sol";

abstract contract FinalityRelayerManagerStorage is Initializable {
    address public operatorWhitelistManager;

    mapping(address => bool) public operatorWhitelist;

    IBLSApkRegistry public blsApkRegistry;

    constructor(IBLSApkRegistry _blsApkRegistry) {
        blsApkRegistry = _blsApkRegistry;
        _disableInitializers();
    }

}
