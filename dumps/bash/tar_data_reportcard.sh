#!/bin/bash

# collect subset of files needed for offline production of original (pre Limn) report card

wikistats=/a/wikistats_git
csv=$wikistats/dumps/csv

cd $csv
tar -cvf $csv/zip_all/csv_report_card.tar */StatisticsMonthly.csv */StatisticsUserActivitySpread.csv */StatisticsPerBinariesExtension.csv

