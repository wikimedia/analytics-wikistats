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
echo "perl $perl"

# dte=$(date +%Y%m)
# dte=$(date --date "$dte -1 days" +%Y%m)
# echo "Compact dammit.lt files for one day: $dte"

# -a is max age of input in months

mode=-m # -m is recompress daily compressed files for full month (comment for daily job)
maxage=2 # process files for last .. months

echo "Compact dammit.lt files for one month"
nice perl DammitCompactHourlyOrDailyPageCountFiles.pl $mode -a $maxage -i $pagecounts -o $pagecounts/monthly -l $logs | tee -a $logs/dammit_compact_monthly.log | cat
 
