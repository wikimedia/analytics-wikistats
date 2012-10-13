#! /bin/sh
ulimit -v 4000000

wikistats=/a/wikistats_git
perl=$wikistats/perl
csv=$wikistats/csv
reports=$wikistats/reports
cd $perl

month=2012-09

quarter=2012Q3

# perl SquidReportArchive.pl -m 201007 > SquidReportArchiveLog.txt
# after further automating SquidScanCountries.sh

# perl SquidCountryScan.pl                  # collect csv data for all months, start in July 2009
# perl SquidReportArchive.pl -c             # >> SquidReportArchiveLog.txt # -c for per country reports
# perl SquidReportArchive.pl -c -q $quarter # >> SquidReportArchiveLog.txt # -c for per country reports
perl SquidReportArchive.pl -m $month      # >> SquidReportArchiveLog.txt

# perl SquidReportArchive.pl -m 2012-05     # >> SquidReportArchiveLog.txt

cd $reports/$month
tar -cvf - *.htm | gzip > reports-$month.tar.gz
cp reports-$month.tar.gz ..
