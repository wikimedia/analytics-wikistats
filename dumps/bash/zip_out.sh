#!/bin/bash

ulimit -v 8000000

wikistats=/a/wikistats_git
out=$wikistats/dumps/out

dataset1001=dataset1001.wikimedia.org::pagecounts-ez/wikistats

if [ "$1" == "" ] ; then
  echo "Project code missing! Specify as 1st argument one of wb,wk,wm,wn,wp,wq,ws,wv,wx"
  exit
fi  

rm $out/zip_all/out_$1.zip

if [ "$1" == "wm" ] ; then
  cd $out/out_$1
else
  cd $out/out_$1/EN
fi

zip -q -r $out/zip_all/out_$1.zip *

echo rsync -ipv4 -avv $out/zip_all/out_w*.zip $dataset1001
rsync -ipv4 -avv $out/zip_all/out_w*.zip $dataset1001
