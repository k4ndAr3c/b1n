#!/bin/bash
nb=$1
gynvael="https://www.youtube.com/user/GynvaelEN/videos"
meshx93="https://www.youtube.com/user/MeshX93/videos"
jacobpersi="https://www.youtube.com/channel/UCxMxlHWqP1P5g8iggTEG13Q/videos"
liveoverflow="https://www.youtube.com/channel/UClcE-kVhqyiHCcjYwcpfj9w/videos"
computerphile="https://www.youtube.com/user/Computerphile/videos"
murmusctf="https://www.youtube.com/channel/UCUB9vOGEUpw7IKJRoR4PK-A/videos"
hatt="https://vimeo.com/user67919562"
ippsec="https://www.youtube.com/channel/UCa6eh7gCkpPo5XXUDfygQQA/videos"
zapping="https://www.youtube.com/channel/UCoRnHlbVByoYV6st5kPxOIQ/"

function upDate(){
	pip2 install -U youtube-dl
	cd /STuff/DOWNS/IppSec
	youtube-dl -i -f18 $(cat url) --playlist-end=$nb
	cd /STuff/DOWNS/LiveOverflow
	youtube-dl -i -f18 $(cat url) --playlist-end=$nb
	cd /HEAvy/LiveOverflow2
	youtube-dl -i -f18 $(cat url) --playlist-end=$nb
	cd /STuff/DOWNS/GynvaelEN
	youtube-dl -i -f18 $(cat url) --playlist-end=$nb
	cd /HEAvy/ScienceEtonnante
	youtube-dl -i -f18 $(cat url) --playlist-end=$nb
	cd /STuff/DOWNS/Computerphile
	youtube-dl -i -f18 $(cat url) --playlist-end=$(($nb+4))
	cd /STuff/DOWNS/MurmusCTF
	youtube-dl -i -f18 $(cat url) --playlist-end=$nb
	cd /home/k4ndar3c/Downloads/canal+/ 
	youtube-dl -i -f18 $zapping --playlist-end=$(($nb+4))
	cd /STuff/DOWNS/MeshX93
	youtube-dl -i -f18 $(cat url) --playlist-end=$nb
	cd /STuff/DOWNS/JacobPersi
	youtube-dl -i -f18 $(cat url) --playlist-end=$nb
	cd /STuff/DOWNS/HackAllTheThings-vimeo
	youtube-dl -i -fhttp-720p $(cat url) --playlist-end=$nb
	for i in /STuff/GiTs/gynvael/stream-en /STuff/GiTs/gynvael/stream /STuff/GiTs/LiveOverflow/PwnAdventure3 /STuff/GiTs/LiveOverflow/liveoverflow_youtube /STuff/GiTs/gynvael/random-stuff ; do cd $i ; git pull ; done
	echo `date` "cron job" >> /var/log/UpdateVidzCron.log
	exit 0
	}
function isItConnect(){
	for i in $(seq 1 14) ; do 
		ping -c1 github.com
		if [ $? -ne 0 ] ; then sleep 120 ; #isItConnect
		else 
			upDate
		fi
	done
	exit 1
}
isItConnect
