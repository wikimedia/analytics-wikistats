#!/bin/sh

ulimit -v 100000

wikistats=/a/wikistats_git
perl=$wikistats/dumps/perl
csv=$wikistats/dumps/csv

clear

cd $perl
perl WikiCountsScanNamespacesWithContent.pl -c $csv

cd $csv/csv_mw
grep "project" StatisticsContentNamespaces.csv >  StatisticsContentNamespacesExtraNamespaces.csv # first line with headers
grep "0|"      StatisticsContentNamespaces.csv >> StatisticsContentNamespacesExtraNamespaces.csv


