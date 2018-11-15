#!/bin/sh

yyyymmdd=$(date +"%Y_%m_%d")
yyyymm=$(date +"%Y_%m")

log_file="/home/ezachte/wikistats_backup/logs/log_backup_monthly_$yyyymm.txt"
exec >> $log_file 2>&1 # send stdout/stderr to file

wikistats_data=$WIKISTATS_DATA
wikistats_backup=$WIKISTATS_BACKUP

dt=$(date +[%Y-%m-%d][%H:%M])

cd $wikistats_data/dumps/csv/zip_all
zip $wikistats_backup/dumps_csv_full/csv_most_$dt.zip *.zip -x *edits.zip
zip $wikistats_backup/dumps_csv_full/csv_edits.zip *edits.zip 

# rsync -av $backup/*.zip  thorium.eqiad.wmnet::wikistats/backup/
