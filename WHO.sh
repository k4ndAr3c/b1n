#!/bin/bash

if [[ -d ~/ip-blacklist-main ]] ; then
	blip=$(grep -r $1 ~/ip-blacklist-main)
	if [[ -z "$blip" ]] ; then
		echo "$1 not found in blacklist"
	else
		echo "BLACKLISTED IP: $blip"
	fi
fi
echo "-----------------"
curl -s "https://api.proxynova.com/v1/geolocation/bulk?ip=$1" | jq
echo "-----------------"
~/bin/scrape_rapiddns.py $1 || curl -s "https://api.hackertarget.com/reverseiplookup/?q=$1" | column -c "$(tput cols)" -x
echo "-----------------"
rDNS -t $1
echo "-----------------"
ripdc.sh -t $1
echo "-----------------"
curl -s "http://ipinfo.io/$1"
echo "-----------------"
nslookup $1 208.67.222.222
echo "-----------------"
dig -t ANY $1
echo "-----------------"
host -a $1 8.8.8.8
echo "-----------------"
dmitry $1
