 #!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;

  $trace_on_exit = $true ;
  ez_lib_version (13) ;

  use SquidCountArchiveProcessLogRecord ;
  use SquidCountArchiveReadInput ;
  use SquidCountArchiveWriteOutput ;

  # set defaults mainly for tests on local machine
  default_argv "-d 2010/05/10" ;

# http://wikitech.wikimedia.org/view/Squid_log_format
# 1. Hostname
# 2. Sequence number
# 3. Current time in ISO 8601 format (oplus milliseconds), according ot the squid server's clock
# 4. Request time in ms
# 5. Client IP
# 6. Squid request status, HTTP status code
# 7. Reply size including HTTP headers
# 8. Request method (GET/POST etc)
# 9. URL
# 10. Squid hierarchy status, peer IP
# 11. MIME content type
# 12. Referer header
# 13. X-Forwarded-For header
# 14 User-Agent header

# valid parameters:
# parm -d m[-n] (last m|n days before today)  or yyyymmdd[-yyyymmdd] or yyyy/mm/dd[-yyyy/mm/dd]
# parm -f [1|2|12] force phase 1 and or 2 even when already ran succesfully earlier
#      phase 1 = collect IP frequency counts, this is first pass through data (there is litle change this needs to be redone, hence default is no overwrite)
#      phase 2 = collect other counts, this may have to be redone after filtering logic has changed
# parm -t test mode

# todo: parm -e use unsampled file with all edits and saves
# todo: parm -r root folder

  $test = $false  ;
  $test_maxlines = 4000000 ;

  if (! $job_runs_on_production_server)
  {
    $test = $true ;
    $file_test = "w:/# Out Locke/sampled-1000-log-20100510b.txt" ;
  # $file_test = getcwd . "/SquidDataFilterFY.txt" ;
    if (! -e $file_test)
    { abort "Test input file '$file_test' not found" ; }
  }

  $time_start = time ;

  if ($job_runs_on_production_server)
  { $path_root = "/a/ezachte" ; }
  else
  { $path_root = "w:/! perl/squids/archive/test" ; }

  $tags_mobile     = "Android|BlackBerry|Windows CE|DoCoMo|iPad|iPod|iPhone|HipTop|LGE|Linux arm|Mobile|MIDP|NetFront|Nintendo|Nokia|Obigo|Opera Mini|Palm Pre|Playstation|Samsung|SoftBank|SonyEricsson|SymbianOS|UP\.Browser|Vodafone|WAP|webOS|Wikiamo|Wikipanion" ;
  $tags_mobile_upd = "May 2010" ;

  $pattern_url_pre  = "(?:^|[a-zA-Z0-9-]+\\.)*?" ;
  $pattern_url_post = "\\.(?:biz|com|info|name|net|org|pro|aero|asia|cat|coop|edu|gov|int|jobs|mil|mobi|museum|tel|travel|arpa|[a-zA-Z0-9-]{2}|(?:com?|ne)\\.[a-zA-Z0-9-]{2})\$" ;

  my (%squid_seqno_lo, %squid_seqno_hi) ;

  my ($from_days_ago, $till_days_ago, $from_date, $till_date) = &ParseArguments ;
  &SetFileNames ;

  my ($path_out, $path_out_month) ;
  for ($days_ago = $from_days_ago ; $days_ago >= $till_days_ago ; $days_ago--)
  {
    if ($days_to_process ++ > 0)
    { print "\n" . "=" x 80 . "\n" ; }
    ($path_out, $path_out_month) = &SetPathOut ($days_ago) ;

    open OUT,  '>', "$path_out/$file_out" ;
    open OUT2, '>', "$path_out/$file_out2" ;
    open ERR,  '>', "$path_out/$file_err" ;
  # open FILTER_FY, '>>', "$path_out_month/$file_filter_fy" ;

    my $do_phase1 = &CheckProcessPhase1 ($days_ago, $path_out) ; # Collect IP frequencies
    my $do_phase2 = &CheckProcessPhase2 ($days_ago, $path_out) ; # collect other data

    next if ! $do_phase1 and ! $do_phase2 ;

    &InitGlobals ;
    undef @files ; # keep out of InitGlobals, to allow rerun with same files, see 'test InitGlobals' below

    ($date_collect_files, $time_to_start, $time_to_stop) = &SetTimeRangeToProcess ($days_ago) ;

    $all_files_found = &CollectFilesToProcess ($days_ago, $date_collect_files, $time_to_start, $time_to_stop, $path_out, $path_out_month) ;
    next if not $all_files_found ;

    if ($do_phase1) # Collect IP frequencies
    { &ProcessPhase1 ($days_ago, $date_collect_files, $time_to_start, $time_to_stop,  $path_out, @files) ; }

    if ($do_phase2) # collect other data
    { &ProcessPhase2 ($days_ago, $date_collect_files, $time_to_start, $time_to_stop,  $path_out, $path_out_month, @files) ; }

    # test InitGlobals: rebuild files in alternate folder, if InitGlobals did its work, all files are binary equal
    # &InitGlobals ;
    # if ($do_phase2) # collect other data
    # { &ProcessPhase2 ($days_ago, $date_collect_files, $time_to_start, $time_to_stop,  $path_out. 'b', $path_out_month, @files) ; }

    close OUT ;
    close OUT2 ;
    close ERR ;
  # close FILTER_FY ;
  }

#  if (defined ($options {"u"})) # all lines with action=edit or action=submit generated in mode scan_squid_archive
#  { &ScanEditsSavesFile ; } # also use to build ScanDataCountriesSaves.csv for earlier months from SquidDataEditsSavesyyyy-mm-dd.txt.bz2
#  else
#  {
#    if (defined ($options {"a"})) # scan ip addresses only (find multiple occurrences, store for reuse)
#    {
#      $scan_ip_frequencies = $true ;
#      print "Scan for multiple occurrences of ip addresses\n\n" ;
#    }
#    elsif (defined ($options {"s"})) # scan squid sequence numbers
#    {
#      $scan_squid_msg_sequence_numbers = $true ;
#      print "Scan for squid sequence numbers\n\n" ;
#    }
#    else
#    {
#      $scan_all_fields = $true ;
#      print "Scan all fields\n\n" ;
#    }

#    &ScanSquidArchive ;
#  }

#  &ProcessSquidSequenceNumbers ;

  print "\n\nReady\n\n" ;
  exit ;

sub ParseArguments
{
  trace ParseArguments ;

  my %options ;

  getopt ("df", \%options) ;

  $date_range   = $options {"d"} ;
  $force_phases = $options {"f"} ;

  if ($force_phases !~ /^(?:|1|2|12|21)$/)
  { abort "Invalid data for -f parameter: specify which phases to force as -f [1|2|12]\nForce  = execute phase even when already done succesfully earlier\nPhase1 = collect ip counts\nPhase2 = collect other counts\n" ; }

  if ($date_range eq '')
  { abort "No valid date range specified\n\nSpecify first and last day to process as:\n'-d yyyymmdd[-yyyymmdd]' (yymmdd or yyyy/mm/dd, " .
          "second date defaults to first)\nor\n'-d mmm[-nnn]', where mmm and nnn are days before today (mmm less or equal to nnn), nnn defaults to mmm\n\n" ; }

  if ($date_range =~ m/^\d{4}\/?\d{2}\/?\d{2}(?:\-\d{4}\/?\d{2}\/?\d{2})?$/) # specify daterange as yyyymmdd-yyyymmdd or yyyy/mm/dd-yyyy/mm/dd
  {
    if ($date_range =~ /^\d{4}\/?\d{2}\/?\d{2}$/) # expand shorthand version
    { $date_range =~ s/^(\d{4}\/?\d{2}\/?\d{2})$/$1-$1/ ; }

    ($from_date,$till_date) = split '-', $date_range ;

    $from_year  = substr ($from_date,0,4) ;
    $from_month = substr ($from_date,4,2) ;
    $from_day   = substr ($from_date,6,2) ;

    $till_year  = substr ($till_date,0,4) ;
    $till_month = substr ($till_date,4,2) ;
    $till_day   = substr ($till_date,6.2) ;

    $from_days_ago = ValidateDateAndCalcDaysAgo ('from date', $from_date) ;
    $till_days_ago = ValidateDateAndCalcDaysAgo ('till date', $till_date) ;

    my $diff_days = ($from_days_ago - $till_days_ago) + 1 ;
    if ($till_days_ago > $from_days_ago)
    { abort "Invalid date range: from date '$from_date' is later than till date '$till_date'\n" ; }

    $yyyymmdd = 'yyyy/mm/dd' ;
    if ($from_date !~ /\//)
    { $yyyymmdd =~ s/\///g ; }
    print "Process following date range:\nFrom '$from_date' till '$till_date' ($yyyymmdd)\nWhich is from $from_days_ago till $till_days_ago days ago = $diff_days days\n" ;
  }
  elsif ($date_range =~ /^\d{1,3}(?:-\d{1,3})?$/) # specify daterange as mmm-nnn (where mmm and nnn are number of days before today), nnn defaults to mmm
  {
    if ($date_range =~ /^\d+$/) # expand shorthand version
    { $date_range =~ s/^(\d+)$/$1-$1/ ; }

    ($from_days_ago,$till_days_ago) = split '-', $date_range ;

    if ($till_days_ago > $from_days_ago) # swap
  # { abort "Invalid date range: from date '$from_date' is later than till date '$till_date'\n" ; }
    { my $temp = $till_days_ago ; $till_days_ago = $from_days_ago ; $from_days_ago = $temp ; }

    ($sec,$min,$hour,$day,$month,$year) = localtime (time) ;
    ($year,$month,$day) = &ShiftDays ($year+1900, $month+1, $day, - $from_days_ago) ;
    $from_date = sprintf ("%04d/%02d/%02d",$year,$month,$day) ;

    ($sec,$min,$hour,$day,$month,$year) = localtime (time) ;
    ($year,$month,$day) = &ShiftDays ($year+1900, $month+1, $day, - $till_days_ago) ;
    $till_date = sprintf ("%04d/%02d/%02d",$year,$month,$day) ;

    my $diff_days = ($from_days_ago - $till_days_ago) + 1 ;
    print "Process following date range:\nFrom $from_days_ago till $till_days_ago days ago, which is:\nFrom '$from_date' till '$till_date' (yyyy/mm/dd) = $diff_days days\n" ;
  }
  else
  { abort "\nNo valid date range specified!\n\nSpecify first and last day to process as:\n'-d yyyymmdd[-yyyymmdd]' (yyyy/m/dd also valid)\n" .
          "(second date defaults to first)\nor\n'-d mmm[-nnn]', where mmm and nnn are days before today (mmm =< nnn), nnn defaults to mmm\n\n" ; }

  if ($options {"t"})
  {
    $test = $true ;
    print "Run in test mode: process less input\n" ;
  }

  return ($from_days_ago, $till_days_ago, $from_date, $till_date) ;
}

sub ValidateDateAndCalcDaysAgo
{
  trace ValidateDateAndCalcDaysAgo ;

  my ($desc, $date) = @_ ;

  my ($sec,$min,$hour,$day,$month,$year) ;
  ($sec,$min,$hour,$day,$month,$year) = localtime (time) ;

  my $date_today = sprintf ("%4d/%02d/%02d", $year+1900,$month+1,$day) ;
  if ($date !~ /\//)
  { $date_today =~ s/\///g ; }

  if ($date =~ m!^(20\d\d)/?(0[1-9]|1[012])/?(0[1-9]|[12][0-9]|3[01])$!)
  {
    # At this point, $1 holds the year, $2 the month and $3 the day of the date entered
    $year  = $1 ;
    $month = $2 ;
    $day   = $3 ;

    if ($day == 31 and ($month == 4 or $month == 6 or $month == 9 or $month == 11))
    { abort "$desc '$date': 31st of a month with 30 days" ; }
    elsif ($day >= 30 and $month == 2)
    { abort "$desc '$date': February 30th or 31st" ; }
    elsif ($month == 2 and $day == 29 and not ($year % 4 == 0 and ($year % 100 != 0 or $year % 400 == 0)))
    { abort "$desc '$date': February 29th outside a leap year" ; }
    else { ; } # valid date
  }
  else { abort "$date: not valid date format: use yyyymmdd or yyyy/mm/dd" ; }

  my $time_input = timelocal (0,0,0,$day, $month-1, $year-1900) ;
  ($sec,$min,$hour,$day,$month,$year) = localtime (time) ;
  my $time_today = timelocal (0,0,0,$day, $month, $year) ;

  my $days_ago = ($time_today - $time_input) / (24 * 60 * 60) ;

  if ($days_ago < 1)
  { abort "$desc '$date' should be before today which is $date_today" ; }

  if ($days_ago > 366)
  { abort "$desc '$date' should be a year or less ago (but before today: '$date_today')" ; }

  return ($days_ago) ;
}

sub SetFileNames
{
  trace SetFileNames ;

  $file_out                  = "private/DebugSquidDataOutDoNotPublish.txt" ;
  $file_out2                 = "private/DebugSquidDataOutDoNotPublish2.txt" ;
  $file_err                  = "private/DebugSquidDataErrDoNotPublish.txt" ;

  $file_ip_frequencies       = "private/SquidDataIpFrequenciesDoNotPublish.csv" ;
  $file_ip_frequencies_bz2   = "private/SquidDataIpFrequenciesDoNotPublish.csv.bz2" ;
  $file_out_referers         = "private/SquidDataReferersDoNotPublish.txt" ;
  $file_edits_saves          = "private/SquidDataEditsSavesDoNotPublish.txt" ;

  $file_csv_agents           = "public/SquidDataAgents.csv" ;
  $file_csv_banners          = "public/SquidDataBanners.csv" ;
  $file_csv_binaries         = "public/SquidDataBinaries.csv" ;
  $file_csv_clients          = "public/SquidDataClients.csv" ;
  $file_csv_clients_by_wiki  = "public/SquidDataClientsByWiki.csv" ; # request Howie
  $file_csv_countries_views  = "public/SquidDataCountriesViews.csv" ; # was SquidDataCountries2.csv
  $file_csv_countries_timed  = "public/SquidDataCountriesViewsTimed.csv" ; # was SquidDataCountriesTimed2.csv
  $file_csv_countries_saves  = "public/SquidDataCountriesSaves.csv" ;
  $file_csv_bots             = "public/SquidDataCrawlers.csv" ;
  $file_csv_extensions       = "public/SquidDataExtensions.csv" ;
  $file_csv_googlebots       = "public/SquidDataGoogleBots.csv" ;
  $file_csv_images           = "public/SquidDataImages.csv" ;
  $file_csv_indexphp         = "public/SquidDataIndexPhp.csv" ; #
  $file_csv_languages        = "public/SquidDataLanguages.csv" ;
  $file_head_tail            = "public/SquidDataLogFilesHeadTail.csv" ;
  $file_csv_methods          = "public/SquidDataMethods.csv" ;
  $file_csv_opsys            = "public/SquidDataOpSys.csv" ;
  $file_csv_origins          = "public/SquidDataOrigins.csv" ;
  $file_csv_requests         = "public/SquidDataRequests.csv" ;
  $file_csv_requests_wap     = "public/SquidDataRequestsWap.csv" ;
  $file_csv_requests_m       = "public/SquidDataRequestsM.csv" ; # .m. in url, not mobile as derived from agent
  $file_csv_scripts          = "public/SquidDataScripts.csv" ;
  $file_csv_search           = "public/SquidDataSearch.csv" ;
  $file_csv_skins            = "public/SquidDataSkins.csv" ;

  $file_seqno_per_squidhour  = "SquidDataSequenceNumbersPerSquidHour.csv" ;
  $file_seqno_all_squids     = "SquidDataSequenceNumbersAllSquids.csv" ;
  $file_head_tail            = "SquidDataLogFilesHeadTail.csv" ;
# $file_filter_fy            = "SquidDataFilterFY.txt" ;

  $path_out = "" ;
}

sub SetPathOut
{
  trace SetPathOut ; # to keep trace tidy , do this at end of routine

  my $days_ago = shift ;
  my ($path_out, $path_out_month) ;

  ($sec,$min,$hour,$day,$month,$year) = localtime ($time_start - $days_ago * 24 * 3600) ;

  $path_out = sprintf ("%04d-%02d", $year+1900, $month+1) ;

  $path_out = "$path_root/$path_out" ;
  $path_out_month = $path_out ;

  if (! -d $path_out)
  {
  # print "mkdir $path_out\n" ;
    mkdir ($path_out) || die "Unable to create directory $path_out\n" ;
  }

  $path_out .= "/" . sprintf ("%04d-%02d-%02d", $year+1900, $month+1, $day) ;
  if (! -d $path_out)
  {
  # print "mkdir $path_out\n" ;
    mkdir ($path_out)           || die "Unable to create directory $path_out\n" ;
  #  print "mkdir $path_out/private\n" ;
    mkdir ("$path_out/private") || die "Unable to create directory $path_out/private\n" ;
  # print "mkdir $path_out/public\n" ;
    mkdir ("$path_out/public" ) || die "Unable to create directory $path_out/public\n" ;
  }

  # clean up obsolete signal files
  $file_ready = "$path_out/\^Ready" ;
  unlink $file_ready ;
  $file_ready = "$path_out/\@Ready" ;
  unlink $file_ready ;

  trace "SetPathOut for $days_ago days ago => path_out = '$path_out'\n" ;
  return ($path_out, $path_out_month) ;
}

sub SetTimeRangeToProcess
{
  my $days_ago = shift ;

  my ($sec,$min,$hour,$day,$month,$year) = localtime ($time_start - $days_ago * 24 * 3600) ;
  my $date_collect_files = sprintf ("%4d-%02d-%02d", $year+1900, $month+1, $day) ;
  my $time_to_start = $date_collect_files . "T00:00:00" ;
  my ($sec,$min,$hour,$day,$month,$year) = localtime ($time_start - ($days_ago-1) * 24 * 3600) ;
  my $date_after_collect_files = sprintf ("%4d-%02d-%02d", $year+1900, $month+1, $day) ;
  my $time_to_stop  = $date_after_collect_files . "T00:00:00" ;
# my $time_to_stop = $date_collect_files . "T23:30:00" ; # Q&D fix to process last file available

  # if ($test)
  # { $time_to_stop  = $date_collect_files . "T00:30:00" ; }

  return ($date_collect_files, $time_to_start, $time_to_stop) ;
}

sub CheckProcessPhase1 # Collect IP frequencies
{
  trace CheckProcessPhase1 ;

  my ($days_ago, $path_out) = @_ ;
  my $process = $true ;

  my $file_ready = "$file_ip_frequencies_bz2" ;
  my $path_ready = "$path_out/$file_ready" ;

  if (-e $path_ready)
  {
    if ($force_phases !~ /1/)
    {
      $process = $false ;
      print "File '[path_out]$file_ready' already exists => skip phase 1 (collecting ip address counts)\n" ;
    }
    else
    { print "File '[path_out]$file_ready' already exists.\nYet force execute phase 1 (collecting ip address counts), as -f 1 has been specified\n" ; }
  }
  else
  { print "File '[path_out]/$file_ready' not found -> process phase 1\n" ; }

  return ($process) ;
}

sub CheckProcessPhase2 # collect other data

{
  trace CheckProcessPhase2 ;

  my ($days_ago, $path_out) = @_ ;
  my $process = $true ;

  my $file_ready = "#Ready" ;
  my $path_ready = "$path_out/$file_ready" ;
  if (-e $path_ready)
  {
    if ($force_phases !~ /2/)
    {
      $process = $false ;
      print "File '[path_out]/$file_ready' already exists => skip phase 2 (collecting counts other than ip counts)\n" ;
    }
    else
    { print "File '[path_out]/$file_ready' already exists.\nYet force execute phase 2 (collecting counts other than ip counts), as -f 2 has been specified\n" ; }
  }
  else
  { print "File '[path_out]/$file_ready' not found -> process phase 2\n" ; }

  return ($process) ;
}

sub InitGlobals # qqq
{
  trace InitGlobals ;

  undef $addresses_stored ;
  undef $banner_requests_ignored ;
  undef $date_prev ;
  undef $fields_too_few ;
  undef $fields_too_many ;
  undef $googlebots ;
  undef $googles ;
  undef $html_pages_found ;
  undef $lines_in_file ;
  undef $lines_processed ;
  undef $lines_this_day ;
  undef $newest_time_read ;
  undef $oldest_time_read ;
  undef $statusses_non_tcp ;
  undef $tot_mime_html ;
  undef $tot_mime_html2 ;
  undef $tot_origins_external_counted ;
  undef $tot_referers_external ;
  undef $tot_referers_internal ;
  undef $unrecognized_domains ;

  undef %google_bot_hits ;
  undef %ip_bot_no_google ;
  undef %agents_raw ;
  undef %binaries ;
  undef %bots ;
  undef %client_ip_record_cnt ;
  undef %client_ip_record_cnt_total ;
  undef %clients ;
  undef %clients_by_wiki ;
  undef %cnt_ip_ranges ;
  undef %countries ;
  undef %countries_saves ;
  undef %countries_timed ;
  undef %countries_views ;
  undef %edit_submit_filtered ;
  undef %engines ;
  undef %exts ;
  undef %google_imposters ;
  undef %googlebins ;
  undef %googlebins2 ;
  undef %grouped_clients ;
  undef %imagesizes ;
  undef %index_php ;
  undef %index_php_raw ;
  undef %ip_distribution ;
  undef %ip_frequencies ;
  undef %languages ;
  undef %languages_unrecognized ;
  undef %lines_read ;
  undef %mobile_other ;
  undef %operating_systems ;
  undef %origin_simplified ;
  undef %origins ;
  undef %origins_external ;
  undef %origins_unsimplified ;
  undef %referers_internal ;
  undef %requests ;
  undef %scripts ;
  undef %search ;
  undef %skins ;
  undef %squid_delta ;
  undef %squid_events ;
  undef %squid_seqno ;
  undef %statusses ;
  undef %unrecognized_domains ;
  undef %wikis ;
# undef @files ;
};

sub ProcessPhase1 # collect IP frequencies, needed for filtering probable bots in phase 2

{
  trace "ProcessPhase1: Collect IP frequencies" ;
  my ($days_ago, $date_collect_files, $time_to_start, $time_to_stop,  $path_out, @files) = @_ ;

  $scan_ip_frequencies = $true ;
  $scan_all_fields     = $false ;

  my $data_read = &ReadSquidLogFiles ($path_out, $time_to_start, $time_to_stop, @files) ;
  return if not $data_read ;

  &WriteOutputIpFrequencies ($path_out) ;
}

sub ProcessPhase2 # Collect other data
{
  trace "ProcessPhase2: Collect other data" ;
  my ($days_ago, $date_collect_files, $time_to_start, $time_to_stop,  $path_out, $path_out_month, @files) = @_ ;

  $scan_ip_frequencies = $false ;
  $scan_all_fields     = $true ;

  my $data_read = &ReadIpFrequencies ($path_out) ;
  return if not $data_read ;

  my $data_read = &ReadSquidLogFiles ($path_out, $time_to_start, $time_to_stop, @files) ;
  return if not $data_read ;

  &WriteOutputSquidSequenceGaps ($path_out) ;
  &WriteOutputSquidLogs ($path_out) ;
  &WriteOutputEditsSavesFile ($path_out) ;
  &WriteOutputCountriesSaves ($path_out) ;

  &WriteDiagnostics ;

  if ($job_runs_on_production_server)
  { &MoveAndCompressFiles ($path_out, $path_out_month, $date_collect_files) ; }


  if ($job_runs_on_production_server)
  {
    $cmd = "echo \"Ready in \"" . ddhhmmss (time - $time_start). " > $path_out/\#Ready" ; # use in next run to test whether this day has been completely processed
   `$cmd` ;
    $cmd = "echo \"\nReady in \"" . ddhhmmss (time - $time_start). " >> /home/ezachte/SquidCountArchiveLog.txt\n\n" ;
   `$cmd` ;
  }
}

#sub ScanSquidArchive
#{
#  trace ScanSquidArchive ;

#  $T00 = "T00:00:00" ;

#  ($time_to_start, $time_to_stop) = &GetSquidLogsToProcess ; # aborts if not all found

#  open OUT,  '>', "$path_out/$file_out" ;
#  open OUT2, '>', "$path_out/$file_out2" ;
#  open ERR,  '>', "$path_out/$file_err" ;

#  &CheckSquidLogsAlreadyProcessed ;  # aborts if this is the case

#  if ($scan_all_fields)
#  { &ReadIpFrequencies ; }

#  &ReadSquidLogFiles ;

#  if (($oldest_time_read gt $time_to_start) || ($newest_time_read lt $time_to_stop))
#  { abort ("Log does not contain full range from $time_to_start till $time_to_stop (oldest time read $oldest_time_read, newest time read $newest_time_read)\n") unless $test ; }

#  print "\ncd $path_out\n" ;
#  chdir ($path_out) ;

#  &WriteOutputSquidLogs ;

#  if ($scan_all_fields)
#  { &WriteDiagnostics ; }

#  close OUT ;
#  close OUT2 ;
#  close ERR ;

#  if ($job_runs_on_production_server && $scan_all_fields)
#  { &MoveAndCompressFiles ($path_out, $time_to_start) ; }
#}

#sub GetSquidLogsToProcess
#{
#  trace GetSquidLogsToProcess ;

#  my ($date_archived, $datestart, $datestop) ;

#  $time  = time ;
#  my ($sec,$min,$hour,$day,$month,$year) = localtime ($time) ;

#  $day_today = sprintf ("%04d-%02d-%02d",$year+1900,$month+1,$day) ;
#  print "Date today is $day_today.\n\n" ;

#  if ($job_runs_on_production_server)
#  {
#    $dir_in        = "/a/squid/archive" ;

#    if ($logdate =~ /^\d{8}$/)
#    {
#      $year  = substr ($logdate,0,4) ;
#      $month = substr ($logdate,4,2) ;
#      $day   = substr ($logdate,6,2) ;

#      $time_to_start = sprintf ("%04d-%02d-%02d$T00",$year,$month,$day) ;
#      ($year,$month,$day) = &ShiftDays ($year, $month, $day, 1) ;
#      $time_to_stop  = sprintf ("%04d-%02d-%02d$T00",$year,$month,$day) ;
#    }
#    elsif ($logdate =~ /^-\d+$/)
#    {
#      ($sec,$min,$hour,$day,$month,$year) = localtime ($time+$logdate*24*3600) ;
#      $year  += 1900 ;
#      $month += 1 ;
#      $time_to_start = sprintf ("%04d-%02d-%02d$T00",$year,$month,$day) ;
#      ($year,$month,$day) = &ShiftDays ($year, $month, $day, 1) ;
#      $time_to_stop  = sprintf ("%04d-%02d-%02d$T00",$year,$month,$day) ;
#    }
#    else
#    {
#      print "No logdate specified\n" ;
#      exit ;
#    }

#    print "-d $logdate => Process data from $time_to_start till $time_to_stop\n\n" ;
#  }
#  else # test
#  {
#  # $time_to_start = "2009-02-05T00" ;
#  # $time_to_stop  = "2009-02-05T23:59:59" ;
#  # push @files, getcwd . "/sampled-1000-oneday.txt" ;

#    $time_to_start = "2010-05-10T00" ;
#    $time_to_stop  = "2010-05-10T01" ;
#    push @files, getcwd . "/sampled-1000-log-20100510.txt" ;

#    print "Job runs in test env => Process data from $time_to_start till $time_to_stop\n\n" ;
#  }

#  $some_files_found = $false ;
#  $full_range_found = $false ;

#  ($path_out, $path_out_month) = &GetPathOut ($time_to_start) ;
#  $path_head_tail = "$path_out_month/$file_head_tail" ;

#  if ($job_runs_on_production_server)
#  {
#    # file naming scheme on server: sampled-1000.log-yyyymmdd, does not mean on that day file sampled-1000.log was archived
#    # file can contain data for days(s) before and day (days?) after yyyymmdd, see e.g. sampled-10000.log-20090802 (days 0801-0803)
#    # this is confusing so start a few days earlier and check for each day:
#    # whether a file exists and whether it's 'head' and or 'tail' time (first last record) fall within range

#    # find first and last file to process that comprise all log records within date range
#    $year  = substr ($time_to_stop,0,4) ;
#    $month = substr ($time_to_stop,5,2) ;
#    $day   = substr ($time_to_stop,8,2) ;
#    ($year,$month,$day) = &ShiftDays ($year, $month, $day, +5) ;
#    $datestop = sprintf ("%4d%02d%02d", $year, $month, $day) ;

#    $year  = substr ($time_to_start,0,4) ;
#    $month = substr ($time_to_start,5,2) ;
#    $day   = substr ($time_to_start,8,2) ;

#    ($year,$month,$day) = &ShiftDays ($year, $month, $day, -5) ;
#    $datestart = sprintf ("%4d%02d%02d", $year, $month, $day) ;

#    $date_archived = $datestart ;
#    while ($date_archived lt $datestop)
#    {
#      $date_archived = sprintf ("%4d%02d%02d", $year, $month, $day) ;
#      ($year,$month,$day) = &ShiftDays ($year, $month, $day, +1) ;

#      $file = "$dir_in/sampled-1000.log-$date_archived.gz" ;

#      if (-e $file)
#      {
#        ($timehead,$timetail) = &GetLogRange ($file, $path_head_tail) ;

#        if (($timehead lt $time_to_start) && ($timetail ge $time_to_start))
#        {
#          $some_files_found = $true ;
#          $processfiles = $true ;
#        }

#        if ($processfiles)
#        {
#          print "$file: time range $timehead - $timetail\n" ;
#          push @files, $file ;
#        }

#        if (($timehead lt $time_to_stop) && ($timetail ge $time_to_stop))
#        {
#          $full_range_found = $true ;
#          last ;
#        }
#      }
#    }
#  }

#  if ($job_runs_on_production_server)
#  {
#    if (! $some_files_found)
#    { print "Not any file containing start time. Aborting...\n\n" ; exit ; }
#    if (! $full_range_found)
#    { print "Not all files were found. Aborting...\n\n" ; exit ; }
#  }

#  print "\n" ;
#  foreach $file (sort @files)
#  { print "Process $file\n" ; }

#  return ($time_to_start, $time_to_stop) ;
#}

#sub GetPathOut
#{
#  my $time_to_start = shift ;

#  $path_out = substr ($time_to_start,0,7) ;
#  if ($job_runs_on_production_server)
#  {
#    $path_out = "$path_root/$path_out" ;
#    $path_out_month = $path_out ;
#  }

#  if (! -d $path_out)
#  {
#    mkdir ($path_out) || die "Unable to create directory $path_out\n" ;
#    print "mkdir $path_out\n" ;
#  }

#  $path_out .= "/" . substr ($time_to_start,0,10) ;
#  if (! -d $path_out)
#  {
#    mkdir ($path_out) || die "Unable to create directory $path_out\n" ;
#    print "mkdir $path_out\n" ;
#  }

#  # clean up obsolete signal files
#  $file_ready = "$path_out/\^Ready" ;
#  unlink $file_ready ;
#  $file_ready = "$path_out/\@Ready" ;
#  unlink $file_ready ;

#  return ($path_out,$path_out_month) ;
#}

#sub CheckSquidLogsAlreadyProcessed
#{
#  trace CheckSquidLogsAlreadyProcessed ;

#  if ($scan_ip_frequencies)
#  {
#    if (-e $file_ip_frequencies)
#    {
#      print "File $path_out/$file_ip_frequencies exists -> Day already processed\nExiting ...\n" ;
#      exit ;
#    }
#  }
#  elsif ($scan_squid_msg_sequence_numbers)
#  {
#    if (-e $file_sequence_numbers)
#    {
#      print "File $path_out/$file_sequence_numbers exists -> Day already processed\nExiting ...\n" ;
#      exit ;
#    }
#  }
#  else
#  {
#    if (-e $file_ready)
#    {
#      print "File $file_ready exists -> Day already processed\nExiting ...\n" ;
#      exit ;
#    }
#    else
#    { print "File $file_ready not found -> process data\n" ; }
#  }
#}

#sub ScanEditsSavesFile
#{
#  trace ScanEditsSavesFile ;

#  if ($logdate =~ /^\d{8}$/)
#  {
#    $year  = substr ($logdate,0,4) ;
#    $month = substr ($logdate,4,2) ;
#    $day   = substr ($logdate,6,2) ;
#  }
#  else
#  {
#    print "No (valid) logdate specified\n" ;
#    if ($job_runs_on_production_server)
#    { exit ; }
#    else
#    {
#      $year  = 2010 ;
#      $month = 4 ;
#      $day   = 01 ;
#    }
#  }

#  $time_to_start = sprintf ("%04d-%02d-%02d$T00",$year,$month,$day) ;
#  ($year2,$month2,$day2) = &ShiftDays ($year, $month, $day, 1) ;
#   $time_to_stop  = sprintf ("%04d-%02d-%02d$T00",$year2,$month2,$day2) ;

#  ($path_out, $path_out_month) = &GetPathOut ($time_to_start) ;

#  if ($job_runs_on_production_server)
#  { $path_out = $path_root ; }
#  else
#  {
#    push @files, getcwd . "/sampled-1000.log-20100401" ;
#  # return ;
#  }

#  $file_txt = "$path_root/" . sprintf ("%4d-%02d", $year, $month) . "/SquidDataEditsSaves" . sprintf ("%4d-%02d-%02d", $year, $month, $day) . ".txt.bz2" ;
#  $file_csv = "$path_root/" . sprintf ("%4d-%02d", $year, $month) . "/" . sprintf ("%4d-%02d-%02d", $year, $month, $day) . "/$file_csv_indexphp" ;
#  $file_csv_countries_saves = "$path_root/" . sprintf ("%4d-%02d", $year, $month) . "/" . sprintf ("%4d-%02d-%02d", $year, $month, $day) . "/$file_csv_countries_saves" ;
#  if (-e $file_txt)
#  {
#    &ReadInputEditsSavesFile   ($file_txt) ;
#    &WriteOutputEditsSavesFile ($file_csv) ;
#    &WriteOutputCountriesSaves ($file_csv_countries_saves) ;
#  }
#  else
#  { print "ScanEditsSavesFile: File $file_txt not found. Aborting...\n\n" ; exit ; }
#}

sub ShiftDays
{
  my $year  = shift ;
  my $month = shift ;
  my $day   = shift ;
  my $delta = shift ;

  my $time  = timelocal (0,0,0,$day, $month-1, $year-1900) ;
  ($sec,$min,$hour,$day,$month,$year) = localtime ($time+$delta*24*3600) ;

  return ($year+1900,$month+1,$day) ;
}

sub ExpandAbbreviation

{
  my $text = shift ;
  # reverse (more or less) abbreviations
  $text =~ s/^[\@\*]//o ;
  $text =~ s/^xx:upload/upload:&nbsp;/o;
  $text =~ s/^wb:/wikibooks:/o;
  $text =~ s/^wk:/wiktionary:/o;
  $text =~ s/^wn:/wikinews:/o;
  $text =~ s/^wp:/wikipedia:/o;
  $text =~ s/^wq:/wikiquote:/o;
  $text =~ s/^ws:/wikisource:/o;
  $text =~ s/^wv:/wikiversity:/o;
  $text =~ s/^wx:/wikispecial:/o;
  $text =~ s/^mw:/wikispecial:/o; # eg bugzilla
  $text =~ s/:!mw/:mediawiki/o;
  $text =~ s/^wm:/wikimedia:/o;
  $text =~ s/:wm$/:wikimedia/o;
  $text =~ s/^wmf:/foundation:/o;
  $text =~ s/:www$/:portal/o;
# $text =~ s/^wikispecial:(.*)$/$1:&nbsp;/o;
  return ($text) ;
}

sub ProcessSquidSequenceNumbers
{
  # input has been established for tast three months of data in WriteOutputSquidLogs
  # there for each day per squid and hour of day total event and total gap were established
  # avg gap for all squids combined (per hour and per day) was written to this csv file
  open CSV, '<', 'SquidDataSequenceNumbersAllSquids.csv' ;
  while ($line = <CSV>)
  {
    next if $line =~ /\*/o ;
    next if $line !~ /\d\d\d\d\-\d\d\-\d\d,/o ;
    chomp $line ;
    ($date,$hour,$events,$mean_gap) = split (',', $line) ;
    $yyyy = substr ($date,0,4) ;
    $mm   = substr ($date,5,2) ;
    $dd   = substr ($date,8,2) ;
    $time = timelocal (0,0,0,$dd,$mm-1,$yyyy-1900) ;
    ($ss,$nn,$hh,$day,$month,$year,$wday,$yday,$isdst) = localtime($time);
    $month ++ ;
    $weekno = int ($yday / 7) ;
    if ($weekno_start {$weekno} eq '')
    { $weekno_start {$weekno} = $date ; }
    $weekno_stop {$weekno} = $date ;
    $events {"$weekno,$hour"} += $events ;
    $totgap {"$weekno,$hour"} += $events * $mean_gap ;
    $events_allday {$weekno} += $events ;
    $totgap_allday {$weekno} += $events * $mean_gap ;

    # to establish correction factor per month igore all days when another anomaly occurred, or after problem was fixed
    # wk 23: from 6/11 till 6/16 unusually many messages got lost due to temporary slowdown of server
    #       (unwanted blocking process had been introduced by vector switch)
    # wk 26: on 6/27 and 6/28 22 hours of data were lost after incomplete manual restart of locke
    # wk 26/27: from 7/7 till 7/10 69 hours of data were lost after incomplete restart of locke after power down
    #       (week 27 does not stand out in the chart, squids got rebooted? <- counters were reset?)
    # wk 29: 7/22 Mark stopped several secondary processes on locke,
    #       around 14.00 hrs GMT message loss vanished almost entirely
    #       After that average gap became 1003, meaning only 0.3% of messages is missing.


    next if $month == 6 and (($day >= 11 and $day <= 16) or ($day >= 27 and $day <= 28)) ;
    next if $month == 7 and (($day >=  7 and $day <= 10) or ($day >= 22)) ;
    # these dates where data were missing or underreported are already skipped in WikiCountsSummarizeProjectCounts
    # and totals are already extrapolated

    $events_allmonth {$month} += $events ;
    $totgap_allmonth {$month} += $events * $mean_gap ;

    $weeks  {$weekno} ++ ;
    $months {$month} ++ ;
  }
  close CSV ;

  open CSV, '>', 'SquidDataSequenceNumbersAllSquidsOut.csv' ;

  print CSV "hour," ;
  print     "hour," ;
  foreach $weekno (sort {$a <=> $b} keys %weeks)
  {
    $start = substr ($weekno_start {$weekno},5) ;
    $start =~ s/-/\//go ;
    $start =~ s/^0//go ;
    # $stop  = substr ($weekno_stop  {$weekno},5) ;


    print CSV "wk $weekno: ($start ..)," ;
    print     "wk $weekno: ($start ..)," ;
  }
  print "\n" ;
  print CSV "\n" ;

  foreach ($hour = 0 ; $hour <= 23 ; $hour++)
  {
    print CSV "$hour," ;
    print     "$hour," ;

    $hour = sprintf ("%02d", $hour) ;
    foreach $weekno (sort {$a <=> $b} keys %weeks)
    {
      $events = $events {"$weekno,$hour"} ;
      $totgap = $totgap {"$weekno,$hour"} ;
      $mean_gap = 0 ;
      if ($events > 0)
      { $mean_gap = sprintf ("%.0f", $totgap / $events ) ; }
      print CSV "$mean_gap," ;
      print     "$mean_gap," ;
    }

    print "\n" ;
    print CSV "\n" ;
  }
  print CSV "all day," ;
  print     "all day," ;
  foreach $weekno (sort {$a <=> $b} keys %weeks)
  {
    $events = $events_allday {$weekno} ;
    $totgap = $totgap_allday {$weekno} ;
    $mean_gap = 0 ;
    if ($events > 0)
    { $mean_gap = sprintf ("%.0f", $totgap / $events ) ; }
    print CSV "$mean_gap," ;
    print     "$mean_gap," ;
  }

  # the following yields (month, avg gap)
  # 4: 1241 so assume this factor for full April: 1,000,000 / 1241 gap = x msgs, too short: y msgs = 1000 - x
  # 5: 1310
  # 6: 1328
  # 7: 1470 so assume this factor for 22.5/days for July

  print "\n\n" ;
  print CSV "\n\n" ;
  foreach $month (sort {$a <=> $b} keys %months)
  {
    print CSV "month $month," ;
    print     "month $month," ;
    $events = $events_allmonth {$month} ;
    $totgap = $totgap_allmonth {$month} ;
    $mean_gap = 0 ;
    if ($events > 0)
    { $mean_gap = sprintf ("%.0f", $totgap / $events ) ; }
    print CSV "$mean_gap\n" ;
    print     "$mean_gap\n" ;
  }

  close CSV ;
}


# how to detect page saves:
# henbane /a/log/vu.awk: (see also Domasz' webstats collector)
#
# function savemark(url, code) {
#         if (url ~ /action=submit$/ && code == "TCP_MISS/302")
#                 return "save"
#         return "-"
# }

# http://svn.wikimedia.org/viewvc/mediawiki/trunk/tools/counter/
# http://leuksman.com/log/2007/06/07/wikimedia-page-views/
# http://www.iplists.com/
# WHOIS http://ws.arin.net/whois/?queryinput=N%20.%20GOOGLE
# WHOIS http://tools.whois.net/index.php?fuseaction=whois.whoisbyipresults
# http://en.wikipedia.org/wiki/List_of_search_engines

# http://en.wikipedia.org/wiki/User_agent
# http://www.texsoft.it/index.php?c=software&m=sw.php.useragent&l=it
# http://www.hyperborea.org/journal/archives/2004/06/19/whats-in-a-user-agent-string/

# Funwebproducts
# No fun with funwebproducts http://www.networkworld.com/newsletters/web/2003/1208web2.html

# SLCC
# Nice and easy. SLCC1 stands for Secure Licensing Commerce Client version 1.0. SLCC is the service responsible for the Windows Anytime upgrade process present in Vista and Server 2008 which allows you to upgrade Vista Home Basic to Vista Ultimate Edition, or Server 2008 Standard to Server 2008 Enterprise ad-hoc.
# SLCC is present in the browser identifier tag, the User Agent, in order to allow Microsoft update servers to offer you the tantalising and irresistible promise of an even more resource heavy version of Vista!
# J2ME
# Java 2 Micro Edition

# Chrome Safari
# http://www.neowin.net/news/main/09/02/01/chrome-masks-as-safari-to-fool-windows-live-mail

# Danger Hiptop
# http://en.wikipedia.org/wiki/Danger_Hiptop

