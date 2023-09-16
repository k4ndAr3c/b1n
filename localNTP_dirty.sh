#!/bin/bash

SshForAll () {
	for i in $(arp-scan -l |cut -f 1 |grep 10\.42 |grep -v \.100 |grep -v 1\.37)
	do
		echo $i
		ssh $i $@
		echo
	done
	ssh 10.42.2.1 $@
}

if [ -z "$1" ] ; then echo "[-] Usage: $0 <srv> <view|set>" ; exit 1 ; fi
if [ -z "$2" ] ; then echo "[-] Usage: $0 <srv> <view|set>" ; exit 1 ; fi

ping -q -c1 "$1"
if [ $? != 0 ] ; then echo "[-] Server Unreachable" ; exit 1 ; fi

echo "$srv"
d4te=$(ssh $1 date)
echo $d4te
echo

if [ "$2" == "view" ] ; then threadedSSH-paramiko.py "hostname ; date" ; date ; fi
if [ "$2" == "set" ] ; then threadedSSH-paramiko.py "hostname ; date --set='$d4te'" ; fi
