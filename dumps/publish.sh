#!/bin/bash
abort_before=$3
day_of_month=$(date +"%d")
if [ $day_of_month -lt ${abort_before:=0} ]
then	  
  echo publish.sh: day of month $day_of_month lt $abort_before - exit
  exit
fi

clear
case "$1" in 
  wb) project='Wikibooks' ;     dir='wikibooks' ;;
  wk) project='Wiktionaries' ;  dir='wiktionary' ;;
  wn) project='Wikinews' ;      dir='wikinews' ;;
  wp) project='Wikipedias' ;    dir='.' ;;
  wq) project='Wikiquotes' ;    dir='wikiquote' ;;
  ws) project='Wikisources' ;   dir='wikisource' ;;
  wv) project='Wikiversities' ; dir='wikiversity' ;;
  wx) project='Wikispecial' ;   dir='wikispecial' ;;
  *)  project='unknown' ;       dir='...' ;; 
esac  
echo "Publish $project" >> WikiCountsLogConcise.txt
echo "Publish $project"

#case "$2" in 
#  en) dir="$dir/EN" ;
#esac

echo "Copy csv files"
csv=/a/wikistats/csv_$1
htdocs=/mnt/htdocs/$dir/csv
echo csv $csv
echo htdocs $htdocs

chmod 774 $csv/*  
#cp $csv/csv_$1.zip $csv/csv.zip
#rm $csv/csv.zip # temp, obsolete file 
#rm -f $htdocs/*
cp $csv/* $htdocs -rvf 

cp /a/wikistats/zip_all/csv_$1.zip /mnt/htdocs

publish=\#publish.txt

for lang in EN AST BG BR CA CS DA DE EO ES FR HE HU ID IT JA NL NN PL PT RO RU SK SL SR SV WA ZH
#for lang in EN 
do
  out=/a/out/out_$1/$lang 
  htdocs=/mnt/htdocs/$dir/$lang
  echo out $out
  echo htdocs $htdocs
  echo dir $dir
  echo lang $lang
#  if test -e $out/WikiReportsPublish.txt
#  then mv $out/WikiReportsPublish.txt "$out/$publish" ; fi ;


#if test -e $out/$publish
#  then 
    echo "New reports generated:\n"
    cat $out/$publish
    echo "\n\nCopy $lang\n\n"
    cp $out/* $htdocs -rvf
    rm $out/$publish
#  else echo "No new files, do not publish"
#  fi
done


