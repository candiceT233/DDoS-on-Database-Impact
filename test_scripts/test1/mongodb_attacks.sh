#!/bin/bash

# User Directories
INSTALL_DIR=$HOME/install
DL_DIR=$HOME/download
SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact
TEST_DIR=$SCRIPT_DIR/test_scripts/test1
RESULT_DIR=$SCRIPT_DIR/results
SERVER_HOST_FILE_DIR=$SCRIPT_DIR/ip_files
mkdir -p $RESULT_DIR
rm -rf $RESULT_DIR/*

num_s="1" # 2, 4, 8?

MONGOD_PORT=57040
MG_SHARD_PORT=37017
MONGOS_PORT=27017

ATTACK_PORTS=( $MONGOD_PORT $MG_SHARD_PORT $MONGOS_PORT )
L4_METHODS=( UDP TCP CONNECTIONS CPS MCBOT MINECRAFT )

# ATTACK_PORTS=( $MONGOD_PORT )
# L4_METHODS=( CONNECTION )

THREADS=64
DURATION=60

attack_host=$(cat $SCRIPT_DIR/ip_files/${num_s}_servers_ip | head -n 1)

if [ -d "$SCRIPT_DIR/bin/PAT" ]; then
    echo "PAT already installed"
else
    echo "Installing PAT"
    cp -r $SCRIPT_DIR/tools/PAT $SCRIPT_DIR/bin
fi
PAT_COL=$SCRIPT_DIR/bin/PAT/PAT-collecting-data
PAT_POS=$SCRIPT_DIR/bin/PAT/PAT-postprocessing

source $SCRIPT_DIR/.ddos_test_env/bin/activate

start_server () {
    set -x

    echo "Starting MongoDB server and client"
    cd $SCRIPT_DIR/mongodb
    ./mongodb.sh start

    mpssh -f $SERVER_HOST_FILE_DIR/${num_s}_servers_ip "tail /mnt/mongodb/mongod/mongod.log"

    set +x
}

stop_server () {
    set -x

    echo "Stopping MongoDB server and client"
    cd $SCRIPT_DIR/mongodb
    ./mongodb.sh stop

    mpssh -f $SERVER_HOST_FILE_DIR/${num_s}_servers_ip "tail /mnt/mongodb/mongod/mongod.log"

    set +x
}

ddos_attack () {

    for port in ${ATTACK_PORTS[@]}; do
        for method in ${L4_METHODS[@]}; do

            start_server

            echo "Attacking ${attack_host} port $port with method $method"

            # SIM_TEST_CMD="stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 15s"
            # python3 $SCRIPT_DIR/tools/MHDDoS/start.py $method $attack_host:$port $THREADS $DURATION

            # Prepare and run PAT test
            TEST_CMD="python3 $SCRIPT_DIR/tools/MHDDoS/start.py $method $attack_host:$port $THREADS $DURATION"
            echo "TEST_CMD: $TEST_CMD"
            sed "s#TEST_CMD#$TEST_CMD#g" $TEST_DIR/config.template > $PAT_COL/config
            sed -i "s#HOSTIP#$attack_host#g" $PAT_COL/config
            cd $PAT_COL && ./pat run

            mv $PAT_COL/results/2023-* $RESULT_DIR/${num_s}_servers_${method}_${port}
            echo "$(du -h $RESULT_DIR/${num_s}_servers_${method}_${port}/instruments/result_templatev1.xlsm)"
            
            stop_server

            sleep 2
        done
    done
}


ddos_attack

# mkdir -p $SCRIPT_DIR/saved_results/mongodb_${num_s}_servers_${THREADS}t${DURATION}s
# mv $RESULT_DIR/${num_s}_servers_* $SCRIPT_DIR/saved_results/mongodb_${num_s}_servers_${THREADS}t${DURATION}s/


