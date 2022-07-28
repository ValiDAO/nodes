#!/bin/bash

THEIR_COMMIT=`curl -sSL https://raw.githubusercontent.com/near/stakewars-iii/main/commit.md`
OUR_COMMIT=`cd ~/nearcore && git log -1 --format='%H'`
echo $THEIR_COMMIT $OUR_COMMIT

if [ "$THEIR_COMMIT" != "$OUR_COMMIT" ]
then
	cd "{{ ansible_facts['env']['HOME'] }}/nearcore" && \
        git fetch && \
	git checkout "$THEIR_COMMIT" && \
	source "{{ ansible_facts['env']['HOME'] }}/.cargo/env" && \
	cargo build -p neard --release --features shardnet && \
	sudo systemctl restart near
fi
