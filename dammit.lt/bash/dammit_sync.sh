#!/bin/bash
ulimit -v 2000000

# collect newewest projectcounts files (hourly page view stats per wiki), add to tar, and publish

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
logs=$dammit/logs

data=/a/dammit.lt
pagecounts=$data/pagecounts

cd $perl

perl DammitSyncProjectCounts.pl 
