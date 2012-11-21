#!/bin/sh

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
csv=$dumps/csv
dblists=$dumps/dblists

cd $perl
perl WikiCountsSortDblist.pl -c $csv/csv_wb/StatisticsLog.csv -d $dblists/wikibooks.dblist   -s wikibooks 
perl WikiCountsSortDblist.pl -c $csv/csv_wk/StatisticsLog.csv -d $dblists/wiktionary.dblist  -s wiktionary 
perl WikiCountsSortDblist.pl -c $csv/csv_wn/StatisticsLog.csv -d $dblists/wikinews.dblist    -s wikinews 
perl WikiCountsSortDblist.pl -c $csv/csv_wp/StatisticsLog.csv -d $dblists/wikipedia.dblist   -s wiki 
perl WikiCountsSortDblist.pl -c $csv/csv_wq/StatisticsLog.csv -d $dblists/wikiquote.dblist   -s wikiquote 
perl WikiCountsSortDblist.pl -c $csv/csv_ws/StatisticsLog.csv -d $dblists/wikisource.dblist  -s wikisource 
perl WikiCountsSortDblist.pl -c $csv/csv_wv/StatisticsLog.csv -d $dblists/wikiversity.dblist -s wikiversity 
perl WikiCountsSortDblist.pl -c $csv/csv_wx/StatisticsLog.csv -d $dblists/special.dblist     -s wiki 
