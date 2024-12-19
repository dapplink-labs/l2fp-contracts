// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {Test, console} from "forge-std/Test.sol";
import {BLSApkRegistry} from "../src/bls/BLSApkRegistry.sol";
import {BLSSignatureChecker} from "../src/bls/BLSSignatureChecker.sol";
import {BN254} from "../src/libraries/BN254.sol";
import {IBLSApkRegistry} from "../src/interfaces/IBLSApkRegistry.sol";
import {IBLSSignatureChecker} from "../src/interfaces/IBLSSignatureChecker.sol";

// forge test -vvvv
contract BLSApkRegistryTest is Test {
    BLSApkRegistry public registry;
    BLSSignatureChecker public checker;
    address public relayerManager;

    address public operator1;
    address public operator2;

    uint256 public privKey1;
    uint256 public privKey2;

    IBLSApkRegistry.PubkeyRegistrationParams pubkeyParams1;
    IBLSApkRegistry.PubkeyRegistrationParams pubkeyParams2;

    function setUp() public {
        console.log("=== Setting up test environment ===");

        relayerManager = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

        operator1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        operator2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

        privKey1 = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
        privKey2 = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

        console.log("Relayer Manager:", relayerManager);
        console.log("Operator 1:", operator1);
        console.log("Operator 2:", operator2);

        vm.startPrank(relayerManager);
        registry = new BLSApkRegistry(relayerManager);
        checker = new BLSSignatureChecker(address(registry));
        vm.stopPrank();

        console.log("Registry deployed at:", address(registry));
        console.log("Checker deployed at:", address(checker));

        pubkeyParams1 = IBLSApkRegistry.PubkeyRegistrationParams({
            pubkeyG1: BN254.G1Point({
                X: 0x90aa0bbe0a82ac9a119d45e0337b8957749559961b2900046876d5c0df3466b,
                Y: 0x2c436aa1f1a8fd8e5964ecf277d3d5645483c11035b3af27f67f103492305122
            }),
            pubkeyG2: BN254.G2Point({
                X: [
                    0x8bc1f908b3df2021040970e8b4f0f1443433dc1d5b35fd6cc28e2497a340cd8,
                    0x24990c69557d7758bcc0ff5c9dfa54a5a968bad95475427367f30cdb407c1fe7
                ],
                Y: [
                    0x27c981ff755ff207b15e5cde297c1c0746e7842d775f1dc5c170b51d7dfbcbe6,
                    0x2bb3d6a222ea00e36725ec7f68b7aab8baf38a98932f398624803eb01a24c3b7
                ]
            }),
            pubkeyRegistrationSignature: BN254.G1Point({
                X: 0x41cdccfcb3af5074ee171d43e36561b6025e9781f6074690cac93cc323a4351,
                Y: 0x139dd6c50a2238d20b21576d62baaf6e86c0f5e863c0c828ea47f0b781eb5820
            })
        });

        pubkeyParams2 = IBLSApkRegistry.PubkeyRegistrationParams({
            pubkeyG1: BN254.G1Point({
                X: 0x1672f853e0e6dd287eb73def27cc34e8b5534a930d8d8f83e2d3346d95fca40a,
                Y: 0x1dcbf68d03ec5e402f9536036a03d2a1829a5e03a4534137d1c0092e6bdc52ef
            }),
            pubkeyG2: BN254.G2Point({
                X: [
                    0x23093418f06aba0833a30d82df9e53cc26675bbc00f45fa0c167676925f847e0,
                    0x15a691d1e7cc2f66e68c1472f481bc6aa341a8e6bf7109f3b7c5c3e49c7c5b6b
                ],
                Y: [
                    0x21562d5cd84501476957b0651b46fdf34c9497bb15527a02fcb17fd29c618b37,
                    0x20b45f5f7403d75824fc1f3081a2f70ae111189e0372334a62801316b3af6b6e
                ]
            }),
            pubkeyRegistrationSignature: BN254.G1Point({
                X: 0x7514c888428aad26f4b712e152ec33016f28d2e9d38cdc9bbe6cb1867227a3c,
                Y: 0x1c15f2d4b9e5c5fff4dd4f15c5bd5cf3b13db289ce9a22b18a28d77fc077748e
            })
        });

        console.log("=== Setup complete ===\n");
    }

    function test_AggregateSignature_Success() public {
        console.log("\n=== Testing successful aggregate signature verification ===");

        // Register operators
        vm.startPrank(relayerManager);

        address[] memory operatorsBefore = registry.getOperators();
        console.log("\nOperators before registration:");
        for(uint i = 0; i < operatorsBefore.length; i++) {
            console.log("Operator", i, ":", operatorsBefore[i]);
        }

        // Register first operator
        BN254.G1Point memory msgHash1 = registry.pubkeyRegistrationMessageHash(operator1);
        BN254.G1Point memory signature1 = BN254.scalar_mul(msgHash1, privKey1);
        pubkeyParams1.pubkeyRegistrationSignature = signature1;
        registry.registerOperator(operator1, pubkeyParams1, msgHash1);

        BN254.G2Point memory g2Pubkey1 = registry.getOperatorG2Pubkey(operator1);
        console.log("\nG2 pubkey for operator1:");
        console.log(" - X[0]:", uint256(g2Pubkey1.X[0]));
        console.log(" - X[1]:", uint256(g2Pubkey1.X[1]));
        console.log(" - Y[0]:", uint256(g2Pubkey1.Y[0]));
        console.log(" - Y[1]:", uint256(g2Pubkey1.Y[1]));

        // Register second operator
        BN254.G1Point memory msgHash2 = registry.pubkeyRegistrationMessageHash(operator2);
        BN254.G1Point memory signature2 = BN254.scalar_mul(msgHash2, privKey2);
        pubkeyParams2.pubkeyRegistrationSignature = signature2;
        registry.registerOperator(operator2, pubkeyParams2, msgHash2);

        BN254.G2Point memory g2Pubkey2 = registry.getOperatorG2Pubkey(operator2);
        console.log("\nG2 pubkey for operator2:");
        console.log(" - X[0]:", uint256(g2Pubkey2.X[0]));
        console.log(" - X[1]:", uint256(g2Pubkey2.X[1]));
        console.log(" - Y[0]:", uint256(g2Pubkey2.Y[0]));
        console.log(" - Y[1]:", uint256(g2Pubkey2.Y[1]));

        address[] memory operatorsAfter = registry.getOperators();
        console.log("\nOperators after registration:");
        for(uint i = 0; i < operatorsAfter.length; i++) {
            console.log("Operator", i, ":", operatorsAfter[i]);
        }

        // Create and sign message
        bytes32 messageToSign = keccak256(abi.encodePacked("Hello, this is a test message"));
        console.log("\nMessage to sign:", uint256(messageToSign));

        // Hash message to curve point
        BN254.G1Point memory messagePoint = BN254.hashToG1(messageToSign);

        // Sign message with both keys
        BN254.G1Point memory sig1 = BN254.scalar_mul(messagePoint, privKey1);
        BN254.G1Point memory sig2 = BN254.scalar_mul(messagePoint, privKey2);

        // Aggregate signatures using BN254 library
        BN254.G1Point memory aggregatedSignature = BN254.plus(sig1, sig2);

        // Convert signature to bytes for the checker contract
        bytes memory sigBytes = new bytes(64);
        assembly {
            mstore(add(sigBytes, 32), mload(aggregatedSignature))
            mstore(add(sigBytes, 64), mload(add(aggregatedSignature, 32)))
        }

        // Create signature params
        IBLSSignatureChecker.SignatureParams memory params = IBLSSignatureChecker.SignatureParams({
            msgHash: messageToSign,
            signature: sigBytes,
            blockNumber: uint32(block.number - 1)
        });

        // Debug output
        console.log("\nAggregated signature:");
        console.log(" - X:", uint256(aggregatedSignature.X));
        console.log(" - Y:", uint256(aggregatedSignature.Y));

        BN254.G2Point memory aggPubkey = registry.getAggregatedPubkey();
        console.log("\nAggregated public key:");
        console.log(" - X[0]:", uint256(aggPubkey.X[0]));
        console.log(" - X[1]:", uint256(aggPubkey.X[1]));
        console.log(" - Y[0]:", uint256(aggPubkey.Y[0]));
        console.log(" - Y[1]:", uint256(aggPubkey.Y[1]));

        // Verify signature using the checker contract
        bool isValid = checker.verifySignature(params);
        console.log("\nSignature verification result:", isValid);
        assertTrue(isValid, "Signature verification failed");

        vm.stopPrank();
        console.log("=== Aggregate signature test passed ===\n");
    }
}
