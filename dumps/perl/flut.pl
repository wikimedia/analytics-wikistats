#!/usr/bin/perl
  open "CSV_IN", "<", "/a/wikistats/csv/csv_wx/EditsBreakdownPerUserPerMonthCOMMONS_NS6.csv" ;
  open "CSV_OUT", ">", "/a/wikistats/csv/csv_mw/uploaders_all.txt" ;

  $line_prev = '' ;
  while ($line = <CSV_IN>)
  {
    chomp $line ;
    next if $line =~ /^\s*$/ ;
    $line =~ s/,.*$// ;
    next if $line eq $line_prev ;
    print CSV_OUT "$line\n" ;
    $line_prev = $line ;
  }

