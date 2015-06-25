#!/bin/sh

ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl
csv=$dumps/csv
input=/mnt/data/xmldatadumps/public/fywikibooks/20140603/fywikibooks-20140603-stub-meta-history.xml.gz

clear

cd $perl

perl WikiCountsCollectEdits.pl -c $csv -p wb -w fywikibooks -i $input
