# Database DDoS Attack Scripts
Start database, uses MHDDoS tool to attack IP:Port, then remove database.
These tests mainly focus on stress testing the different ports.
Test setup:
```
TestDuration : 300 seconds 
Threads : 640
TimeAfterTest : 60 seconds 
```

Attack commands:
```
./mongodb_attacks.sh 2>&1 | tee mongodb_attacks.log
./beegfs_attacks.sh 2>&1 | tee beegfs_attacks.log
```

## BeeGFS Note
Tested combinations:
```
STORAGE_PORT=8003,TCP 
STORAGE_PORT=8003,MINECRAFT 
CLIENT_PORT=8004,UDP 
HELPERD_PORT=8006,MINECRAFT 
MGMTD_PORT=8008,TCP 
MGMTD_PORT=8008,MINECRAFT
```

## MongoDB Note
Tested combinations:
```
MONGOD_PORT=57040,TCP 
MONGOD_PORT=57040,MINECRAFT 
MG_SHARD_PORT=37017,MINECRAFT 
MONGOS_PORT=27017,MINECRAFT
```

## Future
- Try setup L7 attacks
