#!/bin/bash
ulimit -v 400000000

wikistats=/a/wikistats_git
squids=$wikistats/squids
csv=$squids/csv

scripts=/home/ezachte/wikistats # test
hive=$scripts/hive
hql=$hive/hql

#year=2015 ; month=8 ; day=31 ; hour=12 
#cat $hql/views_geo.hql | sed 's/arg_yyyy/'$year'/' | sed 's/arg_mm/'$month'/' | sed 's/arg_dd/'$day'/' | sed 's/arg_hh/'$hour'/' > $hql/views_geo_actualized.hql 
#hive -f $hql/views_geo_actualized.hql | sed 's/,/\%2C/g'| sed 's/\t/,/g' | sed 's/(. (tok_table_or_col s) \([a-z_][a-z_]*\))/\1/g' | bzip2 -c > $hql/views_geo3c.csv.bz2 
#exit

# for day in `seq -f "%02g" 1 31` 
year=2015
#for month in `seq -f "%02g" 7 11`
for month in `seq -f "%02g" 10`
do 
  path_yyyy_mm=$csv'/'$year'-'$month ;
  if [ -d $path_yyyy_mm ]; then 
    echo "" ;  # "path $path_yyyy_mm exists" ; 
  else
    echo "path $path_yyyy_mm does not exist -> create" ;
    mkdir $path_yyyy_mm ; 
  fi

  for day in `seq -f "%02g" 1 31`
  do
     path_yyyy_mm_dd=$path_yyyy_mm'/'$year'-'$month'-'$day ;
     path_public=$path_yyyy_mm_dd'/public' ;

     if [ -d $path_yyyy_mm_dd ]; then
       echo "" ; # "path $path_yyyy_mm_dd exists" ; 
     else
       echo "path $path_yyyy_mm_dd does not exist -> create $path_yyyy_mm_dd[/public]" ; 
       mkdir $path_yyyy_mm_dd ;
       mkdir $path_public ;
     fi
       
     if [ -d $path_public ]; then
       # patch variables with sed, somehow I can't ${hivevar:year} make to work  
       echo "" ;
       echo "$hql/views_geo.hql | sed 's/arg_yyyy/'$year'/' | sed 's/arg_mm/'$month'/' | sed 's/arg_dd/'$day'/' > $path_public/views_geo.hql" 
       cat   $hql/views_geo.hql | sed 's/arg_yyyy/'$year'/' | sed 's/arg_mm/'$month'/' | sed 's/arg_dd/'$day'/' > $path_public/views_geo.hql 
       echo "hive -f $path_public/views_geo.hql | sed 's/,/\%2C/g'| sed 's/\t/,/g' | sed 's/(. (tok_table_or_col s) \([a-z_][a-z_]*\))/\1/g' | bzip2 -c > $path_public/views_geo.csv.bz2" 
       hive       -f $path_public/views_geo.hql | sed 's/,/\%2C/g'| sed 's/\t/,/g' | sed 's/(. (tok_table_or_col s) \([a-z_][a-z_]*\))/\1/g' | bzip2 -c > $path_public/views_geo.csv.bz2 
     else
       echo "path $path_public could not be created" ; 
     fi
  done
done

# hive 
