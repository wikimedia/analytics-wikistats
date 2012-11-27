#!/bin/bash
ulimit -v 4000000

wikistats=/a/wikistats_git
squids=$wikistats/squids
perl=$squids/perl
logs=$squids/logs
cd $perl

log=$logs/SquidCountArchive.log

# process one day for test, usually do full month 
nice perl SquidCountArchive.pl -d 2012/10/02-2012/10/02 -p | tee $log | cat 
