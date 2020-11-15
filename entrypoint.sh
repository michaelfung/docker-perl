#!/bin/bash
CMD=$1

# setup perl environment
#export PATH=/opt/perlbrew/bin:/opt/perlbrew/perls/perl-5.28.3/bin:$PATH

exec $CMD ${@:2}
