 #!/usr/bin/perl

# /usr/local/bin/geoiplogtag uses /usr/share/GeoIP/GeoIP.dat
# test:
# echo 125.123.123.123 | /usr/local/bin/geoiplogtag 1
# refresh: bayes:/usr/share/GeoIP> wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
use config ;

sub CollectFilesToProcess
{
  trace CollectFilesToProcess ;

  if (! $job_runs_on_production_server)
  {
    push @files, $file_test ;
    return $true ;
  }

  my ($days_ago, $date_collect_files, $time_to_start, $time_to_stop, $path_out, $path_out_month) = @_ ;

  print "Collect files for date $date_collect_files: files with timestamps between $time_to_start and $time_to_stop\n\n" ;

  my $all_files_found = $true ;

  my ($date_archived) ;

  $some_files_found = $false ;
  $full_range_found = $false ;

  $path_head_tail = "$path_out_month/$file_head_tail" ;

  # file naming scheme on server: sampled-1000.log-yyyymmdd, does not mean on that day file sampled-1000.log was archived
  # file can contain data for days(s) before and day (days?) after yyyymmdd, see e.g. sampled-10000.log-20090802 (days 0801-0803)
  # this is confusing so start a few days earlier and check for each day:
  # whether a file exists and whether it's 'head' and or 'tail' time (first last record) fall within range

  # find first and last file to process, meaning all files that comprise log records within date range

  $head_found = $false ;
  $tail_found = $false ;

  for ($days_ago_inspect = $days_ago + 2 ; $days_ago_inspect >= $days_ago - 5 ; $days_ago_inspect--)
  {
    next if $days_ago_inspect < 0 ; # days ago can't be negative

    ($sec,$min,$hour,$day,$month,$year) = localtime ($time_start - $days_ago_inspect * 24 * 3600) ;
    $date_archived = sprintf ("%4d%02d%02d", $year+1900, $month+1, $day) ;
    print "\n- Inspect file saved $days_ago_inspect days ago: $logname-$date_archived.gz\n" ;

    my $file = "$dir_in/$logname-$date_archived.gz" ;

    if (! -e $file)
    { print "- File not found: $file\n" ; }
    else
    {
      ($timehead,$timetail) = &GetLogRange ($file, $path_head_tail) ;

      if (($timetail ge $time_to_start) && ($timehead le $time_to_stop))
      {
        print "- Include this file\n" ;

        $some_files_found = $true ;
        push @files, $file ;
        if ($timehead le $time_to_start) { $head_found = $true ; print "- Head found\n" ; }
        if ($timetail ge $time_to_stop)  { $tail_found = $true ; print "- Tail found\n" ; }
      }

      # assuming only one file is archived per day !
      if ($head_found && $tail_found)
      {
        $full_range_found = $true ;
        last ;
      }
    }
  }

  if (! $some_files_found)
  { print "Not any file was found which contains log records for $days_ago days ago. Skip processing for $date_collect_files.\n\n" ; return $false ; }
  if (! $full_range_found)
  { print "Not all files were found which contain log records for $days_ago days ago. Skip processing for $date_collect_files.\n\n" ; return $false ; }

  print "\n" ;
  foreach $file (sort @files)
  { print "Process $file\n" ; }

  return $true ;
}

sub ReadIpFrequencies
{
  trace ReadIpFrequencies ;

  my $path_out = shift ;

  my $data_read = $false ;

  if ($job_runs_on_production_server)
  {
    if (! -e "$path_out/$file_ip_frequencies_bz2")
    { print "$path_out/$file_ip_frequencies_bz2 not found. Abort processing for this day." ; return $false ; }

    open CSV_ADDRESSES, "-|", "bzip2 -dc \"$path_out/$file_ip_frequencies_bz2\"" || abort ("Input file $path_out/$file_ip_frequencies_bz2 could not be opened.") ;
  }
  else
  {
    if (! -e "$path_out/$file_ip_frequencies")
    { print "$path_out/$file_ip_frequencies not found. Abort processing for this day." ; return $false ; }

    open CSV_ADDRESSES, '<', "$path_out/$file_ip_frequencies" || abort ("Input file $path_out/$file_ip_frequencies could not be opened.") ;
  }

  while ($line = <CSV_ADDRESSES>)
  {
    $data_read = $true ;

    if ($line =~ /^#/o) { next ; }
    chomp ($line) ;
    ($frequency, $address) = split (',', $line) ;
    $ip_frequencies {$address} = $frequency ;
    $addresses_stored++ ;
  }

  print "\n$addresses_stored addresses stored that occur more than once\n\n" ;

  return $data_read ;
}

sub ReadSquidLogFiles
{
  trace ReadSquidLogFiles ;

  my $data_read = $false ;

  my ($path_out, $time_to_start, $time_to_stop, @files) = @_ ;

  if ($#files == -1)
  { print "ReadInput: No files to process.\n\n" ; }

  print "Read log records in range $time_to_start till $time_to_stop\n\n" ;

  if ($job_runs_on_production_server && $scan_all_fields)
  {
    open FILE_EDITS_SAVES, '>', "$path_out/$file_edits_saves" ;

    my $file_csv_views_viz2 = $file_csv_views_viz ;
    my $date = substr ($time_to_start,0,4) . substr ($time_to_start,5,2) . substr ($time_to_start,8,2) ;
    $file_csv_views_viz2 =~ s/date/$date/ ;
    $gz_csv_views_viz = gzopen ($file_csv_views_viz2, "wb") || die "Unable to write $file_csv_views_viz2 $!\n" ;

    $comment = "# Data from $time_to_start till $time_to_stop (yyyy-mm-ddThh:mm:ss) - all counts in thousands due to sample rate of log (1 = 1000)\n" ;
    $gz_csv_views_viz->gzwrite($comment) || die "Zlib error writing to $file_csv_views_viz: $gz_csv_views_viz->gzerror\n" ;
    $comment = ":time,ip,domain,bot,mobile,os,client\n" ;
    $gz_csv_views_viz->gzwrite($comment) || die "Zlib error writing to $file_csv_views_viz: $gz_csv_views_viz->gzerror\n" ;
  }

  my $lines = 0 ;
  while ($#files > -1)
  {
    $file_in = shift (@files) ;

    print "Process $file_in\n" ;
    if (! -e $file_in)
    { print "ReadInput: File not found: $file_in. Aborting...\n\n" ; exit ; }

    if ($job_runs_on_production_server)
    {
      if ($file_in =~ /\.gz$/o)
      { open IN, "-|", "gzip -dc $file_in | sed s/\\ \\ */\\ /g | /usr/local/bin/geoiplogtag 5" ; } # http://perldoc.perl.org/functions/open.html
      else
      { open IN, "-|", "cat $file_in | /usr/local/bin/geoiplogtag 5" ; } # http://perldoc.perl.org/functions/open.html
      $fields_expected = 14 ;
    }
    else
    {
      open IN, '<', $file_in ;
    #  $fields_expected = 14 ;
      $fields_expected = 13 ;
    }

    $line = "" ;
    while ($line = <IN>)
    {
      $lines_in_file ++ ;

    # if ($line =~ /fy\.wikipedia\.org/o) # test/debug
    # {
    #   print FILTER_FY $line ;
    #   print $line ;
    # }


# ugly Q&D code to circumvent spaces in agent string
# $line2 = $line ;
      chomp $line ;
      @fields = split (' ', $line) ;
# next if $line =~ /upload/ ;
# next if $line !~ /en\.m\.wikipedia/ ;
# next if $fields[10] eq '-' ;
# print "mime " . $fields[10] . "\n" ;
#next if $fields [9] eq '-' ;
#next if $fields [9] =~ /NONE/ ;
     if ($#fields > 14)
     {
# print "line $line2\n" ;
# print "fields " . $#fields . "\n$line\n" ;
      $country_code = $fields [$#fields] ;
      $fields [$#fields] = '' ;
      $line = join (' ', @fields) ;
# print "2 $line\n" ;
      @fields = split (' ', $line, 14) ;
      $fields [14] = $country_code ;
# print "\n\n12: " . $fields [12] . "\n"  ;
# print "13: " . $fields [13] . "\n"  ;
# print "14: " . $fields [14] . "\n"  ;
# print "15: " . $fields [15] . "\n"  ;
      }

      if ($#fields < $fields_expected) { $fields_too_few  ++ ; print "invalid field count " . $#fields . "\n" ; next ; }
      if ($#fields > $fields_expected) { $fields_too_many ++ ; print "invalid field count " . $#fields . "\n" ; next ; }

      $time = $fields [2] ;

      if (($oldest_time_read eq "") || ($time lt $oldest_time_read))
      { $oldest_time_read = $time ; }
      if (($newest_time_read eq "") || ($time gt $newest_time_read))
      { $newest_time_read = $time ; }

      if ($oldest_time_read ge $time_to_stop)
      { last ; }

      if ($time lt $time_to_start)
      {
        if (++ $times % 100000 == 0)
        { print "[$time]\n" ; }
        next ;
      }

      if ($time ge $time_to_stop)
      { last ; }

      $date = substr ($time,0,10) ;
      if ($date lt $date_prev) { next ; } # occasionally one record for previous day arrives late

      $data_read = $true ;
      if ($date ne $date_prev)
      {
        print &ddhhmmss (time - $time_start) . " $date\n" ;
        if ($date_prev ne "")
        {
          print "$date_prev: $lines_this_day\n" ;
          $lines_read {$date_prev} = $lines_this_day ;
        }
        $lines_this_day = 0 ;
        $date_prev = $date ;
      }
      $lines_this_day++ ;

      if ($job_runs_on_production_server)
      {
        if (($line =~ /action=edit/o) || ($line =~ /action=submit/o))
        { print FILE_EDITS_SAVES $line ; }
      }

      $lines++ ;

#next if $line !~ /http:\/\/\w+\.m\./ ;
#print "$line\n" ;
      &ProcessLine ($line) ;
      if (++ $lines_processed % 10000 == 0)
      {
        if ($banner_requests_ignored == 0)
        { print "$time $lines_processed\n" ; }
        else
        { print "$time $lines_processed ($banner_requests_ignored banner requests ignored)\n" ; }
      }
      if ($test and $lines_processed >= $test_maxlines)
      { last ; }
    }
    close IN ;
  }

  if ($scan_ip_frequencies)
  { return ($data_read) ; }

  if ($job_runs_on_production_server)
  {
    close FILE_EDITS_SAVES ;
    gzclose $gz_csv_views_viz ;
  }

  $lines_read {$date_prev} = $lines_this_day ;

  if ($lines == 0)
  {
    $data_read = $false ;
    print "No data found for $time_to_start - $time_to_stop\n" ;
  }
  else
  { print "$lines_this_day out $lines_in_file processed\n" ; }

  if ($url_wikipedia_mobile > 0)
  {
    print "\n$redirected_to_mobile out of $url_wikipedia_mobile (" . sprintf ("%.1f\%", 100 * $redirected_to_mobile / $url_wikipedia_mobile) . ") redirected to mobile wikipedia\n\n" ;
    foreach $status (sort {$status_url_wikipedia_mobile {$b} <=> $status_url_wikipedia_mobile {$a}} keys %status_url_wikipedia_mobile)
    { print "Status $status: " . $status_url_wikipedia_mobile {$status} . "\n" ; }
    print "\n" ;
  }

  else
  { print "\nNo mobile urls detected ?!?!\n\n" ; }

  return ($data_read) ;
}

sub ReadInputEditsSavesFile
{
  trace ReadInputEditsSavesFile ;

  my $file_txt = shift ;

  print "Process $file_txt\n" ;

  open IN, "-|", "bzip2 -dc \"$file_txt\"" || abort ("Input file '" . $file_txt . "' could not be opened.") ;
# open IN, '<', "2010-04/SquidDataEditsSaves2010-04-01.txt" || abort ("Input file '" . $file_txt . "' could not be opened.") ; # test

  while ($line = <IN>)
  {
    if ($line =~ /index\.php/o)
    { &ProcessLine ($line) ; }
  }
  close IN ;
}

sub GetLogRange # finding first and last timestamp ('head' and 'tail') in compressed file is costly, cache results for reuse
{
  my ($file,$path_head_tail) = @_ ;

  if (-e $path_head_tail)
  {
    open CSV_HEAD_TAIL, '<', $path_head_tail ;
    while ($line = <CSV_HEAD_TAIL>)
    {
      chomp $line ;
      my ($logfile,$head,$tail) = split (',', $line) ;
      $timeheads {$logfile} = $head ;
      $timetails {$logfile} = $tail ;
    }
    close CSV_HEAD_TAIL ;
  }

  $timehead = $timeheads {$file} ;
  $timetail = $timetails {$file} ;

  if (($timehead ne '') && ($timetail ne ''))
  {
    print "- HEAD $timehead TAIL $timetail (from head-tail cache)\n" ;
    return ($timehead, $timetail) ;
  }

  my ($line, @fields, $timehead, $timetail) ;
  print "$file: "  ;
  if (! -e $file)
  {
    print "- GetLogRange error: File not found: $file\n" ;
    exit ;
  }

  if ($file =~ /\.gz$/o)
  { $line = `gzip -dc $file | head -n 1 ` ; }
  else
  { $line = `head -n 1 $file` ; }
  # print "HEAD $line\n" ;
  @fields = split (' ', $line) ;
  # $timehead = substr ($fields [2],0,10) ;
  $timehead = $fields [2] ;

  if ($file =~ /\.gz$/o)
  { $line = `gzip -dc $file | tail -n 1 ` ; }
  else
  { $line = `tail -n 1 $file` ; }

  # print "TAIL $line\n" ;
  @fields = split (' ', $line) ;
  # $timetail = substr ($fields [2],0,10) ;
  $timetail = $fields [2] ;

  print "- HEAD $timehead TAIL $timetail\n" ;

  open  CSV_HEAD_TAIL, '>>', $path_head_tail ;
  print CSV_HEAD_TAIL "$file,$timehead,$timetail\n" ;
  close CSV_HEAD_TAIL ;

  return ($timehead, $timetail) ;
}

sub GetTimeIso8601
{
  my $time = shift ;
  my $year = substr ($time,0,4) ;
  my $mon  = substr ($time,5,2) ;
  my $mday = substr ($time,8,2) ;
  my $hour = substr ($time,11,2) ;
  my $min  = substr ($time,14,2) ;
  my $sec  = substr ($time,17,2) ;
  $time = timelocal($sec,$min,$hour,$mday,$mon-1,$year-1900);
  return ($time) ;
}

1;
