#!/usr/bin/env bash

is_valid_ip () {
    if [[ $1 =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        # Additional check for valid octet ranges
        IFS='.' read -r -a octets <<< "$1"
        for octet in "${octets[@]}"; do
            [[ $octet -ge 0 && $octet -le 255 ]] || return 1
        done
        return 0
    fi
    return 1
}

rdns () {
    curl -m10 -fsSL "https://ip.thc.org/${1:?}?limit=${2}&f=${3}"
}

sub () {
    #[ $# -ne 1 ] && { echo >&2 "crt <domain-name>"; return 255; }
    curl -fsSL "https://crt.sh/?q=${1:?}&output=json" --compressed | jq -r '.[].common_name,.[].name_value' | ~/bin/anew | sed 's/^\*\.//g' | tr '[:upper:]' '[:lower:]'
    curl -fsSL "https://ip.thc.org/sb/${1:?}?l=${2}"
}

grab_all () {
	NextPage=$(curl -fsSL "https://ip.thc.org/sb/${1:?}?l=100"|sed 's/\x1b\[[0-9;]*m//g' |~/bin/anew "all_$1"|grep Next |awk -F"=" '{print $NF}'|sed 's/....$//g')
	echo $NextPage
	while sleep 5 ; do NextPage=$(curl -fsSL "https://ip.thc.org/{1:?}?p=$NextPage" |sed 's/\x1b\[[0-9;]*m//g' |~/bin/anew "all_$1" |grep Next |awk -F"=" '{print $NF}'|sed 's/....$//g') ; echo $NextPage ; done
}

if is_valid_ip "$1" ; then
	if [[ -z "$2" ]] ; then
		max=50
	else
		max="$2"
	fi
	echo "Search for $max websites for ${1:?}"
	rdns "$1" "$max" "$3"
else
	if [[ -z "$2" ]] ; then
		max=50
	elif [[ "$2" == *"all"* ]] ; then
		echo "Grabbing all subdomains for ${1:?}, this may take a while..."
		sub "$1" 100 |sed 's/\x1b\[[0-9;]*m//g' | ~/bin/anew "all_$1"
		grab_all "$1"
	else
		max="$2"
	fi
	echo "Search for $max subdomains of ${1:?}"
        sub "$1" "$max" #|sed 's/\x1b\[[0-9;]*m//g'
fi

