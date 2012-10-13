#! /bin/sh
ulimit -v 4000000

wikistats=/a/wikistats_git
perl=$wikistats/perl
cd $perl

perl ./SquidScanCsvFiles.pl
