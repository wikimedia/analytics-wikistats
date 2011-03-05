#! /bin/sh
ulimit -v 4000000

home="/a/ezachte"
month=2011-02

# perl $home/SquidReportArchive.pl -m 201007 > SquidReportArchiveLog.txt
# after further automating SquidScanCountries.sh:

#perl $home/SquidReportArchive.pl -c $month >> SquidReportArchiveLog.txt # -c for per country reports
#perl $home/SquidReportArchive.pl -m $month >> SquidReportArchiveLog.txt
#perl $home/SquidCountryScan.pl # start in July 2009

cp /a/ezachte/$month/$month-html.tar ./reports_traffic_$month.tar 
tar -cf reports_countries_$month.tar SquidReportPage*.htm 

bzip2 -f reports_traffic_$month.tar
bzip2 -f reports_countries_$month.tar

tar -cf reports_$month.tar reports_*_$month.tar.bz2
