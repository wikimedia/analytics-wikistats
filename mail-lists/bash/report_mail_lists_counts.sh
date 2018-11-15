#! /bin/bash -x 
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

# collect updates from mail archives 
# generate new html reports
# publish at https://stats.wikimedia.org/mail-lists/
# backup data to wikidata_backup
# copy backup to hdfs 

yyyymmdd=$(date +"%Y_%m_%d")
yyyymm=$(date +"%Y_%m")

wikistats=$WIKISTATS_SCRIPTS                                        
wikistats_data=$WIKISTATS_DATA                                      
wikistats_backup=$WIKISTATS_BACKUP                                      

logs=$wikistats_data/mail-lists/logs                                   
logfile_job=$logs/job/log_update_mail_archives_$yyyymmdd.txt          

exec 1> $logfile_job 2>&1 # send stdout/stderr to file

ulimit -v 8000000

logfile_collect=$logs/collect/log_collect_mail_archives_$yyyymmdd.txt  
logfile_report=$logs/report/log_report_mail_archives_$yyyymmdd.txt     

export http_proxy=http://webproxy.eqiad.wmnet:8080
export https_proxy=http://webproxy.eqiad.wmnet:8080                     
htdocs=thorium.eqiad.wmnet::stats.wikimedia.org/htdocs/            
hdfs_backup=/user/ezachte/wikistats_data/mail-lists/lists/             

perl=$wikistats/mail-lists/perl                                        
out=$wikistats_data/mail-lists/out                                     
lists=$wikistats_data/mail-lists/lists                                 
zipfile=mail-lists_$yyyymm.zip                                         
backup_folder=$wikistats_backup/mail-lists                             

{ set +x; } 2>/dev/null ; echo "\n=== Collect data and generate reports ===" ; set -x  

cd $perl
perl CollectMailArchives.pl > $logfile_collect 2>&1     # to do: replace hardcoded paths
perl ReportMailArchives.pl  > $logfile_report  2>&1     # to do: replace hardcoded paths

{ set +x; } 2>/dev/null ; echo "\n=== Publish output to public server ===" ; set -x

cd $out
rsync -a -r -v *.htm* $htdocs/mail-lists >> $logfile_job 2>&1 ; set -x

{ set +x; } 2>/dev/null ; echo "\n=== Zip data ===" ; set -x

cd $lists
zip -q $backup_folder/$zipfile * 
ls -l $backup_folder/$zipfile 

{ set +x; } 2>/dev/null ; echo "\n=== Copy zipped data to HDFS ===" ; set -x

cd $backup_folder
hdfs dfs -put -f -p $zipfile $hdfs_backup >> $logfile_job 2>&1
hdfs dfs -ls -R $hdfs_backup              >> $logfile_job 2>&1

