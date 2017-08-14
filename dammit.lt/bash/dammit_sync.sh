#!/bin/bash
ulimit -v 2000000

echo_() {
 echo "$1" | tee -a $logfile| cat
}

# collect newewest projectcounts files (hourly page view stats per wiki), add to tar, and publish

yyyymmdd=$(date +"%Y_%m_%d")

dataset1001=dataset1001.wikimedia.org::pagecounts-ez        ; echo dataset1001=$dataset1001
xmldatadumps=/mnt/data/xmldatadumps/public/other            ; echo xmldatadumps=$xmldatadumps

perl=$WIKISTATS_SCRIPTS/dammit.lt/perl                      ; echo_ perl=$perl

data=$WIKISTATS_DATA/dammit
pagecounts=$data/pagecounts

logfiles=$data/logs/pageviews_monthly                       ; echo_ logfiles=$logfiles
logfile_projectviews=log_projectviews_sync_$yyyymmdd.txt    ; echo_ logfile_projectviews=$logfile_projectviews
logfile_projectcounts=log_projectcounts_sync_$yyyymmdd.txt  ; echo_ logfile_projectcounts=$logfile_projectcounts

# -t folder for tar files
# -p folder for hourly projectcounts files
# -r folder to rsync tar files to
cd $perl

perl DammitSyncProjectCounts.pl -t "$data/projectviews" \
                                -p "$xmldatadumps/pageviews" \
                                -r "$dataset1001/projectviews" |\
                                tee "$logfiles/$logfile_projectviews" | cat 


perl DammitSyncProjectCounts.pl -t "$data/projectcounts" \
                                -p "$xmldatadumps/pagecounts-raw" \
                                -r "$dataset1001/projectcounts" |\
                                tee "$logfiles/$logfile_projectcounts" | cat 

