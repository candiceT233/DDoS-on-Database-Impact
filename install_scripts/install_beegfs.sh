#!/bin/bash

source env_var.sh

VERSION=7.3.3


COMMON=beegfs-common_${VERSION}_amd64
MGMTD=beegfs-mgmtd_${VERSION}_amd64
META=beegfs-meta_${VERSION}_amd64
STORAGE=beegfs-storage_${VERSION}_amd64
CLIENT=beegfs-client_${VERSION}_all
HELPERD=beegfs-helperd_${VERSION}_amd64
UTILS=beegfs-utils_${VERSION}_amd64
ADMON=beegfs-mon_${VERSION}_amd64 # admon service (optional)

URL_PREFIX=https://www.beegfs.io/release/beegfs_7.3.3/dists/jammy/amd64

COMPONENTS=( $COMMON $MGMTD $META $STORAGE $CLIENT $HELPERD $UTILS )

install_components () {

    # sudo apt-get install beegfs-mgmtd                               # management service
    # sudo apt-get install beegfs-meta libbeegfs-ib                   # metadata service; libbeegfs-ib is only required for RDMA
    # sudo apt-get install beegfs-storage libbeegfs-ib                # storage service; libbeegfs-ib is only required for RDMA
    # sudo apt-get install beegfs-client beegfs-helperd beegfs-utils  # client and command-line utils
    # sudo apt-get install beegfs-admon                               # admon service (optional)

    set -x

    cd $DL_DIR
    rm -rf beegfs_packages
    mkdir beegfs_packages
    cd beegfs_packages

    for C in ${COMPONENTS[@]}
    do
        if [ ! -f "$C.deb" ]; then
            echo "downloading $C.deb"
            wget $URL_PREFIX/$C.deb
        fi
        
        sudo dpkg -i $C.deb
    done

    set +x
}


install_components

