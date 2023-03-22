#!/bin/bash

#customspace(4 spaces)
s="    " 

create_conf_file()
{
  echo -e "systemLog:\n${s}destination: file\n${s}logAppend: true\n${s}path: ${LOG_PATH}" > ${CONFIG_FILE_NAME}
  echo -e "storage:\n${s}dbPath: ${DB_PATH}\n${s}journal:\n${s}${s}enabled: true" >> ${CONFIG_FILE_NAME}
  echo -e "net:\n${s}port: ${PORT}\n${s}bindIpAll: true\n" >> ${CONFIG_FILE_NAME}
  if [ "${CONFIG_TYPE}" = "configsrv" ]
  then
    echo -e "sharding:\n${s}clusterRole: configsvr\nreplication:\n${s}replSetName: ${REPLNAME}" >> ${CONFIG_FILE_NAME}
  fi
  if [ "${CONFIG_TYPE}" = "shardsrv" ]
  then
    echo -e "sharding:\n${s}clusterRole: shardsvr\nreplication:\n${s}replSetName: ${REPLNAME}" >> ${CONFIG_FILE_NAME}
  fi
}

create_mongos_conf_file()
{
  echo -e "systemLog:\n${s}destination: file\n${s}logAppend: true\n${s}path: ${LOG_PATH}" > ${CONFIG_FILE_NAME}
  echo -e "net:\n${s}port: ${PORT}\n${s}bindIpAll: true\n" >> ${CONFIG_FILE_NAME}
  echo -e "sharding:\n${s}configDB: ${REPLNAME}/${CONFIG_SRVS}" >> ${CONFIG_FILE_NAME}
}

# parse input parameters
while getopts 'f:t:p:l:d:r:c:h' opt; do
  case "$opt" in
    f)
      CONFIG_FILE_NAME=${OPTARG}
      ;;
    t)
      CONFIG_TYPE=${OPTARG}
      ;;
    p)
      PORT=${OPTARG}
      ;;
    l)
      LOG_PATH=${OPTARG}
      ;;
    d)
      DB_PATH=${OPTARG}
      ;;
    r)
      REPLNAME=${OPTARG}
      ;;
    c)
      CONFIG_SRVS=${OPTARG}
      ;;
    ?|h)
      echo "Usage: $(basename $0) -f config_file_name -t type -p port -l log_path [-d db_path] [-r replname] [-c configs_servers]"
      exit 1
      ;;
    esac
done

if [ -z "${CONFIG_FILE_NAME}" ] || [ -z "${CONFIG_TYPE}" ] || [ -z "${PORT}" ] || [ -z "${LOG_PATH}" ]
then
  echo "Usage: $(basename $0) -t type -p port -l log_path [-d db_path] [-r replname] [-c configs_servers]"
  exit 1
fi

# create responding config file
case "$CONFIG_TYPE" in
  "configsrv")
    if [ -z "${DB_PATH}" ] || [ -z "${REPLNAME}" ]
    then
     echo "\"db_path\" and \"replsetname\" are required parameters for config server."
     exit 1
    fi
    create_conf_file ${CONFIG_FILE_NAME} ${CONFIG_TYPE} ${LOG_PATH} ${DB_PATH} ${REPLNAME}
    ;;
  "shardsrv")
     if [ -z "${DB_PATH}" ] || [ -z "${REPLNAME}" ]
     then
       echo "\"db_path\" and \"replsetname\" are required parameters for shard server."
       exit 1
     fi
     create_conf_file ${CONFIG_FILE_NAME} ${CONFIG_TYPE} ${LOG_PATH} ${DB_PATH} ${REPLNAME}
     ;;
  "routersrv")
     if [ -z "${CONFIG_SRVS}" ] || [ -z "${REPLNAME}" ]
     then
      echo "\"replsetname\" and \"config servers\" are required parameters for shard server. Here \"replsetname\" is the config server replname"
      exit 1
     fi
     create_mongos_conf_file ${CONFIG_FILE_NAME} ${LOG_PATH} ${REPLNAME} ${CONFIG_SRVS}
     ;;
esac
