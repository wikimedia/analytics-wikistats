#!/bin/bash

perl=/a/wikistats/perl
csv=/a/wikistats/csv
out=/a/wikistats/out

#perl $perl/WikiReports.pl  -m wx -l commons -i $csv/csv_wx/ -o $out/out_test ; 
#perl $perl/WikiReports.pl  -m wx -l en      -i $csv/csv_wx/ -o $out/out_test ; 
 perl $perl/WikiReports.pl  -m wp -l en      -i $csv/csv_wp/ -o $out/out_test_wp ; 

