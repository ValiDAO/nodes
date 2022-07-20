#!/bin/sh
export NEAR_ENV=shardnet

set -e

sudo systemctl stop near
rm -rf ~/.near/data
NEAR_TMP_DIR=`mktemp --directory`
cd ~/nearcore && ./target/release/neard --home "$NEAR_TMP_DIR" init --chain-id shardnet --download-genesis
mv "$NEAR_TMP_DIR/genesis.json" ~/.near
sudo systemctl start near
