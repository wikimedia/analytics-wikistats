#!/bin/bash
ulimit -v 4000000

wikistats=/a/wikistats_git
perl=$wikistats/perl
logs=$wikistats/logs
cd $perl

log=$logs/SquidCountArchive.log

echo "" > $log

nice perl SquidCountArchive.pl -d 2012/09/01-2012/09/30

echo "Ready" >> $log
echo "Ready"
