#!/bin/bash

set -e
set -x
set -o pipefail

VERSION_FILE="$HOME/aptos-core/version"

PREV_VERSION="0"
if [ -f $VERSION_FILE ]
then
   PREV_VERSION=$(cat $VERSION_FILE)
fi

LATEST_VERSION=$(curl 'https://aptos-devnet-stats.s3.us-west-2.amazonaws.com/current_version.json' --compressed -s | jq '.[0].value[1]' | sed -e 's/"//g')
if [ "$LATEST_VERSION" == "null" ]
then
        echo "Error when getting a version"
        exit 0
fi

if [ "$PREV_VERSION" -gt "$LATEST_VERSION" ]
then
        echo "Restarting"
        cd ~/aptos-core && git fetch origin devnet && git reset --hard origin/devnet
        source ~/.cargo/env
        cargo build -p aptos-node --release
        systemctl stop aptos
        rm -rf ~/aptos-data
        wget 'https://devnet.aptoslabs.com/genesis.blob' -O ~/aptos-core/genesis.blob
        wget 'https://devnet.aptoslabs.com/waypoint.txt' -O ~/aptos-core/waypoint.txt
        DATA=$(cat ~/aptos-core/waypoint.txt)
        sed -i -e "s/from_config: \"0:.*/from_config: \"$DATA\"/" ~/aptos-core/public_full_node.yaml
        systemctl start aptos
else
        echo "Doing nothing"
fi

echo $LATEST_VERSION > $VERSION_FILE
