#!/bin/bash
ulimit -v 100000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl
csv=$dumps/csv
out=$dumps/csv/csv_mw
htdocs=thorium.eqiad.wmnet::stats.wikimedia.org/htdocs/
  
clear 
cd $perl ;

perl WikiCountsFindMigrationPatterns.pl -c $out 

