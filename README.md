<!--
parent:
  order: false
-->

<div align="center">
  <h1> l2fp-contracts</h1>
</div>

<div align="center">
  <a href="https://github.com/dapplink-labs/l2-fp-contracts/releases/latest">
    <img alt="Version" src="https://img.shields.io/github/tag/dapplink-labs/l2-fp-contracts.svg" />
  </a>
  <a href="https://github.com/dapplink-labs/l2-fp-contracts/blob/main/LICENSE">
    <img alt="License: Apache-2.0" src="https://img.shields.io/github/license/dapplink-labs/l2-fp-contracts.svg" />
  </a>
  <a href="https://pkg.go.dev/github.com/dapplink-labs/l2-fp-contracts">
    <img alt="GoDoc" src="https://godoc.org/github.com/dapplink-labs/l2-fp-contracts?status.svg" />
  </a>
</div>

## 1.Finality Provider Contracts for layer2

l2fp-contracts is a collection of contracts for managing nodes and verifying BLS signatures in an L2 fast finality network. It receives aggregated signature verifications from Finality Providers in the Babylon and Symbiotic networks to ensure the finality of the network.

## 2.Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Deploy

```shell
$ forge script script/deployFinalityRelayer.s.sol:deployFinalityRelayerScript --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

