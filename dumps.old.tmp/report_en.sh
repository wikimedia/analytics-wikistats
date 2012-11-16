#!/bin/bash
abort_before=$2
day_of_month=$(date +"%d")
if [ $day_of_month -lt ${abort_before:=0} ]
then	  
  echo 
  echo report_en.sh: day of month $day_of_month lt $abort_before - exit
  exit
fi

echo "\nStart report.sh $1" >> WikiCountsLogConcise.txt
echo "\nStart report.sh $1" >> report.txt

date >> report.txt

./sync_language_files.sh

for x in en ;
do perl WikiReports.pl -m $1 -l $x -i /a/wikistats/csv_$1/ -o /a/out/out_$1 ;
done;

./report_regions.sh 

# perl WikiReports.pl -c -m $1 -l en -i /a/wikistats/csv_$1/ -o /a/out/out_$1 

./zip_out.sh $1

echo "Ready" >> report.txt
date >> report.txt
