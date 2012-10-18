#!/bin/bash
ulimit -v 2000000

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
logs=$dammit/logs

data=/a/dammit.lt
pagecounts=$data/pagecounts

cd $perl


#='/a/dammit.lt/pagecounts'       # input dir
#o='/home/ezachte/wikistats/scans' # output dir
#f=20090424 # from date
#t=20091110 # till date
perl /a/dammit.lt/DammitFilterDailyPageCountsPerLanguage.pl 
