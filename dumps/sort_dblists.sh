#!/bin/sh

csv="/a/wikistats"
wikistats="/home/ezachte/wikistats"
dblists="$wikistats/dblists"

perl $wikistats/WikiCountsSortDblist.pl -c $csv/csv_wb/StatisticsLog.csv -d $dblists/wikibooks.dblist -s wikibooks 
perl $wikistats/WikiCountsSortDblist.pl -c $csv/csv_wk/StatisticsLog.csv -d $dblists/wiktionary.dblist -s wiktionary 
perl $wikistats/WikiCountsSortDblist.pl -c $csv/csv_wn/StatisticsLog.csv -d $dblists/wikinews.dblist -s wikinews 
perl $wikistats/WikiCountsSortDblist.pl -c $csv/csv_wp/StatisticsLog.csv -d $dblists/wikipedia.dblist -s wiki 
perl $wikistats/WikiCountsSortDblist.pl -c $csv/csv_wq/StatisticsLog.csv -d $dblists/wikiquote.dblist -s wikiquote 
perl $wikistats/WikiCountsSortDblist.pl -c $csv/csv_ws/StatisticsLog.csv -d $dblists/wikisource.dblist -s wikisource 
perl $wikistats/WikiCountsSortDblist.pl -c $csv/csv_wv/StatisticsLog.csv -d $dblists/wikiversity.dblist -s wikiversity 
perl $wikistats/WikiCountsSortDblist.pl -c $csv/csv_wx/StatisticsLog.csv -d $dblists/special.dblist -s wiki 
