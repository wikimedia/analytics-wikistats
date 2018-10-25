#!/bin/bash -x
# read more about set -x/+x (and why used) in ../../wikistats/read.me
# script migrated to stat1005

ulimit -v 8000000

yyyymmddhhnn=$(date +"%Y_%m_%d__%H_%M")
projectcode='wp_de' 

# announce script name/arguments and (file name compatible) start time
{ set +x; } 2>/dev/null ;
b="##########" ; bar="$b$b$b$b$b$b$b$b$b$b" # will be invoked many times by parent script, hence this separator line
me=`basename "$0"` ; args=${@} ; yyyymmddhhnn=$(date +"%Y_%m_%d__%H_%M") ; job="## $yyyymmddhhnn Job:$me args='$args' ##" ;
echo -e "$bar\n$hr\n$job\n" ;
set -x

wikistats=$WIKISTATS_SCRIPTS
wikistats_data=$WIKISTATS_DATA
perl=$wikistats/dumps/perl
dumps_public=/mnt/data/xmldatadumps/public/dewiki/20171001 # contains all xml files for one wiki, one pass of dump scripts
dumps_extracted=$wikistats_data/dumps/xml
# file_select_titles=$dumps_extracted/Wiki-Studie-100-Wirkstoffe.txt
file_select_titles="/home/ezachte/wikistats_data/dumps/csv/csv_wp/EditsTitlesMissingDE_2004_05_ns0.csv" ;
file_select_titles="/home/ezachte/wikistats_data/dumps/xml/EditsTitlesMissingDE_2004_05_ns0.csv" ;

log_dir=$WIKISTATS_DATA/dumps/logs/extract_dump_articles ; mkdir -m 775 $log_dir >/dev/null 2>&1
log=$log_dir/log_extract_dump_articles_${projectcode}_$yyyymmddhhnn.txt
exec 1>> $log 2>&1 # send stdout/stderr to file

#dumps=$wikistats/dumps
#csv=$dumps/csv
#out=$dumps/out
#htdocs=thorium.eqiad.wmnet::srv/stats.wikimedia.org/htdocs/

cd $perl

# Q&D script: for now, edit hard coded paths in perl file for input and output files
perl WikiDumpExtractArticles.pl -i $dumps_public -o $dumps_extracted -s $file_select_titles 
