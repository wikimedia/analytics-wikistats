#! /bin/bash
ulimit -v 1000000

wikistats=/a/wikistats_git
perl=$traffic/perl
perl=/home/ezachte/wikistats/traffic/perl/ # temp

meta=$wikistats/squids/csv/meta 
echo Collect country info into $meta

cd $perl

perl CollectCountryInfoFromWikipedia.pl -m $meta

