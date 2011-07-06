#!/bin/sh
ulimit -v 8000000

clear
cd /a/analytics

perl AnalyticsPrepBinariesData.pl -i /a/wikistats/ -o /a/analytics/test/

# add or replace data from newest comScore csv files (last 14 months)  into master files (full history)
# and generate database input csv file from it 

# -r replace (default is add only)
# -i input folder, contains manually downloaded csv files from comScore (or xls, converted to csv) 
# -m master files with full history
# -o output csv file, with reach and UV's per region and UV's per top web property, ready for import into database
perl AnalyticsPrepComscoreData.pl -r -i /a/analytics/comscore -m /a/analytics -o /a/analytics

perl AnalyticsPrepWikiCountsOutput.pl -i /a/wikistats/ -o /a/analytics 

cp /a/wikistats/csv_wp/analytics_in_page_views.csv .

