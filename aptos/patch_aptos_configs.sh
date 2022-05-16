#!/bin/bash

WORKSPACE="aptos-testnet-keys"
cp ~/aptos-core/docker/compose/aptos-node/fullnode.yaml ~/$WORKSPACE
cp ~/aptos-core/docker/compose/aptos-node/validator.yaml ~/$WORKSPACE

QUOTED_WORKSPACE=$(echo $HOME/$WORKSPACE | sed -e 's/\//\\\//g')
sed -i -e "s/\/opt\/aptos\/genesis/$QUOTED_WORKSPACE/g" ~/$WORKSPACE/validator.yaml
sed -i -e "s/\/opt\/aptos\/genesis/$QUOTED_WORKSPACE/g" ~/$WORKSPACE/fullnode.yaml

QUOTED_DATADIR=$(echo $HOME/aptos-data-validator | sed -e 's/\//\\\//g')
sed -i -e "s/\/opt\/aptos\/data/$QUOTED_DATADIR/g" ~/$WORKSPACE/validator.yaml
QUOTED_DATADIR=$(echo $HOME/aptos-data-fullnode | sed -e 's/\//\\\//g')
sed -i -e "s/\/opt\/aptos\/data/$QUOTED_DATADIR/g" ~/$WORKSPACE/fullnode.yaml

sed -i -e "s/0.0.0.0\/tcp\/6181/0.0.0.0\/tcp\/16181/g" ~/$WORKSPACE/fullnode.yaml
sed -i -e "s/172.16.1.10/127.0.0.1/g" ~/$WORKSPACE/fullnode.yaml
sed -i -e "s/8080/18080/g" ~/$WORKSPACE/fullnode.yaml

echo "debug_interface:" >> ~/$WORKSPACE/validator.yaml
echo "  admission_control_node_debug_port: 16192" >> ~/$WORKSPACE/validator.yaml
echo "  public_metrics_server_port: 19103" >> ~/$WORKSPACE/validator.yaml
echo "  metrics_server_port: 19104" >> ~/$WORKSPACE/validator.yaml

echo "storage:" >> ~/$WORKSPACE/validator.yaml
echo "  address: 127.0.0.1:16666" >> ~/$WORKSPACE/validator.yaml
echo "  backup_service_address: 127.0.0.1:16186" >> ~/$WORKSPACE/validator.yaml
