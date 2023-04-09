# DDoS-on-Database-Impact
Term Project for CS558 Advanced Computer Security at Illinois Tech.
The env_var.sh has most of the directory setup information. 
- All the /bin,/lib,/include of installed packages are stored in the `$HOME/install` directory. 
- All the downloaded files are stored in the `$HOME/download` directory.
- The github scripts are place in the `$HOME/script` directory.

## dependencies
- ssh should be setup between local host and remote test host
- remote test host should allow sudo command without password
- need mpssh from https://github.com/ndenev/mpssh

## install_scripts
Script to install all databases.
```
cd install_scripts
./install_beegfs.sh
./install_montodb.sh mongod
./install_montodb.sh mongosh
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
./beegfs.sh config
./beegfs.sh start
./beegfs.sh stop
```
* VERSION 7.3.3 tested working for client with Kernel 5.15, but not working with Kernel 5.19 due to failuer of building kernel module:
```
/opt/beegfs/src/client/client_module_7/build/../source/common/nodes/NodeConnPool.c:162:34: error: ‘struct task_struct’ has no member named ‘cpu’
  162 |    int numa = cpu_to_node(current->cpu);
```

## redis/rocks_db
TODO: add a additional database for test

## tools
#### PAT
For measuring system performance (e.g. CPU, memory, and netwrok utilization).
#### MHDDoS
For generating DDOS attacks on started database. 

## test_scripts
Testscripts added for MongoDB and BeeGFS. \
(TODO: may add 3rd database test).
```
cd test_scripts
./beegfs_attack.sh  
./mongodb_attack.sh
```

## TODO
- Do L7 tests if can setup
- Vary threads number
- Vary test length



