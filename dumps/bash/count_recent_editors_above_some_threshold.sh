#!/bin/sh
ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl
csv=$dumps/csv
out=$dumps/out
php=/a/mediawiki/core/languages
dumps_public=/mnt/data/xmldatadumps/public

cd $perl

perl ./count_recent_editors_above_some_threshold.pl 

