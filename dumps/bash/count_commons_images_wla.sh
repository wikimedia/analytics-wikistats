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

echo "first edit count_commons_images_wla.sh: WLM -> WLA" # Q&D path, to be externalized
exit
 
cd $perl
# x = Xml file
# n = country Names
# o = Output folder
# b = Bot names
#perl WikiCountsUploadsByCountryWLA.pl -x $dumps_public/commonswiki/latest/commonswiki-latest-pages-meta-history.xml.7z \
perl WikiCountsUploadsByCountryWL.pl -x $dumps_public/commonswiki/20160203/commonswiki-20160203-pages-meta-current.xml.bz2 \
                                     -o $csv/csv_wx \
				     -b $csv/csv_wx/BotsAll.csv \
				     -n $countrycodes \
                                     | tee $csv/csv_wx/WLA_images_joblog.txt | cat

