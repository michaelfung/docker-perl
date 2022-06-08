#!/bin/bash
CMD=$1

# source /app/devel.rc if exists
[ -f "/app/runtime.rc" ] && source /app/runtime.rc

exec $CMD ${@:2}
