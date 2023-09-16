#!/bin/bash
if [ "$1" == "n" ];
then
    FILE=`ssh n3wb "ls -rt /root/IRCs | grep -v urls | tail -n1"`
    scp n3wb:/root/IRCs/$FILE /tmp/
elif [ "$1" == "k" ];
then
    FILE=`ssh kata "ls -rt /root/IRCs | grep -v urls | tail -n1"`
    scp kata:/root/IRCs/$FILE /tmp/
elif [ "$1" == "y" ];
then
    FILE=`ssh y0lo "ls -rt /root/IRCs | grep -v urls | tail -n1"`
    scp y0lo:/root/IRCs/$FILE /tmp/
else
    echo "Usage: $0 <n|k|y>"
    exit
fi
echo $FILE
scp -P8022 /tmp/$FILE u0_a219@10.42.1.224:~/IrC
