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
#
# 2013 July: added html report
#
# comment by Andrew: In conjunction, there are similar ganglia metrics of these numbers on each of the udp2log boxes. Example: http://bit.ly/13pkK3e
# You can see a similar breakdown of packet_loss_average per role.  These roles are defined by the pybal config:  http://noc.wikimedia.org/pybal/
# The packet_loss_average metric is sampled at a 1/10 level instead of 1/1000, so it will be slightly more accurate.  However, these metrics don't weight anything, so if there is any loss from a role that has very few requests, the average will be skewed.
# Having both of these available for troubleshooting is very useful.
# reply by Erik Zachte:
# > However, these metrics don't weight anything, so if there is any loss from a role that has very few requests, the average will be skewed.
# Yes, that is precisely what I thought was missing. So what my report adds is the bottom line: "how much of x% drop in MoM page views can be attributed to msg loss?"
# And as we have server clusters on hot standby, being fed a trickle of data (as I understood long ago to keep caches up to date), their contribution to overall loss would be minimal.
# But seeing them in red could give early warning that we would have an issue when they would become primary server.

 
  use Time::Local ;
  use Getopt::Std ;
  use File::Path ;
  getopt ("ioh", \%options) ;

  $| = 1; # flush screen output

  $date_yyyy_mm_dd_min = "9999-99-99" ;
  $date_yyyy_mm_dd_max = "0000-00-00" ;
  
  $path_csv_in = $options {'i'} ;
  die "Specify input path (squids csv top folder) as -i [path]" if $path_csv_in eq '' ;
  die "Input path '$path_csv_in' not found (squids csv top folder)" if ! -d $path_csv_in ;

  $path_csv_out = $options {'o'} ;
  die "Specify csv output path as -o [path]" if $path_csv_out eq '' ;

  $path_html_out = $options {'h'} ;
  die "Specify html output path as -h [path]" if $path_html_out eq '' ;

  if (! -d $path_csv_out)
  {
    mkpath $path_csv_out ;
    die "Path '$path_csv_out' could not be created" if ! -d $path_csv_out ;
  }

  if (! -d $path_html_out)
  {
    mkpath $path_html_out ;
    die "Path '$path_html_out' could not be created" if ! -d $path_html_out ;
  }

# read all files on squid log aggregator with hourly counts for
# - number of events received per squid
# - average gap in sequence numbers (this should be 1000 idealy on a 1:1000 sampled log)
# write several aggregations of these data

  &ReadData ;
  &ProcessData ;
  &CalcHourlyEvents ;
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

    # roles mostly taken from http://noc.wikimedia.org/conf/highlight.php?file=squid.php  (roles for older servers retained from elsewhere)
    $role = '' ; 
    if ($squid =~ /^ssl/)
    { $role = 'ssl' ; }

    # not maximaly efficient but compact
    # instead of specifying range which implies nested condition here's a simple and condense iteration:
    $role = 'text' if $location eq 'pmpta' and $name =~ /sq37|sq59|sq60|sq61|sq62|sq63|sq64|sq65|sq66|sq71|sq72|sq73|sq74|sq75|sq76|sq77|sq78/ ;
    $role = 'text' if $location eq 'eqiad' and $name ge 'cp1006'  and $name le 'cp1020' ;
    $role = 'text' if $location eq 'esams' and $name ge 'knsq23'  and $name le 'knsq29' ;
    $role = 'text' if $location eq 'knams' and $name ge 'knsq23'  and $name le 'knsq29' ;
    $role = 'text' if $location eq 'esams' and $name ge 'amssq31' and $name le 'amssq46' ;

    $role = 'bits' if $location eq 'pmpta' and $name =~ /sq67|sq68|sq69|sq70/ ;
    $role = 'bits' if $location eq 'eqiad' and $name =~ /arsenic|mobium|cp1056|cp1057|cp1069|cp1070/ ;
    $role = 'bits' if $location eq 'esams' and $name =~ /cp3019|cp3020|cp3021|cp3022/ ;

    $role = 'api'  if $location eq 'pmpta' and $name =~ /sq33|sq34|sq36/ ;
    $role = 'api'  if $location eq 'eqiad' and $name =~ /cp1001|cp1002|cp1003|cp1004|cp1005/ ;
    
    $role = 'upload' if $location eq 'pmpta' and ( ($name ge 'sq41' and $name le 'sq45') or ($name ge 'sq48' and $name le 'sq58') or ($name ge 'sq79' and $name le 'sq86') ) ;    
    $role = 'upload' if $location eq 'eqiad' and ( ($name ge 'cp1021'  and $name le 'cp1036') or ($name ge 'cp1048'  and $name le 'cp1051') or ($name ge 'cp1061'  and $name le 'cp1064') or $name eq 'dysprosium' ) ;
    $role = 'upload' if $location eq 'esams' and ( ($name ge 'cp3003' and $name le 'cp3010') or ($name ge 'knsq16'  and $name le 'knsq22') ) ;
    $role = 'upload' if $location eq 'knams' and $name ge 'knsq16'  and $name le 'knsq22' ;
    $role = 'upload' if $location eq 'esams' and $name ge 'amssq47' and $name le 'amssq62' ;
    
    $role = 'mobile' if $location eq 'pmpta' and $name =~ /cp1041|cp1042|cp1043|cp1044/ ; # http://noc.wikimedia.org/conf/highlight.php?file=squid.php ?? not live config?
    $role = 'mobile' if $location eq 'eqiad' and $name =~ /cp1041|cp1042|cp1043|cp1044|cp1046|cp1047|cp1059|cp1060/ ;
    $role = 'mobile' if $location eq 'esams' and $name =~ /cp3011|cp3012|cp3013|cp3014/ ;
    
    $role = 'varnish' if $location eq 'eqiad' and ( ($name ge 'cp1037' and $name le 'cp1040') or ($name ge 'cp1052' and $name le 'cp1055') or ($name ge 'cp1065'  and $name le 'cp1068') ) ;
    if ($role eq '') # old code predates squid.php
    {
       if     ($name ge 'sq31'   and $name le 'sq47')  
       { $role = '~RIP1' ; } # $location = '-' ; }
    
       elsif  ($name ge 'knsq1'   and $name le 'knsq9')  
       { $role = '~RIP2' ; } # $location = '-' ; }
    
       elsif  ($name =~ /^mobile/)
       { $role = '~RIP3' ; } # $location = '-' ; }
    
       elsif  ($name eq 'cp1039'  or  $name eq 'cp1040')
       { $roe = '~RIP4' ; } # $location = '-' ; }
    
       elsif  ($name eq 'gurvin'  or  $name eq 'maerlant' or $name eq yvon)
       { $role = '~RIP5' ; } # $location = '-' ; }
    
       else
       { $role = 'zrole?' ; } # z -> sort last, but before RIP
    }   

    next if $location eq 'pmpta' and $name =~ /cp1039|cp1040/ ; # too old, one data point 

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

sub CalcHourlyEvents
{
  foreach $squid_set (sort keys %squid_sets)
  {
    foreach $month (sort keys %months)
    {
      $key = "$squid_set,$month" ;
      if ($squid_set_hours_month {$key} > 0)
      { $squid_set_hourly_events {$key} = sprintf ("%.0f", $squid_set_events_month {$key}  / $squid_set_hours_month {$key}) ;  }
      
      if ( $squid_set_hourly_events {$key} >  $squid_set_hourly_events_hi {$squid_set} ) 
      { $squid_set_hourly_events_hi {$squid_set} =  $squid_set_hourly_events {$key} ; }
    }
  }
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
  open HTML, '>', "$path_html_out/SquidDataMonthlyPerSquidSet.htm" ;
  print HTML "<html>\n<head>\n<title>Monthly avg msg loss per squid set</title>\n" .
             "<style type='text/css'>\n" .
             "<!--\n" .
             "td  {white-space:nowrap; text-align:right; background-color:#DDD; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:10px}\n" .
             "th  {white-space:nowrap; text-align:right; background-color:#BBB; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:10px}\n" .
	     "td.improbable        {background-color:#AAA; color:#B0B}\n" .
	     "td.good              {background-color:#4F4; color:#000}\n" .
	     "td.mediocre          {background-color:#FF4; color:#000}\n" .
	     "td.bad               {background-color:#F00; color:#FFF}\n" .
	     "td.insignificant     {background-color:#AAA; color:#666}\n" .
	     "td.msg_loss_good     {background-color:#FFF; color:#080}\n" .
	     "td.msg_loss_mediocre {background-color:#FFF; color:#FA0}\n" .
	     "td.msg_loss_bad      {background-color:#FFF; color:#F00}\n" .
             "-->\n" .
             "</style>\n" .
	     "</head><body>\n" ;

  print HTML "<h3>udp2log message loss, and traffic volume, based on 1:1000 sampled squid logs</h3>\n" ;
  print HTML "<p>Server roles mostly taken from <a href='http://noc.wikimedia.org/conf/highlight.php?file=squid.php'>squid.php</a><p>\n" ;

  open CSV,  '>', "$path_csv_out/SquidDataMonthlyPerSquidSet.csv" ;
  print CSV "Server roles mostly taken from http://noc.wikimedia.org/conf/highlight.php?file=squid.php<small>\n\n" ;
 
  foreach $role_location (sort keys %roles_locations)
  {
    $line_csv  = "$role_location:" ;
    ($role_location2 = $role_location) =~ s/zrole/role/ ; # z was added to sort last before RIP
    $line_html = "<b>$role_location2:</b>" ;
    %servers = %{$servers_found {$role_location}} ;
    foreach $server (sort keys %servers)    
    { 
      $line_csv  .= " $server" ;
      $line_html .= "$server, " ;
    }
    $line_csv =~ s/~// ; # ~ just for sorting
    print CSV "$line_csv\n" ;
    print HTML "<small>$line_html</small><br>\n" ;
  } 
  print HTML "</small>\n" ;
  print CSV "\n" ;

  print HTML "<p><b>Legend</b><table border=1>\n" ;
  print HTML "<tr><td class='good'>Packet loss less than 0.2% (avg gap < 1020)</td></tr>\n" ;
  print HTML "<tr><td class='mediocre'>Packet loss between 0.2% and 0.5% (1020 <= avg gap < 1052)</td></tr>\n" ;
  print HTML "<tr><td class='bad'>Packet loss larger than 0.5% (avg gap >= 1052)</td></tr>\n" ;
  print HTML "<tr><td class='insignificant'>Insignificant message volume: less than 10 (sampled) msgs per hour</td></tr>\n" ;
  print HTML "<tr><td class='improbable'>Sequence numbers totally broken</td></tr>\n" ;
  print HTML "</table>\n" ;
  print HTML "<p><small>Msg loss is weighed average over all servers, excluding those where sequence numbers are broken (weighed = taking into account message volume)</small>\n" ;
  print HTML "<br><small>Other causes of data loss than UDP msg loss are not covered by this report (e.g. total outage for several hours)</small><br>&nbsp;\n" ;
  print HTML "<table border=1>\n" ;

  print CSV "\nAverage gap between in udp msg sequence numbers per squid per active hour (ideally should be 1000 in 1:1000 sampled log)\n\n" ;

  $line_csv_1  = '' ;
  $line_csv_2  = '' ;
  $line_csv_3  = "month" ;

  $line_html_1 = "<th>&nbsp;</th><th>&nbsp;</th>" ;
  $line_html_2 = "<th>&nbsp;</th><th>&nbsp;</th>" ;
  $line_html_3 = "<th>month</th><th>msg loss</th>" ;

  foreach $squid_set (sort keys %squid_sets)
  {
    next if $squid_set_hourly_events_hi {$squid_set} < 25 ; # skip columns for servers with hardly any throughput ever  
    
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

    $range =~ s/deployment-cache/dpl-ca/ ;

    $role =~ s/zrole/role/ ; # z was to sort last

    $line_csv_1 .= ",$role" ;
    $line_csv_2 .= ",$location" ;
    $line_csv_3 .= ",$range" ;
  
    $line_html_1 .= "<th>$role</th>" ;
    $line_html_2 .= "<th>$location</th>" ;
    $line_html_3 .= "<th>$range</th>" ;
  }
  print CSV "$line_csv_1\n" ;
  print CSV "$line_csv_2\n" ;
  print CSV "$line_csv_3\n" ;

  print HTML "<tr><td colspan=99 style='text-align:left'>&nbsp;<br><b>UDP message loss: average gap between sequence numbers per squid (should be close to 1000 in 1:1000 sampled log)</b><p><small>For calculation of message loss percentage from average gap between sequence numbers see <a href='#calc'>bottom of page</a></small><br>&nbsp;</b></td></tr>\n" ;
  print HTML "<tr>$line_html_1</tr>\n" ;
  print HTML "<tr>$line_html_2</tr>\n" ;
  print HTML "<tr>$line_html_3</tr>\n" ;

  foreach $month (sort keys %months)
  {
    $line_csv = $month ;
    $line_html = "<th>$month</th>XXX" ;
    $total_avg_gap = 0 ;
    $count_avg_gap = 0 ;
    foreach $squid_set (sort keys %squid_sets)
    {
      next if $squid_set_hourly_events_hi {$squid_set} < 25 ; # skip columns for servers with hardly any throughput ever  
      $key = "$squid_set,$month" ;
      if ($squid_set_hours_month {$key} == 0)
      { 
        $line_csv  .= "," ; 
        $line_html .= "<td>&nbsp;</td>" ; 
      }
      else
      { 
        $line_csv  .= "," . sprintf ("%.0f", $squid_set_delta_month {$key}  / $squid_set_hours_month {$key}) ; 
        $class = "" ;

	$avg_gap    = $squid_set_delta_month  {$key}  / $squid_set_hours_month {$key} ;
        $msg_per_hr = sprintf ("%.0f", $squid_set_events_month {$key}  / $squid_set_hours_month {$key}) ; 

	if ($msg_per_hr < 10)
        { $class = "insignificant" ; }
	elsif ((($avg_gap < 950) or ($avg_gap > 2000)) || ($squid_set =~ /^ssl/)) 
        { $class = "improbable" ; }
	else
	{ 
          $count_avg_gap +=            $squid_sets {$squid_set} * $msg_per_hr ;
          $total_avg_gap += $avg_gap * $squid_sets {$squid_set} * $msg_per_hr ;
          if ($avg_gap < 1020)
	  { $class = "good" ; }
	  elsif ($avg_gap < 1040) 
	  { $class = "mediocre" ; }
	  else	
	  { $class = "bad" ; }
        }  
	$avg_gap    = sprintf ("%.0f", $avg_gap) ;
	$line_html .= "<td class='$class'>$avg_gap</td>" ; 
      }
    }
    print CSV  "$line_csv\n" ;

    $weighed_avg_gap = '-' ;
    if ($count_avg_gap > 0)
    { $weighed_avg_gap = sprintf ("%.0f", $total_avg_gap / $count_avg_gap) ; }
    $msg_loss_perc = '-' ;
    if ( $weighed_avg_gap != 0 ) 
    { $msg_loss_perc = sprintf ("%.1f\%", 100 - 100 * (1000 / $weighed_avg_gap)) ; } # see below at $calc for explanation

    if ($msg_loss_perc > 3)
    { $class = "msg_loss_bad" ; }
    elsif ($msg_loss_perc > 1)
    { $class = "msg_loss_mediocre" ; }
    else
    { $class = "msg_loss_good" ; }

    $line_html =~ s/XXX/<td class='$class'><b>$msg_loss_perc<\/b><\/td>/ ;
    print HTML "<tr>$line_html</tr>\n" ;
  }

  $line_html_3 =~ s/msg loss/&nbsp;/ ;

  print CSV "\n\nMessage volume: average events per squid per active hour in 1:1000 sampled log\n\n" ;
  
  print CSV "$line_csv_1\n" ;
  print CSV "$line_csv_2\n" ;
  print CSV "$line_csv_3\n" ;

  print HTML "<tr><td colspan=99 style='text-align:left'>&nbsp;<br><b>Traffic volume: average events per squid per active hour in 1:1000 sampled log <br>&nbsp;</b></td></tr>\n" ;
  print HTML "<tr>$line_html_1</tr>\n" ;
  print HTML "<tr>$line_html_2</tr>\n" ;
  print HTML "<tr>$line_html_3</tr>\n" ;

  foreach $month (sort keys %months)
  {
    $line_csv = $month ;
    $line_html = "<th>$month</th><td>&nbsp;</td>" ;
    foreach $squid_set (sort keys %squid_sets)
    {
      next if $squid_set_hourly_events_hi {$squid_set} < 25 ; # skip columns for servers with hardly any throughput ever  

      $key = "$squid_set,$month" ;
      if ($squid_set_hours_month {$key} == 0)
      { 
        $line_csv  .= "," ; 
        $line_html .= "<td>&nbsp;</td>" ; 
      }
      else
      { 
        $hourly_events = $squid_set_hourly_events {$key} ; 
        $line_csv  .= ",$hourly_events" ;
        $line_html .= "<td>$hourly_events</td>" ; 
      }
    }
    print CSV "$line_csv\n" ;
    print HTML "<tr>$line_html</tr>\n" ;
  }

  close CSV ;

  print HTML "</table>\n" ;

  $calc = <<__calc__ ;
<a name=calc id=calc></a><small>  
<p><b>Calculation of msg loss percentage:</b>
<p>Assume total volume of messages per hour per server is <b>v</b>
<br>We expect average gap between messages per server is 1000 
<br>We see avarage gap is <b>g</b>
<p>Msg received percentage is 100 x actual volume / expected volume 
<br>Msg loss percentage = 100 - msg rcvd percentage
<p>Actual volume = v / g
<br>Expected volume = v / 1000 
<p>Msg rcvd ratio = actual volume / expected volume = (v/g)/(v/1000) = (v/g) x (1000/v)=1000/g
<br>Msg loss perc = 100 - 100 x msg rcvd ratio = 100 - 100 (1000/g)
<p>Examples:
<br>  g = 1000 => msg loss perc = 100 - 100 (1000/1000) =  0 %
<br>  g = 2000 => msg loss perc = 100 - 100 (1000/2000) = 50 %
<p>  g = 1050 => msg loss perc = 100 - 100 (1000/1050) = 4.7%
<br>  g = 1100 => msg loss perc = 100 - 100 (1000/1100) = 9.1%
</small>
__calc__

  print HTML $calc ;
  print HTML "</body></html>\n" ;
  close HTML ;
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

