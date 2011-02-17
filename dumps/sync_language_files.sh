#!/bin/sh

echo "\nSync language files" ;
root="/a/wikistats" ;

file1="LanguageNamesViaPhp.csv" ;

# seed with files

if ! test -e $root/$file1 && test -e $root/csv_wb/$file1 
then echo "copy from csv_wb" ; cp $root/csv_wb/LanguageNames*.csv $root ; fi ;
	
if ! test -e $root/$file1 && test -e $root/csv_wk/$file1
then echo "copy from csv_wk" ; cp $root/csv_wk/LanguageNames*.csv $root ; fi ;

if ! test -e $root/$file1 && test -e $root/csv_wn/$file1
then echo "copy from csv_wn" ; cp $root/csv_wn/LanguageNames*.csv $root ; fi ;

if ! test -e $root/$file1 && test -e $root/csv_wp/$file1
then echo "copy from csv_wp" ; cp $root/csv_wp/LanguageNames*.csv $root ; fi ;
	
if ! test -e $root/$file1 && test -e $root/csv_wq/$file1
then echo "copy from csv_wq" ; cp $root/csv_wq/LanguageNames*.csv $root ; fi ;
if ! test -e $root/$file1 && test -e $root/csv_ws/$file1
then echo "copy from csv_ws" ; cp $root/csv_ws/LanguageNames*.csv $root ; fi ;
	
if ! test -e $root/$file1 && test -e $root/csv_wv/$file1
then echo "copy from csv_wv" ; cp $root/csv_wv/LanguageNames*.csv $root ; fi ;

if ! test -e $root/$file1 && test -e $root/csv_wx/$file1
then echo "copy from csv_wx" ; cp $root/csv_wx/LanguageNames*.csv $root ; fi ;
	
# update with newest files (cp -p = preserve tiestamps etc)
	
if test $root/csv_wb/$file1 -nt $root/$file1
then echo "upd from csv_wb" ; cp -p $root/csv_wb/LanguageNames*.csv $root ; fi ;
	
if test $root/csv_wk/$file1 -nt $root/$file1
then echo "upd from csv_wk" ; cp -p $root/csv_wk/LanguageNames*.csv $root ; fi ;
	
if test $root/csv_wn/$file1 -nt $root/$file1
then echo "upd from csv_wn" ; cp -p $root/csv_wn/LanguageNames*.csv $root ; fi ;
	
if test "$root/csv_wp/$file1" -nt "$root/$file1"
then echo "upd from csv_wp" ; cp -p $root/csv_wp/LanguageNames*.csv $root ; fi ;
	
if test "$root/csv_wq/$file1" -nt "$root/$file1"
then echo "upd from csv_wq" ; cp -p $root/csv_wq/LanguageNames*.csv $root ; fi ;
	
if test "$root/csv_ws/$file1" -nt "$root/$file1"
then echo "upd from csv_ws" ; cp -p $root/csv_ws/LanguageNames*.csv $root ; fi ;
	
if test "$root/csv_wv/$file1" -nt "$root/$file1"
then echo "upd from csv_wv" ; cp -p $root/csv_wv/LanguageNames*.csv $root ; fi ;
	
if test "$root/csv_wx/$file1" -nt "$root/$file1"
then echo "upd from csv_wx" ; cp -p $root/csv_wx/LanguageNames*.csv $root ; fi ;
	
# distribute newest files

echo "copy to csv_wb" ; cp -p $root/LanguageNames*.csv $root/csv_wb ;
echo "copy to csv_wk" ; cp -p $root/LanguageNames*.csv $root/csv_wk ;
echo "copy to csv_wn" ; cp -p $root/LanguageNames*.csv $root/csv_wn ;
echo "copy to csv_wp" ; cp -p $root/LanguageNames*.csv $root/csv_wp ;
echo "copy to csv_wq" ; cp -p $root/LanguageNames*.csv $root/csv_wq ;
echo "copy to csv_ws" ; cp -p $root/LanguageNames*.csv $root/csv_ws ;
echo "copy to csv_wv" ; cp -p $root/LanguageNames*.csv $root/csv_wv ;
echo "copy to csv_wx" ; cp -p $root/LanguageNames*.csv $root/csv_wx ;

echo "Ready\n"
