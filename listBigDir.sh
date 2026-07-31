#!/usr/bin/env bash

PATTERN=""

# Parse optional pattern
if [[ "$1" == "-p" || "$1" == "--pattern" ]]; then
    PATTERN="$2"
    shift 2
fi

if [ $# -lt 2 ]; then
    echo "Usage: $0 [-p pattern] <directory> <command> [args...]" >&2
    exit 1
fi

DIR="$1"
shift

if [ ! -d "$DIR" ]; then
    echo "Error: $DIR is not a directory" >&2
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Error: No command provided" >&2
    exit 1
fi

CMD=("$@")

find "$DIR" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' f; do
    if [ -n "$PATTERN" ]; then
        if grep -qF "$PATTERN" "$f" 2>/dev/null; then
            "${CMD[@]}" "$f"
        fi
    else
        "${CMD[@]}" "$f"
    fi
done
