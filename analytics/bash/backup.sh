#!/bin/bash
ulimit -v 400000
wikistats=/a/wikistats_git
analytics=$wikistats/analytics
cd $analytics

dt=$(date +[%Y-%m-%d][%H:%M])

#zip /a/wikistats/backup/analytics_$dt.zip ./perl/*.pl ./bash/*.sh ./csv/comscore/*.csv ./csv/history/*.csv ./csv/*/*.csv
zip /a/wikistats/backup/analytics_$dt.zip ./csv/*/*
