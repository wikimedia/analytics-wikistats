#!/usr/bin/perl

$qr_csvkey_lang_date = qr/([^,]*,)(\d\d).(\d\d).(\d\d\d\d).*$/ ;

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
      &LogT ("Read $file: " . sprintf ("%9d",$sizefile) . " bytes, " . sprintf ("%6d",$#events+1) . " events\n") ;

      if ($filesizelarge)
      { &TraceMem ($nohashes) ; }

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
      &LogT ("\n$file removed: " . sprintf ("%9d",$sizefile) . " bytes") ;
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
  &LogT ("\nSort took " . ddhhmmss (time - $timestartsort). ".\n") ;
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

  &LogT ("\nCounting ready\n") ;
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
  &LogT ("\nReading $file_events: " . &i2KbMb ($filesize) . ".\n\n") ;

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
  &LogT ("\nWritten $file_events_concise: " . &i2KbMb ($filesize) . ".\n\n") ;
  if ($events_in > 0)
  { &LogT ("\n$events_out out of $events_in events copied to new file (" . sprintf ("%.1f", 100*$events_out/$events_in ) . "%)\n\n") ; }

  # determine month, year of first edit
  # (in human format -> 1 <= month <= 12 )
  ($day,$month,$year) = (localtime $first_edit) [3,4,5] ;
  $month += 1 ;
  $year  += 1900 ;

  &TraceMem ;
  &LogT ("\nYear " . $year . ", month $month\n\n") ;

  ($month_dump,$year_dump) = (localtime $dumpdate_gm) [4,5] ;
  $month_dump += 1 ;
  $year_dump  += 1900 ;

  &LogT ("-----: 1:real_articles, 2:mean_versions, 3:mean_articlesize, 4:articles_over_size1, 5:articles_over_size2\n" .
         "-----: 6:all_size, 7:tot_links, 8:tot_wiki_links, 9:tot_image_links, 10:tot_ext_links\n" .
         "-----: 11:tot_redirects, 12:alternate_articles, 13:tot_words, 14:tot_categorized\n") ;

  while (($year <  $year_dump) ||
         (($year == $year_dump) && ($month <= $month_dump)))
  {
    $yymm = sprintf ("%02d%02d", $year-2000, $month) ;
    $total_all_edits  += $all_edits_per_month  {$yymm} ;
    $total_real_edits += $real_edits_per_month {$yymm} ;
  # print "$yymm TE $total_edits TRE $total_real_edits E ${edits_per_month {$yymm}} RE YYMM ${real_edits_per_month {$yymm}} \n" ;

    $articles_per_month {$yymm} = &CountArticlesUpTo ($year, $month, $total_all_edits, $total_real_edits) ;

    my @fields = split (',', $articles_per_month {$yymm}) ;
    my $f = 0 ;
    foreach $field (@fields)
    { $f++ ; $field = " $f:$field" ; }
    &LogT ("$yymm: " . join (',', @fields) . "\n") ;

    # &Log (" " . $month) ;
    $month ++ ;
    if ($month > 12)
    {
      $month = 1 ;
      $year ++ ;
      &TraceMem ($nohashes) ;
      # &Log ("\nYear " . $year . ", month") ;
    }
  }

  &LogT ("\nCounting ready\n") ;
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

  if ($countarticlesupto++ == 0)
# { &LogT ("\nReading $file_events ($filesize bytes)).\n") ; }
  { &LogT ("\nReading $file_events_concise: " . &i2KbMb ($filesize) . ".\n\n") ; }

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
               $tot_categorized ;

  return ($counts) ;
}

sub CountPrev
{
  my $event_prev = shift ;

  if (substr ($event_prev,0,4) eq $b4hi2bbb)
  { return ; }

  my $count = substr ($event_prev, 9,1) ;

  my $size        = &bbbb2i (substr ($event_prev,10,4)) ;
  my $size2       = &bbbb2i (substr ($event_prev,14,4)) ;
  my $links       = &bb2i   (substr ($event_prev,18,2)) ;
  my $wiki_links  = ord     (substr ($event_prev,20,1)) ;
  my $image_links = ord     (substr ($event_prev,21,1)) ;
  my $cat_links   = ord     (substr ($event_prev,22,1)) ;
  my $ext_links   = ord     (substr ($event_prev,23,1)) ;
  my $words       = &bbb2i  (substr ($event_prev,24,3)) ;
  my $i ;

  if ($count eq "R")
  { $tot_redirects++ ; }

  if (($count eq "+") || ($count eq "L") || ($count eq "S"))
  {
    for ($s = 32, $i = 0 ; $s < $size2 ; $s *= 2 , $i ++) { ; }
    if ($i > 12) { $i = 12 ; }
    $size_group [$i]++ ;

    if (! $edits_only)
    {
      if ($count eq "+") # no redirect, stub or link list
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
    if (@fields [$useritem_reg_namespace_a] == 0) { next ; }
    $first = @fields [$useritem_first] ;
    $last  = @fields [$useritem_last] ;
    @edits_10 = split ('\|', $fields [$useritem_edits_10]) ;
    $tenth = @edits_10 [9] ;

    if ($first == 0) { next ; } # user did only edit redirects
    # if (! (defined ($first))) { next ; } # user only edited redirects

    my $line = sprintf ("%8d %8d %8d %8d %5s %5s %10d %10d %10d %s", # strategy
                        @fields [$useritem_reg_namespace_a],
                        @fields [$useritem_reg_recent_namespace_a],
                        @fields [$useritem_reg_namespace_x],
                        @fields [$useritem_reg_recent_namespace_x],
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
                           ($x=sprintf ("%08d", (99999999 - (substr ($a,0,8) - substr ($a,10,8)))) . substr ($a,48,10),$x) cmp
                           ($y=sprintf ("%08d", (99999999 - (substr ($b,0,8) - substr ($b,10,8)))) . substr ($b,48,10),$y)
                         }
                         @user_stats_reg ;

  $rank = 0 ;

open USERRANK, '>', "c:/userrank2.txt" ;
  foreach $user_stat (@user_stats_reg)
  {
    $user = substr ($user_stat,81) ;
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
    $user = substr ($user_stat,81) ;
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
                           ($x=sprintf ("%08d", (99999999 - (substr ($a,0,8) - substr ($a,10,8)))) . substr ($a,48,10),$x) cmp
                           ($y=sprintf ("%08d", (99999999 - (substr ($b,0,8) - substr ($b,10,8)))) . substr ($b,48,10),$y)
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
                          ($x=sprintf ("%08d", (99999999 - substr ($a,0,8))) . substr ($a,48,10),$x) cmp
                          ($y=sprintf ("%08d", (99999999 - substr ($b,0,8))) . substr ($b,48,10),$y)
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

  $record = ",,,,,,,,,#" ;
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

1;
