#!/bin/bash
ulimit -v 2000000

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
# perl=/home/ezachte/wikistats/dammit.lt/perl # tests
logs=$dammit/logs 

input=/a/dammit.lt/pagecounts/merged # .test
output=/a/dammit.lt/pagecounts/merged # .test
temp=/a/dammit.lt/pagecounts/temp

yyyymm=$(date +"%Y_%m")
logfile=$logs/compact_monthly_$yyyymm.log 
logfile_summary=$logs/_summary_compact_monthly_jobs.log 

cd $perl

mode=-m    # specify -m for monthly combine of daily files, comment line for generating daily files
verbose=-v # comment for concise output
maxage=1   # process files for last .. months

echo Consolidate daily pagecount files into one monthly file for last $maxage completed months 
echo
nice perl DammitCompactHourlyOrDailyPageCountFiles.pl $mode $verbose -a $maxage -i $input -o $output -t $temp | tee -a $logfile | cat

#grep ">>" $logs/*.log
