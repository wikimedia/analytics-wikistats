#!/bin/bash
ulimit -v 2000000

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
logs=$dammit/logs

data=/a/dammit.lt
pagecounts=$data/pagecounts

cd $perl

perl /a/dammit.lt/DammitSyncFiles.pl 
#perl /home/ezachte/wikistats/WikiCountsJobProgress.pl >> /a/dammit.lt/cron.txt
