#!/bin/sh

ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
csv=$dumps/csv
log=$dumps/logs/log_merge_editors.txt

clear

cd $perl

perl WikiCounts.pl -m wb -i $csv/csv_wb/ -o $csv/csv_wb/ -y | tee    $log | cat 
perl WikiCounts.pl -m wk -i $csv/csv_wk/ -o $csv/csv_wk/ -y | tee -a $log | cat
perl WikiCounts.pl -m wn -i $csv/csv_wn/ -o $csv/csv_wn/ -y | tee -a $log | cat
perl WikiCounts.pl -m wp -i $csv/csv_wp/ -o $csv/csv_wp/ -y | tee -a $log | cat
perl WikiCounts.pl -m wq -i $csv/csv_wq/ -o $csv/csv_wq/ -y | tee -a $log | cat
perl WikiCounts.pl -m ws -i $csv/csv_ws/ -o $csv/csv_ws/ -y | tee -a $log | cat
perl WikiCounts.pl -m wv -i $csv/csv_wv/ -o $csv/csv_wv/ -y | tee -a $log | cat
perl WikiCounts.pl -m wx -i $csv/csv_wx/ -o $csv/csv_wx/ -y | tee -a $log | cat

perl WikiCounts.pl       -i $csv/csv_wp/ -o $csv/csv_wp/ -z | tee -a $log | cat 
