#!/bin/sh

ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps      
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
dumps_public=/mnt/data/xmldatadumps/public # input dumps 
countrycodes=/a/wikistats_git/squids/csv/meta/CountryCodes.csv

clear
 
cd $perl
perl WikiCountsUploadsByCountryWLM.pl -i $dumps_public/commonswiki/latest/commonswiki-latest-pages-meta-history.xml.7z -o $csv_csv_wx -n $countrycodes

