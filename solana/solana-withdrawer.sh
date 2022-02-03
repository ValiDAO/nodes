#!/bin/bash

SOLANA=~/.local/share/solana/install/active_release/bin/solana

VOTE_KEYPAIR=~/vote-account-keypair.json
VALIDATOR_KEYPAIR=~/validator-keypair.json

BAL=$($SOLANA balance)
echo "Current balance is $BAL"


if [ ${BAL:0:2} == "0." -o ${BAL:0:2} == "1." -o "$1" == "--force" ]
then
    echo "Withdrawing"
    $SOLANA withdraw-from-vote-account --authorized-withdrawer $VALIDATOR_KEYPAIR $VOTE_KEYPAIR $VALIDATOR_KEYPAIR ALL
    BAL=$($SOLANA balance)
    echo "New balance is $BAL"
fi
