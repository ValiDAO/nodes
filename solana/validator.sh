#!/bin/bash

source `dirname "${BASH_SOURCE[0]}"`/solana.env

export RUST_LOG=info,solana_metrics=error

echo "Downloading a snapshot"
sudo docker run --rm \
    -v {{ ansible_facts['env']['HOME'] }}/validator-ledger:/solana/snapshot \
    --user $(id -u):$(id -g) \
    kostya-downloader:latest \
    --snapshot_path /solana/snapshot \
    -r "$API_URL"


nice -n -20 solana-validator \
  --identity {{ ansible_facts['env']['HOME'] }}/validator-keypair.json \
  --vote-account {{ ansible_facts['env']['HOME'] }}/vote-account-keypair.json \
  --ledger {{ ansible_facts['env']['HOME'] }}/validator-ledger \
  --accounts /mnt/solana-accounts \
  --no-port-check --no-snapshot-fetch \
  --full-rpc-api --rpc-port 8899 \
  --private-rpc \
  --snapshot-packager-niceness-adjustment 5 \
  --gossip-port 8001 \
  --wal-recovery-mode skip_any_corrupted_record \
  --dynamic-port-range 8000-8020 \
  --limit-ledger-size \
  --log {{ ansible_facts['env']['HOME'] }}/$LOG \
  $ENTRYPOINTS $TRUSTED_VALIDATORS $GENESIS_HASH
