#! /bin/bash
# script migrated to stat1005

ulimit -v 1000000
export http_proxy=http://webproxy.eqiad.wmnet:8080
export https_proxy=http://webproxy.eqiad.wmnet:8080

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA
traffic=$wikistats/traffic
perl=$traffic/perl

meta=$wikistats_data/squids/csv/meta 

echo Collect country info into $meta

cd $perl

perl CollectCountryInfoFromWikipedia.pl -m $meta

