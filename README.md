# DDoS-on-Database-Impact
Term Project for CS558 Advanced Computer Security at Illinois Tech.

## install_scripts
Script to install all databases.
```
cd install_scripts
./install_beegfs.sh  
./install_montodb.sh mongod
./install_montodb.sh mongosh
./install_redis.sh
```

## mongodb
Script to start and stop MongoDB server
```
cd mongodb
./mongodb.sh start
./mongodb.sh stop
```

## beegfs
Script to start and stop BeeGFS server and client
```
cd beegfs
./beegfs.sh start
./beegfs.sh stop
```

## redis/rocks_db
TODO: add a additional database for test

## tools
TODO: add Makefile for preparing test environment \
(TODO: add perf tool setup if intelPAT does not work)

## test_scripts
TODO: need to add test script



