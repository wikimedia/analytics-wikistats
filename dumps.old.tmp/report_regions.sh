#!/bin/bash
abort_before=$2
day_of_month=$(date +"%d")
if [ $day_of_month -lt ${abort_before:=0} ]
then	  
  echo report.sh: day of month $day_of_month lt $abort_before - exit
  exit
fi

echo day of month $day_of_month ge $abort_before - continue

echo "\nStart report.sh regions" >> report.txt
date >> report.txt

./sync_language_files.sh 

# for x in en ast bg br ca cs da de eo es fr he hu id it ja nl nn pl pt ro ru sk sl sr sv wa zh ;
for x in en ;
do 
  perl WikiReports.pl -r india      -m wp -l $x -i /a/wikistats/csv_wp/ -o /a/out/out_wp ;
  perl WikiReports.pl -r africa     -m wp -l $x -i /a/wikistats/csv_wp/ -o /a/out/out_wp ;
  perl WikiReports.pl -r america    -m wp -l $x -i /a/wikistats/csv_wp/ -o /a/out/out_wp ;
  perl WikiReports.pl -r asia       -m wp -l $x -i /a/wikistats/csv_wp/ -o /a/out/out_wp ;
  perl WikiReports.pl -r europe     -m wp -l $x -i /a/wikistats/csv_wp/ -o /a/out/out_wp ;
  perl WikiReports.pl -r oceania    -m wp -l $x -i /a/wikistats/csv_wp/ -o /a/out/out_wp ;
  perl WikiReports.pl -r artificial -m wp -l $x -i /a/wikistats/csv_wp/ -o /a/out/out_wp ;
done;

# perl WikiReports.pl -c -m $1 -l en -i /a/wikistats/csv_$1/ -o /a/out/out_$1 

# ./zip_out.sh $1

echo "Ready" >> report.txt
date >> report.txt
