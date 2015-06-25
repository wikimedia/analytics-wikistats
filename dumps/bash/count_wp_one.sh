#!/bin/sh

ulimit -v 8000000
clear

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests 
csv=$dumps/csv
php=/a/mediawiki/core/languages
dumps_public=/mnt/data/xmldatadumps/public

cd $perl

force=-f # comment to disable forced rerun
#bz2=-b # comment to run 7z dump
date=auto # 20101231 # auto
#edits_only=-e # comment to run full scan
#trace=-r # comment to not trace resources
#reverts_only="-u 1" # comment to collect all data (u for undo)
#date=$1

rm $csv/csv_$set/WikiCountsRunAborted.txt

x=itwikinews # wikidatawiki
project=wn # wx
#date=20150430
perl $perl/WikiCounts.pl $trace $reverts_only $edits_only $force $bz2 -m $project -i $dumps_public/$x -o $csv/csv_$project/ -l $x -d $date -s $php

exit

# run from specific dump file
#x=enwiki
#project=wp
#date=20120430
#perl $perl/WikiCounts.pl $reverts_only $force $bz2 -b -m $set -i $dumps/$x/20120307 -o $csv/csv_$set/ -l $x -d $date -s $php ;
#perl $perl/WikiCounts.pl $reverts_only $edits_only $force $bz2 -b -m $project -i $dumps/$x/20120502 -o $csv/csv_wp_temp/ -l $x -d $date -s $php ; # rerun old dump to temp dir
#exit

# auto determine dump file
# force=-f

for x1 in el fa ;
do
x2=wikivoyage
x=$x1$x2
project=wo
perl $perl/WikiCounts.pl $trace $reverts_only $edits_only $force $bz2 -m $project -i $dumps_public/$x -o $csv/csv_$project/ -l $x -d $date -s $php
done
