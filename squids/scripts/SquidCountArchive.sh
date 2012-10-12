#!/bin/bash

ulimit -v 4000000

home="/a/ezachte"
log="$home/SquidCountArchiveLog.txt"
script="$home/SquidCountArchive.pl"

echo "" > $log

nice perl $script -d 2011/02/07-2011/02/11 
echo "Ready" >> $log
echo "Ready"
