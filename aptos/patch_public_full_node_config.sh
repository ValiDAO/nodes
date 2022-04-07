#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
KEY=$(cat "$SCRIPT_DIR/private-key")
PEER_ID=$(cat "$SCRIPT_DIR/peer-info.yaml" | head -n2 | tail -n 1 | cut -d: -f1)

echo -e "/discovery_method/\na\n      identity:\n        type: \"from_config\"\n        key: \"$KEY\"\n        peer_id: \"$PEER_ID\"\n.\nwq" | ed "$SCRIPT_DIR/public_full_node.yaml"

sed -i -e 's/127.0.0.1/0.0.0.0/g' "$SCRIPT_DIR/public_full_node.yaml"
