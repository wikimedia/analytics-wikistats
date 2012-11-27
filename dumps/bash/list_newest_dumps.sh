#!/bin/sh
ulimit -v 8000000

# List for every wiki in one project (-p) the latest stub dump per language, languages as specified in dblist (-l)

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
csv=$dumps/csv
dblists=$dumps/dblists

clear

cd $perl

perl WikiCountsListNewestDumps.pl -c $csv -p wp -w enwiki -l $dblists/wikipedia.dblist 
