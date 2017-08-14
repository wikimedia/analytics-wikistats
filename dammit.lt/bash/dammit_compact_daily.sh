#!/bin/bash
ulimit -v 2000000

# c1()(set -o pipefail;"$@" | perl -pe 's/.*/\e[1;32m$&\e[0m/g') # colorize output green
# c2()(set -o pipefail;"$@" | perl -pe 's/.*/\e[1;33m$&\e[0m/g') # colorize output yellow

echo_() { 
  echo "$1" | tee -a $logfile| cat 
}

input=/mnt/data/xmldatadumps/public/other/pageviews     ; echo_ input=$input   # webstatscollector 3.0 (was pagecounts-raw for webstatscollector 1.0)
public=dataset1001.wikimedia.org::pagecounts-ez/merged/ ; echo_ public=$public # https://dumps.wikimedia.org/other/pagecounts-ez/merged/ 
echo_

scripts=$WIKISTATS_SCRIPTS/dammit.lt                    ; echo_ scripts=$scripts
data=$WIKISTATS_DATA/dammit                             ; echo_ data=$data  
perl=$scripts/perl                                      ; echo_ perl=$perl 
bash=$scripts/bash                                      ; echo_ bash=$bash
output=$data/pagecounts/merged                          ; echo_ output=$output
logs=$data/logs/compact_daily                           ; echo_ logs=$logs
temp=$data/temp                                         ; echo_ temp=$temp

yyyymmdd=$(date +"%Y_%m_%d")
logfile=$logs/compact_daily_$yyyymmdd.log               ; echo_ logfile=$logfile
logfile_summary=$logs/_summary_compact_daily_jobs.log   ; echo_ logfile_summary=$logfile_summary

# extra step, in case yesterdays job did not finish normally
echo_
date | tee -a $logfile | cat
echo_

# echo_ "rsync -arv --include=*.bz2 $output/* $public"
## -a archive mode, -r recursive, -v verbose, -O do not try to upd dir timestamp
#rsync -arv --include=*.bz2 $output/* $public | tee -a $logfile | cat
#exit

echo_ "Remove old temp files from $temp"
cd $temp
rm *sorted
rm *patched
echo_ 

cd $perl
maxage=21 # process files for last .. completed days (runs daily, so should have one day of work to do)
echo_ "Consolidate pagecount files into one daily file for last $maxage completed days"

# date > $bash/dammit_compact_daily.semaphore
# flock -n = non block lock
cmd="nice perl DammitCompactHourlyOrDailyPageCountFiles.pl $mode -a $maxage -i $input -o $output -t $temp | tee -a $logfile | cat"
echo_ "cmd:'$cmd'"
echo_
flock -n -e $bash/dammit_compact_daily.semaphore -c "$cmd" || { echo "Script is already running: lock on ../bash/dammit_compact_daily.semaphore" ; exit 1 ; } >&2

$bash/dammit_compact_monthly.sh # If dammit_compact_monthly.sh fails, we continue nonetheless, to get new daily files rsynced

echo_ "Publish new files\n"
rsync -arv -ipv4 --include=*.bz2 $output/* $public  | tee -a $logfile | cat


#grep ">>" $logs/*.log
