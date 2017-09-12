#!/bin/sh -x 
# -x : trace each line in this file, toggle trace off/on with 'set +x/-x', avoid -x in echo statements (looks messy in log)

ulimit -v 8000000

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

yyyymmddhhnn=$(date +"%Y_%m_%d__%H_%M")

wikistats=$WIKISTATS_SCRIPTS
bash=$wikistats/dumps/bash

# file log_job reports on high level each invocation of perl step within count.sh / report.sh, plus run time 
# file log_steps reports detailed progress of each invocation of perl file within count.sh / report.sh 
# several 'core jobs' will log to same directory log_job_dir (with unique file name, which refers to bash file)
# each core job has own directory for logging detailed progress

wikistats_data=$WIKISTATS_DATA
log_job_dir=$wikistats_data/dumps/logs/core_jobs
log_steps_dir=$wikistats_data/dumps/logs/count_report_publish_$mode
mkdir -m 775 $log_job_dir   >/dev/null 2>&1
mkdir -m 775 $log_steps_dir >/dev/null 2>&1
log_job=$log_job_dir/log_count_report_publish_${mode}_$yyyymmddhhnn.txt
log_steps=$log_steps_dir/count_report_publish_${mode}_$yyyymmddhhnn.txt

cd $bash

{ set +x; } 2>/dev/null ; echo "\n\n==================================\nJob started at $(date +"%d/%m/%y %H:%M") UTC" >> $log_job ; set -x

while [ 1 = 1 ]
do

exec 1>> $log_job 2>&1 # send stdout/stderr to file

  { set +x; } 2>/dev/null ; echo "\n\n=== Phase COUNT ===" ; set -x

  if [ "$mode" = "wp" ] ; then  
    ./count.sh  wp $log_job >> $log_steps
  else
    ./count.sh  wb $log_job >> $log_steps
    ./count.sh  wk $log_job >> $log_steps
    ./count.sh  wn $log_job >> $log_steps
    ./count.sh  wn $log_job >> $log_steps 
    ./count.sh  wo $log_job >> $log_steps
    ./count.sh  wq $log_job >> $log_steps
    ./count.sh  ws $log_job >> $log_steps
    ./count.sh  wv $log_job >> $log_steps
    ./count.sh  wx $log_job >> $log_steps
  fi

  { set +x; } 2>/dev/null ; echo "\n\n=== Phase PUBLISH DRAFT REPORTS ===" ; set -x

# no argument 'final' -> publish reports in ../draft/.. for manual vetting

  # report.sh not yet updated to new folders
 
  # if [ "$mode" = "wp" ] ; then  
  # ./report.sh wb 10  $log_job | tee -a $log_steps | cat
  # else
  # ./report.sh wb 10  $log_job | tee -a $log_steps | cat
  # ./report.sh wk 10  $log_job | tee -a $log_steps | cat
  # ./report.sh wn 10  $log_job | tee -a $log_steps | cat
  # ./report.sh wo 10  $log_job | tee -a $log_steps | cat
  # ./report.sh wq 10  $log_job | tee -a $log_steps | cat
  # ./report.sh ws 10  $log_job | tee -a $log_steps | cat
  # ./report.sh wv 10  $log_job | tee -a $log_steps | cat
  # ./report.sh wx 10  $log_job | tee -a $log_steps | cat
  # fi

  if [ "$mode" = "wp" ] ; then  
    sleep=6
  else
    sleep=24
  fi
  { set +x; } 2>/dev/null ; echo -e "\n\nJob suspended for $sleep hours at $(date +"%d/%m/%y %H:%M") UTC" ; set -x
  sleep ${sleep}h
  { set +x; } 2>/dev/null ; echo "\n\n==============================\nJob resumed at $(date +"%d/%m/%y %H:%M") UTC" >> $log_job ; set -x

done

