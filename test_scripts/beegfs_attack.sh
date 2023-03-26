#!/bin/bash

# User Directories
INSTALL_DIR=$HOME/install
DL_DIR=$HOME/download
SCRIPT_DIR=$HOME/scripts/DDoS-on-Database-Impact
RESULT_DIR=$SCRIPT_DIR/results
mkdir -p $RESULT_DIR
rm -rf $RESULT_DIR/*

num_s="1"

STORAGE_PORT=8003
CLIENT_PORT=8004 #UDP
META_PORT=8005
HELPERD_PORT=8006
MGMTD_PORT=8008

# ATTACK_PORTS=( $STORAGE_PORT $CLIENT_PORT $META_PORT $HELPERD_PORT $MGMTD_PORT )
# L4_METHODS=( UDP TCP CPS MCBOT MINECRAFT)
ATTACK_PORTS=( $STORAGE_PORT )
L4_METHODS=( UDP TCP )

attack_host=$(cat $SCRIPT_DIR/ip_files/${num_s}_servers_ip | head -n 1)

if [ -d "$SCRIPT_DIR/bin/PAT" ]; then
    echo "PAT already installed"
else
    echo "Installing PAT"
    cp -r $SCRIPT_DIR/tools/PAT $SCRIPT_DIR/bin
fi
PAT_COL=$SCRIPT_DIR/bin/PAT/PAT-collecting-data
PAT_POS=$SCRIPT_DIR/bin/PAT/PAT-postprocessing

set -x

source $SCRIPT_DIR/.ddos_test_env/bin/activate

for port in ${ATTACK_PORTS[@]}; do
    for method in ${L4_METHODS[@]}; do
        echo "Attacking ${attack_host} port $port with method $method"

        # LATEST_DIR="$PAT_COL/results/latest"
        # sed "s#RESULT_DIR#$LATEST_DIR#g" $SCRIPT_DIR/test_scripts/config.xml > $PAT_POS/config.xml

        TEST_CMD="echo python3 $SCRIPT_DIR/start.py $method $attack_host:$port; sleep 5"
        echo "TEST_CMD: $TEST_CMD"

        sed "s#TEST_CMD#$TEST_CMD#g" $SCRIPT_DIR/test_scripts/config.template > $PAT_COL/config
        sed -i "s#HOSTIP#$attack_host#g" $PAT_COL/config
        
        cd $PAT_COL && ./pat run

        # python3 $SCRIPT_DIR/start.py $method $attack_host:$port
        mkdir -p $RESULT_DIR/${num_s}_servers_${method}_${port}
        mv $PAT_COL/results/* $RESULT_DIR/${num_s}_servers_${method}_${port}/

        sleep 5
    done
done
