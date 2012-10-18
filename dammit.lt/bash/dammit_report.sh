echo Report most viewed pages for some WMF wikis
echo Script may be obsolete, and still contains hard coded paths to legacy env!
echo Abort
exit

#!/bin/bash
ulimit -v 2000000

wikistats=/a/wikistats_git
dammit=$wikistats/dammit.lt
perl=$dammit/perl
logs=$dammit/logs

cd $perl

perl DammitReportPageRequestsStaffWikis.pl
