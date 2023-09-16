#!/bin/bash
if [[ x"$1" == x ]] ; then NB=1 ; else NB=$1 ; fi
FILE=`ls -rt $HOME/IRCs/|grep -v url|tail -n $NB`
PATH2FILE=$HOME/IRCs/
cd $PATH2FILE
echo $FILE
cat $FILE | ccze -A
echo
FINALFILE=$(echo $FILE|awk '{print $NF}')
tail -F $FINALFILE | ccze -A
