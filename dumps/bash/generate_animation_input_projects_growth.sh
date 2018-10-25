#!/bin/bash

# script migrated to stat1005

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA
logfile=$wikistats_data/dumps/logs/log_generate_animation_input_projects_growth.txt
exec 1> $logfile 2>&1 # send stdout/stderr output to file

perl=$wikistats/dumps/perl
csv=$wikistats_data/dumps/csv
out=$wikistats_data/animations/growth
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

dt=$(date +[%Y-%m-%d][%H:%M])
cd $out 
zip bak_js_$dt.zip *.js

cd $perl
perl WikiReports.pl -a -l en -m wb -i $csv/csv_wb -o $out/new 
perl WikiReports.pl -a -l en -m wk -i $csv/csv_wk -o $out/new 
perl WikiReports.pl -a -l en -m wn -i $csv/csv_wn -o $out/new 
perl WikiReports.pl -a -l en -m wo -i $csv/csv_wo -o $out/new 
perl WikiReports.pl -a -l en -m wp -i $csv/csv_wp -o $out/new 
perl WikiReports.pl -a -l en -m wq -i $csv/csv_wq -o $out/new 
perl WikiReports.pl -a -l en -m ws -i $csv/csv_ws -o $out/new 
perl WikiReports.pl -a -l en -m wv -i $csv/csv_wv -o $out/new 
perl WikiReports.pl -a -l en -m wx -i $csv/csv_wx -o $out/new
exit 

echo after vetting resync, run commented code
# after vetting
  
cd $out 
mv new/EN/*.js .

rsync -av Animation*InitW*.js $htdocs/wikimedia/animations/growth
