#!/bin/sh

AVAIL=$(df --output=avail / | tail -n 1)

if [ "$AVAIL" -lt 10000000 ]
then
	systemctl stop solana
	rm -rf HOME/validator-ledger
	rm -rf HOME/solana.log
	systemctl start solana
else
	echo "Available $AVAIL bytes, not cleaning..."
fi
