
#!/usr/bin/perl
## Collect page views stats by country on Locke
## sub CollectRawData -> SquidDataCountries.csv
## sub ProcessRawData <- SquidDataCountries.csv -> ??

  use SquidCountryScanConfig ;
  print "use EzLib from '$cfg_liblocation'\n" ;
  use lib $cfg_liblocation ;
  use EzLib ;
  $trace_on_exit = $true ;

  use Time::Local ;
  use Getopt::Std ;
  use Cwd;
  $timestart = time ;

  my %options ;
  getopt ("sil", \%options) ;

  $yyyymm_start = $options {"s"} ;
  die "Specify start month as '-s yyyy-dd'" if $yyyymm_start !~ /^\d\d\d\d-\d\d$/ ;

  $path_csv     = $options {"i"} ;
  $path_log     = $options {"l"} ;

  die ("Specify input folder as -i [..]")  if not defined $path_csv ;
  die ("Specify log folder as -i [..]")  if not defined $path_log ;
  die ("Input folder not found")  if ! -d $path_csv ;
  die ("Log folder not found")    if ! -d $path_log ;

  if (! defined ($options {"e"}) && ! defined ($options {"v"}))
  {
    &Log ("Specify '-e' for edits and/or '-v for views\n") ;
    exit ;
 }

# $path_csv = $job_runs_on_production_server ? $cfg_path_csv : $cfg_path_csv_test ;
# $path_log = $job_runs_on_production_server ? $cfg_path_log : $cfg_path_log_test ;
  $file_log = "$path_log/SquidCountryScan.log" ;

  if (defined ($options {"v"})) 
  { 
    $file_raw_data_monthly_visits        = "$path_csv/SquidDataVisitsPerCountryMonthly.csv" ;
    $file_raw_data_daily_visits          = "$path_csv/SquidDataVisitsDaily.csv" ;
    $file_raw_data_daily_visits_wiki     = "$path_csv/SquidDataVisitsPerCountryPerWikiDaily.csv" ;
    $file_raw_data_daily_visits_project  = "$path_csv/SquidDataVisitsPerCountryPerProjectDaily.csv" ;
    $file_raw_data_daily_visits_detailed = "$path_csv/SquidDataVisitsPerCountryDailyDetailed.csv" ;
    $file_per_country_visits             = "public/SquidDataCountriesViews.csv" ;
    $file_per_country_visits_old         = "SquidDataCountries2.csv" ;

    &CollectRawData ('visits', $file_per_country_visits, $file_per_country_visits_old, 
	                       $file_raw_data_monthly_visits, $file_raw_data_daily_visits_wiki, $file_raw_data_daily_visits_wiki, $file_raw_data_daily_visits_project, $file_raw_data_daily_visits_detailed) ; 
  }
  
  if (defined ($options {"e"})) 
  { 
    $file_raw_data_monthly_saves         = "$path_csv/SquidDataSavesPerCountryMonthly.csv" ;
    $file_raw_data_daily_saves           = "$path_csv/SquidDataSavesDaily.csv" ;
    $file_raw_data_daily_saves_wiki      = "$path_csv/SquidDataSavesPerCountryPerWikiDaily.csv" ;
    $file_raw_data_daily_saves_project   = "$path_csv/SquidDataSavesPerCountryPerProjectDaily.csv" ;
    $file_raw_data_daily_saves_detailed  = "$path_csv/SquidDataSavesPerCountryDailyDetailed.csv" ;
    $file_per_country_saves              = "public/SquidDataCountriesSaves.csv" ;
    $file_per_country_saves_old          = "SquidDataCountriesSaves.csv" ;

    &CollectRawData ('saves',  $file_per_country_saves,  $file_per_country_saves_old,  
	                       $file_raw_data_monthly_saves, $file_raw_data_daily_saves, $file_raw_data_daily_saves_wiki, $file_raw_data_daily_saves_project, $file_raw_data_daily_saves_detailed) ; 
  }

# &ProcessRawData ;

  print "\n\nReady\n\n" ;

  exit ;

sub CollectRawData
{
  my ($mode, $file_per_country, $file_per_country_old, $file_raw_data_monthly, $file_raw_data_daily, $file_raw_data_daily_wiki, $file_raw_data_daily_project, $file_raw_data_daily_detailed) = @_ ;
  my ($visits_total, $visits_total_non_bot, $visits_wp_total, $visits_total_wp_en, $visits_per_day, $visits_other, $yyyymmdd, $yyyymm) ;
  my (%visits_monthly, $visits_monthly_non_bot, %visits_daily, %visits_daily_wiki, %visits_daily_project, %visits_wp_yyyymm, %visits_per_project, %visits_per_language, %visits_per_country, %visits_per_day, %visits_wp_b, %visits_wp_u, %correct_for_missing_days) ;
  my (%visits_wp_en, %visits_per_project_language_country, %yyyymmdd_found) ;
  my ($project,$language,$country,$project_language_country,$project_language_country2,$bot,$wiki) ;
  my ($day,$month,$year,$days_in_month,$days_found) ;
  my ($dir,$file,$line) ;
  my ($total, $correction, $total_corrected, $total_corrected_share) ;

  print "Collect raw data for $mode\n\n" ;
  print "Input data per country $file_per_country, $file_per_country_old\n" ;
  print "Raw data monthly       $file_raw_data_monthly\n" ;
  print "Raw data daily per country per wiki    $file_raw_data_daily_wiki\n\n" ;
  print "Raw data daily per country per project $file_raw_data_daily_project\n\n" ;

  $year  = substr ($yyyymm_start,0,4) ;
  $month = substr ($yyyymm_start,5,2) ;

  while ($true)
  {
    $dir  = "$path_csv/" . sprintf ("%04d-%02d", $year, $month) ;
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

          $yyyymmdd_found {$yyyymmdd} ++ ;
        # print "File: $file\n" ;
          open IN, '<', $file or die "Couldn't open $file" ;
          while ($line = <IN>)
          {
            if ($line =~ /^#/) { next ; }

            chomp $line ;
            if ($line =~ ',,')
            { 
              # print "Invalid line '$line'\n" ;  # old bug
              next ;
            }
 
            ($bot,$wiki,$country,$count) = split (',', $line) ;

            if (($mode eq 'visits') && ($yyyymm ge '2015-05')) # switch to hive -> unsampled data!
            {
              $count = sprintf ("%.0f", $count / 1000) ; 
              next if $count < 1 ;
            }                

            if ($bot =~ /Y/)
            { $bot = 'B' ; }
            else
            { $bot = 'U' ; }

            ($project,$language) = split (':', $wiki) ;
            if ($language eq '')
            { 
              ($project,$language) = split ('\.', $wiki) ;
            # print "no lang: wiki $wiki, project $project, lang $language\n" ;
            }
 
            $project =~ s/\s//g ;

          # if ($project ne "wp") { next ; }
          # if ($yyyymm  ne "2009-11") { next ; }
          # if ($language eq "www") { next ; }

          # debug
          # if ($language eq '')
          # { print "file $file, line $line, project $project, lang $langage\n" ; }

            $visits_monthly       {"$yyyymm,$project,$language,$country,$bot"}   += $count ;
            $visits_daily         {"$yyyymmdd,$bot"}                             += $count ;
            $visits_daily_wiki    {"$yyyymmdd,$project,$language,$country,$bot"} += $count ;
            $visits_daily_project {"$yyyymmdd,$project,$country,$bot"}           += $count ;

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

              $visits_per_day {$yyyymmdd} += $count ;

              $visits_per_project_language_country  {"$project,$language,$country"} += $count ;
              $visits_total_non_bot += $count ;
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

  open CSV_MONTHLY, '>', $file_raw_data_monthly  or die "Can't open $file_raw_data_monthly";
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
  open CSV_DAILY, '>', $file_raw_data_daily or die "Can't open $file_raw_data_daily";
  foreach $key (sort keys %visits_daily)
  { print CSV_DAILY "$key,${visits_daily{$key}}\n" ; }
  close CSV_DAILY ;

  open CSV_DAILY, '>', $file_raw_data_daily_wiki or die "Can't open $file_raw_data_daily_wiki";
  foreach $key (sort keys %visits_daily_wiki)
  { print CSV_DAILY "$key,${visits_daily_wiki{$key}}\n" ; }
  close CSV_DAILY ;

  open CSV_DAILY, '>', $file_raw_data_daily_project or die "Can't open $file_raw_data_daily_project";
  foreach $key (sort keys %visits_daily_project)
  { print CSV_DAILY "$key,${visits_daily_project{$key}}\n" ; }
  close CSV_DAILY ;

  foreach $yyyymm (sort keys %visits_wp_yyyymm)
  {
    $total = $visits_wp_yyyymm {$yyyymm} ;
    $correction = $correct_for_missing_days {$yyyymm} ;
    $total_corrected = $total * $correction ;
    $total_corrected_share = int (100 * $total_corrected / $visits_wp_total) ;
    print "$yyyymm: $total * $correction = $total_corrected / $visits_wp_total = $total_corrected_share\%\n" ;
  }

  my $fraction    = 1/5000 ;
  my $threshold   = int ($visits_total_non_bot * $fraction) ;
  my $columns_max = 1000000 ;
  my $bot_perc    = sprintf ("%.1f", 100 * (1 - $visits_total_non_bot/$visits_total)) ;

  print "\nWrite raw details for projects, countries, wikis with over > $fraction of total views (> $threshold)\n\n" ;

  my ($perc,$perc2,$perc_total,$perc2_total) ;
  foreach $project (sort keys %visits_per_project)
  {
    $perc = sprintf ("%.2f", 100 * ($visits_per_project {$project} / $visits_total_non_bot)) ;
    $perc_total += $perc ;
    print "\nproject $project: $perc\% (tot: $perc_total\%)\n\n" ;
    next if $visits_per_project {$project} < $threshold ;
    next if $project eq 'xx' ;

    foreach $country (sort keys %visits_per_country)
    {
      next if $visits_per_country {$country} < $threshold ;
      # print "country $country\n" ;

      foreach $language (sort keys %visits_per_language)
      {
        next if $visits_per_language {$language} < $threshold ;
        next if $visits_per_project_language_country  {"$project,$language,$country"} < $threshold ;
        $perc2= sprintf ("%.2f", 100 * $visits_per_project_language_country  {"$project,$language,$country"}/$visits_total_non_bot) ;
        $perc2_total += $perc2 ;
        print "$project,$language,$country: $perc2\% (total: $perc2_total\%)\n" ;
        push @project_language_country, "$project,$language,$country" ;
      }
    }
  }

  # make sure all days are accounted for
  @yyyymmdd = sort keys %yyyymmdd_found ;
  $yyyymmdd_first = $yyyymmdd [0] ;
  $yyyymmdd_last  = $yyyymmdd [-1] ;

  $yyyy = substr ($yyyymmdd_first,0,4) ;
  $mm   = substr ($yyyymmdd_first,5,2) ;
  $dd   = substr ($yyyymmdd_first,8,2) ;

  while ($yyyymmdd_now lt $yyyymmdd_last)
  {
    $yyyymmdd_now = sprintf ("%4d-%02d-%02d",$yyyy,$mm,$dd) ;
    push @yyyymmdd, $yyyymmdd_now ;
    print "$yyyymmdd_now\n" ;
    $dd++ ;
    if ($dd > &DaysInMonth ($yyyy,$mm))
    {
      $dd = 1 ;
      $mm++ ;
      if ($mm > 12)
      {
        $mm = 1 ;
        $yyyy++ ;
      }
    }
  }

  print "\nShow columns with most page views\n\n" ;
  @project_language_country = sort {$visits_per_project_language_country {$b} <=> $visits_per_project_language_country  {$a}} @project_language_country ;

  open CSV_DAILY_DETAILED, '>', $file_raw_data_daily_detailed or die "Can't open $file_raw_data_daily_detailed";

  print CSV_DAILY_DETAILED "Wikimedia page $mode per day / based on 1:1000 sampled log server -> multiply all counts by 1000 / $bot_perc\% bot traffic excluded / " .
                           " each column shows $mode for one project (e.g. wp=Wikipedia) to one language wiki (e.g. en=English) from one country (e.g. US=United States)\n" ;
  print CSV_DAILY_DETAILED "mob = to mobile site (e.g 'en.m.wikipedia.org') - remainder is to main site (e.g 'en.wikipedia.org') / max columns=$columns_max / threshold=column total > $fraction of overall total\n\n" ;

  print CSV_DAILY_DETAILED ",,,,% of total," ;
  my $columns = 0 ;
  foreach $project_language_country (@project_language_country)
  {
    $perc = sprintf ("%.2f", 100 * $visits_per_project_language_country {$project_language_country}/ $visits_total_non_bot) ;
    print CSV_DAILY_DETAILED "$perc\%," ;
    print "$project_language_country: $perc\n" ;
    last if ++$columns > $columns_max ;
  }
  print CSV_DAILY_DETAILED "\n\n" ;

  print CSV_DAILY_DETAILED "date,date Excel,total $mode,unlisted,% listed ->," ;
  $columns = 0 ;
  foreach $project_language_country (@project_language_country)
  {
    ($project_language_country2 = $project_language_country) =~ s/,/-/g ;
    if ($project_language_country2 =~ /\%/)
    {
      $project_language_country2 =~ s/\%// ;
      $project_language_country2 .= '-mob' ;
    }
    print CSV_DAILY_DETAILED "$project_language_country2," ;
    print "$project_language_country2: " . sprintf ("%.2f", 100 * $visits_per_project_language_country {$project_language_country}/ $visits_total_non_bot) . "\%\n" ;
    last if ++$columns > $columns_max ;
  }
  print CSV_DAILY_DETAILED "\n" ;

  my ($perc_included,$cells_csv,$cells_total,$yyyymmdd_excel) ;
  for $yyyymmdd ( sort @yyyymmdd )
  {
    $columns = 0 ;
    $yyyymmdd_excel = "\"=date(" . substr($yyyymmdd,0,4) . "," . substr($yyyymmdd,5,2) . "," . substr($yyyymmdd,8,2) . ")\"" ;

    $visits_per_day = $visits_per_day {$yyyymmdd} ;

    if ($visits_per_day == 0)
    {
      print CSV_DAILY_DETAILED "$yyyymmdd,$yyyymmdd_excel\n" ;
      next ;
    }

    $cells_csv   = '' ;
    $cells_total = 0 ;
    foreach $project_language_country (@project_language_country)
    {
      $count = $visits_daily_wiki {"$yyyymmdd,$project_language_country,U"} ;
      $cells_csv .= (0 + $count) . "," ; # U = user = no bot
      $cells_total += $count ;
     last if ++$columns > $columns_max ;
    }

    $visits_other = $visits_per_day - $cells_total ;
    $perc_included = sprintf ("%.1f", 100 *  $cells_total / $visits_per_day) ;
    print CSV_DAILY_DETAILED "$yyyymmdd,$yyyymmdd_excel,$visits_per_day,$visits_other,$perc_included\%,$cells_csv\n" ;
  }

  print CSV_DAILY_DETAILED "\nSheet contains $columns columns with basic data\n" ;
  close CSV_DAILY_DETAILED ;
}

# not operational, obsolete? Q&D code?
sub ProcessRawData
{
  print "\nProcessRawData\n\n" ;

  $bots_edits = 0 ;
  $bots_saves = 0 ;
  $user_edits = 0 ;
  $user_saves = 0 ;

  open IN,  '<', $file_raw_data or die "Can't open $file_raw_data";
  open OUT, '>', $file_csv_counts_daily_project or die "Can't open $file_csv_counts_daily_project" ;

  $date_prev = "" ;
  $from = '' ;
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
    # $mime_not_text_html {$mime} ++ ;
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
      { $bots_edits += $count ; }
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

  open CSV_COUNT_DAILY, '>', $file_csv_counts_daily or die "Can't open $file_csv_counts_daily";
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

  $ratio = 'n.a.' ;
  if ($count_submits > 0)
  { $ratio = sprintf ("%5.1f", $count_edits / $count_submits) ; }
  $text .= sprintf ("%-14s",'total') . "edits " . sprintf ("%6d", $count_edits) . ", submits ".  sprintf ("%6d", $count_submits) . ", ratio $ratio\n" ;
  $text .= "\n\n" ;

  $text .= "Count per relevant status with redlink:\n" ;
  foreach $key (sort keys %counts_per_relevant_status_with_redlink)
  {
    $count = $counts_per_relevant_status_with_redlink {$key} ;
    ($to = $key) =~ s/,.*$// ;
    if ($counts_per_destination {$to} < 100) { next ; }
    $text .= sprintf ("%6d", $count) . ",$key\n" ;
  }
  $text .= "\n\n" ;

  open SUMMARY, '>', "$path_log/$file_log" ;
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

sub Log
{
  my $msg = shift ;
  print $msg ;
}

