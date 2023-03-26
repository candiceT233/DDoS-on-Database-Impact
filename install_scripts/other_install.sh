#!/bin/bash

# install stat tools
sudo apt install gawk sysstat cpustat memstat net-tools

# Install perf
sudo apt install linux-tools-common linux-tools-generic linux-tools-`uname -r`
echo "`perf --version`"