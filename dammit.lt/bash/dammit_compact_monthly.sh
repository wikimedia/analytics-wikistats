#!/bin/bash
ulimit -v 2000000

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
logs=$dammit/logs

data=/a/dammit.lt
pagecounts=$data/pagecounts

cd $perl
ls -l

# dte=$(date +%Y%m)
# dte=$(date --date "$dte -1 days" +%Y%m)
# echo "Compact dammit.lt files for one day: $dte"

echo "Compact dammit.lt files for one month"
echo "nice perl DammitCompactHourlyOrDailyPageCountFiles.pl -m -d 201001 -i $pagecounts -o $pagecounts/monthly >> $logs/dammit_compact_monthly.log"
 
