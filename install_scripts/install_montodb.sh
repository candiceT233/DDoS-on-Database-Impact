#!/usr/bin/bash

set -x 
source env_var.sh

VERSION=x86_64-ubuntu2004-5.0.15
PACKAGE_NAME=mongodb-linux-$VERSION

MONGOD () {
# system dependencies
sudo apt-get install libcurl4 openssl liblzma5

# Downloads MongoDB Version 1.2.2 to the Home Dir
# Extracts it and moves the contents into the ~/install/mongodb folder
# Creates a symlink from ~/install/mongod to /usr/local/sbin
cd $DL_DIR/
# wget https://fastdl.mongodb.org/linux/$PACKAGE_NAME.tgz
tar -xf $DL_DIR/$PACKAGE_NAME.tgz

mkdir -p $MONGODB_PATH/
rm -rf $MONGODB_PATH
mv $DL_DIR/$PACKAGE_NAME $MONGODB_PATH
MONGODB_BIN=$MONGODB_PATH/bin
sudo ln -nfs $MONGODB_BIN/mongod /usr/local/sbin
[[ ":$PATH:" != *":${MONGODB_BIN}:"* ]] && PATH="${MONGODB_BIN}:${PATH}"
cd -

# Ensures the required folders exist for MongoDB to run properly
sudo mkdir -p $MONGODB_DATA #data/mongodb
sudo mkdir -p $MONGODB_LOGS #/usr/local/mongodb/logs

# Downloads the MongoDB init script to the /etc/init.d/ folder
# Renames it to mongodb and makes it executable
cd /etc/init.d/
# wget http://gist.github.com/raw/162954/f5d6434099b192f2da979a0356f4ec931189ad07/gistfile1.sh
# mv gistfile1.sh mongodb
sudo cp $SCRIPT_DIR/deploy_scripts/mongodb.sh mongodb
sudo chmod +x mongodb
cd -
# sudo apt install -y software-properties-common gnupg apt-transport-https ca-certificates
# sudo apt install -y mongodb
# wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -


# sudo apt update
# sudo apt install -y mongodb-org

# mongod --version


}



MONGOSH () {
# Download mongosh
MONGOSH_DEB=mongodb-mongosh_1.8.0_amd64.deb
cd $DL_DIR
# wget https://downloads.mongodb.com/compass/$MONGOSH_DEB
sudo dpkg -i $MONGOSH_DEB

cd -
}

if [ $# != 1 ]
then
	echo "Usage: $SCRIPTNAME [mongod|mongosh]"
	exit
fi

case "$1" in

	mongod) MONGOD
	       ;;

	mongosh) MONGOSH
	      ;;
	
	*) echo "unknown command"
	   exit
	   ;;
esac