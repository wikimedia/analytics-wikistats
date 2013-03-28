#!/bin/bash
ulimit -v 2000000


dammit=/a/dammit.lt
merged=$dammit/pagecounts/merged
temp=$dammit/pagecounts/temp

bzgrep -v '^#' $merged/pagecounts-2011-12-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2011-12-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-01-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-01-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-02-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-02-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-03-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-03-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-04-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-04-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-05-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-05-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-06-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-06-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-07-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-07-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-08-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-08-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-09-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-09-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-10-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-10-views-ge-5-totals.bz2 
bzgrep -v '^#' $merged/pagecounts-2012-11-views-ge-5.bz2 | awk '{print $1" "$2" "$3}' | bzip2 > $merged/pagecounts-2012-11-views-ge-5-totals.bz2 
