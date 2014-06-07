#!/bin/sh

ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv

clear

cd $perl

perl WikiCountsMergeBotsAllProjects.pl -c $csv
