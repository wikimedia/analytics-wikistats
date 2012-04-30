#! /bin/sh
ulimit -v 4000000

month=2012-01
quarter=2012Q1

stats=/a/squid/stats
scripts=$stats/scripts
cd $scripts 

# perl $scripts/SquidReportArchive.pl -m 201007 > SquidReportArchiveLog.txt
# after further automating SquidScanCountries.sh

# perl SquidCountryScan.pl                  # collect csv data for all months, start in July 2009
# perl SquidReportArchive.pl -c             # >> SquidReportArchiveLog.txt # -c for per country reports
# perl SquidReportArchive.pl -c -q $quarter # >> SquidReportArchiveLog.txt # -c for per country reports
# perl SquidReportArchive.pl -m $month      # >> SquidReportArchiveLog.txt
perl SquidReportArchive.pl -m 2011-10     # >> SquidReportArchiveLog.txt
perl SquidReportArchive.pl -m 2011-11     # >> SquidReportArchiveLog.txt
perl SquidReportArchive.pl -m 2011-12     # >> SquidReportArchiveLog.txt
perl SquidReportArchive.pl -m 2012-01     # >> SquidReportArchiveLog.txt
perl SquidReportArchive.pl -m 2012-02     # >> SquidReportArchiveLog.txt
perl SquidReportArchive.pl -m 2012-03     # >> SquidReportArchiveLog.txt
 

exit
tar -cf $stats/$month/$month-html.tar $reports/$month/*.htm
cp $reports/$month/$month-html.tar ./reports-traffic-$month.tar 
tar -cf reports-countries-$month.tar SquidReportPage*.htm 
bzip2 -f reports-traffic-$month.tar
bzip2 -f reports-countries-$month.tar
tar -cf reports-$month.tar reports-*-$month.tar.bz2
rm $reports/reports*$month*.bz2
