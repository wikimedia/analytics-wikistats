#!/bin/bash
ulimit -v 2000000

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
perl=/home/ezachte/wikistats/dammit.lt/perl # tests
logs=$dammit/logs 

input=/mnt/data/xmldatadumps/public/other/pagecounts-raw
output=/a/dammit.lt/pagecounts/merged
temp=/a/dammit.lt/pagecounts/temp

yyyymmdd=$(date +"%Y_%m_%d")
logfile=$logs/compact_daily_$yyyymmdd.log 
logfile_summary=$logs/_summary_compact_daily_jobs.log 

cd $perl

# mode=-m # specify -m for monthly combine of daily files, comment line for generating daily files
maxage=105 # process files for last .. completed days
echo Consolidate pagecount files into one daily file for last $maxage completed days 
echo
nice perl DammitCompactHourlyOrDailyPageCountFiles.pl $mode -a $maxage -i $input -o $output -t $temp | tee -a $logfile | cat

#grep ">>" $logs/*.log
