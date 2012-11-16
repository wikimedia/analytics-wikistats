#!/bin/sh

ulimit -v 100000

perl=/a/wikistats/scripts/perl
csv=/a/wikistats/csv

clear

cd $perl

perl ./WikiCountsScanNamespacesWithContent.pl

cd $csv/csv_mw
grep "project" StatisticsContentNamespaces.csv >  StatisticsContentNamespacesExtraNamespaces.csv # first line with headers
grep "0|"      StatisticsContentNamespaces.csv >> StatisticsContentNamespacesExtraNamespaces.csv


