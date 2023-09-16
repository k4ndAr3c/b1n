#!/bin/bash

function getCurrent() {
	cur=$(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | tr "\n" " ")
	echo -e "Current cpuperf are \033[93m$cur\033[0m." ; 
}

if [ "x$1" == "x" ] ; then getCurrent ; echo "Usage: $0 <performance|ondemand>" ; exit ; fi
p=$1
if [ "$p" == "performance" ] || [ "$p" == "ondemand" ] ; then 
	echo "Scaling cpufreq to: $p"
	cd /sys/devices/system/cpu
	echo $p | tee cpu*/cpufreq/scaling_governor
else
	getCurrent
	echo "Must be 'performance' or 'ondemand'." ; exit ; fi

