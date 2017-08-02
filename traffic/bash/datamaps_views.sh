#! /bin/bash
ulimit -v 10000000

# Q&D tweaked bash file with remnants of SquidReportArchive.sh, needs further work
# any reference to 'squids' in names is legacy , pre-hadoop

wikistats=/srv/stat1002-a/wikistats_git
squids=$wikistats/squids
traffic=$wikistats/traffic

perl=$traffic/perl # no longer used, but here files were moved by gerrit  
perl_squids=/home/ezachte/wikistats/squids/perl/   
perl_traffic=/home/ezachte/wikistats/traffic/perl/ 

csv_sampled=$squids/csv               # views and edits, 1:1000 sampled       
reports_sampled=$squids/reports

logs=$traffic/logs
meta=$wikistats/squids/csv/meta # for bots views and edits use these 'meta' files (lookup for country/region codes) 
data_hourly=/mnt/hdfs/wmf/data/archive/projectview/geo/hourly/ 
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

log=$logs/SquidReportArchive.log

month=2017-07
quarter=2017Q2
run_refresh_from_wikipedia=no # do so once every few months
run_collect_country_stats=yes # set to 'no' to speed up repeated tests on one day

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

cd $perl_squids

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

cd $perl_traffic
perl TrafficAnalysisGeo.pl -c $args_views_sampled   -m $month | tee -a $log | cat # -c for per country reports 
exit
echo "rsync -av $reports_sampled/$month/datamaps*. [csv|js|json]        $htdocs/wikimedia/animations/pageviews/$month"
      rsync -av $reports_sampled/$month/datamaps*.csv                   $htdocs/wikimedia/animations/pageviews/$month
      rsync -av $reports_sampled/$month/datamaps*.js                    $htdocs/wikimedia/animations/pageviews/$month
      rsync -av $reports_sampled/$month/datamaps*.json                  $htdocs/wikimedia/animations/pageviews/$month

echo "rsync -av $reports_sampled/$month/datamaps*. [csv|js|json]        $htdocs/wikimedia/animations/pageviews"
      rsync -av $reports_sampled/$month/datamaps*.csv                   $htdocs/wikimedia/animations/pageviews
      rsync -av $reports_sampled/$month/datamaps*.js                    $htdocs/wikimedia/animations/pageviews
      rsync -av $reports_sampled/$month/datamaps*.json                  $htdocs/wikimedia/animations/pageviews
