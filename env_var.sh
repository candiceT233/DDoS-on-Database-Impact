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
BEEGFS_PATH=/opt/beegfs

mkdir -p $MONGODB_PATH
mkdir -p $REDIS_PATH
mkdir -p $BEEGFS_PATH

# database directories -----------

MONGODB_DATA=/data/mongodb
BEEGFS_DATA=/data/beegfs

MONGODB_CLUSTER=/mnt/mongodb
BEEGFS_CLUSTER=/mnt/beegfs

MONGODB_LOGS=$MONGODB_CLUSTER/logs
BEEGFS_LOGS=$BEEGFS_CLUSTER/logs

sudo mkdir -p $MONGODB_DATA
sudo mkdir -p $BEEGFS_DATA

sudo mkdir -p $MONGODB_CLUSTER
sudo mkdir -p $BEEGFS_CLUSTER

# sudo mkdir -p $MONGODB_LOGS
sudo mkdir -p $REDIS_LOGS
sudo mkdir -p $BEEGFS_LOGS

sudo chown $USER:$USER $MONGODB_DATA
sudo chown $USER:$USER $BEEGFS_DATA

sudo chown $USER:$USER $MONGODB_CLUSTER
sudo chown $USER:$USER $BEEGFS_CLUSTER

# sudo chown $USER:$USER $MONGODB_LOGS
sudo chown $USER:$USER $BEEGFS_LOGS

