#!/bin/bash

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
