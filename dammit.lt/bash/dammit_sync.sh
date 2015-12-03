#!/bin/bash
ulimit -v 2000000

# collect newewest projectcounts files (hourly page view stats per wiki), add to tar, and publish

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
perl=/home/ezachte/wikistats/dammit.lt/perl # tests
logs=$dammit/logs

data=/a/dammit.lt
pagecounts=$data/pagecounts

# -t folder for tar files
# -p folder for hourly projectcounts files
# -r folder to rsync tar files to
cd $perl

perl DammitSyncProjectCounts.pl -t "/a/dammit.lt/projectviews" \
                                -p "/mnt/data/xmldatadumps/public/other/pageviews" \
                                -r "dataset1001.wikimedia.org::pagecounts-ez/projectviews" |\
                                tee "/a/dammit.lt/projectviews/log_sync_projectviews.txt" | cat 


perl DammitSyncProjectCounts.pl -t "/a/dammit.lt/projectcounts" \
                                -p "/mnt/data/xmldatadumps/public/other/pagecounts-raw" \
                                -r "dataset1001.wikimedia.org::pagecounts-ez/projectcounts" |\
                                tee "/a/dammit.lt/projectcounts/log_sync_projectcounts.txt" | cat 

