#!/bin/bash

set -x
set -e

echo "Downloading snapshot..."
cd "{{ ansible_facts['env']['HOME'] }}/.near"
aws s3 --no-sign-request cp s3://build.openshards.io/stakewars/shardnet/data.tar.gz .  
tar -xzvf data.tar.gz

cd "{{ ansible_facts['env']['HOME'] }}/nearcore"
./target/release/neard --home ~/.near run
