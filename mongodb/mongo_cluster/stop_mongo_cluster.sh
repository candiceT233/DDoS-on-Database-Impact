#!/bin/bash
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "Current directory is ${CWD}"
if [ -f ${CWD}/env_conf.sh ]
then
  source ${CWD}/env_conf.sh
else
  echo "The env_conf.sh file doesn't exist, exiting ..."
  exit
fi

echo "Stopping MongoDB processes ..."
$HOME/scripts/mpssh/mpssh -f ${CWD}/conf_servers 'killall -9 mongod' > /dev/null
$HOME/scripts/mpssh/mpssh -f ${CWD}/shard_servers 'killall -9 mongod' > /dev/null
$HOME/scripts/mpssh/mpssh -f ${CWD}/router_servers 'killall -9 mongos' > /dev/null

# killall -9 mongod

echo "MongoDB cluster is stopped"
