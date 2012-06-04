#!/bin/sh

cd /a/wikistats/analytics

dt=$(date +[%Y-%m-%d][%H:%M])

zip /a/wikistats/backup/analytics_$dt.zip *.pl *.sh *.csv *.txt comscore/*.csv
