#!/bin/bash
ulimit -v 2000000

c1()(set -o pipefail;"$@" | perl -pe 's/.*/\e[1;32m$&\e[0m/g') # colorize output green
c2()(set -o pipefail;"$@" | perl -pe 's/.*/\e[1;33m$&\e[0m/g') # colorize output yellow

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
perl=/home/ezachte/wikistats/dammit.lt/perl # tests
bash=$perl/../bash
logs=$dammit/logs 

input=/mnt/data/xmldatadumps/public/other/pagecounts-raw
output=/a/dammit.lt/pagecounts/merged
temp=/a/dammit.lt/pagecounts/temp
dataset1001=dataset1001.wikimedia.org::pagecounts-ez/merged/

yyyymmdd=$(date +"%Y_%m_%d")
logfile=$logs/compact_daily_$yyyymmdd.log 
logfile_summary=$logs/_summary_compact_daily_jobs.log 

cd $perl

# mode=-m # specify -m for monthly combine of daily files, comment line for generating daily files
maxage=14 # process files for last .. completed days (runs daily, so should have one day of work to do)

echo Consolidate pagecount files into one daily file for last $maxage completed days 
echo
# c1 perl DammitCompactHourlyOrDailyPageCountFiles.pl $mode -a $maxage -i $input -o $output -t $temp | tee -a $logfile | cat
# date > $bash/dsh/dammit_compact_daily.semaphoreammit_compact_daily.semaphore
# flock -n = non block lock
cmd="nice perl DammitCompactHourlyOrDailyPageCountFiles.pl $mode -a $maxage -i $input -o $output -t $temp | tee -a $logfile | cat"
flock -n -e $bash/dammit_compact_daily.semaphore -c "$cmd" || { echo "Script is already running: lock on ../bash/dammit_compact_daily.semaphore" ; exit 1 ; } >&2

echo Consolidate pagecount files for whole month into one monthly file - only finds work to do on first day of new month 
echo
# c1 $bash/dammit_compact_monthly.sh 
flock -n -e $bash/dammit_compact_monthly.semaphore -c "Run dammit_compact_daily.sh" || { echo "Script dammit_compact_daily.sh is already running: lock on ../bash/dammit_compact_daily.semaphore" ; exit 1 ; } >&2

cd $bash
./dammit_compact_monthly.sh 

echo Publish new files 
echo
# c2 rsync -arv --include=*.bz2 $output/* $dataset1001
     rsync -arv --include=*.bz2 $output/* $dataset1001


#grep ">>" $logs/*.log
