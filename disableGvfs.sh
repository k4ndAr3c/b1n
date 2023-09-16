cd /usr/share/dbus-1/services
for i in $(grep gvfs * |cut -f1 -d":"|sort -u) ; do sed -i 's/Exec/\#Exec/g' $i ; done
