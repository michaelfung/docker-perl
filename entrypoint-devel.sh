#!/bin/bash
CMD=$1

echo "Entrypoint for development"

# setup environment
# export FOO=BAR

exec $CMD ${@:2}
