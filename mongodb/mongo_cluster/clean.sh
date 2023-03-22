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
# mpssh -f ${CWD}/conf_servers 'killall -9 mongod' > /dev/null
# mpssh -f ${CWD}/shard_servers 'killall -9 mongod' > /dev/null
# mpssh -f ${CWD}/router_servers 'killall -9 mongos' > /dev/null

killall -9 mongos #> /dev/null

echo "MongoDB cluster is stopped"

echo "Cleaning the log, config, and data..."
# mpssh -f ${CWD}/conf_servers "rm -rf ${MONGO_CONF_SRV_DIR} ${MONGO_INSTALL_DIR}" > /dev/null
# mpssh -f ${CWD}/shard_servers "rm -rf ${MONGO_SHARD_SRV_DIR} ${MONGO_INSTALL_DIR}" > /dev/null
# mpssh -f ${CWD}/router_servers "rm -rf ${MONGO_ROUTER_SRV_DIR} ${MONGO_INSTALL_DIR}" > /dev/null

rm -rf ${MONGO_CONF_SRV_DIR} ${MONGO_INSTALL_DIR} #> /dev/null
rm -rf ${MONGO_SHARD_SRV_DIR} ${MONGO_INSTALL_DIR} #> /dev/null
rm -rf ${MONGO_ROUTER_SRV_DIR} ${MONGO_INSTALL_DIR} #> /dev/null

echo "Done cleaning MongoDB..."
