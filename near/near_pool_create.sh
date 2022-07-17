#!/bin/bash
echo "NEAR: Pool creator. https://github.com/near/stakewars-iii/blob/main/challenges/003.md"
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
POOL_ID=`cat {{ ansible_env.HOME }}/.near/validator_key.json | jq -r '.account_id' | sed -e 's/.factory.shardnet.near//'`
PUBLIC_KEY=`cat {{ ansible_env.HOME }}/.near/validator_key.json | jq -r '.public_key'`

echo ACCOUNT_ID=$ACCOUNT_ID
echo POOL_ID=$POOL_ID
echo PUBLIC_KEY=$PUBLIC_KEY

read -p 'Looks good? [Y/n] ' -e -i Y ans
if [ "$ans" != "Y" -a "$ans" != "y" ]
then
	echo "Call you node-admin!"
	exit 1
fi

near call factory.shardnet.near create_staking_pool "{\"staking_pool_id\": \"${POOL_ID}\", \"owner_id\": \"${ACCOUNT_ID}\", \"stake_public_key\": \"${PUBLIC_KEY}\", \"reward_fee_fraction\": {\"numerator\": 5, \"denominator\": 100}, \"code_hash\":\"DD428g9eqLL8fWUxv8QSpVFzyHi1Qd16P8ephYCTmMSZ\"}" "--accountId=\"${ACCOUNT_ID}\"" --amount=30 --gas=300000000000000

echo "Check your node appearing on https://explorer.shardnet.near.org/nodes/validators"
