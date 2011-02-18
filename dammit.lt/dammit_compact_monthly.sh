#!/bin/sh

ulimit -v 8000000

# dte=$(date +%Y%m)
# dte=$(date --date "$dte -1 days" +%Y%m)
# echo "Compact dammit.lt files for one day: $dte"

echo "Compact dammit.lt files for one month"
nice perl /a/dammit.lt/DammitCompactHourlyOrDailyPageCountFiles.pl -m -d 201001 -i /a/dammit.lt/pagecounts -o /a/dammit.lt/pagecounts/monthly >> /a/dammit.lt/pagecounts/monthly/compact_log.txt
 
