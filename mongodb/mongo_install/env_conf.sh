#!/bin/bash
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# User Directories
INSTALL_DIR=$HOME/install
DL_DIR=$HOME/download
SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact

sudo mkdir -p $INSTALL_DIR
sudo mkdir -p $DL_DIR
sudo mkdir -p $SCRIPT_DIR


username=$USER
MONGODB_CLUSTER=/mnt/mongodb
MONGO_CONF_SRV_DIR=${MONGODB_CLUSTER}/mongod
MONGO_SHARD_SRV_DIR=${MONGODB_CLUSTER}/mongod_shard
MONGO_ROUTER_SRV_DIR=${MONGODB_CLUSTER}/mongos

mkdir -p $MONGODB_CLUSTER
echo "run: sudo chown $USER:$USER $MONGODB_CLUSTER; sudo chown $USER:$USER $MONGODB_CLUSTER/*"
mkdir -p $MONGO_CONF_SRV_DIR $MONGO_SHARD_SRV_DIR $MONGO_ROUTER_SRV_DIR

MONGODB_LOGS=/usr/local/mongodb/logs
REDIS_LOGS=/usr/local/redis/logs
BEEGFS_LOGS=/usr/local/beegfs/logs



MONGO_DIR=/home/$USER/install/mongodb/bin # changed folder 
CONFIG_SVR_PORT=57040
SHARD_SVR_PORT=37017
ROUTER_SVR_PORT=27017
CONFIG_SVR_CONF_FILE="mongod_config.conf"
SHARD_SVR_CONF_FILE="mongod_shard.conf"
ROUTER_CONF_FILE="mongos.conf"
