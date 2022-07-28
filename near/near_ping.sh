#!/bin/bash
echo "NEAR: Ping. https://github.com/near/stakewars-iii/blob/main/challenges/003.md"
export NEAR_ENV=shardnet

set -e

ACCOUNTS_CNT=`find "{{ ansible_env.HOME }}/.near-credentials/shardnet/" -type f | wc -l`

if [ "$ACCOUNTS_CNT" != 1 ]
then
	echo "Wrong number of accounts"
	exit 1
fi

if [ ! -f "{{ ansible_env.HOME }}/.near/validator_key.json" ]
then
	echo "No ~/.near/validator_key.json file"
	exit 1
fi

ACCOUNT_ID=`cat {{ ansible_env.HOME }}/.near-credentials/shardnet/*.shardnet.near.json | jq -r '.account_id'`
POOL_ID=`cat {{ ansible_env.HOME }}/.near/validator_key.json | jq -r '.account_id'`
PUBLIC_KEY=`cat {{ ansible_env.HOME }}/.near/validator_key.json | jq -r '.public_key'`

echo ACCOUNT_ID=$ACCOUNT_ID
echo POOL_ID=$POOL_ID
echo PUBLIC_KEY=$PUBLIC_KEY

ans=""
if [ "$1" != "-f" ]
then
  read -p 'Looks good? [Y/n] ' -e -i Y ans
else
  ans="Y"
fi

if [ "$ans" != "Y" -a "$ans" != "y" ]
then
	echo "Call you node-admin!"
	exit 1
fi

export PATH="/root/nodejs-18.6/node-v18.6.0-linux-x64/bin/:$PATH"
near call "$POOL_ID" ping '{}' --accountId "$ACCOUNT_ID" --gas=300000000000000
