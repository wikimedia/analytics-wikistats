#! /bin/sh
ulimit -v 4000000

wikistats=/a/wikistats_git
squids=$wikistats/squids
perl=$squids/perl
perl=/home/ezachte/wikistats/squids-scripts-2012-10/perl/ # temp
csv=$squids/csv_edits
reports=$squids/reports_edits
logs=$squids/logs
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

cd $perl

log1=$logs/SquidCountryScanEdits.log
log2=$logs/SquidReportArchiveEdits.log

month=2013-04  
quarter=2013Q1

# once every so many months refresh meta info from English Wikipedia 
# perl SquidReportArchive.pl -w | tee -a $log | cat

# perl SquidReportArchive.pl -m 201007 > $log
# after further automating SquidScanCountries.sh

 perl SquidCountryScan.pl                  | tee -a $log1 | cat # collect csv data for all months, start in July 2009
 perl SquidReportArchive.pl -c             | tee -a $log2 | cat # -c for per country reports
# perl SquidReportArchive.pl -c -q $quarter | tee -a $log2 | cat # -c for per country reports
# perl SquidReportArchive.pl -m $month        | tee -a $log2 | cat

cd $reports/$month
tar -cvf - *.htm | gzip > reports-$month.tar.gz
exit
# after vetting reports are now manually rsynced to 
# - thorium/a/srv/stats.wikimedia.org/htdocs/wikimedia/squids
# - thorium/a/srv/stats.wikimedia.org/htdocs/archive/squid_reports/$month
echo Publish
rsync -av $reports/$month/SquidReport*.htm  $htdocs/wikimedia/squids
rsync -av $reports/$month/SquidReport*.htm  $htdocs/archive/squid_reports/$month
rsync -av $reports/$month/*.gz              $htdocs/archive/squid_reports/$month

cd ../bash
SquidLoadScan.sh

echo Done
# note: all gif and js files are also needed locally, that should change to shared location  
