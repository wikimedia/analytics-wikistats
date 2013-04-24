#!/bin/bash
#env
#set -x
. /home/user/.bashrc;
eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib);
PAGEVIEWS_DIR=/home/user/wikistats/wikistats/pageviews_reports;
echo "BEFORE" >> /tmp/ctest;
/usr/bin/env perl -V > /tmp/cperlver;
/usr/bin/env perl -I$PAGEVIEWS_DIR/lib          \
                  $PAGEVIEWS_DIR/pageviews.pl   \
                  $PAGEVIEWS_DIR/conf/stat1-full-cron.json 2>&1 >/tmp/cperlerr;
echo "AFTER"  >> /tmp/ctest;
