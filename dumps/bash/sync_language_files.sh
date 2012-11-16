#!/bin/sh

exit # needs further testing after move to stat1

echo "Sync language files" ;
csv=/a/wikistats/csv ;

file1="LanguageNamesViaPhp.csv" ;

# seed with files

# note: cp -p = preserve timestamps etc

if ! test -e $csv/$file1 && test -e $csv/csv_wb/$file1 
then echo "copy from csv_wb" ; cp $csv/csv_wb/LanguageNames*.csv $csv ; fi ;
	
if ! test -e $csv/$file1 && test -e $csv/csv_wk/$file1
then echo "copy from csv_wk" ; cp $csv/csv_wk/LanguageNames*.csv $csv ; fi ;

if ! test -e $csv/$file1 && test -e $csv/csv_wn/$file1
then echo "copy from csv_wn" ; cp $csv/csv_wn/LanguageNames*.csv $csv ; fi ;

if ! test -e $csv/$file1 && test -e $csv/csv_wp/$file1
then echo "copy from csv_wp" ; cp $csv/csv_wp/LanguageNames*.csv $csv ; fi ;
	
if ! test -e $csv/$file1 && test -e $csv/csv_wq/$file1
then echo "copy from csv_wq" ; cp $csv/csv_wq/LanguageNames*.csv $csv ; fi ;
if ! test -e $csv/$file1 && test -e $csv/csv_ws/$file1
then echo "copy from csv_ws" ; cp $csv/csv_ws/LanguageNames*.csv $csv ; fi ;
	
if ! test -e $csv/$file1 && test -e $csv/csv_wv/$file1
then echo "copy from csv_wv" ; cp $csv/csv_wv/LanguageNames*.csv $csv ; fi ;

if ! test -e $csv/$file1 && test -e $csv/csv_wx/$file1
then echo "copy from csv_wx" ; cp $csv/csv_wx/LanguageNames*.csv $csv ; fi ;
	
# update with newest files
	
if test $csv/csv_wb/$file1 -nt $csv/$file1
then echo "upd from csv_wb" ; cp -p $csv/csv_wb/LanguageNames*.csv $csv ; fi ;
	
if test $csv/csv_wk/$file1 -nt $csv/$file1
then echo "upd from csv_wk" ; cp -p $csv/csv_wk/LanguageNames*.csv $csv ; fi ;
	
if test $csv/csv_wn/$file1 -nt $csv/$file1
then echo "upd from csv_wn" ; cp -p $csv/csv_wn/LanguageNames*.csv $csv ; fi ;
	
if test "$csv/csv_wp/$file1" -nt "$csv/$file1"
then echo "upd from csv_wp" ; cp -p $csv/csv_wp/LanguageNames*.csv $csv ; fi ;
	
if test "$csv/csv_wq/$file1" -nt "$csv/$file1"
then echo "upd from csv_wq" ; cp -p $csv/csv_wq/LanguageNames*.csv $csv ; fi ;
	
if test "$csv/csv_ws/$file1" -nt "$csv/$file1"
then echo "upd from csv_ws" ; cp -p $csv/csv_ws/LanguageNames*.csv $csv ; fi ;
	
if test "$csv/csv_wv/$file1" -nt "$csv/$file1"
then echo "upd from csv_wv" ; cp -p $csv/csv_wv/LanguageNames*.csv $csv ; fi ;
	
if test "$csv/csv_wx/$file1" -nt "$csv/$file1"
then echo "upd from csv_wx" ; cp -p $csv/csv_wx/LanguageNames*.csv $csv ; fi ;
	
# distribute newest files

echo "copy to csv_wb" ; cp -p $csv/LanguageNames*.csv $csv/csv_wb ;
echo "copy to csv_wk" ; cp -p $csv/LanguageNames*.csv $csv/csv_wk ;
echo "copy to csv_wn" ; cp -p $csv/LanguageNames*.csv $csv/csv_wn ;
echo "copy to csv_wp" ; cp -p $csv/LanguageNames*.csv $csv/csv_wp ;
echo "copy to csv_wq" ; cp -p $csv/LanguageNames*.csv $csv/csv_wq ;
echo "copy to csv_ws" ; cp -p $csv/LanguageNames*.csv $csv/csv_ws ;
echo "copy to csv_wv" ; cp -p $csv/LanguageNames*.csv $csv/csv_wv ;
echo "copy to csv_wx" ; cp -p $csv/LanguageNames*.csv $csv/csv_wx ;

echo "Sync language files completed" ;
