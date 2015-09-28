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
# x = Xml file
# n = country Names
# o = Output folder
# b = Bot names
#perl WikiCountsUploadsByCountryWLA.pl -x $dumps_public/commonswiki/latest/commonswiki-latest-pages-meta-history.xml.7z \
perl WikiCountsUploadsByCountryWLA.pl -x $dumps_public/commonswiki/20150110/commonswiki-20150110-pages-meta-history.xml.7z \
                                      -o $csv/csv_wx \
				      -b $csv/csv_wx/BotsAll.csv \
				      -n $countrycodes \
                                      | tee $csv/csv_wx/WLA_images_joblog.txt | cat
