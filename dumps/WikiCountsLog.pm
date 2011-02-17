#!/usr/bin/perl

sub OpenLog
{
  my $job = shift ;
  if ($job eq '')
  { $job = "WikiCounts" ; }

  my $target = "" ;
  if    ($webalizer)    { $target = "Webalizer" ; }
  elsif ($mode eq "wb") { $target = "Wikibooks" ; }
  elsif ($mode eq "wk") { $target = "Wiktionary" ; }
  elsif ($mode eq "wn") { $target = "Wikinews" ; }
  elsif ($mode eq "wp") { $target = "Wikipedia" ; }
  elsif ($mode eq "wq") { $target = "Wikiquote" ; }
  elsif ($mode eq "ws") { $target = "Wikisource" ; }
  elsif ($mode eq "wx") { $target = "Wikispecial" ; }
  elsif ($mode eq "wv") { $target = "Wikiversity" ; }
  else                  { $target = "???" ; }

  $fileage  = -M $file_log ;
  if ($fileage > 5)
  {
    open "FILE_LOG", "<", $file_log || abort ("Log file 'WikiCountsLog.txt' could not be opened.") ;
    @log = <FILE_LOG> ;
    close "FILE_LOG" ;
    $lines = 0 ;
    open "FILE_LOG", ">", $file_log || abort ("Log file 'WikiCountsLog.txt' could not be opened.") ;
    foreach $line (@log)
    {
      if (++$lines >= $#log - 5000)
      { print FILE_LOG $line ; }
    }
    close "FILE_LOG" ;
  }
  open "FILE_LOG", ">>", $file_log || abort ("Log file '$file_log' could not be opened.") ;
  $log_enabled = $true ;
  &LogT ("\n\n===== $job / " . &GetDateTime(time) . " / $target / project C:" . uc($mode) . ":" . uc ($language) . " =====\n\n") ;

  if ($edits_total_previous_run > 100000)
  { &LogT ("Previous run took $runtime_previous_run for " . i2KM ($edits_total_previous_run) . " edits\n\n") ; }

  &Log ($log_buffer) ;
  $log_buffer = "" ;
}

sub Log
{
  $msg = encode_non_ascii(shift) ;
  if ($log_enabled)
  {
    print $msg ;
    print FILE_LOG $msg ;
  }
  else
  { $log_buffer .= $msg ; }
}

sub Log2
{
  $msg = encode_non_ascii(shift) ;
  if ($log_enabled)
  { print FILE_LOG $msg ; }
  else
  { $log_buffer .= $msg ; }
}

sub LogPhase
{
  $msg = encode_non_ascii(shift) ;
# if (&TraceJob)
# { &Log ("\n") ; }
# &LogT ($msg) ;
  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
  my $time = sprintf ("%02d:%02d:%02d", $hh, $mm, $ss) ;
  print "\n$time $msg\n" ;
  open "FILE_LOG_CONCISE", ">>", $file_log_concise || print ("Log file 'WikiCountsLogConcise.txt' could not be opened.\n") ;
  print FILE_LOG_CONCISE "$time $msg\n" ;
  close FILE_LOG_CONCISE ;
}

sub LogC
{
  $msg = encode_non_ascii(shift) ;
  $msg2 = $msg ;
  $msg2 =~ s/\n//gs ;
  print "\n\n[$msg2]\n\n" ;
  open "FILE_LOG_CONCISE", ">>", $file_log_concise || print ("Log file 'WikiCountsLogConcise.txt' could not be opened.\n") ;
  print FILE_LOG_CONCISE $msg ;
  close FILE_LOG_CONCISE ;
}

sub LogT
{
  my $msg  = shift ;
  my $msg2 = $msg ;
  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
  my $time = sprintf ("%02d:%02d:%02d", $hh, $mm, $ss) ;
  $msg2 =~ s/([^\n])\n(.)/$1\n         $2/gs ;
  $msg2 =~ s/(^\n*)/$1$time /s ;
  &Log ($msg2) ;
  if (($mode eq "wp") && (($language eq "en") || ($language eq "nv")) && (length ($msg) > 12))
  {
    my $msg3 = $msg ;
    $msg3 =~ s/\n//g ;
    $msg3 =~ s/\s//g ;
    if ($msg3 ne "")
    {
      open "FILE_LOG_CONCISE", ">>", $file_log_concise || print ("Log file 'WikiCountsLogConcise.txt' could not be opened.\n") ;

      if ($msg =~ /^\n?\d\d\:\d\d\:\d\d/)
      { print FILE_LOG_CONCISE "$msg\n" ; }
      else
      { print FILE_LOG_CONCISE "$time $msg2\n" ; }
      close FILE_LOG_CONCISE ;
    }
  }
}

sub LogTime
{
  my $postfix = shift ;
  if ($filesizelarge || $testmode)
  {
    my ($min, $hour) = (localtime (time))[1,2] ;
    &Log ("\n" . sprintf ("%02d", $hour) . ":" . sprintf ("%02d", $min) . $postfix) ;
  }
}

sub SpoolPreviousErrors
{
  if (-e $file_errors)
  {
    open  (ERRORS, "<", $file_errors) ;
    @errors = <ERRORS> ;
    close (ERRORS) ;
    if ($#errors != -1)
    {
      &LogT ("Log run time errors from previous run (from captured stderr)\n") ;
      &Log2 (">>\n") ;
      foreach $line (@errors)
      { &Log2 ($line) ; }
      &Log2 ("<<\n\n") ;
    }
    unlink $file_errors ;
    undef @errors ;
  }
}

sub WriteJobRunStats
{
  my $time_total  = time - $timestart ;
  my $time = time ;
  my $time_en = &GetDateTimeEnglishShorter($time) ;
  my $edits_total = $edits_total_namespace_a + $edits_total_namespace_x ;

  my $lang = $language ;
  $lang =~ s/^(..)$/ $1/ ;

  my $legend = "" ;
  if (! -e $file_csv_run_stats)
  { $legend = "language,dump date,time now,time now english,file format,file size on disk,file size uncompressed,host name,time parse input,time total,edits namespace 0,other edits,\n" ; }

  my $dump = 'full_dump' ;
  if ($edits_only)
  { $dump = 'edits_only' ; }

  open "FILE_RUNSTATS", ">>", $file_csv_run_stats || abort ("File '$file_csv_run_stats' could not be opened.") ;
  if ($legend ne "")
  { print FILE_RUNSTATS $legend ; }
  print FILE_RUNSTATS "$lang,$dumpdate,$time,$time_en,$fileformat,$filesize_ondisk,$filesize_uncompressed,$hostname,$time_parse_input,$time_total,$edits_total_namespace_a,$edits_total_namespace_x,$dump\n" ;
  close "FILE_RUNSTATS";
}

sub SignalReportingToDo
{
  open "FILE_REPORTING", ">>", $file_report || abort ("File '$file_report' could not be opened.") ;
  print FILE_REPORTING "$lang,$dumpdate,$time,$time_en\n" ;
  close "FILE_REPORTING";
}

sub UpdateLog
{
  &TraceMem ;

  my $year  = substr($dumpdate,0,4) ;
  my $month = substr($dumpdate,4,2) ;

  my $fraction_5   = 0 ;
  my $fraction_100 = 0 ;
# if ($forecast_partial_month)
# {
#   my $months_5    = 0 ;
#   my $months_100  = 0 ;
#   for ($m = 1 ; $m <= 5 ; $m++)
#   {
#     $month -- ;
#     if ($month == 0)
#     { $month = 12 ; $year -- ; }
#     $yymm = sprintf ("%02d%02d", $year-2000, $month) ;

#     if ($active_users_per_month {"A,5,$yymm"} > 0)
#     {
#       $months_5++ ;
#       $fraction_5   += $active_users_per_partial_month {"A,5,$yymm"} /
#                        $active_users_per_month {"A,5,$yymm"} ;
#     }
#     if ($active_users_per_month {"A,100,$yymm"} > 0)
#     {
#       $months_100++ ;
#       $fraction_100 += $active_users_per_partial_month {"A,100,$yymm"} /
#                        $active_users_per_month {"A,100,$yymm"} ;
#     }
#   }
#   if ($months_5 == 0)
#   { $fraction_5 = "1.00" ; }
#   else
#   { $fraction_5 = sprintf ("%.2f", $fraction_5 / $months_5) ; }

#   if ($months_100 == 0)
#   { $fraction_100 = "1.00" ; }
#   else
#   { $fraction_100 = sprintf ("%.2f", $fraction_100 / $months_100) ; }
# }

  my $dump = 'full_dump' ;
  if ($edits_only)
  { $dump = 'edits_only' ; }

  &ReadFileCsv ($file_csv_log) ;

  $runtime = ddhhmmss (time - $timestart, '%d days %d hrs %d min %d sec') ;
  $conversions =~ s/\s//g ;

  $line = &csv($language) . &csv($dumpdate) .
          &csv(&mmddyyyy (time)) . &csv($runtime) .
          &csv(sprintf ("%d",$conversions)) .
          &csv($fraction_5). &csv($fraction_100).
          &csv($recently_active_users) .
          &csv($edits_total_namespace_a) . &csv($edits_total_ip_namespace_a) .
          &csv($edits_total_namespace_x) . &csv($edits_total_ip_namespace_x) . $dump ;

  &LogT ("\nStatisticsLog.csv <- $line\n") ;
  push @csv, $line ;
  @csv = sort {$a cmp $b} @csv ;
  &WriteFileCsv ($file_csv_log) ;
}

sub TraceJob
{
# if ($testmode)
# { return ($true) ; }

  if (! $traceresources)
  { return ($false) ; }

  # only trace memory on the most massive jobs: wp:en and wp:de and two smaller for tests: wp:fy and wp:af
  if ($project !~ /^(?:enwiki|dewiki|frwiki|jawiki|nlwiki|fywiki|afwiki|itwiki|nvwiki|metawiki)/)
  { return ($false) ; }

  return ($true) ;
}

sub TraceMem
{
  if (! &TraceJob) { return ; }

  my $tracehashes = shift ;
  if ($tracehashes ne $nohashes)
  { &TraceHashes ; }

  if ($path_in =~ /\\/) # Windows ?
  {
    &LogTime ("TraceMem\n") ;
    return ;
  }

  my @ps = `ps ux | grep \"WikiCounts.pl\"` ;

  my $text = "" ;
  foreach $t (@ps)
  {
    if ($t =~ m/\-d/)
    {
      $t =~ s/^[^ ]+// ;
      $t =~ s/pts.*$// ;
      @tf = split (' ', $t) ;
      $t2 = sprintf ("CPU %s MEM %s VSZ %s RSS %s\n", $tf[1],$tf[2],$tf[3],$tf[4]) ;
      $text .= $t2 ;
    }
  }

  my @top = `top -b -u ezachte -n 1` ;
  foreach $t (@top)
  {
    $t =~ s/[^\s\w]/ /g ;
    if (($t =~ m/^(?:Mem|Swap)/) || ($t =~ /perl/))
    { $text .= $t ; }
  }

# &LogTime ;

  $log = "\n------------------------------------------------------------------------\n" . $text ;

  $text = `df -h /dev/sda1` ;
# $log .= "\ndf -h =>\n" . $text ;
  $text =~ s/^.*?\//\//s ; # remove headers (part before /dev/..)
  $log .= $text ;

  $text = `df -h $path_temp` ;
# $log .= "\ndf -h =>\n" . $text ;
  $text =~ s/^.*?\//\//s ; # remove headers (part before /dev/..)
  $log .= $text ;

  $disk_free = $text ;
# $disk_free =~ s/^.*?Mounted\son\n.// ;
  $disk_free =~ s/^.*?\n//s ;
  $disk_free =~ s/^[^\s]+\s+[^\s]+\s+[^\s]+\s+//g ;
  $disk_free =~ s/\s.*$// ;
  $disk_free =~ s/\n.*$//s ;

  $text = `du -h $path_temp` ;
  $text =~ s/^(.*?)(\/.*)$/$2  $1/ ;
# $log .= "\ndu -h =>\n" . $text ."------------------------------------------------------------------------\n " ;
  $log .= $text ."------------------------------------------------------------------------\n\n " ;

  $disk_used = substr ($text,0,5) ;
  $disk_used =~ s/\s.*$//g ;
  $disk_used =~ s/\t.*$//g ;
  &LogT ($log) ;
}

sub TraceHashes
{
  $trace_hashes = "" ;
  &TraceHash ("binaries_per_month") ;
  &TraceHash ("new_titles_per_namespace_per_month") ;
  &TraceHash ("zeitgeist_reg_users_rank") ;
  &TraceHash ("zeitgeist_reg_users_title") ;
  &TraceHash ("access") ;
  &TraceHash ("book_authors") ;
  &TraceHash ("book_chaptercnt") ;
  &TraceHash ("book_chapterlist") ;
  &TraceHash ("book_edits") ;
  &TraceHash ("book_size") ;
  &TraceHash ("book_words") ;
  &TraceHash ("bots") ;
  &TraceHash ("botsndx") ;
  &TraceHash ("chaptercnt") ;
  &TraceHash ("edits_per_month") ;
  &TraceHash ("edits_per_user_ip_namespace_0") ;
  &TraceHash ("edits_per_user_ip_namespace_x") ;
  &TraceHash ("edits_per_user_per_month") ;

  if ($forecast_partial_month)
  {
    &TraceHash ("edits_per_user_per_partial_month") ;
    &TraceHash ("files_events_user_month_partial") ;
    &TraceHash ("partial_months") ;
  }

  &TraceHash ("files_events_article") ;
  &TraceHash ("files_events_month") ;
  &TraceHash ("files_events_user_month") ;
  &TraceHash ("months_edited_per_article") ;
  &TraceHash ("namespaces") ;
  &TraceHash ("namespacesinv") ;
  &TraceHash ("timelines_info") ;
  &TraceHash ("timelines_md5") ;
  &TraceHash ("total_per_namespace") ;
  &TraceHash ("undef_namespaces") ;
  &TraceHash ("userfirst") ;
  &TraceHash ("userlast") ;
  &TraceHash ("users") ;
  &TraceHash ("users_per_month") ;
  &TraceHash ("wikipedias") ;
  if ($trace_hashes ne "")
# { &Log ("\n\n           new number of entries for hash:\n$trace_hashes\n") ; }
  {
    &Log ("\n\nHashes ->\n$trace_hashes\n") ;
    &LogTime (" - ") ;
  }
}

sub TraceHash
{
  my $hash = shift ;
  my $count = scalar keys(%$hash) ;
  if ($count != $hashes {$hash})
  {
    $diff = "+" ;
    if ($count < $hashes {$hash})
    { $diff = "-" ; }
    $trace_hashes .= sprintf ("%9d", $count) . "$diff $hash\n" ;
    $hashes {$hash} = $count ;
  }
}

sub TraceRelease
{
  if (! &TraceJob) { return ; }

  my $msg = shift ;
  &TraceMem ($nohashes) ;
  &LogTime (" - ") ;
  &Log ("$msg") ;
}

sub WriteTraceBuffer
{
  if ($tracemsg ne "")
  {
    $tracemsg =~ s/(^|\n)/\n\n           /gs ;
    &Log ("\n\n           $tracemsg\n") ;
    $tracemsg = "" ;
  }
  if (! $TraceJob)
  { &LogT ("\n- ") ; }
}

sub WriteDiskStatus
{
  &Log ("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++") ;
  $path_temp2 = "/a/tmp/wikistats" ;
  if (($path_in !~ /\\/) && (-d $path_temp)) # Windows ?
  {
    $text = `df -h $path_temp` ;
    &Log ("\nDisk free: \n$text\n") ;
    $text = `du -h $path_temp | grep tmp` ;
    &Log ("\nDisk used: \n$text\n") ;

    if ($filesizelarge)
    {
      $text = `ls -lh $path_temp` ;
      &Log ("List $path_temp =>" . $text . "\n") ;
    }
  }
  $text = `ls -l $path_temp2` ;
  &Log ("List $path_temp2 =>" . $text . "\n") ;
  &Log ("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n") ;
}

1;
