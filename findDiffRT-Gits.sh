#!/bin/bash

if [ "x$1" == x ] ;then echo "Use: $0 <find|cp> <rt|p17>" ;fi
if [ "$1" == "find" ] 
then
    echo "### ==> format /foo/bar <== ###" > /root/tmpToCP
    if [ "$2" == "rt" ] ; then
        mount.nfs -v 10.42.1.100:/media/RT-FILES /mnt/RT-FILES
    elif [ "$2" == "p17" ] ; then
        mount.nfs -v 10.42.1.39:/mnt/oth3r /mnt/RT-FILES
    else
        echo "Usage $0 <find|cp> <rt|p17>"
        exit
    fi
    cd /EXT4/GITs/ && find . -maxdepth 2 -type d -print |sort -u > /tmp/lGITs
    cd /mnt/RT-FILES/GITs && find . -maxdepth 2 -type d -print |sort -u > /tmp/rGITs 
    diff /tmp/lGITs /tmp/rGITs | grep '<' >> /root/tmpToCP
    vim /root/tmpToCP
elif [ "$1" == "cp" ]
then
### ==> format /foo/bar <== ###
for toCp in `cat /root/tmpToCP | grep -v "#"`
    do DIR=`cut -f2 -d'/' <<< $toCp`
        echo "toCp:" $toCp ; echo "dir:" $DIR
        cp -Rv /EXT4/GITs$toCp /mnt/RT-FILES/GITs/$DIR
done
umount /mnt/RT-FILES
rm /root/tmpToCP
fi
