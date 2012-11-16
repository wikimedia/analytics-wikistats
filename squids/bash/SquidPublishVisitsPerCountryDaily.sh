wikistats=/a/wikistats_git
squids=$wikistats/squids
csv=$squids/csv
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/
archive=dataset2::pagecounts-ez

cd $csv
zip csv_squids_daily_visits_per_country.zip  SquidDataVisitsPerCountryDaily.csv
rsync csv_squids_daily_visits_per_country.zip $archive/wikistats

