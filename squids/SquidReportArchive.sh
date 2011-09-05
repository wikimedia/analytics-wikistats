#! /bin/sh
ulimit -v 4000000

home="/a/ezachte"
month=2011-08

# perl $home/SquidReportArchive.pl -m 201007 > SquidReportArchiveLog.txt
# after further automating SquidScanCountries.sh

# perl $home/SquidCountryScan.pl # start in July 2009
# perl $home/SquidReportArchive.pl -c           # >> SquidReportArchiveLog.txt # -c for per country reports
# perl $home/SquidReportArchive.pl -c -q 2010Q2 # >> SquidReportArchiveLog.txt # -c for per country reports
perl $home/SquidReportArchive.pl -m $month           # >> SquidReportArchiveLog.txt

ls -l /a/ezachte/reports*$month*
rm    /a/ezachte/reports*$month*

tar -cf /a/ezachte/$month/$month-html.tar /a/ezachte/$month/*.htm
cp /a/ezachte/$month/$month-html.tar ./reports-traffic-$month.tar 
tar -cf reports-countries-$month.tar SquidReportPage*.htm 
bzip2 -f reports-traffic-$month.tar
bzip2 -f reports-countries-$month.tar
tar -cf reports-$month.tar reports-*-$month.tar.bz2
rm /a/ezachte/reports*$month*.bz2
