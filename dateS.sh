#!/bin/bash
if [ "x$1" == "x" ]
then
    echo "[*] Prints dates backwards until x days"
    echo "[-] Usage: $0 <nb of days> <en|en2|fr>"
    exit
fi
a=$(($1 / 365))
echo "[+] $1 days ~~ $a year(s)"
for day in `seq 1 $1`
do 
    if [ "$2" == "en" ]
    then
        date -d "now - $day days" +"%Y/%-m/%-d"
    elif [ "$2" == "en2" ]
    then
        date -d "now - $day days" +"%-m/%-d/%Y"
    elif [ "$2" == "fr" ]
    then
        date -d "now - $day days" +"%d/%-m/%-Y"
    else
        echo "[-] Usage: $0 <nb of days> <en|fr>"
        exit
    fi
done
