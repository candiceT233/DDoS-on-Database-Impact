#!/bin/bash

# User Directories
INSTALL_DIR=$HOME/install
DL_DIR=$HOME/download
SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact


BEEGFS_PATH=/opt/beegfs
BEEGFS_SBIN=$BEEGFS_PATH/sbin
BEEGFS_DATA=/data/beegfs
BEEGFS_CLUSTER=/mnt/beegfs
BEEEGFS_SCRIPT_DIR=$SCRIPT_DIR/beegfs
BEEGFS_CONF_DIR=$BEEEGFS_SCRIPT_DIR/configs
# BEEGFS_CONF_TMP_DIR=$BEEEGFS_SCRIPT_DIR/configs_tmp
BEEGFS_LOGS=/usr/local/beegfs_logs

SERVER_HOST_FILE_DIR=$SCRIPT_DIR/ip_files

sudo mkdir -p $BEEGFS_DATA
sudo mkdir -p $BEEGFS_CLUSTER
sudo mkdir -p $BEEGFS_LOGS

# sudo chown $USER:$USER $BEEGFS_DATA
sudo chown $USER:$USER $BEEGFS_CLUSTER
sudo chown $USER:$USER $BEEGFS_LOGS

echo "If permission denied, run: sudo chown $USER:$USER $BEEGFS_DATA"