#!/bin/bash
keypress() {
    echo -n "Hit any key to continue..."
    read key -n1 -e -r 2> /dev/null
    if [ "$key" == "n" ]; then
    	exit
    else
    	echo
    fi
}

clear
echo "System Upgrade Script"
echo "--------------------------------------------------------------------------------"
echo
echo -n -e "portage sync ? ([y]/n) "
read key -n1 -e -r 2> /dev/null
if [ "$key" == "n" ]; then
    echo
else
    echo "Portage Sync"
    emerge --sync
fi

echo
echo "Complete system upgrade (emerge --update --deep --newuse world)"
keypress
START=`date`
time emerge --update --deep --newuse world -vt
STOP=`date`
echo "Start : "$START
echo "End   : "$STOP

echo
echo "Configuration files upgrade (etc-update)"
keypress
etc-update

echo
echo "Dependencies Clean (emerge --depclean)"
keypress
time emerge --depclean

echo
echo "Dependencies Check and Rebuild (revdep-rebuild)"
keypress
time revdep-rebuild

echo
echo "Dependencies Rebuild (@preserved-rebuild)"
keypress
time emerge @preserved-rebuild

echo
echo
echo
echo "--------------------------------------------------------------------------------"
echo "                      System Upgrade Completed"
echo "--------------------------------------------------------------------------------"
echo
echo
