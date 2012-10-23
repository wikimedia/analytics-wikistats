#! /bin/sh
ulimit -v 4000000

wikistats=/a/wikistats_git
squids=$wikistats/squids
perl=$squids/perl
#perl=/home/ezachte/wikistats/squids/perl/ # tests
csv=$squids/csv
reports=$squids/reports
logs=$squids/logs
cd $perl

log1=$logs/SquidCountryScan.log
log2=$logs/SquidReportArchive.log

month=2012-09 # adjust each month 
quarter=2012Q3

# once every so many months refresh meta info from English Wikipedia 
# perl SquidReportArchive.pl -w | tee -a $log | cat

# perl SquidReportArchive.pl -m 201007 > $log
# after further automating SquidScanCountries.sh

# perl SquidCountryScan.pl                  | tee -a $log1 | cat # collect csv data for all months, start in July 2009
# perl SquidReportArchive.pl -c             | tee -a $log2 | cat # -c for per country reports
# perl SquidReportArchive.pl -c             | tee -a $log2 | cat # -c for per country reports
# perl SquidReportArchive.pl -c -q $quarter | tee -a $log2 | cat # -c for per country reports
perl SquidReportArchive.pl -m $month        | tee -a $log2 | cat

cd $reports/$month
tar -cvf - *.htm | gzip > reports-$month.tar.gz

# after vetting reports are now manually rsynced to 
# - stat1001/a/srv/stats.wikimedia.org/htdocs/wikimedia/squids
# - stat1001/a/srv/stats.wikimedia.org/htdocs/archive/squid_reports/$month

# note: all gif and js files are also needed locally, that should change to shared location  
