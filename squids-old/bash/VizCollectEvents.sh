#!/bin/bash
ulimit -v 4000000

wikistats=/a/wikistats_git
perl=$wikistats/perl
cd $perl

#nice perl VizCollectEvents.pl      -d 2011/07/29 # one day
#nice perl VizCollectEventsMonth.pl -m 2011/08    # one month

perl VizPrepJs.pl

