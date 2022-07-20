#!/bin/bash

set -x
set -e

echo "Wiping out old data..."
rm -rf "{{ ansible_facts['env']['HOME'] }}/.near/data"

echo "Downloading snapshot..."
cd "{{ ansible_facts['env']['HOME'] }}/.near"
aws s3 --no-sign-request cp s3://build.openshards.io/stakewars/shardnet/data.tar.gz .  
tar -xzvf data.tar.gz
