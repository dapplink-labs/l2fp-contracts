## Finality Provider Contracts for evm layer2

<!--
parent:
  order: false
-->

<div align="center">
  <h1> l2-fp-contracts </h1>
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

l2-fp-contracts is a finality bls signature verify and submit stateroot to layer2's contracts in Ethereum(layer1), 

## Usage

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

