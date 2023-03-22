#!/bin/bash
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# User Directories
INSTALL_DIR=$HOME/install
DL_DIR=$HOME/download
SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact

mkdir -p $INSTALL_DIR
mkdir -p $DL_DIR
mkdir -p $SCRIPT_DIR


username=$USER
MONGODB_CLUSTER=/mnt/mongodb
MONGO_CONF_SRV_DIR=${MONGODB_CLUSTER}/mongod
MONGO_SHARD_SRV_DIR=${MONGODB_CLUSTER}/mongod_shard
MONGO_ROUTER_SRV_DIR=${MONGODB_CLUSTER}/mongos

mkdir -p $MONGODB_CLUSTER
echo "if permission denied, run: sudo chown $USER:$USER $MONGODB_CLUSTER $MONGODB_CLUSTER/*"
mkdir -p $MONGO_CONF_SRV_DIR $MONGO_SHARD_SRV_DIR $MONGO_ROUTER_SRV_DIR

MONGODB_LOGS=/usr/local/mongodb/logs
REDIS_LOGS=/usr/local/redis/logs
BEEGFS_LOGS=/usr/local/beegfs/logs


MONGODB_PATH=$INSTALL_DIR/mongodb
MONGO_BIN=$MONGODB_PATH/bin # changed folder 
CONFIG_SVR_PORT=57040
SHARD_SVR_PORT=37017
ROUTER_SVR_PORT=27017
CONFIG_SVR_CONF_FILE="mongod_config.conf"
SHARD_SVR_CONF_FILE="mongod_shard.conf"
ROUTER_CONF_FILE="mongos.conf"
