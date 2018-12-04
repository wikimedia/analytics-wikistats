#! /bin/bash -x
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

ulimit -v 2000000

yyyymmdd=$(date +"%Y_%m_%d")

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA

logfile=$wikistats_data/dammit/logs/compact_daily/log_compact_daily_$yyyymmdd.txt
exec 1> $logfile 2>&1 # send stdout/stderr to file	
maxage=21

input=/mnt/data/xmldatadumps/public/other/pageviews     # webstatscollector 3.0 (was pagecounts-raw for webstatscollector 1.0)
public=/srv/dumps/pagecounts-ez/merged/ # https://dumps.wikimedia.org/other/pagecounts-ez/merged/ 

scripts=$WIKISTATS_SCRIPTS/dammit.lt               
data=$WIKISTATS_DATA/dammit       
perl=$scripts/perl           
bash=$scripts/bash                
output=$data/pagecounts/merged        
logs=$data/logs/compact_daily      
temp=$data/temp          

{ set +x; } 2>/dev/null ; echo -e "\n>> Start with rsync, in case yesterdays job did not finish normally <<\n" ; set -x

# -a archive mode, -r recursive, -v verbose, -O do not try to upd dir timestamp
#rsync -arm --stats --include=*.bz2 $output $public 
rsync -ar -ipv4 --stats --include=*.bz2 --exclude=*~ $output/* $public 

{ set +x; } 2>/dev/null ; echo -e "\n>> Remove old temp files *sorted/*patched from $temp <<\n" ; set -x

cd $temp
rm -f *sorted
rm -f *patched

{ set +x; } 2>/dev/null ; echo -e "\n>> Process files for last $maxage completed days (runs daily, so should have one day of work to do) <<\n" ; set -x

# date > $bash/dammit_compact_daily.semaphore
# flock -n = non block lock

cd $perl
cmd="nice perl DammitCompactHourlyOrDailyPageCountFiles.pl $mode -a $maxage -i $input -o $output -t $temp"

flock -n -e $bash/dammit_compact_daily.semaphore -c "$cmd" || { echo "Script is already running: lock on ../bash/dammit_compact_daily.semaphore" ; exit 1 ; } >&2

{ set +x; } 2>/dev/null ; echo -e ">> Invoke dammit_compact_monthly.sh, and see if monthly file should be generated <<\n" ; set -x
$bash/dammit_compact_monthly.sh 

{ set +x; } 2>/dev/null ; echo -e ">> Continue even if ../bash/dammit_compact_monthly.sh failed, to get new daily files rsynced <<" ; set -x
{ set +x; } 2>/dev/null ; echo -e ">> Publish new files <<\n" ; set -x

rsync -ar -ipv4 --include=*.bz2 --exclude=*~ $output/* $public  
