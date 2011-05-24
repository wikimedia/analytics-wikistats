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

# Functionality:
# comScore data can be downloaded as csv file, which each contain 14 months history
# This script uses these files to update 'master' csv files which contain all known history
# Note: only entities which are already in master file will be updated!
# Then it merges these master files into one csv file which can be loaded into analytics database
# Data are: reach by region, unique visitors by region, unique visitors by web property

# Parameters:
# -m (required) folder with 'master' csv files (files with all known history)
# -u (required) folder with 'update' csv files (files with lastest 14 months history, produced by comScore)

# Output:
# updated master csv files + merged and formatted csv for import in MySQL

# http://svn.wikimedia.org/viewvc/mediawiki/trunk/wikistats/analytics/

  use Getopt::Std ;
  use Cwd;

  my $options ;
  getopt ("mu", \%options) ;

  $true  = 1 ;
  $false = 0 ;

  $script_name    = "MySQLPrepComscoreData.pl" ;
  $script_version = "0.3" ;

# EZ test only
# $source       = "comscore" ;
# $server       = "ez_test" ;
# $generated    = "2011-05-06 00:00:00" ;
# $user         = "ezachte" ;

  $dir_analytics        = $options {"m"} ;
  $dir_comscore_updates = $options {"u"} ;

  $dir_analytics        = "c:/MySQL/analytics" ;    # EZ test only
  $dir_comscore_updates = "W:/@ Report Card/Data" ; # EZ test only

  if (($dir_analytics eq '') || ($dir_comscore_updates eq ''))
  { abort ("Specify folder for 'master' csv files as '-m folder', folder for 'update' csv files as -u folder'") ; }

  $file_comscore_reach_master     = "excel_out_comscore_reach_regions.csv" ;
  $file_comscore_reach_update     = "*reach*by*region*csv" ;
  $file_comscore_uv_region_master = "excel_out_comscore_UV_regions.csv" ;
  $file_comscore_uv_region_update = "*UVs*by*region*csv" ;
  $file_comscore_uv_property_master = "excel_out_comscore_UV_properties.csv" ;
  $file_comscore_uv_property_update = "*UV*trend*csv" ;

  $layout_csv_reach      = 1 ;
  $layout_csv_regions    = 2 ;
  $layout_csv_properties = 3 ;

  print "Directories:\nAnalytics '$dir_analytics'\nUpdates '$dir_comscore_updates'\n\n" ;

  %region_codes = (
    "Europe"=>"EU",
    "North America"=>"NA",
    "Latin America"=>"LA",
    "World-Wide" => "W",
    "Middle East - Africa" => "MA",
    "Asia Pacific"=> "AS",
    "United States" => "US",
    "India" => "I",
    "China" => "C"
  ) ;

  foreach $region_name (keys %region_codes)
  { $region_names {$region_codes {$region_name}} = $region_name ; }

  @months_short = qw "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec" ;

  &ReadDataReachPerRegion ($file_comscore_reach_master, $file_comscore_reach_update, "%.1f", 1, $layout_csv_reach) ;
  %reach_region_code = %data ;

  &ReadDataVisitorsPerRegion ($file_comscore_uv_region_master, $file_comscore_uv_region_update, "%.0f", 1000, $layout_csv_regions) ;
  %visitors_region_code = %data ;

  &ReadDataVisitorsPerProperty ($file_comscore_uv_property_master, $file_comscore_uv_property_update, "%.0f", 1000, $layout_csv_properties) ;
  %visitors_web_property = %data ;

  &WriteDataAnalytics ;

  print "\nReady\n\n" ;
  exit ;

sub UpdateFromLatestComscoreData
{
  my ($file_comscore_master, $file_comscore_updates, $multiplier, $layout_csv, @update_only) = @_ ;

  undef %update_only ;
  undef %do_not_update ;

  foreach $id (@update_only)
  { $update_only {$id} = $true ; }

  if (! -e "$dir_analytics/$file_comscore_master")
  { abort ("File $file_comscore_master not found!") ; }

  $age_all = -M "$dir_analytics/$file_comscore_master" ;
  print "Latest comscore master file is " . sprintf ("%.0f", $age_all) . " days old: '$file_comscore_master'\n" ;

  my $cwd = getcwd ;
  chdir $dir_comscore_updates ;

  @files = glob($file_comscore_updates) ;
  $min_age_upd = 999999 ;
  $file_comscore_updates_latest = '' ;
  foreach $file (@files)
  {
    $age = -M $file ;
    if ($age < $min_age_upd)
    {
      $min_age_upd = $age ;
      $file_comscore_updates_latest = $file ;
    }
  }
  print "Latest comscore update file is " . sprintf ("%.0f", $min_age_upd) . " days old: '$file_comscore_updates_latest'\n" ;

  if ($min_age_upd == 999999)
  {
    print "No valid update file found. Nothing to update." ;
    return ;
  }

  if ($age_all > $min_age_upd)
  {
    print "File with master data more recent than latest update csv from comScore. Nothing to update." ;
    return ;
  }

  my $updates_found = $false ;

  print "\nRead updates\n\n" ;
  open CSV, '<', $file_comscore_updates_latest ;
  while ($line = <CSV>)
  {
    chomp $line ;
    $line = &GetNumberOnly ($line) ;

    if ($line =~ /Jan-\d\d\d\d.*?Feb-\d\d\d\d/) # e.g. 'Location,Location,Jan-2010,Feb-2010,Mar-2010,Apr-2010,...'
    {
      if ($layout_csv == $layout_csv_properties)
      { ($dummy1,$dummy2,$dummy3,@months) = split (',', $line) ; } # web properties csv file
      else
      { ($dummy1,$dummy2,@months) = split (',', $line) ; }         # uv / reach csv files

      @months = &mmm_yyyy2yyyy_mm (@months) ;
    }

    if ($line =~ /^\d+,/)
    {
      if ($layout_csv == $layout_csv_properties)
      {
        ($index,$dummy,$property,@data) = split (',', $line) ;
        $property =~ s/^\s+// ;
        $property =~ s/\s+$// ;

        $property =~ s/.*Google.*/Google/i ;
        $property =~ s/.*Microsoft.*/Microsoft/i ;
        $property =~ s/.*FACEBOOK.*/Facebook/i ;
        $property =~ s/.*Yahoo.*/Yahoo/i ;
        $property =~ s/.*Amazon.*/Amazon/i ;
        $property =~ s/.*Apple.*/Apple/i ;
        $property =~ s/.*AOL.*/AOL/i ;
        $property =~ s/.*Wikimedia.*/Wikimedia/i ;
        $property =~ s/.*Tencent.*/Tencent/i ;
        $property =~ s/.*Baidu.*/Baidu/i ;
        $property =~ s/.*CBS.*/CBS/i ;

        $id = $property ;
      }
      else
      {
        ($index,$region,@data) = split (',', $line) ;
        $region =~ s/^\s+// ;
        $region =~ s/\s+$// ;
        $id = $region_codes {$region} ;
      }

      if ($update_only {$id} == 0)
      {
        $do_not_update {$id}++ ;
        next ;
      }

      for ($m = 0 ; $m <= $#months ; $m++)
      {
        $yyyymm = $months [$m] ;
        $months {$yyyymm} ++ ;
        $yyyymm_id = "$yyyymm,$id" ;
        $data = $data [$m] * $multiplier ;

        if (! defined $data {$yyyymm_id})
        {
          $updates_found = $true ;
          print "New data found: $yyyymm_id = $data\n" ;
          $data {$yyyymm_id} = $data ;
        }
      }
    }
  }

  $ignored = join ', ', sort keys %do_not_update ;
  print "\nEntities ignored:\n$ignored\n\n" ;

  if (! $updates_found)
  { print "No new updates found\n" ; }
  else
  { print "\nUpdates found, rewrite master file '$file_comscore_master'\n\n" ; }

  return ($updates_found) ;
}

sub ReadDataReachPerRegion
{
  my ($file_comscore_master, $file_comscore_updates, $precision, $layout_csv) = @_ ;

  undef %months ;
  undef %data ;
  undef @regions ;

  open IN,  '<', "$dir_analytics/$file_comscore_master" ;

  $lines = 0 ;
  while ($line = <IN>)
  {
    chomp $line ;

    ($yyyymm,@data) = split (',', $line) ;

    if ($lines++ == 0)
    { @regions = @data ; next ; }

    $field_ndx = 0 ;
    foreach (@data)
    {
      $region      = $regions [$field_ndx] ;
      $region_code = $region_codes {$region} ;

      $data      = $data [$field_ndx] ;
      if ($data eq '')
      { $data = '0' ; }
      $months {$yyyymm} ++ ;
      $data {"$yyyymm,$region_code"} = $data ;
      # print "Old data $yyyymm,$region_code = $data\n" ;
      $field_ndx++ ;
    }
  }
  close IN ;

  my $updates_found = &UpdateFromLatestComscoreData ($file_comscore_master, $file_comscore_updates, 1, $layout_csv, @regions) ;
  return if ! $updates_found ;

  rename "$dir_analytics/$file_comscore_master", "$dir_analytics/$file_comscore_master.~" ;
  open OUT,  '>', "$dir_analytics/$file_comscore_master" ;

  $line_out = "yyyymm" ;
  foreach $region_name (@regions)
  { $line_out .= ",$region_name" ; }
  print OUT "$line_out" ;

  foreach $yyyymm (sort {$b cmp $a} keys %months)
  {
    $line_out = "\n$yyyymm" ;
    foreach $region_name (@regions)
    {
      $yyyymm_region_code = $yyyymm . ',' . $region_codes {$region_name} ;
      $line_out .= "," . sprintf ($precision, $data {$yyyymm_region_code}) ;
    }
    print OUT "$line_out" ;
  }

  close OUT ;
}

sub ReadDataVisitorsPerRegion
{
  my ($file_comscore_master, $file_comscore_updates, $precision, $multiplier, $layout_csv) = @_ ;

  undef %months ;
  undef %data ;
  undef @regions ;

  open IN,  '<', "$dir_analytics/$file_comscore_master" ;

  $lines  = 0 ;
  $metric = 'unique_visitors' ;
  while ($line = <IN>)
  {
    chomp $line ;
    $line = &GetNumberOnly ($line) ;

    ($yyyymm,@data) = split (',', $line) ;

    if ($lines++ == 0)
    { @regions = @data ; next ; }

    $field_ndx = 0 ;
    foreach (@data)
    {
      $region      = $regions [$field_ndx] ;
      $region_code = $region_codes {$region} ;

      $data      = $data    [$field_ndx] ;
      if ($data eq '')
      { $data = '0' ; }

      # print "Old data $yyyymm,$region = $data\n" ;

      $months {$yyyymm} ++ ;
      $data {"$yyyymm,$region_code"} = $data ;

      $field_ndx++ ;
    }
  }
  close IN ;

  my $updates_found = &UpdateFromLatestComscoreData ($file_comscore_master, $file_comscore_updates, 1000, $layout_csv, @regions) ;
  return if ! $updates_found ;

  rename "$dir_analytics/$file_comscore_master", "$dir_analytics/$file_comscore_master.~" ;
  open OUT,  '>', "$dir_analytics/$file_comscore_master" ;

  $line_out = "yyyymm" ;
  foreach $region_name (@regions)
  { $line_out .= ",$region_name" ; }
  print OUT "$line_out" ;

  foreach $yyyymm (sort {$b cmp $a} keys %months)
  {
    $line_out = "\n$yyyymm" ;
    foreach $region_name (@regions)
    {
      $yyyymm_region_code = $yyyymm . ',' . $region_codes {$region_name} ;
      $line_out .= "," . sprintf ($precision, $data {$yyyymm_region_code}) ;
    }
    print OUT "$line_out" ;
  }

  close OUT ;
}

sub ReadDataVisitorsPerProperty
{
  my ($file_comscore_master, $file_comscore_updates, $precision, $multiplier, $layout_csv) = @_ ;

  undef %months ;
  undef %data ;
  undef @properties ;

  open IN,  '<', "$dir_analytics/$file_comscore_master" ;

  $lines = 0 ;
  $metric       = 'unique_visitors' ;
  while ($line = <IN>)
  {
    chomp $line ;

    ($yyyymm,@data) = split (',', $line) ;
    if ($lines++ == 0)
    { @properties = @data ; next ; }

    $field_ndx = 0 ;
    foreach (@data)
    {
      $property = $properties [$field_ndx] ;
      $property =~ s/.*Yahoo.*/Yahoo/ ;
      $data      = $data    [$field_ndx] ;
      if ($data eq '')
      { $data = '0' ; }

      # print "Old data $yyyymm,$property = $data\n" ;

      $months {$yyyymm} ++ ;
      $data {"$yyyymm,$property"} = $data ;

      $field_ndx++ ;
    }
  }
  close IN ;

  my $updates_found = &UpdateFromLatestComscoreData ($file_comscore_master, $file_comscore_updates, 1000, $layout_csv, @properties) ;
  return if ! $updates_found ;

  rename "$dir_analytics/$file_comscore_master", "$dir_analytics/$file_comscore_master.~" ;
  open OUT,  '>', "$dir_analytics/$file_comscore_master" ;

  $line_out = "yyyymm" ;
  foreach $property (@properties)
  { $line_out .= ",$property" ; }
  print OUT "$line_out" ;

  foreach $yyyymm (sort {$b cmp $a} keys %months)
  {
    $line_out = "\n$yyyymm" ;
    foreach $property (@properties)
    {
      $yyyymm_property = "$yyyymm,$property" ;
      $line_out .= "," . sprintf ($precision, $data {$yyyymm_property}) ;
    }
    print OUT "$line_out" ;
  }

  close OUT ;
}

sub WriteDataAnalytics
{
  open OUT, '>', "c:/MySQL/analytics/analytics_in_comscore.csv" ;

  $metric = 'unique_visitors' ;
  foreach $yyyymm (sort keys %months)
  {
    # store meta data elsewhere
    # $line = "$generated,$source,$server,$script_name,$script_version,$user,$yyyymm,$country_code,$region_code,$property,$project,$normalized,$metric,$data\n" ;
    foreach $region_code (sort values %region_codes)
    {
      $country_code = '-' ;
      $property     = '-' ;
      $project      = '-' ;
      $reach        = $reach_region_code     {"$yyyymm,$region_code"} ;
      $visitors     = $visitors_region_code  {"$yyyymm,$region_code"} ;

      if (! defined $reach)    { $reach = -1 ; }
      if (! defined $visitors) { $reach = -1 ; }

      $line = "$yyyymm,$country_code,$region_code,$property,$project,$reach,$visitors\n" ;
      print OUT $line ;
      print     $line ;
    }

    foreach $property (sort @properties)
    {
      $country_code = '-' ;
      $region_code  = '-' ;
      $project      = '-' ;
      $reach        = '-1' ;
      $visitors     = $visitors_web_property {"$yyyymm,$property"} ;

      next if ! defined $visitors ;

      $line = "$yyyymm,$country_code,$region_code,$property,$project,$reach,$visitors\n" ;
      print OUT $line ;
      # print     $line ;
    }
  }
}

sub GetNumberOnly
{
  my $line = shift ;
  $line =~ s/("[^\"]+")/($a=$1,$a=~s#,##g,$a)/ge ; # nested regexp: remove comma's inside double quotes
  $line =~ s/"//g ;
  return $line ;
}

sub mmm_yyyy2yyyy_mm
{
  my @months = @_ ;
  # Jan -> 01, etc
  foreach my $month (@months)
  {
    my ($mmm,$yyyy) = split ('-', $month) ;
    for ($m = 0 ; $m <= $#months_short ; $m++)
    {
      if ($mmm eq $months_short [$m])
      { $month = "$yyyy-" . sprintf ("%02d", $m+1) ; }
    }
  }
  return @months ;
}

sub abort
{
  $msg = shift ;

  print  "\nAbort, reason: $msg\n\n" ;
  exit ;
}
