#!/bin/bash
ulimit -v 4000000

wikistats=/a/wikistats_git
squids=$wikistats/squids
perl=$squids/perl
perl=/home/ezachte/wikistats/squids/perl # tests
cd $perl


log=$squids/logs/SquidCountArchiveSampled.log
cp SquidCountArchiveConfigSampled.pm SquidCountArchiveConfig.pm
nice perl SquidCountArchive.pl -d 2015/07/01-2015/07/01 | tee $log | cat 


#log=$squids/logs_edits/SquidCountArchiveEdits.log
#cp SquidCountArchiveConfigEdits.pm SquidCountArchiveConfig.pm
#nice perl SquidCountArchive.pl -d 2015/01/01-2015/03/31 | tee $log | cat 
