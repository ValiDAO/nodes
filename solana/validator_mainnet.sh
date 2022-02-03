#!/bin/sh

export RUST_LOG=warn,solana_metrics=error
export SOLANA_METRICS_CONFIG="host=https://metrics.solana.com:8086,db=mainnet-beta,u=mainnet-beta_write,p=password"

solana-validator \
  --identity HOME/validator-keypair.json \
  --vote-account HOME/vote-account-keypair.json \
  --ledger HOME/validator-ledger \
  --accounts /mnt/solana-accounts \
  --snapshot-interval-slots 0 \
  --maximum-local-snapshot-age 1000 \
  --snapshot-compression none \
  --private-rpc \
  --rpc-port 8899 \
  --rpc-bind-address 127.0.0.1 \
  --gossip-port 8001 \
  --entrypoint entrypoint.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint2.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint3.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint4.mainnet-beta.solana.com:8001 \
  --entrypoint entrypoint5.mainnet-beta.solana.com:8001 \
  --trusted-validator 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
  --trusted-validator GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
  --trusted-validator DE1bawNcRJB9rVm3buyMVfr8mBEoyyu73NBovf2oXJsJ \
  --trusted-validator CakcnaRDHka2gXyfbEd2d3xsvkJkqsLw2akB3zsN1D2S \
  --expected-genesis-hash 5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d \
  --wal-recovery-mode skip_any_corrupted_record \
  --dynamic-port-range 8000-8010 \
  --limit-ledger-size \
  --log HOME/solana.log
