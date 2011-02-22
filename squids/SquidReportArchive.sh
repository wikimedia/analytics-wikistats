#! /bin/sh
ulimit -v 4000000
home="/a/ezachte"
# perl $home/SquidReportArchive.pl -m 201007 > SquidReportArchiveLog.txt
# after further automating SquidScanCountries.sh:
perl $home/SquidReportArchive.pl -c 201101 >> SquidReportArchiveLog.txt # -c for per country reports
perl $home/SquidReportArchive.pl -m 201101 >> SquidReportArchiveLog.txt
tar -cf reports.tar /a/ezachte/*.htm 
bzip2 reports.tar
mv reports.tar.bz2 /a/ezachte
