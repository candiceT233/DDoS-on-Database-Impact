#!/bin/bash
if [ $# -ne 1 ];
then
    echo "Usage:./start_redis_cluster.sh env_conf_c1.sh"
    exit
fi

conf_file_name=$1
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo ${CWD}
if [ -f ${CWD}/${conf_file_name} ]
then
  source ${CWD}/${conf_file_name}
else
  echo "The ${conf_file_name} file doesn't exist, exiting ..."
  exit
fi

# check if the number of redis servers meets the minimum requirements
if [ ${N_REDIS_NODES} -lt 3 ]
then
  echo "At least 3 servers are required for redis cluster, exiting ..."
  exit
fi

# prepare configuration for each redis instance
echo "Prepare redis cluster configuration file for each redis instance in redis cluster ..."
index=0
for server in ${REDIS_NODES[@]}
do
  ((port=$REDIS_PORT_BASE+$index))
  redis_instance_dir="${CWD}/cluster/${port}"
  mkdir -p ${redis_instance_dir}
  # create the conf file
  echo "port $port" > ${redis_instance_dir}/$CONFIG_FILE
  echo "protected-mode no" >> ${redis_instance_dir}/$CONFIG_FILE
  echo "daemonize yes" >> ${redis_instance_dir}/$CONFIG_FILE
  echo "pidfile ${CLUSTER_INSTALL_DIR}/${port}/redis.pid" >> ${redis_instance_dir}/$CONFIG_FILE
  echo "cluster-enabled yes" >> ${redis_instance_dir}/$CONFIG_FILE
  echo "cluster-config-file nodes.conf" >>  ${redis_instance_dir}/$CONFIG_FILE
  echo "cluster-node-timeout 5000" >> ${redis_instance_dir}/$CONFIG_FILE
  #echo "appendonly yes" >> ${redis_instance_dir}/$CONFIG_FILE
  echo "save 60 10000" >> ${redis_instance_dir}/$CONFIG_FILE
  echo "dir ${CLUSTER_INSTALL_DIR}/${port}/${redis_server_dir}" >> ${redis_instance_dir}/$CONFIG_FILE
  echo "logfile ${CLUSTER_INSTALL_DIR}/${port}/file.log" >> ${redis_instance_dir}/$CONFIG_FILE
  ((index=index+1))
done

# Copy configuration file to redis install directory
echo "Copying redis configuration file to redis install directory ..."
index=0
for server in ${REDIS_NODES[@]}
do
  ((port=$REDIS_PORT_BASE+$index))
  redis_instance_dir="${CWD}/cluster/${port}"
  ssh ${server} mkdir -p ${CLUSTER_INSTALL_DIR}
  rsync -qraz ${redis_instance_dir} $server:${CLUSTER_INSTALL_DIR}
  ((index=index+1))
done
wait

# Start redis cluster
echo "Starting redis cluster ..."
index=0
for server in ${REDIS_NODES[@]}
do
  echo "\tStarting redis instance ${index} on ${server}..."
  ((port=$REDIS_PORT_BASE+$index))
  ssh $server "sh -c \"cd ${CLUSTER_INSTALL_DIR}/$port; ${REDIS_BIN}/redis-server ./${CONFIG_FILE} > /dev/null 2>&1 &\""
  ((index=index+1))
done
# sleep 10 seconds to wait all redis instances start successfully
sleep 10

# Verify redis instance status
echo "Verifying Redis instance status ..."
# mpssh -f ${CWD}/servers 'pgrep -l redis-server'
pgrep -l redis-server

# Create redis cluster through redis-cli
echo "Connecting Redis cluster servers by using redis-cli ..."
index=0
cmd="$REDIS_BIN/redis-cli --cluster create "
for server in ${REDIS_NODES[@]}
do
  server_ip=$(getent ahosts $server | grep STREAM | awk '{print $1}')
  ((port=$REDIS_PORT_BASE+$index))
  cmd="${cmd}${server_ip}:${port} "
  ((index=index+1))
done
cmd="${cmd}--cluster-replicas 0"
echo yes | $cmd

sleep 5

# Check redis cluster status
echo "Checking redis cluster status ..."
first_server=`head -1 ${CWD}/servers`
cmd="$REDIS_BIN/redis-cli -c -h ${first_server} -p ${REDIS_PORT_BASE} cluster nodes"
$cmd | sort -k9 -n
echo "Redis cluster is started"

