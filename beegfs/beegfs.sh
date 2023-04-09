#!/bin/bash
if [ $# -ne 1 ]
then
	echo "Usage: $SCRIPTNAME [start|stop|config|restart]"
    # echo "server_num: 4,8,12,16,20,24"
    echo "server: localhost"
    exit 1
fi

# get env variables
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ -f ${CWD}/env_conf.sh ]; then
  source ${CWD}/env_conf.sh
else
  echo "The environment configuration file (env_conf.sh) doesn't exist. Exit....."
  exit
fi

# REBUILD_CLIENT=false
#local variable
num_s="1" # 2, 4, 8?

hosts=($(cat $SERVER_HOST_FILE_DIR/${num_s}_servers_ip ))
hosts_str=$(IFS=','; echo "${hosts[*]}")
# hosts_str="localhost"
echo "hosts_str=$hosts_str"


clean_path () {
    mpssh -f ${SERVER_HOST_FILE_DIR}/${num_s}_servers_ip "sudo rm -rf ${BEEGFS_DATA} ${BEEGFS_CLUSTER} ${BEEGFS_LOGS}"
    echo "$BEEGFS_DATA $BEEGFS_CLUSTER $BEEGFS_LOGS cleared ..."
    mpssh -f ${SERVER_HOST_FILE_DIR}/${num_s}_servers_ip "sudo mkdir -p ${BEEGFS_DATA} ${BEEGFS_CLUSTER} ${BEEGFS_LOGS}"
}

clear_cache(){
    # clear server system cache
    mpssh -f ${SERVER_HOST_FILE_DIR}/${num_s}_servers_ip 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    # mpssh -f ${MONGO_SCRIPT_DIR}/shard_servers "sudo fm" > /dev/null 2>&1
    # sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"
}

beegfs_config () {
    for node in "${hosts[@]}"
    do
        ssh ${node} /bin/bash << EOF
sudo cp ${BEEGFS_CONF_DIR}/* /etc/beegfs/

sudo ${BEEGFS_SBIN}/beegfs-setup-mgmtd -p ${BEEGFS_DATA}/beegfs_mgmtd
sudo ${BEEGFS_SBIN}/beegfs-setup-meta -p ${BEEGFS_DATA}/beegfs_meta -s 2 -m "${hosts_str}"
sudo ${BEEGFS_SBIN}/beegfs-setup-storage -p ${BEEGFS_DATA}/beegfs_storage -s 3 -i 301 -m "${hosts_str}"
sudo ${BEEGFS_SBIN}/beegfs-setup-client -m "${hosts_str}"

sudo sed -i "s#/var/log/#/usr/local/beegfs_logs/#" /etc/beegfs/beegfs-mgmtd.conf
sudo sed -i "s#/var/log/#/usr/local/beegfs_logs/#" /etc/beegfs/beegfs-meta.conf
sudo sed -i "s#/var/log/#/usr/local/beegfs_logs/#" /etc/beegfs/beegfs-storage.conf
sudo sed -i "s#/var/log/#/usr/local/beegfs_logs/#" /etc/beegfs/beegfs-helperd.conf
exit
EOF
    done


    # sudo sed -i "s/connDisableAuthentication[[:space:]]*=[[:space:]]*false/connDisableAuthentication = true/g" /etc/beegfs/beegfs-mgmtd.conf
    # sudo sed -i "s/connDisableAuthentication[[:space:]]*=[[:space:]]*false/connDisableAuthentication = true/g" /etc/beegfs/beegfs-meta.conf
    # sudo sed -i "s/connDisableAuthentication[[:space:]]*=[[:space:]]*false/connDisableAuthentication = true/g" /etc/beegfs/beegfs-storage.conf
    # sudo sed -i "s/connDisableAuthentication[[:space:]]*=[[:space:]]*false/connDisableAuthentication = true/g" /etc/beegfs/beegfs-helperd.conf
    # sudo sed -i "s/connDisableAuthentication[[:space:]]*=[[:space:]]*false/connDisableAuthentication = true/g" /etc/beegfs/beegfs-client.conf
    
}

check_beegfs_status () {
    mpssh -f ${SERVER_HOST_FILE_DIR}/${num_s}_servers_ip 'sudo systemctl status beegfs-mgmtd beegfs-meta beegfs-storage beegfs-helperd beegfs-client'
}

start_beegfs_server () {
    echo "Starting BeeGFS Server ..."

    for node in "${hosts[@]}"
    do
        ssh ${node} /bin/bash << EOF
    sudo systemctl start beegfs-mgmtd 
    sudo systemctl start beegfs-meta
    sudo systemctl start beegfs-storage
EOF
done
    # sudo systemctl status beegfs-mgmtd beegfs-meta beegfs-storage
}

start_beegfs_client () {
    echo "Starting BeeGFS Client ..."

    for node in "${hosts[@]}"
    do
        ssh ${node} /bin/bash << EOF
sudo systemctl start beegfs-helperd
sudo /etc/init.d/beegfs-client rebuild
sudo systemctl start beegfs-client
EOF
done
}

stop_beegfs_server () {
    echo "Stopping BeeGFS Server ..."
    mpssh -f ${SERVER_HOST_FILE_DIR}/${num_s}_servers_ip 'sudo systemctl stop beegfs-storage beegfs-meta beegfs-mgmtd'

}

stop_beegfs_client () {
    echo "Stopping BeeGFS Client ..."
    mpssh -f ${SERVER_HOST_FILE_DIR}/${num_s}_servers_ip 'sudo systemctl stop beegfs-client beegfs-helperd'
}

case "$1" in
	start) 
        clean_path
        beegfs_config
        clear_cache
        start_beegfs_server
        start_beegfs_client
        ;;

	stop) 
        stop_beegfs_client
        stop_beegfs_server
	    ;;
    restart)
        stop_beegfs_client
        stop_beegfs_server
        clean_path
        start_beegfs_server
        start_beegfs_client
          ;;
    config) 
        clean_path
        beegfs_config
        ;;
    status)
        check_beegfs_status
        ;;
	
	*) echo "unknown command"
	   exit
	   ;;
esac