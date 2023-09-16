#!/bin/bash
if [ "x$1" == "x" ] ; then echo "Usage: $0 <mountPoint>" ; exit ; fi
mount -t proc none $1/proc
mount --rbind /dev $1/dev
mount --make-rslave $1/dev
mount --rbind /sys $1/sys
mount --make-rslave $1/sys
chroot $1
