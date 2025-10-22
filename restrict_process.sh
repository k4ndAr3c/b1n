#!/usr/bin/env bash

CGROUP_NAME="restricted_process"

while getopts 'n:p:m:c:' opt; do
    case "$opt" in
        n) CGROUP_NAME=$OPTARG;;
        p) PROCESS=$OPTARG;;
        m) MEMORY=$OPTARG;;
        c) CPU=$OPTARG;;
        *) fatal 'bad option';;
    esac
done

if [[ -z "$PROCESS" ]]; then
	echo "Usage: $0 -p <process_name> [-n <cgroup_name>] [-m <memory_limit>] [-c <cpu_limit>]"
	exit 1
fi

if [[ -z "$MEMORY" && -z "$CPU" ]]; then
	echo "At least one of -m <memory_limit> or -c <cpu_limit> must be specified."
	exit 1
fi

CGROUP_PATH="/sys/fs/cgroup/$CGROUP_NAME"
mkdir -p "$CGROUP_PATH"
pid=$(pgrep -f "$PROCESS" | head -n 1)

if [[ -z "$pid" ]]; then
	echo "Process '$PROCESS' not found."
	exit 1
fi

if [[ -n "$MEMORY" ]]; then
	echo "$MEMORY" > "$CGROUP_PATH/memory.max"
	echo "max mem $MEMORY has been set."
fi

if [[ -n "$CPU" ]]; then
	echo "$(($CPU*1000)) 100000" > "$CGROUP_PATH/cpu.max"
	echo "max cpu $(($CPU*1000)) 100000 has been set."
fi

echo "$pid" > "$CGROUP_PATH/cgroup.procs"
echo 1 > "$CGROUP_PATH/memory.oom.group"
echo "Process $PROCESS (PID: $pid) has been added to cgroup $CGROUP_NAME."
