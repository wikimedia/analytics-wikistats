#! /bin/bash -x 
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005 

# replaced (entirely ?) by ../wikistats/traffic/bash/datamaps_views.sh

ulimit -v 12000000

yyyymmddhhnn=$(date +"%Y_%m_%d__%H_%M")

logs=$WIKISTATS_DATA/squids/logs
log=$logs/log_squids_report_$yyyymmddhhnn.txt

exec 1>> $log 2>&1 # send stdout/stderr to file

month=2018-03
quarter=2017Q3
quarter2="${quarter:0:4}-${quarter:4:2}" # hmm need to remove dash in some folders some day 

data_hourly=/mnt/hdfs/wmf/data/archive/projectview/geo/hourly/ 
htdocs=thorium.eqiad.wmnet::stats.wikimedia.org/htdocs/
hdfs_backup=/user/ezachte/wikistats_data/squids

wikistats=$WIKISTATS_SCRIPTS
perl=$wikistats/squids/perl

wikistats_data=$WIKISTATS_DATA
squids=$wikistats_data/squids
csv_sampled=$squids/csv               # views and edits, 1:1000 sampled       
meta=$csv_sampled/meta # for bots views and edits use these 'meta' files (lookup for country/region codes) 
#csv_edits_unsampled=$squids/csv_edits # edits only, 1:1 unsampled

reports_sampled=$squids/reports
#reports_edits_unsampled=$squids/reports_edits # input no longer avaiable 

cd $perl

{ set +x; } 2>/dev/null ; 

#init values (echo final values later in the script)
run_backup_data_to_hdfs=no
run_collect_country_stats=yes
run_refresh_from_wikipedia=no # run every half year or so 
run_monthly_countries_reports=yes
run_quarterly_countries_reports=no
run_monthly_non_geo_reports=no # deprecated

# very loose input validation
if [ "$1" != "" ]
then
  echo "Argument provided: $1"
  if [[ $1 =~ ^2[0-9][0-9][0-9]-[0-1][0-9]$ ]]
  then 
    echo "Month provided: $1"
    month=$1
    run_monthly_countries_reports=yes
    run_quarterly_countries_reports=no
  elif [[ $1 =~ ^2[0-9][0-9][0-9]Q[1-4]$ ]]  
  then 
    echo "Quarter provided: $1"
    quarter=$1
    run_monthly_countries_reports=no
    run_quarterly_countries_reports=yes
  else 
    echo "Unexpected argument: $1"
    exit
  fi
fi


if [ "$run_monthly_countries_reports" == "yes" ] ; then
  run_collect_country_stats=yes
fi
if [ "$run_quarterly_countries_reports" == "yes" ] ; then
  run_collect_country_stats=yes
fi

set -x
file="$csv_sampled/SquidDataVisitsPerCountryMonthly.csv" 
age=$(stat -c %Y $file)
now=$(date +"%s")
days=$(( (now - age) / (60 * 60 * 24) ))
threshold=2 
{ set +x; } 2>/dev/null ; 

echo "$file age: $age secs secs, now: $now secs -> age $days days"
if (( $days < $threshold )) 
then
  echo "File $file less than $threshold days old, skip regenerating" 
  run_collect_country_stats=no
fi

# run_collect_country_stats=no # overrule file date based decision above, for repeated runs

echo
echo run_backup_data_to_hdfs
echo run_collect_country_stats:$run_collect_country_stats
echo run_refresh_from_wikipedia:$run_refresh_from_wikipedia
echo run_monthly_countries_reports:$run_monthly_countries_reports
echo run_quarterly_countries_reports:$run_quarterly_countries_reports
echo run_monthly_non_geo_reports:$run_quarterly_countries_reports 
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

set -x
args_views_sampled="  -v  -i $csv_sampled         -o $reports_sampled         -a $meta -l $logs -x 1000"
args_edits_sampled="  -e  -i $csv_sampled         -o $reports_sampled         -a $meta -l $logs -x 1000"
args_edits_unsampled="-e  -i $csv_edits_unsampled -o $reports_edits_unsampled -a $meta -l $logs -x 1"



# >> BACKUP_DATA_TO_HDFS <<
# run this first, as end of bash file may not always be reached, due to early exit

{ set +x; } 2>/dev/null ; 
if [ "$run_backup_data_to_hdfs" == "yes" ] ; then
  echo -e "\n >> BACKUP DATA TO HDFS <<\n"
  set -x  
  cd "$wikistats_data/squids/csv/"
  hdfs dfs -put -p * "$hdfs_backup/csv/" 

  cd "$wikistats_data/squids/csv_edits/"
  hdfs dfs -put -p * "$hdfs_backup/csv_edits/" 

  cd "$wikistats_data/squids/reports/"
  hdfs dfs -put -p * "$hdfs_backup/reports/" 

  cd "$wikistats_data/squids/reports_edits/"
  hdfs dfs -put -p * "$hdfs_backup/reports_edits/" 

  hdfs dfs -ls -R $hdfs_backup > "$wikistats_data/squids/logs/files_in_hdfs" 
  exit
fi


# >> COLLECT META DATA FROM WIKIPEDIA <<

{ set +x; } 2>/dev/null ; 
if [ "$run_refresh_from_wikipedia" == "yes" ] ; then
  echo -e "\n >> COLLECT META DATA FROM WIKIPEDIA <<\n"
  set -x ; perl SquidReportArchive.pl -w $args_views_sampled # last run Feb 2016
  exit
fi



# once every so many months refresh meta info from English Wikipedia 
# this is not one too often, as Wikipedia page syntax can change anytime, so vetting is needed

{ set +x; } 2>/dev/null ; 
if [ "$run_refresh_from_wikipedia" == "yes" ] ; then
  echo -e "\n >> COLLECT META DATA FROM WIKIPEDIA <<\n"
  set -x ; perl SquidReportArchive.pl -w $args_views_sampled # last run Feb 2016
  exit
fi

# already commented before migration to stat1005, keep ?
# ?? perl SquidReportArchive.pl -m 201007 > $log
# ?? after further automating SquidScanCountries.sh



# >> COLLECT PER COUNTRY STATS <<

# reads 
# SquidDataCountriesViews.csv
#
# produces 
# SquidDataVisitsPerCountryMonthly.csv
# SquidDataVisitsPerCountryPerWikiDaily.csv
# SquidDataVisitsPerCountryPerProjectDaily.csv
# SquidDataVisitsPerCountryDailyDetailed.csv

# reads 
# SquidDataCountriesSaves.csv
#
# produces 
# SquidDataSavesPerCountryMonthly.csv
# SquidDataSavesPerCountryPerWikiDaily.csv
# SquidDataSavesPerCountryPerProjectDaily.csv
# SquidDataSavesPerCountryDailyDetailed.csv

{ set +x; } 2>/dev/null ; 
if [ "$run_collect_country_stats" == "yes" ] ; then
  echo -e  "\n>> COLLECT PER COUNTRY STATS <<\n"

  cd $perl
  set -x
  perl SquidCountryAggregateDaily.pl -v -s "2015-05" -i $data_hourly -o $csv_sampled -l $logs  

  # collect per country page view stats for all months, start in July 2009
  perl SquidCountryScan.pl  -v -s "2009-07" -i $csv_sampled -l $logs 

  # up to date edit stats no longer available, hence these lines are no longer used until further notice 
  # collect per country page edit stats for all months, start in Nov 2011 (comment said earlier July 2013 (?))
  # perl SquidCountryScan.pl  -e -s "2011-11" -i $csv_edits_unsampled -l $logs 
  # no edits: perl SquidCountryScan.pl  -e -s "2011-11" -i $csv_sampled   -l $logs
fi

{ set +x; } 2>/dev/null ; 


# >> WRITE MONTHLY COUNTRY REPORTS <<
if [ "$run_monthly_countries_reports" == "yes" ] ; then
  echo -e "\n>> WRITE MONTHLY COUNTRY REPORTS <<\n"  

  cd $perl
  perl SquidReportArchive.pl -c $args_views_sampled   -m $month # -c for per country reports
# perl SquidReportArchive.pl -c $args_edits_unsampled -m $month # -c for per country reports

# no edits: perl SquidReportArchive.pl -c $args_edits_sampled   -m $month # -c for per country reports

#      ls -l     $reports_sampled/countries/SquidReport*Per*.htm         
# echo "rsync -av $reports_sampled/countries/SquidReport*Per*.htm         $htdocs/archive/squid_reports_draft/$month"
#       rsync -av $reports_sampled/countries/SquidReport*Per*.htm         $htdocs/archive/squid_reports_draft/$month

  ls -l     $reports_sampled/$month/SquidReportPageViewsPer*.htm         
  rsync -av $reports_sampled/$month/SquidReportPageViewsPer*.htm                   $htdocs/archive/squid_reports/$month
  rsync -av $reports_sampled/$month/SquidReportPageViewsPer*.htm                   $htdocs/wikimedia/squids

# no edits:       ls -l     $reports_sampled/$month/SquidReportPageEditsPer*.htm         
# no edits: echo "rsync -av $reports_sampled/$month/SquidReportPageEditsPer*.htm                   $htdocs/archive/squid_reports/$month"
# no edits:       rsync -av $reports_sampled/$month/SquidReportPageEditsPer*.htm                   $htdocs/archive/squid_reports/$month
# ls -l     $reports_edits_unsampled/countries/SquidReport*.htm 
# rsync -av $reports_edits_unsampled/countries/SquidReport*.htm $htdocs/archive/squid_reports_draft/$month
# exit
# rsync -av $reports_sampled/countries/SquidReport*.htm         $htdocs/wikimedia/squids
# no edits: rsync -av $reports_edits_unsampled/countries/SquidReport*.htm $htdocs/archive/squid_reports/$month
  
  cd $reports_sampled/countries
  tar -cvf - *.htm | gzip > reports-countries_sampled-$month.tar.gz
  rsync -av *.gz          $htdocs/archive/squid_reports/$month
  
# cd $reports_edits_unsampled/countries
# tar -cvf - *.htm | gzip > reports-countries-unsampled-$month.tar.gz
# rsync -av *.gz  $htdocs/archive/squid_reports/$month
fi



# >> WRITE QUARTERLY COUNTRY REPORTS <<
if [ "$run_quarterly_countries_reports" == "yes" ] ; then
  echo ">> WRITE QUARTERLY COUNTRY REPORTS <<" 

  cd $perl
# generate page view reports from sampled squid logs  
  perl SquidReportArchive.pl  -c -q $quarter $args_views_sampled
  rsync -av $reports_sampled/$quarter2/SquidReportPageViewsPerCountryOverview$quarter.htm  $htdocs/wikimedia/squids/SquidReportPageViewsPerCountryOverview$quarter.htm

# no longer obsolete (has been kept for reference and fallback): generate page edit reports from sampled squid logs  
# no edits: perl SquidReportArchive.pl  -c -q $quarter $args_edits_sampled
  rsync -av $reports_sampled/$quarter2/SquidReportPageEditsPerCountryOverview$quarter.htm  $htdocs/wikimedia/squids/SquidReportPageEditsPerCountryOverview$quarter.htm

# generate page edit reports from *un*sampled squid logs  
# perl SquidReportArchive.pl  -c -q $quarter $args_edits_unsampled
# rsync -av $reports_edits_unsampled/$quarter2/SquidReportPageEditsPerCountryOverview$quarter.htm  $htdocs/wikimedia/squids/SquidReportPageEditsPerCountryOverview$quarter.htm
fi

if [ "$run_monthly_non_geo_reports" == "yes" ] ; then
  echo ">> WRITE NON-GEO REPORTS <<" 

  cd $perl
  perl SquidReportArchive.pl -m $month $args_views_sampled

  cd $reports_sampled/$month
  echo "tar -cvf - *.htm | gzip > reports-sampled-$month.tar.gz"
        tar -cvf - *.htm | gzip > reports-sampled-$month.tar.gz
  echo "rsync -av *.gz   $htdocs/archive/squid_reports/$month"
        rsync -av *.gz   $htdocs/archive/squid_reports/$month
  echo "rsync -av *.htm  $htdocs/archive/squid_reports/$month"
        rsync -av *.htm  $htdocs/archive/squid_reports/$month
fi
# after vetting reports are now manually rsynced to 
# - thorium stats.wikimedia.org/htdocs/wikimedia/squids

# - thorium stats.wikimedia.org/htdocs/archive/squid_reports/$month

# note: all gif and js files are also needed locally, that should change to shared location 
 
echo Ready 
