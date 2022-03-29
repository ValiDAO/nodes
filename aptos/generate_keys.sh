#!/bin/bash

set -e
set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

BOOTSTRAP_SERVER=$(ansible --list-hosts --one-line aptos 2>/dev/null | grep -v 'hosts (' | sort | head -n1)
BOOTSTRAP_SERVER="dmitrii-aptos"

if [ $# -ne 1 ]
then
	echo "Usage: $0 KEYDIRNAME"
	exit 1
fi

KEY_FOLDER="$SCRIPT_DIR/keys/$1"
KEY_FILE="$KEY_FOLDER/private-key"

if [ -f "$KEY_FILE" ]
then
	echo "Folder $KEY_FOLDER exists"
	exit 1
else
	mkdir -p "$KEY_FOLDER"
fi

REMOTE_KEY_FILE=$(ssh $BOOTSTRAP_SERVER mktemp)

ssh $BOOTSTRAP_SERVER "source ~/.cargo/env && cd ~/aptos-core && \
cargo run -p aptos-operational-tool -- generate-key --encoding hex --key-type x25519 --key-file $REMOTE_KEY_FILE"

function clear_remote_private_key {
	echo "Cleaning remote private key"
	ssh $BOOTSTRAP_SERVER "shred --verbose \"$REMOTE_KEY_FILE\""
}
trap clear_remote_private_key EXIT

scp "$BOOTSTRAP_SERVER:$REMOTE_KEY_FILE" "$KEY_FILE"

