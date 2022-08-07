#!/bin/bash

source `dirname "${BASH_SOURCE[0]}"`/solana.env

SHOULD_START_CLEAN=1
SLOT_DELAY_ALLOWANCE=2000

SNAPSHOTS_CNT=$(find "{{ ansible_facts['env']['HOME'] }}/validator-ledger" -maxdepth 1 -name 'snapshot*tar.zst' | wc -l)
if [ "$SNAPSHOTS_CNT" = 0 ]
then
	echo "SNAPSHOTS_CNT=$SNAPSHOTS_CNT is 0, doing reset"
else
	echo "SNAPSHOTS_CNT=$SNAPSHOTS_CNT is not 0, doing next check..."

	BEST_KNOWN_INCREMENTAL_SLOT=$(cd {{ ansible_facts['env']['HOME'] }}/validator-ledger/ && find . -maxdepth 1 -name 'incremental-snapshot*tar.zst' | sort | tail -n1 | cut -d'-' -f4)
	if [ -z "$BEST_KNOWN_INCREMENTAL_SLOT" ]
	then
		echo "BEST_KNOWN_INCREMENTAL_SLOT=$BEST_KNOWN_INCREMENTAL_SLOT is empty, doing reset"
	else
		echo "BEST_KNOWN_INCREMENTAL_SLOT=$BEST_KNOWN_INCREMENTAL_SLOT is not empty, doing next check..."
		SLOT=$(solana slot)
		echo "Current slot is $SLOT"
		SLOT_DELAY=$((SLOT-BEST_KNOWN_INCREMENTAL_SLOT))
		echo "Slot delay is $SLOT_DELAY"

		if [ "$SLOT_DELAY" -gt "$SLOT_DELAY_ALLOWANCE" ]
		then
			echo "Slot delay $SLOT_DELAY is higher than $SLOT_DELAY_ALLOWANCE, doing reset"
		else
			echo "Slot delay $SLOT_DELAY is lower than $SLOT_DELAY_ALLOWANCE, just starting..."
			SHOULD_START_CLEAN=0
		fi
	fi
fi


if [ "$SHOULD_START_CLEAN" = 1 ]
then
	echo "Cleaning..."
	rm -rf "{{ ansible_facts['env']['HOME'] }}/validator-ledger"
	mkdir -p "{{ ansible_facts['env']['HOME'] }}/validator-ledger"

	echo "Downloading a snapshot"
	sudo docker run --rm \
	    -v {{ ansible_facts['env']['HOME'] }}/validator-ledger:/solana/snapshot \
	    --user $(id -u):$(id -g) \
	    kostya-downloader:latest \
	    --snapshot_path /solana/snapshot \
	    -r "$API_URL"
fi



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
