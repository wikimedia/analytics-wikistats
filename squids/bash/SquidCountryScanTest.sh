#!/bin/bash
ulimit -v 4000000

wikistats=/a/wikistats_git
squids=$wikistats/squids
perl=$squids/perl
perl=/home/ezachte/wikistats/squids-scripts-2012-10/perl # tests
cd $perl

# perl SquidCountryScan.pl -y 2010
perl SquidCountryScan.pl # startwith oldest recoded month: July 2009  
