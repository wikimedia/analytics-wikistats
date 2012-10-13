#!/bin/bash
ulimit -v 4000000

wikistats=/a/wikistats_git
perl=$wikistats/perl
cd $perl

# perl SquidCountryScan.pl -y 2010
perl SquidCountryScan.pl # startwith oldest recoded month: July 2009  
