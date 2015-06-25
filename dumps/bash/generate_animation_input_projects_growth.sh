#!/bin/bash

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
bash=$dumps/bash
csv=$dumps/csv
out=$dumps/out
htdocs=stat1001.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

log=$dumps/logs/log_generate_animation_input_projects_growth.txt

dt=$(date +[%Y-%m-%d][%H:%M])
cd $wikistats/animations/growth 
zip bak/js_$dt.zip *.js

cd $perl
perl WikiReports.pl -a -l en -m wb -i $csv/csv_wb -o $wikistats/animations/growth/new 
perl WikiReports.pl -a -l en -m wk -i $csv/csv_wk -o $wikistats/animations/growth/new 
perl WikiReports.pl -a -l en -m wn -i $csv/csv_wn -o $wikistats/animations/growth/new 
perl WikiReports.pl -a -l en -m wo -i $csv/csv_wo -o $wikistats/animations/growth/new 
perl WikiReports.pl -a -l en -m wp -i $csv/csv_wp -o $wikistats/animations/growth/new 
perl WikiReports.pl -a -l en -m wq -i $csv/csv_wq -o $wikistats/animations/growth/new 
perl WikiReports.pl -a -l en -m ws -i $csv/csv_ws -o $wikistats/animations/growth/new 
perl WikiReports.pl -a -l en -m wv -i $csv/csv_wv -o $wikistats/animations/growth/new 
perl WikiReports.pl -a -l en -m wx -i $csv/csv_wx -o $wikistats/animations/growth/new

# exit 
# after vetting
  
cd $wikistats/animations/growth 
mv new/EN/*.js .

rsync -av Animation*InitW*.js $htdocs/wikimedia/animations/growth
