#!/usr/bin/perl

  use WikiCountsConversions ;

  $qr_csvkey_lang_date = qr/([^,]*,)(\d\d).(\d\d).(\d\d\d\d).*$/ ;

  # count user with over x edits
  # threshold starting with a 3 are 10xSQRT(10), 100xSQRT(10), 1000xSQRT(10), etc
  @thresholds = (1,3,5,10,25,32,50,100,250,316,500,1000,2500,3162,5000,10000,25000,31623,50000,100000,250000,316228,500000,1000000,2500000,3162278,500000,10000000,25000000,31622777,5000000,100000000) ;
  @thresholds_sparse = (1,3,5,10,25,100,250,1000,2500,10000,25000,100000,250000,1000000,2500000,10000000,25000000,100000000) ;

# debugging: code needed to restart aborted SortArticleHistoryOnDateTime

#  $length_line_event = 32 ;
#  $Kb = 1024 ;
#  $Mb = $Kb * $Kb ;

#  $filesizelarge = 1 ;
#  $path_temp = "D:/Wikipedia/\@wp/csv/Temp/" ;
#  @files_events_month {"D:/Wikipedia/\@wp/csv/Temp/EventsSortByMonth~2007-03"} = 1 ;
#  &SortArticleHistoryOnDateTimeNew ;
#  exit ;

#sub Log { print shift ; }
#sub TraceMem {;} ;
#sub ddhhmm2bbb
#{
#  my $dd = shift ;
#  my $hh = shift ;
#  my $mm = shift ;
#  my $int = ($dd - 1) * 1440 + ($hh*60) + $mm ;
#  return (&i2bbb ($int)) ;
#}
#sub bbb2ddhhmm
#{
#  my $bbb = shift ;
#  my $int = &bbb2i ($bbb) ;
#  my $mm  = $int % 60 ;
#  $int -= $mm ;
#  my $hh  = ($int/60) % 60 ;
#  $int -= $hh * 60 ;
#  my $dd  = int ($int/1440) ;
#  return (sprintf ("%02d%02d%02d", $dd, $hh, $mm)) ;
#}
## unpack 3 bytes (binary) back to integer
#sub bbb2i
#{
#  my $bbb = shift ;
#  return (ord (substr ($bbb,0,1)) * 128 * 128 +
#          ord (substr ($bbb,1,1)) * 128 +
#          ord (substr ($bbb,2,1))) ;
#}
## pack integer into 3 bytes (binary), range = 0 - 7F7F7F = 0 - 2097151
#sub i2bbb
#{
#   my $i = shift ;
#   die "Function i2bbb failed: integer ($i) exceeds max (2097151)" if ($i > 2097151) ;
#   my $b3  = $i % 128 ;
#   my $b2  = int ($i / 128) % 128 ;
#   my $b1  = int ($i / (128 * 128)) ;
#   return (chr($b1).chr($b2).chr($b3)) ;
#}


# for CountUsersPerWeek

sub SortAndCompactEditsUserMonth
{
  my $timestartsort = time ;

  &LogPhase ("SortAndCompactEditsUserMonth") ;
  &TraceMem ;

  if (! $job_runs_on_production_server)
  {
    &Log ("Not on Linux system, skip this step, which involves external sort.\n") ;
    return ;
  }

  $filesize_in = &i2KbMb (-s $file_csv_user_month_article) ;
  $cmd = "sort $file_csv_user_month_article -o $file_csv_user_month_article_s -T $path_temp" ;
  $result = `$cmd` ;
  &LogT ("Cmd $cmd -> result '$result'\n") ;
  &LogT ("Sort took " . ddhhmmss (time - $timestartsort). ".\n") ;
# unlink $file_csv_user_month_article ;

  &TraceMem ;

  &LogT ("Compact into $file_csv_user_month\n") ;
  open    EDITS_USER_MONTH_ARTICLE, "<", $file_csv_user_month_article_s ;
  open    EDITS_USER_MONTH,         ">", $file_csv_user_month ;
  binmode EDITS_USER_MONTH_ARTICLE ;
  binmode EDITS_USER_MONTH ;

  print EDITS_USER_MONTH "# Edit counts per registered user per month per namespace, produced by monthly wikistats job\n" ;
  print EDITS_USER_MONTH "# user, month, namespace, edits in whole month, edits in first 28 days (for normalized trends with equal length partial months)\n" ;
  $user_month_ns_prev = '' ;
  my ($count_all, $count_all_28) ;
  while ($line = <EDITS_USER_MONTH_ARTICLE>)
  {
    chomp $line ;
    my ($user,$month,$namespace,$count,$count_28) = split (',', $line) ;
    $namespace += 0 ; # remove leading zeroes, used to influence sort order
    if (("$user,$month,$namespace" ne $user_month_ns_prev) &&  ($user_month_ns_prev ne ''))
    {
      print EDITS_USER_MONTH "$user_month_ns_prev,$count_all," . ($count_all_28+0) . "\n" ; # only second count can be zero
      $count_all    = $count ;
      $count_all_28 = $count_28 ;
    }
    else
    {
      $count_all    += $count ;
      $count_all_28 += $count_28 ;
    }

    $user_month_ns_prev = "$user,$month,$namespace" ;
  }
  print EDITS_USER_MONTH "$user_month_ns_prev,$count_all," . ($count_all_28+0) . "\n" ; # only second count can be zero
  close EDITS_USER_MONTH ;
  close EDITS_USER_MONTH_ARTICLE ;

  $filesize_out = &i2KbMb (-s $file_csv_user_month) ;
  &LogT ("File '$file_csv_user_month' ($filesize_in -> $filesize_out))\n") ;

  &TraceMem ;
# unlink $file_csv_user_month_article_s ;
  &TraceMem ;
}

sub SortArticleHistoryOnDateTime
{
  &LogPhase ("SortArticleHistoryOnDateTime") ;
  &TraceMem ;

  my ($day,$day2) ; ;

  $timestartsort = time ;
  open "FILE_EVENTS_ALL", ">", $path_temp . "EventsSortByTime" ;
  binmode FILE_EVENTS_ALL ;
  foreach $file (sort keys %files_events_month)
  {
    my $sizefile = -s $file ;
    if ($sizefile < 10 * $Mb)
    {
      open "FILE_EVENTS", "<", $file ;
      binmode FILE_EVENTS ;
      undef @events ;
      while (read (FILE_EVENTS, $event, $length_line_event) == $length_line_event)
      { push @events, $event ; }
      close "FILE_EVENTS" ;

      # unlink $file ;
      # &LogT ("Read $file: " . sprintf ("%9d",$sizefile) . " bytes, " . sprintf ("%6d",$#events+1) . " events\n") ;

      @events = sort {substr ($a,4,5) cmp substr ($b,4,5)} @events ;
      foreach $event (@events)
      { print FILE_EVENTS_ALL $event ; }
    }
    else
    {
      foreach $day (1..31)
      {
        $day2 = sprintf ("%02d", $day) ;
        open    "FILE_EVENTS_TEMP-$day2", ">", "$file-$day2" ;
        binmode "FILE_EVENTS_TEMP-$day2" ;
      }

      open "FILE_EVENTS", "<", $file ;
      binmode FILE_EVENTS ;
      while (read (FILE_EVENTS, $event, $length_line_event) == $length_line_event)
      {
        my $time = substr ($event,4,5) ;
        my $ddhhmm = &bbb2ddhhmm (substr ($time,2,3)) ;
        my $day_event = sprintf ("%02d", substr ($ddhhmm,0,2) + 1) ;
        print {"FILE_EVENTS_TEMP-$day_event"} $event ;
      }
      close "FILE_EVENTS" ;

      if ($filesizelarge)
      { &TraceMem ($nohashes) ; }

      foreach $day (1..31)
      {
        $day2 = sprintf ("%02d", $day) ;
        &LogT ("\nSort $file day $day: ") ;

        close   "FILE_EVENTS_TEMP-$day2" ;
        open    "FILE_EVENTS_TEMP-$day2", "<", "$file-$day2" ;
        binmode "FILE_EVENTS_TEMP-$day2" ;

        undef @events ;
        while (read ("FILE_EVENTS_TEMP-$day2", $event, $length_line_event) == $length_line_event)
        { push @events, $event ; }
        close "FILE_EVENTS_TEMP-$day2" ;
        # unlink "$file-$day2" ;
        &Log ($#events."\n") ;

        @events = sort {substr ($a,4,5) cmp substr ($b,4,5)} @events ;
        foreach $event (@events)
        { print FILE_EVENTS_ALL $event ; }
      }

      # unlink $file ;
      # &LogT ("\n$file removed: " . sprintf ("%9d",$sizefile) . " bytes") ;
    }
  }

  close "FILE_EVENTS_ALL" ;

  undef @events ;
# @article_history = sort { substr ($a,4,5) cmp substr ($b,4,5) } @article_history ;
  &TraceMem ;
  &LogT ("\nSort took " . ddhhmmss (time - $timestartsort). ".\n") ;
}

# for CountUsersPerWeek
sub SortArticleHistoryOnDateTimeOld
{
  &LogPhase ("SortArticleHistoryOnDateTimeOld") ;
  &TraceMem ;

  $timestartsort = time ;
  open "FILE_EVENTS_ALL", ">", $path_temp . "EventsSortByTime" ;
  binmode FILE_EVENTS_ALL ;
  foreach $file (sort keys %files_events_month)
  {
    my $sizefile = -s $file ;
    open "FILE_EVENTS", "<", $file ;
    binmode FILE_EVENTS ;
    undef @events ;
    $recs = 0 ;
    while (read (FILE_EVENTS, $event, $length_line_event) == $length_line_event)
    { push @events, $event ; }
    close "FILE_EVENTS" ;
    # unlink $file ;
    &LogT ("Read $file: " . sprintf ("%9d",$sizefile) . " bytes, " . sprintf ("%6d",$#events+1) . " events\n") ;

    if ($filesizelarge)
    {
 #    unlink $file ;
      &TraceMem ($nohashes) ;
    }
    @events = sort {substr ($a,4,5) cmp substr ($b,4,5)} @events ;
    foreach $event (@events)
    { print FILE_EVENTS_ALL $event ; }
  }

  close "FILE_EVENTS_ALL" ;

  undef @events ;
# @article_history = sort { substr ($a,4,5) cmp substr ($b,4,5) } @article_history ;
  &TraceMem ;
  &LogT ("\nSort took " . ddhhmmss (time - $timestartsort). ".\n") ;
}

# for CountArticlesPerFewDays
# for CountArticlesUpTo
sub SortArticleHistoryOnArticleDateTime
{
  &LogPhase ("SortArticleHistoryOnArticleDateTime") ;
  &TraceMem ;

  $timestartsort = time ;
  open "FILE_EVENTS_ALL", ">", $path_temp . "EventsSortByArticleTime" ;
  binmode FILE_EVENTS_ALL ;
  foreach $file (sort keys %files_events_article)
  {
    my $sizefile = -s $file ;
    open "FILE_EVENTS", "<", $file ;
    binmode FILE_EVENTS ;
    undef @events ;
    while (read (FILE_EVENTS, $event, $length_line_event) == $length_line_event)
    { push @events, $event ; }
    close "FILE_EVENTS" ;
    # unlink $file ;
    &LogT ("Read $file: " . sprintf ("%9d",$sizefile) . " bytes, " . sprintf ("%6d",$#events+1) . " events\n") ;

    if ($filesizelarge && ($trace_files_events_sort_by_article_time ++ % 100 == 0))
    {
#     unlink $file ;
      &TraceMem ($nohashes) ;
    }
    @events = sort {$a cmp $b} @events ;
    foreach $event (@events)
    { print FILE_EVENTS_ALL $event ; }
  }

  # add dummy record (this prevents last real record being a special case)
  for ($i = 1 ; $i <= 32 ; $i++)
  { print FILE_EVENTS_ALL chr (127) ; }

  close "FILE_EVENTS_ALL" ;
  undef @events ;
  &TraceMem ;
  &LogT ("Sort took " . ddhhmmss (time - $timestartsort). ".\n") ;
}

sub CountUsersPerWeek
{
  &LogPhase ("CountUsersPerWeek") ;
  &TraceMem ;

  my $ndx_event = 0 ;
  my $contributors = 0 ;
  my $contributors_prev = 0 ;
  my %contributions ;
  my %contributions_tot ;
  my %contributions_this_week ;
  my $days_prev = -1 ;
  my $user ;
  my $time0 = chr (0) ;

  my $file_events = $path_temp . "EventsSortByTime" ;
  open "FILE_EVENTS", "<", $file_events || abort ("Temp file '$file_events' could not be opened.") ;
  binmode FILE_EVENTS ;
  $filesize = -s $file_events ;
  &LogT ("\nReading back intermediate file EventsSortByTime (". &i2KbMb ($filesize) . ").\n" .
         "Pass 1\nEvents (x 10000):\n ") ;
  $bytes_read = 0 ;
  $mb_read = 0 ;
  while (read (FILE_EVENTS, $event, $length_line_event) == $length_line_event)
  {
    $user = &bbbb2i  (substr ($event,27,4)) ;
    if ($user != 0)
    { @contributions_tot {$user} ++ ; }
  }
  close "FILE_EVENTS" ;

  open "FILE_EVENTS", "<", $file_events || abort ("Temp file '$file_events' could not be opened.") ;
  binmode FILE_EVENTS ;
  &LogT ("\nPass 2\nEvents (x 10000):\n ") ;
  $bytes_read = 0 ;
  $mb_read = 0 ;
  while (read (FILE_EVENTS, $event, $length_line_event) == $length_line_event)
  {
    $ndx_event++ ;
    if (($ndx_event >= 10000) && ($ndx_event % 10000 == 0))
    {
      &Log (($ndx_event / 10000) . " ") ;
      if ($ndx_event % 200000 == 0)
      { &LogT ("\n - ") ; }
    }

    my $days  = &bbbbb2d (substr ($event, 4,5)) ;
    if ($ndx_event == 1)
    {
      $days_first = $days ;
      while (($days_first % 7) != 0)
      { $days_first -- ; }
    }

    $user = &bbbb2i  (substr ($event,27,4)) ;
    if ($user != 0)
    {
      @contributions           {$user} ++ ;
      @contributions_this_week {$user} ++ ;
    }

    if (($ndx_event > 1) &&
        (($days != $days_prev) || ($ndx_event == $tot_events - 1)))
    {
      while ((++$days_prev <= $days) ||
             ($ndx_event == $tot_events - 1))
      {
        if ((($days_prev > $days_first) && ((($days_prev-$days_first) % 7) == 0)) ||
             ($ndx_event == $tot_events - 1))
        {
          $contributors = 0 ;
          $users_active = 0 ;
          $users_very_active = 0 ;
          foreach $user (keys %contributions)
          {
#           if ($contributions {$user} >= 10)
            if ($language eq "sep11")
            { $contributors ++ ; }
            elsif ($contributions_tot {$user} >= 10)
            { $contributors ++ ; }
          }
          foreach $user (keys %contributions_this_week)
          {
            if ($contributions_this_week {$user} >= 5)
            { $users_active ++ ; }
            if ($contributions_this_week {$user} >= 25)
            { $users_very_active ++ ; }
          }
          $contributors_new = $contributors - $contributors_prev ;
          push @weekly_stats, &csv (&d2mmddyyyy($days_prev)) .
                              &csv ($contributors) .
                              &csv ($contributors_new) .
                              &csv ($users_active) .
                              &csv ($users_very_active) ;
          $contributors_prev = $contributors ;
          undef (%contributions_this_week) ;

          if ($ndx_event == $tot_events - 1)
          { last ; }
        }
      }
    }
    $days_prev  = $days ;
  }
  close "FILE_EVENTS" ;

  &TraceRelease ("Release tables \@contributions[_tot][_this_week]") ;
  &LogT ("\nCounting ready\n") ;
}

sub CountArticlesPerFewDays
{
  &LogPhase ("CountArticlesPerFewDays") ;
  &TraceMem ;

  undef (%edits_per_day) ;
  my $interval = 7 ; # used to be 3, could this code now be merged with code for weekly stats ?

  my $day_now = &bbbbb2d (&t2bbbbb ($dumpdate_gm)) ;
  my $day_max = $day_now + $interval + 1 ;

  while ($day_max % $interval > 0)
  { $day_max ++ ; }

  my $ndx_event = 0 ;
  my $ndx_prev  = -1;
  my $days_prev = -1 ;
  my $edits     = 0 ;
  my ($count, $size, $size2, $words, $links, $wiki_links) ;
  my $b4hi2bbb = &i2bbbb ($b4hi) ;

  my $file_events = $path_temp . "EventsSortByArticleTime" ;
  open "FILE_EVENTS", "<", $file_events || abort ("Temp file '$file_events' could not be opened.") ;
  binmode FILE_EVENTS ;
  $filesize = -s $file_events ;
  # &LogT ("\nReading back intermediate file EventsSortByArticleTime (". &i2KbMb ($filesize) . ").\n") ;
  &LogT ("\nEvents (x 10000): ") ;
  $bytes_read = 0 ;
  $mb_read = 0 ;
  $time0 = chr (0) ;
  while (read (FILE_EVENTS, $event, $length_line_event) == $length_line_event)
  {
    if (substr ($event,0,4) eq $b4hi2bbb)
    { next ; }

    $ndx_event++ ;
    if (($ndx_event >= 10000) && ($ndx_event % 10000 == 0))
    {
      &Log (($ndx_event / 10000) . " ") ;
      if ($ndx_event % 200000 == 0)
      { &LogT ("\n - ") ;}
    }

    $edits ++ ;

    my $ndx   = &bbbb2i   (substr ($event, 0,4)) ;
    my $days  = &bbbbb2d  (substr ($event, 4,5)) ;
    @edits_per_day {$days} ++ ;
    if ($ndx_event == 1)
    {
      $day_count = $days ;
      while ($day_count % $interval > 0)
      { $day_count ++ ; }
    }

    if ($ndx != $ndx_prev)
    { $days = $day_max ;
     }

    if (($days > $day_count) && ($ndx_event > 1))
    {
      $count       =          substr ($event_prev, 9,1) ;
      $size        = &bbbb2i (substr ($event_prev,10,4)) ;
      $size2       = &bbbb2i (substr ($event_prev,14,4)) ;
      $links       = &bb2i   (substr ($event_prev,18,2)) ;
      $wiki_links  = ord     (substr ($event_prev,20,1)) ;
#     $image_links = ord (substr ($event_prev,21,1)) ;
#     $cat_links   = ord (substr ($event_prev,22,1)) ;
#     $ext_links   = ord (substr ($event_prev,23,1)) ;
      $words       = &bbb2i  (substr ($event_prev,24,3)) ;

      while ($day_count < $days)
      {
        $articles_per_day_L {$day_count} += $edits ;
        $articles_per_day_M {$day_count} += $size ;

        if (($count eq "+") || ($count eq "L") || ($count eq "S"))
        {
          $articles_per_day_E {$day_count} ++ ; # article count official

          if ($count eq "+") # no redirect, stub or link list
          { $articles_per_day_F {$day_count} ++ ; } # article count alternate

          $articles_per_day_N {$day_count} += $words ;
          $articles_per_day_O {$day_count} += $links ;
          $articles_per_day_P {$day_count} += $wiki_links ;
        }
        $day_count += $interval ;
      }
    }
    if ($ndx != $ndx_prev)
    {
      $day_count = &bbbbb2d (substr ($event, 4,5)) ;
      while ($day_count % $interval > 0)
      { $day_count ++ ; }
      $edits = 0 ;
    }
    $event_prev = $event ;
    $ndx_prev   = $ndx ;
  }
  close "FILE_EVENTS" ;

  undef (@csv2) ;
  foreach $key (keys %edits_per_day)
  {
    $line_csv = &csv ($language) .
                &csv (&d2mmddyyyy ($key)) .
                &csv (@edits_per_day {$key}) ;
    $line_csv =~ s/\,$// ;
    push @csv2, $line_csv ;
  }

  &TraceRelease ("Release table \%edits_per_day") ;
  undef (%edits_per_day) ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_edits_per_day) ;
  foreach $line (@csv2)
  { push @csv, $line ; }
# @csv = sort {&csvkey_lang_date ($a) cmp &csvkey_lang_date ($b)} @csv ;
  @csv = sort {($x=$a,$x=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$x) cmp ($y=$b,$y=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$y)} @csv ;
  &WriteFileCsv ($file_csv_edits_per_day) ;

  undef (@csv2) ;
  foreach $key (sort {$a <=> $b} keys %articles_per_day_E)
  {
    $date = &d2mmddyyyy ($key) ;
#    if (substr ($date,3,2) > 3) { next ; }
    $line_csv = &csv ($language) .
                &csv (&d2mmddyyyy ($key)) .
                &csv ($articles_per_day_E {$key}) .
                &csv ($articles_per_day_F {$key}) .
                &csv ($articles_per_day_L {$key}) .
                &csv ($articles_per_day_M {$key}) .
                &csv ($articles_per_day_N {$key}) .
                &csv ($articles_per_day_O {$key}) .
                &csv ($articles_per_day_P {$key}) ;
    $line_csv =~ s/\,$// ;
    push @csv2, $line_csv ;
  }

  &TraceRelease ("Release tables \@articles_per_day_..") ;

  undef (%articles_per_day_E) ;
  undef (%articles_per_day_F) ;
  undef (%articles_per_day_K) ;
  undef (%articles_per_day_L) ;
  undef (%articles_per_day_M) ;
  undef (%articles_per_day_N) ;
  undef (%articles_per_day_O) ;
  undef (%articles_per_day_P) ;
  &ReadFileCsv ($file_csv_stats_ploticus) ;
  foreach $line (@csv2)
  { push @csv, $line ; }
  undef (@csv2) ;

# @csv = sort {&csvkey_lang_date ($a) cmp &csvkey_lang_date ($b)} @csv ;
  @csv = sort {($x=$a,$x=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$x) cmp ($y=$b,$y=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$y)} @csv ;
  &WriteFileCsv ($file_csv_stats_ploticus) ;

  &LogT ("\nCountArticlesPerFewDays ready\n") ;
}

sub CountArticlesPerMonth
{
  &LogPhase ("CountArticlesPerMonth") ;
  &TraceMem ;

  my ($events_in, $events_out) ;
  my $file_events         = $path_temp . "EventsSortByArticleTime" ;
  my $file_events_concise = $path_temp . "EventsSortByArticleTimeConcise" ;
  open "FILE_EVENTS",         "<", $file_events         || abort ("Temp file '$file_events' could not be opened.") ;
  open "FILE_EVENTS_CONCISE", ">", $file_events_concise || abort ("Temp file '$file_events_concise' could not be opened.") ;
  binmode FILE_EVENTS ;
  binmode FILE_EVENTS_CONCISE ;

  $filesize = -s $file_events ;
  &LogT ("Reading $file_events: " . &i2KbMb ($filesize) . ".\n") ;

  $ndx_article_prev = "" ;
  $month_event_prev = "" ;
  $event_prev = "" ;
  while (read (FILE_EVENTS, $event, $length_line_event) == $length_line_event)
  {
    $events_in++ ;
    $month_event = &bb2yymm (substr ($event,4,2)) ;

  # $edits ++ ;
    $all_edits_per_month {$month_event} ++ ;

    $ndx_article = &bbbb2i (substr ($event,0,4)) ;

    my $count = substr ($event, 9,1) ;

    if ($count ne "R")
    {
    # $real_edits ++ ;
      $real_edits_per_month {$month_event} ++ ;
    }

    if ((($ndx_article ne $ndx_article_prev) || ($month_event ne $month_event_prev)) && ($event_prev ne ""))
    {
      $events_out++ ;
      print FILE_EVENTS_CONCISE $event_prev ;
    }

    # if ($mopfsopfko ++ < 1000)
    # { print "IN $events_in OUT $events_out MONTH $month_event MONTH_PREV $month_event_prev ART $ndx_article ART_PREV $ndx_article_prev\n"  ; }

    $ndx_article_prev = $ndx_article ;
    $month_event_prev = $month_event ;
    $event_prev       = $event ;
  }
  $events_out++ ;
  print FILE_EVENTS_CONCISE $event ;
  close "FILE_EVENTS" ;

  $filesize = -s $file_events_concise ;
  &LogT ("Written $file_events_concise: " . &i2KbMb ($filesize) . ".\n") ;
  if ($events_in > 0)
  { &LogT ("$events_out out of $events_in events copied to new file (" . sprintf ("%.1f", 100*$events_out/$events_in ) . "%)\n") ; }

  # determine month, year of first edit
  # (in human format -> 1 <= month <= 12 )
  ($day,$month,$year) = (localtime $first_edit) [3,4,5] ;
  $month += 1 ;
  $year  += 1900 ;

  &TraceMem ;
  &LogT ("First edit in year " . $year . ", month $month\n") ;

  ($month_dump,$year_dump) = (localtime $dumpdate_gm) [4,5] ;
  $month_dump += 1 ;
  $year_dump  += 1900 ;

  if ($log_progress_verbose)
  {
    &LogT ("-----: 1:real_articles, 2:mean_versions, 3:mean_articlesize, 4:articles_over_size1, 5:articles_over_size2\n" .
           "-----: 6:all_size, 7:tot_links, 8:tot_wiki_links, 9:tot_image_links, 10:tot_ext_links\n" .
           "-----: 11:tot_redirects, 12:alternate_articles, 13:tot_words, 14:tot_categorized, 15:not articles\n") ;
  }


  while (($year <  $year_dump) ||
         (($year == $year_dump) && ($month <= $month_dump)))
  {
    $yymm = sprintf ("%02d%02d", $year-2000, $month) ;
    $total_all_edits  += $all_edits_per_month  {$yymm} ;
    $total_real_edits += $real_edits_per_month {$yymm} ;

    $articles_per_month {$yymm} = &CountArticlesUpTo ($year, $month, $total_all_edits, $total_real_edits) ;

    my @fields = split (',', $articles_per_month {$yymm}) ;
    my $fields = '' ;
    my $f = 0 ;
    foreach $field (@fields)
    {
      $f++ ;
      $fields .= " $f:$field" ;
      last if ($edits_only && ($f eq 2)) ;
    }
    if ($log_progress_verbose)
    { &LogT ("$yymm: $fields\n") ; }

    $month ++ ;
    if ($month > 12)
    {
      $month = 1 ;
      $year ++ ;
      &TraceMem ($nohashes) ;
    }
  }

  &LogT ("CountArticlesPerMonth ready\n") ;
}


sub CountArticlesUpTo
{
  my $b2lo = chr(0).chr(0) ;
  my $b3lo = chr(0).chr(0).chr(0) ;

  my $year  = shift ;
  my $month = shift ;
  my $edits = shift ;
  my $real_edits = shift ;

  my $yymm = sprintf ("%02d%02d", $year-2000, $month) ;
  undef (@size_group) ;
  for ($i=0 ; $i<12; $i++)
  { $size_group [$i] = 0 ; }

  # set compare date/time to end of this month
  $month_upto = &yyyymm2bb ($year, $month) ;
  $real_articles = 0 ;
  $pages_without_internal_link = 0 ;
  $alternate_articles = 0 ;
# $edits      = 0 ;
  $real_size  = 0 ;
# $real_edits = 0 ;
  $articles_over_size1 = 0 ;
  $articles_over_size2 = 0 ;
  $all_size   = 0 ;
  $tot_links = 0 ;
  $tot_words = 0 ;
  $tot_wiki_links = 0 ;
  $tot_image_links = 0 ;
  $tot_categorized = 0 ;
  $tot_ext_links = 0 ;
  $tot_redirects = 0 ;
  $do_count_prev    = "-" ;

  $events = 0 ;
  my $file_events_concise = $path_temp . "EventsSortByArticleTimeConcise" ;
  open "FILE_EVENTS_CONCISE", "<", $file_events_concise || abort ("Temp file '$file_events_concise' could not be opened.") ;
  binmode FILE_EVENTS_CONCISE ;
  $filesize = -s $file_events_concise ;
  # &LogT ("\nReading back intermediate file EventsSortByArticleTime (". &i2KbMb ($filesize) . ").\n") ;

  if ($log_progress_verbose && ($countarticlesupto++ == 0))
  { &LogT ("Reading $file_events_concise: " . &i2KbMb ($filesize) . ".\n\n") ; }

  $bytes_read = 0 ;
  $mb_read = 0 ;
  $time0 = chr (0) ;

  my $event_prev = "" ;
  my $ndx_article_prev = "" ;

  while (read (FILE_EVENTS_CONCISE, $event, $length_line_event) == $length_line_event)
  {
    $month_event = substr ($event,4,2) ;
    if ($month_event gt $month_upto)
    { next ; }

  # $edits ++ ;

    $ndx_article = substr ($event,0,4) ;

  #  my $count = substr ($event, 9,1) ;
  #  if ($count ne "R")
  #  { $real_edits ++ ; }

    # raise counters for last revision of this article within current period
    if (($ndx_article ne $ndx_article_prev) && ($event_prev ne ""))
    { &CountPrev ($event_prev) ; }

    $event_prev = $event ;
    $ndx_article_prev = $ndx_article ;
  }
  close "FILE_EVENTS_CONCISE" ;

  &CountPrev ($event_prev) ;

  if ($real_articles != 0)
  {
#   $articles_over_size1  = sprintf ("%.0f\%",(100 * ($articles_over_size1 / $real_articles))) ;
#   $articles_over_size2 = sprintf ("%.0f\%",(100 * ($articles_over_size2 / $real_articles))) ;
    $mean_versions      = sprintf ("%2.1f",($edits/$real_articles)) ;
    $mean_articlesize   = sprintf ("%5.0f",($real_size/$real_articles)) ;
  }
  else
  {
    $articles_over_size1  = "-" ;
    $articles_over_size2 = "-" ;
    $mean_articlesize   = "-" ;
    $mean_versions      = "-" ;
  }

  if ($real_articles > 0)
  {
    my $distribution = "" ;
    for ($i = 0 ; $i <= $#size_group ; $i++)
    { $distribution .= sprintf ("%.1f", ((100*$size_group [$i])/$real_articles)) . "," ; }
    $distribution =~ s/\,$// ;
    if (($year == $year_dump) && ($month == $month_dump))
    {
      ($day,$month,$year) = (localtime $dumpdate_gm) [3,4,5] ;
       $date_show = sprintf ("%02d/%02d/%04d", $month+1, $day, $year+1900) ;
    }
    else
    {
      $days_passed = days_in_month ($year, $month) ;
      $date_show   = sprintf ("%02d/%02d/%04d", $month, $days_passed, $year) ;
    }

    push @size_distribution, &csv ($language) . &csv ($date_show) . $distribution ;
  }

  my $counts = $real_articles . "," .
               $mean_versions . "," .
               $mean_articlesize . "," .
               $articles_over_size1 . "," .
               $articles_over_size2 . "," .
               $all_size . "," .
               $tot_links . "," .
               $tot_wiki_links . "," .
               $tot_image_links . "," .
               $tot_ext_links . "," .
               $tot_redirects . "," .
               $alternate_articles . "," .
               $tot_words . "," .
 #             $articles_ns10 . "," .
 #             $articles_ns14 . "," .
               $tot_categorized . "," .
               $pages_without_internal_link ;

  return ($counts) ;
}

sub CountPrev
{
  my $event_prev = shift ;

  if (substr ($event_prev,0,4) eq $b4hi2bbb)
  { return ; }

  my $article_type = substr ($event_prev, 9,1) ;

  my $size        = &bbbb2i (substr ($event_prev,10,4)) ;
  my $size2       = &bbbb2i (substr ($event_prev,14,4)) ;
  my $links       = &bb2i   (substr ($event_prev,18,2)) ;
  my $wiki_links  = ord     (substr ($event_prev,20,1)) ;
  my $image_links = ord     (substr ($event_prev,21,1)) ;
  my $cat_links   = ord     (substr ($event_prev,22,1)) ;
  my $ext_links   = ord     (substr ($event_prev,23,1)) ;
  my $words       = &bbb2i  (substr ($event_prev,24,3)) ;
  my $i ;

  if ($article_type eq "R")
  { $tot_redirects++ ; }

  elsif (($article_type eq "+") || ($article_type eq "L") || ($article_type eq "S"))
  {
    for ($s = 32, $i = 0 ; $s < $size2 ; $s *= 2 , $i ++) { ; }
    if ($i > 12) { $i = 12 ; }
    $size_group [$i]++ ;

    if (! $edits_only)
    {
      if ($article_type eq "+") # no redirect, stub or link list
      { $alternate_articles++ ; }
    }
    $real_articles++ ;
    $real_size       += $size2 ; # April 2007 $size -> $size2 = count printable text chars only and multibyte/html chars for one
    $tot_links       += $links ;
    $tot_wiki_links  += $wiki_links ;
    $tot_image_links += $image_links ;
    $tot_ext_links   += $ext_links ;
    $tot_words       += $words ;
    if ($size2 >= 512) # in de pas met size distribution
    { $articles_over_size1 ++ ; }
    if ($size2 >= 4*512)
    { $articles_over_size2 ++ ; }
    if ($cat_links > 0)
    { $tot_categorized ++ ; }
  }

  elsif ($article_type eq "-")
  { $pages_without_internal_link++ ; }

  $all_size += $size ;
}

sub CountArticlesPerNamespacePerMonth
{
  &LogPhase ("CountArticlesPerNamespacePerMonth") ;
  &TraceMem ;

  my ($namespace, $month, $year, $time, $month_edit, $yymm, $m, $counts, $key, $ext, $month_new, %exts, $line) ;

  $month_first = $dumpmonth_ord ;

  foreach $key (keys %new_titles_per_namespace_per_month)
  {
    $year      = substr ($key,0,4) ;
    $month     = substr ($key,4,2) ;
    $namespace = substr ($key,6) ;

    $cnt   = @new_titles_per_namespace_per_month {$key} ;
    $month_new = &bb2i (&yyyymm2bb ($year,$month)) ;

    if ($month_new < $month_first)
    { $month_first = $month_new ; }

    for ($m = $month_new ; $m <= $dumpmonth_ord ; $m++)
    { $articles_per_namespace {"$m-$namespace"}+= $cnt ; }
  }

  &TraceRelease ("Release table \%new_titles_per_namespace_per_month") ;
  undef (%new_titles_per_namespace_per_month) ;

  for ($m = $month_first ; $m <= $dumpmonth_ord ; $m++)
  {
    $counts = "" ;
    for ($ns = 0 ; $ns <= 17 ; $ns += 2)
    { $counts .= &csv ($articles_per_namespace {"$m-$ns"}) ; }
    for ($ns = 100 ; $ns <= 110 ; $ns += 2)
    { $counts .= &csv ($articles_per_namespace {"$m-$ns"}) ; }
    if ($mode eq "ws")
    {
      for ($ns = 200 ; $ns <= 208 ; $ns += 2)
      { $counts .= &csv ($articles_per_namespace {"$m-$ns"}) ; }
    }

    $counts =~ s/,$// ;

    @articles_per_month_per_namespace {&i2yymm ($m)} = $counts ;
  }

  undef (%articles_per_namespace) ;
}

sub CountEditsPerNamespacePerMonth
{
  &LogPhase ("CountEditsPerNamespacePerMonth") ;
  &TraceMem ;

  my ($ns, $counts, $yymm) ;

  $legend = "@," ;
  for ($ns = 0 ; $ns <= 17 ; $ns ++)
  { $legend .= &csv ($ns) ; }
  for ($ns = 100 ; $ns <= 110 ; $ns ++)
  { $legend .= &csv ($ns) ; }
  if ($mode eq "ws")
  {
    for ($ns = 200 ; $ns <= 208 ; $ns ++)
    { $legend .= &csv ($ns) ; }
  }
  $legend =~ s/,$// ;
  $edits_per_month_per_namespace {"0000"} = $legend ;

  # month_first set in CountArticlesPerNamespacePerMonth
  for ($c = 0 ; $c <= 2 ; $c++)
  {
    $usertype = substr ("ABR",$c,1) ; # anon, bot, registered (non bot)

    for ($m = $month_first ; $m <= $dumpmonth_ord ; $m++)
    {
      $yymm = &i2yymm ($m) ;
      $counts = "" ;
      for ($ns = 0 ; $ns <= 17 ; $ns ++)
      { $counts .= &csv ($edits_per_namespace_per_month {"20$yymm$ns$usertype"}) ; }
      for ($ns = 100 ; $ns <= 110 ; $ns ++)
      { $counts .= &csv ($edits_per_namespace_per_month {"20$yymm$ns$usertype"}) ; }
      if ($mode eq "ws")
      {
        for ($ns = 200 ; $ns <= 208 ; $ns ++)
        { $counts .= &csv ($edits_per_namespace_per_month {"20$yymm$ns$usertype"}) ; }
      }

      $counts =~ s/,$// ;

      $edits_per_month_per_namespace {"$yymm$usertype"} = $counts ;
    }
  }
  undef (%edits_per_namespace_per_month) ;
}

sub CountBinariesPerExtensionPerMonth
{
  &LogPhase ("CountBinariesPerExtensionPerMonth") ;
  &TraceMem ;

  my ($key, $month, $year, $ext, $month_new, $month_first, @exts, %exts, $m, $line) ;

  $month_first = $dumpmonth_ord ;

  foreach $key (keys %binaries_per_month)
  {
    $year  = substr ($key,0,4) ;
    $month = substr ($key,4,2) ;
    $ext   = substr ($key,6) ;
    $cnt   = @binaries_per_month {$key} ;

    $month_new = &bb2i (&yyyymm2bb ($year,$month)) ;

    if ($month_new < $month_first)
    { $month_first = $month_new ; }
    # print "\nKEY $key CNT $cnt MONTH_FIRST $month_first, MONTH_NEW $month_new DUMPMONTH_ORD $dumpmonth_ord\n" ;
    for ($m = $month_new ; $m <= $dumpmonth_ord ; $m++)
    { @binaries_per_month {"$m-$ext"} += $cnt ; }
    @exts {$ext}++ ;
  }

  @exts = sort keys %exts ;

# &TraceRelease ("Release table \%binaries_per_month") ;
# undef (%binaries_per_month) ;

  $line = "$language,00/0000," ;
  foreach $ext (@exts)
  { $line .= "$ext," ; }
  $line =~ s/,$// ;
  push @csv_binaries, $line ;

  for ($m = $month_first ; $m <= $dumpmonth_ord ; $m++)
  {
    $line = &csv ($language) . &csv (&bb2mmyyyy (&i2bb ($m))) ;
    foreach $ext (@exts)
    { $line .= &csv (@binaries_per_month {"$m-$ext"}) ; }
    $line =~ s/,$// ;
  # print "\nM $m LINE $line\n" ;
    push @csv_binaries, $line ;
  }

  undef (%binaries_per_month) ;
}

sub CollectActiveUsersPerMonth
{
  &LogPhase ("CollectActiveUsersPerMonth") ;
  &TraceMem ;

  my ($edits, $yymm) ;

  if (! $filesizelarge)
  {
    foreach $yymm_user_nscat (keys %edits_per_user_per_month)
    {
      $edits = $edits_per_user_per_month {$yymm_user_nscat} ;
      ($yymm,$user,$usertype,$nscat) = split (',', $yymm_user_nscat) ;
#     if ($nscat ne "A") { next ; } # for now count only nscat 'A' = namespace a (0 and other 'article' namespaces, depends on wiki)

      for ($t = 0 ; $t < $#thresholds ; $t++)
      {
        $threshold = $thresholds [$t] ;
        if ($edits < $threshold) { last ; }
        $active_users_per_month {"$usertype,$nscat,$threshold,$yymm"} ++ ;
      }
    }
    undef (%edits_per_user_per_month) ;

#   if ($forecast_partial_month)
#   {
#     foreach $key (keys %edits_per_user_per_partial_month)
#     {
#       $edits = $edits_per_user_per_partial_month {$key} ;
#      if ($edits < 5) { next ; }
#       $yymm = substr ($key,0,4) ;
#       @active_users_per_partial_month {"A,5,$yymm"} ++ ;
#       if ($edits < 100) { next ; }
#       @active_users_per_partial_month {"A,100,$yymm"} ++ ;
#     }
#     undef (%edits_per_user_per_partial_month) ;
#   }
  }
  else
  {
    $timestartsort = time ;
    &LogT ("Counting user edits\n") ;
    &TraceMem ;

    foreach $file (sort keys %files_events_user_month)
    {
      ($year, $month) = $file =~ /^.*?(\d\d)-(\d\d)$/ ;
      $yymm = sprintf ("%02d%02d", $year, $month) ;

      open "FILE_USEREDITS", "<", $file ;
      binmode FILE_USEREDITS ;
      while ($user_type_nscat = <FILE_USEREDITS>)
      {
        chomp ($user_type_nscat) ;
        $edits_per_user {$user_type_nscat} ++ ;
      }
      close FILE_USEREDITS ;

      foreach $user_type_nscat (keys %edits_per_user)
      {
        $edits = $edits_per_user {$user_type_nscat} ;

        ($user,$usertype,$nscat) = split (',', $user_type_nscat) ;

        for ($t = 0 ; $t < $#thresholds ; $t++)
        {
          $threshold = $thresholds [$t] ;
          if ($edits < $threshold) { last ; }
          $active_users_per_month {"$usertype,$nscat,$threshold,$yymm"} ++ ;
        }
      }
      undef %edits_per_user ;

      if (&TraceJob)
      {
  #     unlink $file ;
        $file =~ s/^.*[\\\/]// ;
        &LogT ("Count $yymm $file\n") ;
      }
      &TraceMem ($nohashes) ;
    }

#   if ($forecast_partial_month)
#   {
#     foreach $file (sort keys %files_events_user_month_partial)
#     {
#       ($year, $month) = $file =~ /^.*?(\d\d)-(\d\d)$/ ;
#       $yymm = sprintf ("%02d%02d", $year, $month) ;

#       open "FILE_USEREDITS", "<", $file ;
#       binmode FILE_USEREDITS ;
#       while ($user = <FILE_USEREDITS>)
#       {
#         chomp ($user) ;
#         @edits_per_user {$user} ++ ;
#       }
#       close FILE_USEREDITS ;

#       foreach $key (keys %edits_per_user)
#       {
#         $edits = $edits_per_user {$key} ;
#         if ($edits < 5) { next ; }
#         @active_users_per_partial_month {"A,5,$yymm"} ++ ;
#         if ($edits < 100) { next ; }
#         @active_users_per_partial_month {"A,100,$yymm"} ++ ;
#       }
#       undef %edits_per_user ;

#       if (&TraceJob)
#       {
#       # unlink $file ;
#         $file =~ s/^.*[\\\/]// ;
#         &LogT ("Count $yymm $file\n") ;
#       }
#       &TraceMem ($nohashes) ;
#     }
#   }
  }
}

# merge wiki specific files with per user/month/namespace specific edit counts
sub CollectActiveUsersPerMonthsAllWikis
{
  my (@files,  %file_sizes, %file_names, %file_ages, $file_csv_add, $file_csv_from, $file_csv_to, $time_start_step, $time_start_job) ;

  &LogPhase ("CollectActiveUsersPerMonthAllWikis") ;
  &TraceMem ;

  print "Input folder is $path_in\n" ;
  print "Output folder is $path_out\n" ;
  chdir $path_in ;

  # collect basic data for relevant input files, names EditsBreakdownPerUserPerMonthXX.csv (XX language code)
  # cleanup temp files
  @files = <*>;
  foreach $file (@files)
  {
    next if $file !~ /^EditsBreakdownPerUserPerMonth.*?[A-Z]\.csv/ ;
    if ($file =~ /^EditsBreakdownPerUserPerMonth.*?Temp.*?.csv/)
    { unlink $file ; next ; }

   ($wp = $file) =~ s/^EditsBreakdownPerUserPerMonth(.*?)\.csv$/$1/ ;
    $wp = lc $wp ;

    next if $wp eq 'xx' ; # some code for aggregates from earlier
    next if $wp eq 'commons' and $path_in !~ /wx/ ; # leftover in project wikipedia, contains counts for commons as well
    next if $wp eq 'nostalgia' ; # restored and renamed copy of old english wikipedia

    $file_sizes {$wp} = -s $file ;
    $file_names {$wp} = $file ;
    $file_ages  {$wp} = -M $file ;
  }

  # check if 25 largest files are more recent than merged data
  # if not defer merge to later
  if (-e $file_csv_user_month_all_wikis)
  {
    my $file_age_merged_data = -M $file_csv_user_month_all_wikis ;
    my $file_cnt = 0 ;
    foreach $wp (sort { $file_sizes {$b} <=> $file_sizes {$a} } keys %file_sizes)
    {
      if ($file_ages {$wp} > $file_age_merged_data)
      { $file_ages_older .= "$wp (" . sprintf ("%.0f", $file_ages {$wp}). "), " ; }
      last if ++$file_cnt >= 25 ;
    }
    if ($file_ages_older ne '')
    {
      print "\nFor the following 25 largest data files with edits per user/month/namespace are older\n" .
            "than merged file $file_csv_user_month_all_wikis ($file_age_merged_data):\n" . $file_ages_older . ".\nFiles are not ready for merging\n\n" ;
      return ;
    }
  }

  if ($mode eq 'wp')
  { $large_wikis_required_for_merge = 25 ; }
  else
  { $large_wikis_required_for_merge =  3 ; }

  # ok, we will continue to merge
  print "\nAll $large_wikis_required_for_merge largest per wiki data files are more recent than merged data file => time to update merged file.\n" ;
  print "Determine last month of data available for these wikis in StatisticsMonthly.csv.\n\n" ;
  &ReadFileCsv ($file_csv_monthly_stats) ;
  foreach $line (@csv)
  {
    ($wp,$date) = split (',', $line) ;
    $yyyymm = substr ($date,6,4) . '-' . substr ($date,0,2) ;
    $lastmonth {$wp} = $yyyymm ;
  }
  $month_last = '9999-99' ;
  $file_cnt = 0 ;
  print "\n" ;
  foreach $wp (sort { $file_sizes {$b} <=> $file_sizes {$a} } keys %file_sizes)
  {
    next if $wp =~ /^zz+/ ;

    if ($lastmonth {$wp} !~ /^\d\d\d\d-\d\d$/)
    {
      print "$wp: " . $lastmonth {$wp} . "!~ /^\d\d\d\d-\d\d$/\n" ;
      next ;
    }

    if ($lastmonth {$wp} lt $month_last)
    {
      $month_last = $lastmonth {$wp} ;
      print "$wp -> month_last $month_last\n" ;
    }

    print $lastmonth {$wp} . " $wp\n" ;
    last if ++$file_cnt >= $large_wikis_required_for_merge ;
  }
  print "\nDiscard data beyond month $month_last (last month where top $large_wikis_required_for_merge wikis are up to date).\n\n" ;

  # sort files by size, then from smallest to largest merge one at a time
  # in merge routine prep each file
  $time_start_job = time ;
  unlink $file_csv_user_month_all_wikis ;
  my $files_merged = 0 ;
  $file_csv_from = 'none' ;

  # merge all language specific files, starting with the smallest
  # resulting file contains edit counts per user per month for all relevant ~'article' namespaces (usually 0 only)
  # two counts: one for full month, one for first 28 days (for fair comparison of consecutive months)
  # example
  # Amirobot,2011-06,14,14
  # Amirobot,2011-07,6,6
  # Amirobot,2011-08,4,4
  # Amirobot,2011-09,3,1

  open FILE_CSV_WLM, '>', $file_csv_wiki_loves_monuments ; # wlm = Wiki Loves Monuments

  print "\n" ;
  foreach $wp (sort { $file_sizes {$a} <=> $file_sizes {$b} } keys %file_sizes)
  {
    # next if $wp eq 'commons' ; # do not merge in yet 

    # next if $wp !~ /^(?:ab|ak)$/ ; # test only, use few files for speed
    # next if $wp !~ /^a/ ; # test only, use few files for speed

    $file_csv_add = $file_names {$wp} ;
    $file_csv_to  = $file_csv_user_month_all_wikis ;
    $file_csv_to  =~ s/\.csv/"Temp_" . ($files_merged++). uc ("_$wp") . ".csv"/e ;

    $time_start_step = time ;
    print "Merge\n$file_csv_add \&\n$file_csv_from=>\n$file_csv_to\n\n" ;

    &MergeActiveUsersPerMonthsAllWikisOrProjects ($wp, $file_csv_add, $file_csv_from, $file_csv_to, ($merge_namespaces = $true), $month_last) ;

    $file_size_add  = sprintf ("%.1f", (-s $file_csv_add)  / 1000000) . 'Mb' ;
    $file_size_from = sprintf ("%.1f", (-s $file_csv_from) / 1000000) . 'Mb' ;
    $file_size_to   = sprintf ("%.1f", (-s $file_csv_to)   / 1000000) . 'Mb' ;

    print "Merge in " .  ddhhmmss (time - $time_start_job) . " / " .ddhhmmss (time - $time_start_step) . ": $file_size_add \& $file_size_from => $file_size_to\n\n" ;

    $file_csv_from = $file_csv_to ;
  }

  close FILE_CSV_WLM ;

  # rename resulting file to EditsBreakdownPerUserPerMonthAllWikis.csv
  print "Rename $file_csv_to to $file_csv_user_month_all_wikis\n" ;
  print "All files merged\n\n" ;

# rename $file_csv_to, $file_csv_user_month_all_wikis ;
# for tests copy rather than rename
  open IN,  '<', $file_csv_to ;
  open OUT, '>', $file_csv_user_month_all_wikis ;
  binmode IN ;
  binmode OUT ;
  while ($line = <IN>)
  { print OUT $line ; }
  close IN ;
  close OUT ;

  # threshold starting with a 3 are 10xSQRT(10), 100xSQRT(10), 1000xSQRT(10), etc
  @thresholds = (1,3,5,10,25,32,50,100,250,316,500,1000,2500,3162,5000,10000,25000,31623,50000,100000,250000,316228,500000,1000000,2500000,3162278,500000,10000000,25000000,31622777,5000000,100000000) ;

  # now read back EditsBreakdownPerUserPerMonthAllWikis.csv
  # aggregate edits per user/month to hash files: editors per month with x+ edits (x = many levels)
  # (again full month and first 28 days)
  open FILE_CSV_ALL, '<', $file_csv_user_month_all_wikis ;
  $line = <FILE_CSV_ALL> ; # skip comment line
  $line = <FILE_CSV_ALL> ; # skip comment line
  while ($line = <FILE_CSV_ALL>)
  {
    chomp $line ;
    next while $line =~ /^\s*$/ ;

    ($user,$month,$edits,$edits_28) = split (',', $line) ;

    $yyyy = substr ($month,0,4) ;
    $mm   = substr ($month,5,2) ;
    if (($yyyy !~ /20\d\d$/) || ($mm !~ /^\d\d$/) || ($mm < 1 ) || ($mm > 12))
    { print "\nSkip invalid month '$yyyy $mm' <- '$month'\n" ; next ; }

    for ($t = 0 ; $t < $#thresholds ; $t++)
    {
      $threshold = $thresholds [$t] ;

      # if ($bots {$user} == 0)
      # counts bots separately (again test for implicit bot names, as $file_csv_bots_all is not fully built yet)
      if (($bots {$user} == 0) && ($user !~ /bot\b/i) && ($user !~ /_bot_/i)) # name(part) ends on bot,
      {
        if ($edits >= $threshold)
        { $active_users_per_month_all_wikis {$month} {$threshold} ++ ; }
        if ($edits_28 >= $threshold)
        { $active_users_per_month_all_wikis_28 {$month} {$threshold} ++ ; }
      }
      else
      {
        if ($edits >= $threshold)
        { $active_bots_per_month_all_wikis {$month} {$threshold} ++ ; }
        if ($edits_28 >= $threshold)
        { $active_bots_per_month_all_wikis_28 {$month} {$threshold} ++ ; }
      }

      if ($edits < $threshold) { last ; } # edits_28 always <= $edits
    }
  }

  # now store these activity levels, per month for all languages,
  # to existing file StatisticsUserActivitySpread.csv with activity levels per language (written in UpdateMonthlyStats)
  # like always use code 'zz' for overall totals
  # add counts for registered users edting articles only (only 'R,A,' = registered 'users,articles')
  # (language specific counts also for 'B,..,' for bots, '..,T,' for talk pages, '..,O,' for other pages)
  # example
  # zz,09/30/2011,R,A,49,26,21,15,6,5,2
  # zz,06/30/2011,R,A,45,31,20,13,8,7,3,1
  print "\nUpdate file $file_csv_users_activity_spread, code 'zz'\n" ;
  $language = 'zz' ;
  &ReadFileCsv ($file_csv_users_activity_spread) ;

  foreach $month (sort keys %active_users_per_month_all_wikis_28) # active_users_per_month_all_wikis_28 is more inclusive than active_users_per_month_all_wikis
  {
    $yyyy     = substr ($month,0,4) ;
    $mm       = substr ($month,5,2) ;

    if ("$yyyy-$mm" gt $month_last)
    {
      print "zz discard data for $yyyy-$mm\n" ;
      next ;
    }

    if (($yyyy !~ /20\d\d$/) || ($mm !~ /^\d\d$/) || ($mm < 1 ) || ($mm > 12))
    {
      print "\ninvalid month '$yyyy $mm' <- '$month'\n" ;
      next ;
    }


    $dd       = days_in_month ($yyyy, $mm) ;
    $ddmmyyyy = sprintf ("%02d/%02d/%04d", $mm, $dd, $yyyy) ;

    $line  = "$language,$ddmmyyyy,R,A," ; # R=registered users, A=article namespaces
    for ($t = 0 ; $t < $#thresholds ; $t++)
    {
      $threshold = $thresholds [$t] ;
      last if $active_users_per_month_all_wikis {$month} {$threshold} == 0 ;
      $line .= $active_users_per_month_all_wikis {$month} {$threshold} . ',' ;
    }
    $line =~ s/,$// ;
    push @csv, $line ;
  }
  &WriteFileCsv ($file_csv_users_activity_spread) ;

  # now repeat the process, but only consider edits in first 28 days of month
  # use new code 'zz28'
  print "\nUpdate file $file_csv_users_activity_spread, code 'zz28' (edits for first 28 days of each month)\n" ;
  $language = 'zz28' ;
  &ReadFileCsv ($file_csv_users_activity_spread) ;
  foreach $month (sort keys %active_users_per_month_all_wikis_28)
  {
    $yyyy     = substr ($month,0,4) ;
    $mm       = substr ($month,5,2) ;
    $dd       = days_in_month ($yyyy, $mm) ;
    $ddmmyyyy = sprintf ("%02d/%02d/%04d", $mm, $dd, $yyyy) ;

    if ("$yyyy-$mm" gt $month_last)
    {
      print "zz28 discard data for $yyyy-$mm\n" ;
      next ;
    }

    $line  = "$language,$ddmmyyyy,R,A," ; # R=registered users, A=article namespaces
    for ($t = 0 ; $t < $#thresholds ; $t++)
    {
      $threshold = $thresholds [$t] ;
      last if $active_users_per_month_all_wikis_28 {$month} {$threshold} == 0 ;
      $line .= $active_users_per_month_all_wikis_28 {$month} {$threshold} . ',' ;
    }
    $line =~ s/,$// ;
    push @csv, $line ;
  }
  &WriteFileCsv ($file_csv_users_activity_spread) ;
}

sub CollectActiveUsersPerMonth
{
  &LogPhase ("CollectActiveUsersPerMonth") ;
  &TraceMem ;

  # count user with over x edits
  # threshold starting with a 3 are 10xSQRT(10), 100xSQRT(10), 1000xSQRT(10), etc
  @thresholds = (1,3,5,10,25,32,50,100,250,316,500,1000,2500,3162,5000,10000,25000,31623,50000,100000,250000,316228,500000,1000000,2500000,3162278,500000,10000000,25000000,31622777,5000000,100000000) ;

  my ($edits, $yymm) ;

  if (! $filesizelarge)
  {
    foreach $yymm_user_nscat (keys %edits_per_user_per_month)
    {
      $edits = $edits_per_user_per_month {$yymm_user_nscat} ;
      ($yymm,$user,$usertype,$nscat) = split (',', $yymm_user_nscat) ;
#     if ($nscat ne "A") { next ; } # for now count only nscat 'A' = namespace a (0 and other 'article' namespaces, depends on wiki)

      for ($t = 0 ; $t < $#thresholds ; $t++)
      {
        $threshold = $thresholds [$t] ;
        if ($edits < $threshold) { last ; }
        $active_users_per_month {"$usertype,$nscat,$threshold,$yymm"} ++ ;
      }
    }
    undef (%edits_per_user_per_month) ;

#   if ($forecast_partial_month)
#   {
#     foreach $key (keys %edits_per_user_per_partial_month)
#     {
#       $edits = $edits_per_user_per_partial_month {$key} ;
#      if ($edits < 5) { next ; }
#       $yymm = substr ($key,0,4) ;
#       @active_users_per_partial_month {"A,5,$yymm"} ++ ;
#       if ($edits < 100) { next ; }
#       @active_users_per_partial_month {"A,100,$yymm"} ++ ;
#     }
#     undef (%edits_per_user_per_partial_month) ;
#   }
  }
  else
  {
    $timestartsort = time ;
    &LogT ("Counting user edits\n") ;
    &TraceMem ;

    foreach $file (sort keys %files_events_user_month)
    {
      ($year, $month) = $file =~ /^.*?(\d\d)-(\d\d)$/ ;
      $yymm = sprintf ("%02d%02d", $year, $month) ;

      open "FILE_USEREDITS", "<", $file ;
      binmode FILE_USEREDITS ;
      while ($user_type_nscat = <FILE_USEREDITS>)
      {
        chomp ($user_type_nscat) ;
        $edits_per_user {$user_type_nscat} ++ ;
      }
      close FILE_USEREDITS ;

      foreach $user_type_nscat (keys %edits_per_user)
      {
        $edits = $edits_per_user {$user_type_nscat} ;

        ($user,$usertype,$nscat) = split (',', $user_type_nscat) ;

        for ($t = 0 ; $t < $#thresholds ; $t++)
        {
          $threshold = $thresholds [$t] ;
          if ($edits < $threshold) { last ; }
          $active_users_per_month {"$usertype,$nscat,$threshold,$yymm"} ++ ;
        }
      }
      undef %edits_per_user ;

      if (&TraceJob)
      {
  #     unlink $file ;
        $file =~ s/^.*[\\\/]// ;
        &LogT ("Count $yymm $file\n") ;
      }
      &TraceMem ($nohashes) ;
    }

#   if ($forecast_partial_month)
#   {
#     foreach $file (sort keys %files_events_user_month_partial)
#     {
#       ($year, $month) = $file =~ /^.*?(\d\d)-(\d\d)$/ ;
#       $yymm = sprintf ("%02d%02d", $year, $month) ;

#       open "FILE_USEREDITS", "<", $file ;
#       binmode FILE_USEREDITS ;
#       while ($user = <FILE_USEREDITS>)
#       {
#         chomp ($user) ;
#         @edits_per_user {$user} ++ ;
#       }
#       close FILE_USEREDITS ;

#       foreach $key (keys %edits_per_user)
#       {
#         $edits = $edits_per_user {$key} ;
#         if ($edits < 5) { next ; }
#         @active_users_per_partial_month {"A,5,$yymm"} ++ ;
#         if ($edits < 100) { next ; }
#         @active_users_per_partial_month {"A,100,$yymm"} ++ ;
#       }
#       undef %edits_per_user ;

#       if (&TraceJob)
#       {
#       # unlink $file ;
#         $file =~ s/^.*[\\\/]// ;
#         &LogT ("Count $yymm $file\n") ;
#       }
#       &TraceMem ($nohashes) ;
#     }
#   }
  }
}

# merge files generated in CollectActiveUsersPerMonthsAllWikis for al projects
# based on CollectActiveUsersPerMonthsAllWikis (some more common code to be split off)
sub CollectActiveUsersPerMonthAllProjects
{
  my (@files, %file_sizes, %file_names, %file_ages, $file_csv_add, $file_csv_from, $file_csv_to, $time_start_step, $time_start_job) ;

  &LogPhase ("CollectActiveUsersPerMonthAllProjects") ;
  &TraceMem ;


  chdir $path_in ;
  chdir ".." ;

  print "Input folder is " . cwd () . "\n" ;
  print "Output folder is " . cwd () . "/csv_wp\n" ;

  foreach $wp (qw (wb wk wn wo wp wq ws wv wx))
  {
    $file = "csv_$wp/EditsBreakdownPerUserPerMonthAllWikis.csv" ;
    $file_sizes {$wp} = -s $file ;
    $file_names {$wp} = $file ;
    $file_ages  {$wp} = -M $file ;
  }

$qqq = $true ; # disable code during tests to speed up
if ($qqq)
{
  # check if any input file is more recent than merged data
  # if not defer merge to later
  $file_age_low = 9999 ;
  if (-e $file_csv_user_month_all_projects)
  {
    foreach $wp (keys %file_sizes)
    {
      if (-e $file_names {$wp} && ($file_ages {$wp} < $file_age_low))
      { $file_age_low = $file_ages {$wp} ; }
    }

    my $file_age_merged_data = -M $file_csv_user_month_all_projects ;
    if ($file_age_low > $file_age_merged_data)
    {
      print "\nMerged project counts is more recent than any csv_../EditsBreakdownPerUserPerMonthAllWikis.csv. No need to merge.\n" ;
      return ;
    }
  }

  # ok, we will continue to merge
  print "\nOne or more ..AllWikis.csv is newer, merge all into ..AllProjects.csv.\n\n" ;

  # sort files by size, then from smallest to largest merge one at a time
  # in merge routine prep each file
  $time_start_job = time ;
  unlink $file_csv_user_month_all_projects ;
  my $files_merged = 0 ;
  $file_csv_from = 'none' ;

  # merge all language specific files, starting with the smallest
  # resulting file contains edit counts per user per month for all relevant ~'article' namespaces (usually 0 only)
  # two counts: one for full month, one for first 28 days (for fair comparison of consecutive months)
  # example
  # Amirobot,2011-06,14,14
  # Amirobot,2011-07,6,6
  # Amirobot,2011-08,4,4
  # Amirobot,2011-09,3,1

  print "\n" ;
  foreach $wp (sort { $file_sizes {$a} <=> $file_sizes {$b} } keys %file_sizes)
  {
    if (! -e $file_names {$wp})
    {
      print "File not found " . $file_names {$wp} . "\n" ;
      next ;
    }

    $file_csv_add = $file_names {$wp} ;
    $file_csv_to  = $file_csv_user_month_all_projects ;
    $file_csv_to  =~ s/\.csv/"Temp_" . ($files_merged++). uc ("_$wp") . ".csv"/e ;

    $time_start_step = time ;
    print "Merge\n$file_csv_add \&\n$file_csv_from=>\n$file_csv_to\n\n" ;

    &MergeActiveUsersPerMonthsAllWikisOrProjects ($wp, $file_csv_add, $file_csv_from, $file_csv_to, ($merge_namespaces = $false)) ;

    $file_size_add  = sprintf ("%.1f", (-s $file_csv_add)  / 1000000) . 'Mb' ;
    $file_size_from = sprintf ("%.1f", (-s $file_csv_from) / 1000000) . 'Mb' ;
    $file_size_to   = sprintf ("%.1f", (-s $file_csv_to)   / 1000000) . 'Mb' ;

    print "Merge in " .  ddhhmmss (time - $time_start_job) . " / " .ddhhmmss (time - $time_start_step) . ": $file_size_add \& $file_size_from => $file_size_to\n\n" ;

    $file_csv_from = $file_csv_to ;
  }

  # rename resulting file to EditsBreakdownPerUserPerMonthAllProjects.csv
  print "Rename $file_csv_to to $file_csv_user_month_all_projects\n" ;
  print "All files merged\n\n" ;
  rename $file_csv_to, $file_csv_user_month_all_projects ;

  undef %active_users_per_month_all_wikis ;
  undef %active_users_per_month_all_wikis_28 ;
  undef %active_bots_per_month_all_wikis ;
  undef %active_bots_per_month_all_wikis_28 ;

  # again merge with Commons, add namespace 6 edits (file uploads) as new columns
  # all usernames and months should already be in FILE_CSV_ALL

  $file_csv_commons   = "csv_wx/EditsBreakdownPerUserPerMonthCOMMONS.csv" ;
  $file_csv_commons_6 = "csv_wx/EditsBreakdownPerUserPerMonthCOMMONS_NS6.csv" ;

  abort ("$file_csv_commons missing!") if ! -e $file_csv_commons ;

  open COMMONS,  '<', $file_csv_commons ;
  open COMMONS6, '>', $file_csv_commons_6 ;
  binmode COMMONS ;
  binmode COMMONS6 ;

  while ($line = <COMMONS>)
  {
    chomp $line ;
    ($user,$month,$namespace,$edit,$edits28) = split (',', $line) ;
    next if $namespace != 6 ;
    $line = "$user,$month,$edit,$edits28" ;
    print COMMONS6 "$line\n" ;
  }
  close COMMONS ;
  close COMMONS6 ;
}

  ($file_csv_user_month_all_projects_edits_uploads = $file_csv_user_month_all_projects) =~ s/\.csv/_EditsUploads.csv/ ;
  ($file_csv_commons_only = $file_csv_commons_6) =~ s/\.csv/_Only.csv/ ;
  $file_csv_commons   = "csv_wx/EditsBreakdownPerUserPerMonthCOMMONS.csv" ;
  $file_csv_commons_6 = "csv_wx/EditsBreakdownPerUserPerMonthCOMMONS_NS6.csv" ;

  abort ("$file_csv_commons_6 missing!")               if ! -e $file_csv_commons_6 ;
  abort ("$file_csv_user_month_all_projects missing!") if ! -e $file_csv_user_month_all_projects ;

  open FILE_CSV_COMMONS,      '<', $file_csv_commons_6 ;
  open FILE_CSV_ALL,          '<', $file_csv_user_month_all_projects ;
  open FILE_CSV_ALL6,         '>', $file_csv_user_month_all_projects_edits_uploads ;
  open FILE_CSV_COMMONS_ONLY, '>', $file_csv_commons_only ;

  binmode FILE_CSV_COMMONS ;
  binmode FILE_CSV_COMMONS_ONLY ;
  binmode FILE_CSV_ALL ;
  binmode FILE_CSV_ALL6 ;

  $line_all = <FILE_CSV_ALL> ;
  while ($line_all =~ /^#/) # copy comments
  { $line_all = <FILE_CSV_ALL> ; }

  $line_commons = <FILE_CSV_COMMONS> ;
  while ($line_commons =~ /^#/) # skip comments
  { $line_commons = <FILE_CSV_COMMONS> ; }

  print FILE_CSV_ALL6 "# user, month, edits in whole month, edits in first 28 days, uploads, uploads in first 28 days\n" ;
  print FILE_CSV_ALL6 "# first 28 days for normalized trends with equal length partial months\n" ;
  print FILE_CSV_ALL6 "# edits includes uploads, uploads also added a separate columns for other metric\n" ;

  chomp $line_all ;
  chomp $line_commons ;

  ($user_all,     $month_all,     $edits,   $edits_28)   = split (',', $line_all) ;
  ($user_commons, $month_commons, $uploads, $uploads_28) = split (',', $line_commons) ;

  $edits      =~ s/ //g ;
  $edits_28   =~ s/ //g ;
  $uploads    =~ s/ //g ;
  $uploads_28 =~ s/ //g ;

  while ($line_all)
  {
    # note alphabetic sort of csv file puts "X 1" before "X" because in reality sort sees "X 1,etc" and "X,etc"
    while (("$user_all," gt "$user_commons,") || (($user_all eq $user_commons) && ($month_all gt $month_commons)) && ($line_commons))
    {
      if (($user_commons ne $user_all_prev) || ($month_commons ne $month_all_prev)) # only anons and bots should be missing from FILE_CSV_ALL
      {
        if ($user_commons !~ /^[0-9\.]*$/)
        { print FILE_CSV_COMMONS_ONLY "$line_commons\n" ; }
      }

      $line_commons = <FILE_CSV_COMMONS> ;
      last if ! $line_commons ;
      chomp $line_commons ;
      ($user_commons, $month_commons, $uploads, $uploads_28) = split (',', $line_commons) ;

      $uploads    =~ s/ //g ;
      $uploads_28 =~ s/ //g ;
#print "line_commons $line_commons\n" ;
    }

    if (($user_all eq $user_commons) && ($month_all eq $month_commons))
    {
      print FILE_CSV_ALL6 "$user_all,$month_all,$edits,$edits_28,$uploads, $uploads_28\n" ;
#print "line_all > $user_all,$month_all,$edits,$edits_28,$uploads, $uploads_28\n" ;
    }
    else
    {
      print FILE_CSV_ALL6 "$user_all,$month_all,$edits,$edits_28,0,0\n" ;
#print "line_all6 > $user_all,$month_all,$edits,$edits_28,0,0\n" ;
    }

    $user_all_prev  = $user_all ;
    $month_all_prev = $month_all ;

    $line_all = <FILE_CSV_ALL> ;
    chomp $line_all ;
    ($user_all, $month_all, $edits, $edits_28) = split (',', $line_all) ;
#print "line_all $line_all\n" ;

    $edits    =~ s/ //g ;
    $edits_28 =~ s/ //g ;
  }

  if (($user_commons ne $user_all_prev) || ($month_commons ne $month_all_prev) && ($line_commons))
  { print FILE_CSV_COMMONS_ONLY "$line_commons\n" ; }
  while ($line_commons)
  {
    $line_commons = <FILE_CSV_COMMONS> ;
    last if ! $line_commons ;
    print FILE_CSV_COMMONS_ONLY "$line_commons\n" ;
  }

  close FILE_CSV_COMMONS ;
  close FILE_CSV_COMMONS_ONLY ;
  close FILE_CSV_ALL ;
  close FILE_CSV_ALL6 ;

  # threshold starting with a 3 are 10xSQRT(10), 100xSQRT(10), 1000xSQRT(10), etc
  @thresholds = (1,3,5,10,25,32,50,100,250,316,500,1000,2500,3162,5000,10000,25000,31623,50000,100000,250000,316228,500000,1000000,2500000,3162278,500000,10000000,25000000,31622777,5000000,100000000) ;

  # now read back EditsBreakdownPerUserPerMonthAllProjects.csv
  # aggregate edits per user/month to hash files: editors per month with x+ edits (x = many levels)
  # (again full month and first 28 days)
  open FILE_CSV_ALL, '<', $file_csv_user_month_all_projects_edits_uploads ;
  $line = <FILE_CSV_ALL> ; # skip comment line
  $line = <FILE_CSV_ALL> ; # skip comment line
  while ($line = <FILE_CSV_ALL>)
  {
    chomp $line ;
    next while $line =~ /^\s*$/ ;

    ($user,$month,$edits,$edits_28,$uploads,$uploads_28) = split (',', $line) ;

    $yyyy = substr ($month,0,4) ;
    $mm   = substr ($month,5,2) ;
    if (($yyyy !~ /20\d\d$/) || ($mm !~ /^\d\d$/) || ($mm < 1 ) || ($mm > 12))
    { print "\nSkip invalid month '$yyyy $mm' <- '$month'\n" ; next ; }

    for ($t = 0 ; $t < $#thresholds ; $t++)
    {
      $threshold = $thresholds [$t] ;
      # if ($bots {$user} == 0)
      # counts bots separately (again test for implicit bot names, as $file_csv_bots_all is not fully built yet)
      if (($bots {$user} == 0) && ($user !~ /bot\b/i) && ($user !~ /_bot_/i)) # name(part) ends on bot,
      {
        if ($edits >= $threshold)
        { $active_users_per_month_all_wikis {$month} {$threshold} ++ ; }
        if ($edits_28 >= $threshold)
        { $active_users_per_month_all_wikis_28 {$month} {$threshold} ++ ; }

        # now count again and value one uploads a 5 edits
        # every upload was already counted so add four-fold
        if ($edits + 4 * $uploads>= $threshold)
        { $active_users_per_month_all_wikis_edits_uploads {$month} {$threshold} ++ ; }
        if ($edits_28 + 4 * $uploads_28 >= $threshold)
        { $active_users_per_month_all_wikis_edits_uploads_28 {$month} {$threshold} ++ ; }
      }
      else
      {
        if ($edits >= $threshold)
        { $active_bots_per_month_all_wikis {$month} {$threshold} ++ ; }
        if ($edits_28 >= $threshold)
        { $active_bots_per_month_all_wikis_28 {$month} {$threshold} ++ ; }
      }

      if ($edits < $threshold) { last ; } # edits_28 always <= $edits
    }
  }

  # now store these activity levels, per month for all languages,
  # to existing file StatisticsUserActivitySpread.csv with activity levels per language (written in UpdateMonthlyStats)
  # like always use code 'zz' for overall totals
  # add counts for to  (only 'R,A,' = registered 'users,articles')
  # language specific counts also for 'B,..,' for bots, '..,T,' for talk pages, '..,O,' for other pages)
  # example
  # zz,09/30/2011,R,A,49,26,21,15,6,5,2
  # zz,06/30/2011,R,A,45,31,20,13,8,7,3,1

  print "\nUpdate file $file_csv_users_activity_spread_all, code 'zz'\n" ;
  $language = 'zz' ;
  &ReadFileCsv ($file_csv_users_activity_spread_all) ;
  foreach $month (sort keys %active_users_per_month_all_wikis_28) # active_users_per_month_all_wikis_28 is more inclusive than active_users_per_month_all_wikis
  {
    $yyyy     = substr ($month,0,4) ;
    $mm       = substr ($month,5,2) ;

    next if ($yyyy !~ /20\d\d$/) || ($mm !~ /^\d\d$/) || ($mm < 1 ) || ($mm > 12) ; # 2 lines will be rejected

    $dd       = days_in_month ($yyyy, $mm) ;
    $ddmmyyyy = sprintf ("%02d/%02d/%04d", $mm, $dd, $yyyy) ;

    $line  = "$language,$ddmmyyyy,R,A," ; # R=registered users, A=article namespaces
    for ($t = 0 ; $t < $#thresholds ; $t++)
    {
      $threshold = $thresholds [$t] ;
      last if $active_users_per_month_all_wikis {$month} {$threshold} == 0 ;
      $line .= $active_users_per_month_all_wikis {$month} {$threshold} . ',' ;
    }
    $line =~ s/,$// ;
    push @csv, $line ;
  }
  &WriteFileCsv ($file_csv_users_activity_spread_all) ;

  # again, but now use code 'zz28' for totals for first 28 days of each month

  print "\nUpdate file $file_csv_users_activity_spread_all, code 'zz28' (edits for first 28 days of each month)\n" ;
  $language = 'zz28' ;
  &ReadFileCsv ($file_csv_users_activity_spread_all) ;
  foreach $month (sort keys %active_users_per_month_all_wikis_28)
  {
    $yyyy     = substr ($month,0,4) ;
    $mm       = substr ($month,5,2) ;
    $dd       = days_in_month ($yyyy, $mm) ;
    $ddmmyyyy = sprintf ("%02d/%02d/%04d", $mm, $dd, $yyyy) ;

    $line  = "$language,$ddmmyyyy,R,A," ; # R=registered users, A=article namespaces
    for ($t = 0 ; $t < $#thresholds ; $t++)
    {
      $threshold = $thresholds [$t] ;
      last if $active_users_per_month_all_wikis_28 {$month} {$threshold} == 0 ;
      $line .= $active_users_per_month_all_wikis_28 {$month} {$threshold} . ',' ;
    }
    $line =~ s/,$// ;
    push @csv, $line ;
  }
  &WriteFileCsv ($file_csv_users_activity_spread_all) ;

  print "\nUpdate file $file_csv_users_activity_spread_all, code 'zzw'\n" ;
  $language = 'zzw' ; # zz for all languages, w for edits and uploads weighed (one upload is five edits)
  &ReadFileCsv ($file_csv_users_activity_spread_all) ;
  foreach $month (sort keys %active_users_per_month_all_wikis_28) # active_users_per_month_all_wikis_28 is more inclusive than active_users_per_month_all_wikis
  {
    $yyyy     = substr ($month,0,4) ;
    $mm       = substr ($month,5,2) ;

    next if ($yyyy !~ /20\d\d$/) || ($mm !~ /^\d\d$/) || ($mm < 1 ) || ($mm > 12) ; # 2 lines will be rejected

    $dd       = days_in_month ($yyyy, $mm) ;
    $ddmmyyyy = sprintf ("%02d/%02d/%04d", $mm, $dd, $yyyy) ;

    $line  = "$language,$ddmmyyyy,R,A," ; # R=registered users, A=article namespaces
    for ($t = 0 ; $t < $#thresholds ; $t++)
    {
      $threshold = $thresholds [$t] ;
      last if $active_users_per_month_all_wikis_edits_uploads {$month} {$threshold} == 0 ;
      $line .= $active_users_per_month_all_wikis_edits_uploads {$month} {$threshold} . ',' ;
    }
    $line =~ s/,$// ;
    push @csv, $line ;
  }
  &WriteFileCsv ($file_csv_users_activity_spread_all) ;

  # again, but now use code 'zz28' for totals for first 28 days of each month

  print "\nUpdate file $file_csv_users_activity_spread_all, code 'zzw28' (edits for first 28 days of each month)\n" ;
  $language = 'zzw28' ; # zz for all languages, w for edits and uploads weighed, 28 for first 28 days
  &ReadFileCsv ($file_csv_users_activity_spread_all) ;
  foreach $month (sort keys %active_users_per_month_all_wikis_28)
  {
    $yyyy     = substr ($month,0,4) ;
    $mm       = substr ($month,5,2) ;
    $dd       = days_in_month ($yyyy, $mm) ;
    $ddmmyyyy = sprintf ("%02d/%02d/%04d", $mm, $dd, $yyyy) ;

    $line  = "$language,$ddmmyyyy,R,A," ; # R=registered users, A=article namespaces
    for ($t = 0 ; $t < $#thresholds ; $t++)
    {
      $threshold = $thresholds [$t] ;
      last if $active_users_per_month_all_wikis_edits_uploads_28 {$month} {$threshold} == 0 ;
      $line .= $active_users_per_month_all_wikis_edits_uploads_28 {$month} {$threshold} . ',' ;
    }
    $line =~ s/,$// ;
    push @csv, $line ;
  }
  &WriteFileCsv ($file_csv_users_activity_spread_all) ;

}

sub CountActiveWikisPerMonthAllProjects 
{
  &LogPhase ("CountActiveWikisPerMonthAllProjects") ;

  chdir $path_in ;
  chdir ".." ;

  print "Input folder is " . cwd () . "\n" ;
  print "Output folder is " . cwd () . "/csv_wp\n" ;

  my $filename_csv_in  = "StatisticsUserActivitySpread.csv" ;
# my $file_out_sorted = $file_out ;
# $file_out_sorted =~ s/\.csv/_sorted.csv/ ;

  my (%active_wikis, %dates, 
      $count_5, $count_100, 
      $date,$dd,$mm,$yyyy,
      $wp, $reguser_bot, $ns_group, $counts, @counts) ;

  foreach $project (qw (wb wk wn wo wp wq ws wv wx))
  {
    my $file = cwd () . "/csv_$project/$filename_csv_in" ;
    open CSV_IN, '<', $file ;
    binmode CSV_IN ;
    while ($line = <CSV_IN>)
    {
      next if $line =~ /^#/ ; 

      chomp ($line) ;
      my ($wp, $date, $reguser_bot, $ns_group, $counts) = split (",", $line,5) ;
      next if $wp =~ /^zz/ ;        # totals for all languages
      next if $reguser_bot ne "R" ; # R: registered user, B: bot
      next if $ns_group    ne "A" ; # A: articles, T: talk pages, O: other
      
      # why those strange levels 3, 32, 316, 3162, etc?
      # these are SQRT(10), 10xSQRT(10), 100xSQRT(10), 1000xSQRT(10),
      # for finer evenly spaced level in charts (316/100 is 1000/316)
      # thresholds =1,3,5,10,25,32,50,100,250,316,500,1000,2500,3162,5000,10000,25000,31623,50000,100000,etc
      
      @counts = split (',', $counts) ;
      $count_5   = $counts [2] ;

      $mm   = substr ($date,0,2) ;
      $dd   = substr ($date,3,2) ;
      $yyyy = substr ($date,6,4) ;
      $date = sprintf ("%04d%02d%02d",$yyyy,$mm,$dd) ; # dd/mm/yyyy -> yyyy/mm/dd

      next if $dd != days_in_month ($yyyy,$mm) ; # incomplete month
      next if $count_5 == 0 ;                    # nothing to count

      if ($yyyy == 2001)                                                            # did wp:ar and wp:zh really start Jan 2001? Don't think so.  
      { print "[$line] project:$project date:$date 5:$count_5 100:$count_100\n" ; } # we need to screen for these outliers and remove them from stats. 

      $active_wikis {"1,$project,$date"} ++ ; 
      $active_wikis {"1,*,$date"} ++ ; 
      if ($count_5 >= 5) 
      { 
        $active_wikis {"5,$project,$date"} ++ ; 
        $active_wikis {"5,*,$date"} ++ ; 
      }

      $dates {$date} ++ ;
    }
    close CSV_IN ;
  }
  
  my $filename_csv_out = "ActiveWikisPerProject.csv" ;
  my $file_out = cwd () . "/csv_mw/$filename_csv_out" ;
  
  open CSV_OUT, '>', $file_out ;
  binmode CSV_OUT ;
  print CSV_OUT "# date,project (wb=wikibooks;wk=wiktionary;wn=wikinews;wo=wikivoyage;wp=wikipedia;wq=wikiquote;ws=wikisource;wv=wikiversity;wx=wikispecial),wikis with at least one active editor (5+ edits),wikis with at least five active editors (5+ edits)\n" ; 
  
  foreach $date (sort keys %dates)
  {
    my $date2 = substr ($date,4,2) . '/' . substr ($date,6,2) . '/'  . substr ($date,0,4) ; # yyyymmdd -> dd/mm/yyyy
    foreach $project (qw (wb wk wn wo wp wq ws wv wx))
    {
      next if $active_wikis {"1,$project,$date"} == 0 ;
      print CSV_OUT "$date2,$project," . (0 + $active_wikis {"1,$project,$date"}) . ',' .  (0 + $active_wikis {"5,$project,$date"}) . "\n" ;
    }
  }

  close CSV_OUT ;

  my $filename_csv_out = "ActiveWikisPerProjectExcel.csv" ;
  my $file_out = cwd () . "/csv_mw/$filename_csv_out" ;
  
  open CSV_OUT, '>', $file_out ;
  binmode CSV_OUT ;
  print CSV_OUT "1+ active editors,,,,,,,,,,,," ; 
  print CSV_OUT "5+ active editors\n" ; 
  print CSV_OUT "date,Total,Wikibooks,Wikinews,Wikipedia,Wikiquote,Wikisource,Wikiversity,Wikivoyage,Wiktionary,Other projects,," ; 
  print CSV_OUT "date,Total,Wikibooks,Wikinews,Wikipedia,Wikiquote,Wikisource,Wikiversity,Wikivoyage,Wiktionary,Other projects\n" ; 
  
  foreach $date (sort keys %dates)
  {
    my $date_excel = "\"=date(" . substr ($date,0,4) . ',' . substr ($date,4,2) . ','  . substr ($date,6,2) . ")\"" ;

    print CSV_OUT "$date_excel" ;
    print CSV_OUT ',' . $active_wikis {"1,*,$date"} ; 
    foreach $project (qw (wb wn wp wq ws wv wo wk wx))
    { print CSV_OUT ',' . $active_wikis {"1,$project,$date"} ; }
    
    print CSV_OUT ",,$date_excel" ;
    print CSV_OUT ',' . $active_wikis {"5,*,$date"} ; 
    foreach $project (qw (wb wn wp wq ws wv wo wk wx))
    { print CSV_OUT ',' . $active_wikis {"5,$project,$date"} ; }

    print CSV_OUT "\n" ;
  }

  close CSV_OUT ;

  exit ;
}

sub CollectActiveUsersWikiLovesMonuments
{
  &LogPhase ("CollectActiveUsersWikiLovesMonuments") ;

  chdir $path_in ;
  chdir ".." ;

  exit ;
}

sub CollectActiveUsersWikiLovesMonuments
{
  &LogPhase ("CollectActiveUsersWikiLovesMonuments") ;

  chdir $path_in ;
  chdir ".." ;

  print "Input folder is " . cwd () . "\n" ;
  print "Output folder is " . cwd () . "/csv_wp\n" ;

  my $filename_csv_in  = "EditsBreakdownPerUserPerMonthWikiLovesMonumentsUploaders.csv" ;
  my $filename_csv_out = "WLM_Uploaders_EditsBreakdownPerUserPerMonth.csv" ;
  my $file_out = cwd () . "/csv_mw/$filename_csv_out" ;
  my $file_out_sorted = $file_out ;
  $file_out_sorted =~ s/\.csv/_sorted.csv/ ;

  open CSV_OUT, '>', $file_out ;
  binmode CSV_OUT ;
  foreach $wp (qw (wb wk wn wo wp wq ws wv wx))
  {
    my $file = cwd () . "/csv_$wp/$filename_csv_in" ;
    open CSV_IN, '<', $file ;
    binmode CSV_IN ;
    while ($line = <CSV_IN>)
    {
      if ($line !~ /^\s*$/)
      { print CSV_OUT $line ; }
    }
    close CSV_IN ;
  }
  close CSV_OUT ;

  $cmd = "sort $file_out -o $file_out_sorted" ;
  $result = `$cmd` ;
  print "$cmd => $result\n" ;
  rename $file_out_sorted, $file_out ;

  my @lines ;
  my $counts = 0 ;
  open CSV_IN,  '<', $file_out ;
  $user_prev = '' ;
  while ($line = <CSV_IN>)
  {
    chomp $line ;
    my ($user,$month,$wiki,$namespace,$count) = split (',', $line) ;

    if ($month_first eq '')
    { $month_first = $month ; }

    if (($user ne $user_prev) && ($user_prev ne ''))
    {
      push @lines, "$month_first,$month_last,$user_prev,$counts," . join ('|', sort keys %wikis) . "\n" ;

      $wlm_uploaders_month_first {$month_first}++ ;
      $wlm_uploaders_month_last  {$month_last}++ ;

      # also collect all relevant months in one hash
      $wlm_uploaders_months {$month_first}++ ;
      $wlm_uploaders_months {$month_last}++ ;

      undef %wikis ;
      $month_first = $month ;
      $counts = 0 ;
    }
    $wikis {$wiki}++ ;
    $month_last = $month ;
    $user_prev  = $user ;
    $counts     += $count ;
  }
  push @lines, "$month_first,$month_last,$user,$counts," . join ('|', sort keys %wikis) . "\n" ;
  close CSV_IN ;

  my $filename_csv = "WLM_Uploaders_EditsFirstLast2.csv" ;
  open CSV_OUT, '>', cwd () . "/csv_mw/$filename_csv" ;
  print CSV_OUT "#month,first edit, last edit\n" ;
  foreach $month (sort keys %wlm_uploaders_months)
  { print CSV_OUT "$month," . ($wlm_uploaders_month_first {$month}+0) . "," . ($wlm_uploaders_month_last {$month}+0) . "\n" ; }
  close CSV_OUT ;

  @lines = sort @lines ;

# my $filename_csv = "EditsFirstLastWikiLovesMonumentsUploaders.csv" ;
  my $filename_csv = "WLM_Uploaders_EditsFirstLast.csv" ;
  open CSV_OUT, '>', cwd () . "/csv_mw/$filename_csv" ;
  print CSV_OUT "#first month,last month,user,edits,wikis\n" ;
  foreach $line (@lines)
  {
    if ($line !~ /^\s*$/)
    { print CSV_OUT $line ; }
  }
  close CSV_OUT ;

  my $period_prev = '' ;
  my $edits_prev  = 0 ;
  my $edits_tot   = 0 ;

# my $filename_csv = "EditsFirstLastWikiLovesMonumentsUploadersRetention.csv" ;
  my $filename_csv = "WLM_Uploaders_EditsFirstLastRetention.csv" ;
  open CSV_OUT, '>', cwd () . "/csv_mw/$filename_csv" ;
  print CSV_OUT "#first month,last month,users,total edits,average edits per user\n" ;
  foreach $line (@lines)
  {
    next if $line =~ /^#/ ;
    next if $line =~ /^\s*$/ ;
    chomp $line ;
    ($month_first,$month_last,$user,$edits,$dummy) = split (',', $line) ;
    $period = "$month_first,$month_last" ;
    if (($period ne $period_prev) && ($period_prev ne ''))
    {
      $edits_avg = sprintf ("%.0f", $edits_tot/ $users) ;
      print CSV_OUT "$period_prev,$users,$edits_tot,$edits_avg\n" ;
      $edits_tot  = 0 ;
      $users = 0 ;
    }
    $period_prev = $period ;
    $users ++ ;
    $edits_tot += $edits ;
  }
  $edits_avg = sprintf ("%.0f", $edits_tot/ $users) ;
  print CSV_OUT "$period_prev,$users,$edits_tot,$edits_avg\n" ;
  close CSV_OUT ;
}



# merge all language specific files, starting with the smallest, add one file on each call
# resulting file contains edit counts per user per month for all relevant ~'article' namespaces (usually 0 only)
# two counts: one for full month, one for first 28 days (for fair comparison of consecutive months)
# example
# Amirobot,2011-06,14,14
# Amirobot,2011-07,6,6
# Amirobot,2011-08,4,4
# Amirobot,2011-09,3,1
sub MergeActiveUsersPerMonthsAllWikisOrProjects
{
  my ($wp, $file_csv_add, $file_csv_from, $file_csv_to, $merge_namespaces, $month_last) = @_ ;
  my $language = '?' ;

  if ($merge_namespaces) # already done when merging projects
  {
    $file_csv_add2 = $file_csv_add ;
    $file_csv_add2 =~ s/\.csv/Temp.csv/ ;

$trace = ($file_csv_add =~ /ZH.csv/) ;

    # step 1: preprocess new file before merging with already merged content
    # discard all non-article namespaces (on most wikis all non zero namespaces), acculumulate per user per month what for remaining namespaces
    # but first copy data for wiki loves monuments participants for all namespaces to later determine retention levels
    open FILE_CSV_ADD,  '<', $file_csv_add ;
    open FILE_CSV_ADD2, '>', $file_csv_add2 ;
    binmode FILE_CSV_ADD ;
    binmode FILE_CSV_ADD2 ;

    undef @lines_add ;

    my $lines_written = 0 ;
    $prev_user_add  = '' ;
    $prev_month_add = '' ;

    while ($line_add = <FILE_CSV_ADD>)
    {
      if ($line_add =~ /^#/) # skip duplicate comments
      {
        $line_add =~ s/ per namespace// ;
        $line_add =~ s/ namespace,// ;

        print FILE_CSV_ADD2 $line_add ;
        next ;
      }

      chomp $line_add ;
      $line_add =~ s/,\s+(\d)/,$1/g ;

      ($user_add, $month_add, $namespace_add, $edits_add, $edits_add_28)  = split (',', $line_add) ;

      # if this user uploaded to WLM in any year, copy edits to WLM file
      # after merging such files for all projects, we can find out when user started to contribute
      # if that is in month of WLM event we assume user joined because of WLM and cheer for that
      if ($wiki_loves_monuments_participant {$user_add})
      { print FILE_CSV_WLM "$user_add,$month_add,$mode-$wp,$namespace_add,$edits_add\n" ; }

# print "mode $mode $mode-$wp\n" ;
# exit ;

      # print "IN  $user_add, $month_add, $namespace_add, $edits_add\n" if $trace ;
      if (&IpAddress ($user_add))
      { $user_add = 'an.on.ym.ous' ; }
      next if $user_add eq 'an.on.ym.ous' ;

      next if ($user_add =~ /bot\b/i) || ($user_add =~ /_bot_/i) ; # name(part) ends on bot,
      next while (! &NameSpaceArticle ($wp, $namespace_add)) ;

      if (($user_add ne $prev_user_add) || ($month_add ne $prev_month_add))
      {
        if ($prev_user_add ne '') # not first record ?
        {
        # print "OUT $prev_user_add, $prev_month_add,$edits_add_tot\n" if $trace ;
          print FILE_CSV_ADD2 "$prev_user_add,$prev_month_add,$edits_add_tot, $edits_add_tot_28\n" ;
        }

        $edits_add_tot    = $edits_add ;
        $edits_add_tot_28 = $edits_add_28 ;
      }
      else
      {
        $edits_add_tot    += $edits_add ;
        $edits_add_tot_28 += $edits_add_28 ;
      }

      $prev_user_add  = $user_add ;
      $prev_month_add = $month_add ;
    }

    print FILE_CSV_ADD2 "$prev_user_add,$prev_month_add,$edits_add_tot, $edits_add_tot_28\n" ;
    # print "OUT $prev_user_add, $prev_month_add\n" if $trace ;

    close FILE_CSV_ADD ;
    close FILE_CSV_ADD2 ;

    # exit if $trace ;

  }
  else
  { $file_csv_add2 = $file_csv_add ; }


  # step 1 ready
  # step 2: merged 'condensed' file with already merged data

  if ($file_csv_from eq 'none')
  {
    # first file to 'merge', just copy
    open FILE_CSV_ADD2, '<', $file_csv_add2 ;
    open FILE_CSV_TO,   '>', $file_csv_to ;
    binmode FILE_CSV_ADD2 ;
    binmode FILE_CSV_TO ;

    while ($line = <FILE_CSV_ADD2>)
    { print FILE_CSV_TO $line ; }
    close FILE_CSV_ADD2 ;
    close FILE_CSV_TO ;
  }
  else
  {
    # add new file to already merged content
    open FILE_CSV_ADD2, '<', $file_csv_add2 ;
    open FILE_CSV_FROM, '<', $file_csv_from ;
    open FILE_CSV_TO,   '>', $file_csv_to ;

    binmode FILE_CSV_ADD2 ;
    binmode FILE_CSV_FROM ;
    binmode FILE_CSV_TO ;

    if ($month_last ne '')
    { print FILE_CSV_TO "# Counts are complete, at least for top 25 wikis, up to and including $month_last (do not report incomplete counts for a later date)\n" ; }

    $line_add  = <FILE_CSV_ADD2> ;
    while ($line_add =~ /^#/) # skip duplicate comments
    {
      print FILE_CSV_TO $line_add ;
      $line_add = <FILE_CSV_ADD2> ;
    }

    $line_from = <FILE_CSV_FROM> ;
    while ($line_from =~ /^#/) # skip duplicate comments
    {
      $line_from = <FILE_CSV_FROM> ;
    }

    chomp $line_add ;
    chomp $line_from ;

    ($user_add, $month_add, $edits_add, $edits_add_28)  = split (',', $line_add) ;
    ($user_from,$month_from,$edits_from,$edits_from_28) = split (',', $line_from) ;
# print "add $line_add\n" ;
# print "from $line_from\n" ;

    # combine counts per user,month  but only for article namespace(s)
    # article namespaces is usually only namespace 0 but there are exceptions
    while (($line_add ne '') || ($line_from ne ''))
    {
      $copy_add  = $false ;
      $copy_from = $false ;
      $copy_none = $false ;
      if ($line_add eq '')
      { $copy_from = $true ; }
      elsif ($line_from eq '')
      { $copy_add = $true ; }
      else
      {
        if ("$user_add," lt "$user_from,")      # add comma to comparison as csv file is sorted alphabetically over all fields
        { $copy_add = $true ; }                 # so "John Doe" comes before "John"  but "John Doe," after "John,"
        elsif ("$user_from," lt "$user_add,")
        { $copy_from = $true ; }
        else
        {
          if ($month_add lt $month_from)
          { $copy_add = $true ; }
          elsif ($month_from lt $month_add)
          { $copy_from = $true ; }
          else
          {
            $copy_none = $true ;

#if ($user_from eq '')
#{ print "user_from empty / abort\n" ; exit ; }

            $line_new = "$user_from,$month_from," . ($edits_add+$edits_from) . ',' . ($edits_add_28+$edits_from_28) . "\n" ;
#print "merge $line_new" if $line_new =~ /^Erik(?: Zachte)?,/ ;

            print FILE_CSV_TO $line_new ;

          # print "merge\n" ;
            $line_add = <FILE_CSV_ADD2> ;
            chomp $line_add ;
            ($user_add, $month_add, $edits_add, $edits_add_28)  = split (',', $line_add) ;

            $line_from = <FILE_CSV_FROM> ;
            chomp $line_from ;
            ($user_from,$month_from,$edits_from,$edits_from_28) = split (',', $line_from) ;
          }
        }
      }

      if ($copy_add)
      {
        print FILE_CSV_TO "$line_add\n" ;
        #print "copy add [$user_add/$user_from] [$month_add/$month_from] $line_add\n" if $line_add =~ /^Erik(?: Zachte)?,/ ;
        $line_add = <FILE_CSV_ADD2> ;
        chomp $line_add ;
        ($user_add, $month_add, $edits_add, $edits_add_28)  = split (',', $line_add) ;
      }
      elsif ($copy_from)
      {
        print FILE_CSV_TO "$line_from\n" ;
        #print "1 copy from [$user_add/$user_from] [$month_add/$month_from] $line_from\n" if $line_from =~ /^Erik/ ;
        #print "2 copy from [$user_add/$user_from] [$month_add/$month_from] $line_from\n" if $line_from =~ /^Erik(?: Zachte),/ ;
        $line_from = <FILE_CSV_FROM> ;
        chomp $line_from ;
        ($user_from,$month_from,$edits_from,$edits_from_28) = split (',', $line_from) ;
      }
      else
      {
        #if ($copy_none)
        #{
        ## print "copy_none, not copy_add nor copy_from <- [$user_add/$user_from] [$month_add/$month_from]\n$line_add\n$line_from\n \n" ;
        # }
        #else
        #{ print "not copy_none, not copy_add nor copy_from <- [$user_add/$user_from] [$month_add/$month_from] \n" ; }
      }
    }

    close FILE_CSV_ADD2 ;
    close FILE_CSV_FROM ;
    close FILE_CSV_TO ;

#   open FILE_CSV_TO, '<', $file_csv_to ;
#   binmode FILE_CSV_TO ;

#   $line = <FILE_CSV_TO> ;
#   while ($line =~ /^#/) # skip duplicate comments
#   {
#     $line = <FILE_CSV_TO> ;
#   }

#   $prev_user = '' ;
#   while ($line = <FILE_CSV_TO>)
#   {
#     ($user,$month,@dummy) = split (',', $line) ;
#     if ($line =~ /^\s*$/)
#     {
#       $lines_skipped1++ ;
#       next ;
#     } ;
#     if ($prev_user eq '')
#     {
#       print "user '$user' lt prev user '$prev_user'\n" ;
#       print "prev line $prev_line" ;
#       print "line $line" ;
#       $lines_skipped2++ ;
#       $prev_user = $user ;
#       next ;
#     } ;
#     if ("$user," lt "$prev_user,")
#     {
#       print "user '$user' lt prev user '$prev_user'\n" ;
#       print "prev line $prev_line" ;
#       print "line $line" ;
#       exit ;
#     }
#     $prev_user = $user ;
#     $prev_line = $line ;
#   }
#   close FILE_CSV_TO ;
#   print "Lines skipped1: $lines_skipped1\n" ;
#   print "Lines skipped2: $lines_skipped2\n" ;

    if ($merge_namespaces) # only relevant when merging wikis, not projects
    {
      # unlink $file_csv_add2 ; # temporary file
      # unlink $file_csv_from ; # temporary file
    }
    else
    {
      # unlink $file_csv_from ; # temporary file
    }
  }
}

sub CollectUserStats
{
  &LogPhase ("CollectUserStats") ;
  &TraceMem ;


  $secsinday = 24 * 60 * 60 ;
  foreach $user (keys %userdata)
  {
    my $record = $userdata {$user} ;
    # &Log ("Record4 $record\n") ;
    my @fields = split (',', $record) ;
    if (@fields [$useritem_edit_reg_namespace_a] == 0) { next ; }
    $first = @fields [$useritem_edit_first] ;
    $last  = @fields [$useritem_edit_last] ;
    @edits_10 = split ('\|', $fields [$useritem_edits_10]) ;
    $tenth = @edits_10 [9] ;

    if ($first == 0) { next ; } # user did only edit redirects
    # if (! (defined ($first))) { next ; } # user only edited redirects

    my $line = sprintf ("%8d %8d %8d %8d %8d %8d %8d %8d %5s %5s %10d %10d %10d %s", # strategy
                        @fields [$useritem_edit_reg_namespace_a],
                        @fields [$useritem_edit_reg_recent_namespace_a],
                        @fields [$useritem_edit_reg_namespace_x],
                        @fields [$useritem_edit_reg_recent_namespace_x],
                        @fields [$useritem_create_reg_namespace_a],
                        @fields [$useritem_create_reg_recent_namespace_a],
                        @fields [$useritem_create_reg_namespace_x],
                        @fields [$useritem_create_reg_recent_namespace_x],
                        'rank1',
                        'rank2',
                        $first,
                        $last,
                        $tenth,
                        $user) ;

    if ($bots {$user})
    { push (@user_stats_bot, $line) ; } # -> UpdateBotEdits
    else
    {
      push (@user_stats_reg, $line) ;
      if ($tenth > 0)
      { push (@user_stats_reg_10_edits, $line) ; }
    }
  }

  if (&TraceJob)
  { &TraceMem ; }
}

# -> UpdateBotEdits
# -> UpdateActiveUsers
# -> UpdateSleepingUsers
sub RankUserStats
{
  &LogPhase ("RankUserStats") ;
  &TraceMem ;

# @user_stats_reg = sort {&csvkey_editsprev_first ($a) cmp &csvkey_editsprev_first ($b)} @user_stats_reg ;
# sub csvkey_editsprev_first
# {
#   my $record = shift ;
#   my $edits_namespace_a      = substr ($record,0,8) ;
#   my $edits_prev_namespace_0 = substr ($record,10,8) ;
#   my $first                  = substr ($record,48,10) ;
#   return (sprintf ("%08d", (99999999 - ($edits_namespace_a - $edits_prev_namespace_0))) . sprintf ("%10d", $first)) ;
# }
  @user_stats_reg = sort {
                           ($x=sprintf ("%08d", (99999999 - (substr ($a,0,8) - substr ($a,10,8)))) . substr ($a,84,10),$x) cmp
                           ($y=sprintf ("%08d", (99999999 - (substr ($b,0,8) - substr ($b,10,8)))) . substr ($b,84,10),$y)
                         }
                         @user_stats_reg ;

  $rank = 0 ;

open USERRANK, '>', "c:/userrank2.txt" ;
  foreach $user_stat (@user_stats_reg)
  {
    $user = substr ($user_stat,117) ;
    if ((index (lc($user), "conversion") != -1) ||
        ((index (lc($user), "konvertilo") != -1) & ($language eq "eo")))
    { next ; }

    $rank++ ;
    $rank5 = sprintf ("%5d", $rank) ;
print USERRANK "1: $user_stat\n" ;
    $user_stat =~ s/rank2/$rank5/ ;
print USERRANK "2: $user_stat\n" ;
  }
close USERRANK ;

  @user_stats_reg = sort {&csvkey_edits_first ($a) cmp &csvkey_edits_first ($b)} @user_stats_reg ;

open USERRANK, '>', "c:/userrank1.txt" ;
  $rank = 0 ;
  foreach $user_stat (@user_stats_reg)
  {
    $user = substr ($user_stat,117) ;
    if ((index (lc($user), "conversion") != -1) ||
        ((index (lc($user), "konvertilo") != -1) & ($language eq "eo")))
    { next ; }

    $rank++ ;
    $rank5 = sprintf ("%5d", $rank) ;
print USERRANK "1: $user_stat\n" ;
    $user_stat =~ s/rank1/$rank5/ ;
print USERRANK "2: $user_stat\n" ;
  }
close USERRANK ;

# @user_stats_bot = sort {&csvkey_editsprev_first ($a) cmp &csvkey_editsprev_first ($b)} @user_stats_bot ;
# see above
  @user_stats_bot = sort {
                           ($x=sprintf ("%08d", (99999999 - (substr ($a,0,8) - substr ($a,10,8)))) . substr ($a,84,10),$x) cmp
                           ($y=sprintf ("%08d", (99999999 - (substr ($b,0,8) - substr ($b,10,8)))) . substr ($b,84,10),$y)
                         }
                         @user_stats_bot ;
  $rank = 0 ;
  foreach $user_stat (@user_stats_bot)
  {
    $rank++ ;
    $rank5 = sprintf ("%5d", $rank) ;
    $user_stat =~ s/rank2/$rank5/ ;
  }

# @user_stats_bot = sort {&csvkey_edits_first ($a) cmp &csvkey_edits_first ($b)} @user_stats_bot ;
# sub csvkey_edits_first
# {
#   my $record = shift ;
#   my $edits_namespace_a = substr ($record,0,8) ;
#   my $first             = substr ($record,48,10) ;
#   return (sprintf ("%08d", (99999999 - $edits_namespace_a)) . sprintf ("%10d", $first)) ;
# }
  @user_stats_bot = sort {
                          ($x=sprintf ("%08d", (99999999 - substr ($a,0,8))) . substr ($a,84,10),$x) cmp
                          ($y=sprintf ("%08d", (99999999 - substr ($b,0,8))) . substr ($b,84,10),$y)
                         } @user_stats_bot ;
  $rank = 0 ;
  foreach $user_stat (@user_stats_bot)
  {
    $rank++ ;
    $rank5 = sprintf ("%5d", $rank) ;
    $user_stat =~ s/rank1/$rank5/ ;
  }

}

sub GetUserData
{
  my $user = shift ;
  my $ndx  = shift ;
  my $record = $userdata {$user} ;

  if ($record eq "")
  { $record = &NewUserData ($user) ; }

  my @fields = split (',', $record) ;
# &Log ("GetUserData $user : $ndx : " . @fields [$ndx] . "\n") ;
  return (@fields [$ndx]) ;
}

sub NewUserData
{
  my $user = shift ;

  $record = ",,,,,,,,,,,,,#" ;
  my @fields = split (',', $record) ;

  if (&IpAddress ($user))
  {
    $cnt_users_ip += 2 ;
    @fields [$useritem_id] = $cnt_users_ip ;
  }
  else
  {
    $cnt_users_reg += 2 ;
    @fields [$useritem_id] = $cnt_users_reg ;
  }

  $record = join (',', @fields) ;
  $userdata {$user} = $record ;

  if (++$newusersadded % 100000 == 0)
  { $tracemsg .= "Unique users: " . int ($cnt_users_reg/2) . " registered, " . int (($cnt_users_ip+2)/2) . " anonymous => $newusersadded x 60 (?) bytes = " . &i2KbMb (60 * $newusersadded) . "\n"  ; }

  return ($record) ;
# &Log ("PutUserData $user : $ndx : $data\n") ;
}

sub PutUserData
{
  my $user = shift ;
  my $ndx  = shift ;
  my $data = shift ;

  my $record = $userdata {$user} ;
  if ($record eq "")
  { $record = &NewUserData ($user) ; }

  my @fields = split (',', $record) ;
  @fields [$ndx] = $data ;
  $userdata {$user} = join (',', @fields) ;
# &Log ("PutUserData $user : $ndx : $data\n") ;
}

sub IncUserData
{
  my $user = shift ;
  my $ndx  = shift ;

  my $record = $userdata {$user} ;
  if ($record eq "")
  { $record = &NewUserData ($user) ; }

  my @fields = split (',', $record) ;
  @fields [$ndx]++ ;
  $userdata {$user} = join (',', @fields) ;
# &Log ("IncUserData $user : $ndx\n") ;
}

sub CollectUploaders
{
  &LogT ("CollectUploaders $language\n") ;

  my $file_csv_creates                  = $path_out . "Creates"                        . uc ($language)  . ".csv" ;
  my $file_csv_creates_binaries         = $path_out . "CreatesBinaries"                . uc ($language)  . ".csv" ;
  my $file_csv_creates_binaries_sorted  = $path_out . "CreatesBinariesSorted"          . uc ($language)  . ".csv" ;
  my $file_csv_activity_trends_binaries = $path_out . "UserActivityTrendsNewBinaries"  . uc ($language)  . ".csv" ;
  my $file_csv_top_uploaders            = $path_out . "UserActivityTrendsTopUploaders" . uc ($language)  . ".csv" ;
  my $file_csv_top_uploaders_monthly    = $path_out . "UserActivityTrendsTopUploadersMonthly" . uc ($language)  . ".csv" ;
  my $file_csv_uploadwizard             = $path_out . "UserActivityTrendsUploadWizard" . uc ($language)  . ".csv" ;

  return if ! -e $file_csv_creates ;

# for tests on Windows skip this very time consuming step, (rely on 'once per session only' manual workaround)
if ($job_runs_on_production_server)
{
  # reorder fields in input
  open FILE_CREATES,          '<', $file_csv_creates ;
  open FILE_CREATES_BINARIES, '>', $file_csv_creates_binaries ;

  binmode FILE_CREATES ;
  binmode FILE_CREATES_BINARIES ;

   while ($line = <FILE_CREATES>)
  {
    next if $line =~ /^#/ ;
    chomp $line ;

    ($count_flag,$yyyymmddhhnn,$namespace,$usertype,$user,$title,$cat_uploadwizard) = split (',', $line) ;

    next if $namespace != 6 ;

if ($usertype eq 'R')
{ $not_bots {$user}++ ; } # temp code to fix few users that have some uploads attributed to bot due to 'bot' in comment (temp fix)

    $yyyy_mm = substr ($yyyymmddhhnn,0,7) ;
    $line = "$yyyy_mm,$user,$usertype,$count_flag,$cat_uploadwizard" ;
    print FILE_CREATES_BINARIES "$line\n" ;
  }
  close FILE_CREATES ;
  close FILE_CREATES_BINARIES ;

  $filesize_in = -s $file_csv_creates_binaries ;
  return if $filesize_in == 0 ;
  $filesize_in = &i2KbMb ($filesize_in) ;

  $timestartsort = time ;
  &LogT ("Sort $file_csv_creates_binaries\nInto $file_csv_creates_binaries_sorted\nUsing folder $path_temp\n") ;
  $cmd = "sort $file_csv_creates_binaries -o $file_csv_creates_binaries_sorted -T $path_temp" ;
  $result = `$cmd` ;
  if ($result ne '')
  { &LogT ("Cmd $cmd -> results '$result'\n") ; }
  &LogT ("Sort took " . ddhhmmss (time - $timestartsort). ".\n") ;
# unlink $file_csv_creates_binaries ;
}

  &LogT ("\nCollect uploads per user per month\n") ;

  undef %yyyy_mm ;
  undef %t_max ; # max threshold level for which a non zero value is found

  $yyyy_mm_prev  = '' ;
  $user_prev     = '' ;
  $usertype_prev = '' ;
  $flag_uploadwizard = '' ;
  $uploads_this_user_this_month_wizard = 0 ;

  open FILE_CREATES_BINARIES,             '<', $file_csv_creates_binaries_sorted ;
  open FILE_ACTIVITY_TRENDS_NEW_BINARIES, '>', $file_csv_activity_trends_binaries ;

  binmode FILE_CREATES_BINARIES ;
  binmode FILE_ACTIVITY_TRENDS_NEW_BINARIES ;

  $level_max_R = 0 ;
  $level_max_B = 0 ;

  my $lines = 0 ;
  while ($line = <FILE_CREATES_BINARIES>)
  {
    $lines++ ;

    #if ($lines % 1000000 == 0)
    #{ print "$lines\n" ; }

    chomp $line ;
    ($yyyy_mm,$user,$usertype,$count_flag,$cat_uploadwizard) = split (',', $line) ;
    $cat_uploadwizard =~ s/[\x00-\x1F]//g ;

    if ($usertype eq 'B' and $cat_uploadwizard ne '')
    { &Log2 ("Bot upload via uploadwizard: $line\n") ; }
    if ($usertype eq 'R' and $cat_uploadwizard ne '')
    {
      if (yyyy_mm lt '2011-01')
      { &Log ("\n\nEarly reference to uploadwizard: $line\n\n") ; }
    }

    if ($cat_uploadwizard ne '')
    { $flag_uploadwizard = 'Y' ; }
    else
    { $flag_uploadwizard = 'N' ; }

    $uploads_per_month_per_method          {"$yyyy_mm $usertype $flag_uploadwizard"} ++ ;
    $uploads_per_month_per_method_per_user {"$yyyy_mm $user $flag_uploadwizard"} ++ ;

if ($not_bots {$user} > 0) # temp code to fix few users that have some uploads attributed to bot due to 'bot' in comment (temp fix)
{ $usertype = 'R' ; }
if ($user =~ /robot/i) # temp code to fix few users, should migrate to counts job
{ $usertype = 'B' ; }

    if ($usertype eq 'B')
    {
      $all_uploads1 {$user} ++ ;
      $bot_uploads1 {$user} ++ ;
      $all_uploads_month {"$user,$yyyy_mm"}++ ;
    }
    else
    {
      $all_uploads1 {$user} ++ ;
      $reg_uploads1 {$user} ++ ;
      $all_uploads_month {"$user,$yyyy_mm"}++ ;
    }


    # if ($cat_uploadwizard ne '')
    # { $cat_uploadwizard = 'X' ; }

    if ($user_prev eq '') # first record ?
    {
      $yyyy_mm_prev  = $yyyy_mm ;
      $user_prev     = $user ;
      $usertype_prev = $usertype ;
      $uploads_this_user_this_month = 1 ;
      next ;
    }

    if ($yyyy_mm ne $yyyy_mm_prev)
    {
      $yyyy_mm {$yyyy_mm} ++ ;

      if ($user_prev ne '')
      {
        $active_uploads_per_month   {"$user_prev,$usertype_prev"} = $uploads_this_user_this_month ;
        if (($usertype_prev eq 'R') && ($uploads_this_user_this_month_wizard > 0))
        { $active_uploads_per_month {"$user_prev,W"} = $uploads_this_user_this_month_wizard ; }
      }

      if ($yyyy_mm_prev ne '')
      {
      # print "\n$yyyy_mm_prev\n" ;
        &CollectUploadersPerMonth ($yyyy_mm_prev) ;
      }

      %active_uploads_per_month        = {} ;
      %active_uploads_per_month_wizard = {} ;
      $yyyy_mm_prev  = $yyyy_mm ;
      $user_prev     = $user ;
      $usertype_prev = $usertype ;

      $uploads_this_user_this_month = 1 ;
      if (($cat_uploadwizard ne '') && ($usertype eq 'R'))
      { $uploads_this_user_this_month_wizard = 1 ; }
      else
      { $uploads_this_user_this_month_wizard = 0 ; }
    }
    elsif ($user ne $user_prev)
    {
      if ($user_prev ne '')
      {
        $active_uploads_per_month {"$user_prev,$usertype_prev"} = $uploads_this_user_this_month ;
        $active_uploads_per_month {"$user_prev,W"}              = $uploads_this_user_this_month_wizard ;
      }
      $user_prev     = $user ;
      $usertype_prev = $usertype ;

      $uploads_this_user_this_month = 1 ;
      if (($cat_uploadwizard ne '') && ($usertype eq 'R'))
      { $uploads_this_user_this_month_wizard = 1 ; }
      else
      { $uploads_this_user_this_month_wizard = 0 ; }
    }
    else
    {
      $uploads_this_user_this_month ++ ;
      if (($cat_uploadwizard ne '') && ($usertype eq 'R'))
      { $uploads_this_user_this_month_wizard ++ ; }
    }
  }

  $active_uploads_per_month {"$user_prev,$usertype_prev"} = $uploads_this_user_this_month ;
  if (($usertype_prev eq 'R') && ($uploads_this_user_this_month_wizard > 0))
  { $active_uploads_per_month {"$user_prev,W"} = $uploads_this_user_this_month_wizard ; }

  &CollectUploadersPerMonth ($yyyy_mm_prev) ;

# print "t_max R " . $t_max {'R'} . "\n" ;
# print "t_max B " . $t_max {'B'} . "\n" ;
# print "t_max W " . $t_max {'W'} . "\n" ;

  # write uploaders per month per activity level (for reg users and bots)
  $intro  = "#Binaries Uploaders - User Activity Trends (namespace 6 only)\n" ;
  $intro .= "#Language,Date," ;
  for ($t = 0 ; $t < $t_max {'R'} ; $t++)
  { $intro .= $thresholds_sparse [$t] . ',' ; }
  $intro .= "Date," ;
  for ($t = 0 ; $t < $t_max {'W'} ; $t++)
  { $intro .= $thresholds_sparse [$t] . ',' ; }
  $intro .= "Date," ;
  for ($t = 0 ; $t < $t_max {'B'} ; $t++)
  { $intro .= $thresholds_sparse [$t] . ',' ; }
  $intro =~ s/,$// ;
  print FILE_ACTIVITY_TRENDS_NEW_BINARIES "$intro\n" ;
  &Log ("\n$intro\n") ;

  $t_max {'R'}-- ;
  $t_max {'W'}-- ;
  $t_max {'B'}-- ;

  foreach $yyyy_mm (sort keys %yyyy_mm)
  {
    $yyyy = substr ($yyyy_mm,0,4) ;
    $mm   = substr ($yyyy_mm,5,2) ;
    $dd   = days_in_month ($yyyy, $mm) ;
    $mmddyyyy = sprintf ("%02d/%02d/%04d", $mm, $dd, $yyyy) ;

    $line_csv = "commons,$mmddyyyy," ;

    for ($t = 0 ; $t <= $t_max {'R'} ; $t++)
    {
      $threshold = $thresholds_sparse [$t] ;
      $uploaders = $active_uploaders_per_month {$yyyy_mm} {'R'} {$threshold};
      if ($uploaders == 0)
      { $uploaders = '' ; }
      $line_csv .= "$uploaders," ;
    }

    $line_csv .= "$mmddyyyy," ;
    for ($t = 0 ; $t <= $t_max {'W'} ; $t++)
    {
      $threshold = $thresholds_sparse [$t] ;
      $uploaders = $active_uploaders_per_month {$yyyy_mm} {'W'} {$threshold};
      if ($uploaders == 0)
      { $uploaders = '' ; }
      $line_csv .= "$uploaders," ;
    }

    $line_csv .= "$mmddyyyy," ;
    for ($t = 0 ; $t <= $t_max {'B'} ; $t++)
    {
      $threshold = $thresholds_sparse [$t] ;
      $uploaders = $active_uploaders_per_month {$yyyy_mm} {'B'} {$threshold};
      if ($uploaders == 0)
      { $uploaders = '' ; }
      $line_csv .= "$uploaders," ;
    }
    print FILE_ACTIVITY_TRENDS_NEW_BINARIES "$line_csv\n" ;
    print "$line_csv\n" ;
  }

  close FILE_ACTIVITY_TRENDS_NEW_BINARIES ;

  &LogT ("\nWrite top uploaders\n") ;

  $top_uploaders = 0 ;

  open FILE_ACTIVITY_TRENDS_TOP_UPLOADERS, '>', $file_csv_top_uploaders ;

  foreach $user (sort {$all_uploads1 {$b} <=> $all_uploads1 {$a}} keys %all_uploads1)
  {
  # for verification only:
  # if ($bot_uploads1 {$user} != $bot_uploads2 {$user})
  # {
  #   print $bot_uploads1 {$user} . " != " .  $bot_uploads2 {$user} . ": $user\n" ;
  #  print $reg_uploads1 {$user} . " != " .  $reg_uploads2 {$user} . ": $user\n" ;
  # }
    if (++ $top_uploaders <= 100)
    { push @top_uploaders, $user ; }

    last if $all_uploads1 {$user} < 1000 ;

    if ($bot_uploads1 {$user} > 0)
    { $usertype = 'bot' ; }
    else
    { $usertype = 'user' ; }

    print FILE_ACTIVITY_TRENDS_TOP_UPLOADERS "$usertype,$user," .$all_uploads1 {$user} . "\n" ;
  }

  close FILE_ACTIVITY_TRENDS_TOP_UPLOADERS ;

  open FILE_ACTIVITY_TRENDS_TOP_UPLOADERS_MONTHLY, '>', $file_csv_top_uploaders_monthly ;

  $line = "Month" ;
  foreach $user (@top_uploaders)
  {
    $line .= ",\"$user\"" ;
  }
  print FILE_ACTIVITY_TRENDS_TOP_UPLOADERS_MONTHLY "$line\n" ;

  foreach $yyyy_mm (sort keys %yyyy_mm)
  {
    $line = $yyyy_mm ;
    foreach $user (@top_uploaders)
    { $line .= ',' . $all_uploads_month {"$user,$yyyy_mm"} ; }
    print FILE_ACTIVITY_TRENDS_TOP_UPLOADERS_MONTHLY "$line\n" ;
  }

  close FILE_ACTIVITY_TRENDS_TOP_UPLOADERS_MONTHLY ;


  if (! $edits_only)
  {
    print "\n\n\n" ;
    open FILE_UPLOADWIZARD, '>', $file_csv_uploadwizard ;
    print FILE_UPLOADWIZARD "month,total uploads,uploads by bot,uploads by reg. user, uploads by reg. user via uploadwizard, perc uploads by reg. user via uploadwizard\n" ;
    foreach $yyyy_mm (sort {$a cmp $b} keys %yyyy_mm)
    {
      $cat_r_y   = $uploads_per_month_per_method {"$yyyy_mm R Y"} ;
      $cat_r_n   = $uploads_per_month_per_method {"$yyyy_mm R N"} ;
      $cat_b_y   = $uploads_per_month_per_method {"$yyyy_mm B Y"} ;
      $cat_b_n   = $uploads_per_month_per_method {"$yyyy_mm B N"} ;
      $cat_r_tot = $cat_r_n + $cat_r_y ;
      $cat_b_tot = $cat_b_n + $cat_b_y ;
      $cat_tot   = $cat_r_tot + $cat_b_tot ;
      next if $cat_tot == 0 ;

      $perc_r_y = '-' ;
      if ($cat_r_tot > 0)
      { $perc_r_y = sprintf ("%.1f", 100 * $cat_r_y / $cat_r_tot) ; }

      $line = "$yyyy_mm,$cat_tot,$cat_b_tot,$cat_r_tot,$cat_r_y,$perc_r_y\%\n" ;
      print FILE_UPLOADWIZARD $line ;
      print "$line" ;
    }
    close FILE_UPLOADWIZARD ;
  }
}

sub CollectUploadersPerMonth
{
  my ($yyyy_mm) = @_ ;

  foreach $user_usertype (keys %active_uploads_per_month)
  {
    my $uploads = $active_uploads_per_month {$user_usertype} ;
    my ($user,$usertype) = split (',', $user_usertype) ;

    if ($usertype ne 'W') # uploads via wizard by registered user
    {
      if ($usertype eq 'B')
      { $bot_uploads2 {$user} += $uploads ; }
      else
      { $reg_uploads2 {$user} += $uploads ; }
    }

    for ($t = 0 ; $t <= $#thresholds_sparse ; $t++)
    {
      $threshold = $thresholds_sparse [$t] ;
      if ($uploads < $threshold) { last ; }
      if ($t > $t_max {$usertype})
      { $t_max {$usertype} = $t ; }
      $active_uploaders_per_month {$yyyy_mm} {$usertype} {$threshold} ++ ;
    }
  }

  my $line = 'R' ;
  for ($t = 0 ; $t <= $#thresholds_sparse ; $t++)
  {
    $threshold = $thresholds_sparse [$t] ;
    next if $active_uploaders_per_month {$yyyy_mm} {'R'} {$threshold} == 0 ;
    $line .= "," . $active_uploaders_per_month {$yyyy_mm} {'R'} {$threshold} ;
  }
  &Log ("$yyyy_mm $line\n") ;

  my $line = 'W' ;
  for ($t = 0 ; $t <= $#thresholds_sparse ; $t++)
  {
    $threshold = $thresholds_sparse [$t] ;
    next if $active_uploaders_per_month {$yyyy_mm} {'W'} {$threshold} == 0 ;
    $line .= "," . $active_uploaders_per_month {$yyyy_mm} {'W'} {$threshold} ;
  }
  &Log ("$yyyy_mm $line\n") ;

  my $line = 'B' ;
  for ($t = 0 ; $t < $#thresholds_sparse ; $t++)
  {
    $threshold = $thresholds_sparse [$t] ;
    next if $active_uploaders_per_month {$yyyy_mm} {'B'} {$threshold} == 0 ;
    $line .= "," . $active_uploaders_per_month {$yyyy_mm} {'B'} {$threshold} ;
  }
  &Log ("$yyyy_mm $line\n") ;
}

1;

#sub MergeActiveUsersPerMonthsAllWikisOrProjectsOldVersion
#{
#  my ($file_csv_add, $file_csv_from, $file_csv_to) = @_ ;

#  if ($file_csv_from eq 'none')
#  {
#    # first file to 'merge', just copy
#    open FILE_CSV_ADD, '<', $file_csv_add ;
#    open FILE_CSV_TO,  '>', $file_csv_to ;
#    binmode FILE_CSV_ADD ;
#    binmode FILE_CSV_TO ;
#    while ($line = <FILE_CSV_ADD>)
#    {
#      print FILE_CSV_TO $line ;
#    }
#    close FILE_CSV_ADD ;
#    close FILE_CSV_TO ;
#  }
#  else
#  {
#    open FILE_CSV_ADD,  '<', $file_csv_add ;
#    open FILE_CSV_FROM, '<', $file_csv_from ;
#    open FILE_CSV_TO,   '>', $file_csv_to ;

#    binmode FILE_CSV_ADD ;
#    binmode FILE_CSV_FROM ;
#    binmode FILE_CSV_TO ;

#    $line_add  = <FILE_CSV_ADD> ;
#    while ($line_add =~ /^#/) # skip duplicate comments
#    {
#      print FILE_CSV_TO $line_add ;
#      $line_add = <FILE_CSV_ADD> ;
#    }

#    $line_from = <FILE_CSV_FROM> ;
#    while ($line_from =~ /^#/) # skip duplicate comments
#    {
#      $line_from = <FILE_CSV_FROM> ;
#    }

#    chomp $line_add ;
#    chomp $line_from ;

#    ($user_add, $month_add, $namespace_add, $edits_add, $edits_add_28)  = split (',', $line_add) ;
#    ($user_from,$month_from,$namespace_from,$edits_from,$edits_from_28) = split (',', $line_from) ;

#    # combine counts per user,month  but only for article namespace(s)
#    # article namespaces is usually only namespace 0 but there are exceptions

#    while (($line_add ne '') || ($line_from ne ''))
#    {
#      $copy_add  = $false ;
#      $copy_from = $false ;

#      if ($line_add eq '')
#      { $copy_from = $true ; }
#      elsif ($line_from eq '')
#      { $copy_add = $true ; }
#      else
#      {
#        if ($user_add lt $user_from)
#        { $copy_add = $true ; }
#        elsif ($user_from lt $user_add)
#        { $copy_from = $true ; }
#        else
#        {
#          if ($month_add lt $month_from)
#          { $copy_add = $true ; }
#          elsif ($month_from lt $month_add)
#          { $copy_from = $true ; }
#          else
#          {
#            if ($namespace_add < $namespace_from)
#            { $copy_add = $true ; }
#            elsif ($namespace_from < $namespace_add)
#            { $copy_from = $true ; }
#            else
#            {
#              print FILE_CSV_TO "$user_from,$month_from,$namespace_from," . ($edits_add+$edits_from) . ',' . ($edits_add_28+$edits_from_28) . "\n" ;

#              $line_add = <FILE_CSV_ADD> ;
#              chomp $line_add ;
#              ($user_add, $month_add, $namespace_add, $edits_add, $edits_add_28)  = split (',', $line_add) ;

#              $line_from = <FILE_CSV_FROM> ;
#              chomp $line_from ;
#              ($user_from,$month_from,$namespace_from,$edits_from,$edits_from_28) = split (',', $line_from) ;
#            }
#          }

#        }
#      }

#      if ($copy_add)
#      {
#        print FILE_CSV_TO "$line_add\n" ;
#        $line_add = <FILE_CSV_ADD> ;
#        chomp $line_add ;
#        ($user_add, $month_add, $namespace_add, $edits_add, $edits_add_28)  = split (',', $line_add) ;
#      }
#      elsif ($copy_from)
#      {
#        print FILE_CSV_TO "$line_from\n" ;
#        $line_from = <FILE_CSV_FROM> ;
#        chomp $line_from ;
#        ($user_from,$month_from,$namespace_from,$edits_from,$edits_from_28) = split (',', $line_from) ;
#      }
#    }

#    close FILE_CSV_ADD ;
#    close FILE_CSV_FROM ;
#    close FILE_CSV_TO ;
#  }
#}


