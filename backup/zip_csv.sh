#!/bin/bash -x
# script migrated to stat1005

ulimit -v 8000000

yyyymmdd=$(date +"%Y_%m_%d")
yyyymm=$(date +"%Y_%m")
yyyy=$(date +"%Y")
yyyyq=$(date +"%Y_%q%q")
 
backup=$WIKISTATS_BACKUP

log_file="$backup/logs/log_backup_csv_dumps_$yyyymmdd.txt"
exec >> $log_file 2>&1 # send stdout/stderr to file

data=$WIKISTATS_DATA
backup=$WIKISTATS_BACKUP
csv=$data/dumps/csv
zip=/srv/dumps/wikistats_1 # was zip=$backup/dumps_csv

# dataset1001=dataset1001.wikimedia.org::pagecounts-ez/wikistats

{ set +x; } 2>/dev/null 
if [ "$1" == "" ] ; then
  echo "Project code missing! Specify as 1st argument one of wb,wk,wn,wo,wp,wq,ws,wv,wx"
  exit
fi  
echo -e "\n";
set -x

cd $csv/csv_$1

{ set +x; } 2>/dev/null ; echo -e "\nrebuild $zip/csv_$1_main.zip\n" ; set -x
rm     $zip/csv_$1_main.zip 2>/dev/null                                                
zip -q $zip/csv_$1_main.zip *.csv -x Creates\* Edits\* Revert\* \*PageViews\* Timelines\* UserActivity\* \*Temp\* \*Test\* \*Ploticus\*

{ set +x; } 2>/dev/null ; echo -e "\nrebuild $zip/csv_$1_creates.zip\n" ; set -x
rm     $zip/csv_$1_creates.zip
zip -q $zip/csv_$1_creates.zip Creates*.csv -i Creates* -x \*Temp\* \*Test\*

{ set +x; } 2>/dev/null ; echo -e "\nrebuild $zip/csv_$1_edits_per_user.zip\n" ; set -x
rm     $zip/csv_$1_edits_per_user.zip
zip -q $zip/csv_$1_edits_per_user.zip   EditsPerUser*.csv -x EditsPerUserPerMonthPerNamespace\*  EditsBreakdownPerUserPerMonth\* \*Temp\* \*Test\*

{ set +x; } 2>/dev/null ; echo -e "\nrebuild $zip/csv_$1_edits_per_user_month_namespace.zip\n" ; set -x
rm     $zip/csv_$1_edits_per_user_month_namespace.zip
zip -q $zip/csv_$1_edits_per_user_month_namespace.zip   EditsPerUserPerMonthPerNamespace*.csv -x EditsBreakdownPerUserPerMonth\* \*Temp\* \*Test\*

{ set +x; } 2>/dev/null ; echo -e "\nrebuild $zip/csv_$1_reverts.zip\n" ; set -x
rm     $zip/csv_$1_reverts.zip
zip -q $zip/csv_$1_reverts.zip Revert*.csv -x \*Temp\* \*Test\* 

{ set +x; } 2>/dev/null ; echo -e "\nrebuild $zip/csv_$1_activity_trends.zip\n" ; set -x
rm     $zip/csv_$1_activity_trends.zip
zip -q $zip/csv_$1_activity_trends.zip UserActivity*.csv -x \*Temp* \*Test*

cd $zip
ls -l *.zip 

# April 2018, rsync now happens asynchronous by ops
# { set +x; } 2>/dev/null ; echo -e "\nPublish new files\n" ; set -x
# echo "rsync -ipv4 -avv $zip/csv_*.zip $dataset1001"
# rsync -ipv4 -avv $zip/csv_*.zip $dataset1001

