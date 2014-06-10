#!/bin/bash
ulimit -v 2000000

# c1()(set -o pipefail;"$@" | perl -pe 's/.*/\e[1;32m$&\e[0m/g') # colorize output green
# c2()(set -o pipefail;"$@" | perl -pe 's/.*/\e[1;33m$&\e[0m/g') # colorize output yellow
echo_() { 
echo "$1" | tee -a $logfile| cat 
}

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

# extra step, in case yesterdays job did not finish normally
date | tee -a $logfile | cat
echo_ "rsync -arv --include=*.bz2 $output/* $dataset1001"
# -a archive mode, -r recursive, -v verbose, -O do not try to upd dir timestamp
rsync -arv --include=*.bz2 $output/* $dataset1001 | tee -a $logfile | cat

cd $perl

maxage=14 # process files for last .. completed days (runs daily, so should have one day of work to do)

echo_ "Consolidate pagecount files into one daily file for last $maxage completed days\n"
# date > $bash/dsh/dammit_compact_daily.semaphoreammit_compact_daily.semaphore
# flock -n = non block lock
cmd="nice perl DammitCompactHourlyOrDailyPageCountFiles.pl $mode -a $maxage -i $input -o $output -t $temp | tee -a $logfile | cat"
flock -n -e $bash/dammit_compact_daily.semaphore -c "$cmd" || { echo "Script is already running: lock on ../bash/dammit_compact_daily.semaphore" ; exit 1 ; } >&2

"$bash"/dammit_compact_monthly.sh # If dammit_compact_monthly.sh fails, we
# continue nonetheless, to get new daily files rsynced

echo_ "Publish new files\n"
rsync -arv --include=*.bz2 $output/* $dataset1001  | tee -a $logfile | cat


#grep ">>" $logs/*.log
