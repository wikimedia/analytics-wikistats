wikistats=/a/wikistats_git
squids=$wikistats/squids
csv=$squids/csv
htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/
archive=dataset2::pagecounts-ez

rsync $csv/SquidDataVisitsPerCountryDaily.csv $archive/wikistats

