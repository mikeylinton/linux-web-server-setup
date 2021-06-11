#!/bin/bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
        echo "Not running as root"
        exit
fi
cd /usr/local/src
wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
tar xzf noip-duc-linux.tar.gz
cd no-ip-*
make
make install
/usr/local/bin/noip2
