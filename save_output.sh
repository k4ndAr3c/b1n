#!/bin/bash
o=$(mktemp)
echo $o
bash -c "$1 | tee -a $o"
echo $o
