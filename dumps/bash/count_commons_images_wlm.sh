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
# x = xml file
# n = country Names
# o = Output folder
# b = Bot names
perl WikiCountsUploadsByCountryWL.pl -x $dumps_public/commonswiki/20161001/commonswiki-20161001-stub-meta-history.xml.gz \
                                     -o $csv/csv_wx_tmp \
				     -b $csv/csv_wx/BotsAll.csv \
				     -n $countrycodes 

