#!/bin/bash

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
bash=$dumps/bash
csv=$dumps/csv
out=$dumps/out
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

log=$dumps/logs/log_report_regions.txt

/interval_days=-1 # set to -1 to have all reports generated despite age

function echo2 {
  echo $1
  echo $1 >> $log
}

clear

cd $perl

echo2 ""
echo2 "========================================================================" 
echo2 ""
echo2 "Start report_regions.sh"
date >> $log

# Validate project code
if [ "$1" == "" ] ; then
  echo2 "Project code missing! Specify as 1st argument one of wb,wk,wn,wp,wq,ws,wv,wx"
  exit
fi  

#
abort_before=$2
day_of_month=$(date +"%d")
if [ $day_of_month -lt ${abort_before:=0} ]
then	  
  echo2 "report.sh: day of month $day_of_month lt $abort_before - exit"
  exit
fi

echo2 day of month $day_of_month ge $abort_before - continue

echo2 "\nStart report.sh regions"
date >> $log

./sync_language_files.sh 

echo2 ""
echo2 "Generate regional reports"
echo2 ""

for region in India Africa America Asia Europe Oceania Artificial ;
do
  for lang in en ; # ast bg br ca cs da de eo es fr he hu id it ja nl nn pl pt ro ru sk sl sr sv wa zh ;
  do	  
    echo2 "Get timestamp sitemap page for report $region, language $lang"
    lang_upper=$( echo "$lang" | tr '[:lower:]' '[:upper:]' )	
    file="/a/out/out_$1/${lang_upper}_$region/#index.html"	
    now=`date +%s`
    prevrun=`stat -c %Y $file`
    let secs_out="$now - $prevrun" 
    let days_out="$secs_out/86400"
    echo2 "File $file generated $days_out days ago"
   
    if [ $days_out -lt $interval_days ] ; then
      echo2 " Skip report step (files less than $interval_days days old)"
      echo2 ""
    else  
      echo2 ""	
      echo2 "Generate reports for $region in language $lang "
      region_lc=$( echo "$region" | tr '[:upper:]' '[:lower:]' )	
      perl WikiReports.pl -r $region_lc -m wp -l $lang -i $csv/csv_wp/ -o $out/out_wp # >> $log
      echo2 ""
      echo2 "Reports for $region completed, rsync to htdocs"
      echo2 "rsync -a /a/out/out_wp/EN_$region/ $htdocs/EN_$region"
      rsync -a /a/out/out_wp/EN_$region/ $htdocs/EN_$region
    fi  
  done;  
done;
exit

# for x in en ast bg br ca cs da de eo es fr he hu id it ja nl nn pl pt ro ru sk sl sr sv wa zh ;
for x in en ;
do 
  perl WikiReports.pl -r india      -m wp -l $x -i $csv/csv_wp/ -o $out/out_wp # >> $log
  rsync -avv $out/out_wp/EN_India
#  perl WikiReports.pl -r africa     -m wp -l $x -i $csv/csv_wp/ -o $out/out_wp ;
#  perl WikiReports.pl -r america    -m wp -l $x -i $csv/csv_wp/ -o $out/out_wp ;
#  perl WikiReports.pl -r asia       -m wp -l $x -i $csv/csv_wp/ -o $out/out_wp ;
#  perl WikiReports.pl -r europe     -m wp -l $x -i $csv/csv_wp/ -o $out/out_wp ;
#  perl WikiReports.pl -r oceania    -m wp -l $x -i $csv/csv_wp/ -o $out/out_wp ;
#  perl WikiReports.pl -r artificial -m wp -l $x -i $csv/csv_wp/ -o $out/out_wp ;
done;

# perl WikiReports.pl -c -m $1 -l en -i $csv_$1/ -o $out_$1 

# ./zip_out.sh $1

echo "Ready" >> "$log"
date >> $log
