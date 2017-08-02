#!/bin/bash
clear
now=`date +%s`

function echo2 {
  echo $1
  echo $1 >> log_publish_sh.txt
}

clear
echo2 "----------------"
echo2 "Start publish.sh $1 $2"
date >> log_publish_sh.txt

# Validate project code
if [ "$1" == "" ]
then
  echo2 "Project code missing! Specify as 1st argument one of wb,wk,wn,wp,wq,ws,wv,wx"
  exit
fi  

# Abort when 3rd argument specifies a threshold in days, which is not met
# This prevents costly processing step when new month has just started and most ocunting still needs to be done
abort_before=$3
day_of_month=$(date +"%d")
if [ $day_of_month -lt ${abort_before:=0} ]
then	  
  echo2 "publish.sh: day of month $day_of_month lt $abort_before - exit"
  exit
/fi

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
echo2 "Publish $project"

#case "$2" in 
#  en) dir="$dir/EN" ;
#esac

htdocs="thorium.eqiad.wmnet::srv/stats.wikimedia.org/$dir/csv"
csv="/a/wikistats/csv_$1"
archive="/mnt/data/xmldatadumps/public/other/pagecounts-ez/wikistats" # odd name, temp location

rm -f $csv/csv.zip  
chmod 774 $csv/*.csv

echo2 ""
echo2 "Copy new/updated csv files from $csv -> $htdocs/$dir/csv"

echo2 ""
rsync -av $csv/*.csv $htdocs/$dir/csv
  
echo2 ""
echo2 "Copy csv and html zip files -> public archive $archive"
echo2 ""
rsync -av /a/wikistats/zip_all/csv*.zip $archive >> log_publish_sh.txt
rsync -av /a/wikistats/zip_all/out*.zip $archive >> log_publish_sh.txt

publish="#publish.txt"

# for lang in EN AST BG BR CA CS DA DE EO ES FR HE HU ID IT JA NL NN PL PT RO RU SK SL SR SV WA ZH
for lang in EN  
do
  out=/a/out/out_$1/$lang/ 

  echo2 ""
  echo2 "Language $lang"
  echo2 ""
  echo2 "Copy new and updated files from $out -> $htdocs/$dir/lang"
  rsync -a $out/* $htdocs/$dir/lang >>  log_publish_sh.txt

#  if test -e $out/WikiReportsPublish.txt
#  then mv $out/WikiReportsPublish.txt "$out/$publish" ; fi ;

#if test -e $out/$publish
#  then 
#    echo2 "New reports generated"
#    cat $out/$publish
#    echo2 "Copy $lang"
#    # rsync [<-cp] $out/* $htdocs -rvf
#    rm $out/$publish
#  else echo "No new files, do not publish"
#  fi
done

echo2 ""
echo2 "Ready"
date >> log_publish_sh.txt
echo2 "-----"


