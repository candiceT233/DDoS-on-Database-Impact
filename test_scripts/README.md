# Database DDoS Attack Scripts
Start database, uses MHDDoS tool to attack IP:Port, then remove database.

## BeeGFS Note
Available ports:
- tested
```
STORAGE_PORT=8003
META_PORT=8005
CLIENT_PORT=8004 #UDP
HELPERD_PORT=8006
MGMTD_PORT=8008
```
Currently tested working Layer4 methods:
`TCP UDP UDP TCP MCBOT MINECRAFT CPS `
TODO: 
- L4 test CONNECTION again
- Test untested ports (CLIENT_PORT, HELPERD_PORT, MGMTD_PORT)
- Try setup L7 attacks


## MongoDB Note
Available ports (tested):
```
MONGOD_PORT=57040
MG_SHARD_PORT=37017
MONGOS_PORT=27017
```
Currently tested working Layer4 methods:
`UDP TCP CONNECTIONS CPS MCBOT MINECRAFT `
TODO: 
- Try setup L7 attacks