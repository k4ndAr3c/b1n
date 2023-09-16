#!/bin/bash
if [ "x$1" == x ] ; then echo "Usage: $0 <start|stop>" ; exit ; fi
if [ "$1" == "start" ] ; then
	systemctl restart containerd.service docker.service docker.socket
elif [ "$1" == "stop" ] ; then
	systemctl stop containerd.service docker.service docker.socket
else
	echo "Usage: $0 <start|stop>"
fi
