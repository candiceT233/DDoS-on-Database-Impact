#!/bin/bash
if [ $# -ne 1 ]
then
	echo "Usage: $SCRIPTNAME [start|stop|restart]"
    # echo "server_num: 4,8,12,16,20,24"
    echo "server: localhost"
    exit 1
fi

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

sudo mkdir -p $BEEGFS_DATA
sudo mkdir -p $BEEGFS_CLUSTER
sudo mkdir -p $BEEGFS_LOGS

sudo chown $USER:$USER $BEEGFS_DATA
sudo chown $USER:$USER $BEEGFS_CLUSTER
sudo chown $USER:$USER $BEEGFS_LOGS

echo "If permission denied, run: sudo chown $USER:$USER $BEEGFS_DATA"

clean_path () {
    sudo rm -rf $BEEGFS_DATA $BEEGFS_CLUSTER $BEEGFS_LOGS
}

clear_cache(){
    # clear server system cache
    #mpssh -f ${MONGO_SCRIPT_DIR}/shard_servers 'sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"'
    # mpssh -f ${MONGO_SCRIPT_DIR}/shard_servers "sudo fm" > /dev/null 2>&1
    sudo su root -c "sync; echo 3 > /proc/sys/vm/drop_caches"
}

beegfs_config () {
    clean_path

    sudo $BEEGFS_SBIN/beegfs-setup-mgmtd -p $BEEGFS_DATA/beegfs_mgmtd
    sudo $BEEGFS_SBIN/beegfs-setup-meta -p $BEEGFS_DATA/beegfs_meta -s 2 -m localhost

    sudo $BEEGFS_SBIN/beegfs-setup-storage -p $BEEGFS_DATA/beegfs_storage -s 3 -i 301 -m localhost
    sudo $BEEGFS_SBIN/beegfs-setup-client -m localhost

    sudo cp $BEEGFS_CONF_DIR/* /etc/beegfs/
}

start_beegfs_server () {

    sudo systemctl start beegfs-mgmtd
    sudo systemctl start beegfs-meta
    sudo systemctl start beegfs-storage

    sudo systemctl status beegfs-mgmtd beegfs-meta beegfs-storage

}

start_beegfs_client () {
    sudo systemctl start beegfs-helperd
    sudo systemctl start beegfs-client

    sudo systemctl status beegfs-helperd beegfs-client

}

stop_beegfs_server () {
    echo "stop_beegfs_server"

    sudo systemctl stop beegfs-storage
    sudo systemctl stop beegfs-meta
    sudo systemctl stop beegfs-mgmtd

    sudo systemctl status beegfs-mgmtd beegfs-meta beegfs-storage
}

stop_beegfs_client () {
    echo "stop_beegfs_client"

    sudo systemctl stop beegfs-client
    sudo systemctl stop beegfs-helperd

    sudo systemctl status beegfs-helperd beegfs-client
    
}

case "$1" in
	start) clear_cache
            start_beegfs_server
            start_beegfs_client
	       ;;

	stop) stop_beegfs_client
            stop_beegfs_server
            clean_path
	      ;;
    config) beegfs_config
          ;;
	
	*) echo "unknown command"
	   exit
	   ;;
esac