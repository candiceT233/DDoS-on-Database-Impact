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

CONFIG_SERVER_LIST=`cat ${CWD}/conf_servers | awk '{print $1}'`
# Prepare congfig for config servers
echo "Prepare configuration file for each config server instance in mongo cluster ..."
for conf_srv in ${CONFIG_SERVER_LIST[@]}
do
  # Create config server configuration
  CONFIG_SRV_DIR="${CWD}/mongod"
  rm -rf ${CONFIG_SRV_DIR}
  mkdir -p ${CONFIG_SRV_DIR}/db
  ${CWD}/create_conf.sh -f ${CONFIG_SRV_DIR}/${CONFIG_SVR_CONF_FILE} -t "configsrv" -p "${CONFIG_SVR_PORT}" -l "${MONGO_CONF_SRV_DIR}/mongod.log" -d "${MONGO_CONF_SRV_DIR}/db" -r "replconfig01"
  # copy the config file
  ssh ${conf_srv} mkdir -p ${MONGO_CONF_SRV_DIR}
  rsync -qraz ${CWD}/mongod/* ${conf_srv}:${MONGO_CONF_SRV_DIR}
done
wait

# Start config server
echo "Start each config server instance in mongo cluster ..."
CONF_SRV_BIN=${MONGO_BIN}/mongod
for conf_srv in ${CONFIG_SERVER_LIST[@]}
do
  ssh ${conf_srv} "sh -c \"${CONF_SRV_BIN} --config ${MONGO_CONF_SRV_DIR}/${CONFIG_SVR_CONF_FILE} --fork > /dev/null 2>&1 \""
done
sleep 2

# Initialize config server
# Initialize config server
echo "Initialize each config server instance in mongo cluster ..."
# step1: create config replica init file
conf_replname="replconfig01"
echo -e "rs.initiate(\n\t{\n\t\t_id: \"${conf_replname}\",\n\t\tconfigsvr: true,\n\t\tmembers: [" > ${CWD}/conf_repl_init.js
index=0
num_conf_srvs=`cat ${CWD}/conf_servers|wc -l`
for conf_srv in ${CONFIG_SERVER_LIST[@]}
do
  #echo "index=${index}, srv_nums=${num_conf_srvs}"
  if [ ${index} -eq $(($num_conf_srvs - 1)) ]
  then
    echo -e "\t\t\t{ _id : ${index}, host : \"${conf_srv}:${CONFIG_SVR_PORT}\" }" >> ${CWD}/conf_repl_init.js
  else
    echo -e "\t\t\t{ _id : ${index}, host : \"${conf_srv}:${CONFIG_SVR_PORT}\" }," >> ${CWD}/conf_repl_init.js
  fi
  ((index=index+1))
done
echo -e "\t\t]\n\t}\n)" >> ${CWD}/conf_repl_init.js
# step2: Init the config server
first_config_server=`head -1 ${CWD}/conf_servers`
CLIENT_BIN=${MONGO_BIN}/mongo
mkdir -p ${CWD}/log
${CLIENT_BIN} --host ${first_config_server} --port ${CONFIG_SVR_PORT} < ${CWD}/conf_repl_init.js > ${CWD}/log/conf_replica_init.log
cat ${CWD}/log/conf_replica_init.log | grep -i ok
${CLIENT_BIN} --host ${first_config_server} --port ${CONFIG_SVR_PORT} --eval "rs.isMaster()" > ${CWD}/log/conf_replica_init.log
cat ${CWD}/log/conf_replica_init.log | grep -i "ismaster\|configsvr"

# prepare configurations for each sharding server
SHARD_SERVER_LIST=`cat ${CWD}/shard_servers | awk '{print $1}'`
index=0
for shard_server in ${SHARD_SERVER_LIST[@]}
do
  # Create config server configuration
  SHARD_SRV_DIR="${CWD}/mongod_shard"
  rm -rf ${SHARD_SRV_DIR}
  mkdir -p ${SHARD_SRV_DIR}/db
  ${CWD}/create_conf.sh -f ${SHARD_SRV_DIR}/${SHARD_SVR_CONF_FILE} -t "shardsrv" -p "${SHARD_SVR_PORT}" -l "${MONGO_SHARD_SRV_DIR}/mongod_shard.log" -d "${MONGO_SHARD_SRV_DIR}/db" -r "replshard${index}"
  # copy the config file
  ssh ${shard_server} mkdir -p ${MONGO_SHARD_SRV_DIR}
  rsync -qraz ${CWD}/mongod_shard/* ${shard_server}:${MONGO_SHARD_SRV_DIR}
  ((index=index+1))
done

# Start shard server
echo "Start each shard server instance in mongo cluster ..."
SHARD_SRV_BIN=${MONGO_BIN}/mongod
for shard_server in ${SHARD_SERVER_LIST[@]}
do
  ssh ${shard_server} "sh -c \"${SHARD_SRV_BIN} --config ${MONGO_SHARD_SRV_DIR}/${SHARD_SVR_CONF_FILE} --fork > /dev/null 2>&1\""
done
sleep 2

# Initialize shard server
index=0
for shard_server in ${SHARD_SERVER_LIST[@]}
do
  repl_name="replshard${index}"
  ((index=index+1))
  # create shard repl init file
  echo -e "rs.initiate(\n\t{\n\t\t_id: \"${repl_name}\",\n\t\tmembers: [" > ${CWD}/shard_repl_init.js
  echo -e "\t\t\t{ _id : 0, host : \"${shard_server}:${SHARD_SVR_PORT}\" }" >> ${CWD}/shard_repl_init.js
  echo -e "\t\t]\n\t}\n)" >> ${CWD}/shard_repl_init.js
  ${CLIENT_BIN} --host ${shard_server} --port ${SHARD_SVR_PORT} < ${CWD}/shard_repl_init.js > ${CWD}/log/shard_replica_init_${index}.log
  cat ${CWD}/log/shard_replica_init_${index}.log | grep -i ok
done


# start and initialize the router
echo "Starting router nodes ...."
router_SERVER_LIST=`cat ${CWD}/router_servers | awk '{print $1}'`
index=0
for router in ${router_SERVER_LIST[@]}
do
  # Create config server configuration
  ROUTER_SRV_DIR="${CWD}/mongos"
  rm -rf ${ROUTER_SRV_DIR}
  mkdir -p ${ROUTER_SRV_DIR}/db
  conf_servers=""
  for conf_srv in ${CONFIG_SERVER_LIST[@]}
  do
    conf_servers="${conf_servers}${conf_srv}:${CONFIG_SVR_PORT},"
  done
  conf_servers=`echo ${conf_servers} | sed 's/,$//'`
  ${CWD}/create_conf.sh -f ${ROUTER_SRV_DIR}/${ROUTER_CONF_FILE} -t "routersrv" -p "${ROUTER_SVR_PORT}" -l "${MONGO_ROUTER_SRV_DIR}/mongos.log" -r "replconfig01" -c ${conf_servers}
  # copy the config file
  ssh ${router} mkdir -p ${MONGO_ROUTER_SRV_DIR}
  rsync -qraz ${CWD}/mongos/* ${router}:${MONGO_ROUTER_SRV_DIR}
done

echo "Start each router server instance in mongo cluster ..."
ROUTER_SRV_BIN=${MONGO_BIN}/mongos
for router in ${router_SERVER_LIST[@]}
do
  ssh ${router} "sh -c \"${ROUTER_SRV_BIN} --config ${MONGO_ROUTER_SRV_DIR}/${ROUTER_CONF_FILE} --fork > /dev/null 2>&1\""
done
sleep 5

# Adding shard servers to router
index=0
rm -f ${CWD}/add_shards_to_routers.js
for shard_srv in ${router_SERVER_LIST[@]}
do
  echo "sh.addShard(\"replshard${index}/${shard_srv}:${SHARD_SVR_PORT}\")" >> ${CWD}/add_shards_to_routers.js
  ((index=index+1))
done

first_ruter_server=`head -1 ${CWD}/router_servers`
${CLIENT_BIN} --host ${first_ruter_server} --port ${ROUTER_SVR_PORT} < ${CWD}/add_shards_to_routers.js > ${CWD}/log/add_shard_to_mongos.log
cat ${CWD}/log/add_shard_to_mongos.log | grep -i ok

# Enable Sharding for a Database
#${CLIENT_BIN} --host server1 --port ${ROUTER_SVR_PORT} --eval "sh.enableSharding(\"ycsb\")"
#sharding the collection
DATABASE_NAME="ycsb"
COLLECTION_NAME="usertable"
${CLIENT_BIN} --host ${first_ruter_server} --port ${ROUTER_SVR_PORT} > ${CWD}/log/enableSharding.log << EOF
use $DATABASE_NAME;
sh.enableSharding("${DATABASE_NAME}");
db.createCollection("${COLLECTION_NAME}")
sh.shardCollection("$DATABASE_NAME.$COLLECTION_NAME",{_id:"hashed"});
db.${COLLECTION_NAME}.getShardVersion()
db.${COLLECTION_NAME}.getShardDistribution()
EOF

# Checking mongod
echo -e "${GREEN}Checking mongod ...${NC}"
# mpssh -f ${CWD}/conf_servers 'pgrep -la mongod' | sort
# mpssh -f ${CWD}/shard_servers 'pgrep -la mongod' | sort
pgrep -la mongod | sort
pgrep -la mongod | sort

# Checking mongos
echo -e "${GREEN}Checking mongos ...${NC}"
# mpssh -f ${CWD}/router_servers 'pgrep -la mongos' | sort
pgrep -la mongos | sort

echo "MongoDB cluster starts successfully"