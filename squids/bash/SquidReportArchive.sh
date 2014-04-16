#! /bin/bash
ulimit -v 8000000

# todo some day: simplify logging
# logs are now written twice (with variations?), inside the script to name file and here by tee from stdout

wikistats=/a/wikistats_git
squids=$wikistats/squids
perl=$squids/perl
perl=/home/ezachte/wikistats/squids-scripts-2012-10/perl/ # temp

csv_sampled=$squids/csv               # views and edits, 1:1000 sampled       
csv_edits_unsampled=$squids/csv_edits # edits only, 1:1 unsampled

reports_sampled=$squids/reports
reports_edits_unsampled=$squids/reports_edits

logs=$squids/logs
meta=$csv_sampled/meta # for bots views and edits use these 'meta' files (lookup for country/region codes) 

htdocs=stat1001.wikimedia.org::a/srv/stats.wikimedia.org/htdocs/

cd $perl

log=$logs/SquidReportArchive.log

month=2014-03  
quarter=2013Q4
quarter2=2013-Q4 # hmm need to remove dash some day 

run_collect_country_stats=no
run_refresh_from_wikipedia=no
run_monthly_countries_reports=no
run_quarterly_countries_reports=yes
run_monthly_non_geo_reports=no

if [ "$run_monthly_countries_reports" == "yes" ] ; then
  run_collect_country_stats=yes
fi
if [ "$run_quarterly_countries_reports" == "yes" ] ; then
  run_collect_country_stats=yes
fi
# run_collect_country_stats=no # speed up repeated tests

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

args_views_sampled="  -v  -i $csv_sampled         -o $reports_sampled         -a $meta -l $logs -x 1000"
args_edits_sampled="  -e  -i $csv_sampled         -o $reports_sampled         -a $meta -l $logs -x 1000"
args_edits_unsampled="-e  -i $csv_edits_unsampled -o $reports_edits_unsampled -a $meta -l $logs -x 1"

# once every so many months refresh meta info from English Wikipedia 
# this is not one too often, as Wikipedia page syntax can change anytime, so vetting is needed
if [ "$refresh_from_wikipedia" == "yes" ] ; then
  perl SquidReportArchive.pl -w $args_views_sampled | tee -a $log | cat # last run Oct 2013
fi

# perl SquidReportArchive.pl -m 201007 > $log
# after further automating SquidScanCountries.sh

# >> COLLECT PER COUNTRY STATS <<
if [ "$run_collect_country_stats" == "yes" ] ; then
  echo ">> COLLECT PER COUNTRY STATS <<" >> $log

  # collect per country page view stats for all months, start in July 2009
  perl SquidCountryScan.pl  -v -s "2009-07" -i $csv_sampled         -l $logs | tee -a $log | cat 
  # collect per country page edit stats for all months, start in July 2013
  perl SquidCountryScan.pl  -e -s "2011-11" -i $csv_edits_unsampled -l $logs | tee -a $log | cat 
fi

# >> WRITE OTHER COUNTRY REPORTS <<
if [ "$run_monthly_countries_reports" == "yes" ] ; then
  echo ">> WRITE OTHER COUNTRY REPORTS <<" >> $log 

  cd $perl
  perl SquidReportArchive.pl -c $args_views_sampled   -m $month | tee -a $log | cat # -c for per country reports
  perl SquidReportArchive.pl -c $args_edits_unsampled -m $month | tee -a $log | cat # -c for per country reports

      ls -l     $reports_sampled/countries/SquidReport*.htm         
echo "rsync -av $reports_sampled/countries/SquidReport*.htm         $htdocs/archive/squid_reports_draft/$month"
      rsync -av $reports_sampled/countries/SquidReport*.htm         $htdocs/archive/squid_reports_draft/$month
      ls -l     $reports_edits_unsampled/countries/SquidReport*.htm 
echo "rsync -av $reports_edits_unsampled/countries/SquidReport*.htm $htdocs/archive/squid_reports_draft/$month"
      rsync -av $reports_edits_unsampled/countries/SquidReport*.htm $htdocs/archive/squid_reports_draft/$month
exit
  rsync -av $reports_sampled/countries/SquidReport*.htm         $htdocs/wikimedia/squids
  rsync -av $reports_edits_unsampled/countries/SquidReport*.htm $htdocs/archive/squid_reports/$month
  
  cd $reports_sampled/countries
  echo "tar -cvf - *.htm | gzip > reports-countries-sampled-$month.tar.gz"
        tar -cvf - *.htm | gzip > reports-countries_sampled-$month.tar.gz
  echo "rsync -av *.gz          $htdocs/archive/squid_reports/$month"
        rsync -av *.gz          $htdocs/archive/squid_reports/$month
  
  cd $reports_edits_unsampled/countries
  echo "tar -cvf - *.htm | gzip > reports-countries-unsampled-$month.tar.gz"
        tar -cvf - *.htm | gzip > reports-countries-unsampled-$month.tar.gz
  echo "rsync -av *.gz  $htdocs/archive/squid_reports/$month"
        rsync -av *.gz  $htdocs/archive/squid_reports/$month
fi

# >> WRITE QUARTERLY COUNTRY REPORTS <<
if [ "$run_quarterly_countries_reports" == "yes" ] ; then
  echo ">> WRITE QUARTERLY COUNTRY REPORTS <<" >> $log

  cd $perl
# generate page view reports from sampled squid logs  
  perl SquidReportArchive.pl  -c -q $quarter $args_views_sampled | tee -a $log | cat 
  rsync -av $reports_sampled/$quarter2/SquidReportPageViewsPerCountryOverview$quarter.htm  $htdocs/wikimedia/squids/SquidReportPageViewsPerCountryOverview$quarter.htm

# obsolete (but kept for reference and fallback): generate page edit reports from sampled squid logs  
# perl SquidReportArchive.pl  -c -q $quarter $args_edits_sampled | tee -a $log | cat 
# rsync -av $reports_sampled/$quarter2/SquidReportPageEditsPerCountryOverview$quarter.htm  $htdocs/wikimedia/squids/SquidReportPageEditsPerCountryOverview$quarter.htm

# generate page edit reports from *un*sampled squid logs  
  perl SquidReportArchive.pl  -c -q $quarter $args_edits_unsampled | tee -a $log | cat 
  rsync -av $reports_edits_unsampled/$quarter2/SquidReportPageEditsPerCountryOverview$quarter.htm  $htdocs/wikimedia/squids/SquidReportPageEditsPerCountryOverview$quarter.htm
fi

if [ "$run_monthly_non_geo_reports" == "yes" ] ; then
  echo ">> WRITE NON-GEO REPORTS <<" >> $log

  cd $perl
  perl SquidReportArchive.pl -m $month $args_views_sampled | tee -a $log | cat

  cd $reports_sampled/$month
  echo "tar -cvf - *.htm | gzip > reports-sampled-$month.tar.gz"
        tar -cvf - *.htm | gzip > reports-sampled-$month.tar.gz
  echo "rsync -av *.gz   $htdocs/archive/squid_reports/$month"
        rsync -av *.gz   $htdocs/archive/squid_reports/$month
  echo "rsync -av *.htm  $htdocs/archive/squid_reports/$month"
        rsync -av *.htm  $htdocs/archive/squid_reports/$month
fi
# after vetting reports are now manually rsynced to 
# - stat1001/a/srv/stats.wikimedia.org/htdocs/wikimedia/squids
# - stat1001/a/srv/stats.wikimedia.org/htdocs/archive/squid_reports/$month

echo Done
# note: all gif and js files are also needed locally, that should change to shared location  
