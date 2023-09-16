#!/bin/bash

vboxmanage list hdds |grep Location
read -p "disk ? " DISK
vboxmanage modifymedium disk $DISK --compact
