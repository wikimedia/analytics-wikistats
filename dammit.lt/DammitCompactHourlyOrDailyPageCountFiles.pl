#!/usr/local/bin/perl

# Introduction:
# This script merges and encodes content from hourly unsampled page view files, generated with Domas Mituzas' udp2log script
# Input files were located for many years on dammit.lt/wikistats (hence 'Dammit' in the script name), now on http://dumps.wikimedia.org/other/pagecounts-raw/
# Two key objectives:
# 1) greatly reduce overall file size, which makes it much easier to download all data for a month, but also to upload it 3rd party archives
# 2) preserve hourly granularity of original files
# Reduction is mostly achieved by merging 24 hourly files into one 1 daily file, then later up to 31 daily files into 1 monthly file
# In this consolidated file every article title occurs only once, instead of up to 744 times -> major space saver
# Preservation of granularity is achieved by having all hourly counts in one record, in a very condensed format
# Instead of up to 744 csv values per article for each hour of the month (most would be ',0' for many many articles) the counts are coded as follows:
# Each non-zero count is specified as day number converted to 'A-X' followed by hour number converted to 'A-_' followed by count (no delimiters needed)
# Further reduction follows from optionally filtering article titles with less than x (say e.g. 5) views per month, which reduces file size with another order of magnitude
# (many or even most of these titles with less than 5 views per month are actually malformed requests (either by manual typos or client script errors)

# More on data format:
#
# compression for hourly files: gzip  # temp files, choose fast compression
# compression for daily files : bzip2 # permanent files, choose strong compression

# Each line contains four fields separated by spaces
# - wiki code (subproject.project, see below)
# - article title (encoding from original hourly files is preserved to maintain proper sort sequence)
# - monthly total (possibly extrapolated from available data when hours/days in input were missing)
# - hourly counts (only for hours where indeed article requests occurred)
#
# Subproject is language code, followed by project code
# Project is b:wikibooks, k:wiktionary, n:wikinews, q:wikiquote,s:wikisource, v:wikiversity, z:wikipedia
# Note: suffix z added by compression script: project wikipedia happens to be sorted last in dammit.lt files, so add this suffix to fix sort order
#
# To keep hourly counts compact and tidy both day and hour are coded as one character each, as follows:
# Hour 0..23 shown as A..X                            convert to back number:ordinal (char) - ordinal ('A')
# Day  1..31 shown as A.._  27=[ 28=\ 29=] 30=^ 31=_  convert to back number:ordinal (char) - ordinal ('A') + 1
#
# Example output in monthly file:
# aa.b File:Wikiversity-logo.png 7 AB1,BO1,CE1,EV1,LA1,TA1,[C1
# aa.b File:Wiktionary-logo-de.png 5 CE1,CM1,EV1,TA1,^N1
# aa.b File_talk:Commons-logo.svg 9 CE3,UO3,YE3
# aa.b File_talk:Incubator-notext.svg 60 CH3,CL3,DB3,DG3,ET3,FH3,GM3,GO3,IA3,JQ3,KT3,LK3,LL3,MH3,OO3,PF3,XO3,[F3,[O3,]P3
# aa.b MediaWiki:Ipb_cant_unblock 5 BO1,JL1,XX1,[F2

# Script history:
#  4/27/2010 renamed from WikiStatsCompactDammitFiles.pl
# 11/23/2011 renamed lots of dead (commented) code
# 11/23/2011 remove lots of code to track monitor requests to special non-existing page (never used really, we have different tools to monitor squid log udp losses)
# 11/23/2011 remove code to count totals per namespace (could reappear as post processing step, was omitted on monthly aggregation anyway)
# 11/2011    rework all code into small modules

# variable naming :
# $fn_... short for 'file name'
# $fh_... short for 'file handle'
# $fs_... short for 'file status' (open vs closed, also key part of last read line)

# to do
# test $abort_on_hourly_file_missing

# Command line arguments:
# -a max age of hourly files in days (derived from yyyymmdd part of file name, not from file timestamp), or monthly files in months
# -i folder for input (for hourly files top folder which contains one folder per year, which contains one folder per month, which contains files)
# -f filter folder (receives copy of all lines for certain wikis) (deprecated)
# -d date range, specify as yyyy[mm[dd]]
# -o output folder
# -t test run, just print which files were found and should be processed, do not actually process them
# -v verbose

# if both max_age (-a) and date range (-d) have been specified both criteria will have to be fulfilled, allows e.g. to (re)process only files for first three months of year
# note for monthly processing specifying both -a + -d may seem a bit over the top, -a is default for cron processing (-d may be deprecated)

  $fn_log         = "DammitCompactPageCountFiles.log" ;
  $fn_log_summary = "DammitCompactPageCountFilesSummary.log" ;

  &AttachLibraries ;
  &OnTestOnlySetDefaultArgs ;
  &SetFilterFoundationWikis ;

  $| = 1; # flush screen output

  $true  = 1 ;
  $false = 0 ;

  $verbose = $false ;

  $fs_missing = 'M' ;
  $fs_open    = 'O' ;
  $fs_closed  = 'C' ;

  $test_max_lines_output = 0 ;    # if $test_max_lines_output > 0 break after $test_max_lines_output lines output
  $test_max_language     = 'ad' ; # if $test_max_language ne '', treat input line starting with language code gt $test_max_language as end of file

  $threshold_views_per_day   = 0 ; # while merging hourly files, omit titles with less views than ..
  $threshold_views_per_month = 5 ; # while merging daily files, omit titles with less views than ..
  $abort_on_hourly_file_missing = $false ;
# $abort_on_daily_file_missing  = $false ;
  $time_start_overall = time ;

  &DetectCurrentMonth ;

  ($dir_in,$dir_out,$dir_filtered,$date_range,$max_file_age,$test_run) = &ReadAndValidateCmdLineArguments ;

  &SetFolders ;

  open $fh_log, ">>", "$work/$fn_log" ;
  print "Log file: $work/$fn_log\n" ;
  &Log ("\n\n" . '=' x 80 . "\n\n") ;

  # the main body of work
  &CompactFiles ($dir_in,$dir_out,$dir_filtered,$date_range,$max_file_age, $test_run) ;

  close $fh_log ;

  &Log ("\nReady\n") ;
  exit ;


# set defaults mainly for tests on local machine, see EzLib
sub OnTestOnlySetDefaultArgs
{
# &default_argv ("-v ''|-d 20111101|-i 'w:/# in dammit.lt/pagecounts'|-o 'w:/# in dammit.lt/pagecounts'|-f 'w:/# in dammit.lt/pagecounts/filtered'|-t") ;
#  &default_argv ("-m ''|-d 201111|-i 'w:/# in dammit.lt/pagecounts'|-o 'w:/# in dammit.lt/pagecounts'|-f 'w:/# in dammit.lt/pagecounts/filtered'|-t") ;
   &default_argv ("-m ''|-i 'w:/# in dammit.lt/pagecounts'|-o 'w:/# in dammit.lt/pagecounts'|-f 'w:/# in dammit.lt/pagecounts/filtered'") ;
}

#sub MergeFilesFullMonth
#{
#  my $dir_in  = shift ;
#  my $dir_out = shift ;
#  my $dir     = shift ;
#  my @files_this_month  = @_ ;

#  my $year  = substr ($dir,0,4) ;
#  my $month = substr ($dir,5,2) ;

#  my (@file_in_open, @file_in_found, @counts, $days_missing) ;
#  my $days_in_month = days_in_month ($year, $month) ;

#  my ($file_out2) ;

#  $lines = 0 ;

#  undef @in_day ;
#  my $time_start = time ;

#  if ($dir eq $month_run)
#  { $scope = "part" ; }
#  else
#  { $scope = "all" ; }

#  $fn_out_merged_daily = "$dir_out/pagecounts-$year-$month-$scope" ;

#  &Log ("\nMergeFilesFullMonth\nIn:  $dir_in/$dir\nOut: $dir_out/$fn_out_merged_daily\nDays expected: $days_in_month\n\nProcess...\n") ;

#  if ($job_runs_on_production_server)
#  {
#    if ((-e "$fn_out_merged_daily.7z") || (-e "$fn_out_merged_daily.bz2") || (-e "$fn_out_merged_daily.zip") || (-e "$fn_out_merged_daily.gz"))
#    {
#      &Log ("\nTarget file '$fn_out_merged_daily.[7z|bz2|zip|gz]' exists already. Skip this month.\n") ;
#      return ;
#    }
#  }

#  my $out_month_all = new IO::Compress::Bzip2 "$fn_out_merged_daily.bz2" or die "bzip2 failed for $file_out.bz2: $Bzip2Error\n";
#  my $out_month_ge5 = new IO::Compress::Bzip2 "${fn_out_merged_daily}_ge5.bz2" or die "bzip2 failed for ${fn_out_merged_daily}_ge5.bz2: $Bzip2Error\n";

#  $out_month_all->binmode() ;
#  $out_month_ge5->binmode() ;

#  for ($day = 0 ; $day < $days_in_month ; $day++)
#  { $file_in_found [$day] = $false ; }

#  $files_in_open  = 0 ;
#  $files_in_found = 0 ;
#  $total_hours_missing = 0 ;
#  $lang_prev = "" ;
#  $lines_read_this_month = 0 ;
#  @hours_missing_per_day = () ;
#  $hours_missing_coded = '' ;
#  $lines_omitted_daily = 0 ;

#  foreach $fn_in_daily (@files_this_month)
#  {
#    next if $fn_in_daily eq "" ;
#    next if $fn_in_daily !~ /\.(?:bz2|7z)/ ;

#    ($day = $fn_in_daily) =~ s/^pagecounts-\d{6}(\d+)_(?:fdt|fdt\.7z|h\.bz2)$/$1/ ;
#    $day = sprintf ("%2d", $day-1) ;

#    $fn_in_daily = "$dir_in/$year-$month/$fn_in_daily" ;
#    # print "File $fn_in_daily -> day $day\n" ;

#    &CheckHoursMissing ($year,$month,$day,$fn_in_daily) ;

#    $open_failed = $false ;
#    if ($job_runs_on_production_server)
#    {
#      if ($fn_in_daily =~ /\.bz2$/)
#      { open $fh_in_daily [$day], "-|", "bzip2 -dc \"$fn_in_daily\"" || &Abort ("MergeFilesFullMonth: Open failed for '$fn_in_daily'\n") ; }
#      else # .gz
#      { open $fh_in_daily [$day], "-|", "7z e  -so \"$fn_in_daily\"" || &Abort ("MergeFilesFullMonth: Open failed for '$fn_in_daily'\n") ; }
#    }
#    else
#    { open $fh_in_daily [$day], '<', $fn_in_daily || &Abort ("Open failed for '$fn_in_daily'\n") ; }

#    binmode $fh_in_daily [$day] ;

#    $files_in_open++ ;
#    $file_in_found [$day] = $true ;
#    $file_in_open  [$day] = $true ;
#    $files_in_found ++ ;

#    $file = $fh_in_daily [$day] ;
#    $line = <$file> ;
#    while (($line =~ /^#/) || ($line =~ /^@/))
#    { $line = <$file> ; }

#    chomp $line ;
#    if ($line =~ /^[^ ]+ [^ ]+ [^ ]+$/) # prepare for format change: space will be added between daily total and hourly counts
#    {
#      ($lang,$title,$counts) = split (' ', $line) ;
#    }
#    else
#    {
#      ($lang,$title,$total,$counts) = split (' ', $line) ;
#      $counts = "$total$counts" ;
#    }

#    $key [$day] = "$lang $title" ;
#    $counts [$day] = $counts ;
#    # print "DAY " . ($day+1) . " KEY ${key [$day]} COUNTS $counts\n" ;
#  }
#  print "\n" ;

#  $comment = "# Wikimedia article requests (aka page views) for year $year, month $month\n" ;
#  if ($threshold > 0 )
#  { $comment .= "# Count for articles with less than $threshold requests per full month are omitted\n" ; }
#  $comment .= "#\n" ;
#  $comment .= "# Each line contains four fields separated by spaces\n" ;
#  $comment .= "# - wiki code (subproject.project, see below)\n" ;
#  $comment .= "# - article title (encoding from original hourly files is preserved to maintain proper sort sequence)\n" ;
#  $comment .= "# - monthly total (possibly extrapolated from available data when hours/days in input were missing)\n" ;
#  $comment .= "# - hourly counts (only for hours where indeed article requests occurred)\n" ;
#  $comment .= "#\n" ;
#  $comment .= "# Subproject is language code, followed by project code\n" ;
#  $comment .= "# Project is b:wikibooks, k:wiktionary, n:wikinews, q:wikiquote, s:wikisource, v:wikiversity, z:wikipedia\n" ;
#  $comment .= "# Note: suffix z added by compression script: project wikipedia happens to be sorted last in dammit.lt files, so add this suffix to fix sort order\n" ;
#  $comment .= "#\n" ;
#  $comment .= "# To keep hourly counts compact and tidy both day and hour are coded as one character each, as follows:\n" ;
#  $comment .= "# Hour 0..23 shown as A..X                            convert to number: ordinal (char) - ordinal ('A')\n" ;
#  $comment .= "# Day  1..31 shown as A.._  27=[ 28=\\ 29=] 30=^ 31=_  convert to number: ordinal (char) - ordinal ('A') + 1\n" ;
#  $comment .= "#\n" ;
#  $comment .= "# Original data source: Wikimedia full (=unsampled) squid logs\n" ;
#  $comment .= "# These data have been aggregated from hourly pagecount files at http://dammit.lt/wikistats, originally produced by Domas Mituzas\n" ;
#  $comment .= "# Daily and monthly aggregator script built by Erik Zachte\n" ;
#  $comment .= "# Each day hourly files for previous day are downloaded and merged into one file per day\n" ;
#  $comment .= "# Each month daily files are merged into one file per month\n" ;
## $comment .= "# If data are missing for some hour (file missing or corrupt) a question mark (?) is shown (and for each missing hour the daily total is incremented with hourly average)\n" ;
## $comment .= "# If data are missing for some day  (file missing or corrupt) a question mark (?) is shown (and for each missing day the monthly total is incremented with daily average)\n" ;
#  $comment .= "#\n" ;

#  $out_month_all->print ($comment) ;
#  $comment .= "# This file contains only lines with monthly page request total greater/equal 5\n" ;
#  $comment .= "#\n" ;
#  $out_month_ge5->print ($comment) ;

#  if ($files_in_found < $days_in_month)
#  {
#    for ($day = 0 ; $day < $days_in_month ; $day++)
#    {
#      if (! $file_in_found [$day])
#      {
#        $days_missing .= ($day+1) . "," ;
#        $total_hours_missing += 24 ;
#        for (my $h = 0 ; $h <= 23 ; $h++)
#        { $hours_missing_coded .= chr ($day + ord ('A')) . chr ($h + ord ('A')) .',' ; }
#      }
#    }

#    $days_missing =~ s/,$// ;
#    &Log ("Merge files: year $year, month $month, only $files_in_found files found!\n\n") ;

#    if ($days_missing =~ /,/)
#    {
#      $out_month_all->print ("# No input files found for days $days_missing!\n#\n") ;
#      $out_month_ge5->print ("# No input files found for days $days_missing!\n#\n") ;
#      print           "No input files found for days $days_missing!\n\n" ;
#    }
#    else
#    {
#      $out_month_all->print ("# No input file found for day $days_missing!\n#\n") ;
#      $out_month_ge5->print ("# No input file found for day $days_missing!\n#\n") ;
#      print           "No input file found for day $days_missing!\n\n" ;
#    }
#  }
#  else
#  { &Log ("Merge files: year $year, month $month\n\n") ; }

#  if ($#hours_missing_per_day > -1)
#  {
#    $out_month_all->print (@hours_missing_per_day) ;
#    $out_month_ge5->print (@hours_missing_per_day) ;
#  }

#  if ($hours_missing_coded ne '')
#  {
#    $hours_missing_coded =~ s/,$// ;
#    $hours_missing_coded = join (',', sort {$a cmp $b} split (',', $hours_missing_coded)) ; # single hours and full days missing added out of sort order
#    $out_month_all->print ("#\n# Hours missing: $hours_missing_coded\n") ;
#    $out_month_ge5->print ("#\n# Hours missing: $hours_missing_coded\n") ;
#    print           "Hours missing: $hours_missing_coded\n\n" ;
#  }

#  $monthly_correction = 1 ;
#  if ($total_hours_missing == 0)
#  {
#    $out_month_all->print ("# Data for all hours of each day were available in input\n#\n") ;
#    $out_month_ge5->print ("# Data for all hours of each day were available in input\n#\n") ;
#    print           "Data for all hours of each day were available in input\n\n" ;
#  }
#  else
#  {
#    $monthly_correction = sprintf ("%.4f", ($days_in_month * 24) / ($days_in_month * 24 - $total_hours_missing)) ;
#    $out_month_all->print ("#\n# In this file data for $total_hours_missing hours were not encountered in input\n") ;
#    $out_month_ge5->print ("#\n# In this file data for $total_hours_missing hours were not encountered in input\n") ;
#    $out_month_all->print ("# Monthly totals per page have been extrapolated from available counts: multiplication factor = $monthly_correction\n#\n") ;
#    $out_month_ge5->print ("# Monthly totals per page have been extrapolated from available counts: multiplication factor = $monthly_correction\n#\n") ;
#    print           "In this file data for $total_hours_missing hours were not encountered in input\n" ;
#    print           "Monthly totals per page have been extrapolated from available counts: multiplication factor = $monthly_correction\n\n" ;
#  }

#  if ($threshold_requests_omitted > 0)
#  {
#    $out_month_all->print ("# For this month intermediate files (from daily aggregation of hourly files) did no longer contain lines with daily total below $threshold_requests_omitted page requests\n#\n") ;
#    $out_month_ge5->print ("# For this month intermediate files (from daily aggregation of hourly files) did no longer contain lines with daily total below $threshold_requests_omitted page requests\n#\n") ;
#    print           "# For this month intermediate files (from daily aggregation of hourly files) did no longer contain lines with daily total below $threshold_requests_omitted page requests\n#\n" ;
#  }

#  $key_low_prev = "" ;
#  while ($files_in_open > 0)
#  {
#  # last if $cycles ++ > 10000 ; # test code

#    $key_low = "\xFF\xFF";
#    for ($day = 0 ; $day < $days_in_month ; $day++)
#    {
#      if (($files_in_open == $days_in_month) || ($file_in_found [$day] && $file_in_open [$day]))
#      {
#        if ($key [$day] lt $key_low)
#        { $key_low = $key [$day] ; }
#      }
#    }

#    $counts_per_month = "" ;
#    $total_per_month  = 0 ;

#    for ($day = 0 ; $day < $days_in_month ; $day++)
#    {
#      if (! $file_in_found [$day])
#      {
#      # $counts_per_month .= chr ($day+ord('A')) . '?' ;
#      }
#      elsif (($files_in_open == $days_in_month) || $file_in_open [$day]) # slight optimization
#      {
#        if ($key [$day] eq $key_low)
#        {
#          $ch_day = chr ($day+ord('A')) ;
#          $counts_per_day = $counts [$day] ;

#          ($total_per_day = $counts_per_day) =~ s/^(\d+).*$/$1/ ;
#          $counts_per_day =~ s/^\d+// ; # remove total

#          $counts_per_day =~ s/([A-Z]\d+)/$ch_day$1,/g ; # prefix each hourly count with char that represent day
#          $counts_per_month .= $counts_per_day ;

#          $total_per_month += $total_per_day ;
#          $file = $fh_in_daily [$day] ;
#          # $line = <$file> ;

#          while ($true)
#          {
#            # if (($line = <$file>) && ($lines_read_this_month++ < 10000)) # test code
#              if ($line = <$file>)
#            {
#              next if $line =~ /^#/ ;
#              next if $line =~ /^@/ ;

#              $line =~ s/^([\w\-]+)2 /$1.y /o  ;
#              $line =~ s/^([\w\-]+) /$1.z /o  ;

#              chomp $line ;

#              if ($line =~ /^[^ ]+ [^ ]+ [^ ]+$/) # prepare for format change: space will be added between daily total and hourly counts
#              {
#                ($lang,$title,$counts) = split (' ', $line) ;
#              }
#              else
#              {
#                ($lang,$title,$total,$counts) = split (' ', $line) ;
#                $counts = "$total$counts" ;
#              }

#              $key [$day] = "$lang $title" ;
#              $counts [$day] = $counts ;

#              last ;
#            }
#            else
#            {
#              close $fh_in_daily [$day] ;

#              $files_in_open-- ;
#              $file_in_open [$day] = $false ;
#              $key [$day] = "\xFF\xFF";

#              last ;
#            }
#          }
#        }
#      }
#    }
#    if ($lines == 0)
#    { &Log ("\nlines:  project key\n") ; }

#    if (++$lines % 100000 == 0)
#    { &Log ("$lines: $key_low\n") ; }

#  # last if $lines > 10000 ; # test

#    last if $key_low eq "\xFF\xFF" ;

#    # Q&D fix for unexplained out of order error for what seems to be invalid language
#    # remember : language code without suffix gets appended by .y or .z to fix sort order
#    # ^nov.mw nov1 1 8765
#    # ^nov1.mw nov1 1 931 <--------------
#    # ^nov 10_dw_oktobre 1 11421
#    ($lang,$title) = split (' ', $key_low) ;
#    if ($lang =~ /\d/)
#    {
#      $invalid_languages {$lang}++ ;
#      &Log ("\nSkip invalid language '$lang'\n") ;
#      next ;
#    }

#    if ($key_low_prev gt $key_low)
#    {
#      for ($day = 0 ; $day < $days_in_month ; $day++)
#      { &Log ("day " . ($day+1) . ": key ${key[$day]}\n") ; }

#      &Abort ("Sequence error: '$key_low_prev' gt '$key_low'\n") ;
#    }

#    if (($key_low_prev eq $key_low)  && ($files_in_open > 0))
#    {
#      for ($day = 0 ; $day < $days_in_month ; $day++)
#      {
#         if ($file_in_open [$day])
#         { print "day " . ($day+1) . ": file open,   key ${key [$day]}\n" ; }
#         else
#         { print "day " . ($day+1) . ": file closed, key ${key [$day]}\n" ; }
#      }
#      &Abort ("Sequence error: '$key_low_prev' eq '$key_low'\n") ;
#    }

#    ($lang,$title) = split (' ', $key_low) ;

#    if (($lang ne $lang_prev) && ($lang_prev ne ""))
#    {
#      $filter_matches = $lang =~ $reg_exp_filter ;
#      if ($filter_matches)
#      { print "F $lang\n" ; }
#    }
#    $lang_prev = $lang ;

#    if (($files_in_found < $days_in_month) && ($files_in_found > 0)) # always > 0 actually
#    { $total = sprintf ("%.0f",($total / $files_in_found) * $days_in_month) ; }

#    $counts_per_month =~ s/,$// ;
#    $total_per_month = sprintf ("%.0f", $monthly_correction * $total_per_month) ;

#    $out_month_all->print ("$key_low $total_per_month $counts_per_month\n") ;
#    if ($total_per_month ge 5)
#    { $out_month_ge5->print ("$key_low $total_per_month $counts_per_month\n") ; }

#    $key_low_prev = $key_low ;
#  }

#  &Log ("File production took " . (time-$time_start) . " seconds\n\n") ;

#  &Log ("[$lines, $files_in_open] $key_low\n") ;

#  $out_month_all->close () ;
#  $out_month_ge5->close () ;

#  if ($job_runs_on_production_server)
#  {
#    foreach $file_in (@files_this_month)
#    {
#      print "unlink $dir_in/$file_in (dummy run, test only)\n" ;
#      # unlink "$dir_in/$file_in" ;
#    }
#  }

#  &Log ("Processed in " . (time-$time_start) . " seconds\n\n") ;
#}

sub CheckHoursMissing
{
  my ($year,$month,$day,$fn_in_check) = @_ ;
  my ($hour,%hours_seen,%hours_valid,$hours_seen,$hours_missing,%hours_missing) ;

  &Log ("\nCheckHoursMissing for day " . ($day+1) . "\n") ;

  if ($job_runs_on_production_server)
  {
    return if $fn_in_check !~ /\.(?:bz2|7z)/ ;

    if ($fn_in_check =~ /\.bz2$/)
    { open $fh_in_check, "-|", "bzip2 -dc \"$fn_in_check\"" || &Abort ("CheckHoursMissing: could not open '$fn_in_check'.") ; }
    else #7z
    { open $fh_in_check, "-|", "7z e -so \"$fn_in_check\""  || &Abort ("CheckHoursMissing: could not open '$fn_in_check'.") ; }
  }
  else
  { open $fh_in_check, '<', $fn_in_check || &Abort ("Open failed for '$fn_in_check'\n") ; }

  binmode $fh_in_check ;

  $lines_checked = 0 ;
  while ($line = <$fh_in_check>)
  {
    if ($line =~ /^#.*?requests per full day are omitted/)
    { ($threshold_requests_omitted = $line) =~ s/[^\d]//g ; }

    next if $line =~ /^#/ or $line =~ /^@/ ;

    last if $lines_checked ++ > 10000 ;

    chomp $line ;
    if ($line =~ /^[^ ]+ [^ ]+ [^ ]+$/) # prepare for format change: space will be added between daily total and hourly counts
    {
      ($lang,$title,$counts) = split (' ', $line) ;
    }
    else
    {
      ($lang,$title,$total,$counts) = split (' ', $line) ;
      $counts = "$total$counts" ;
    }

    undef @counts ;
    $counts =~ s/([A-X])(\d+|\?)/(push @counts,"$1$2"),""/ge ;
    foreach $fs_key_hourly (@counts)
    {
      my $hour = ord (substr ($fs_key_hourly,0,1)) - ord ('A') ;

      next if $hours_seen {$hour} > 0 ;
      $hours_seen {$hour} = $true ;
      $hours_seen ++ ;
      if ($fs_key_hourly =~ /\d/)
      { $hours_valid {$hour} ++ ; }
      else
      {
        $hours_missing {$hour} ++ ;
        $hours_missing ++ ;
        $hours_missing_coded .= chr ($day + ord ('A')) . chr ($hour + ord ('A')) .',' ;
      }
    }

    last if $hours_seen == 24 ;
  }

  close $fh_in_check ;

  for ($hour = 0 ; $hour <= 23 ; $hour++)
  {
    if (! $hours_seen {$hour})
    {
      $hours_missing {$hour} ++ ;
      $hours_missing ++ ;
      $hours_missing_coded .= chr ($day + ord ('A')) . chr ($hour + ord ('A')) .',' ;
    }
  }

  if ($lines_checked > 10000)
  { &Log ("\nDay " . ($day+1) . ": not all hours encountered after 10,000 lines !!! Seen (can be ?=missing) " . (join ',', sort {$a <=> $b}  keys %hours_seen) . "\n") ; }

  if ($hours_missing > 0)
  {
    $text_hour = $hours_missing > 1 ? 'hours' : 'hour' ;
    push @hours_missing_per_day, "# Day " . ($day+1) . ": $text_hour missing " .  (join ',', sort {$a <=> $b} keys %hours_missing) . "\n" ;
    &Log ("Day " . ($day+1) . ": $text_hour missing " .  (join ',', sort {$a <=> $b} keys %hours_missing) . "\n") ;
  }

  $total_hours_missing += $hours_missing ;
}

sub AttachLibraries
{
  # to be changed: some general routines are in EzLib, at unusual location (workaround for access rights issues)
  use lib "/home/ezachte/lib" ;
  use EzLib ;

  # on exit print names and timestamp of used libraries
  $trace_on_exit = $true ;

  # check if EzLib is recent enough on this server
  ez_lib_version (13) ;

  use CGI qw(:all);
  use URI::Escape;
  use Cwd ;

  # to be changed: some general routines are in EzLib, at unusual location (workaround for access rights issues)
  $job_runs_on_production_server = -d "/a/dammit.lt" ;

  if (! $job_runs_on_production_server)
  {
    &Log ("Test on Windows\n") ;
    use IO::Compress::Bzip2 qw(bzip2 $Bzip2Error) ;
    use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ; # install IO-Compress-Zlib
    use IO::Compress::Gzip     qw(gzip   $GzipError) ;   # install IO-Compress-Zlib
  }
}

sub ReadAndValidateCmdLineArguments
{
  my $options ;
  getopt ("adfimotv", \%options) ;

  $phase_build_monthly_file = $options {"m"} ;
  $phase_build_daily_file = ! $phase_build_monthly_file ;

  if (! defined ($options {"i"})) { &Abort ("Specify input dir: -i dirname") } ;
  if ($phase_build_daily_file)
  {
    if (! defined ($options {"o"})) { &Abort ("Specify output dir as: -o dirname") } ;
    if (! defined ($options {"f"})) { &Abort ("Specify filter dir as: -f dirname") } ;
  }

  my $max_file_age = $options {"a"} ;
  my $date_range   = $options {"d"} ;
  my $dir_in       = $options {"i"} ;
  my $dir_out      = $options {"o"} ;
  my $dir_filtered = $options {"f"} ;
  my $test_run     = $options {"t"} ;

  if (defined ($options {"v"}))
  { $verbose = $true ; }

  if (defined $test_run)
  { $test_run = $true ; }
  else
  { $test_run = $false ; }

  $dir_in       =~ s/'//g ;
  $dir_out      =~ s/'//g ;
  $dir_filtered =~ s/'//g ;

  ($today_day,$today_month,$today_year) = (gmtime(time))[3,4,5] ;
  $today_year = $today_year + 1900;
  $today_month++ ;

  if ($phase_build_daily_file)
  {
    if ($date_range ne '')
    {
      if ($date_range !~ /^\d{4}(\d{2})?(\d{2})?$/)               { &Abort ("Invalid date range, specify as: -d yyyy[mm[dd]]") } ;

      my $year  = substr ($date_range,0,4) ;
      my $month = substr ($date_range,4,2) ;
      my $day   = substr ($date_range,6,2) ;

      if (($year < 2008) || ($year > $today_year))                 { &Abort ("Invalid date range, year $year, specify as: -d yyyy[mm[dd]]") } ;
      if ($month ne '')
      {
        if (($month < 1)   || ($month > 12))                       { &Abort ("Invalid date range, month $month, specify as: -d yyyy[mm[dd]]") } ;
        if (($year == $today_year) && ($month >= $today_month))    { &Abort ("Invalid date range, month $month, specify as: -d yyyy[mm[dd]], last month allowed is previous month") } ;
        if ($day ne '')
        { if (($day < 1) || ($day >= &DaysInMonth ($year,$month))) { &Abort ("Invalid date range, days $day, specify as: -d yyyy[mm[dd]], last day allowed is previous day") } ; }
      }
    }

    if ($max_file_age eq '')
    {
      if ($date_range ne '')
      { $max_file_age = 99999 ; }
      else
      {
        $max_file_age = 30 ;
        &Log ("No maximum file age in days (-a ..) specified: default is 30\n") ;
      }
    }
    else
    {
      if ($max_file_age !~ /^\d{1,3}$/)
      { &Abort ("Specify max file age in days as: -a n (1 <= n <= 999)") } ;
      &Log ("\nMaximum file age in days (-a ..) specified: $max_file_age\n\n") ;
    }
  }
  else # $phase_build_monthly_file
  {
  # -d argument for monthly processing obsolete, remove code later
  #
  # if ($date_range ne '')
  # {
  #   if ($date_range !~ /^\d{4}\d{2}?$/)                        { &Abort ("Invalid date range, specify as: -d yyyy[mm]") } ;
  #
  #   my $year  = substr ($date_range,0,4) ;
  #   my $month = substr ($date_range,4,2) ;
  #
  #   if (($year < 2008) || ($year > $today_year))               { &Abort ("Invalid date range, year $year, specify as: -d yyyy[mm[dd]]") } ;
  #   if ($month ne '')
  #   {
  #     if (($month < 1)   || ($month > 12))                       { &Abort ("Invalid date range, month $month, specify as: -d yyyy[mm[dd]]") } ;
  #     if (($year == $today_year) && ($month >= $today_month))    { &Abort ("Invalid date range, month $month, specify as: -d yyyy[mm[dd]], last month allowed is previous month") } ;
  #   }
  # }

    if ($date_range ne '')
    {
      &Log ("\nDate range (-d) no longer valid option for phase 'build monthly file', and will be ignored. Instead specify max age in months (-a).\n\n") ;
      $date_range = '' ;
    }

    if ($max_file_age eq '')
    {
  #   if ($date_range ne '')
  #   { $max_file_age = 99 ; }
  #   else
  #   {
        $max_file_age = 12 ;
        &Log ("\nNo maximum file age in months (-a ..) specified: default is 12\n\n") ;
      }
  # }
    else
    {
      if ($max_file_age !~ /^\d{1,2}$/)
      { &Abort ("Specify max file age in months as: -a n (1 <= n <= 99)") } ;
      &Log ("\nMaximum file age in months (-a ..) specified: $max_file_age\n\n") ;
    }
  }

  return ($dir_in,$dir_out,$dir_filtered,$date_range,$max_file_age, $test_run) ;
}

sub CompactFiles
{
  my ($dir_in,$dir_out,$dir_filtered,$date_range,$max_file_age,$test_run) = @_ ;

  my $cycles = 0 ;

  # the two phases have a different flow to determine what work to do:
  # for phase 'build daily files', folders are scanned, all processable files are collected, then processed in daily chunks
  # this is because file names are not quite predictable, also some almost duplicate files occur occasionally
  # for phase 'build monthly files', a list of months to be processed is directly derived from script arguments (-a -d),
  # only then available files are scanned and processed in monthly chunks

  if ($phase_build_daily_file)
  {
    @files_to_process = &PhaseBuildDailyFile_CollectFilesToProcessForAllDays ($dir_in, $date_range, $max_file_age) ;
    @dates_to_process = &PhaseBuildDailyFile_CollectDatesToProcess (@files_to_process) ;

    foreach $date (@dates_to_process)
    {
      $cycles++ ;
      &Log ("\n" . '=' x 80 . "\n\n") ;

      @files_to_merge = &PhaseBuildDailyFile_SelectFilesToMergeForOneDay ($date, @files_to_process) ;

      if (! $test_run)
      { &PhaseBuildDailyFile_MergeFiles ($dir_in, $dir_out, $dir_filtered, $date, @files_to_merge) ; }
    }
  }
  else # $phase_build_monthly_file
  {
    @months_to_process = &PhaseBuildMonthlyFile_CollectMonthsToProcess ($dir_in, $max_file_age) ;

    foreach $month (@months_to_process)
    {
      $cycles++ ;
      &Log ("\n" . '=' x 80 . "\n\n") ;

      if (! $test_run)
      { &PhaseBuildMonthlyFile_MergeFiles ($dir_in, $dir_out, $month) ; }
    }
  }

  if ($cycles > 1)
  { &WriteJobStatsOverall ($cycles) ; }
}

sub PhaseBuildDailyFile_CollectFilesToProcessForAllDays
{
# most files have zeroes for minutes and second, but not all
# very rarely even two files are found for same hour
# therefore scan actually available files, instead of building file name from day/month/year and hour

  my ($dir_in, $date_range, $max_file_age_in_days) = @_ ;
  my (@folders, @files) ;

  &Log ("\nPhaseBuildDailyFile_CollectFilesToProcessForAllDays\n") ;
  &Log ("\nCollect file names for hourly pagecount files, for last $max_file_age_in_days days\n") ;
  &Log ("\n\nRead input files from folder:$dir_in\nWrite merged files to folder:$dir_out\nWrite filtered lines to folder:$dir_filtered\n\n") ;

  chdir ($dir_in) || &Abort ("Cannot chdir to $dir_in\n") ;
  local (*DIR);

  &Log ("Scan yearly and monthly folders and hourly files\n\n") ;
  # collect all yearly folders
  opendir (DIR, ".");
  while ($folder_yyyy = readdir (DIR))
  {
    next if $folder_yyyy !~ /^2\d\d\d$/ ;
    next if ! -d $folder_yyyy ;

    if (($date_range ne '') && ($folder_yyyy ne substr ($date_range,0,4)))
    {
      if ($verbose)
      { &Log ("Skip year $folder_yyyy, outside date range '$date_range'\n") ; }
      next ;
    }

    if ($verbose)
    { &Log ("Scan yearly folder $folder_yyyy\n") ; }
    push @folders_yyyy, $folder_yyyy ;
  }
  closedir (DIR);

  # collect all monthly subfolders per yearly folder
  foreach $folder_yyyy (sort {$a cmp $b} @folders_yyyy)
  {
    opendir (DIR, "$folder_yyyy");
    while ($folder_yyyy_mm = readdir (DIR))
    {
      next if $folder_yyyy_mm !~ /^2\d\d\d-\d\d$/ ;
      next if ! -d "$folder_yyyy/$folder_yyyy_mm" ;

      if ((length ($date_range) >= 6) && ($folder_yyyy_mm ne substr ($date_range,0,4) . '-' . substr ($date_range,4,2)))
      {
        if ($verbose)
        { &Log ("Skip month $folder_yyyy_mm, outside date range '$date_range'\n") ; }
        next ;
      }

      if ($verbose)
      { &Log ("Scan monthly folder $folder_yyyy/$folder_yyyy_mm\n") ; }
      push @folders_yyyy_mm, "$folder_yyyy/$folder_yyyy_mm" ;
    }
    closedir (DIR);
  }

  &Log ("\n") ;
  # collect all hourly files within monthly subfolder which are within date range
  foreach $folder_yyyy_mm (sort {$a cmp $b} @folders_yyyy_mm)
  {
    opendir (DIR, "$folder_yyyy_mm");
    while ($file_yyyy_mm_dd_hh = readdir (DIR))
    {
      next if $file_yyyy_mm_dd_hh !~ /pagecounts-\d{8,8}-\d{6,6}.gz$/ ;

      if ($file_yyyy_mm_dd_hh !~ /pagecounts-$date_range/)
      {
        if ($verbose)
        { &Log ("Skip $file_yyyy_mm_dd_hh, outside date range '$date_range'\n") ; }
        next ;
      }

      my $file_age_in_days = &PhaseBuildDailyFile_FileAgeInDays ($file_yyyy_mm_dd_hh) ;
      if ($file_age_in_days < 1)
      {
        if ($verbose)
        { &Log ("Skip $file_yyyy_mm_dd_hh, file less a day old\n") ; }
        next ;
      }
      if ($file_age_in_days > $max_file_age_in_days)
      {
        if ($verbose)
        { &Log ("Skip $file_yyyy_mm_dd_hh, file age in days ($file_age_in_days) exceeds specified max age ($max_file_age_in_days)\n") ; }
        next ;
      }

      &Log ("File $folder_yyyy_mm/$file_yyyy_mm_dd_hh\n") ;
      push @files, "$folder_yyyy_mm/$file_yyyy_mm_dd_hh" ;
    }
    closedir (DIR);
  }

  &Log ("\n") ;

  my $files_to_process = $#files + 1 ;
  if ($files_to_process < 1)
  { &Abort ("!! No compactable files found for last $max_file_age_in_days days. End processing.\n") ; }

  return (sort @files) ;
}

sub PhaseBuildDailyFile_FileAgeInDays
{
  my ($file_yyyy_mm_dd_hh) = @_ ;
  my $yyyy = substr ($file_yyyy_mm_dd_hh,11,4) ;
  my $mm   = substr ($file_yyyy_mm_dd_hh,15,2) ;
  my $dd   = substr ($file_yyyy_mm_dd_hh,17,2) ;
  my $days_file = sprintf ("%.0f", timegm (0,0,0,$dd, $mm-1, $yyyy-1900) / (24 * 60 * 60)) ;

  ($dd,$mm,$yyyy) = (gmtime (time)) [3,4,5] ;
  my $days_today = sprintf ("%.0f", timegm (0,0,0,$dd, $mm, $yyyy) / (24 * 60 * 60)) ;

  $file_age_in_days = $days_today - $days_file ;
# print "$file_yyyy_mm_dd_hh: $file_age_in_days days ago\n" ;
  return ($file_age_in_days) ;
}

# collect and filter dates to process
# ignore last date if valid files for that date is less than 24, because more files may be appear later
sub PhaseBuildDailyFile_CollectDatesToProcess
{
  my (@files) = @_ ;
  my (%files_per_date, @dates_found, @dates_to_process) ;

  &Log ("\nDetermine which dates to process from collected files\n") ;

  foreach $file (@files)
  {
    $file =~ s/^.*\/// ;
    $date = substr ($file,11,8) ;
    $files_per_date {$date}++ ;
  }

  @dates_found = sort keys %files_per_date ;

  foreach $date (@dates_found)
  {
    &Log ("\nDate $date: " . $files_per_date {$date} . " hourly input files\n") ;
    my $year  = substr ($date,0,4) ;
    my $month = substr ($date,4,2) ;
    my $day   = substr ($date,6,2) ;

    $file_to_build =  sprintf ("pagecounts-%04d-%02d-%02d.gz", $year, $month, $day) ;
    $path_to_build =  "$dir_out/" . sprintf ("%04d/%04d-%02d/%s", $year, $year, $month, $file_to_build) ;

    if (-e $path_to_build)
    { &Log ("File $file_to_build already exists. Skip date.\n") ; }
    else
    {
      &Log ("File $file_to_build not found. Store date $date.\n") ;
      push @dates_to_process, $date ;
    }
  }

  my $dates_to_process = $#dates_to_process + 1 ;
  if ($dates_to_process < 1)
  { &Abort ("\n!! No dates found for which files need to be compacted. End processing.\n") ; }

  $last_date = $dates_to_process {$#dates} ;
  if ($files_per_date {$last_date} < 24)
  {
    &Log ("\nLess than 24 hourly files available for last date ($last_date) -> skip this date, more files may appear later\n") ;
    pop @dates_to_process ;
  }

  return (@dates_to_process) ;
}

sub PhaseBuildDailyFile_SelectFilesToMergeForOneDay
{
  my ($date, @files) = @_ ;

  &Log ("Merge hourly files for date " . &FormatDate ($date) . "\n\n") ;

  my (@files_found, @files_to_merge)  ;

  foreach $file (@files)
  {
    next if $file !~ /pagecounts-$date-\d{6,6}.gz$/ ;

    push @files_found, $file ;
  }

  # very few times (nearly) duplicate files are found for same hour
  # keep the largest and presumably most complete one
  for ($i = 0 ; $i < $#files_found ; $i++)
  {
    for ($j = $i+1 ; $j <= $#files_found ; $j++)
    {
      if (substr ($files_found [$i],0,38) eq substr ($files_found [$j],0,38))
      {
        $size_i = -s $files_found [$i] ;
        $size_j = -s $files_found [$j] ;
        &Log ("\nTwo input files for same hour found:\n") ;
        &Log ("${files_found [$i]}: $size_i\n") ;
        &Log ("${files_found [$j]}: $size_j\n") ;
        if ($size_i > $size_j)
        {
          &Log ("Keep ${files_found [$i]}\n\n") ;
          $files_found [$j]= "" ;
        }
        else
        {
          &Log ("Keep ${files_found [$j]}\n\n") ;
          $files_found [$i]= "" ;
        }
      }
    }
  }

  foreach $file (@files_found)
  {
    if ($file ne '')
    { push @files_to_merge, $file ; }
  }

  &Log ("Merge " . ($#files_to_merge + 1) . " files:\n" . join ("\n", @files_to_merge) . "\n") ;
  return (@files_to_merge) ;
}

sub PhaseBuildDailyFile_MergeFiles
{
  my ($dir_in, $dir_out, $dir_filtered, $date, @files) = @_ ;

  my ($fn_out_merged_hourly, $fh_out_merged_hourly, $files_in_found_hourly, $files_in_open_hourly, $hours_missing, $lang_prev) ;

  my $year  = substr ($date,0,4) ;
  my $month = substr ($date,4,2) ;
  my $day   = substr ($date,6,2) ;  $dir_out = "$dir_out/$year" ;

  &MakeOutputDir ($dir_out) ;

  $dir_out = "$dir_out/${year}-${month}" ;
  &MakeOutputDir ($dir_out) ;

  $time_start_cycle = time ;
  $lines = 0 ;

  undef @fh_in_hourly ;
  undef %totals_in ;
  undef %totals_out ;
  undef @fs_key_hourly ;
  undef @fs_open_hourly ;
  undef @invalid_languages ;
  $hours_missing = '' ;

  ($fn_out_merged_hourly, $fh_out_merged_hourly, $fh_out_filtered, $process_day) = &PhaseBuildDailyFile_OpenOutputFiles ($dir_out, $date) ;
  return if ! $process_day ;

  ($files_in_found_hourly, $msg_files_found_hourly) = &PhaseBuildDailyFile_OpenInputFiles ($date, @files) ;
  $files_in_open_hourly = $files_in_found_hourly ;

  my $header = &PhaseBuildDailyFile_CreateHeaderDailyFile ($date, $threshold_views_per_day, $msg_files_found_hourly) ;
  print $fh_out_merged_hourly $header ;

  $key_low_prev = "" ;
  while ($files_in_open_hourly > 0)
  {
    # find lowest key among all open files
    $key_low = "\xFF\xFF";
    for ($hour = 0 ; $hour < 24 ; $hour++)
    {
      if (($files_in_open_hourly == 24) || ($fs_open_hourly [$hour] eq $fs_open))
      {
        if ($fs_key_hourly [$hour] lt $key_low)
        { $key_low = $fs_key_hourly [$hour] ; }
      }
    }

    # debug
    # if (($key_low =~ /^nov/) || ($key_low_prev =~ /^nov/))
    # { &Log ("key_low '$key_low' (key_low_prev '$key_low_prev')\n") ; }

    $counts = "" ;
    $total  = 0 ;
    for ($hour = 0 ; $hour < 24 ; $hour++)
    {
      if ($fs_open_hourly [$hour] eq $fs_missing)
      { $counts .= chr ($hour+ord('A')) . '?' ; }
      elsif ($fs_open_hourly [$hour] eq $fs_open)
      {
        # for all files where this lowest key is present, updated encoded counts and numeric total, and read new line
        if ($fs_key_hourly [$hour] eq $key_low)
        {
          $counts .= chr ($hour+ord('A')) . $count [$hour] ;
          $total += $count [$hour] ;

          $file = $fh_in_hourly [$hour] ;
          $line = <$file> ;

          $line =~ s/^([\w\-]+)2 /$1.y /o  ; # project wikipedia comes without suffix -> out of sort order, make it fit by appending suffix
          $line =~ s/^([\w\-]+) /$1.z /o  ;
         ($lang,$title,$count,$dummy) = split (' ', $line) ;

          # during tests fake end of file early on, after some language project has been fully processed
          if ($line && (($test_max_language eq '') || ($lang le $test_max_language)))
          {
            $fs_key_hourly [$hour] = "$lang $title" ;
            $count [$hour] = $count ;

            $totals_in {$lang} += $count ;
          }
          else
          {
            if ($job_runs_on_production_server)
            { close $fh_in_hourly [$hour] ; }
            else
            { $fh_in_hourly [$hour] -> close () ; }

            $files_in_open_hourly-- ;
            $fs_open_hourly [$hour] = $fs_closed ;
            $fs_key_hourly  [$hour] = "\xFF\xFF";
          }
        }
      }
    }
    if ($lines == 0)
    { &Log ("\nLines   Project Article\n") ; }

    if (++$lines % 100000 == 0)
    { &Log ("$lines: $key_low\n") ; }

    last if $test_max_lines_output > 0 and $lines > $test_max_lines_output ;

    last if $key_low eq "\xFF\xFF" ;

  # next if &InvalidLanguage ($key_low) ;

    &CheckForSequenceError ($key_low_prev, $key_low, $files_in_open_hourly) ;

    $filter_matches = &PhaseBuildDailyFile_WriteCounts ($fh_out_merged_hourly, $fh_out_filtered, $total, $counts, $files_in_found_hourly, $key_low, $lang_prev, $filter_matches) ;

    $key_low_prev = $key_low ;
    $lang_prev = $lang ;
  }

  # debug
  &Log ("\nLines written: $lines, files open after merge: $files_in_open_hourly, first key not written: " . substr ($key_low,0,20) . " [etc]\n") ;

  &PhaseBuildDailyFile_CloseOutputFiles ($fn_out_merged_hourly, $fh_out_merged_hourly, $fh_out_filtered) ;
}

sub MakeOutputDir
{
  my ($dir_out) = @_ ;

  if (! -d $dir_out)
  {
    mkdir $dir_out ;
    if (! -d $dir_out)
    { &Abort ("Output dir could not be created: $dir_out") } ;
  }
}

sub PhaseBuildDailyFile_OpenOutputFiles
{
  my ($dir_out, $date) = @_ ;
  my ($fh_out_merged_hourly, $fh_out_filtered, $process_day) ;

  &Log ("\nOpen Output Files\n\n") ;

  my $year  = substr ($date,0,4) ;
  my $month = substr ($date,4,2) ;
  my $day   = substr ($date,6,2) ;

  $process_day = $true ;

  $fn_out_merged_hourly = "$dir_out/pagecounts-$year-$month-$day" . ".~" ; # full day, hourly data, count above $threshold_views_per_day
  &Log ("Write merged hourly files to\n$fn_out_merged_hourly\n") ;

  if ($job_runs_on_production_server)
  {
  # if ((-e "$fn_out_merged_hourly.7z") || (-e "$fn_out_merged_hourly.bz2") || (-e "$fn_out_merged_hourly.zip") || (-e "$fn_out_merged_hourly.gz"))
  # {
  #   &Log ("\nTarget file '$fn_out_merged_hourly.[7z|bz2|zip|gz]' exists already. Skip this date.\n") ;
  #   return ('', '', ! $process_day) ;
  # }

    open $fh_out_merged_hourly, '>', "$fn_out_merged_hourly" || &Abort ("Output file '$fn_out_merged_hourly' could not be opened.") ;
    binmode $fh_out_merged_hourly ;
  }
  else
  {
    $fh_out_merged_hourly = IO::Compress::Gzip->new ($fn_out_merged_hourly) || &Abort ("IO::Compress::Gzip failed: $GzipError\n") ;
    binmode $fh_out_merged_hourly ;
  }

  $fn_out_filtered = "$dir_filtered/pagecounts-$year-$month-$day.txt" ;
  &Log ("\nWrite filtered counts to\n$fn_out_filtered\n") ;

  open $fh_out_filtered, '>', $fn_out_filtered ;
  binmode $fh_out_filtered ;

  return ($fn_out_merged_hourly, $fh_out_merged_hourly, $fh_out_filtered, $process_day) ;
}

sub PhaseBuildDailyFile_CloseOutputFiles
{
  ($fn_out_merged_hourly, $fh_out_merged_hourly, $fh_out_filtered) = @_ ;

  &Log ("\nClose Output Files\n\n") ;

  if ($job_runs_on_production_server)
  {
    close $fh_out_merged_hourly ;
    close $fh_out_filtered ;

#    $time_start_compression = time ;
#    $cmd = "bzip2 -9 -v $fn_out_merged_hourly" ;
#    &Log ("\n\n$cmd ->\n") ;
#    $result = `$cmd` ;
#    &Log ("\n\nCompression took " . (time-$time_start_compression) . " seconds\n$result\n") ;

#    if ($true)
#    {
#      foreach $file_in (@files_today)
#      {
#        &Log ("unlink $dir_in/$file_in\n") ;
#        unlink "$dir_in/$file_in" ;
#      }
#    }
#    else
#    {
#      # &log ("Delete $fn_out_merged_hourly.7z\n") ;
#      # unlink "$fn_out_merged_hourly.7z" ;
#    }
  }
  else
  {
    $fh_out_merged_hourly->close() ;
    close $fh_out_filtered ;
  }

  if (! &OutputMatchesInput)
  {
    &Log ("!! Output does not match input !! ->\nKeep temp file $fn_out_merged_hourly\nDo not rename, just proceed to next day\n")  ;
    return ;
  }

  ($fn_out_merged_hourly_final = $fn_out_merged_hourly) =~ s/\~$// ;
  rename ($fn_out_merged_hourly, $fn_out_merged_hourly_final) ;
  $total_bytes_produced_per_cycle = -s $fn_out_merged_hourly_final ;
  &Log ("File complete: $fn_out_merged_hourly_final (size $total_bytes_produced_per_cycle bytes)\n") ;

  &WriteJobStatsPerCycle ($fn_out_merged_hourly) ;
}


sub PhaseBuildDailyFile_OpenInputFiles
{
  my ($date,@files) = @_ ;

  $total_files_processed_per_cycle = 0 ;
  $total_bytes_processed_per_cycle = 0 ;
  $total_bytes_produced_per_cycle  = 0 ;

  my ($files_in_found, $msg_files_found) ;

  &Log ("\nOpen Input Files\n\n") ;

  my $hour ;
  for ($hour = 0 ; $hour < 24 ; $hour++)
  { $fs_open_hourly [$hour] = $fs_missing ; }


  foreach $file_in (@files)
  {
    next if $file_in eq "" ;

    ($hour = $file_in) =~ s/^.*?pagecounts-\d+-(\d\d)\d+\.gz$/$1/ ;
    $hour += 0 ; # force numeric
    &Log ("File found '$file_in'\n") ;

    if ($job_runs_on_production_server)
    { open $fh_in_hourly [$hour], "-|", "gzip -dc \"$file_in\"" || &Abort ("Input file '" . $file_in . "' could not be opened.") ; }
    else
    { $fh_in_hourly [$hour] = IO::Uncompress::Gunzip->new ($file_in) || &Abort ("IO::Uncompress::Gunzip failed for '$file_in': $GunzipError\n") ; }

    $total_files_processed_per_cycle ++ ;
    $total_bytes_processed_per_cycle += -s $file_in ;
    $total_files_processed_overall ++ ;
    $total_bytes_processed_overall += -s $file_in ;

    binmode $fh_in_hourly [$hour] ;

    $files_in_found ++ ;

    $fs_open_hourly [$hour] = $fs_open ;

    $file = $fh_in_hourly [$hour] ;
    $line = <$file> ;
    while ($line !~ /^[0-9a-zA-Z]/)
    {
      chomp $line ;
      &Log ("Skip malformed line '" . substr ($line, 0, 20) . "' [etc]\n") ;
      $line = <$file> ;
    }

    $line =~ s/^(\w+)2 /$1.y /o  ;# project wikipedia comes without suffix -> out of sort order, make it fit by appending suffix
    $line =~ s/^(\w+) /$1.z /o  ;

    ($lang,$title,$count,$dummy) = split (' ', $line) ;

    $fs_key_hourly [$hour] = "$lang $title" ;
    $count [$hour] = $count ;
    $totals_in {$lang} += $count ;
  }

  if ($files_in_found < 24)
  {
    for ($hour = 0 ; $hour < 24 ; $hour++)
    {
      if ($fs_open_hourly [$hour] eq $fs_missing)
      { $hours_missing .= "$hour, " ; }
    }
    $hours_missing =~ s/, $// ;
    &Log ("\n!! Only $files_in_found files found!!\n\n") ;
  }

  if ($hours_missing ne '')
  { $msg_files_found = "# In this file data are missing for hour(s): $hours_missing !\n#\n" ; }

  return ($files_in_found+0, $msg_files_found.'') ; # force numeric, alpha

}

sub PhaseBuildDailyFile_CreateHeaderDailyFile
{
  my ($date, $threshold, $msg_files_found) = @_ ;
  $date = substr ($date,6,2) . '/' . substr ($date,4,2) . '/' . substr ($date,0,4) . " (dd/mm/yyyy) " ;
  if ($threshold > 0 )
  { $header_threshold = "\n# Count for articles with less than $threshold requests per full day are omitted" ; }

  my $header = <<__HeaderDailyFile__ ;
# Wikimedia page request counts for $date
#
# Each line shows 'project page daily-total hourly-counts'$header_threshold
#
# Project is 'language-code project-code'
#
# Project-code is
#
# b:wikibooks,
# k:wiktionary,
# n:wikinews,
# q:wikiquote,
# s:wikisource,
# v:wikiversity,
# z:wikipedia (z added by compaction script: wikipedia happens to be sorted last in dammit.lt files, but without suffix)
#
# Counts format: only hours with page view count > 0 (or data missing) are represented,
#
# Hour 0..23 shown as A..X (saves up to 22 bytes per line compared to comma separated values), followed by view count.
# If data are missing for some hour (file missing or corrupt) a question mark (?) is shown,
# and a adjusted daily total is extrapolated as follows: for each missing hour the total is incremented with hourly average
#
# Page titles are shown unmodified (preserves sort sequence)
#
__HeaderDailyFile__

$header .= $msg_files_found ;

  return ($header) ;
}

sub PhaseBuildDailyFile_WriteCounts
{
  my ($fh_out_merged_hourly, $fh_out_filtered, $total, $counts, $files_in_found_hourly, $key_low, $lang_prev, $filter_matches) = @_ ;

# test only: introduce mismatch between totals read and totals written -> produces error and temp file stays
# return if $total % 23 != 0 ;

  ($lang,$title) = split (' ', $key_low) ;

# $title =~ s/\%20/_/g ;
# $title =~ s/\%3A/:/gi ;
# $title =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/seg;

  $totals_out {$lang} += $total ;

  if (($files_in_found_hourly < 24) && ($files_in_found_hourly > 0)) # always > 0 actually
  { $total = sprintf ("%.0f",($total / $files_in_found_hourly) * 24) ; }

  if (($lang ne $lang_prev) && ($lang_prev ne ""))
  {
    $filter_matches = $lang =~ $reg_exp_filter ;
    if ($filter_matches)
    { &Log ("F $lang\n") ; }
    # else
    # { &Log ("- $lang\n") ; }
  }

  if ($filter_matches)
  { print $fh_out_filtered "$key_low $total $counts\n" ; }

  if ($total >= $threshold_views_per_day)
  { print $fh_out_merged_hourly "$key_low $total $counts\n" ; }

  return ($filter_matches) ;
}

# if both max_age (-a) and date range (-d) have been specified both criteria will have to be fulfilled, allows e.g. to (re)process only files for first three months of year
# note for monthly processing specifying both -a + -d may seem a bit over the top, -a is default for cron processing (-d may be deprecated)

sub PhaseBuildMonthlyFile_CollectMonthsToProcess
{
  my ($dir_in, $max_file_age_in_months) = @_ ;
  my @months_to_process ;

  &Log ("\nPhaseBuildDailyFile_CollectMonthsToProcess\n") ;

  if ($verbose)
  {
    &Log ("\nList last $max_file_age_in_months months (-a ..) before current month,") ;
    if ($date_range ne '')
    { &Log (" filtered by date range '$date_range' (-d ..),") ; }
    &Log (" for which no consolidated monthly file exists yet.\n") ;
  }

  &Log ("\n\nRead input files from folder: $dir_in\n\n") ;

  $year  = $today_year ;
  $month = $today_month ;

  $check_month_complete = $true ;

  while ($max_file_age_in_months-- > 0)
  {
    $month-- ;
    if ($month == 0)
    { $month = 12 ; $year-- ; }

    $month = sprintf ("%02d", $month) ;

  # -d argument for monthly processing obsolete, remove code later
  #
  # $yyyymm = sprintf ("%04d%02d",$year,$month) ;
  #
  # if (($date_range ne '') && ($yyyymm !~ /$date_range/))
  # {
  #   if ($verbose)
  #   { &Log ("Skip year/month $yyyymm, outside date range '$date_range'\n") ; }
  #   next ;
  # }

    $dn_in_monthly = "$dir_in/$year/$year-$month/" ;

    if (! -d $dn_in_monthly)
    {
      if ($verbose)
      { &Log ("Skip month $year-$month, input folder not found: $dn_in_monthly\n") ; }
      next ;
    }

    # only for previous month (newest to be processed) check if all input is available
    # only continue when input for last of month is available, if not skip month
    # if input file will never appear (maybe longer server outage, no input data)
    # either use force option (to be implemented) or add 0 byte file
    if ($check_month_complete)
    {
      $day = sprintf ("%02d", &DaysInMonth ($year, $month)) ;
      $fn_in_daily = "$dir_in/$year/$year-$month/pagecounts-$year-$month-$day.gz" ;

      if (! -e $fn_in_daily)
      {
        &Log ("File missing: $fn_in_daily\n") ;
        &Log ("Skip month $year-$month, input for last day of this month not yet found\n") ;
        &Log ("1) Data feed from hourly log files has stalled?\n") ;
        &Log ("2) Daily consolidation of hourly files still needs to run? (phase 1 of this script)\n") ;
        next ;
      }
    }

    $fn_out_monthly = "$dir_out/pagecounts-$year-$month.bz2" ;

    if (-e $fn_out_monthly)
    {
      if ($verbose)
      { &Log ("Skip month $year-$month, output file already exists: $fn_out_monthly\n") ; }
      next ;
    }

    $files_missing = 0 ;
    for ($day = 1 ; $day <= &DaysInMonth ($year, $month) ; $day++)
    {
      $day = sprintf ("%02d", $day) ;
      $fn_in_daily = "$dir_in/$year/$year-$month/pagecounts-$year-$month-$day.gz" ;
      if (! -e $fn_in_daily)
      {
        $files_missing++ ;
        &Log ("Input file not found: $fn_in_daily\n") ;
      }
    }

    if ($files_missing > 10)
    {
      &Log ("Skip month $year-$month, too many files ($files_missing) are missing.\n") ;
      next ;
    }
    elsif ($files_missing > 0)
    {
      $s = ($files_missing > 1) ? 's' : '' ;
      &Log ("$files_missing file$s missing -> monthly counts will be recalculated/adjusted for missing day$s.\n") ;
    }

    &Log ("List month $year-$month\n\n") ;
    push @months_to_process, "$year-$month" ;

    $check_month_complete = $false ;
  }

  my $months_to_process = $#months_to_process + 1 ;
  if ($months_to_process < 1)
  { &Abort ("\n!! No months found for which files need to be compacted. End processing.\n") ; }

  # keep list sorted backwards -> process newest month first
  return @months_to_process ;
}

#qqq
sub PhaseBuildMonthlyFile_MergeFiles
{
  my ($dir_in, $dir_out, $year_month) = @_ ;

  my ($fn_out_merged_daily, $fh_out_merged_daily, $files_in_found_daily, $files_in_open_daily, $days_missing, $lang_prev) ;

  my $year  = substr ($year_month,0,4) ;
  my $month = substr ($year_month,5,2) ;

  &MakeOutputDir ($dir_out) ;

  $time_start_cycle = time ;
  $lines = 0 ;

  my $days_in_month = &DaysInMonth ($year,$month) ;

  undef @fh_in_daily ;
  undef %totals_in ;
  undef %totals_out ;
  undef @counts_daily ;
  undef @total_daily ;
  undef @fs_key_daily ;
  undef @fs_open_daily ;
  undef @invalid_languages ;
  $days_missing = '' ;

  ($fn_out_merged_daily, $fh_out_merged_daily, $process_day) = &PhaseBuildMonthlyFile_OpenOutputFile ($dir_out, $year_month) ;
  return if ! $process_day ;

  ($files_in_found_daily, $msg_files_found_daily) = &PhaseBuildMonthlyFile_OpenInputFiles ($year_month) ;
  $files_in_open_daily = $files_in_found_daily ;

  my $header = &PhaseBuildMonthlyFile_CreateHeaderMonthlyFile ($year_month, $threshold_views_per_month, $msg_files_found_daily) ;
  print $fh_out_merged_daily $header ;

  $key_low_prev = "" ;
  while ($files_in_open_daily > 0)
  {
    # find lowest key among all open files
    $key_low = "\xFF\xFF";
    for ($day = 1 ; $day <= $days_in_month ; $day++)
    {
      if (($files_in_open_daily == $days_in_month) || ($fs_open_daily [$day] eq $fs_open))
      {
        if ($fs_key_daily [$day] lt $key_low)
        { $key_low = $fs_key_daily [$day] ; }
      }
    }

    $counts_monthly = "" ;
    $total_monthly  = 0 ;
    for ($day = 1 ; $day <= $days_in_month ; $day++)
    {
# print "day $day fs_open_daily " . $fs_open_daily [$day] . "\n" ;
      if ($fs_open_daily [$day] eq $fs_missing)
      {
      # for ($hour = 0 ; $hour < 24 ; $hour++)
      # { $counts_monthly .= chr ($day+ord('A')-1) . chr ($hour+ord('A')) . '?' ; }
        $counts_monthly .= chr ($day+ord('A')-1) . '*?,' ;
# print "day $day $counts_monthly\n" ;
      }
      elsif ($fs_open_daily [$day] eq $fs_open)
      {
        # for all files where this lowest key is present, updated encoded counts and numeric total, and read new line
        if ($fs_key_daily [$day] eq $key_low)
        {
          $counts_monthly .= chr ($day+ord('A')-1) . $counts_daily [$day] . ',' ;
          $total_monthly += $total_daily [$day] ;

          $fh = $fh_in_daily [$day] ;
          $line = <$fh> ;

        # patch already done in phase 1:
        # $line =~ s/^([\w\-]+)2 /$1.y /o  ; # project wikipedia comes without suffix -> out of sort order, make it fit by appending suffix
        # $line =~ s/^([\w\-]+) /$1.z /o  ;

        chomp $line ;
         ($lang,$title,$total_daily,$counts_daily) = split (' ', $line) ;

          # during tests fake end of file early on, after some language project has been fully processed
          if ($line && (($test_max_language eq '') || ($lang le $test_max_language)))
          {
            $fs_key_daily [$day] = "$lang $title" ;
            $counts_daily [$day] = $counts_daily ;
            $total_daily  [$day] = $total_daily ;
            $totals_in {$lang}  += $total_daily ;
          }
          else
          {
            if ($job_runs_on_production_server)
            { close $fh_in_daily [$day] ; }
            else
            { $fh_in_daily [$day] -> close () ; }

            $files_in_open_daily-- ;
            $fs_open_daily [$day] = $fs_closed ;
            $fs_key_daily  [$day] = "\xFF\xFF";
          }
        }
      }
# print "day $day $counts_monthly\n" ;
    }
# print "$key_low: $total_monthly $counts_monthly\n" ;
    if ($lines == 0)
    { &Log ("\nLines   Project Article\n") ; }

    if (++$lines % 100000 == 0)
    { &Log ("$lines: $key_low\n") ; }

    last if $test_max_lines_output > 0 and $lines > $test_max_lines_output ;

    last if $key_low eq "\xFF\xFF" ;

  # next if &InvalidLanguage ($key_low) ;

    $filter_matches = &PhaseBuildMonthlyFile_WriteCounts ($fh_out_merged_daily, $total_monthly, $counts_monthly, $days_in_month, $files_in_found_daily, $key_low) ;

    $key_low_prev = $key_low ;
    $lang_prev = $lang ;
  }
  &Log ("\nLines written: $lines, files open after merge: $files_in_open_daily, first key not written: " . substr ($key_low,0,20) . " [etc]\n") ;

  &PhaseBuildMonthlyFile_CloseOutputFile ($fn_out_merged_daily, $fh_out_merged_daily) ;
}

sub PhaseBuildMonthlyFile_OpenInputFiles
{
  my ($year_month) = @_ ;

  my $year  = substr ($year_month,0,4) ;
  my $month = substr ($year_month,5,2) ;

  $total_files_processed_per_cycle = 0 ;
  $total_bytes_processed_per_cycle = 0 ;
  $total_bytes_produced_per_cycle  = 0 ;

  my ($files_in_found, $msg_files_found) ;

  &Log ("\nOpen Input Files for month $year-$month\n\n") ;

  my $days_in_month = &DaysInMonth ($year,$month) ;

  my $day ;
  for ($day = 1 ; $day <= $days_in_month ; $day++)
  {
    $day = sprintf ("%02d", $day) ;
    $fs_open_daily [$day] = $fs_missing ;

    $fn_in_daily = "$dir_in/$year/$year-$month/pagecounts-$year-$month-$day.gz" ;
    if (! -e $fn_in_daily)
    {
      if ($verbose)
      { &Log ("File missing: $fn_in_daily\n") ; }
      next ;
    }

    if ($verbose)
    { &Log ("File found: $fn_in_daily\n") ; }

    if ($job_runs_on_production_server)
    { open $fh_in_daily [$day], "-|", "gzip -dc \"$fn_in_daily\"" || &Abort ("Input file '" . $fn_in_daily . "' could not be opened.") ; }
    else
    { $fh_in_daily [$day] = IO::Uncompress::Gunzip->new ($fn_in_daily) || &Abort ("IO::Uncompress::Gunzip failed for '$fn_in_daily': $GunzipError\n") ; }

    $total_files_processed_per_cycle ++ ;
    $total_bytes_processed_per_cycle += -s $fn_in_daily ;
    $total_files_processed_overall ++ ;
    $total_bytes_processed_overall += -s $fn_in_daily ;

    binmode $fh_in_daily [$day] ;

    $files_in_found ++ ;

    $fs_open_daily [$day] = $fs_open ;

    $fh = $fh_in_daily [$day] ;
    $line = <$fh> ;
    while ($line && ($line =~ /^#/))
    {
      $line = <$fh> ;
    }
    if (! $line) { &Abort ("No valid data found in $fn_in_daily") ; }

    ($lang,$title,$total_daily,$counts_daily) = split (' ', $line) ;

    $fs_key_daily [$day] = "$lang $title" ;
    $counts_daily [$day] = $counts_daily ;
    $total_daily [$day]  = $total_daily ;
    $totals_in {$lang}  += $total_daily ;
  }

  if ($files_in_found < $days_in_month)
  {
    for ($day = 1 ; $day <= $days_in_month ; $day++)
    {
      if ($fs_open_daily [$day] eq $fs_missing)
      { $days_missing .= "$day, " ; }
    }
    $days_missing =~ s/, $// ;
    &Log ("\n!! Only $files_in_found files found !!\n\n") ;
  }

  if ($days_missing ne '')
  { $msg_files_found = "# In this file data are missing for day(s): $days_missing !\n#\n" ; }

  return ($files_in_found+0, $msg_files_found.'') ; # force numeric, alpha

}

sub PhaseBuildMonthlyFile_CreateHeaderMonthlyFile
{
  my ($year_month, $threshold, $msg_files_found) = @_ ;

  if ($threshold > 0 )
  { $header_threshold = "\n# Count for articles with less than $threshold requests per full month are omitted" ; }

  my $header = <<__HeaderDailyFile__ ;
# Wikimedia page request counts for year $year month $month
#
# Each line shows 'project page monthly-total hourly-counts'
#
# Project is 'language-code project-code'
#
# Project-code is
#
# b:wikibooks,
# k:wiktionary,
# n:wikinews,
# q:wikiquote,
# s:wikisource,
# v:wikiversity,
# z:wikipedia (z added by compaction script: wikipedia happens to be sorted last in dammit.lt files, but without suffix)
#
# Counts format: only hours with page view count > 0 (or data missing) are represented,
#
# Hour 0..23 shown as A..X, followed by view count.
# Day  1..31 shown as A.._  27=[ 28=\ 29=] 30=^ 31=_  convert to number: ordinal (char) - ordinal ('A') + 1
#
# If data are missing for some hour (file missing or corrupt) a question mark (?) is shown for that hour.
# If data are missing for a whole day an asterisk + question is showing for that day,
#
# For missing hours/days an adjusted monthly total is extrapolated as follows:
# For each missing hour the daily total was incremented with hourly average (in consolidation step 1: 24 hourly files -> 1 daily file)
# For each missing day the monthly total was incremented with daily average (in consolidation step 2: 28-31 daily files -> 1 monthly file)
#
# Page titles are shown unmodified (preserves sort sequence)
#
__HeaderDailyFile__

if ($threshold_views_per_month > 0)
{ $header .= "# Articles with less than $threshold_views_per_month page views per month have been omitted\n#\n" ; }

$header .= $msg_files_found ;

  return ($header) ;
}

sub PhaseBuildMonthlyFile_WriteCounts
{
  my ($fh_out_merged_daily, $total_monthly, $counts_monthly, $days_in_month, $files_in_found_daily, $key_low) = @_ ;

# test only: introduce mismatch between totals read and totals written -> produces error and temp file stays
#  return if $total_monthly % 23 == 0 ;

  $counts_montly =~ s/,$// ;

  ($lang,$title) = split (' ', $key_low) ;

# $title =~ s/\%20/_/g ;
# $title =~ s/\%3A/:/gi ;
# $title =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/seg;

  $totals_out {$lang} += $total_monthly ;

  if (($files_in_found_daily < $days_in_month) && ($files_in_found_daily > 0)) # always > 0 actually
  { $total_monthly = sprintf ("%.0f",($total_monthly / $files_in_found_daily) * $days_in_month) ; }

  if ($total_monthly >= $threshold_views_per_month)
  { print $fh_out_merged_daily "$key_low $total_monthly $counts_monthly\n" ; }

  return ($filter_matches) ;
}

sub CheckForSequenceError
{
  my ($key_low_prev, $key_low, $files_in_open) = @_ ;

  if ($key_low_prev gt $key_low)
  {
    for ($hour = 0 ; $hour < 24 ; $hour++)
    { &Log ("hour $hour: key ${fs_key_hourly[$hour]}\n") ; }
    &Abort ("Sequence error: '$key_low_prev' gt '$key_low'\n") ;
  }

  if (($key_low_prev eq $key_low)  && ($files_in_open > 0))
  {
    for ($hour = 0 ; $hour < 24 ; $hour++)
    {
       if ($fs_open_hourly [$hour] eq $fs_open)
       { &Log ("hour $hour: file open,   key ${fs_key_hourly [$hour]}\n") ; }
       else
       { &Log ("hour $hour: file closed, key ${fs_key_hourly [$hour]}\n") ; }
    }
    &Abort ("Sequence error: '$key_low_prev' eq '$key_low'\n") ;
  }
}

sub PhaseBuildMonthlyFile_OpenOutputFile
{
  my ($dir_out, $year_month) = @_ ;
  my ($fh_out_merged_daily, $process_day) ;

  &Log ("\nOpen Output File\n\n") ;

  my $year  = substr ($year_month,0,4) ;
  my $month = substr ($year_month,5,2) ;

  $process_day = $true ;

  if ($threshold_views_per_month > 0)
  { $fn_ge_threshold = "-ge-$threshold_views_per_month" ; }

  $fn_out_merged_daily = "$dir_out/pagecounts-$year-$month$fn_ge_threshold" . ".bz2~" ; # full month, hourly data
  &Log ("Write merged daily files to\n$fn_out_merged_daily\n") ;

  if ($job_runs_on_production_server)
  {
  # if ((-e "$fn_out_merged_hourly.7z") || (-e "$fn_out_merged_hourly.bz2") || (-e "$fn_out_merged_hourly.zip") || (-e "$fn_out_merged_hourly.gz"))
  # {
  #   &Log ("\nTarget file '$fn_out_merged_hourly.[7z|bz2|zip|gz]' exists already. Skip this date.\n") ;
  #   return ('', '', ! $process_day) ;
  # }

    open $fh_out_merged_daily, '>', "$fn_out_merged_daily" || &Abort ("Output file '$fn_out_merged_daily' could not be opened.") ;
    binmode $fh_out_merged_daily ;
  }
  else
  {

  # $fh_out_merged_daily = IO::Compress::Gzip->new ($fn_out_merged_daily) || &Abort ("IO::Compress::Gzip failed: $GzipError\n") ;
    $fh_out_merged_daily = new IO::Compress::Bzip2 "$fn_out_merged_daily" or die "bzip2 failed for fn_out_merged_daily: $Bzip2Error\n";

    binmode $fh_out_merged_daily ;
  }

  return ($fn_out_merged_daily, $fh_out_merged_daily, $process_day) ;
}

sub PhaseBuildMonthlyFile_CloseOutputFile
{
  ($fn_out_merged_daily, $fh_out_merged_daily) = @_ ;

  &Log ("\nClose Output File\n\n") ;

  if ($job_runs_on_production_server)
  {
    close $fh_out_merged_daily ;

#    $time_start_compression = time ;
#    $cmd = "bzip2 -9 -v $fn_out_merged_hourly" ;
#    &Log ("\n\n$cmd ->\n") ;
#    $result = `$cmd` ;
#    &Log ("\n\nCompression took " . (time-$time_start_compression) . " seconds\n$result\n") ;

#    if ($true)
#    {
#      foreach $file_in (@files_today)
#      {
#        &Log ("unlink $dir_in/$file_in\n") ;
#        unlink "$dir_in/$file_in" ;
#      }
#    }
#    else
#    {
#      # &log ("Delete $fn_out_merged_hourly.7z\n") ;
#      # unlink "$fn_out_merged_hourly.7z" ;
#    }
  }
  else
  {
    $fh_out_merged_daily->close() ;
  }

  if (! &OutputMatchesInput)
  {
    &Log ("Ouput does not match input ->\nKeep temp file $fn_out_merged_daily 'as is'\nDo not rename and proceed to next month\n")  ;
    return ;
  }

  ($fn_out_merged_daily_final = $fn_out_merged_daily) =~ s/\~// ;
  rename ($fn_out_merged_daily, $fn_out_merged_daily_final) ;
  $total_bytes_produced_per_cycle = -s $fn_out_merged_daily_final ;
  &Log ("File complete: $fn_out_merged_daily_final (size $total_bytes_produced_per_cycle bytes)\n") ;

  &WriteJobStatsPerCycle ($fn_out_merged_daily) ;
}

sub SetFolders
{
  $work = cwd() ;
  &Log ("Work dir: '$work'\n") ;

  if ($dir_in !~ /[\/\\]/)
  { $dir_in = "$work/$dir_in" ; }

  if ($dir_out eq '')
  { $dir_out = "$work" ; }
  elsif ($dir_out !~ /[\/\\]/)
  { $dir_out = "$work/$dir_out" ; }

  if ($phase_build_monthly_file && ($dir_out eq ''))
  { $dir_out = $dir_in ; }

  if ($dir_filtered !~ /[\/\\]/)
  { $dir_filtered = "$work/$dir_filtered" ; }

  &Log ("Input folder: '$dir_in'\n") ;
  if (! -d $dir_in)
  { &Abort ("Input dir not found: $dir_in") } ;

  &MakeOutputDir ($dir_out) ;
}

sub DetectCurrentMonth
{
  ($month,$year) = (gmtime(time))[4,5] ;
  $year = $year + 1900;
  $month++ ;
  $month_run = sprintf ("%4d-%2d", $year, $month) ;
  &Log ("Current month: $month_run\n") ;
}

sub SetFilterFoundationWikis
{
  $filter = "outreach|quality|strategy|usability" ;
  &Log ("Filter: $filter\n") ;
  $filter = "^(?:$filter)\.m\$" ;
  $reg_exp_filter = qr"$filter" ;
}


sub InvalidLanguage
{
  my ($key_low) = @_ ;
  # Q&D fix for unexplained out of order error for what seems to be invalid language
  # remember : no suffix on language code gets replaced by .y or .z to fixed sort order
  # ^nov.mw nov1 1 8765
  # ^nov1.mw nov1 1 931 <--------------
  # ^nov 10_dw_oktobre 1 11421

  my ($lang,$title) = split (' ', $key_low) ;
  if ($lang =~ /\d/)
  {
    $invalid_languages {$lang}++ ;
    &Log ("\nSkip invalid language '$lang'\n") ;
    return ($true) ;
  }
  return ($false) ;
}

sub OutputMatchesInput
{
  $msg_mismatch = '' ;

  @invalid_languages = sort keys %invalid_languages ;
  if ($#invalid_languages > -1)
  {
    &Log ("\nRecords skipped for invalid languages:\n") ;
    foreach $key (@invalid_languages)
    { &Log ("$key: ${invalid_languages {$key}}\n") ; }
  }

  for $key (sort keys %totals_in)
  {
    if ($totals_in {$key} != $totals_out {$key})
    { $msg_mismatch .= "                 $key in: ${totals_in {$key}}, out: ${totals_out {$key}}\n" ; }
  }

  if ($msg_mismatch ne '')
  {
    &Log        ("\nMismatch between count read and count written:\n$msg_mismatch\n") ;
    &LogSummary ("Mismatch between count read and count written:\n$msg_mismatch") ;
    return ($false) ;
  }

  return ($true) ;
}

sub WriteJobStatsPerCycle
{
  my ($file_out) = @_ ;
  $file_out =~ s/.*\/// ;

  my $seconds = (time-$time_start_cycle) ;

  my $stats = "Stats: $total_files_processed_per_cycle files consolidated into $file_out, in $seconds sec, " .
              sprintf ("%.0f", $total_bytes_processed_per_cycle / (1024*1024)) . " Mb" .
              " -> " . sprintf ("%.0f", $total_bytes_produced_per_cycle / (1024*1024)) . " Mb" ;

  if ($total_bytes_processed_per_cycle > 0)
  {
    $perc = sprintf ("%.0f", 100 * (1 - $total_bytes_produced_per_cycle / $total_bytes_processed_per_cycle)) ;
    $stats .= " (= -$perc\%)" ;
  }

  if ($seconds > 0)
  {
    $Mb_sec = sprintf ("%.2f", ($total_bytes_processed_per_cycle / (1024*1024)) / $seconds) ;
    $stats .= ", $Mb_sec Mb/sec" ;
  }

  &Log        ("$stats\n") ;
  &LogSummary ("$stats\n") ;
}

sub WriteJobStatsOverall
{
  my ($cycles) = @_ ;

  &Log ("\n\n" . '-' x 80 . "\n\n") ;

  my $seconds = (time-$time_start_overall) ;

  my $stats = "\nOverall, in $cycles cycles:\n\n" . ($total_files_processed_overall+0) . " files processed in $seconds seconds\n\n" .
              sprintf ("%.0f", $total_bytes_processed_overall / (1024*1024)) . " Mb" ;

  if ($seconds > 0)
  {
    $Mb_sec = sprintf ("%.2f", ($total_bytes_processed_overall / (1024*1024)) / $seconds) ;
    $stats .= ", $Mb_sec Mb/sec (compressed file size)\n" ;
  }
  &Log ("$stats\n") ;
}

sub FormatDate
{
  my ($date) = @_ ;
  return (substr ($date,6,2) . '/' . substr ($date,4,2) . '/' . substr ($date,0,4) . " (dd/mm/yyyy) ") ;
}

sub DaysInMonth
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

sub Log
{
  my $msg = shift ;
  print $msg ;

  if ($fn_log != 0)
  { print $fh_log $msg ; }
}

sub LogSummary
{
  my $msg = shift ;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime (time) ;
  my $time = sprintf ("%02d/%02d/%04d %02d:%02d", $mday, $mon+1, $year+1900, $hour, $min) ;

  open  $fh_log_summary, ">>", "$work/$fn_log_summary" ;
  print $fh_log_summary "$time $msg" ;
  close $fh_log_summary ;
}



sub Abort
{
  $msg = shift . "\n" ;
  &Log ($msg) ;
  exit ;
}


#=============================================================================================================

# http://article.gmane.org/gmane.science.linguistics.wikipedia.technical/38154/match=new+statistics+stuff
# http://svn.wikimedia.org/viewvc/mediawiki/trunk/webstatscollector/
# https://bugzilla.wikimedia.org/show_bug.cgi?id=13541
# http://de.wikipedia.org/w/api.php?action=query&meta=siteinfo&siprop=general|namespaces|namespacealiases

# Ideas:
# 1 namespace string -> namespace number ? (may not save much space: compress will deal with recurring patterns like these)
# 2 frequency distribution hits per file per first letter _-> manifest crawler
#   assuming crawler collects articles in alphabetical order
# 3 always convert first letter after namespace string to uppercase, then sort and merge


