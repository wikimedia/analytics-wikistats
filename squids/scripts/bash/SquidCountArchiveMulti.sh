#!/bin/bash

ulimit -v 4000000

workdir="/a/squid/stats/scripts"
log="$workdir/SquidCountArchive.log"
script="$workdir/SquidCountArchive.pl"

#log="$workdir/SquidCountArchive-2011-10.log"
#nohup perl $script -d 2011/10/01-2011/10/31 > nohup.2011-10 &

#log="$workdir/SquidCountArchive-2011-11.log"
#nohup perl $script -d 2011/11/01-2011/11/30 > nohup.2011-11 &

#log="$workdir/SquidCountArchive-2011-12.log"
#nohup perl $script -d 2011/12/01-2011/12/31 > nohup.2011-12 &

log="$workdir/SquidCountArchive-2012-03.log"
nohup perl $script -d 2012/03/01-2012/03/31 > nohup.2012-03 &

echo "Ready"
