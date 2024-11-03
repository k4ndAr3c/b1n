#!/bin/bash

INTERFACE="enp37s0"
function command(){
	xte "str $1"
	sleep 0.5
	xte "key Return"
}
function ctrl(){
	xte "keydown Control_L" "key $1" "keyup Control_L"
}
function hide_guake(){
	xte "keydown Shift_L" "key Return" "key Return" "keyup Shift_L"
	sleep 0.5
}
function alt_tab(){
	xte "keydown Alt_L" "keydown Tab" "keyup Alt_L" "keyup Tab"
	sleep 0.5
}
function new_pane(){
	ctrl b ; xte "str %"
	sleep 1
}
function new_pane_h(){
	ctrl b ; xte "str \""
	sleep 1
}
function change_pane(){
	ctrl b ; xte "key l"
	sleep 0.5
}
function zoom_pane(){
	ctrl b ; xte "key z"
}
function launch_app(){
	xte "keydown Alt_L" "key F2" "keyup Alt_L"
	sleep 0.5
}
function change_desktop_right(){
	xte "keydown Alt_L" "keydown Control_L" "key Up" "keyup Alt_L" "keyup Control_L"
}
function change_desktop_left(){
	xte "keydown Alt_L" "keydown Control_L" "key Down" "keyup Alt_L" "keyup Control_L"
}
function launch_term(){
	launch_app
	#command "terminator -e tmux"
	#command "xfce4-terminal --maximize -e tmux"
	command "xfce4-terminal --maximize"
	sleep 2
}
function resize_pane_up(){
	xte "keydown Control_L" "key b" "key Up" "sleep 0.3" "keyup Control_L"
}
function resize_pane_down(){
	xte "keydown Control_L" "key b" "key Down" "sleep 0.3" "keyup Control_L"
}
function rename_pane(){
	ctrl b ; xte "str ," 
	xte "sleep 0.5"
	for i in {1..9} ; do xte "key BackSpace" ; done
	command "$1"
}

#IP=$(curl -s ifconfig.me/ip)
#IP=$(ip -4 addr show $INTERFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}' --color=none | grep -v 127.0.0.1)
