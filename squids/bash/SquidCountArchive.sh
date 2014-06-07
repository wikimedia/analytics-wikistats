#!/bin/bash
ulimit -v 4000000

wikistats=/a/wikistats_git
squids=$wikistats/squids
perl=$squids/perl
perl=/home/ezachte/wikistats/squids/perl # tests
cd $perl


log=$squids/logs/SquidCountArchiveSampled.log
cp SquidCountArchiveConfigSampled.pm SquidCountArchiveConfig.pm
nice perl SquidCountArchive.pl -d 2014/04/01-2014/04/30 | tee $log | cat 

#exit

log=$squids/logs_edits/SquidCountArchiveEdits.log
cp SquidCountArchiveConfigEdits.pm SquidCountArchiveConfig.pm
nice perl SquidCountArchive.pl -d 2014/04/01-2014/04/30 | tee $log | cat 
