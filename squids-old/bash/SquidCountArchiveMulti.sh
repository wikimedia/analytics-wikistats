#!/bin/bash
ulimit -v 4000000

wikistats=/a/wikistats_git
perl=$wikistats/perl
logs=$wikistats/logs
cd $perl

script=SquidCountArchive.pl

# probably better to build one .sh file and invoke that with nohup
# or susbmit all jobs in different threads 
# (which was was actually the plan but I need to look further how to do that)

log=$logs/SquidCountArchive-2011-10.log
nohup perl $script -d 2011/10/01-2011/10/31 > nohup.2011-10 &

log=$logs/SquidCountArchive-2011-11.log
nohup perl $script -d 2011/11/01-2011/11/30 > nohup.2011-11 &

log=$logs/SquidCountArchive-2011-12.log
nohup perl $script -d 2011/12/01-2011/12/31 > nohup.2011-12 &

log=$logs/SquidCountArchive-2012-03.log
nohup perl $script -d 2012/03/01-2012/03/31 > nohup.2012-03 &

echo Ready
