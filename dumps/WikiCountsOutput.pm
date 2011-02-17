#!/usr/bin/perl

$qr_csvkey_lang_date = qr/([^,]*),(\d\d).(\d\d).(\d\d\d\d).*$/ ;
$qr_csvkey_lang_date_short = qr/([^,]*),(\d\d).(\d\d\d\d).*$/ ;
$qr_csvkey_lang_type_date = qr/([^,]*),(\d\d).(\d\d).(\d\d\d\d),([^,]*).*$/ ;


sub UpdateWeeklyStats
{
  &LogPhase ("UpdateWeeklyStats") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_weekly_stats) ;
  foreach $week (@weekly_stats)
  { push @csv, &csv($language) . $week ; }
# @csv = sort {&csvkey_lang_date ($a) cmp &csvkey_lang_date ($b)} @csv ;
  @csv = sort {($x=$a,$x=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$x) cmp ($y=$b,$y=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$y)} @csv ;

  &WriteFileCsv ($file_csv_weekly_stats) ;

  &TraceRelease ("Release table \@weekly_stats") ;
  undef (@weekly_stats) ;
}

sub UpdateMonthlyStats
{
  &LogPhase ("UpdateMonthlyStats") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_namespace_stats) ;
  @csv2 = @csv ;
  &ReadFileCsv ($file_csv_namespace_edit_stats) ;
  @csv3 = @csv ;
  &ReadFileCsv ($file_csv_users_activity_spread) ;
  @csv4 = @csv ;
  foreach $line (@csv)
  {
    if (substr ($line,13,3) eq ",0,") # repair file, remove invalid records
    { $line = "" ; }
  }

  &ReadFileCsvOnly ($file_csv_monthly_stats) ;
  @csv_prev = @csv ;
  &ReadFileCsv ($file_csv_monthly_stats) ;

# @user_stats_reg = sort {substr ($a,48,10) <=> substr ($b,48,10)} @user_stats_reg ;
  @user_stats_reg_10_edits = sort {substr ($a,70,10) <=> substr ($b,70,10)} @user_stats_reg_10_edits ; # sort by tenth edit

  # determine month, year of first edit
  # (in human format -> 1 <= month <= 12 )
  ($day,$month,$year) = (localtime $first_edit) [3,4,5] ; # <- WikiCountsInput:ProcessRecord
  $month += 1 ;
  $year  += 1900 ;

  if ($year < 2001)
  {
    &LogT ("Invalid date found for first edit ($first_edit): $day/$month/$year\n" ) ;
    $day   = 1 ;
    $month = 1 ;
    $year  = 2001 ;
  }

  # set compare date/time to end of this month
  if ($month < 12)
  { $date = timegm (0,0,0,1,($month+1)-1,$year-1900) ; }
  else
  { $date = timegm (0,0,0,1,0,($year+1)-1900) ; }

  # add dummy record to simplify loop condition
# push @user_stats_reg,          "99999999 99999999 99999999 99999999 99999 99999 9999999999 9999999999 9999999999" ;
  push @user_stats_reg_10_edits, "99999999 99999999 99999999 99999999 99999 99999 9999999999 9999999999 9999999999" ;
  $users = 0 ;
  $prev_users = 0 ;
  $prev_articles = 0 ;

  foreach $user_rec (@user_stats_reg_10_edits)
  {
    $edits_namespace_a        = substr ($user_rec, 0, 8) ;
    $edits_recent_namespace_a = substr ($user_rec, 9, 8) ;
    $first                    = substr ($user_rec,48,10) ;
    $tenth                    = substr ($user_rec,70,10) ;
    $user                     = substr ($user_rec,81) ;

    # if (index (lc($user), "conversion") != -1) { next ; }
    # if (index (lc($user), "konvertilo") != -1) { next ; } # eo:

    if ($tenth == 0)
    { next ; }

    if ($language eq "sep11")
    { $users ++ ; }
    elsif ($edits_namespace_a >= 10)
    { $users ++ ; }

  # while ($first > $date)
    while ($tenth > $date)
    {
      $yymm     = sprintf ("%02d%02d", $year-2000, $month) ;

      if ($date > $dumpdate_gm) # edits eq "99999999")  # <- WikiCountsArguments:SetEnvironment
      {
        ($day,$month,$year) = (localtime $dumpdate_gm) [3,4,5] ;
         $date_show = sprintf ("%02d/%02d/%02d", $day, $month+1, $year-100) ;
         $days_passed = $day ;
      }
      else
      {
        $days_passed = days_in_month ($year, $month) ;
        $date_show   = sprintf ("%02d/%02d/%02d", $days_passed, $month, $year-2000) ;
      }

      $counts = $articles_per_month {$yymm} ;

      ($articles,$mean_versions,$mean_bytes,$over_size1,$over_size2,
       $tot_bytes, $tot_links, $tot_links_wiki,
       $tot_links_images, $tot_links_external,
       $tot_redirects, $articles_alt, $tot_words,
       $tot_categorized) = split (',', $counts) ;

      $new_articles = $articles - $prev_articles ;
      $new_articles_per_day = sprintf ("%.0f", ($new_articles / $days_passed)) ;

      if ($edits_only) # <- WikiCountsArguments:ParseArguments
      {
        foreach $line (@csv_prev)
        {
          ($language_prev,$date_prev) = split (',', $line) ;
          if ($date_prev eq &ddmmyy2mmddyyyy ($date_show))
          {
             chomp ($line) ;

            ($language_prev, $date_prev, $dummy1, $dummy2, $dummy3, $dummy4,
             $dummy5, $articles_alt_prev, $dummy6,
             $dummy7, $mean_bytes,
             $over_size1, $over_size2,
             $dummy8,
             $tot_bytes, $tot_words, $tot_links,
             $tot_links_wiki, $tot_links_images, $tot_links_external, $tot_redirects, $tot_categorized) = split (',', $line) ;

             if ($articles_alt_prev > $articles_alt)
             { $articles_alt = $articles_alt_prev ; }
             last ;
          }
        }
      }

      $line = &csv ($language). # # <- WikiCountsArguments:ParseArguments
              &csv (&ddmmyy2mmddyyyy ($date_show)).
              &csv ($users).
              &csv ($users - $prev_users).
              &csv ($active_users_per_month {"R,A,5,$yymm"}   + $active_users_per_month {"B,A,5,$yymm"}).   # <- WikiCountsProcess:CollectActiveUsersPerMonth
              &csv ($active_users_per_month {"R,A,100,$yymm"} + $active_users_per_month {"B,A,100,$yymm"}). # <- WikiCountsProcess:CollectActiveUsersPerMonth
              &csv ($articles).
              &csv ($articles_alt) .
              &csv ($new_articles_per_day).
              &csv ($mean_versions).
              &csv ($mean_bytes).
              &csv ($over_size1).
              &csv ($over_size2).
              &csv ($edits_per_month {$yymm}).
              &csv ($tot_bytes).
              &csv ($tot_words).
              &csv ($tot_links).
              &csv ($tot_links_wiki).
              &csv ($tot_links_images).
              &csv ($tot_links_external).
              &csv ($tot_redirects).
              &csv ($tot_categorized);

      $line =~ s/.$// ;
      push @csv, $line ;

      $counts = @articles_per_month_per_namespace {$yymm} ; # <- WikiCountsProcess:CountArticlesPerNamespacePerMonth
      (@articles_per_namespace) = split (',', $counts) ;

      $line = &csv ($language).
              &csv (&ddmmyy2mmddyyyy ($date_show)) ;
      foreach $count (@articles_per_namespace)
      { $line .= &csv ($count) ; }

      $line =~ s/.$// ;
      push @csv2, $line ;


      for ($c = 0 ; $c <= 2 ; $c++)
      {
        $usertype = substr ("ABR",$c,1) ; # anon, bot, registered (non bot)
        $counts = @edits_per_month_per_namespace {"$yymm$usertype"} ; # <- WikiCountsProcess:CountEditsPerNamespacePerMonth
        (@edits_per_namespace) = split (',', $counts) ;

        $line = &csv ($language).
                &csv (&ddmmyy2mmddyyyy ($date_show)) .
                &csv ($usertype) ;
        foreach $count (@edits_per_namespace)
        { $line .= &csv ($count) ; }

        $line =~ s/.$// ;
        $line =~ s/(?:,0)+$// ;
        push @csv3, $line ;
      }

      for ($u = 0 ; $u <= 1 ; $u++)
      {
        $usertype = substr ("BR",$u,1) ; # bot, registered (non bot) ; no stats for anonymous written here
        for ($c = 0 ; $c <= 2 ; $c++)
        {
          $nscat = substr ("ATO",$c,1) ; # article, talk, other
          $line = &csv ($language).
                  &csv (&ddmmyy2mmddyyyy ($date_show)) .
                  &csv ($usertype).
                  &csv ($nscat) ;
          for ($t = 0 ; $t < $#thresholds ; $t++)
          {
            $threshold = $thresholds [$t] ;
            $active_users = $active_users_per_month {"$usertype,$nscat,$threshold,$yymm"} ; # <- WikiCountsProcess:CollectActiveUsersPerMonth
            if ($active_users == 0) { last ; }
            $line .= &csv ($active_users) ;
          }
          $line =~ s/.$// ;
          push @csv4, $line ;
        }
      }

      if ($date > $dumpdate_gm) # edits eq "99999999") # <- WikiCountsArguments:SetEnvironment
#      if ($edits_namespace_a eq "99999999")
      { last ; }

      $month ++ ;
      if ($month > 12)
      {
        $month = 1 ;
        $year ++ ;
      }
      if ($month < 12)
      { $date = timegm (0,0,0,1,($month+1)-1,$year-1900) ; }
      else
      { $date = timegm (0,0,0,1,0,($year+1)-1900) ; }

      $prev_users    = $users ;
      $prev_articles = $articles ;
    }
  }


  &TraceRelease ("Release table \%articles_per_month") ;
  undef (%articles_per_month) ;
  &TraceMem ;

  # remove dummy record
  # $dummy = pop @user_stats_reg ;
  $dummy = pop @user_stats_reg_10_edits ;
# @csv = sort {&csvkey_lang_date ($a) cmp &csvkey_lang_date ($b)} @csv ;
  @csv = sort {($x=$a,$x=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$x) cmp ($y=$b,$y=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$y)} @csv ;
  &WriteFileCsv ($file_csv_monthly_stats) ;

# @csv = sort {&csvkey_lang_date ($a) cmp &csvkey_lang_date ($b)} @csv2 ;
  @csv = sort {($x=$a,$x=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$x) cmp ($y=$b,$y=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$y)} @csv2 ;
  &WriteFileCsv ($file_csv_namespace_stats) ;

  $line = &csv ($language). "00/00/0000," . @edits_per_month_per_namespace {"0000"} ; # legend: namespaces
  push @csv3, $line ;
#  @csv = sort {&csvkey_lang_type_date ($a) cmp &csvkey_lang_type_date ($b)} @csv3 ;
  @csv = sort {($x=$a,$x=~s/$qr_csvkey_lang_type_date/$1$5$4$2$3/o,$x) cmp ($y=$b,$y=~s/$qr_csvkey_lang_type_date/$1$5$4$2$3/o,$y)} @csv3 ;
  &WriteFileCsv ($file_csv_namespace_edit_stats) ;

# @csv = sort {&csvkey_lang_type_date ($a) cmp &csvkey_lang_type_date ($b)} @csv4 ;
  @csv = sort {($x=$a,$x=~s/$qr_csvkey_lang_type_date/$1$5$4$2$3/o, $x) cmp ($y=$b,$y=~s/$qr_csvkey_lang_type_date/$1$5$4$2$3/o, $y)} @csv4 ;
  &WriteFileCsv ($file_csv_users_activity_spread) ;
}

sub UpdBinariesStats
{
  &LogPhase ("UpdBinariesStats") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_binaries_stats) ;
  foreach my $line (@csv_binaries)
  { push @csv, $line ; }
# @csv = sort {&csvkey_lang_date ($a) cmp &csvkey_lang_date ($b)} @csv ;
  @csv = sort {($x=$a,$x=~s/$qr_csvkey_lang_date_short/$1$3$2/o,$x) cmp ($y=$b,$y=~s/$qr_csvkey_lang_date_short/$1$3$2/o,$y)} @csv ;
  &WriteFileCsv ($file_csv_binaries_stats) ;
}

# for $file_csv_user
# $file_csv_edit_distribution
sub UpdateUsers
{
  &LogPhase ("UpdateUsers") ;
  &TraceMem ;

  my (@edits_min, @edits, @users) ;

  my $sqrt10 = sqrt (10) ;
  my $bins = 15 ;
  $j = 1 ;
  for ($i = 0 ; $i < $bins ; $i++)
  { @edits_min [$i] = $j - 0.01 ; $j *= $sqrt10 ; }

# my (@csv2) ;

  &ReadFileCsv ($file_csv_user) ;

  if ($language ne 'strategy')
  {
    foreach $line (@csv) # drastically reduce file, temp code
    {
      ($dummy1, $edits_namespace_a, $dummy2, $edits_namespace_x) = split (',', $line) ;
      # if ($edits_namespace_a + $edits_namespace_x < 10)
      if ($edits_namespace_a < 10)
      { $line = "" ; }
    }
  }

# foreach $user_rec (@user_stats_reg)
# { push @user_stats2, $user_rec ; }

# foreach $user_rec (@user_stats2)
  my $users_tot = 0 ;
  my $edits_tot = 0 ;

#open USERSTATSREG, '>', "c:/userstatsreg.txt" ;
  foreach $user_rec (@user_stats_reg)
  {
    if ($user_rec eq "")
    { next ; }
#print USERSTATSREG "USER_REC '$user_rec'\n" ;
    $edits_namespace_a        = substr ($user_rec, 0, 8) ;
    $edits_recent_namespace_a = substr ($user_rec, 9, 8) ;
    $edits_namespace_x        = substr ($user_rec,18, 8) ;
    $edits_recent_namespace_x = substr ($user_rec,27, 8) ;
    $rank_now                 = substr ($user_rec,36, 5) ;
    $rank_prev                = substr ($user_rec,42, 5) ;
    $first                    = substr ($user_rec,48,10) ;
    $last                     = substr ($user_rec,59,10) ;
    $tenth                    = substr ($user_rec,70,10) ;
    $user                     = substr ($user_rec,81) ;
    $days_first               = int (($dumpdate_gm - $first) / $secsinday) ;
    $days_last                = int (($dumpdate_gm - $last)  / $secsinday) ;

#   if ($edits_namespace_a < 3)
#   { next ; }

    # if ($edits_namespace_a + $edits_namespace_x >= 10)
    if (($edits_namespace_a >= 10) || ($language eq 'strategy'))
    {
      $line_csv = &csv($language) .
                  &csv($edits_namespace_a).
                  &csv($edits_recent_namespace_a).
                  &csv($edits_namespace_x).
                  &csv($edits_recent_namespace_x).
                  &csv($rank_now) .
                  &csv($rank_prev) .
                  &csv($user) .
                  &csv(&mmddyyyy ($first)) .
                  &csv(&mmddyyyy ($last)) .
                  &csv2(&mmddyyyy ($tenth))  ;

#print USERSTATSREG "LINE_CSV $line_csv\n" ;
      push @csv, $line_csv ;
    }

    $users_tot ++ ;
    $edits_tot += $edits_namespace_a ;

    for ($i = 0 ; $i < $bins ; $i++)
    {
      if (@edits_min [$i] <= $edits_namespace_a)
      {
        @users [$i] ++ ;
        @edits [$i] += $edits_namespace_a ;
#print USERSTATSREG "EDITS_NAMESPACE_A $edits_namespace_a I $i EDITS_MIN @{edits_min [$i]} USERS ${users[$i]} EDITS ${edits [$i]}\n" ;
      }
    }
  }

  $timestartsort = time ;
  @csv = sort {&csvkey_lang_rank_first1 ($a) cmp &csvkey_lang_rank_first1 ($b)} @csv ;
  &LogT ("Sorting " . ($#csv+1) . " user records took " . ddhhmmss (time - $timestartsort). ".\n") ;
  &WriteFileCsv ($file_csv_user) ;

  &ReadFileCsv  ($file_csv_edit_distribution) ;
  for ($i = 0 ; $i < $bins ; $i++)
  {
    if (@users [$i] == 0) { last ; }

    $line_csv =
               &csv($language) .
               &csv($i) .
               &csv(sprintf ("%.0f", @edits_min [$i])) .
               &csv(@users [$i]) .
               &csv(sprintf ("%.1f\%", 100 * (@users [$i] / $users_tot))) .
               &csv(@edits [$i]) .
               &csv(sprintf ("%.1f\%", 100 * (@edits [$i] / $edits_tot))) ;
    push @csv, $line_csv ;
    print USERSTATSREG "$line_csv\n" ;
  }
#close USERSTATSREG  ;

# @csv = sort {&csvkey_lang_edits ($b) cmp &csvkey_lang_edits ($b)} @csv ;
# sub csvkey_lang_edits
# {
#   my ($language, $edits_namespace_a) = split (",", (shift)) ;
#   return ($language . sprintf ("%08d", $edits_namespace_a)) ;
# }
  @csv = sort {(($lang,$edits)=split (',', $a),sprintf ("$s %08d", $lang,$edits)) cmp
               (($lang,$edits)=split (',', $b),sprintf ("$s %08d", $lang,$edits))} @csv ;

  &WriteFileCsv ($file_csv_edit_distribution) ;

  &TraceMem ;
  &TraceRelease ("Release table \@user_stats_reg") ;
  undef (@user_stats_reg) ;
}

sub UpdateBotEdits
{
  &LogPhase ("UpdateBotEdits") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_bot_edits) ;

  foreach $user_rec (@user_stats_bot)
  {
    $edits_namespace_a = substr ($user_rec, 0, 8) ;
    $edits_namespace_x = substr ($user_rec,18, 8) ;
    $rank_now          = substr ($user_rec,36, 5) ;
    $rank_prev         = substr ($user_rec,42, 5) ;
    $first             = substr ($user_rec,48,10) ;
    $last              = substr ($user_rec,59,10) ;
    $tenth             = substr ($user_rec,70,10) ;
    $user              = substr ($user_rec,81) ;

    $days_first   = int (($dumpdate_gm - $first) / $secsinday) ;
    $days_last    = int (($dumpdate_gm - $last)  / $secsinday) ;

#   if ($user =~ m/^\d+\.\d+\.\d+\./) { next ; } # moved to RankUSerStats

    $user = convert_unicode ($user) ;

    push @csv, &csv ($language) .
               &csv ($user).
               &csv ($edits_namespace_a).
               &csv ($edits_namespace_x).
               &csv ($rank_now).
               &csv ($rank_prev).
               &csv (&mmddyyyy ($first)).
               &csv ($days_first).
               &csv (&mmddyyyy ($last)).
               &csv ($days_last) ;
  }

  @csv = sort {&csvkey_lang_rank_first3 ($a) cmp &csvkey_lang_rank_first3 ($b)} @csv ;
  &WriteFileCsv ($file_csv_bot_edits) ;

  &TraceRelease ("Release table \@user_stats_bot") ;
  undef (@user_stats_bot) ;
}

sub UpdateAccessLevels
{
  &LogPhase ("UpdateAccessLevels") ;

  my @keys = keys %access ;
  if ($#keys == -1)
  {
    &Log ("No entries in hash \%access -> empty ....-user_groups.sql dump\n") ;
    return ;
  }

  &ReadFileCsv ($file_csv_access_levels) ;

  foreach $key (sort keys %access)
  {
    push @csv, &csv ($language) .
               &csv ($key).
               &csv (@access{$key}) ;
  }
  @csv = sort {$a cmp $b} @csv ;
  &WriteFileCsv ($file_csv_access_levels) ;
}

sub UpdateUsersAnonymous
{
  &LogPhase ("UpdateUsersAnonymous") ;
  &TraceMem ;

  my @csv2 ;
  my $threshold = 10 ;
  if ($filesizelarge)
  { $threshold = 100 ; }

  &ReadFileCsv ($file_csv_anonymous_users) ;

  foreach my $user (keys %userdata)
  {
    my $record = @userdata {$user} ;
    my @fields = split (',', $record) ;
    if (@fields [$useritem_ip_namespace_a] >= $threshold)
    {
      push @csv2, &csv ($language) .
                  &csv  (@fields [$useritem_ip_namespace_a]) .
                  &csv  (@fields [$useritem_ip_namespace_x]) .
                  &csv2 ($user) ;
    }
  }

  if ($#csv2 >= 0)
  {
  # @csv2 = sort {&csvkey_lang_edits ($b) cmp &csvkey_lang_edits ($a)} @csv2 ;
    @csv2 = sort {(($lang,$edits)=split (',', $b),$x=sprintf ("%s %08d", $lang,$edits),$x) cmp
                  (($lang,$edits)=split (',', $a),$y=sprintf ("%s %08d", $lang,$edits),$y)} @csv2 ;
    $users = 0 ;
    foreach $record (@csv2)
    {
      push @csv, $record ;
      # if ($users++ >= 100) { last ; }
    }
  }

# @csv = sort {&csvkey_lang_edits ($b) cmp &csvkey_lang_edits ($a)} @csv ;
  @csv = sort {(($lang,$edits)=split (',', $a),sprintf ("$s %08d", $lang,$edits)) cmp
               (($lang,$edits)=split (',', $b),sprintf ("$s %08d", $lang,$edits))} @csv ;
  &WriteFileCsv ($file_csv_anonymous_users) ;

  &TraceRelease ("Release table \%edits_per_user_ip_namespace_..") ;
  undef (%edits_per_user_ip_namespace_a) ;
  undef (%edits_per_user_ip_namespace_x) ;
}

sub UpdateActiveUsers
{
  &LogPhase ("UpdateActiveUsers") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_active_users) ;

  @user_stats_reg = sort {$b <=> $a} @user_stats_reg ;

  $active_users  = 0 ;
  $recently_active_users = 0 ;
  $scan_users = 50 ;
  foreach $user_rec (@user_stats_reg)
  {
    $edits_namespace_a        = substr ($user_rec, 0, 8) ;
    $edits_recent_namespace_a = substr ($user_rec, 9, 8) ;
    $edits_namespace_x        = substr ($user_rec,18, 8) ;
    $edits_recent_namespace_x = substr ($user_rec,27, 8) ;
    $rank_now                 = substr ($user_rec,36, 5) ;
    $rank_prev                = substr ($user_rec,42, 5) ;
    $first                    = substr ($user_rec,48,10) ;
    $last                     = substr ($user_rec,59,10) ;
    $tenth                    = substr ($user_rec,70,10) ;
    $user                     = substr ($user_rec,81) ;
    $days_first               = int (($dumpdate_gm - $first) / $secsinday) ;
    $days_last                = int (($dumpdate_gm - $last)  / $secsinday) ;

#   if ($user =~ m/^\d+\.\d+\.\d+\./) { next ; } # moved to RankUSerStats

    if ((index (lc($user), "conversion") != -1) ||
        ((index (lc($user), "konvertilo") != -1) & ($language eq "eo")))
    {
      # $scan_users ++ ;
      $conversions = $edits_namespace_a ;
      next ;
    }
    $active_users ++ ;
    if ($days_last <= 28)
    {
      $user = convert_unicode ($user) ;

      push @csv, &csv ($language) .
                 &csv ($user).
                 &csv ($edits_namespace_a).
                 &csv ($edits_recent_namespace_a).
                 &csv ($edits_namespace_x).
                 &csv ($edits_recent_namespace_x).
                 &csv ($rank_now).
                 &csv ($rank_prev).
                 &csv (&mmddyyyy ($first)).
                 &csv ($days_first) ;

      if (++ $recently_active_users >= $scan_users) { last ; } # show max. 50 users
    }
  }
  @csv = sort {&csvkey_lang_rank_first2 ($a) cmp &csvkey_lang_rank_first2 ($b)} @csv ;
  &WriteFileCsv ($file_csv_active_users) ;
}

sub UpdateSleepingUsers
{
  &LogPhase ("UpdateSleepingUsers") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_sleeping_users) ;

  $memorable_absent_users = 0 ;
  $scan_users = 20 ;
  foreach $user_rec (@user_stats_reg)
  {
    $edits_namespace_a = substr ($user_rec, 0, 8) ;
    $edits_namespace_x = substr ($user_rec,18, 8) ;
    $rank_now          = substr ($user_rec,36, 5) ;
    $rank_prev         = substr ($user_rec,42, 5) ;
    $first             = substr ($user_rec,48,10) ;
    $last              = substr ($user_rec,59,10) ;
    $tenth             = substr ($user_rec,70,10) ;
    $user              = substr ($user_rec,81) ;

    $days_first   = int (($dumpdate_gm - $first) / $secsinday) ;
    $days_last    = int (($dumpdate_gm - $last)  / $secsinday) ;

#   if ($user =~ m/^\d+\.\d+\.\d+\./) { next ; } # moved to RankUSerStats

    if ((index (lc($user), "conversion") != -1) ||
        ((index (lc($user), "konvertilo") != -1) & ($language eq "eo")))
    {
      $scan_users++ ;
      next ;
    }

    if ($days_last > 28)
    {
      $memorable_absent_users ++ ;

      $user = convert_unicode ($user) ;

      push @csv, &csv ($language) .
                 &csv ($user).
                 &csv ($edits_namespace_a).
                 &csv ($edits_namespace_x).
                 &csv ($rank_now).
                 &csv ($rank_prev).
                 &csv (&mmddyyyy ($first)).
                 &csv ($days_first).
                 &csv (&mmddyyyy ($last)).
                 &csv ($days_last) ;

      if ($memorable_absent_users >= $scan_users) { last ; } # show max. 20 users
    }
  }
  @csv = sort {&csvkey_lang_rank_first3 ($a) cmp &csvkey_lang_rank_first3 ($b)} @csv ;
  &WriteFileCsv ($file_csv_sleeping_users) ;
}

sub UpdateSizeDistribution
{
  if ($edits_only) { return ; }

  &LogPhase ("UpdateSizeDistribution\n") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_size_distribution) ;
  foreach $line (@size_distribution)
  { push @csv, $line ; }
# @csv = sort {&csvkey_lang_date ($a) cmp &csvkey_lang_date ($b)} @csv ;
  @csv = sort {($x=$a,$x=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$x) cmp ($y=$b,$y=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$y)} @csv ;
  &WriteFileCsv ($file_csv_size_distribution) ;

  &TraceRelease ("Release table \@size_distribution") ;
  undef (@size_distribution) ;
}

sub UpdateEditsPerArticle
{
  if ($edits_only)   { return ; }

  &LogPhase ("UpdateEditsPerArticle") ;
  &TraceMem ;

  &ReadFileCsvAll ($file_csv_edits_per_article2) ;
  if ($#csv == -1)
  {
    &LogT ("No article edit records in temporary file\n") ;
    unlink ($file_csv_edits_per_article) ;
    return ;
  }
  &LogT ($#csv . " article edit records in temporary file\n") ;
# @csv2 = sort {&csvkey_lang_edits ($b) cmp &csvkey_lang_edits ($a)} @csv ;
  @csv2 = sort {(($lang,$edits)=split (',', $b),sprintf ("%s %08d", $lang,$edits)) cmp
                (($lang,$edits)=split (',', $a),sprintf ("%s %08d", $lang,$edits))} @csv ;
  @csv = () ;
  my $lines = 0 ;
  foreach $line (@csv2)
  {
    if (++$lines > 5000)
    { last  ; }
    push @csv, $line ;
  }
  &WriteFileCsv ($file_csv_edits_per_article) ;

  &TraceRelease ("Release table \@csv[2]") ;
  undef (@csv) ;
  undef (@csv2) ;
# unlink $file_csv_edits_per_article2 ;
}

sub UpdateReverts
{
  if ($edits_only)   { return ; }

  &LogPhase ("UpdateReverts") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_monthly_reverts) ;

  my ($year,$month, $flags, $count, $yearmonth_prev, $line) ;
  foreach $key (sort keys %reverts_month)
  {
    $year  = substr ($key,0,4) ;
    $month = substr ($key,4,2) ;
    $flags = substr ($key,6) ;
    $count = $reverts_month{$key} ;
    if ("$year$month" ne $yearmonth_prev)
    {
      push @csv, $line ;
      $line = $language . sprintf (",%02d/%02d/%04d", $month, days_in_month ($year, $month), $year ) ;
    }
    $yearmonth_prev = "$year$month" ;
    $line .= ",$flags:$count" ;
  }
  push @csv, $line ;

  &WriteFileCsv ($file_csv_monthly_reverts) ;

}

sub UpdateZeitGeist
{
  &LogPhase ("UpdateZeitGeist\n") ;
  &TraceMem ;

  my $keyprev = "" ;
  &ReadFileCsv ($file_csv_zeitgeist) ;
  foreach $key (sort keys %zeitgeist_reg_users_rank)
  {
    # if (substr ($key,0,6) ne substr ($keyprev,0,6))
    # { &Log2 ("\n\n") ; }
    # &Log2 ("$key : " . @zeitgeist_reg_users_rank  {$key} . " - " . @zeitgeist_reg_users_title  {$key} . "\n") ;
    push @csv, "$language," . substr ($key,0,6) . "," . substr ($key,6,2) . ",REG," . @zeitgeist_reg_users_rank  {$key} . "," . @zeitgeist_reg_users_title  {$key} ;
    $keyprev = $key ;
  }
# foreach $key (sort keys %ZeitGeistAllUsersRank)
# {
#   if (substr ($key,0,6) ne substr ($keyprev,0,6))
#   { &Log2 ("\n\n") ; }
#   &Log2 ("$key : " . @ZeitGeistAllUsersRank  {$key} . " - " . @ZeitGeistAllUsersTitle  {$key} . "\n") ;
#   push @csv, "$language," . substr ($key,0,6) . "," . substr ($key,6,2) . ",ALL," . @ZeitGeistAllUsersRank  {$key} . "," . @ZeitGeistAllUsersTitle  {$key} ;
#   $keyprev = $key ;
# }

  @csv = sort {$a cmp $b} @csv ;
  &WriteFileCsv ($file_csv_zeitgeist) ;

  &TraceRelease ("Release table \@csv") ;
  undef (@csv) ;
}

sub UpdateNamespaces
{
  &LogPhase ("UpdateNamespaces\n") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_namespaces) ;

  foreach $key (sort {$a <=> $b} keys %namespacesinv)
  {
    my $name = @namespacesinv {$key} ;
    push @csv, "$language,$key,'$name'" ;
  }
  @csv = sort {$a cmp $b} @csv ;

  &WriteFileCsv ($file_csv_namespaces) ;
}

sub UpdateBots
{
  if ($read_stored_bots) { return ; }

  &LogPhase ("UpdateBots") ;
  &ReadFileCsv ($file_csv_bots) ;

  @bots2 = (sort {$a cmp $b} keys %bots) ;
  if ($#bots2 > -1)
  { push @csv, "$language," . join ('|', @bots2) ; }
  @csv = sort {$a cmp $b} #csv ;

  &WriteFileCsv ($file_csv_bots) ;
}

sub UpdateTimelines
{
  if ($mode ne "wp") { return ; }
  if ($edits_only)   { return ; }

  &LogPhase ("UpdateTimelines") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_timelines) ;
  foreach my $NameTimeline (keys %timelines_info)
  {
    my $NameTimeline2 = $NameTimeline ;
    $NameTimeline2 =~ s/,/&comma;/g ;
    push @csv, &csv ($language) . @timelines_info {$NameTimeline} . "," . $NameTimeline2 ;
  }
# @csv = sort {&csvkey_lang_date ($a) cmp &csvkey_lang_date ($b)} @csv ;
  @csv = sort {($x=$a,$x=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$x) cmp ($y=$b,$y=~s/$qr_csvkey_lang_date/$1$4$2$3/o,$y)} @csv ;
  &WriteFileCsv ($file_csv_timelines) ;
}

sub WriteTimelineOverview
{
  if ($mode ne "wp") { return ; }
  if ($edits_only)   { return ; }

  &LogPhase ("WriteTimelineOverview") ;
  &TraceMem ;

  my $text ;

  &WriteHeadersFilesTimelines ;

# $html_timelines .= "<div align='right'><a id='\#$scriptcnt' name='\#$scriptcnt'>End</a></div><hr><hr>\n" ;
  open "FILE_TIMELINES", "<", $file_timelines || abort ("Temp file '$file_timelines' could not be opened.") ;
  while ($line = <FILE_TIMELINES>)
  { $html_timelines .= $line ; }
  close "FILE_TIMELINES" ;

  $html_timelines .= "<p><table border='0' width='100%'><tr><td><small>Generated on " .
                     &GetDateEnglish (time) . " from SQL dump files of " .
                     &GetDateEnglish ($dumpdate_gm) . "</small></td></tr>\n" ;
  $html_timelines .= "<p><tr><td><small>Note: only timelines on article and template pages are shown. Timelines on discussion pages, user pages, etc are ignored.</small></td>\n" ;

  $html_timelines .= "<td align=right valign=bottom><a id='$scriptcnt' name='$scriptcnt'></a><a href='\#top'>Top</a></td><tr></table>" ;
  $html_timelines .= "</body></html>" ;

  $last_timeline_added = 0 ;
  $cnt_timelines = 0 ;

  foreach $key (keys %timelines_info)
  {
    my ($firstedit, $lastedit, $ns, $md5, $user) = split (",", @timelines_info {$key}) ;
    my @md5 = split ('\|', $md5) ;

    if (($ns ne "00") && ($ns ne "10")) { next ; }

    if ($firstedit > $last_timeline_added)
    { $last_timeline_added = $firstedit ; }

    if ($#md5 > 0)
    { $q = "?" ; }
    else
    { $q = "" ; }

    $link_user = "<a href='http://$language.wikipedia.org/wiki/$usertag\:" .
                 encode_url ($user) . "'>" . convert_unicode ($user) . "</a>" ;

    $date1 = &GetDateEnglish ($firstedit) ;
    $date2 = &GetDateEnglish ($lastedit) ;

    if ($date1 eq $date2)
    {  $text = "<p><small>Initial version by $link_user $q on $date1</small>\n" ; }
    else
    {  $text = "<p><small>First version by $link_user $q on $date1, last update on $date2</small>\n" ; }

    foreach $md5b (@md5)
    {
      $cnt_timelines++ ;
      $html_timelines =~ s/\{\{$md5b\}\}/$text/ ;
    }
  }

  if ($cnt_timelines > 0)
  {
    $text = "" ;
    if ($cnt_timelines > 1)
    { $text = "So far $cnt_timelines timelines have been created on this Wikipedia. Last timeline added on " .
              &GetDateEnglish  ($last_timeline_added) ; }

    $file_timelines_skipped = "TimelinesSkipped" . uc ($language) . ".htm" ;
    if ($timelines_skipped > 0)
    { $text .= "<p>$timelines_skipped <a href='$file_timelines_skipped'>very basic, repetitive or bot created timelines</a> not shown here." ; }

    $html_timelines =~ s/\{\{intro\}\}/$text/ ;

    $text = "" ;
    if ($#timelinesTOC > 1)
    {
      $text .= "<hr>Timelines: " ;
      foreach $entry (@timelinesTOC)
      { $text .= $entry . " / " ; }
      $text =~ s/ \/ $// ;
    }
    $html_timelines =~ s/\{\{toc\}\}/$text/ ;

    my $wikipedia = @wikipedias {$language} ;
    $url       = $wikipedia ;
    $url       =~ s/(^[^\s]+).*$/$1/ ;
    $wikipedia =~ s/^[^\s]+\s+(.*)$/$1/ ;
    $text = "<a href='$url'>$wikipedia</a>" ;
    $html_timelines =~ s/\{\{wikipedia\}\}/$text/g ;

    open "FILE_TIMELINES", ">", $file_timelines || abort ("Temp file '$file_timelines' could not be opened.") ;
    print FILE_TIMELINES $html_timelines ;
    close FILE_TIMELINES ;
  }
  else
  { unlink $file_timelines ; }

  if ($timelines_skipped == 0)
  { unlink $file_timelines_skipped ; }
}

sub WriteCategoryInfo
{
  if ($edits_only) { return ; }

  &LogPhase ("WriteCategoryInfo") ;
  &TraceMem ;

  &ReadFileCsv ($file_csv_bots) ;

  open "FILE_CATEGORIES", "<", $file_categories || abort ("File '$file_categories' could not be opened.") ;
  while ($line = <FILE_CATEGORIES>)
  {
    chomp ($line) ;
    ($namespace, $length, $cat, $catlist) = split (',', $line) ;

    if ($namespace == 14)
    { @Categories {$cat} = $catlist ; }

    elsif (($namespace % 2) == 0)
    {
      @CategoryList = split ('\|', $catlist) ;
      foreach $cat (@CategoryList)
      {
        my ($articles, $bytes) = split (",", @CategoryCounts {$cat}) ;
        $articles ++ ;
        $bytes += $length ;
        @CategoryCounts {$cat} = "$articles,$bytes" ;
      }
    }
  }
  close FILE_CATEGORIES ;

  open "FILE_CATEGORIES", ">", $file_csv_categories || abort ("File '$file_csv_categories' could not be opened.") ;
  print FILE_CATEGORIES "#category,belongs to,articles,total byte count of articles\n" ;
  foreach $category (sort keys %Categories)
  {
    my ($articles, $bytes) = split (",", @CategoryCounts {$category}) ;

    $category =~ s/\|/&pipe;/g ;
    $category =~ s/\,/&comma;/g ;
    print FILE_CATEGORIES "$category," . @Categories {$category}. ",". ($articles+0) . "," . ($bytes+0) . "\n" ;
  }
  close "FILE_CATEGORIES";
}

sub WriteWikibooksInfo
{
  if ($edits_only) { return ; }

  &LogPhase ("WriteWikibooksInfo") ;
  &TraceMem ;

  open "FILE_BOOKS", ">", $file_csv_wikibooks || abort ("File '$file_csv_wikibooks' could not be opened.") ;
  print FILE_BOOKS "#book title, chapters, edits, size, words, authors, chapters\n" ;
  foreach my $book (sort { @book_chaptercnt {$b} <=> @book_chaptercnt {$a} } keys %book_chaptercnt)
  {
    my $authors = 0 ;
    my $authorlist = @book_authors {$book} ;
    foreach ($authorlist =~ m/\[\d+\]/g)
    { $authors++ ; }
    my $line =  &csv ($book) .
                &csv (@book_chaptercnt  {$book}) .
                &csv (@book_edits       {$book}) .
                &csv (@book_size        {$book}) .
                &csv (@book_words       {$book}) .
                &csv ($authors) .
                      @book_chapterlist {$book} ;
    $line =~ s/\|$// ;
    print FILE_BOOKS "$line\n" ;
  }
  close "FILE_BOOKS";
}

sub WriteFileCsv
{
  my $file_csv = shift ;
  my $lines = 0 ;
  open "FILE_OUT", ">", $file_csv ;
  foreach $line (@csv)
  {
     $line =~ s/\,$// ;
     if ($line !~ /^\s*$/)
     {
       if ($lines++ > 0)
       { print FILE_OUT "\n" ; }

#       if ($file_csv eq $file_csv_user)
#       {
#         print "1 $line\n" ;
#         $line =~ s/([\x80-\xFF]{2})/'%' . sprintf ("%02X", ord ($1))/ge ;
#         print "2 $line\n" ;
#       }

       print FILE_OUT $line ;
     }
  }
  close "FILE_OUT" ;

  &TraceRelease ("Release table \@csv") ;
  undef (@csv) ;
  &TraceMem ;
}

1;
