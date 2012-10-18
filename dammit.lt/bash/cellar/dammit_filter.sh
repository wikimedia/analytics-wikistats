echo legacy, similar work now done with bash commands
echo note perl file still has hard coded paths !
echo abort
exit

#!/bin/bash
ulimit -v 2000000

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl/cellar

cd $perl


#='/a/dammit.lt/pagecounts'       # input dir
#o='/home/ezachte/wikistats/scans' # output dir
#f=20090424 # from date
#t=20091110 # till date
perl !DammitFilterDailyPageCountsPerLanguage.pl 
