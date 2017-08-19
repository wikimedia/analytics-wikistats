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

nice perl WikiCollectWordFrequencies.pl

