#!/bin/bash

# iptables/ip6tables wrappers (see below)
IP4T() { :; }
IP6T() { :; }
IP46T() {
    IP4T "$@"
    IP6T "$@"
}

saveRules() {
	if [[ "$do_IPv4" == true && "$do_IPv6" == true ]] ; then
		echo "[+]  Saving rules ipv46"
		iptables-save > /etc/iptables.rules.v4
        	ip6tables-save > /etc/iptables.rules.v6
	elif [[ "$do_IPv4" != true && "$do_IPv6" == true ]] ; then
		echo "[+]  Saving rules ipv6"
        	ip6tables-save > /etc/iptables.rules.v6
	elif [[ "$do_IPv4" == true && "$do_IPv6" != true ]] ; then
		echo "[+]  Saving rules ipv4"
		iptables-save > /etc/iptables.rules.v4
	fi	
}

usage() {
    cat <<EOT

Usage:
    ${0##*/} {-h|--help}
    ${0##*/} [-v] -4     Reinitialize IPv4 firewall ruleset
    ${0##*/} [-v] -6     Reinitialize IPv6 firewall ruleset
    ${0##*/} [-v] -46    Reinitialize both IPv4&IPv6 firewall rulesets

Options:
    -v|--verbose            Print what's being done

EOT
}

verbose=false
do_IPv4=false
do_IPv6=false
[ $# -eq 0 ] && set -- '--help'
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)      usage; exit 0;;
        -v|--verbose)   verbose=true;;
	-4)             do_IPv4=true;;
	-6)             do_IPv6=true;;
	-46|-64)    set -- "$@" -4 -6;;
        *)          echo "'$1': unknown option" >&2
                    usage >&2
                    exit 1
                    ;;
    esac
    shift
done

trap saveRules EXIT

$do_IPv4 && IP4T() { $verbose && echo "IP4T $*"; /sbin/iptables "$@" ; }
$do_IPv6 && IP6T() { $verbose && echo "IP6T $*"; /sbin/ip6tables "$@" ; }

# -------------------------------
# | reset the current rulesets: |
# -------------------------------
#    1) empty chains,
#    2) delete user-defined chains,
#    3) reset counters
for table in raw mangle filter nat; do
    IP4T -t $table -F
    IP4T -t $table -X
    IP4T -t $table -Z
done 2>/dev/null
for table in raw mangle filter; do
    IP6T -t $table -F
    IP6T -t $table -X
    IP6T -t $table -Z
done 2>/dev/null
#IP46T -F
IP46T -P INPUT ACCEPT
IP46T -P OUTPUT ACCEPT
IP46T -P FORWARD ACCEPT

# Disable processing of any RH0 packet
# Which could allow a ping-pong of packets (TODO: other dangerous headers?)
#IP6T  -A INPUT   -m rt --rt-type 0 -j DROP

# Drop INVALID packets ASAP, this will save some resources and
# they'll eventually be dropped by the kernel anyway
IP46T -A INPUT -m conntrack --ctstate INVALID -j DROP
#IP6T -A INPUT -p icmpv6 -j ACCEPT
#IP6T -A OUTPUT -p icmpv6 -j ACCEPT

# Don't filter anything from the loopback interface
IP46T -A INPUT -i lo -j ACCEPT
IP6T -A OUTPUT -o lo -j ACCEPT
IP6T -A INPUT -i eth0 -j ACCEPT
IP6T -A INPUT -i wlan1 -j ACCEPT
IP6T -A OUTPUT -o wlan1 -j ACCEPT
IP6T -A OUTPUT -o eth0 -j ACCEPT

## very basic ICMP handling
#IP46T -N INPUT-ICMP
#IP4T  -A INPUT-ICMP -p icmp -m conntrack --ctstate RELATED -j ACCEPT
#IP4T  -A INPUT-ICMP -p icmp --icmp-type echo-request -j ACCEPT
## TODO: follow rfc4890
#IP6T -N INPUT-ICMP
#IP6T  -A INPUT-ICMP -p icmpv6 -m conntrack --ctstate RELATED -j ACCEPT
#IP6T  -A INPUT-ICMP -p icmpv6 --icmpv6-type echo-request -j ACCEPT
#IP6T  -A INPUT-ICMP -p icmpv6 --icmpv6-type router-advertisement -j ACCEPT
#IP6T  -A INPUT-ICMP -p icmpv6 --icmpv6-type neighbour-advertisement -j ACCEPT
#IP6T  -A INPUT-ICMP -p icmpv6 --icmpv6-type neighbour-solicitation -j ACCEPT
##
### use the newly created chain!
##IP4T  -A INPUT -p icmp -j INPUT-ICMP
#IP6T  -A INPUT -p icmpv6 -j INPUT-ICMP

# accept ssh connections!
#IP46T -A INPUT -p tcp --dport 22 -j ACCEPT

IP4T -t nat -A POSTROUTING -o wlan1 -j MASQUERADE
#iptables -A INPUT -i wlan1 -m conntrack --ctstate INVALID -j DROP
#iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
IP6T -A FORWARD -p icmpv6 -i eth0 -o wlan1 -j ACCEPT
IP6T -A FORWARD -p icmpv6 -i wlan1 -o eth0 -j ACCEPT
IP46T -A FORWARD -i wlan1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
IP46T -A FORWARD -i eth0 -o wlan1 -j ACCEPT
