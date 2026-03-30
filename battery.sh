#!/usr/bin/env bash

bat=$(upower -e | grep BAT)
level=$(upower -i $bat|grep percentage|awk '{print $NF}'|sed 's/.$//g')
out=$(( 100 - level ))
gr='\033[92m'
red='\033[31m'
end='\033[0m'

for i in $(seq 1 $level); do
  echo -en "${gr}|"
done
for i in $(seq 1 $out); do
  echo -en "${red}|"
done
echo -e "${end}"
