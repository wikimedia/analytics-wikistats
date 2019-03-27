#! /bin/bash -x
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

# this job collects data (csv,json) for visualization WiViVi, currently at https://stats.wikimedia.org/wikimedia/animations/wivivi/wivivi.html

month=2018-05
quarter=2018Q1

# announce script name/arguments and (file name compatible) start time
{ set +x; } 2>/dev/null ;
me=`basename "$0"` ; args=${@} ; yyyymmddhhnn=$(date +"%Y_%m_%d__%H_%M") ; job="## $yyyymmddhhnn Job:$me args='$args' ##" ;
echo -e "$job\n" ; # repeated after exec to reroute log
set -x
 
ulimit -v 10000000

data_hourly=/mnt/hdfs/wmf/data/archive/projectview/geo/hourly/ 
htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

wikistats=$WIKISTATS_SCRIPTS
bash=$wikistats/dumps/bash
wikistats_data=$WIKISTATS_DATA
worldbank_demographics=/home/ezachte/wikistats/worldbank/world_bank_demographics_for_wikimedia_2018_05.json

dir_logs=$wikistats_data/traffic/logs/datamaps_views
mkdir -p -m 775 $dir_logs >/dev/null 2>&1
log_file=$dir_logs/datamaps_views_$yyyymmddhhnn.txt

# Q&D tweaked bash file with remnants of SquidReportArchive.sh, needs further work
# Note: any reference to 'squids' in names is legacy, pre-hadoop

### wikistats=/srv/stat1002-a/wikistats_git
squids=$wikistats_data/squids
traffic=$wikistats_data/traffic

perl=$traffic/perl # no longer used, but here files were moved by gerrit  
perl_squids=/home/ezachte/wikistats/squids/perl/   
perl_traffic=/home/ezachte/wikistats/traffic/perl/ 

csv_sampled=$squids/csv               # views and edits, 1:1000 sampled       
reports_sampled=$squids/reports

logs=$traffic/logs
meta=$wikistats_data/squids/csv/meta # for bots views and edits use these 'meta' files (lookup for country/region codes) 


{ set +x; } 2>/dev/null ; echo -e "\n\n==================================\nJob started at $(date +"%d/%m/%y %H:%M") UTC" ; set -x

{ set +x; } 2>/dev/null ;
echo -e "\nsend log to $log_file"
# exec >> $log_file 2>&1 # send stdout/stderr to file
echo -e "$job\n" ; # repeated after exec to reroute log
set -x

run_refresh_from_wikipedia=no # do so once every few months
# run_collect_country_stats=no # set to 'no' to speed up repeated tests on one day

# very loose input validation
{ set +x; } 2>/dev/null ; 
echo -e "\n"
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
set -x

file="$csv_sampled/SquidDataVisitsPerCountryMonthly.csv" 
age=$(stat -c %Y $file)
now=$(date +"%s")
days=$(( (now - age) / (60 * 60 * 24) ))
threshold=2 

{ set +x; } 2>/dev/null ; 
echo -e "\nFile '$file' generated at time $age, time now is $now, so age of file is $days days (rounded down)"
if (( $days < $threshold )) 
then
  echo "File is less than $threshold days old, so skip regenerating" 
  run_collect_country_stats=no
fi
echo
set -x

# -c = country reports
# -v = views
# -e = edits
# -s = start month 
# -i = input folder
# -o = output folder
# -a = meta folder (a for >a<bout ~ meta)
# -l = logs folders
# -w = extra data from English Wikipedia
# -m = month to process for basic reports
# -x = sample rate 

cd $perl_squids

args_views_sampled=" -v -i $csv_sampled -o $reports_sampled -a $meta -l $logs -x 1000"

# once every so many months refresh meta info from English Wikipedia 
# this is not ran so often, as Wikipedia page syntax can change anytime, so vetting is needed

{ set +x; } 2>/dev/null ; 
if [ "$run_refresh_from_wikipedia" == "yes" ] ; then
  set -x
  perl SquidReportArchive.pl -w $args_views_sampled  
  exit
fi

{ set +x; } 2>/dev/null ; 
if [ "$run_collect_country_stats" == "yes" ] ; then
  echo -e "\n>> COLLECT PER COUNTRY STATS <<" 
  set -x

  perl SquidCountryAggregateDaily.pl -v -s "2015-05" -i $data_hourly -o $csv_sampled -l $logs 
  perl SquidCountryScan.pl           -v -s "2009-07" -i $csv_sampled                 -l $logs 
fi

cd $perl_traffic
perl TrafficAnalysisGeo.pl -c $args_views_sampled -m $month -b $worldbank_demographics # -c for per country reports 
      rsync -av $reports_sampled/$month/*.htm                           $htdocs/archive/squid_reports/$month/draft2

cp $reports_sampled/$month/datamaps-*.csv $reports_sampled
perl DatamapsBuildJsonFromCsv.pl # paths still hard coded, to be fixed
exit

echo "rsync -av $reports_sampled/$month/*.htm                           $htdocs/wikimedia/squids"
      rsync -av $reports_sampled/$month/*.htm                           $htdocs/wikimedia/squids
echo "rsync -av $reports_sampled/$month/*.htm                           $htdocs/archive/squid_reports/$month"
      rsync -av $reports_sampled/$month/*.htm                           $htdocs/archive/squid_reports/$month

echo "rsync -av $reports_sampled/$month/datamaps*. [csv|js|json]        $htdocs/wikimedia/animations/wivivi/$month"
      rsync -av $reports_sampled/$month/datamaps*.csv                   $htdocs/wikimedia/animations/wivivi/$month
      rsync -av $reports_sampled/$month/datamaps*.js                    $htdocs/wikimedia/animations/wivivi/$month
      rsync -av $reports_sampled/$month/datamaps*.json                  $htdocs/wikimedia/animations/wivivi/$month

echo "rsync -av $reports_sampled/$month/datamaps*. [csv|js|json]        $htdocs/wikimedia/animations/wivivi"
      rsync -av $reports_sampled/$month/datamaps*.csv                   $htdocs/wikimedia/animations/wivivi
      rsync -av $reports_sampled/$month/datamaps*.js                    $htdocs/wikimedia/animations/wivivi
      rsync -av $reports_sampled/$month/datamaps*.json                  $htdocs/wikimedia/animations/wivivi
