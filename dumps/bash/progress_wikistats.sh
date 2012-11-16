#!/bin/sh
ulimit -v 1000000

perl=/a/wikistats/scripts/perl

perl $perl/WikiCountsJobProgress.pl >/dev/null

rsync -av /a/wikistats/out/out_wm/WikiCountsJobProgress*.html  stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs

