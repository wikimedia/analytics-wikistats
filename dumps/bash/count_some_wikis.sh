#! /bin/bash -x 
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005  

# collect counts from dumps for one or more specific wikis (like count.sh does for entire project)
# adjust following three lines:
project=wp 
suffix=wiki # or wikibooks, wiktionary, etc
codes="atj" # codes separated by spaces, e.g. "ab cd ef"

ulimit -v 8000000
clear

start_time_job=`date +%s`

yyyymmddhhnn=$(date +"%Y_%m_%d__%H_%M")

php=/a/mediawiki/core/languages
dumps_public=/mnt/data/xmldatadumps/public

wikistats=$WIKISTATS_SCRIPTS
perl=$wikistats/dumps/perl

wikistats_data=$WIKISTATS_DATA
csv=$wikistats_data/dumps/csv

log_job_dir=$wikistats_data/dumps/logs/core_jobs
log_steps_dir=$wikistats_data/dumps/logs/count_one_wiki
mkdir -m 775 $log_job_dir   >/dev/null 2>&1
mkdir -m 775 $log_steps_dir >/dev/null 2>&1
log_job=$log_job_dir/log_count_some_wikis_$yyyymmddhhnn.txt

{ set +x; } 2>/dev/null ; echo -e "\n\n==================================\nProcess project code:$project suffix:$suffix codes:$codes" >> $log_job ; set -x

exec 1>> $log_job 2>&1 # send stdout/stderr to file

{ set +x; } 2>/dev/null ; echo -e "\n\n==================================\nJob started at $(date +"%d/%m/%y %H:%M") UTC" >> $log_job ; set -x

cd $perl

# Command line options:

# Optional:             (comment following lines if default should be used)
#
# edits_only=-e        # run all in 'edits only' (= from stub dump) # Aug 2013: full dump -> zero articles
  trace=-r             # trace resources
# force=-f             # force rerun even when dump for last month has already been processed
# bz2=-b               # dump extension, default: 7z
# reverts=-u 1         # uncomment to collect revert history only (-u from undo, -r was in use already)

# Required:
#
# -m                   # project (-m from 'mode'), e.g. '-m wp' project = Wikipedia
# -l                   # wiki    (-l from 'language', though some wiki names aren't about languages, like wikicommons)
# -i                   # input folder (dumps)
# -o                   # output folder (csv files)
# -d                   # dump date (either specific date or 'auto', which means last date for which dumps are available)
# -s                   # php languages files (-s from 'sources')

date=auto               
#date=$1
#date=20150430

for code in $codes ; # language codes for wikis to be processed
do
  start_time_step=`date +%s`
  wiki=$code$suffix
  log_step=$log_steps_dir/count_wiki_${wiki}_$yyyymmddhhnn.txt

{ set +x; } 2>/dev/null ; echo -e "\n\n----------------------------------\nStep started at $(date +"%d/%m/%y %H:%M") UTC" >> $log_job ; set -x
  perl $perl/WikiCounts.pl $trace $reverts $edits_only $force $bz2 -m $project -i $dumps_public/$wiki -o $csv/csv_$project/ -l $wiki -d $date -s $php >> $log_step

  { set +x; } 2>/dev/null ; 
echo -e "\n\n----------------------------------\nStep completed at $(date +"%d/%m/%y %H:%M") UTC" >> $log_job 
  date "+%Y-%m-%d %H:%M: count project: $project, wiki: $wiki" >> $log_job
  echo -e "\n\nRun time step: $(expr `date +%s` - $start_time_step) sec" >> $log_job
  set -x
done

{ set +x; } 2>/dev/null ; 
echo -e "\n\n==================================\nJob completed at $(date +"%d/%m/%y %H:%M") UTC" >> $log_job 
echo -e "\n\nRun time job: $(expr `date +%s` - $start_time_job) sec" >> $log_job

