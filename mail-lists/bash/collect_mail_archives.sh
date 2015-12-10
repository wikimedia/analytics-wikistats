#!/bin/sh 

export http_proxy=http://webproxy.eqiad.wmnet:8080 # Jan 2015 see https://wikitech.wikimedia.org/wiki/Http_proxy

ulimit -v 8000000

wikistats=/a/wikistats_git
mail=$wikistats/mail-lists
perl=$mail/perl
perl=/home/ezachte/wikistats/mail-lists/perl # tests 

cd $perl

perl CollectMailArchives.pl
