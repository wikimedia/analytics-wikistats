#!/bin/bash
ulimit -v 2000000

#out=/a/wikistats_git/tmp/pagecounts_bad_lines.txt

#cd /mnt/data/xmldatadumps/public/other/pagecounts-raw/2013/2013-11/
#zgrep -H Autonym.ttf pagecount*.gz > $out

#cd /mnt/data/xmldatadumps/public/other/pagecounts-raw/2013/2013-06/
#zgrep -H Special:CentralAutoLogin pagecount*.gz >> $out
#cd /mnt/data/xmldatadumps/public/other/pagecounts-raw/2013/2013-07/
#zgrep -H Special:CentralAutoLogin pagecount*.gz >> $out
#cd /mnt/data/xmldatadumps/public/other/pagecounts-raw/2013/2013-08/
#zgrep -H Special:CentralAutoLogin pagecount*.gz >> $out
#cd /mnt/data/xmldatadumps/public/other/pagecounts-raw/2013/2013-09/
#zgrep -H Special:CentralAutoLogin pagecount*.gz >> $out
#cd /mnt/data/xmldatadumps/public/other/pagecounts-raw/2013/2013-10/
#zgrep -H Special:CentralAutoLogin pagecount*.gz >> $out
#cd /mnt/data/xmldatadumps/public/other/pagecounts-raw/2013/2013-11/
#zgrep -H Special:CentralAutoLogin pagecount*.gz >> $out

# second run to catch last files
out=/a/wikistats_git/tmp/pagecounts_bad_lines2.txt
cd /mnt/data/xmldatadumps/public/other/pagecounts-raw/2013/2013-12/
zgrep -H Special:CentralAutoLogin pagecount*.gz >> $out

