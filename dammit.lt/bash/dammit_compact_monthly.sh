#!/bin/bash
ulimit -v 2000000

echo_() {
  echo "$1" | tee -a $logfile| cat
}

public=dataset1001.wikimedia.org::pagecounts-ez/merged/ ; echo public=$public # https://dumps.wikimedia.org/other/pagecounts-ez/merged/

scripts=$WIKISTATS_SCRIPTS/dammit.lt                    ; echo_ scripts=$scripts
data=$WIKISTATS_DATA/dammit                             ; echo_ data=$data
perl=$scripts/perl                                      ; echo_ perl=$perl
bash=$scripts/bash                                      ; echo_ bash=$bash
output=$data/pagecounts/merged                          ; echo_ output=$output
input=$data/pagecounts/merged                           ; echo_ input=$input 
output=$data/pagecounts/merged                          ; echo_ output=$output 
temp=$data/temp                                         ; echo_ temp=$temp

echo_

logs=$data/logs                                         ; echo_ logs=$logs
yyyymmdd=$(date +"%Y_%m_%d")
logfile=$logs/compact_daily_$yyyymmdd.log               ; echo_ logfile=$logfile
logfile_summary=$logs/_summary_compact_daily_jobs.log   ; echo_ logfile_summary=$logfile_summary
echo_

yyyymm=$(date +"%Y_%m")
logfile=$logs/compact_monthly_$yyyymm.log               ; echo logfile=$logfile
logfile_summary=$logs/_summary_compact_monthly_jobs.log ; echo logfile_summary=$logfile_summary 

cd $perl

mode=-m    # specify -m for monthly combine of daily files, comment line for generating daily files
verbose=-v # comment for concise output
maxage=2   # process files for last .. months

echo Consolidate daily pagecount files into one monthly file for last $maxage completed months 
echo

echo grab semaphore dammit_compact_monthly.semaphore
cmd="nice perl DammitCompactHourlyOrDailyPageCountFiles.pl $mode $verbose -a $maxage -i $input -o $output -t $temp | tee -a $logfile | cat"
flock -n -e $bash/dammit_compact_monthly.semaphore -c "$cmd" || { echo "Script is already running: lock on ../bash/dammit_compact_monthly.semaphore" ; exit 1 ; } >&2


#grep ">>" $logs/*.log
