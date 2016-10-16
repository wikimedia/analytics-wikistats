#!/bin/bash

perl=/home/ezachte/wikistats/wiki_loves/perl
csv=/a/wikistats_git/wiki_loves/csv
logs=/a/wikistats_git/wiki_loves/logs

cd $perl
perl ./wiki_loves_stats_parse_json_db.pl -i http://tools.wmflabs.org/wikiloves/db.json -o $csv -l $logs
