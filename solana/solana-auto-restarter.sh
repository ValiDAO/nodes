#!/bin/bash

SOLANA=~/.local/share/solana/install/active_release/bin/solana

THEIR_SLOT=$($SOLANA slot)
OUR_SLOT=$($SOLANA slot -ul)

echo "Their slot $THEIR_SLOT , our slot $OUR_SLOT"

if [ $((OUR_SLOT + 5000)) -lt $THEIR_SLOT ]
then
	echo "Restart needed"
	sudo systemctl stop solana
	rm -rf ~/solana.log
	rm -rf ~/validator-ledger/*snap*tar*
	sudo systemctl start solana
else
	echo "All good"
fi
