#! /bin/bash -x 
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

# this job collect counts and generates reports for all wikis per project, either Wikipedia project or all other projects
# thus two jobs can run simultaneously 'count_report_publish.sh wp' and 'count_report_publish.sh nonwp' 
# follow progress on https://stats.wikimedia.org/WikiCountsJobProgress[Current].html ([Current] being most verbose)
# which is generated every 5 or 15 minutes by /home/ezachte/wikistats/dumps/bash/progress_wikistats.sh 
# vet draft results and publish final version with '/home/ezachte/wikistats/dumps/bash/report_all.sh final'


# announce script name/arguments and (file name compatible) start time
{ set +x; } 2>/dev/null ;
me=`basename "$0"` ; args=${@} ; yyyymmddhhnn=$(date +"%Y_%m_%d__%H_%M") ; job="## $yyyymmddhhnn Job:$me args='$args' ##" ;
echo -e "$job\n" ; # repeated after exec to reroute log
set -x

ulimit -v 10000000

# cycle all Wikipedia wikis or all wikis for non-Wikipedia projects, collect counts, generate and publish draft reports
#
# why 'draft' reports?
# many years ago, the process was fully automated, then a mishap occurred that made all counts far too low
# as this process always regenerates all reports for all historic months the last month wasn't detected as outlier
# instead some people assumed this was on purpose and all previous cycles had been totally wrong
# without asking me, an alarmistic article was submitted to the German equivalent of the Signpost  
# hence since then there is always a manual vetting phase before publishing the final stats 
# (add command line option 'final' to report.sh, as is done in report_all.sh)

{ set +x; } 2>/dev/null
if [ "$#" -ne 1 ] ; then echo "1 argument required, $# provided -> abort" ; exit 1 ; fi
if [ "$1" != "wp" ] && [ "$1" != "nonwp" ] ; then echo "invalid argument \$1: '$1', specify 'wp' or (for all other projects) 'nonwp' -> abort" ; exit 1 ; fi
mode=$1
if [ "$mode" = "nonwp" ] ; then mode="non_wp" ; fi # better read for file names 
if [ "$mode" = "wp" ] ; then  
  echo run in mode "'wp' = 'Wikipedia'"
else
  echo run in mode "'nonwp' = 'wb wk wn wo wq ws wv wx' = all non wikipedia projects"
fi
set -x

wikistats=$WIKISTATS_SCRIPTS
bash=$wikistats/dumps/bash

# file log_job reports on high level each invocation of perl step within count.sh / report.sh, plus run time 
# file log_details reports detailed progress of each invocation of perl file within count.sh / report.sh 
# several 'core jobs' will log to same directory dir_logs_job (with unique file name, which refers to bash file)
# each core job has own directory for logging detailed progress

wikistats_data=$WIKISTATS_DATA

#dir_logs_job=$wikistats_data/dumps/logs/core_jobs
#dir_logs_details=$wikistats_data/dumps/logs/count_report_publish_$mode
#mkdir -m 775 $dir_logs_job   >/dev/null 2>&1
#mkdir -m 775 $dir_logs_details >/dev/null 2>&1
#log_job=$dir_logs_job/log_count_report_publish_${mode}_$yyyymmddhhnn.txt
#log_details=$dir_logs_details/count_report_publish_${mode}_$yyyymmddhhnn.txt

dir_logs=$wikistats_data/dumps/logs/count_report_publish_$mode
mkdir -m 775 $dir_logs >/dev/null 2>&1
log_file=$dir_logs/count_report_publish_${mode}_$yyyymmddhhnn.txt

cd $bash

{ set +x; } 2>/dev/null ; echo -e "\n\n==================================\nJob started at $(date +"%d/%m/%y %H:%M") UTC" >> $log_job ; set -x

{ set +x; } 2>/dev/null ; 
echo -e "\nsend log to $log_file"

exec >> $log_file 2>&1 # send stdout/stderr to file
echo -e "$job\n" ; # repeated after exec to reroute log

echo -e "\nwhile forever do ...\n" 

while [ 1 = 1 ]
do

set -x
{ set +x; } 2>/dev/null ; echo -e "$job\n" ; set -x

  { set +x; } 2>/dev/null ; echo -e "\n=== Phase COUNT ===\n" ; set -x

# if [ "$mode" = "wp" ] ; then  
#   ./count.sh  wp $log_job >> $log_details
# else
#   ./count.sh  wb $log_job >> $log_details
#   ./count.sh  wk $log_job >> $log_details
#   ./count.sh  wn $log_job >> $log_details
#   ./count.sh  wn $log_job >> $log_details 
#   ./count.sh  wo $log_job >> $log_details
#   ./count.sh  wq $log_job >> $log_details
#   ./count.sh  ws $log_job >> $log_details
#   ./count.sh  wv $log_job >> $log_details
#   ./count.sh  wx $log_job >> $log_details
# fi

# if [ "$mode" = "wp" ] ; then  
#   ./count.sh  wp $log_job 
# else
#   ./count.sh  wb $log_job 
#   ./count.sh  wk $log_job 
#   ./count.sh  wn $log_job 
#   ./count.sh  wn $log_job  
#   ./count.sh  wo $log_job 
#   ./count.sh  wq $log_job 
#   ./count.sh  ws $log_job 
#   ./count.sh  wv $log_job 
#   ./count.sh  wx $log_job 
# fi

  if [ "$mode" = "wp" ] ; then  
    ./count.sh  wp  
  else
    ./count.sh  wb  
    ./count.sh  wk  
    ./count.sh  wn  
    ./count.sh  wn   
    ./count.sh  wo  
    ./count.sh  wq  
    ./count.sh  ws  
    ./count.sh  wv  
    ./count.sh  wx  
  fi

  { set +x; } 2>/dev/null ; echo -e "\n=== Phase PUBLISH DRAFT REPORTS ===\n" ; set -x

# no argument 'final' -> publish reports in ../draft/.. for manual vetting

  # report.sh not yet updated to new folders
 
  # if [ "$mode" = "wp" ] ; then  
  # ./report.sh wb 10  $log_job | tee -a $log_details | cat
  # else
  # ./report.sh wb 10  $log_job | tee -a $log_details | cat
  # ./report.sh wk 10  $log_job | tee -a $log_details | cat
  # ./report.sh wn 10  $log_job | tee -a $log_details | cat
  # ./report.sh wo 10  $log_job | tee -a $log_details | cat
  # ./report.sh wq 10  $log_job | tee -a $log_details | cat
  # ./report.sh ws 10  $log_job | tee -a $log_details | cat
  # ./report.sh wv 10  $log_job | tee -a $log_details | cat
  # ./report.sh wx 10  $log_job | tee -a $log_details | cat
  # fi

  { set +x; } 2>/dev/null ; echo -e "\n=== Phase SLEEP BEFORE NEXT ITERATION ===\n" ; 
  if [ "$mode" = "wp" ] ; then  
    hours=6
  else
    hours=24
  fi

  echo -e "\n\nJob suspended for $sleep hours at $(date +"%d/%m/%y %H:%M") UTC" 
  set -x
  sleep ${hours}h
  { set +x; } 2>/dev/null ; 
  echo "\n\n==============================\nJob resumed at $(date +"%d/%m/%y %H:%M") UTC" 
  set -x

done

