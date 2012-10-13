#!/bin/bash

ulimit -v 4000000

#nice perl VizCollectEvents.pl      -d 2011/07/29 # one day
#nice perl VizCollectEventsMonth.pl -m 2011/08    # one month

perl VizPrepJs.pl

