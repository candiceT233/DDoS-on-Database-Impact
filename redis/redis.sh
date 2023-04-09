#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $SCRIPTNAME [start|stop]"
    echo "cmd: start, stop"
    # echo "server_num: 4,8,12,16,20,24"
    echo "server: localhost"
    exit 1
fi

# User Directories
INSTALL_DIR=$HOME/install
DL_DIR=$HOME/download
SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact

mkdir -p $INSTALL_DIR
mkdir -p $DL_DIR
mkdir -p $SCRIPT_DIR

# global variables
username=$USER
SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact
REDIS_SCRIPT_DIR=$SCRIPT_DIR/redis/redis_cluster
REDIS_CLUSTER=/mnt/redis
SERVER_HOST_FILE_DIR=$SCRIPT_DIR/ip_files

#local variable
num_s="1"
cmd=$1


start_redis_cluster(){
    # start redis cluster
    ${REDIS_SCRIPT_DIR}/start_redis_cluster.sh env_conf_c1.sh
}

stop_redis_cluster(){
    # stop redis cluster
    ${REDIS_SCRIPT_DIR}/stop_redis_cluster.sh env_conf_c1.sh
    # clean redis cluster
    ${REDIS_SCRIPT_DIR}/clean.sh env_conf_c1.sh
}

clear_cache(){
    # clear client system cache
    #mpssh -f ${CLIENT_HOST_FILE} 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    # clear server system cache
    #mpssh -f ${REDIS_SCRIPT_DIR}/servers 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    # mpssh -f ${REDIS_SCRIPT_DIR}/servers "sudo fm" > /dev/null 2>&1
    sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"
}

# modify "REDIS_CLUSTER" in config file
sed -i "/^REDIS_CLUSTER=/cREDIS_CLUSTER=${REDIS_CLUSTER}" ${REDIS_SCRIPT_DIR}/env_conf_c1.sh
cp ${SERVER_HOST_FILE_DIR}/workers-${num_s}  ${REDIS_SCRIPT_DIR}/servers


case "$1" in

	start) clear_cache
            start_redis_cluster
	       ;;

	stop) stop_redis_cluster
	      ;;
	
	*) echo "unknown command"
	   exit
	   ;;
esac