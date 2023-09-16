#!/bin/bash

if [ "x$2" == "x" ] ; then echo "Use: "$0" <mp4_file/yt_url> <dest.amv>" ; exit ; fi
echo "$1" | grep yout |grep -v grep
if [ $? -eq 1 ] ; then 
	ffmpeg -i "$1" -vcodec msmpeg4 -q:v 1 -s qqvga -r 16 -acodec wmav2 -ac 1 -ar 22050 /tmp/amv_convert.wmv
	amv-ffmpeg -i /tmp/amv_convert.wmv -f amv -r 16 -ac 1 -ar 22050 -qmin 3 -qmax 3 "$2"
else
	yt-dlp -f18 "${1}" -o /tmp/amv_convert.mp4
	ffmpeg -i /tmp/amv_convert.mp4 -vcodec msmpeg4 -q:v 1 -s qqvga -r 16 -acodec wmav2 -ac 1 -ar 22050 /tmp/amv_convert.wmv
	amv-ffmpeg -i /tmp/amv_convert.wmv -f amv -r 16 -ac 1 -ar 22050 -qmin 3 -qmax 3 "$2"
fi
rm /tmp/amv_convert.mp4 /tmp/amv_convert.wmv
echo "[+] Done ."
