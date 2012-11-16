#!/bin/sh

perl=/a/wikistats/scripts/perl
csv=/a/wikistats/csv
dblists=/a/wikistats/dblists

perl $perl/WikiCountsSortDblist.pl -c $csv/csv_wb/StatisticsLog.csv -d $dblists/wikibooks.dblist   -s wikibooks 
perl $perl/WikiCountsSortDblist.pl -c $csv/csv_wk/StatisticsLog.csv -d $dblists/wiktionary.dblist  -s wiktionary 
perl $perl/WikiCountsSortDblist.pl -c $csv/csv_wn/StatisticsLog.csv -d $dblists/wikinews.dblist    -s wikinews 
perl $perl/WikiCountsSortDblist.pl -c $csv/csv_wp/StatisticsLog.csv -d $dblists/wikipedia.dblist   -s wiki 
perl $perl/WikiCountsSortDblist.pl -c $csv/csv_wq/StatisticsLog.csv -d $dblists/wikiquote.dblist   -s wikiquote 
perl $perl/WikiCountsSortDblist.pl -c $csv/csv_ws/StatisticsLog.csv -d $dblists/wikisource.dblist  -s wikisource 
perl $perl/WikiCountsSortDblist.pl -c $csv/csv_wv/StatisticsLog.csv -d $dblists/wikiversity.dblist -s wikiversity 
perl $perl/WikiCountsSortDblist.pl -c $csv/csv_wx/StatisticsLog.csv -d $dblists/special.dblist     -s wiki 
