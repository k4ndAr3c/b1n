#!/bin/bash
echo -e '\n|HEAD :.' &&
curl -k -I $* &&
for i in GET POST PUT TRACE OPTIONS PATCH DELETE
do
echo -e '\n|'$i' :.' && curl -k -X $i $*
done
