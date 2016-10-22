#!/bin/bash

ulimit -v 8000000

wikistats=/a/wikistats_git
csv=$wikistats/dumps/csv
zip_all=$csv/zip_all

dataset1001=dataset1001.wikimedia.org::pagecounts-ez/wikistats

if [ "$1" == "" ] ; then
  echo "Project code missing! Specify as 1st argument one of wb,wk,wn,wo,wp,wq,ws,wv,wx"
  exit
fi  

cd $csv/csv_$1

#echo "rebuild $zip_all/csv_$1_main.zip"
#rm     $zip_all/csv_$1_main.zip                                                                     # always skip:
#zip -q $zip_all/csv_$1_main.zip *.csv -x Creates* Edits* Revert* Categories* UserActivity*          *Temp* *Test* *Ploticus* *.zip

echo "rebuild $zip_all/csv_$1_creates.zip"
rm     $zip_all/csv_$1_creates.zip
zip -q $zip_all/csv_$1_creates.zip *.csv -i Creates* -x *Temp* *Test*

echo "rebuild $zip_all/csv_$1_edits.zip"
rm     $zip_all/csv_$1_edits.zip
zip -q $zip_all/csv_$1_edits.zip *.csv -i Edits* -x *PerMonthXX* *Temp* *Test*

echo "rebuild $zip_all/csv_$1_reverts.zip"
rm     $zip_all/csv_$1_reverts.zip
zip -q $zip_all/csv_$1_reverts.zip *.csv -i Revert* -x *Temp* *Test* 

echo "rebuild $zip_all/csv_$1_categories.zip"
rm     $zip_all/csv_$1_categories.zip
zip -q $zip_all/csv_$1_categories.zip *.csv -i Categories* -x *Temp* *Test*

echo "rebuild $zip_all/csv_$1_activity_trends.zip"
rm     $zip_all/csv_$1_activity_trends.zip
zip -q $zip_all/csv_$1_activity_trends.zip *.csv -i UserActivity* -x *Temp* *Test*

ls -l $zip_all/*.zip 

# obsolete ?
#echo "rebuild $zip_all/bz2_$1.zip"
#rm     $zip_all/bz2_$1.zip
#zip -q $zip_all/bz2_$1.zip *.bz2

echo "Publish new files\n"

echo "rsync -ipv4 -avv $zip_all/csv_*.zip $dataset1001"
rsync -ipv4 -avv $zip_all/csv_*.zip $dataset1001

