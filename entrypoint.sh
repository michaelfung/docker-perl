#!/bin/bash
CMD=$1

# setup perl environment
#export PATH=/opt/perlbrew/bin:/opt/perlbrew/perls/perl-5.28.3/bin:$PATH

# source /app/devel.rc if exists
[ -f "/app/runtime.rc" ] && source /app/runtime.rc

exec $CMD ${@:2}
