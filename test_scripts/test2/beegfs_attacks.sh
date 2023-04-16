#!/bin/bash

# User Directories
INSTALL_DIR=$HOME/install
DL_DIR=$HOME/download
SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact
TEST_DIR=$SCRIPT_DIR/test_scripts/test2
RESULT_DIR=$SCRIPT_DIR/results
SERVER_HOST_FILE_DIR=$SCRIPT_DIR/ip_files
mkdir -p $RESULT_DIR
rm -rf $RESULT_DIR/*

num_s="1"

STORAGE_PORT=8003
CLIENT_PORT=8004 #UDP
META_PORT=8005
HELPERD_PORT=8006
MGMTD_PORT=8008

THREADS=640
DURATION=300

attack_host=$(cat $SCRIPT_DIR/ip_files/${num_s}_servers_ip | head -n 1)

if [ -d "$SCRIPT_DIR/bin/PAT" ]; then
    echo "PAT already installed"
else
    echo "Installing PAT"
    mkdir $SCRIPT_DIR/bin/PAT
    cp -r $SCRIPT_DIR/tools/PAT/* $SCRIPT_DIR/bin/PAT/
fi
PAT_COL=$SCRIPT_DIR/bin/PAT/PAT-collecting-data
PAT_POS=$SCRIPT_DIR/bin/PAT/PAT-postprocessing



source $SCRIPT_DIR/.ddos_test_env/bin/activate

start_server () {
    set -x

    echo "Starting BeeGFS server and client"
    cd $SCRIPT_DIR/beegfs
    ./beegfs.sh start

    mpssh -f $SERVER_HOST_FILE_DIR/${num_s}_servers_ip 'tail /usr/local/beegfs_logs/beegfs-client.log'

    # sleep 10

    set +x
}

check_server () {
    set -x

    echo "checking BeeGFS status"
    cd $SCRIPT_DIR/beegfs
    ./beegfs.sh status

    # sleep 3

    set +x
}

stop_server () {
    set -x

    echo "Stopping BeeGFS server and client"
    cd $SCRIPT_DIR/beegfs
    ./beegfs.sh stop

    mpssh -f ${SERVER_HOST_FILE_DIR}/${num_s}_servers_ip 'tail /usr/local/beegfs_logs/beegfs-client.log'
    # sleep 3

    set +x
}

ddos_attack () {

    for test in $STORAGE_PORT,TCP $STORAGE_PORT,MINECRAFT $CLIENT_PORT,UDP $HELPERD_PORT,MINECRAFT $MGMTD_PORT,TCP $MGMTD_PORT,MINECRAFT
    do
        IFS=","
        set -- $test

        port=$1
        method=$2

        start_server

        echo "Attacking ${attack_host} port $port with method $method"

        TEST_CMD="python3 $SCRIPT_DIR/tools/MHDDoS/start.py $method $attack_host:$port $THREADS $DURATION ; sleep 10"
        echo "TEST_CMD: $TEST_CMD"

        # Prepare and run PAT test
        sed "s#TEST_CMD#$TEST_CMD#g" $TEST_DIR/config.template > $PAT_COL/config
        sed -i "s#HOSTIP#$attack_host#g" $PAT_COL/config

        cd $PAT_COL && ./pat run

        mv $PAT_COL/results/2023-* $RESULT_DIR/${num_s}_servers_${method}_${port}
        echo "$(du -h $RESULT_DIR/${num_s}_servers_${method}_${port}/instruments/result_templatev1.xlsm)"
        
        $RESULT_DIR/${num_s}_servers_${method}_${port}

        stop_server
        sleep 5

    done
}

stop_server

ddos_attack

# mkdir -p $SCRIPT_DIR/saved_results/beegfs_${num_s}_servers_${THREADS}t${DURATION}s
# mv $RESULT_DIR/${num_s}_servers_* $SCRIPT_DIR/saved_results/beegfs_${num_s}_servers_${THREADS}t${DURATION}s/

