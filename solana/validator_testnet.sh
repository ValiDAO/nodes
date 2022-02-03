#!/bin/sh

export RUST_LOG=warn,solana_metrics=error

solana-validator                                                       \
  --identity HOME/validator-keypair.json                              \
  --vote-account HOME/vote-account-keypair.json                       \
  --ledger HOME/validator-ledger                                      \
  --rpc-bind-address 127.0.0.1                                        \
  --rpc-port 8899                                                     \
  --no-port-check                                                     \
  --trusted-validator 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on \
  --trusted-validator 7XSY3MrYnK8vq693Rju17bbPkCN3Z7KvvfvJx4kdrsSY \
  --trusted-validator Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN \
  --trusted-validator 9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv \
  --no-untrusted-rpc \
  --entrypoint entrypoint.testnet.solana.com:8001 \
  --entrypoint entrypoint2.testnet.solana.com:8001 \
  --entrypoint entrypoint3.testnet.solana.com:8001 \
  --expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
  --wal-recovery-mode skip_any_corrupted_record                        \
  --dynamic-port-range 8000-8011                                       \
  --limit-ledger-size 50000000 \
  --snapshot-compression none                                          \
  --snapshot-interval-slots 500 \
  --maximum-local-snapshot-age 500 \
  --log HOME/solana.log
