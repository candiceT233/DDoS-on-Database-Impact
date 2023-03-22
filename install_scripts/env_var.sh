#!/bin/bash

# User Directories
INSTALL_DIR=$HOME/install
DL_DIR=$HOME/download
SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact

mkdir -p $INSTALL_DIR
mkdir -p $DL_DIR
mkdir -p $SCRIPT_DIR
# git clone https://github.com/candiceT233/DDoS-on-Database-Impact $SCRIPT_DIR

# database content -----------
MONGODB_PATH=$INSTALL_DIR/mongodb
REDIS_PATH=$INSTALL_DIR/redis
BEEGFS_PATH=$INSTALL_DIR/beegfs

sudo mkdir -p $MONGODB_PATH
sudo mkdir -p $REDIS_PATH
sudo mkdir -p $BEEGFS_PATH

# database directories -----------

MONGODB_DATA=/data/mongodb
REDIS_DATA=/data/redis
BEEGFS_DATA=/data/beegfs

MONGODB_CLUSTER=/mnt/mongodb
REDIS_CLUSTER=/mnt/redis
BEEGFS_CLUSTER=/mnt/beegfs

MONGODB_LOGS=/usr/local/mongodb/logs
REDIS_LOGS=/usr/local/redis/logs
BEEGFS_LOGS=/usr/local/beegfs/logs

sudo mkdir -p $MONGODB_DATA
sudo mkdir -p $REDIS_DATA
sudo mkdir -p $BEEGFS_DATA

sudo mkdir -p $MONGODB_CLUSTER
sudo mkdir -p $REDIS_CLUSTER
sudo mkdir -p $BEEGFS_CLUSTER

sudo mkdir -p $MONGODB_LOGS
sudo mkdir -p $REDIS_LOGS
sudo mkdir -p $BEEGFS_LOGS

sudo chown $USER:$USER $MONGODB_DATA
sudo chown $USER:$USER $REDIS_DATA
sudo chown $USER:$USER $BEEGFS_DATA

sudo chown $USER:$USER $MONGODB_CLUSTER
sudo chown $USER:$USER $REDIS_CLUSTER
sudo chown $USER:$USER $BEEGFS_CLUSTER

sudo chown $USER:$USER $MONGODB_LOGS
sudo chown $USER:$USER $REDIS_LOGS
sudo chown $USER:$USER $BEEGFS_LOGS

