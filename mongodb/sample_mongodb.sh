#!/usr/bin/bash
#===============================================================================
#
#          FILE:  mongo_start_stop.sh 
#
#         USAGE:  ./mongo_start_stop.sh [start|stop|restart] 
#
#   DESCRIPTION:  Start, stop or restart unix mongodb-server 
#
#       OPTIONS:  ---  
#
#	   TODO:  logging
#                 
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Patrick Kowalik, kowalik.patrick@online.de
#    REPOSITORY:  https://github.com/patrick0585/Mongo_Start_Stop
#       COMPANY:  ---
#       VERSION:  5.0.15
#       CREATED:  15/05/2017 22:00:00 PM MDT
#      REVISION:  ---
#===============================================================================

VERSION=5.0.15
SCRIPTNAME=$(basename "$0")
source env_var.sh
# MONGODB_PATH=
MONGODB_BIN=$MONGODB_PATH/bin
MONGOD=$MONGODB_BIN/mongod
# MONGODB_DATA=
MONGODBCONFIG=$SCRIPT_DIR/deploy_scripts/mongo.conf


if [ $# != 1 ]
then
	echo "Usage: $SCRIPTNAME [start|stop|restart]"
	exit
fi

pid() {
    ps -ef | awk '/[m]ongodb/ {print $2}'
}

stopServer() {
    PID=$(pid)
    if [ ! -z "$PID" ]; 
    then
        echo "... stopping mongodb-server with pid: $PID"
	sudo kill $PID
    else
        echo "... mongodb-server is not running!"
    fi
}

startServer() {
    PID=$(pid)
    if [ ! -z "$PID" ];
    then
        echo "... mongodb-server already running with pid: $PID"
    else
        echo "... starting mongodb-server"
        sudo "$MONGOD" --dbpath "$MONGODB_DATA" --config "$MONGODBCONFIG"
    fi
#     tail $MONGODB_LOGS/mongod.log
}

restartServer() {
    stopServer
    sleep 1s
    startServer    
}

case "$1" in

	start) startServer
	       ;;

	stop) stopServer
	      ;;

	restart) restartServer
		 ;;
	
	*) echo "unknown command"
	   exit
	   ;;
esac