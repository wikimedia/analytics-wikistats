#! /bin/bash
ulimit -v 8000000

# note: any ref to squids in names is legacy , pre-hadoop

wikistats=/a/wikistats_git
squids=$wikistats/squids
traffic=$wikistats/traffic
perl=$traffic/perl
perl=/home/ezachte/wikistats/traffic/perl/ # temp

csv_sampled=$squids/csv               # views and edits, 1:1000 sampled       

reports_sampled=$squids/reports

logs=$traffic/logs
meta=$wikistats/squids/csv/meta # for bots views and edits use these 'meta' files (lookup for country/region codes) 
data_hourly=/mnt/hdfs/wmf/data/archive/projectview/geo/hourly/ 
htdocs=stat1001.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

cd $perl

log=$logs/SquidReportArchive.log

month=2016-09
quarter=2016Q3

run_collect_country_stats=yes
run_refresh_from_wikipedia=no

# very loose input validation
if [ "$1" != "" ]
then
  echo "Argument provided: $1"
  if [[ $1 =~ ^2[0-9][0-9][0-9]-[0-1][0-9]$ ]]
  then 
    echo "Month provided: $1"
    month=$1
  else 
    echo "Unexpected argument: $1"
    exit
  fi
fi

file="$csv_sampled/SquidDataVisitsPerCountryMonthly.csv" 
age=$(stat -c %Y $file)
now=$(date +"%s")
days=$(( (now - age) / (60 * 60 * 24) ))
threshold=2 

echo
echo "File '$file' generated at time $age, time now is $now, so age of file is $days days (rounded down)"
if (( $days < $threshold )) 
then
  echo "File is less than $threshold days old, so skip regenerating" 
  run_collect_country_stats=no
fi
echo

# run_collect_country_stats=yes # speed up repeated tests

# -c = country reports
# -v = views
# -e = edits
# -s = start month 
# -i = input folder
# -o = output folder
# -a = meta folder (a for about ~ meta)
# -l = logs folders
# -w = extra data from English Wikipedia
# -m = month to process for basic reports
# -x = sample rate 

args_views_sampled=" -v -i $csv_sampled -o $reports_sampled -a $meta -l $logs -x 1000"
# once every so many months refresh meta info from English Wikipedia 
# this is not ran so often, as Wikipedia page syntax can change anytime, so vetting is needed
if [ "$run_refresh_from_wikipedia" == "yes" ] ; then
  perl SquidReportArchive.pl -w $args_views_sampled | tee -a $log | cat 
  exit

fi

if [ "$run_collect_country_stats" == "yes" ] ; then
  echo ">> COLLECT PER COUNTRY STATS <<" >> $log

  perl SquidCountryAggregateDaily.pl -v -s "2015-05" -i $data_hourly -o $csv_sampled -l $logs | tee -a $log | cat 
  perl SquidCountryScan.pl           -v -s "2009-07" -i $csv_sampled                 -l $logs | tee -a $log | cat 
fi

cd $perl
perl TrafficAnalysisGeo.pl -c $args_views_sampled   -m $month | tee -a $log | cat # -c for per country reports 

echo "rsync -av $reports_sampled/$month/datamaps*. [csv|js|json]        $htdocs/archive/squid_reports/$month/draft7"
      rsync -av $reports_sampled/$month/datamaps*.csv                   $htdocs/archive/squid_reports/$month/draft7
echo
      rsync -av $reports_sampled/$month/datamaps*.js                    $htdocs/archive/squid_reports/$month/draft7
echo
      rsync -av $reports_sampled/$month/datamaps*.json                  $htdocs/archive/squid_reports/$month/draft7
