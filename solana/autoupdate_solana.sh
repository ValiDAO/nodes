#!/bin/bash

TMP_VALIDATORS_FILE="/tmp/validators"
UPDATE_SENSIVITY=100

sleep $(( $RANDOM % 120 + 1 ))

export PATH="{{ ansible_facts['env']['HOME'] }}/.local/share/solana/install/active_release/bin/:$PATH"

solana validators -ul --output=json > "$TMP_VALIDATORS_FILE"

readarray -t versions < <(cat $TMP_VALIDATORS_FILE | jq '.stakeByVersion | to_entries[] | [.key] | @tsv' | grep -v unknow | sed -e 's/"//g' | sort -t. -k 1,1nr -k 2,2nr -k 3,3nr)

for version in "${versions[@]}";do                                                      
  CURRENT_VALUDATORS=$(cat $TMP_VALIDATORS_FILE | jq ".stakeByVersion.\"$version\".currentValidators")
  if [ "${CURRENT_VALUDATORS}" -gt "${UPDATE_SENSIVITY}" ]
  then
    echo "For version ${version} there are ${CURRENT_VALUDATORS}"
    CURRENT_SOLANA_VERSION=$(solana --version | cut -d' ' -f2)
    if [ "$CURRENT_SOLANA_VERSION" == "${version}" ]
    then
      echo "We are already on version ${version}, doing nothing..."
    else
      echo "INSTALLING ${version}!"
      sleep $(( 60 * ($RANDOM % 1400 + 1) ))
      wget "https://release.solana.com/v${version}/install" -O ~/install
      chmod +x ~/install
      ./install
      solana-validator --ledger {{ ansible_facts['env']['HOME'] }}/validator-ledger exit --max-delinquent-stake 8
      sudo systemctl restart solana
    fi
    break
  else
    echo "For version ${version} there are only ${CURRENT_VALUDATORS}"
  fi
done 
