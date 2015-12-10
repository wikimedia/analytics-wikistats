#!/bin/sh 

ulimit -v 8000000

wikistats=/a/wikistats_git
mail=$wikistats/mail-lists
perl=$mail/perl
perl=/home/ezachte/wikistats/mail-lists/perl # tests 
out=$mail/out
htdocs=stat1001.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

cd $perl
perl ReportMailArchives.pl

cd $out
rsync -a -r *.htm* $htdocs/mail-lists
