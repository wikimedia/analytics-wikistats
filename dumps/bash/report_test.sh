#!/bin/bash

wikistats=/a/wikistats_git
dumps=$wikistats/dumps
perl=$dumps/perl
perl=/home/ezachte/wikistats/dumps/perl # test
csv=$dumps/csv
out=$dumps/out

cd $perl
#perl WikiReports.pl  -m wx -l commons -i $csv/csv_wx/ -o $out/out_test ; 
#perl WikiReports.pl  -m wx -l en      -i $csv/csv_wx/ -o $out/out_test ; 
 perl WikiReports.pl  -m wp -l en      -i $csv/csv_wp/ -o $out/out_test_wp ; 

