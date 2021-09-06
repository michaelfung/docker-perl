#!/bin/bash
CMD=$1

echo "Entrypoint for development"

# source /app/devel.rc if exists
[ -f "/app/devel.rc" ] && source /app/devel.rc

# setup environment
# export FOO=BAR

exec $CMD ${@:2}
