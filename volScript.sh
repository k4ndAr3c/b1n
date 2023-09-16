#!/bin/bash
# Script to collect information by utilizing volatility

####  Configurable Settings #############
if [ "x$1" == "x" ] ; then echo "Use: "$0" <mem.dump> <profile> (if you know)" ; exit ; fi
homeDir=`pwd`
memImage="$homeDir/"$1
locVolPy=$(whereis volatility| tr ' ' '\n' |grep bin)
volProfile=''
outputDir="$homeDir/outputVol"
dumpDir="$homeDir/dumpdir"
tempDir="$homeDir/temp"
pluginsDir=$(locate "volatility-plugins" | grep ".git" | head -n 1 | awk 'sub("....$", "")')
echo "[+]   Plugins dir found => "$pluginsDir

if [ ! -d $outputDir ]; then
    mkdir $outputDir
    mkdir $dumpDir
fi

# Find the profile for the image that is being analyzed and store it in volProfile
if [ "x$2" == "x" ]
	then $locVolPy -f $memImage imageinfo > $outputDir/imageInfo
	volProfile=`cat $outputDir/imageinfo | grep "Suggested Profile(s)" | awk '{print $4}' | sed 's/,//'`
else
	volProfile=$2
fi
echo "[+]   Profile is "$volProfile

for pluginCommand in `$locVolPy --plugins=$pluginsDir --profile=$volProfile -h |grep -A 222 "Supported Plugin Commands" |grep -v "Supported Plugin Commands" |awk '{print $1}'`
do
    echo -e "Running \033[92m"$pluginCommand"\033[0m and saving results to $outputDir/$pluginCommand"
    if [ "$pluginCommand" == "dumpfiles" ] 
    then $locVolPy -n -f $memImage --profile=$volProfile --output-file=$outputDir/$pluginCommand --dump-dir=$dumpDir $pluginCommand
    else
    $locVolPy --plugins=$pluginsDir -f $memImage --profile=$volProfile --output-file=$outputDir/$pluginCommand $pluginCommand 
    fi
    if [ $? != 0 ] ; then rm $outputDir/$pluginCommand ; $locVolPy --plugins=$pluginsDir -f $memImage --profile=$volProfile --output-file=$outputDir/$pluginCommand --dump-dir=$dumpDir $pluginCommand 
    fi
    if [ $? != 0 ] ; then rm $outputDir/$pluginCommand ; echo $pluginCommand "failed" >> $homeDir/err0rs ; echo -e "[-]  \033[31m"$pluginCommand"\033[0m failed."
    fi
done
