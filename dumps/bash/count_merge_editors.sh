#!/bin/sh
# script migrated to stat1005

ulimit -v 8000000
 
clear

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA

dumps=$wikistats/dumps
perl=$dumps/perl
csv=$wikistats_data/dumps/csv

log=$wikistats_data/dumps/logs/count_merge_editors.log

cd $perl

echo . > $log

# merge editors for all wikis of one project
perl WikiCounts.pl -m wb -i $csv/csv_wb -o $csv/csv_wb/ -y | tee -a $log | cat
perl WikiCounts.pl -m wk -i $csv/csv_wk -o $csv/csv_wk/ -y | tee -a $log | cat
perl WikiCounts.pl -m wn -i $csv/csv_wn -o $csv/csv_wn/ -y | tee -a $log | cat
perl WikiCounts.pl -m wo -i $csv/csv_wo -o $csv/csv_wo/ -y | tee -a $log | cat
perl WikiCounts.pl -m wp -i $csv/csv_wp -o $csv/csv_wp/ -y | tee -a $log | cat
perl WikiCounts.pl -m wq -i $csv/csv_wq -o $csv/csv_wq/ -y | tee -a $log | cat
perl WikiCounts.pl -m ws -i $csv/csv_ws -o $csv/csv_ws/ -y | tee -a $log | cat
perl WikiCounts.pl -m wv -i $csv/csv_wv -o $csv/csv_wv/ -y | tee -a $log | cat
perl WikiCounts.pl -m wx -i $csv/csv_wx -o $csv/csv_wx/ -y | tee -a $log | cat

# merge editors for all wikis of all projects
perl WikiCounts.pl -i $csv/csv_wp -o $csv/csv_wp/ -z | tee -a $log | cat
