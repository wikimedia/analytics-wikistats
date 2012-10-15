#! /usr/bin/perl

  use Getopt::Std ;
  use File::Path ;
  getopt ("io", \%options) ;

  $| = 1; # flush screen output

  $path_csv_in = $options {'i'} ;
  die "Specify input path (squids csv top folder) as -i [path]" if $path_csv_in eq '' ;
  die "Input path '$path_csv_in' not found (squids csv top folder)" if ! -d $path_csv_in ;

  $path_csv_out = $options {'o'} ;
  die "Specify output path as -o [path]" if $path_csv_out eq '' ;

  if (! -d $path_csv_out)
  {
    mkpath $path_csv_out ;
    die "Path '$path_csv_out' could not be created" if ! -d $path_csv_out ;
  }

# read all files on squid log aggregator with hourly counts for
# - number of events received per squid
# - average gap in sequence numbers (this should be 1000 idealy on a 1:1000 sampled log)
# write several aggregations of these data

  &ReadData ;
  &ProcessData ;

  &WriteHourlyAveragedDeltaSequenceNumbers ;
  &WriteMonthlyAveragedEventsPerSquidPerHour ;
  &WriteMonthlyMetricsPerSquidSet ;

  print "\n\nReady\n\n" ;

sub ReadData
{
  chdir $path_csv_in ;

  @files = <*>;
  foreach $file (@files)
  {
    next if ! -d $file ;
    next if $file !~ /^\d\d\d\d-\d\d$/ ;
    push @folders, $file ;
  }

  foreach $folder (@folders)
  {
    print "Scanning $folder\n" ;
    chdir "$path_csv_in/$folder" ;
    @files = <*>;

    foreach $file (@files)
    {
      next if ! -d $file ;
      next if $file !~ /^\d\d\d\d-\d\d-\d\d$/ ;
      $folder2 = $file ;
      $file_csv = "$path_csv_in/$folder/$folder2/SquidDataSequenceNumbersPerSquidHour.csv" ;
      if (-e $file_csv)
      { &ProcessData ($folder2, $file_csv) ; }
    }
  }
}

sub ProcessData
{
  my ($date_yyyy_mm_dd, $file) = @_ ;
  $date_yyyy_mm = substr ($date_yyyy_mm_dd,0,7) ;
  $months {$date_yyyy_mm}++ ;

  open CSV, '<', $file ;
  while ($line = <CSV>)
  {
    next if $line =~ /events/i ; # headers + totals
    chomp $line ;
    ($squid,$hour,$events,$tot_delta,$avg_delta) = split (',', $line) ;

    $squid2 = $squid ;
    $squid2 =~ s/\..*// ;

    ($digits = $squid2) =~ s/[^\d]//g ;
    $digits =~ s/\d?\d$/*/ ;
    ($name = $squid2) =~ s/[\d]//g ;

    $squid_set = $name . $digits  ;
    $squid_sets {$squid_set}++ ;
    if ($squid_sets_lo {$squid_set} eq '')
    { $squid_sets_lo {$squid_set} = $squid2 ; }
    if ($squid_sets_hi {$squid_set} eq '')
    { $squid_sets_hi {$squid_set} = $squid2 ; }
    if ($squid_sets_lo {$squid_set} gt $squid2)
    { $squid_sets_lo {$squid_set} = $squid2 ; }
    if ($squid_sets_hi {$squid_set} lt $squid2)
    { $squid_sets_hi {$squid_set} = $squid2 ; }

  # if ($squid ne '')
  # { $squids {"$squid,$date_yyyy_mm"} += $events ; }

    $squid_events_month {"$squid,$date_yyyy_mm"} += $events ;
    $squid_hours_month  {"$squid,$date_yyyy_mm"} ++ ;

    $squid_set_delta_month  {"$squid_set,$date_yyyy_mm"} += $avg_delta ;
    $squid_set_events_month {"$squid_set,$date_yyyy_mm"} += $events ;
    $squid_set_hours_month  {"$squid_set,$date_yyyy_mm"} ++ ;

    if ($squid =~ /sq/)  # only for regular squids for clearer correction data
    {
      $all_regular_squids_delta_hour  {"$date_yyyy_mm_dd,$hour"} += $avg_delta ;
      $all_regular_squids_active      {"$date_yyyy_mm_dd,$hour"} ++ ;
    }
  }
  close CSV ;
}

# this file can be used to patch projectcounts files from dammit.lt/wikistats to make up for missing events (due to server overload)
# if for some hour average gap in sequence numbers is 1200 instead of 1000 this means all per wiki counts in projectcount file for that hour need correction: * 1200/1000
sub WriteHourlyAveragedDeltaSequenceNumbers
{
  open CSV , '>',  "$path_csv_out/SquidDataHourlyAverageDeltaSequenceNumbers.csv" ;
  foreach $date_hour (sort keys %all_regular_squids_active)
  {
    $avg_delta_all_regular_squids = sprintf ("%.0f", $all_regular_squids_delta_hour  {$date_hour} / $all_regular_squids_active {$date_hour}) ;
    print CSV "$date_hour,$avg_delta_all_regular_squids\n" ;
    print     "$date_hour,$avg_delta_all_regular_squids\n" ;
  }
  close CSV ;
}

sub WriteMonthlyAveragedEventsPerSquidPerHour
{
  open CSV , '>',  "$path_csv_out/SquidDataMonthlyEventsPerSquidPerHour.csv" ;
  foreach $key (sort keys %squid_events_month)
  {
    $events_per_hour =  sprintf ("%.0f", $squid_events_month {$key} / $squid_hours_month {$key}) ;
    $key =~ s/(\w)0(\d\.)/$1$2/ ;

    print CSV "$key,$events_per_hour\n" ;
  }
  close CSV ;
}

# monthly data per squid set, first average hourly delta between sequence numbers, then hourly number of events
sub WriteMonthlyMetricsPerSquidSet
{
  open CSV , '>',  "$path_csv_out/SquidDataMonthlyPerSquidSet.csv" ;
  print CSV "\nAverage delta in sequence numbers per squid per active hour \n\n" ;
  $line = "month" ;
  foreach $squid_set (sort keys %squid_sets)
  {
    if ($squid_sets_lo {$squid_set} eq $squid_sets_hi {$squid_set})
    { $squid_range = $squid_sets_lo {$squid_set} ; }
    else
    {
      ($squid_sets_hi_num = $squid_sets_hi {$squid_set}) =~ s/[^\d]//g ;
      $squid_range = $squid_sets_lo {$squid_set} . "-" . $squid_sets_hi_num ;
    }
    $line .= ",$squid_range" ;
  }
  print CSV "$line\n" ;

  foreach $month (sort keys %months)
  {
    $line = $month ;
    foreach $squid_set (sort keys %squid_sets)
    {
      $key = "$squid_set,$month" ;
      if ($squid_set_hours_month {$key} == 0)
      { $line .= "," ; }
      else
      { $line .= "," . sprintf ("%.0f", $squid_set_delta_month {$key}  / $squid_set_hours_month {$key}) ; }
    }
    print CSV "$line\n" ;
  }

  print CSV "\n\nAverage events per squid per active hour \n\n" ;

  $line = "month" ;
  foreach $squid_set (sort keys %squid_sets)
  {
    if ($squid_sets_lo {$squid_set} eq $squid_sets_hi {$squid_set})
    { $squid_range = $squid_sets_lo {$squid_set} ; }
    else
    {
      ($squid_sets_hi_num = $squid_sets_hi {$squid_set}) =~ s/[^\d]//g ;
      $squid_range = $squid_sets_lo {$squid_set} . "-" . $squid_sets_hi_num ;
    }
    $line .= ",$squid_range" ;
  }
  print CSV "$line\n" ;

  foreach $month (sort keys %months)
  {
    $line = $month ;
    foreach $squid_set (sort keys %squid_sets)
    {
      $key = "$squid_set,$month" ;
      if ($squid_set_hours_month {$key} == 0)
      { $line .= "," ; }
      else
      { $line .= "," . sprintf ("%.0f", $squid_set_events_month {$key}  / $squid_set_hours_month {$key}) ; }
    }
    print CSV "$line\n" ;
  }

  print CSV "\n\nSquid names grouped by first 2 digits\n" ;
  close CSV ;
}
