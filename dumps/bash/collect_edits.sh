#!/bin/sh

ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
csv=$dumps/csv
input=/mnt/data/xmldatadumps/public/nlwikinews/20121115/nlwikinews-20121115-stub-meta-history.xml.gz

clear

cd $perl

perl WikiCountsCollectEdits.pl -c $csv -p wn -w nlwikinews -i $input
