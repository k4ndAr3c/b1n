#!/bin/bash
if [ "x$1" == "x" ]
	then
		echo "[+] Use msfhandler <port>"
		exit
fi
echo "use exploit/multi/handler" > /tmp/handler.rc && 
echo "set LHOST 0.0.0.0" >> /tmp/handler.rc && 
echo "set LPORT "$1 >> /tmp/handler.rc && 
echo "set ExitOnSession false" >> /tmp/handler.rc && 
echo "exploit -j" >> /tmp/handler.rc && 
msfconsole -r /tmp/handler.rc
