#!/bin/bash
if [ $# -ne 1 ];
then
    echo "Usage:./clean.sh env_conf_c1.sh"
    exit
fi
conf_file_name=$1
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [ -f ${CWD}/${conf_file_name} ]
then
  source ${CWD}/${conf_file_name}
else
  echo "The ${conf_file_name} file doesn't exist, exiting ..."
  exit
fi

echo "Stopping redis cluster ..."
mpssh -f ${CWD}/servers 'killall -9 redis-server' > /dev/null

echo "Double checking if redis cluster is stopped ..."
mpssh -f ${CWD}/servers 'pgrep -la redis-server' | sort

# Clear log and cluster node infor
echo "Clear log information ..."
echo "${CLUSTER_INSTALL_DIR}"
mpssh -f ${CWD}/servers "rm -rf ${CLUSTER_INSTALL_DIR}/*" > /dev/null
