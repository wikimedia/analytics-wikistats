#!/bin/bash

ulimit -v 8000000

yyyymmdd=$(date +"%Y_%m_%d")
yyyymm=$(date +"%Y_%m")

log_file="/home/ezachte/wikistats_backup/logs/log_zip_out_$yyyymm.txt"
exec >> $log_file 2>&1 # send stdout/stderr to file

# dataset1001=dataset1001.wikimedia.org::pagecounts-ez/wikistats

if [ "$1" == "" ] ; then
  echo "Project code missing! Specify as 1st argument one of wb,wk,wm,wn,wp,wq,ws,wv,wx"
  exit
fi  

wikistats_data=$WIKISTATS_DATA
wikistats_backup=$WIKISTATS_BACKUP
data=$wikistats_data/dumps/out
backup=/dumps/wikistats_1 #backup=$wikistats_backup/dumps_out

rm $backup/out_$1.zip

if [ "$1" == "wm" ] ; then
  cd $data/out_$1
else
  cd $data/out_$1/EN
fi

echo 
date 
echo zip -q -r $backup/out_$1.zip *

zip -q -r $backup/out_$1.zip * -x *.zip
# 7z a $backup/out_$1.7z *
# 7z a -mx=9  $backup/out_$1.mx9.7z *

# April 2018 rsync now happens asynchronous by ops
#echo rsync -ipv4 -avv $out/zip_all/out_w*.zip $dataset1001
#rsync -ipv4 -avv $backup/out_w*.zip $dataset1001
