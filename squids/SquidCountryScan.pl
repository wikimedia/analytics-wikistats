#!/usr/bin/perl
## Collect page views stats by country on Locke
## sub CollectRawData -> SquidDataCountries.csv
## sub ProcessRawData <- SquidDataCountries.csv -> ??

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;

  use Time::Local ;
  use Getopt::Std ;
  use Cwd;
  $timestart = time ;

  my %options ;
  getopt ("y", \%options) ;
  $process_year = $options {"y"} ;
  if (($process_year !~ /^\d\d\d\d$/) || ($process_year < 2009))
  {
    $process_year = 2009 ;
  # print "Specify year as '-y nnnn'\n\n" ;
  # exit ;
  }

  $path_root = "/a/ezachte/" ;
# $path_root = "w:/! perl/squids/archive/" ;

  $file_raw_data_monthly_visits  = "$path_root/SquidDataVisitsPerCountryMonthly.csv" ;
  $file_raw_data_daily_visits    = "$path_root/SquidDataVisitsPerCountryDaily.csv" ;
  $file_per_country_visits       = "public/SquidDataCountriesViews.csv" ;
  $file_per_country_visits_old   = "SquidDataCountries2.csv" ;

  $file_raw_data_monthly_saves   = "$path_root/SquidDataSavesPerCountryMonthly.csv" ;
  $file_raw_data_daily_saves     = "$path_root/SquidDataSavesPerCountryDaily.csv" ;
  $file_per_country_saves        = "public/SquidDataCountriesSaves.csv" ;
  $file_per_country_saves_old    = "SquidDataCountriesSaves.csv" ;

  &CollectRawData ('visits', $file_per_country_visits, $file_per_country_visits_old, $file_raw_data_monthly_visits, $file_raw_data_daily_visits) ;
  &CollectRawData ('saves',  $file_per_country_saves,  $file_per_country_saves_old,  $file_raw_data_monthly_saves,  $file_raw_data_daily_saves) ;
# &ProcessRawData ;

  exit ;

sub CollectRawData
{
  my ($mode, $file_per_country, $file_per_country_old, $file_raw_data_monthly, $file_raw_data_daily) = @_ ;
  my ($visits_wp_total, $visits_total_wp_en) ;
  my (%visits_monthly, %visits_daily, %visits_wp_yyyymm, %visits_per_project, %visits_per_language, %visits_per_country, %visits_wp_b, %visits_wp_u, %correct_for_missing_days) ;

  print "Collect raw data for $mode\n\n" ;
  print "Input data per country $file_per_country, $file_per_country_old\n" ;
  print "Raw data monthly       $file_raw_data_monthly\n" ;
  print "Raw data daily         $file_raw_data_daily\n\n" ;

  $year  = $process_year ;
  if ($year == 2009)
  { $month = 7 ; }
  else
  { $month = 1 ; }

  while ($true)
  {
    $dir  = "$path_root/" . sprintf ("%04d-%02d", $year, $month) ;
    $yyyymm = sprintf ("%04d-%02d", $year, $month) ;
    if (-d $dir)
    {
      print "Dir:  $dir\n" ;
      $days_in_month = &DaysInMonth ($year,$month) ;

      $days_found = 0 ;
      for ($day = 1 ; $day <= $days_in_month ; $day++)
      {
        if (($month == 4) && ($year == 2009) && ($day < 18)) { next ; }

        $yyyymmdd = sprintf ("%04d-%02d-%02d", $year, $month, $day) ;

        # do not combine with SquidDataCountries.csv from earlier months
        # only from 2009-07 anonymous bots (hits > 1 in sampled log) were ignored
        $file = "$dir/" . sprintf ("%04d-%02d-%02d", $year, $month, $day) . "/$file_per_country_old" ;
        # print "READ1 $file\n" ;
        if (! -e $file)
        {
          $file = "$dir/" . sprintf ("%04d-%02d-%02d", $year, $month, $day) . "/$file_per_country" ;
          # print "READ2 $file\n" ;
        }

        if (-e $file)
        {
          $days_found++ ;
        # print "File: $file\n" ;
          open IN, '<', $file ;
          while ($line = <IN>)
          {
            if ($line =~ /^#/) { next ; }

            chomp $line ;
            ($bot,$wiki,$country,$count) = split (',', $line) ;

            if ($bot =~ /Y/)
            { $bot = 'B' ; }
            else
            { $bot = 'U' ; }

            ($project,$language) = split (':', $wiki) ;
            $project =~ s/\s//g ;

          # if ($project ne "wp") { next ; }
          # if ($yyyymm  ne "2009-11") { next ; }
          # if ($language eq "www") { next ; }

            $visits_monthly {"$yyyymm,$project,$language,$country,$bot"} += $count ;
            $visits_daily   {"$yyyymmdd,$project,$language,$country,$bot"} += $count ;

            # following hashes for specific research, not for regular csv files
            if (($project eq "wp") && ($bot eq 'U') && ($country ne "--"))
            {
              $visits_wp_yyyymm {$yyyymm} += $count ;
              $visits_wp_total += $count ;
            }

            if (($project eq "wp") && ($language eq "en") && ($bot eq 'U') && ($country ne "--"))
            {
              $visits_total_wp_en += $count ;
              $visits_wp_en {$country} += $count ;
            }

            if (($bot eq 'U') && ($country ne "--"))
            {
              $visits_per_project  {$project} += $count ;
              $visits_per_language {$language} += $count ;
              $visits_per_country  {$country} += $count ;
            }

            $visits_total += $count ;

            if (($project eq "wp") && ($language =~ /^(?:th|sk)$/))
            {
              if ($bot eq 'U')
              { $visits_wp_u {"$language $yyyymm"} += $count ; }
              else
              { $visits_wp_b {"$language $yyyymm"} += $count ; }
            }
          }
          close IN ;
        }
        else
        { print "Miss! $file\n" ; }
      }
      $correct_for_missing_days {$yyyymm} = 1 ;
      if (($days_found > 0) && ($days_in_month > $days_found))
      {
        $correct_for_missing_days {$yyyymm} = $days_in_month / $days_found ;
        print "Correct for $yyyymm: $days_found -> $days_in_month = * ${correct_for_missing_days {$yyyymm}}\n" ;
      }
    }
    else
    {
      print "Folder $dir not found. Processing complete.\n" ;
      last ;
    }

    $month++ ;
    if ($month > 12)
    {
      $month =1 ;
      $year ++ ;
    # last ;
    }
  }

  print "\nVisits per project:\n" ;
  foreach $key (sort {$visits_per_project {$b} <=> $visits_per_project {$a} } keys %visits_per_project)
  {
    print sprintf ("%9d", $visits_per_project {$key}) . "  " .sprintf ("%5.2f", 100 * $visits_per_project {$key}/$visits_total) . "% $key\n" ;
  }

  print "\n\n" ;

  print "\nVisits per country:\n" ;
  foreach $key (sort {$visits_per_country {$a} <=> $visits_per_country {$b}} keys %visits_per_country)
  {
    print sprintf ("%9d", $visits_per_country {$key}) . "  " .sprintf ("%6.3f", 100 * $visits_per_country {$key}/$visits_total) . "% $key\n" ;
  }

  print "\nWikipedia visits per country:\n" ;
  foreach $key (sort {$visits_wp_u {$b} cmp $visits_wp_u {$a}} keys %visits_wp_u)
  {
    print sprintf ("%9.1f", ($visits_wp_u {$key} +  $visits_wp_b {$key}) /1000) . " - " . sprintf ("%9.1f", $visits_wp_u {$key} /1000) . " - " . sprintf ("%9.1f", $visits_wp_b {$key} /1000) . " $key\n" ; # / 1000 on 1:1000 sampled file is millions
  }

  print "\nVisits per language:\n" ;
  foreach $key (sort {$visits_per_language {$a} <=> $visits_per_language {$b}} keys %visits_per_language)
  {
    print sprintf ("%9d", $visits_per_language {$key}) . "  " .sprintf ("%6.3f", 100 * $visits_per_language {$key}/$visits_total)  . "% $key\n" ;
  }

  print "\nVisits to English Wikipedia\n" ;
  foreach $key (sort {$visits_wp_en {$a} <=> $visits_wp_en {$b}} keys %visits_wp_en)
  {
    print sprintf ("%9d", $visits_wp_en {$key}) . "  " .sprintf ("%6.3f", 100 * $visits_wp_en {$key}/$visits_total_wp_en)  . "% $key\n" ;
  }

  print "\n\n" ;

  print "\n\n" ;

#  foreach $key (sort keys %visits)
#  {
#    if ($key !~ /wq/) { next ; }
#    print sprintf ("%5d", $visits {$key}) . " $key\n" ;
#  }

  open CSV_MONTHLY, '>', $file_raw_data_monthly ;
  foreach $key (sort keys %visits_monthly)
  {
    ($yyyymm, $project, $language, $country) = split (',', $key) ;
    $correction = $correct_for_missing_days {$yyyymm} ;
    $count = $visits_monthly{$key} ;
    $count2 = $count ;
    if (($correction != 0) && ($correction != 1))
    {
      $count2 = $count ;
      $count  = sprintf ("%.0f", $count * $correction) ;
    # print "$yyyymm: $count2 -> $count (=* $correction)\n" ;
    }
    print CSV_MONTHLY "$key,$count\n" ;
  }
  close CSV_MONTHLY ;

  # note correct for missing days in follow processing, see monthly data above
  open CSV_DAILY, '>', $file_raw_data_daily ;
  foreach $key (sort keys %visits_daily)
  { print CSV_DAILY "$key,${visits_daily{$key}}\n" ; }
  close CSV_DAILY ;

  foreach $yyyymm (sort keys %visits_wp_yyyymm)
  {
    $total = $visits_wp_yyyymm {$yyyymm} ;
    $correction = $correct_for_missing_days {$yyyymm} ;
    $total_corrected = $total * $correction ;
    $total_corrected_share = int (100 * $total_corrected / $visits_wp_total) ;
    print "$yyyymm: $total * $correction = $total_corrected / $visits_wp_total = $total_corrected_share\%\n" ;
  }
}

sub ProcessRawData
{
  print "\nProcessRawData\n\n" ;

  open IN,  '<', $file_raw_data ;
  open OUT, '>', $file_csv_counts_daily_project ;

  $date_prev = "" ;

  while ($line = <IN>)
  {
    $lines++ ;
    chomp ($line) ;
  # ($date,$bot,$from,$to,$php,$status,$mime,$action,$agent,$count) = split (',', $line) ;
    ($date,$bot,$from,$to,$status,$mime,$action,$count) = split (',', $line) ;

# if ($to !~ /wk:lt/) { next ; }

    if ($bot =~ /^#/) { next ; } # fix, should be removed in CollectRawData

  # if ($php ne "php(index.php)") { $lines_unexpected_php {$php}++ ; next ; }

    $action2 = $action ;
    $action2 =~ s/\&.*$// ;
    $counts_per_action {"$action2"} += $count ;

    $action =~ s/\&amp;/&/g ;

    if ($action =~ /submitlogin/)
    { next ; }

    if (($action !~ /^action=edit\&/) && ($action !~ /^action=submit\&/) )
    {
      $invalid_actions ++ ;
      next ;
    }

    if ($mime ne "text/html")
    {
      $mime_not_text_html {$mime} ++ ;
      next ;
    }

    if (! ((($action =~ /action=edit/)   && ($status =~ /200/)) ||
           (($action =~ /action=submit/) && ($status =~ /302/))))
    { next ; }

    $counts_per_relevant_action_and_status1 {"$action2"} += $count ;

    $counts_per_bot_relevant_action_and_status2 {"$bot,$action2,$status"} += $count ;

    if ($action !~ /redlink/)
    {
      $counts_per_relevant_action_and_status_no_redlink {"$action2,$status"} += $count ;

      $counts_per_bot_relevant_action_and_status_no_redlink {"$bot,$status,$action2"} += $count ;

      if ($bot =~ /N/)
      {
      # print "$to,$action2,$count\n" ;
        $counts_no_bot_per_relevant_action_and_status_no_redlink {"$to,$action2"} += $count ;
        $counts_no_bot_no_redlink_per_destination {$to} += $count ;
      }
    }

    if (($action =~ /redlink/) && ($status =~ /(?:200|302)/))
    {
      $counts_per_relevant_status_with_redlink {"$to,action=edit,redlink=..,$status"} += $count ;
      $counts_per_destination {$to} += $count ;
    }

    if ($action =~ /redlink/)
    { next ; }

    if (($to !~ /wp:(?:en|de|ja|es|fr|ru|zh)$/) && ($to !~ /wk:(?:lt)$/) && ($to !~ /wx:(?:mw)$/))
    { next ; }

    if ($bot !~ /N/)
    { next ; }

    $counts {"$date,$to,$action2"} += $count ;
    $dates {$date}++ ;
    $tos {$to}++ ;

    if ($bot eq "bot=Y")
    {
      if ($action =~ /action=edit/)
      {$ bots_edits += $count ; }
      elsif ($action =~ /action=submit/)
      { $bots_saves += $count ; }
    }
    else
    {
      if ($action =~ /action=edit/)
      {$user_edits += $count ; }
      elsif ($action =~ /action=submit/)
      { $user_saves += $count ; }
    }
  }


  print OUT "date," ;
  foreach $to (sort keys %tos)
  { print OUT "edits $to,saves $to,ratio $to," ; }
  print OUT "\n" ;

  foreach $date (sort keys %dates)
  {
  # print "DAY $date\n" ;
    $csv_date = "\"=DATE(" . substr ($date,0,4) . "," . substr ($date,4,2) . "," . substr ($date,6,2) . ")\"" ;

    print OUT "$csv_date, " ;

    foreach $to (sort keys %tos)
    {
      # print "TO $to\n" ;

      $edits   = $counts {"$date,$to,action=edit"} ;
      $submits = $counts {"$date,$to,action=submit"} ;
      $ratio   = -1 ;
      if ($submits > 0)
      { $ratio = sprintf ("%.1f", $edits/$submits) ; }
      print OUT "$edits,$submits,$ratio," ;
    }
    print OUT "\n" ;
  }

 # Write CSV_COUNT_DAILY

  open CSV_COUNT_DAILY, '>', $file_csv_counts_daily ;
  foreach $key (sort keys %counts)
  { print CSV_COUNT_DAILY sprintf ("%6d", $counts {$key}) . ",$key\n" ; }
  close CSV_COUNT_DAILY ;

  $text = "" ;
  $text .= "\nInvalid actions: $invalid_actions\n\n" ;

  $text .= "Counts per action:\n" ;
  foreach $key (sort keys %counts_per_action)
  {
    $count = $counts_per_action {$key} ;
    if ($count < 5) { next ; }
    $text .= sprintf ("%6d", $count) . ",$key\n" ;
  }
  $text .= "\n\n" ;

  $text .= "Counts per relevant action and status:\n" ;
  foreach $key (sort keys %counts_per_relevant_action_and_status1)
  {
    $count = $counts_per_relevant_action_and_status1 {$key} ;
    # if ($count < 5) { next ; }
    $text .= sprintf ("%6d", $count) . ",$key\n" ;
  }
  $text .= "\n\n" ;

  $text .= "Counts per bot, relevant action and status:\n" ;
  foreach $key (sort keys %counts_per_bot_relevant_action_and_status2)
  {
    $count = $counts_per_bot_relevant_action_and_status2 {$key} ;
    # if ($count < 5) { next ; }
    $text .= sprintf ("%6d", $count) . ",$key\n" ;
  }
  $text .= "\n\n" ;

  $text .= "Counts per relevant action and status and no redlinks:\n" ;
  foreach $key (sort keys %counts_per_relevant_action_and_status_no_redlink)
  {
    $count = $counts_per_relevant_action_and_status_no_redlink {$key} ;
    if ($count < 5) { next ; }
    $text .= sprintf ("%6d", $count) . ",$key\n" ;
  }
  $text .= "\n\n" ;

  $text .= "Count per bot, relevant action and status and no redlink:\n" ;
  foreach $key (sort keys %counts_per_bot_relevant_action_and_status_no_redlink)
  {
    $count = $counts_per_bot_relevant_action_and_status_no_redlink {$key} ;
    # if ($count < 5) { next ; }
    $text .= sprintf ("%-33s",$key) . sprintf ("%6d", $count) . "\n" ;
  }
  $text .= "\n\n" ;

  $text .= "Counts no bot, per relevant action and status no redlink:\n" ;
  foreach $key (sort keys %counts_no_bot_per_relevant_action_and_status_no_redlink)
  {
    ($to = $key) =~ s/,.*$// ;
    if ($to !~ /:/) { next ; }
    if ($counts_no_bot_no_redlink_per_destination {$to} < 100) { next ; }
    $count = $counts_no_bot_per_relevant_action_and_status_no_redlink {$key} ;
    if ($key =~ /action=edit/)
    {
      $count_edit     = $counts_no_bot_per_relevant_action_and_status_no_redlink {"$to,action=edit"} ;
      $count_submit   = $counts_no_bot_per_relevant_action_and_status_no_redlink {"$to,action=submit"} ;
      $count_edits   += $count_edit ;
      $count_submits += $count_submit ;
      $ratio = '..' ;
      if ($count_submit > 0)
      { $ratio = sprintf ("%5.1f", $count_edit / $count_submit) ; }
      push @ratios, "$ratio|" . sprintf ("%-14s",$to) . "edits " . sprintf ("%6d", $count_edit) . ", submits ".  sprintf ("%6d", $count_submit) . ", ratio $ratio\n" ;
    }
  # $text .= sprintf ("%-33s",$key) . sprintf ("%6d", $count) . "\n" ;
  }
  @ratios = sort {$b <=> $a} @ratios ;
  foreach $line (@ratios)
  {
    ($ratio, $line) = split ('\|', $line) ;
    $text .= $line ;
  }
  $ratio = sprintf ("%5.1f", $count_edits / $count_submits) ;
  $text .= sprintf ("%-14s",'total') . "edits " . sprintf ("%6d", $count_edits) . ", submits ".  sprintf ("%6d", $count_submits) . ", ratio $ratio\n" ;
  $text .= "\n\n" ;
  print $count

  $text .= "Count per relevant status with redlink:\n" ;
  foreach $key (sort keys %counts_per_relevant_status_with_redlink)
  {
    $count = $counts_per_relevant_status_with_redlink {$key} ;
    ($to = $key) =~ s/,.*$// ;
    if ($counts_per_destination {$to} < 100) { next ; }
    $text .= sprintf ("%6d", $count) . ",$key\n" ;
  }
  $text .= "\n\n" ;

  open SUMMARY, '>', $file_txt_summary ;
  print SUMMARY $text ;
  close SUMMARY ;

  print $text ;
}


sub DaysInMonth
{
  my $year = shift ;
  my $month = shift ;
  my $timegm1 = timegm (0,0,0,1,$month-1,$year-1900) ;
  $month++ ;
  if ($month > 12)
  { $month = 1 ; $year++ }
  my $timegm2 = timegm (0,0,0,1,$month-1,$year-1900) ;
  my $days = ($timegm2-$timegm1) / (24*60*60) ;
  return ($days) ;
}
