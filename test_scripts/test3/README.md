# Database DDoS Attack Scripts
Start database, uses MHDDoS tool to attack IP:Port, then remove database.
These test are for showing machine behaviore trends for the 3 tests below.
Test setup:
```
TestDuration : 120 seconds 
Threads : 320
TimeAfterTest : 40 seconds 
```

Attack commands:
```
./mongodb_attacks.sh 2>&1 | tee mongodb_attacks.log
./beegfs_attacks.sh 2>&1 | tee beegfs_attacks.log
```

## BeeGFS Note
Tested combinations:
```
HELPERD_PORT=8006,MINECRAFT 
MGMTD_PORT=8008,MINECRAFT
```

## MongoDB Note
Tested combinations:
```
MONGOS_PORT=27017,MINECRAFT
```
