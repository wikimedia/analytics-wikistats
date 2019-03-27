#!/bin/sh -x

yyyymmdd=$(date +"%Y_%m_%d")
yyyymm=$(date +"%Y_%m")
yyyy=$(date +"%Y")
yyyyq=$(date +"%Y_q%q")

log_file="/home/ezachte/wikistats_backup/logs/log_backup_squids_$yyyymmdd.txt"
exec >> $log_file 2>&1 # send stdout/stderr to file

wikistats_data=$WIKISTATS_DATA
wikistats_backup=$WIKISTATS_BACKUP

cd $wikistats_data/squids/reports
zip -T  $wikistats_backup/squids/reports/misc_$yyyyq.zip loads/* countries/* *
for yyyy in `seq 2018 2050` ; # update lower value yearly; relying on manual update prevents incomplete zip for previous year, on Jan 1
do
  zip -rT $wikistats_backup/squids/reports/reports_${yyyy}.zip $yyyy*
done

exit

cd $wikistats_data/squids/csv
zip -rT $wikistats_backup/squids/csv/csv_meta_etc_$yyyy.zip    excel* meta* load* uniques*
zip -T  $wikistats_backup/squids/csv/csv_aggregated_$yyyyq.zip *csv

for yyyy in `seq 2018 2050` ; # update lower value yearly; relying on manual update prevents incomplete zip for previous year, on Jan 1
do
  zip -rT $wikistats_backup/squids/csv/csv_${yyyy}_do_not_publish.zip $yyyy*
done


# rsync -av $backup/*.zip  thorium.eqiad.wmnet::wikistats/backup/
