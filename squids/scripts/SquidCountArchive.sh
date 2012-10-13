#!/bin/bash

ulimit -v 4000000

workdir="/a/squid/stats/scripts"
log="$workdir/SquidCountArchiveSep.log"

script="$workdir/SquidCountArchive.pl"

echo "" > $log

nice perl $script -d 2012/09/01-2012/09/30

echo "Ready" >> $log
echo "Ready"
