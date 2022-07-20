#!/bin/bash

set -x
set -e

#Uncomment me later
if [ -d "{{ ansible_facts['env']['HOME'] }}/.near/data" ]
then
    ./near_download_snapshot.sh
fi

cd "{{ ansible_facts['env']['HOME'] }}/nearcore"
./target/release/neard --home ~/.near run
