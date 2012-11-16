#!/bin/bash

cd /a/wikistats/csv
tar -cvf /a/wikistats/csv/zip_all/csv_report_card.tar */StatisticsMonthly.csv */StatisticsUserActivitySpread.csv */StatisticsPerBinariesExtension.csv
