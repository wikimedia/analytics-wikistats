#! /usr/bin/perl

# aggregate stats per squid set per month from hourly stats per squid server
# collected by SquidCountArchive.pl via SquidCountArchive.sh
#
# hourly data per squid found in 
# /a/wikistats_git/squids/csv/[yyyy-mm]/[yyyy-mm-dd]/SquidDataSequenceNumbersPerSquidHour.csv
#
# example:
# squid,hour,events,tot delta,avg delta 
# amssq31.esams.wikimedia.org,00,606,636883,1051
#
# delta is difference in sequence number beteen consecutive udp messages from same squid
# should ideally be 1000 in a 1:1000 sampled log, but small fluctuations are normal 
# avg gap between sequence numbers > 1010: there is probably packet loss  
 
  use Time::Local ;
  use Getopt::Std ;
  use File::Path ;
  getopt ("io", \%options) ;

  $| = 1; # flush screen output

  $date_yyyy_mm_dd_min = "9999-99-99" ;
  $date_yyyy_mm_dd_max = "0000-00-00" ;
  
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
  &BuildListDaysHours ;

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

  if ($date_yyyy_mm_dd !~ /^\d\d\d\d-\d\d-\d\d$/)
  {
    print "Skip invalid date '$date_yyyy_mm_dd'\n" ;
    return ;    
  }
  if ($date_yyyy_mm_dd lt $date_yyyy_mm_dd_min)
  { $date_yyyy_mm_dd_min = $date_yyyy_mm_dd ; }
  if ($date_yyyy_mm_dd gt $date_yyyy_mm_dd_max)
  { $date_yyyy_mm_dd_max = $date_yyyy_mm_dd ; }

  $date_yyyy_mm = substr ($date_yyyy_mm_dd,0,7) ;
  $months {$date_yyyy_mm}++ ;

  open CSV, '<', $file ;
  while ($line = <CSV>)
  {
    next if $line =~ /events/i ; # headers + totals
    chomp $line ;
    ($squid,$hour,$events,$tot_delta,$avg_delta) = split (',', $line) ;

    next if $squid eq '' ;

    ($name = $squid) =~ s/\..*$// ; # 
   
    # Q&D,make this config file
    $location = 'loc.?' ; 
    if ($squid =~ /esams/)
    { $location = 'esams' ; }
    elsif ($squid =~ /knams/)
    { $location = 'knams' ; }
    elsif ($squid =~ /eqiad/)
    {$location = 'eqiad' ; }
    elsif ($squid =~ pmpta)
    { $location = 'pmpta' ; }
    elsif ($squid =~ /^ssl30/)
    {$location = 'esams' ; }
    elsif ($squid =~ /^ssl10/)
    { $location = 'eqiad' ; }
    elsif ($squid =~ /^ssl\d$/)
    { $location = 'pmpta' ; }
    elsif ($squid =~ wikimedia)
    { $location = 'pmpta' ; }

    # roles taken from CommonSettings.php 
    $role = 'role?' ; 
    if ($squid =~ /^ssl/)
    { $role = 'https' ; }
    elsif (($name eq 'sq37')                           or
           ($name ge 'sq59'    and $name le 'sq66')    or
           ($name ge 'sq71'    and $name le 'sq78')    or
           ($name ge 'cp1006'  and $name le 'cp1020')  or
           ($name ge 'knsq23'  and $name le 'knsq29')  or
           ($name ge 'amssq31' and $name le 'amssq46'))
    { $role = 'text' ; }
    elsif ( $name eq 'sq67'    or  $name eq 'sq68'     or
            $name eq 'arsenic' or  $name eq 'niobium'  or  
            $name eq 'cp3001'  or  $name eq 'cp3002'   or  
           ($name ge 'cp3019'  and $name le 'cp3022'))    
    { $role = 'bits' ; }
    elsif (($name eq 'sq33'    or  $name eq 'sq34' or $name eq 'sq36') or
           ($name ge 'cp1001'  and $name le 'cp1005')) 
    { $role = 'API' ; }
    elsif (($name ge 'sq41'    and $name le 'sq45')    or
           ($name ge 'sq48'    and $name le 'sq58')    or
           ($name ge 'sq79'    and $name le 'sq86')    or
           ($name ge 'cp1021'  and $name le 'cp1036')  or
           ($name ge 'amssq47' and $name le 'amssq62') or
           ($name ge 'knsq16'  and $name le 'knsq22'))  
    { $role = 'upload' ; }
    elsif  ($name ge 'cp1041'  and $name le 'cp1044')  
    { $role = 'mobile' ; }
    elsif (($name ge 'cp1021'  and $name le 'cp1036')  or
           ($name ge 'cp3003'  and $name le 'cp3010'))
    { $role = 'cache' ; }
    elsif  ($name ge 'sq31'   and $name le 'sq47')  
    { $role = '~RIP1' ; $location = '-' ; }
    elsif  ($name ge 'knsq1'   and $name le 'knsq9')  
    { $role = '~RIP2' ; $location = '-' ; }
    elsif  ($name =~ /^mobile/)
    { $role = '~RIP3' ; $location = '-' ; }
    elsif  ($name eq 'cp1039'  or  $name eq 'cp1040')
    { $role = '~RIP4' ; $location = '-' ; }
    elsif  ($name eq 'gurvin'  or  $name eq 'maerlant' or $name eq yvon)
    { $role = '~RIP5' ; $location = '-' ; }
    elsif  ($name eq 'marmontel')
    { $role = 'unknown1' ;  }


    next if $role eq 'text' and $location eq 'pmpta' ;

    $roles_locations {"$role/$location"} ++ ;
    ($squid3 = $squid) =~ s/\.wikimedia\.org// ; 
    $squid3 =~ s/\.esams// ;
    $squid3 =~ s/\.knams// ;
    $squid3 =~ s/\.eqiad// ;
    $squid3 =~ s/\.pmpta// ;
    $squid3 =~ s/\.wmnet// ;
    $servers_found {"$role/$location"} {$squid3} ++ ;

    $squid2 = $squid ;
    $squid2 =~ s/\..*// ;
    ($digits = $squid2) =~ s/[^\d]//g ;
    $digits =~ s/\d?\d$/*/ ;
    ($name = $squid2) =~ s/[\d]//g ;
    $squid_set = "$role/$location.$name$digits"  ;

    $squid_sets {$squid_set}++ ;

    if ($squid_sets_lo {$squid_set} eq '')
    { $squid_sets_lo {$squid_set} = "$role/$location.$squid2" ; }
    if ($squid_sets_hi {$squid_set} eq '')
    { $squid_sets_hi {$squid_set} = "$role/$location.$squid2" ; }

    if ($squid_sets_lo {$squid_set} gt "$role/$location.$squid2")
    { $squid_sets_lo {$squid_set} = "$role/$location.$squid2" ; }
    if ($squid_sets_hi {$squid_set} lt "$role/$location.$squid2")
    { $squid_sets_hi {$squid_set} = "$role/$location.$squid2" ; }

  # if ($squid ne '')
  # { $squids {"$squid,$date_yyyy_mm"} += $events ; }

    $squid_events_month {"$squid,$date_yyyy_mm"} += $events ;
    $squid_hours_month  {"$squid,$date_yyyy_mm"} ++ ;

    $squid_set_delta_month  {"$squid_set,$date_yyyy_mm"} += $avg_delta ;
    $squid_set_events_month {"$squid_set,$date_yyyy_mm"} += $events ;
    $squid_set_hours_month  {"$squid_set,$date_yyyy_mm"} ++ ;

    #if ($squid =~ /^(?:amssq|cp10|kns|sq)/)  # only for regular squids for clearer correction data
    #{
    #  $squid_sets_averaged_delta_sequence_numbers {$squid_set} ++ ;
    #  $all_regular_squids_delta_hour  {"$squid_set,$date_yyyy_mm_dd,$hour"} += $avg_delta ;
    #  $all_regular_squids_active      {"$squid_set,$date_yyyy_mm_dd,$hour"} ++ ;
    #}
    $squid_sets_averaged_delta_sequence_numbers {$role} ++ ;
    $all_regular_squids_delta_hour  {"$role,$date_yyyy_mm_dd,$hour"} += $avg_delta ;
    $all_regular_squids_active      {"$role,$date_yyyy_mm_dd,$hour"} ++ ;
  }
  close CSV ;
}

sub BuildListDaysHours
{
  $yyyy_min = substr ($date_yyyy_mm_dd_min,0,4) ;
  $mm_min   = substr ($date_yyyy_mm_dd_min,5,2) ;
  $dd_min   = substr ($date_yyyy_mm_dd_min,8,2) ;

  $yyyy_max = substr ($date_yyyy_mm_dd_max,0,4) ;
  $mm_max   = substr ($date_yyyy_mm_dd_max,5,2) ;
  $dd_max   = substr ($date_yyyy_mm_dd_max,8,2) ;

  print "start at $yyyy_min $mm_min $dd_min\n" ;
  print "stop at  $yyyy_max $mm_max $dd_max\n" ;
  
  $yyyy = $yyyy_min ;
  $mm   = $mm_min ;
  $dd   = $dd_min ; 

  $yyyy_mm_dd = sprintf ("%04d-%02d-%02d", $yyyy,$mm,$dd) ;

  while ($yyyy_mm_dd le $date_yyyy_mm_dd_max)
  {
    for (my $h = 0 ; $h < 24 ; $h++)
    { push @days_hours, "$yyyy_mm_dd," . sprintf ("%02d",$h) ; }
    $dd++ ;
    if ($dd > days_in_month ($yyyy,$mm))
    {
      $dd = 1 ;
      $mm++ ;
      if ($mm > 12)      
      {
        $mm = 1 ; 
        $yyyy++ ;	
      }
    }	    
    $yyyy_mm_dd = sprintf ("%04d-%02d-%02d", $yyyy,$mm,$dd) ;
    print "$yyyy_mm_dd\n" ;
  }
}

# this file can be used to patch projectcounts files from dammit.lt/wikistats to make up for missing events (due to server overload)
# if for some hour average gap in sequence numbers is 1200 instead of 1000 this means all per wiki counts in projectcount file for that hour need correction: * 1200/1000
sub WriteHourlyAveragedDeltaSequenceNumbers
{
  my $line ;

  open CSV , '>',  "$path_csv_out/SquidDataHourlyAverageDeltaSequenceNumbers.csv" ;

  $line = "day,hour" ;
  foreach $squid_set (sort keys %squid_sets_averaged_delta_sequence_numbers)
  { $line .= ",$squid_set" ; }
  print CSV "$line\n" ;

  foreach $date_hour (@days_hours)
  {
    $line = "$date_hour" ;
    foreach $squid_set (sort keys %squid_sets_averaged_delta_sequence_numbers)
    {
      $squid_set_date_hour = "$squid_set,$date_hour" ;	    
      if ($all_regular_squids_delta_hour  {$squid_set_date_hour} == 0)	  
      { $avg_delta_all_regular_squids = '' ; }
      else
      { $avg_delta_all_regular_squids = sprintf ("%.0f", $all_regular_squids_delta_hour  {$squid_set_date_hour} / $all_regular_squids_active {$squid_set_date_hour}) ; }
      $line .= ",$avg_delta_all_regular_squids" ;
    }  
    print CSV "$line\n" ;
    print     "$line\n" ;
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
  
  print CSV "Role taken from CommonSettings.php\n\n" ;
 
  foreach $role_location (sort keys %roles_locations)
  {
    $line = "$role_location:" ;
    %servers = %{$servers_found {$role_location}} ;
    foreach $server (sort keys %servers)    
    { $line .= " $server" ; }
    $line =~ s/~// ; # ~ just for sorting
    print CSV "$line\n" ;
  } 
  print CSV "\n" ;

  print CSV "\nAverage delta in sequence numbers per squid per active hour \n\n" ;

  $line1 = '' ;
  $line2 = '' ;
  $line3 = "month" ;
  foreach $squid_set (sort keys %squid_sets)
  {
    if ($squid_sets_lo {$squid_set} eq $squid_sets_hi {$squid_set})
    { $squid_range = $squid_sets_lo {$squid_set} ; }
    else
    {
      ($squid_sets_hi_num = $squid_sets_hi {$squid_set}) =~ s/[^\d]//g ;
      $squid_range = $squid_sets_lo {$squid_set} . "-" . $squid_sets_hi_num ;
    }
    ($role     = $squid_range) =~ s/\/.*$// ;  $role =~ s/\~// ; # ~ just for sorting
    ($location = $squid_range) =~ s/\..*$// ;  $location =~ s/^[^\/]*\/// ;
    ($range    = $squid_range) =~ s/^[^\.]*\.// ;

    $line1 .= ",$role" ;
    $line2 .= ",$location" ;
    $line3 .= ",$range" ;
  }
  print CSV "$line1\n" ;
  print CSV "$line2\n" ;
  print CSV "$line3\n" ;

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

  print CSV "\n\nAverage events per squid per active hour in 1:1000 sampled log\n\n" ;
  
  print CSV "$line1\n" ;
  print CSV "$line2\n" ;
  print CSV "$line3\n" ;

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

  close CSV ;
}

sub days_in_month
{
  my $year = shift ;
  my $month = shift ;

  my $month2 = $month+1 ;
  my $year2  = $year ;
  if ($month2 > 12)
  { $month2 = 1 ; $year2++ }

  my $timegm1 = timegm (0,0,0,1,$month-1,$year-1900) ;
  my $timegm2 = timegm (0,0,0,1,$month2-1,$year2-1900) ;
  $days = ($timegm2-$timegm1) / (24*60*60) ;
  return ($days) ;
}

