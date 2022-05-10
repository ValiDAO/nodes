#!/bin/bash

set -e
set -x
set -o pipefail

VERSION_FILE="$HOME/ironfish/version"

PREV_VERSION="0"
if [ -f $VERSION_FILE ]
then
   PREV_VERSION=$(cat $VERSION_FILE)
fi

LATEST_VERSION=$(cd $HOME/ironfish && git fetch && git tag --list | grep -E '^v' | sort -t. -k 1,1nr -k 2,2nr -k 3,3nr | head -n1)

if [ "$PREV_VERSION" != "$LATEST_VERSION" ]
then
	cd $HOME/ironfish && git checkout "$LATEST_VERSION"
	source $HOME/.cargo/env && cd $HOME/ironfish && /usr/bin/yarn install
	echo "$LATEST_VERSION" > "$VERSION_FILE"
	if [ -f /etc/systemd/system/ironfish-node.service ]
	then
		sudo systemctl stop ironfish-miner
		sudo systemctl restart ironfish-node
		sudo systemctl start ironfish-miner
	fi
else
	echo "Doing nothing"
fi
