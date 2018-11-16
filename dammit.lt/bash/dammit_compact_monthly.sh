#! /bin/bash -x
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

ulimit -v 2000000

yyyymmdd=$(date +"%Y_%m_%d")
yyyymm=$(date +"%Y_%m")

merged=/srv/dumps/pagecounts-ez/merged
input=$merged                           
output=$merged                          

temp=$WIKISTATS_DATA/dammit/pagecounts/temp                             
logfile=$WIKISTATS_DATA/dammit/logs/compact_monthly/log_compact_monthly_$yyyymmdd.txt      
exec 1> $logfile 2>&1 # send stdout/stderr to file        

data=/srv/dumps/pagecounts-ez/merged/ 

scripts=$WIKISTATS_SCRIPTS/dammit.lt                    
perl=$scripts/perl                                      
bash=$scripts/bash                                      

cd $perl

mode=-m    # specify -m for monthly combine of daily files (just comment this line for combining hourly into daily files)
verbose=-v # comment for concise output
maxage=2   # process files for last .. months

echo -e "\nConsolidate daily pagecount files into one monthly file for last $maxage completed months\n" 
echo -e "Grab semaphore dammit_compact_monthly.semaphore\n" 

cmd="nice perl DammitCompactHourlyOrDailyPageCountFiles.pl $mode $verbose -a $maxage -i $input -o $output -t $temp | tee -a $logfile | cat"
flock -n -e $bash/dammit_compact_monthly.semaphore -c "$cmd" || { echo "Script is already running: lock on ../bash/dammit_compact_monthly.semaphore" ; exit 1 ; } >&2
