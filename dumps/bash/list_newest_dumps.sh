#!/bin/sh

ulimit -v 8000000

perl=/a/wikistats/scripts/perl
csv=/a/wikistats/csv
log=/a/wikistats/logs/log_merge_editors.txt

clear

cd $perl

perl ./WikiCountsListNewestDumps.pl 
