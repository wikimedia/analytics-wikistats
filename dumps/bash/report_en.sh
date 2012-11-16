#!/bin/bash

ulimit -v 8000000
clear

perl=/a/wikistats/scripts/perl
bash=a/wikistats/scripts/bash
logs=/a/wikistats/logs
csv=/a/wikistats/csv
out=/a/wikistats/out

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

cd $bash
./sync_language_files.sh

./report_regions.sh 

perl $perl/WikiReports.pl -c -m $1 -l en -i $csv/csv_$1/ -o $out/out_$1 

./zip_out.sh $1
