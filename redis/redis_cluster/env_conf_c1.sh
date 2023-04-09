#!/bin/bash
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# User Directories
INSTALL_DIR=$HOME/install
DL_DIR=$HOME/download
SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact

mkdir -p $INSTALL_DIR
mkdir -p $DL_DIR

REDIS_CLUSTER=/mnt/redis
REDIS_PATH=$INSTALL_DIR/redis
REDIS_BIN=$INSTALL_DIR/redis/bin
CONFIG_FILE=redis.conf
HOSTNAME_POSTFIX=""
REDIS_NODES=`cat ${CWD}/servers | awk '{print $1}'`
N_REDIS_NODES=`cat ${CWD}/servers |wc -l`
REDIS_PORT_BASE=6379

mkdir -p $REDIS_CLUSTER
echo "if permission denied, run: sudo chown $USER:$USER $REDIS_CLUSTER $REDIS_CLUSTER/*"
mkdir -p $REDIS_PATH