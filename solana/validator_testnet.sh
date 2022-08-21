#!/bin/sh

solana-validator                                                       \
  --identity HOME/validator-keypair.json                              \
  --vote-account HOME/vote-account-keypair.json                       \
  --ledger HOME/validator-ledger                                      \
  --rpc-bind-address 127.0.0.1                                        \
  --rpc-port 8899                                                     \
  --no-port-check                                                     \
  --known-validator 5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on \
  --known-validator dDzy5SR3AXdYWVqbDEkVFdvSPCtS9ihF5kJkHCtXoFs \
  --known-validator Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN \
  --known-validator eoKpUABi59aT4rR9HGS3LcMecfut9x7zJyodWWP43YQ \
  --known-validator 9QxCLckBiJc783jnMvXZubK4wH86Eqqvashtrwvcsgkv \
  --no-untrusted-rpc \
  --entrypoint entrypoint.testnet.solana.com:8001 \
  --entrypoint entrypoint2.testnet.solana.com:8001 \
  --entrypoint entrypoint3.testnet.solana.com:8001 \
  --expected-genesis-hash 4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY \
  --wal-recovery-mode skip_any_corrupted_record                        \
  --dynamic-port-range 8000-8020                                       \
  --limit-ledger-size 50000000 \
  --snapshot-compression none                                          \
  --snapshot-interval-slots 500 \
  --maximum-local-snapshot-age 500 \
  --log HOME/solana.log
