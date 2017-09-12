#!/bin/bash
ulimit -v 8000000

# collect counts from dumps for all wikis that belong to one Wikimedia project (e.g. all Wikipedias)
# e.g. 'count.sh wp'

if [ "$#" -lt 1 ] ; then echo "1 or 2 arguments required, $# provided" ; exit 1 ; fi
if [ "$#" -gt 2 ] ; then echo "1 or 2 arguments required, $# provided" ; exit 1 ; fi

project=$1
log_job="/dev/null"
if [ "$#" -eq 2 ] ; then log_job=$2 ; echo Log job steps to "'$log_job'" ; fi

if [[ "$project" =~ wb|wk|wn|wp|wq|ws|wv|wx|wo ]]
then 
  echo "Process project $1"
else
  echo "Invalid project code: specify wb (wikibooks), wk (wiktionary), wn (wikinews), wo (wikivoyage), wp (wikipedia), wq (wikiquote), ws (wikisource), wv (wikiversity), wx (wikispecial: commons, meta...)" ; exit 
fi
  
set -x
dumps_public=/mnt/data/xmldatadumps/public # the huge xml files to be parsed  
php=/a/mediawiki/core/languages            # parsed for certain language specific keywords 

wikistats=$WIKISTATS_SCRIPTS
perl=$wikistats/dumps/perl 
bash=$wikistats/dumps/bash

wikistats_data=$WIKISTATS_DATA
csv=$wikistats_data/dumps/csv
dblists=$wikistats_data/dumps/dblists      # list of wikis in a project, see also below
set +x

# File [xxx].dblist is a list of all dump prefixes, e.g. enwiki, for English Wikipedia, enwiktionary for English Wiktionary.
# These lists are manually maintained, Wikistats no longer uses dblists which are maintained outside Wikistats.

# Originally existing dblists were used here as well,
# but once someone by mistake added a private wiki to one of those lists,
# and private data leaked via Wikistats (e.g. articles names, shown in Wikistats ZeitGeist reports).
# It proved quite a lot of work to clean data for that wiki from all csv files.  
# Hence manual maintenance of dblists, to prevent such an issue happening again. 

case "$project" in
  wb) projectname='Wikibooks' ;     dblist='wikibooks.dblist' ;;
  wk) projectname='Wiktionary' ;    dblist='wiktionary.dblist' ;;
  wn) projectname='Wikinews' ;      dblist='wikinews.dblist' ;;
  wo) projectname='Wikivoyage' ;    dblist='wikivoyage.dblist' ;;
  wp) projectname='Wikipedia' ;     dblist='.' ;                   edits_only=-e  ;;
  wq) projectname='Wikiquote' ;     dblist='wikiquote.dblist' ;;
  ws) projectname='Wikisource' ;    dblist='wikisource.dblist' ;;
  wv) projectname='Wikiversity' ;   dblist='wikiversity.dblist' ;;
  wx) projectname='Wikispecial' ;   dblist='special.dblist' ;;
  *)  projectname='unknown' ;       dblist='...' ;;
esac

echo project=$project $projectname
echo dblist=$dblist
exit
# Command line options: 

# optional:  (comment following lines if default should be used)
# edits_only=-e        # run all in 'edits only' (= from stub dump) # Aug 2013: full dump -> zero articles
  trace=-r             # trace resources
# force=-f             # force rerun even when dump for last month has already been processed
# bz2=-b               # dump extension, default: 7z
# reverts=-u 1         # uncomment to collect revert history only (-u from undo, -r as in use already)

# required:              
# -m                   # project (-m from 'mode'), e.g. '-m wp' project = Wikipedia
# -l                   # wiki    (-l from 'language', though some wiki names aren't about languages, like wikicommons)  
# -i                   # input folder (dumps) 
# -o                   # output folder (csv files)
# -d                   # dump date (either specific date or 'auto', which means last date for which dumps are available)
# -s                   # php languages files (-s from 'sources')

clear

cd $perl
for wiki in `cat $dblists/$dblist`
do 
  if [[ "$wiki" =~ ^(enwiki|dewiki|jawiki)$ ]] ; then
    echo "Skip Wikipedia wiki '$wiki' (will be counted in separate job, for more paralellization"
    continue
  fi

  # to add: log exit codes, see http://bencane.com/2014/09/02/understanding-exit-codes-and-how-to-use-them-in-bash-scripts/
  echo >> $log_job
  start_time=`date +%s`
  cmd="  perl WikiCounts.pl -m $project -l $wiki $trace $force $reverts $edits_only $bz2 -i $dumps_public/$wiki -o $csv/csv_$project/ -d auto -s $php"
  date "+%Y-%m-%d %H:%M: count project: $project=$projectname, wiki: $wiki" >> $log_job
  echo -e "$cmd" >> $log_job
  $cmd # execute perl step
  echo -e "run time: $(expr `date +%s` - $start_time) sec" >> $log_job
done

# $bash/zip_csv.sh $project # move step to cron, count.sh is invoked too often now
