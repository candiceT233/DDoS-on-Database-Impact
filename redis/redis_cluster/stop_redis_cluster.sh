#!/bin/bash
if [ $# -ne 1 ];
then
    echo "Usage:./stop_redis_cluster.sh env_conf_c1.sh"
    exit
fi
conf_file_name=$1
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ -f ${CWD}/${conf_file_name} ]
then
  source ${CWD}/${conf_file_name}
else
  echo "The env_conf.sh file doesn't exist, exiting ..."
  exit
fi

echo "Stopping redis cluster ..."
mpssh -f ${CWD}/servers 'killall -9 redis-server' > /dev/null

echo "Double checking if redis cluster is stopped ..."
mpssh -f ${CWD}/servers 'pgrep -la redis-server' | sort

echo "Redis cluster is stopped"

