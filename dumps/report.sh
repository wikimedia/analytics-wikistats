#!/bin/bash
abort_before=$2
day_of_month=$(date +"%d")
if [ $day_of_month -lt ${abort_before:=0} ]
then	  
  echo report.sh: day of month $day_of_month lt $abort_before - exit
  exit
fi

echo day of month $day_of_month le $abort_before - continue

echo "\nStart report.sh $1" >> report.txt
date >> report.txt

./sync_language_files.sh 

for x in en ast bg br ca cs da de eo es fr he hu id it ja nl nn pl pt ro ru sk sl sr sv wa zh ;
#for  x in en ;
do perl WikiReports.pl -m $1 -l $x -i /a/wikistats/csv_$1/ -o /a/out/out_$1 ;
done;

# perl WikiReports.pl -c -m $1 -l en -i /a/wikistats/csv_$1/ -o /a/out/out_$1 

./zip_out.sh $1

echo "Ready" >> report.txt
date >> report.txt
