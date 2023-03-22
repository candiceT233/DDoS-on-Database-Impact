#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $SCRIPTNAME [start|stop]"
    echo "cmd: start, stop"
    # echo "server_num: 4,8,12,16,20,24"
    echo "server: localhost"
    exit 1
fi

# global variables
username=$USER

# source env_var.sh

SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact
MONGO_SCRIPT_DIR=${SCRIPT_DIR}/mongodb/mongo_install
SERVER_HOST_FILE_DIR=${SCRIPT_DIR}/ip_files
MONGODB_CLUSTER=/mnt/mongodb

#local variable
num_s="1" # 2, 4, 8?
cmd=$1

start_mongo_cluster(){
    # start mongo cluster
    ${MONGO_SCRIPT_DIR}/start_mongo_cluster.sh
}

stop_mongo_cluster(){
    # stop mongo cluster
    ${MONGO_SCRIPT_DIR}/stop_mongo_cluster.sh
    # clean mongo cluster
    ${MONGO_SCRIPT_DIR}/clean.sh
}

clear_cache(){
    # clear server system cache
    #mpssh -f ${MONGO_SCRIPT_DIR}/shard_servers 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    mpssh -f ${MONGO_SCRIPT_DIR}/shard_servers "sudo fm" > /dev/null 2>&1
}

# modify "MONGODB_CLUSTER" in config file
sed -i "/^MONGODB_CLUSTER=/cMONGODB_CLUSTER=${MONGODB_CLUSTER}" ${MONGO_SCRIPT_DIR}/env_conf.sh

# create "conf_servers", "shard_servers", and "router_servers" file according to ${num_s}
head -2 ${SERVER_HOST_FILE_DIR}/${num_s}_servers_ip > ${MONGO_SCRIPT_DIR}/conf_servers
cp ${SERVER_HOST_FILE_DIR}/${num_s}_servers_ip  ${MONGO_SCRIPT_DIR}/shard_servers
cp ${SERVER_HOST_FILE_DIR}/${num_s}_servers_ip  ${MONGO_SCRIPT_DIR}/router_servers


# if [ ${cmd} == "start" ];
# then
#     clear_cache
#     start_mongo_cluster
# elif [ ${cmd} == "stop" ];
# then
#     stop_mongo_cluster
# else
#     echo "Error: invalid command \"${cmd}\""
#     exit 1
# fi

SCRIPTNAME=$(basename "$0")



case "$1" in

	start) clear_cache
            start_mongo_cluster
	       ;;

	stop) stop_mongo_cluster
	      ;;
	
	*) echo "unknown command"
	   exit
	   ;;
esac