#! /bin/bash -x 
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

yyyymmddhhnn=$(date +"%Y_%m_%d__%H_%M")

# announce script name/arguments and (file name compatible) start time
{ set +x; } 2>/dev/null ;
b="##########" ; bar="$b$b$b$b$b$b$b$b$b$b" # will be invoked many times by parent script, hence this separator line
me=`basename "$0"` ; args=${@} ; yyyymmddhhnn=$(date +"%Y_%m_%d__%H_%M") ; job="## $yyyymmddhhnn Job:$me args='$args' ##" ;
echo -e "$bar\n$hr\n$job\n" ;
set -x

ulimit -v 2000000
# ulimit -s 32768
keep logging dewstination 'as is', may already be redirected by calling bash file 'count_report_publish.sh'
log_dir=$WIKISTATS_DATA/dumps/logs/report_one_project ; mkdir -m 775 $log_dir >/dev/null 2>&1
log=$log_dir/log_report_one_project_${projectcode}_$yyyymmddhhnn.txt
exec 1>> $log 2>&1 # send stdout/stderr to file
projectcode="$1"  # repeat for log file
{ set +x; } 2>/dev/null ; echo $job ; set -x # repeat for log file

projectcode=$1
mode_publish=$2

{ set +x; } 2>/dev/null # trace bash commands off for echos
echo -e "\nArguments for report.sh: 1:'$1', 2:'$2', 3:'$3', 4:'$4', 5:'$5'"

if [[ "$projectcode" =~ wb|wk|wn|wp|wq|ws|wv|wx|wo ]]
  then
    echo -e "\nProcess project code $1"
  else
    echo -e "\nInvalid project code: specify wb (wikibooks), wk (wiktionary), wn (wikinews), wo (wikivoyage), wp (wikipedia), wq (wikiquote), ws (wikisource), wv (wikiversity), wx (wikispecial: commons, meta...)" ; exit
fi
echo
set -x

htdocs=thorium.eqiad.wmnet::stats.wikimedia.org/htdocs/ # publish reports on this server

wikistats=$WIKISTATS_SCRIPTS
perl=$wikistats/dumps/perl
bash=$wikistats/dumps/bash

wikistats_data=$WIKISTATS_DATA
out=$wikistats_data/dumps/out
csv=$wikistats_data/dumps/csv
csv_pv=$wikistats_data/dammit/projectviews/csv
dblists=$wikistats_data/dumps/dblists      # list of wikis in a project, see also below

{ set +x; } 2>/dev/null
echo -e "\nUpdate English reports for project '$projectcode' whenever input csv files are newer than html reports"
echo -e "Update reports for other 25+ languages at most once a month, to economize processing time" 
echo -e "Whenever English reports have been updated run archive job (not active now)"
echo -e "Only update non-English reports once per 'interval' days" 
echo -e "force_run_report determines if report are always generated, init at 1 (= yes)\n" 
set -x

interval=0   
force_run_report=1

# why 'draft' reports?
# many years ago, the process was fully automated, then a mishap occurred that made all counts far too low
# as this process always regenerates all reports for all historic months the last month wasn't detected as outlier
# instead some people assumed this was on purpose and all previous cycles had been totally wrong
# without asking me, an alarmistic article was submitted to the German equivalent of the Signpost
# hence since then there is always a manual vetting phase before publishing the final stats
# (add command line option 'final' to report.sh, as is done in report_all.sh)

{ set +x; } 2>/dev/null 
echo -e "\nDetermine publication mode, based on \$mode_publish, which is '$mode_publish'"
if [[ "$mode_publish" == "final" ]]
then
  echo -e "Publish final reports" 	
else
  echo -e "Publish draft reports" 	
fi	

#if [ "$1" == "" ] ; then
#  echo -e "Project code missing! Specify as 1st argument one of wb,wk,wn,wo,wp,wq,ws,wv,wx"
#  exit
#fi  

{ set +x; } 2>/dev/null
echo -e "\nAbort when 2nd argument specifies a threshold for day of month which is not met"
echo -e "This prevents costly reporting step when new month has just started and most counting still needs to be done"
abort_before=$2
if [ "$abort_before" != "" ] ; then
  echo -e "Threshold day of month specified: abort before day of month '$abort_before'" 
  day_of_month=$(date +"%d")
  if [ $day_of_month -lt ${abort_before:=0} ] ; then
    echo -e "Day of month '$day_of_month' lt threshold '$abort_before' -> exit\n" 
    exit
  else
    echo -e "Day of month '$day_of_month' equal of above threshold $abort_before -> continue\n" 
  fi
  else
    echo -e "No threshold day of month specified -> continue\n" 
fi  
set -x

# Once in a while update and cache language names in so many target languages
# Sources are TranslateWiki and interwiki links on English Wikipedia 
# ./sync_language_files.sh 

do_zip=0 # trigger archive step ?

{ set +x; } 2>/dev/null
case "$projectcode" in 
  wb) project='Wikibooks' ;   dir='wikibooks' ;;
  wk) project='Wiktionary' ;  dir='wiktionary' ;;
  wn) project='Wikinews' ;    dir='wikinews' ;;
  wo) project='Wikivoyage' ;  dir='wikivoyage' ;;
  wp) project='Wikipedia' ;   dir='.' ;;
  wq) project='Wikiquotes' ;  dir='wikiquote' ;;
  ws) project='Wikisource' ;  dir='wikisource' ;;
  wv) project='Wikiversity' ; dir='wikiversity' ;;
  wx) project='Wikispecial' ; dir='wikispecial' ;;
  *)  project='unknown' ;     dir='...' ;;
esac 
echo -e "projectcode -> $project, dir = $dir\n" 
set -x

{ set +x; } 2>/dev/null ; 
echo -e "\nNow start doing something" 
echo -e "======================================================="
echo -e "Generate and publish reports for project $projectcode=$project\n"  
set -x

# for langcode in en # test
for langcode in en de ast bg br ca cs da eo es fr he hu id it ja nl nn pl pt ro ru sk sl sr sv wa zh ;
do
  { set +x; } 2>/dev/null  
  echo -e "\n>>> loop with $projectcode:$langcode\n"

  if [[ "$langcode" != "en" ]] 
  then	  
    if [[ "$mode_publish" != "final" ]]
    then
      echo -e "Only process target language in draft mode\n"
      exit	  
    fi
  fi  
  set -x

  { set +x; } 2>/dev/null ; echo -e "\n\nGet timestamp last reports for language $langcode" 
  langcode_upper=$( echo -e "$langcode" | tr '[:lower:]' '[:upper:]' )	
  
  { set +x; } 2>/dev/null ; echo -e "\n\nSet source and destination paths for publishing reports" 
  out_project=$out/out_$1/$langcode_upper 
  htdocs_project=$htdocs/$dir/$langcode_upper
  if [[ "$mode_publish" != "final" ]]
  then
    htdocs_project=$htdocs_project/draft
  fi

  
  { set +x; } 2>/dev/null  
  echo -e "\n\nTarget folder $out_project" 
  file=$out/out_$1/$langcode_upper/index.html	
  now=`date +%s`
  prevrun=`stat -c %Y $file`
  let secs_out="$now - $prevrun" 
  let days_out="$secs_out/86400"
  echo -e "days_out=$days_out days" 
  echo -e "File '$file' generated $days_out days ago\n" 

  echo -e "Get timestamp for most recent csv files" 
  file=$csv/csv_$1/StatisticsLog.csv	
  now=`date +%s`
  prevrun=`stat -c %Y $file`
  let secs_csv="$now - $prevrun" 
  let days_csv="$secs_csv/86400" 
  echo -e "File '$file' generated $days_csv days ago\n\n" 

  echo -e "Check if reports need to be run now for language $langcode" 
  
  run_report=0

  if [ $force_run_report -ne 0 ] ; then
    echo -e "Forced run of reports"					
    run_report=1		
    do_zip=1 
  else  
    if [ "$secs_csv" -lt "$secs_out" ] ; then
      echo -e "Csv files are newer than reports ... "

      if [ "$langcode" == "en" ] ; then
        do_zip=1
        run_report=1
      else  
        echo -e "$days_out days since reports were generated, reporting interval is $interval days"  
        if [ $days_out -gt $interval ] ; then
          run_report=1
        else
          if [ "$force_run_report" -ne 0 ] ; then
            echo -e "Skip reporting for non-English languages, only update these once every $interval days"
          fi							
        fi	
      fi  
    else
      echo -e "Reports for language code '$langcode' are up to date -> skip reporting"			
    fi  
  fi
  echo -e "run_report=$run_report, do_zip=$do_zip\n\n"			

  if [ $run_report -eq 1 ] ; then
    echo -e "Generate reports for language $langcode_upper"
    
    set -x ; 
    cd $perl
    perl WikiReports.pl -m $1 -l $langcode -i $csv/csv_$1/ -j $csv_pv/csv_$1 -o $out/out_$1
    cd $bash
    { set +x; } 2>/dev/null ; 

    echo -e "\n\nCopy new and updated files\nfrom $out_project\nto $htdocs_project\n" 
  
    if [ "$langcode" == "en" ] ; then
      if [[ "$mode_publish" == "final" ]]
      then	      
	echo -e "List files (except charts) from target folder older than a day"
        set -x ; 
        find $out_project/ -mtime +1 | xargs ls -l | grep -P -v 'svg|png' # rather than 'ls -l [dir]' 
        { set +x; } 2>/dev/null ; 

        echo -e "Publish final en"
      else
        echo -e "Publish draft en"
      fi	      
    else  
      if [[ "$mode_publish" == "final" ]]
      then	      
        echo -e "Publish final $projectcode"
      fi	
    fi

    filecount=`ls -l $out_project | grep -v ^1 | wc -l`
    echo -e "\nFile count in $out_project is $filecount\n" 

    echo rsync -av $out_project/\* $htdocs_project/ 
    rsync -av $out_project/* $htdocs_project/ 
  fi
  
  echo -e "\n>>> end of loop with $projectcode:$langcode\n"
set -x
done
{ set +x; } 2>/dev/null ; 

# Generate category overviews (deactivated, reports became too large, lines kept for reference)
# perl $perl/WikiReports.pl -c -m $1 -l en -i $csv/csv_$1/ -o $out/out_$1 

echo

# Archive English reports
#if [ $do_zip -eq 1 ] ; then
#  echo -e "Archive new English reports" 
#  cd $bash
#  ./zip_out.sh $1
#else
#  echo "No English reports built. Skip zip phase"							
#fi  

echo -e "\nReady" 

