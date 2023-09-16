#!/bin/bash
if [ "x$1" == x ] ; then echo "Usage: $0 <start|stop>" ; exit ; fi
if [ "$1" == "start" ] ; then
	systemctl restart vboxautostart-service.service vboxballoonctrl-service.service vboxdrv.service vboxweb-service.service
elif [ "$1" == "stop" ] ; then
	systemctl stop vboxautostart-service.service vboxballoonctrl-service.service vboxdrv.service vboxweb-service.service
else
	echo "Usage: $0 <start|stop>"
fi
