#!/bin/bash

cd /boot
for i in initramfs-linux-fallback.img initramfs-linux.img vmlinuz-linux ; do
  cp $i $i.SVG
done
