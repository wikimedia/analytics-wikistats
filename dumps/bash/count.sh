#!/bin/bash

c1()(set -o pipefail;"$@" | perl -pe 's/.*/\e[1;32m$&\e[0m/g') # colorize output green
c2()(set -o pipefail;"$@" | perl -pe 's/.*/\e[1;33m$&\e[0m/g') # colorize output yellow

die () {
    echo >&2 "$@"
    exit 1
}


[ "$#" -eq 1 ] || die "1 argument required, $# provided"

project=$1

if [[ "$project" = "wb" || "$project" = "wk" || "$project" = "wn" || "$project" = "wp" || "$project" = "wq" || "$project" = "ws" || "$project" = "wv" || "$project" = "wx" || "$project" = "wo" ]]
then 
  echo "Process project $1"
else
	echo "Invalid project code: specify wb (wikibooks), wk (wiktionary), wn (wikinews), wo (wikivoyage), wp (wikipedia), wq (wikiquote), ws (wikisource), wv (wikiversity), wx (wikispecial: commons, meta...)" ; exit 
fi
  
ulimit -v 8000000

wikistats=/a/wikistats_git
dumps=$wikistats/dumps                     # folder for scripts and output
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # tests
csv=$dumps/csv
bash=$dumps/bash
dblists=$dumps/dblists
php=/a/mediawiki/core/languages
dumps_public=/mnt/data/xmldatadumps/public # input dumps 

if [[ $project == "wb" ]] ; then 	
  dblist=wikibooks.dblist
fi
if [[ $project == "wk" ]] ; then 	
  dblist=wiktionary.dblist
fi
if [[ $project == "wn" ]] ; then 	
  dblist=wikinews.dblist
fi
if [[ $project == "wo" ]] ; then 	
  dblist=wikivoyage.dblist
fi
if [[ $project == "wp" ]] ; then 	
  dblist=wikipedia.dblist
  edits_only=-e 
fi
if [[ $project == "wq" ]] ; then 	
  dblist=wikiquote.dblist
fi
if [[ $project == "ws" ]] ; then 	
  dblist=wikisource.dblist
fi
if [[ $project == "wv" ]] ; then 	
  dblist=wikiversity.dblist
fi
if [[ $project == "wx" ]] ; then 	
  dblist=special.dblist
fi


#edits_only=-e # run all in 'edits only' (= from stub dump) # Aug 2013: full dump -> zero articles
trace=-r # trace resources
# force=-f # force rerun even when dump for last month has already been processed (comment to disable)
# bz2=-b # comment for default: 7z
# reverts=-u 1 # uncomment to collect revert history only

clear

cd $perl
for x in `cat $dblists/$dblist`
#for x in bswikinews
#do c1 perl WikiCounts.pl $trace $force $reverts $edits_only $bz2 -m $project -i $dumps_public/$x -o $csv/csv_$project/ -l $x -d auto -s $php
do perl WikiCounts.pl $trace $force $reverts $edits_only $bz2 -m $project -i $dumps_public/$x -o $csv/csv_$project/ -l $x -d auto -s $php
done

# $bash/zip_csv.sh $project # move step to cron, count.sh is invoked too often now
