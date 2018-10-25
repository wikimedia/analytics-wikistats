#! /bin/bash -x 
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

yyyymmdd=$(date +"%Y_%m_%d")

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA

logfile=$wikistats_data/dumps/logs/dblists/log_dblists_$yyyymmdd.txt
exec 1> $logfile 2>&1 # send stdout/stderr to file

perl=$wikistats/dumps/perl
csv=$wikistats_data/dumps/csv
dblists=$wikistats_data/dumps/dblists

# dblists are 

# dblists are maintained manually:
# Once a private wiki got added to original dblist file inadvertently,
# which required major cleanup operation across csv files,
# so I'd rather vet new wiki codes myself (EZ).

# Update Jan 2012:
# As these files are updated by a script (to sort wikis by size on each run)
# which causes git warnings, there is now a folder 'master copy'

# Update Jan 2013:
# Script now uses master copy as input and writes sorted list to folder where wikistats reads them
# Oops, I shouldn't have used a space in folder name 'master copy', oh well  

cd $perl
perl WikiCountsSortDblist.pl -c $csv/csv_wb/StatisticsLog.csv \
                             -i $dblists/master\ copy/wikibooks.dblist \
                             -o $dblists/wikibooks.dblist \
                             -s wikibooks 
perl WikiCountsSortDblist.pl -c $csv/csv_wk/StatisticsLog.csv \
                             -i $dblists/master\ copy/wiktionary.dblist \
                             -o $dblists/wiktionary.dblist \
                             -s wiktionary 
perl WikiCountsSortDblist.pl -c $csv/csv_wn/StatisticsLog.csv \
                             -i $dblists/master\ copy/wikinews.dblist \
                             -o $dblists/wikinews.dblist \
                             -s wikinews 
perl WikiCountsSortDblist.pl -c $csv/csv_wo/StatisticsLog.csv \
                             -i $dblists/master\ copy/wikivoyage.dblist \
                             -o $dblists/wikivoyage.dblist \
                             -s wikivoyage 
perl WikiCountsSortDblist.pl -c $csv/csv_wp/StatisticsLog.csv \
                             -i $dblists/master\ copy/wikipedia.dblist \
                             -o $dblists/wikipedia.dblist \
                             -s wiki 
perl WikiCountsSortDblist.pl -c $csv/csv_wq/StatisticsLog.csv \
                             -i $dblists/master\ copy/wikiquote.dblist \
                             -o $dblists/wikiquote.dblist \
                             -s wikiquote 
perl WikiCountsSortDblist.pl -c $csv/csv_ws/StatisticsLog.csv \
                             -i $dblists/master\ copy/wikisource.dblist \
                             -o $dblists/wikisource.dblist \
                             -s wikisource 
perl WikiCountsSortDblist.pl -c $csv/csv_wv/StatisticsLog.csv \
                             -i $dblists/master\ copy/wikiversity.dblist \
                             -o $dblists/wikiversity.dblist \
                             -s wikiversity 
perl WikiCountsSortDblist.pl -c $csv/csv_wx/StatisticsLog.csv \
                             -i $dblists/master\ copy/special.dblist \
                             -o $dblists/special.dblist \
                             -s wiki 
