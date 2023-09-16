#!/bin/bash
rm /etc/resolv.conf
for i in "nameserver 208.67.222.222" "nameserver 185.121.177.177" "nameserver 8.8.8.8" "nameserver 2620:0:ccc::2" "nameserver 2001:4860:4860::8888" "nameserver 2620:0:ccd::2" "options rotate" ; do echo $i >> /etc/resolv.conf ; done

