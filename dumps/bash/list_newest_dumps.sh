#!/bin/sh
ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
csv=$dumps/csv
dblists=$dumps/dblists

clear

cd $perl

perl WikiCountsListNewestDumps.pl -c $csv -p wp -l $dblists/wikipedia.dblist 
