#! /bin/sh
ulimit -v 4000000

wikistats=/a/wikistats_git
squids=$wikistats/squids
perl=$squids/perl
perl=/home/ezachte/wikistats/squids/perl # tests
csv=$squids/csv

cd $perl

perl SquidCollectGoogleStatsExcel.pl -i $csv -o $csv/excel
