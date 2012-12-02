#!/usr/bin/perl

# Copyright (C) 2011 Wikimedia Foundation
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, at
# http://www.fsf.org/licenses/gpl.html

# Author:
# Erik Zachte, email ezachte@wikimedia.org

  use Getopt::Std ;
  use Cwd;
  use Time::Local ;
  use POSIX qw/ceil/;

  $| = 1; # flush output

  print "\n" . "="x80 . "\n\n" ;

  my $options ;
  getopt ("cft12", \%options) ;

  $true  = 1 ;
  $false = 0 ;

  $verbose = $false ;
  $script_name    = "AnalyticsCompareMonthlyCsvFiles.pl" ;
  $script_version = "0.1" ;

  $dir_csv      = $options {"c"} ; # root dir , which should contain folder per month with relevant csv files
  $yyyymm_1     = $options {"1"} ; # specify some month       as '-1 yyyy-mm', e.g. '-1 2012-05'
  $yyyymm_2     = $options {"2"} ; # specify some other month as '-2 yyyy-mm', e.g. '-2 2012-06'
  $threshold    = $options {"t"} ; # report in detail when absolute ratio largest/smallest (as percentage) exceeds x percetage points
  $compare_file = $options {"f"} ; # specify one of two valid wikilytics csv files

  if ($threshold eq '')
  { $threshold = 2 ; }

  if (! -d "/a/") # EZ test env
  {
    $dir_csv   = "W:/@ Report Card/csv" ;
    $yyyymm_1  = "2012-06" ;
    $yyyymm_2  = "2012-07" ;
  # $compare_file = 'wikilytics_in_pageviews.csv' ;
    $compare_file = 'wikilytics_in_wikistats_core_metrics.csv' ;
  }

  if ($yyyymm_1 !~ /^20\d\d-\d\d$/)
  { die ("Specify month 1 as '-1 yyyy-mm', not '-1 $yyyymm_1'") ; }
  if ($yyyymm_2 !~ /^20\d\d-\d\d$/)
  { die ("Specify month 2 as '-2 yyyy-mm', not '-2 $yyyymm_2'") ; }
  if ($yyyymm_1 eq $yyyymm_2)
  { die ("Specify two different months.") ; }
  if ($threshold !~ /^\d(\.\d+)?$/)
  { die ("Specify threshold for reporting percentual difference between old and new values as -t n[.n]") ; }
  if ($compare_file !~ /^(?:wikilytics_in_pageviews.csv|wikilytics_in_wikistats_core_metrics.csv)/)
  { die ("Unexpected csv file '$compare_file', specify 'wikilytics_in_pageviews.csv' or 'wikilytics_in_wikistats_core_metrics.csv'") ; }

  $min_ratio_old_new = $threshold ; # report when old and new value differ more than $min_ratio_old_new percent

  if ($yyyymm_1 gt $yyyymm_2)
  {
    $yyyymm_x = $yyyymm_1 ;
    $yyyymm_1 = $yyyymm_2 ;
    $yyyymm_2 = $yyyymm_x ;
  }

  $file_csv_out = "$dir_csv/$yyyymm_2/comparison $yyyymm_1 $yyyymm_2 $compare_file.txt" ;

  $dir_csv_1 = "$dir_csv/$yyyymm_1" ;
  $dir_csv_2 = "$dir_csv/$yyyymm_2" ;

  if (! -e $dir_csv_1)
  { die ("Folder not found: '$dir_csv_1'. Specify csv folder as -c [folder] and month as -[1|2] [yyyy-mm]") ; }
  if (! -e $dir_csv_2)
  { die ("Folder not found: '$dir_csv_2'. Specify csv folder as -c [folder] and month as -[1|2] [yyyy-mm]") ; }

  print "Compare file $compare_file\n\n" ;

  &Compare ($compare_file) ;

  print "\nReady\n\n" ;
  print "="x80 . "\n" ;
  exit ;

sub Compare
{
  my $filename = shift ;

  $file_csv_in_1 = "$dir_csv_1/$filename" ;
  $file_csv_in_2 = "$dir_csv_2/$filename" ;

  if (! -e $file_csv_in_1)
  { die ("File not found: '$file_csv_in_1'.") ; }
  if (! -e $file_csv_in_2)
  { die ("File not found: '$file_csv_in_2'.") ; }

  push @filenames, "Oldest file: $file_csv_in_1\n" ;
  push @filenames, "Newest file: $file_csv_in_2\n" ;

  &ReadCsv (1, $file_csv_in_1) ;
  &ReadCsv (2, $file_csv_in_2) ;

  open CSV_OUT, '>', $file_csv_out ;
# print CSV_OUT '=' x 80 . "\n" ;
  &FindNonOverlappingMonths ;
  &WriteDiff ($file_csv_out) ;
# print CSV_OUT '=' x 80 . "\n" ;
  close CSV_OUT ;
}

sub ReadCsv
{
  my ($set, $file_csv_in) = @_ ;

  open CSV_IN, '<', $file_csv_in ;
  while ($line = <CSV_IN>)
  {
    chomp $line ;

    if ($line =~ /^\d+,,/) 
    { die "Invalid line, language name missing '$line'\n" ; }

    $line_original = $line ;
    $line =~ s/^,+// ;
    $line =~ s/,+$// ;
    @fields = split (',', $line) ;

    next if $line =~ /^\s*$/ ;
    next if $line =~ /Note/i ;

    # find section name
    if (($#fields < 3) && ($line_original !~ /,,,,/))
    {
      $section = $fields [0] ;

      next if $section =~ /Note/i ;
      next if $file_csv_in =~ /core_metrics/ and $line =~ /===/ ;
      next if $file_csv_in =~ /pageviews/    and $line =~ /Page view data are normalized to 30 day months/ ; # actually not a section header
      $section =~ s/===//g ;
      $section =~ s/^\s+// ;
      $section =~ s/\s+$// ;
      $sections {$section} ++ ;
      next ;
    }

    # find months
    if ($line =~ /project\,/)
    {
    # print "\n\nMonths $line\n" ; # debug
      undef @months ;
      foreach $field (@fields)
      {
        next if $field !~ /^\d\d\/\d\d\d\d$/ ;

        $month = substr ($field,3,4) . '-' . substr ($field,0,2) ;
        $months {$month} ++ ;
        push @months, $month ;
      }
      next ;
    }

    # find metric name
    $f0 = 0 ; # index in @fields
    $m0 = 0 ; # index in @months
    $metric = $fields [$f0] ;
    if ($metric =~ /^\d+$/)
    { $f0++ ; $metric = $fields [$f0] ; }
    $f0++ ;

  # print "section/metric: '$section'/'$metric'\n" ;


    # read values
    $m = $m0 - 1 ;
# $line = '' ;
    for ($f = $f0 ; $f <= $#fields ; $f++)
    {
      $m++ ;
      $month = $months [$m] ;
      $value = $fields [$f] ;
      next if $month !~ /^\d\d\d\d-\d\d$/ ;
      next if $value eq '' ;
      next if ! defined $value ;
      next if $value !~ /^[0-9.,]+$/ ;

      $section_metrics {$section} {$metric} ++ ;
      $set_section_metrics {$set} {$section} {$metric} ++ ;

      $values {$set} {$section} {$metric} {$month} = $value ;
      $months_in_set {$set} {$month} ++ ;
      $months_total  {$month} ++ ;
    }
# print "$line\n" ;
  }

  close CSV_IN ;
}

sub FindNonOverlappingMonths
{
  my ($file_csv_out) = @_ ;

  $lines = "\nMonths which occur only in oldest file: " ;
  for $month (sort keys %months_total)
  {
    if ($months_in_set {'2'} {$month} == 0)
    {
      $months_no_overlap {$month}++ ;
      $lines .= " $month " ;
    }
  }

  $lines .= "\n" ;
  $lines .= "Months which occur only in newest file: " ;
  for $month (sort keys %months_total)
  {
    if ($months_in_set {'1'} {$month} == 0)
    {
      $months_no_overlap {$month}++ ;
      $lines .= " $month " ;
    }
  }
  $lines .= "\n\nFor months which occur in both files:\n" ;

  push @months_only_in_one_set, $lines ;
}

sub WriteDiff
{
  foreach $section (keys %section_metrics)
  {
    push @sections_found, "Section found: $section\n" ;

    foreach $metric (sort keys %{$section_metrics {$section}} )
    {
    # print "Section '$section', Metric '$metric'\n" ;
      foreach $month (sort keys %months)
      {
        # some months only occur in oldest file, some only in newest files
        # some metrics only occur in oldest file, some only in newest files e.g. per language counts (only top 25 languages for each month are included)
        next if $months_no_overlap {$month} > 0 ;

        if ($set_section_metrics {'1'} {$section} {$metric} == 0)
        {
          $metrics_only_in_one_set {"Metric only in newest file: '$section' / '$metric'\n"} ++ ;
          next ;
        }
        if ($set_section_metrics {'2'} {$section} {$metric} == 0)
        {
          $metrics_only_in_one_set {"Metric only in oldest file: '$section' / '$metric'\n"} ++ ;
          next ;
        }

        $val_1 = $values {'1'} {$section} {$metric} {$month} ;
        $val_2 = $values {'2'} {$section} {$metric} {$month} ;

        next if ((! defined $val_1) && (! defined $val_2)) ;

        if (($val_1 eq '') and ($val_2 ne ''))
        {
          $only_val_2 ++ ;

          next if $metric =~ /1 upload is 5 edits/ and $month lt "2012-05" ; # metric only introduced in June 2012" ;
          next if $metric =~ /1st 28 days/ and $month lt "2012-05" ; # metric only introduced in June 2012" ;
          next if $metric =~ /Total after merge/ and $month lt "2012-05" ; # metric only introduced in June 2012" ;

          push @values_only_in_one_set, "Value only in newest file: '$section' / '$metric' / $month : $val_2\n" ;
        }
        elsif (($val_2 eq '') and ($val_1 ne ''))
        {
          $only_val_1 ++ ;
          push @values_only_in_one_set, "Value only in oldest file: '$section' / '$metric' / $month : $val_1\n" ;
        }
        else
        {
          # indexed numbers in both files are relative growth versus oldest month in file
          # as base month differs per file these numbers could vary a lot from one file to another
          # so ignore in this comparison, any data error should reveal iself in the raw (=absolute =unindexed) numbers
          next if $section =~ /indexed/i ;

          # new articles per day is a rounded number small in input, tiny changes yield seemingly large disparities
          # so ignore in this comparison, any data error should reveal iself in the total numbers of articles
          next if $section =~ /new articles per day/i ;

          # ratio is *abs* difference between old and new value in percentage of smallest value
          if ($val_1 == 0)
          { die "DivByZero follows: '$section' / '$metric': v2='$val_2', v1='$val_1'\n\n" ; }

          if ($val_1 == $val_2)
          { $no_disparities++ ; next ; }

          $ratio_old_new          = 100 * ($val_2 / $val_1) - 100 ;
          $ratio_old_new_abs_ceil = ceil (abs ($ratio_old_new)) ;
          $ratio_old_new          = sprintf ("%.1f", $ratio_old_new) ;
          $ratio_old_new_abs      = sprintf ("%.1f", abs ($ratio_old_new)) ;

          # make numbers align
          if ($ratio_old_new_abs =~ /^\d\./)
          { $ratio_old_new_abs = " $ratio_old_new_abs" ; }

          if ($ratio_old_new =~ /^[-]?\d\./)
          { $ratio_old_new = " $ratio_old_new" ; }
          if ($ratio_old_new !~ /[-]\d/)
          { $ratio_old_new = " $ratio_old_new" ; }

          if ($ratio_old_new_abs_ceil <= 10)
          { $disparities_0_10  {$ratio_old_new_abs_ceil} ++ ; }
          else
          { $disparities_gt_10 ++ ; }

          if ($ratio_old_new_abs >= $min_ratio_old_new)
          {
            push @values_quite_disparate, "Values differ more than $min_ratio_old_new%: $ratio_old_new_abs% $month '$section' / '$metric' : old $val_1, new $val_2 = $ratio_old_new%\n" ;
            $disparitiesabove_threshold_per_month {$month} ++ ;
          }
        }
      }
    }
  }

  foreach $line (sort keys %metrics_only_in_one_set) #deduplicate
  { push @metrics_only_in_one_set, $line ; }
  push @metrics_only_in_one_set, "\nFor metrics which occur in both files:\n" ;

  push @disparities, "For values which occur in both files:\n\n" ;
  push @disparities, "Distribution by amount of disparity:\n\n" ;
  push @disparities, "No disparity    : $no_disparities\n" ;
  foreach $integer (sort {$a <=> $b} keys %disparities_0_10)
  {
    if ($integer == 0)
    { push @disparities, "No disparity    : " . $disparities_0_10 {$integer} . "\n" ; }
    else
    { push @disparities, "Abs disp. " . ($integer - 1) . "%-$integer% : " . $disparities_0_10 {$integer} . "\n" ; }
    # never mind that upper bound is repeated as next lower bound (2-3 rather than 2-2.999999), keep it simple
  }
  if ( $disparities_gt_10 > 0)
  { push @disparities, "Abs disp. > 10% : $disparities_gt_10\n" ; }

  foreach $month (sort keys %disparitiesabove_threshold_per_month)
  { push @disparitiesabove_threshold_per_month, "Disparities > $min_ratio_old_new% for month $month: " . $disparitiesabove_threshold_per_month {$month} . "\n" ; }

  push @values_only_in_one_file, "Values for shared months/metrics which occur only in oldest file: " . (0+$only_val_1) . "\n" ;
  push @values_only_in_one_file, "Values for shared months/metrics which occur only in newest file: " . (0+$only_val_2) . "\n" ;

  &Report (@filenames) ;
  &Report (@sections_found) ;
  &Report (@months_only_in_one_set) ;
  &Report (@metrics_only_in_one_set) ;
  &Report (@values_only_in_one_set) ;
  &Report (@values_only_in_one_file) ;
  &Report (@values_quite_disparate) ;
  &Report (@disparities) ;
  &Report (@disparitiesabove_threshold_per_month) ;
}

sub Report
{
  my @lines = @_ ;
  print @lines ;
  print "\n" ;
  print CSV_OUT @lines ;
  print CSV_OUT "\n" ;
}




