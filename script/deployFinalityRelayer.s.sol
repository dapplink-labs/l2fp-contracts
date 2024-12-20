// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import { Script, console } from "forge-std/Script.sol";
import { BLSApkRegistry } from "../src/bls/BLSApkRegistry.sol";
import { FinalityRelayerManager } from "../src/core/FinalityRelayerManager.sol";


contract deployFinalityRelayerScript is Script {
    ProxyAdmin public dappLinkProxyAdmin;
    BLSApkRegistry public blsApkRegistry;
    FinalityRelayerManager public finalityRelayerManager;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address fpAdmin =  vm.envAddress("FP_ADMIN");
        address relayerManagerAddr =  vm.envAddress("RELAYER_MANAGER");
        address l2OutputOracleAddr =  vm.envAddress("L2OUTPUT_ORACLE");
        address disputeGameFactoryAddr = vm.envAddress("DISPUTE_GAME_FACTORY");

        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);


        blsApkRegistry = new BLSApkRegistry();
        finalityRelayerManager = new FinalityRelayerManager();

        TransparentUpgradeableProxy proxyBlsApkRegistry = new TransparentUpgradeableProxy(
            address(blsApkRegistry),
            address(fpAdmin),
            abi.encodeWithSelector(BLSApkRegistry.initialize.selector, deployerAddress, finalityRelayerManager, relayerManagerAddr)
        );

        TransparentUpgradeableProxy proxyFinalityRelayerManager = new TransparentUpgradeableProxy(
            address(finalityRelayerManager),
            address(fpAdmin),
            abi.encodeWithSelector(FinalityRelayerManager.initialize.selector, deployerAddress, false, blsApkRegistry, l2OutputOracleAddr, disputeGameFactoryAddr)
        );

        console.log("deploy proxyBlsApkRegistry:", address(proxyBlsApkRegistry));
        console.log("deploy proxyFinalityRelayerManager:", address(proxyFinalityRelayerManager));
        vm.stopBroadcast();
    }
}
