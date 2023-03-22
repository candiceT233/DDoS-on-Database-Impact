#!/usr/bin/bash

set -x 
source env_var.sh

sudo apt update
sudo apt install lsb-release
mkdir -p $REDIS_PATH

cd $DL_DIR
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
rm -rf redis-stable
cd redis-stable
make
make test
make PREFIX=$REDIS_PATH install
