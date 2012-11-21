#!/bin/bash

ulimit -v 8000000
clear

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
bash=$dumps/bash
logs=$dumps/logs
csv=$dumps/csv
out=$dumps/out

#abort_before=$2
#day_of_month=$(date +"%d")
#if [ $day_of_month -lt ${abort_before:=0} ]
#then	  
#  echo 
#  echo report_en.sh: day of month $day_of_month lt $abort_before - exit
#  exit
#fi

echo "\nStart report.sh $1" >> $logs/WikiCountsLogConcise.txt
echo "\nStart report.sh $1" >> $logs/report_en.sh.log

# date >> report.txt

$bash/sync_language_files.sh
$bash/report_regions.sh 

perl $perl/WikiReports.pl -c -m $1 -l en -i $csv/csv_$1/ -o $out/out_$1 

$bash/zip_out.sh $1
