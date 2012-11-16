#!/bin/bash

# collect subset of files needed for offline production of original (pre Limn) report card

wikistats=/a/wikistats_git

cd $wikistats/dumps/csv
tar -cvf $wikistats/dumps/csv/zip_all/csv_report_card.tar */StatisticsMonthly.csv */StatisticsUserActivitySpread.csv */StatisticsPerBinariesExtension.csv
