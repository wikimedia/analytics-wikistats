#!/usr/bin/perl

no warnings 'uninitialized';

sub ParseArguments
{
  my $options ;
  getopt ("ldiopmsvr", \%options) ;

  foreach $key (keys %options)
  {
    $options {$key} =~ s/^\s*(.*?)\s*$/$1/ ;
    $options {$key} =~ s/^'(.*?)'$/$1/ ;
    $options {$key} =~ s/\@/\\@/g ;
  }

  $csv_only = defined ($options {"c"}) ;

  abort ("Specify language code as: -l xx") if (! defined ($options {"l"})) ;
# abort ("Specify SQL dump date as: -d yyyymmdd") if (! defined ($options {"d"})) ;
  abort ("Specify input folder for csv files as: -i path") if (! defined ($options {"i"})) ;
  abort ("Specify output folder for html files as: -o path") if (! defined ($options {"o"})) ;

  $language      = $options {"l"} ;
# $dumpdate      = $options {"d"} ;
  $path_in       = $options {"i"} ;
  $path_out      = $options {"o"} ;
  $path_pl       = $options {"p"} ;
  $gif2png       = $options {"g"} ;
  $mode          = $options {"m"} ;
  $site          = $options {"s"} ;
  $categorytrees = $options {"c"} ;
  $animation     = $options {"a"} ;
  $pageviews     = $options {"v"} ;
  $region        = $options {"r"} ;
  $normalize_days_per_month = $options {"n"} ;

# Indian languages
# as Assamese (http://as.wikipedia.org)
# bn Bengali (http://bn.wikipedia.org)
# bh Bhojpuri (http://bh.wikipedia.org)
# bpy Bishnupriya Manipuri (http://bpy.wikipedia.org)
# my Burmese (http://my.wikipedia.org)
# gu Gujarathi (http://gu.wikipedia.org)
# hi Hindi (http://hi.wikipedia.org)
# kn Kannada (http://kn.wikipedia.org)
# ks Kashmiri (http://ks.wikipedia.org)
# ml Malayalam (http://ml.wikipedia.org)
# mr Marathi (http://mr.wikipedia.org)
# ne Nepali (http://ne.wikipedia.org)
# new Nepal Bhasha/Newari (http://new.wikipedia.org)
# or Odia (Oriya) (http://or.wikipedia.org)
# pi Pali (http://pi.wikipedia.org)
# pa Punjabi (http://pa.wikipedia.org)
# sa Sanskrit (http://sa.wikipedia.org)
# sd Sindhi (http://sd.wikipedia.org)
# si Sinhala (http://si.wikipedia.org)
# ta Tamil (http://ta.wikipedia.org)
# te Telugu (http://te.wikipedia.org)
# ur Urdu (http://ur.wikipedia.org)
  $wp_1st = "en" ;
  $wp_2nd = "de" ;
  if ($region =~ /^india$/i) #misuse language
  {
    $region = lc $region ;
    $some_languages_only = $true ;
    foreach my $wp qw(as bn bh bpy en gu hi kn ks ml mr my ne new or pi pa sa sd si ta te ur)
    {
      $include_language {$wp}     = $true ;
      $include_language {"$wp.m"} = $true ; # also mobile
      $languages_region .= "$wp," ;
    }

    $wp_1st = "ta" ;
    $wp_2nd = "hi" ;
  }
  elsif ($region =~ /^(?:africa|america|asia|europe|oceania|artificial)$/i) #misuse language
  {
    $region = lc $region ;
    $region_uc = ucfirst $region ;
    $some_languages_only = $true ;

    if ($region =~ /africa/i)
    {
      $region_filter = ',AF,' ;
      $wp_1st = "ar" ;
      $wp_2nd = "af" ;
    }
    if ($region =~ /america/i)
    {
      $region_filter = ',NA,SA,' ;
      $wp_1st = "en" ;
      $wp_2nd = "es" ;
    }
    if ($region =~ /asia/i)
    {
      $region_filter = ',AS,' ;
      $wp_1st = "ja" ;
      $wp_2nd = "id" ;
    }
    if ($region =~ /europe/i)
    {
      $region_filter = ',EU,' ;
      $wp_1st = "en" ;
      $wp_2nd = "de" ;
    }
    if ($region =~ /oceania/i)
    {
      $region_filter = ',OC,' ;
      $wp_1st = "fi" ;
      $wp_2nd = "hif" ;
    }
    if ($region =~ /artificial/i)
    {
      $region_filter = ',AL,' ;
      $wp_1st = "eo" ;
      $wp_2nd = "ia" ;
    }

    # code duplication - streamline !
    foreach my $wp (keys %wikipedias)
    {
      my $wikipedia = $wikipedias {$wp} ;
      if ($wikipedia =~ /\[.*\]/)
      {
        $wikipedia =~ s/^.*?\[// ;
        $wikipedia =~ s/\].*$// ;
        my ($speakers, $regions) = split (',', $wikipedia,2) ;
        my @regions = split (',', $regions) ;

        foreach my $region (@regions)
        {
          if (index ($region_filter, ",$region,") > -1)
          {
            $include_language {$wp}     = $true ;
            $include_language {"$wp.m"} = $true ; # also mobile
            $languages_region .= "$wp," ;
          }
        }
      }
    }
  }

  if ($region ne '')
  {
    $languages_region =~ s/,$// ;
    &Log ("Process region " . ucfirst ($region) . "\nLanguages $languages_region\n\n") ;
  }

  $langcode = uc ($language) ;
  $testmode = ((defined $options {"t"}) ? $true : $false) ;

  if (defined $pageviews)
  {
    if ($pageviews eq 'n')
    { $pageviews_normal = $true ; print "Generate page views report for non-mobile site" ; }
    elsif ($pageviews eq 'm')
    { $pageviews_mobile = $true ; print "Generate page views report for mobile site" ; }
    else { abort ("Invalid option for pageviews: specify '-v n' for non-mobile or '-v m' for mobile data") ; }

    $pageviews = $true ;

    if ($pageviews_normal && $normalize_days_per_month)
    { $keys_html_pageviews_all_projects = 'non-mobile,normalized' ; }
    elsif ($pageviews_normal && (! $normalize_days_per_month))
    { $keys_html_pageviews_all_projects = 'non-mobile,not-normalized' ; }
    elsif ((! $pageviews_normal) && $normalize_days_per_month)
    { $keys_html_pageviews_all_projects = 'mobile,normalized' ; }
    else
    { $keys_html_pageviews_all_projects = 'mobile,not-normalized' ; }
    print "\nCollect pageviews for $keys_html_pageviews_all_projects\n\n" ;
  }

  if (defined $animation)
  { undef $pageviews ; undef $categorytrees ; }

  if ($mode eq "")
  { $mode = "wp" ; }
  if ($mode !~ /^(?:wb|wk|wn|wp|wq|ws|wv|wx)$/)
  { abort ("Specify mode as: -m [wb|wk|wn|wp|wq|ws|wv|wx]\n(wp=wikipedia (default), wb=wikibooks, wk=wiktionary, wn=wikinews, wq=wikiquote, ws=wikisource, wv=wikiversity, wx=wikispecial)") ; }

  if ($mode eq "wb") { $mode_wb = $true ; }
  if ($mode eq "wk") { $mode_wk = $true ; }
  if ($mode eq "wn") { $mode_wn = $true ; }
  if ($mode eq "wp") { $mode_wp = $true ; }
  if ($mode eq "wq") { $mode_wq = $true ; }
  if ($mode eq "ws") { $mode_ws = $true ; }
  if ($mode eq "wv") { $mode_wv = $true ; }
  if ($mode eq "wx") { $mode_wx = $true ; }

# if (! ($dumpdate =~ m/^\d{8,8}$/))
# { abort ("Specify SQL dump date as: -d yyyymmdd\n") ; }
# $filedate = timegm (0,0,0,substr($dumpdate,6,2),
#                           substr($dumpdate,4,2)-1,
#                           substr($dumpdate,0,4)-1900) ;
# $testmode = defined ($options {"t"}) ; # use input files with language code

  if ($path_in =~ /\\/)
  { $path_in  =~ s/[\\]*$/\\/ ; } # make sure there is one trailing (back)slash
  else
  { $path_in  =~ s/[\/]*$/\// ; }

  if ($path_out =~ /\\/)
  {
    $path_out =~ s/[\\]*$/\\/ ;
    $path_out_timelines = $path_out . "EN\\" ;
    $path_out .= uc ($language) ;
  }
  else
  {
    $path_out =~ s/[\/]*$/\// . "\/" . uc ($language);
    $path_out_timelines = $path_out . "EN\/" ;
    $path_out .= uc ($language) ;
  }
  if ($region ne '')
  { $path_out .= '_' . ucfirst ($region) ; }
  $path_out .= "\/" ;

  $path_out_categories = $path_out_timelines ;
  $path_out_wikibooks  = $path_out_timelines ;

  if (defined ($path_pl))
  {
    if ((! ($path_pl =~ /\\$/)) &&
        (! ($path_pl =~ /\/$/)))
    {
      if ($path_pl =~ /\\/)
      { $path_pl .= "\\" ; }
      else
      { $path_pl .= "\/" ; }
    }
    if ((! -e $path_pl . "pl") &&
        (! -e $path_pl . "pl.exe"))
    { abort ("Ploticus not found in folder $path_pl") ; }
  }

  if (! -d $path_in)
  { abort ("Input directory '" . $path_in . "' not found.") ; }

  if (! -d $path_out)
  { mkdir $path_out, 0777 ; }

  if (($mode_wp) && $mediawiki)
  {
    if (! -d $path_out_timelines)
    { mkdir $path_out_timelines, 0777 ; }
  }

  if (! -d $path_out)
  { abort ("Output directory '" . $path_out . "' not found and could not be created") ; }


if ($false)
{
  $path_out_plots = $path_out . "Plots" ;
  if ($path_out =~ /\\/)
  { $path_out_plots .= "\\" ; }
  else
  { $path_out_plots .= "\/" ; }
  if (! -d $path_out_plots . "Images")
  { mkdir $path_out_plots, 0777 ; }
  if (! -d $path_out_plots)
  { abort ("Output directory '" . $path_out_plots . "' not found and could not be created") ; }
}
else
{ $path_out_plots = $path_out ; }

  $file_csv_stats_ploticus        = $path_in . "StatisticsPlotInput.csv" ;
  $file_csv_monthly_stats         = $path_in . "StatisticsMonthly.csv" ;
  $file_csv_namespace_stats       = $path_in . "StatisticsPerNamespace.csv" ;
  $file_csv_weekly_stats          = $path_in . "StatisticsWeekly.csv" ;
  $file_csv_users                 = $path_in . "StatisticsUsers.csv" ;
  $file_csv_active_users          = $path_in . "StatisticsActiveUsers.csv" ;
  $file_csv_bot_edits             = $path_in . "StatisticsBots.csv" ;
  $file_csv_bots                  = $path_in . "Bots.csv" ;
  $file_csv_access_levels         = $path_in . "StatisticsAccessLevels.csv" ;
  $file_csv_sleeping_users        = $path_in . "StatisticsSleepingUsers.csv" ;
  $file_csv_size_distribution     = $path_in . "StatisticsSizeDistribution.csv" ;
  $file_csv_edit_distribution     = $path_in . "StatisticsEditDistribution.csv" ;
  $file_csv_edits_per_day         = $path_in . "StatisticsEditsPerDay.csv" ;
  $file_csv_anonymous_users       = $path_in . "StatisticsAnonymousUsers.csv" ;
  $file_csv_webalizer_monthly     = $path_in . "StatisticsWebalizerMonthly.csv" ;
  $file_csv_web_requests_daily    = $path_in . "StatisticsWebRequestsDaily.csv" ;
  $file_csv_web_visits_daily      = $path_in . "StatisticsWebVisitsDaily.csv" ;
  $file_csv_timelines             = $path_in . "StatisticsTimelines.csv" ;
  $file_csv_log                   = $path_in . "StatisticsLog.csv" ;
  $file_csv_binaries_stats        = $path_in . "StatisticsPerBinariesExtension.csv" ;
  $file_csv_language_codes        = $path_in . "LanguageCodes.csv" ;
  $file_csv_zeitgeist             = $path_in . "ZeitGeist.csv" ;
  $file_csv_pageviewsmonthly      = $path_in . "PageViewsPerMonthAll.csv" ;
  $file_csv_edits_per_article     = $path_in . "EditsPerArticle.csv" ;
  $file_csv_users_activity_spread = $path_in . "StatisticsUserActivitySpread.csv" ;
  $file_csv_views_yearly_growth   = $path_in . "PageViewsGrowthLastYear.csv" ;
  $file_csv_growth                = $path_in . "WikimediaGrowthStats.csv" ;
  $file_txt_growth                = $path_in . "WikimediaGrowthStats.txt" ;

  $file_csv_user_activity_trends  = $path_in . "UserActivityTrends.csv" ;
  $file_csv_namespaces            = $path_in . "Namespaces.csv" ;
  $file_edits_per_namespace       = $path_in . "StatisticsEditsPerNamespace.csv" ;
  $file_edits_per_usertype        = $path_in . "StatisticsEditsPerUsertype.csv" ;

  $file_log                       = $path_in . "WikiReportsLog.txt" ;
  $file_errors                    = $path_in . "WikiReportsErrors.txt" ;

  $file_csv_participation         = $path_in . "Participation.csv" ;
  $file_csv_language_names_php    = $path_in . "LanguageNamesViaPhp.csv" ;
  $file_csv_language_names_wp     = $path_in . "LanguageNamesViaWpEn.csv" ;
  $file_csv_language_names_wp_cl  = $path_in . "LanguageNamesViaWpEnEdited.csv" ;
  $file_csv_language_names_diff   = $path_in . "LanguageNamesViaPhpAndWpCompared.csv" ;
  $file_csv_translatewiki         = $path_in . "TranslateWiki.csv" ;

  $file_csv_pageviewsmonthly_html = $path_in . "PageViewsPerMonthHtmlAllProjects.csv" ;

  $file_publish                   = $path_out . "#publish.txt" ;

  if ($testmode)
  { unlink $file_log ; }
#  $path_timelines_out = $path_in ; # . "Timelines" ;
#  if ($path_in =~ /\\/)
#  { $path_timelines .= "\\" ; }
#  else
#  { $path_timelines .= "\/" ; }
#  if (! -d $path_timelines)
#  { mkdir $path_timelines, 0777 ; }
#  if (! -d $path_timelines)
#  { abort ("Output directory '" . $path_timelines . "' not found and could not be created") ; }
  $file_timelines                 = $path_out_timelines . "IndexTimelines.htm" ;
# $file_animation_projects_growth = $path_out . "AnimationProjectsGrowth.js" ;
  $file_animation_projects_growth    = "W:/@ Visualizations/Animation Projects Growth/AnimationProjectsGrowthInit".ucfirst($mode).".js" ;
  $file_animation_size_and_community = "W:/@ Visualizations/Animation Size And Community/AnimationProjectsGrowthInit".ucfirst($mode).".js" ;

  if ($pageviews)
  {
    if (! -e $file_csv_pageviewsmonthly)
    { abort ("CSV file '" . $file_csv_pageviewsmonthly . "' not found or in use") ; }
    return ;
  }

  if (! -e $file_csv_monthly_stats)
  { abort ("CSV file '" . $file_csv_monthly_stats . "' not found or in use") ; }

  if (! $animation)
  {
    if (! -e $file_csv_language_codes)
    { abort ("CSV file '" . $file_csv_language_codes . "' not found or in use") ; }
    if (! -e $file_csv_active_users)
    { abort ("CSV file '" . $file_csv_active_users . "' not found or in use") ; }
    if (! -e $file_csv_sleeping_users)
    { abort ("CSV file '" . $file_csv_sleeping_users . "' not found or in use") ; }
  }
  if (! -e $file_csv_log)
  { abort ("CSV file '" . $file_csv_log . "' not found or in use") ; }
}

sub LogArguments
{
  my $arguments ;
  foreach $arg (sort keys %options)
  { $arguments .= " -$arg " . $options {$arg} . "\n" ; }
  &Log ("\nArguments\n$arguments\n") ;
}

sub DetectWikiMedia
{
  if (($site eq "wikimedia") || (! $mode_wp) || $pageviews)
  { $wikimedia = $true ; }
  else
  {
    my $chars = "" ;
    my $lines = 0 ;
    my $wp ;
    my %languages ;
    &ReadFileCsv ($file_csv_log, "") ;

    $wikimedia = $false ;
    foreach $wp (@csv)
    {
      $lines++ ;
      $wp =~ s/,.*$// ;
      $chars .= $wp ;
      $languages {$wp}++ ;
    }
    if ($lines > 0)
    {
      $avg_length = length ($chars) / $lines ;
      if (($avg_length < 3) && ($languages {$wp_1st} > 0) && ($languages {$wp_2nd} > 0))
      { $wikimedia = $true ; }
    }
  }

  if ($wikimedia)
  { &Log ("Script runs on Wikimedia server\n\n") ; }
  else
  { &Log ("Script does not run on WikiMedia server\n\n") ; }
}

sub InitGlobals
{
  &Log ("InitGlobals\n") ;

  if ($pageviews)
  {
    &GetPercPageViewsMobile ;
    &ReadFileCsv ($file_csv_pageviewsmonthly, "") ;
    $datemax = "" ;
    foreach $line (@csv)
    {
      my ($language,$date,$count) = split (",", $line) ;
      if ($date gt $datemax)
      { $datemax = $date ; }
    }
    if ($datemax eq "")
    { abort ("No lines found in $file_csv_pageviewsmonthly") ; }
    else
    { print "Datemax = $datemax\n" ; }

    $dumpdate_hi = substr ($datemax,0,4) . substr ($datemax,5,2) . substr ($datemax,8,2) ;
    $dumpday   = substr ($dumpdate_hi,6,2) ;
    $dumpmonth = substr ($dumpdate_hi,4,2) ;
    $dumpyear  = substr ($dumpdate_hi,0,4) ;
    $dumpmonth_ord = ord (&yyyymm2b ($dumpyear, $dumpmonth)) ;
    $dumpmonth_incomplete = ($dumpday < days_in_month ($dumpyear, $dumpmonth)) ;
  }
  else
  {
    &ReadFileCsv ($file_csv_log, "") ;
    @csv = sort {&csvkey_date2 ($a) cmp &csvkey_date2 ($b)} @csv ;
    ($dummy1, $dumpdate_hi) = split (",", $csv [$#csv]) ;
    $dumpday   = substr ($dumpdate_hi,6,2) ;
    $dumpmonth = substr ($dumpdate_hi,4,2) ;
    $dumpyear  = substr ($dumpdate_hi,0,4) ;
    $dumpmonth_ord = ord (&yyyymm2b ($dumpyear, $dumpmonth)) ;
    $dumpmonth_incomplete = ($dumpday < days_in_month ($dumpyear, $dumpmonth)) ;
  }

  if (($dumpday < 10) || ($dumpday == days_in_month ($dumpyear, $dumpmonth)))
  { $show_forecasts = $false ; }
  else
  { $show_forecasts = $true ; }

  if ($wikimedia && ($mode_wp))
  { $fmax = ord ('U') - ord ('A') ; }
  else
  { $fmax = ord ('S') - ord ('A') ; }

  for ($f=0 ; $f<=25 ; $f++) { $c[$f] = chr (ord ('A') + $f) ; }

  $mirror = $false ;
  if ($language eq "he")
  { $mirror = $true ; }

  $registration_enforced = $false ;
  $category_index        = $true ;

  $color_outofdate = "#FFA0A0" ;

#  $dumpdate_hi = "20030815" ;  # test only
}

sub ReadLog
{
  my $wp = shift ;

  if ($wp eq "zz")
  { $wpdump = $wp_1st ; }
  else
  { $wpdump = $wp ; }

  if ($wp eq "tr")
  { $a = 1 ; }

  &ReadFileCsv ($file_csv_log, $wpdump) ;
  ($dummy, $dumpdate, $countdate, $counttime, $conversions, $dummy, $dummy2, $dummy3, $edits_total, $edits_total_ip,) = split (",", $csv [0]) ;
}

sub ReadFileCsv
{
  my $file_csv = shift ;
  my $wp       = shift ;
  my $maxlines = shift ;

  if ($wp ne "")
  { $wp .= "," ; }
  undef @csv  ;
  open "FILE_IN", "<", $file_csv ;
  my $lines = 0 ;
  while ($line = <FILE_IN>)
  {
    if ((! defined ($wp)) || ($line =~ /^$wp/))
    {
      chomp ($line) ;
      push @csv, $line ;
      if (($maxlines ne "") && (++$lines >= $maxlines))
      { last ; }
    }
  }
  close "FILE_IN" ;
}

sub ReadFileCsvOnly
{
  my $file_csv = shift ;
  my $wp   = shift ;
  undef @csv  ;

  if (! -e $file_csv)
  { &Log ("File $file_csv not found.\n") ; return ; }

  open FILE_IN, "<", $file_csv ;
  while ($line = <FILE_IN>)
  {
    if ($line =~ /^$language\,/)
    {
      chomp ($line) ;
      push @csv, $line ;
    }
  }
  close FILE_IN ;
}

sub FixDateMonthlyStats
{
  #fix date of wp's that were not updated on last run
  my $date = shift ;
  $day   = substr ($date,3,2) ;
  $month = substr ($date,0,2) ;
  $year  = substr ($date,6,4) ;

  if ($year < 2001)  # StatisticsMonthly.csv contains weird dates for tiny Wp's, to be fixed in counts job
  { return ($date) ; }

  if ($day < days_in_month ($year, $month))
  {
    if (($year < $dumpyear) || ($month < $dumpmonth))
    { $date = sprintf ("%02d/%02d/%04d", $month, days_in_month ($year, $month), $year) ; }
    else
    {
      if ($day != $dumpday)
      { $date = sprintf ("%02d/%02d/%04d", $dumpmonth, $dumpday, $dumpyear) ; }
    }
  }
  return ($date) ;
}

sub ReadDumpDateAndForecastFactors
{
  &ReadFileCsv ($file_csv_log, "") ;
  $tot_factor_5     = 0 ;
  $tot_factor_100   = 0 ;
  $tot_active_users_counted     = 0 ;
  $tot_active_users_not_counted = 0 ;

  foreach $line (@csv)
  {
    my ($wp,$dumpdate,$dummy3,$dummy4,$dummy5, $factor_5, $factor_100, $active_users) = split (",", $line) ;
    if (($factor_5 > 0) && ($factor_100 > 0))
    {
      $tot_active_users_counted += $active_users ;
      $tot_factor_5             += $factor_5   * $active_users ;
      $tot_factor_100           += $factor_100 * $active_users ;
    }
    else
    { $tot_active_users_not_counted += $active_users ; }

  # $dumpdate2 = substr ($dumpdate,4,2) . "/" . substr ($dumpdate,6,2) . "/". substr ($dumpdate,0,4) ;
    $dumpdate2 = substr ($dumpdate,4,2) . "/" . 99                     . "/". substr ($dumpdate,0,4) ;
    $lastdump       {$wp} = $dumpdate ;
    $lastdump_short {$wp} = &GetDateShort ($dumpdate2, $false) ;
    if ($dumpdate > $lastdump {"zz"})
    { $lastdump {"zz"} = $dumpdate ; }
  }

  my $year  = substr ($lastdump {"zz"},0,4) ;
  my $month = substr ($lastdump {"zz"},4,2) ;
  my $dumpdate_ord = ord (&yyyymm2b ($year,$month)) ;
  foreach $wp (sort keys %lastdump)
  {
    my $year  = substr ($lastdump {$wp},0,4) ;
    my $month = substr ($lastdump {$wp},4,2) ;
    $lastdump_ago {$wp} = $dumpdate_ord - ord (&yyyymm2b ($year,$month)) ;
  }

  if ($tot_active_users_counted > 0)
  {
    $forecast_5   = sprintf ("%.2f", $tot_factor_5   / $tot_active_users_counted) ;
    $forecast_100 = sprintf ("%.2f", $tot_factor_100 / $tot_active_users_counted) ;
  }

# &Log ("Forecast factors : Active wikipedians: $forecast_5, Very Active: $forecast_100\n") ;
}

sub ReadBotStats
{
  if (! -e $file_csv_bot_edits)
  { &Log ("$file_csv_bot_edits not found!\n") ; return ; }
  if (! -e $file_csv_bots)
  { &Log ("$file_csv_bots not found!\n") ; return ; }

  &ReadFileCsv ($file_csv_bots) ;
  foreach $line (@csv)
  {
    ($wp,$bots) = split (',',$line,2) ;
    @bots = split ('\|', $bots) ;
    foreach $bot (@bots)
    {
      if ($bot ne "MediaWiki default")
      {
        $BotStatsWpBot1 {"$wp|$bot"} = 0 ;
        $BotStatsWpBot2 {"$wp|$bot"} = 0 ;
      }
    }
  }
  &ReadFileCsv ($file_csv_bot_edits) ;
  foreach $line (@csv)
  {
    ($wp,$bot,$edits1,$edits2) = split (',',$line) ;
    $BotStatsWpBot1  {"$wp|$bot"}   = $edits1 ;
    $BotStatsBotTot1 {"$bot"}      += $edits1 ;
    $BotStatsWpTot1  {"$wp"}       += $edits1 ;
    $BotStatsTotGen1               += $edits1 ;
    $BotStatsWpBot2  {"$wp|$bot"}   = $edits2 ;
    $BotStatsBotTot2 {"$bot"}      += $edits2 ;
    $BotStatsWpTot2  {"$wp"}       += $edits2 ;
    $BotStatsTotGen2               += $edits2 ;
  }
}

sub ReadMonthlyStats
{
  my ($wp, $day, $month, $year, $days, $m, $prev, $curr, $forecast, @fc) ;
  my $md = $dumpmonth_ord ;
  my @oldest_month ;
  my (%wp_ok,%wp_nok) ;
  undef (@languages) ;
  undef (@max_links) ;

  # file is sorted by WikiCounts as {&csvkey_lang_date ($a) cmp &csvkey_lang_date ($b)}

  $MonthlyStatsWpStart {"zz"} = 9999 ;

  $month_max = 0 ;

  open "FILE_IN", "<", $file_csv_users_activity_spread ;
  while ($line = <FILE_IN>)
  {
    chomp ($line) ;
    # count user with over x edits
    # threshold starting with a 3 are 10xSQRT(10), 100xSQRT(10), 1000xSQRT(10), etc
    # thresholds = 1,3,5,10,25,32,50,100,etc

    ($wp, $date, $reguser_bot, $ns_group, @fields) = split (",", $line) ;
  #  print "$wp, $date,  $reguser_bot, $ns_group\n" ;
    if ($reguser_bot ne "R") { next ; } # R: registered user, B: bot
    if ($ns_group    ne "A") { next ; } # A: articles, T: talk pages, O: other

    $user_edits_5   {"$wp,$date"} = $fields [2] ;
    $user_edits_100 {"$wp,$date"} = $fields [7] ;
  }
  close "FILE_IN" ;

  if ($pageviews)
  {
    print "\nRead input for page views\n" ;
    &ReadFileCsv ($file_csv_log) ;
    foreach $wp (@csv)
    {
      $wp =~ s/,.*$// ;
      $wp =~ s/_/-/g ;
      next if $some_languages_only and ! $include_language {$wp} ;
      $wp_ok {$wp} = 1 ;
      $wp_ok {"$wp.m"} = 1 ;
    }
    # find oldest month (to be skipped, probably incomplete)
    # $oldest_month_pageviews  = "9999/99/99" ;
    open "FILE_IN", "<", $file_csv_pageviewsmonthly ;
    while ($line = <FILE_IN>)
    {
      ($wp, $date, @fields) = split (",", $line) ;

      next if $wp ne lc $wp ; # cruft
      next if $some_languages_only and ! $include_language {$wp} ;

    #  if ((! $mode_wp) && ($date eq '2008/05/31')) { next ; }  # skip incomplete first month

      if ($wp_ok {$wp} == 0)
      { $wp_nok {$wp} ++ ; }
      if (($oldest_month_pageviews {$wp} eq "") || ($date lt $oldest_month_pageviews {$wp}))
      { $oldest_month_pageviews {$wp} = $date ; }
    }
    close "FILE_IN" ;

    my $msg = "\nLanguage codes skipped (not in StatisticsLog.csv):\n" ;
    foreach $wp (sort keys %wp_nok)
    { $msg .= "$wp," ; }
    if ($msg =~ /,/)
    {
      $msg =~ s/,$/\n/ ;
      print $msg ;
    }

    open "FILE_IN", "<", $file_csv_pageviewsmonthly ;
  }
  else
  { open "FILE_IN", "<", $file_csv_monthly_stats ; }

  while ($line = <FILE_IN>)
  {
    chomp ($line) ;

    if ($pageviews)
    {
      ($wp, $date, @fields) = split (",", $line) ;

      next if $wp ne lc $wp ; # cruft
      next if $pageviews_mobile and $wp !~ /\.m/ ;
      next if $pageviews_normal and $wp =~ /\.m/ ;
      next if $some_languages_only and ! $include_language {$wp} ;

      $wp =~ s/\.m// ; # mobile postix is .m

      if ($date eq $oldest_month_pageviews {$wp}) # skip first month, probably incomplete
      { next ; }

      if ($wp_nok {$wp} > 0)                # invalid language code or project in different group
      { next ; }                            # e.g. special wikipedias are not mixed with normal wikipedias

      if ($normalize_days_per_month)
      {
        my $month = substr ($date,5,2) ;
        my $day   = substr ($date,8,2) ;
        my $year  = substr ($date,0,4) ;

        $days_in_month =  days_in_month ($year,$month) ;
        $fields_0 = $fields [0] ;
        $fields [0] = sprintf ("%.0f", 30/$days_in_month * $fields [0]) ;
      }
      $date = substr ($date,5,2) . "/" . substr ($date,8,2) . "/" . substr ($date,0,4) ;# month day year

    }
    else
    { ($wp, $date, @fields) = split (",", $line) ; }

    # use newer counts, excluding bots from $file_csv_users_activity_spread

    $fields [2] = $user_edits_5   {"$wp,$date"} ;
    $fields [3] = $user_edits_100 {"$wp,$date"} ;

    next if $some_languages_only and ! $include_language {$wp} ;

    # if ($wp eq $wp_1st) { next ; } # Dec 2006: skip till counts are fixed
    if ($mode_wk && (($wp eq "als") || ($wp eq "tlh")))  { next ; } # obsolete
    if ($wp eq "dk") { next ; } # Dec 2006: dumps exist but site not
    if ($wp eq "zz") { next ; }
    if ($wp eq "test") { next ; }
    if ($wp eq "tlh") { next ; } # Klignon
    if ($wp eq "ru-sib") { next ; } # Siberian
    if ($wp eq "ru_sib") { next ; } # Siberian

    if ($wp =~ /mania/i)  { next ; }
    if ($wp =~ /team/i)   { next ; }
    if ($wp =~ /comcom/i) { next ; }
    if ($wp =~ /closed/i) { next ; }
    if ($wp =~ /chair/i) { next ; }
    if ($wp =~ /langcom/i) { next ; }
    if ($wp =~ /office/i) { next ; }
    if ($wp =~ /searchcom/i) { next ; }
    if ($wp =~ /sep11/i) { next ; }
    if ($wp =~ /nostalgia/i) { next ; }
    if ($wp =~ /stats/i) { next ; }
    if (! $mode_wx && ($wp =~ /commons/i)) { next ; }

    # $date = &FixDateMonthlyStats ($date) ;
    $day   = substr ($date,3,2) ;
    $month = substr ($date,0,2) ;
    $year  = substr ($date,6,4) ;

    if ($year < 2001)  # StatisticsMonthly.csv contains weird dates for tiny Wp's, to be fixed in counts job
    { next ; }
    if (($wp eq "ar") && ($year < 2003))  # clearly erroneous record for arwiki pollutes TablesWikipediaGrowthSummaryContributors.htm
    { next ; }

    $m = ord (&yyyymm2b ($year, $month)) ;

    next if $pageviews and $mode_wx and $m < 102 ; # oldest months are erroneous (incomplete)
    
    next if $wp eq 'commons' and $m < 58 ;
    
    # figures for current month are ignored when month has just begun
    #                          (were)
#    if ($day < 7)
#    { next ; }
    $languages {$wp} ++ ;

    for ($f = 0 ; $f <= $#fields ; $f++)
    {
      if (($c [$f] =~ /J|K|T/) && (! ($fields  [$f] =~ /\%/))) # T -> V after daily stats are inserted
      {
        my $articles = $MonthlyStats {$wp.$m.$c[4]} ;
        if ($articles != 0)
        {
          $fields [$f] = 100 * ($fields [$f]  / $articles) ;
          # > 100 can happen on V where categorized articles can include articles without link? -> check
          if ($fields [$f] > 100)
          { $fields [$f] = 100 ; }
          $fields [$f] = sprintf ("%.0f\%", $fields [$f]) ;
        }
        else
        { $fields [$f] = 0 ; }
      }

      if ($pageviews || ($f < $#fields))
      { $MonthlyStats {$wp.$m.$c[$f]} = $fields [$f] ; }
      else
      { $MonthlyStats {$wp.$m.$c[$f+2]} = $fields [$f] ; } # daily usage counts will be 'inserted' below,
                                                           # those used to be last columns in input,
                                                           # before 'perc. categorized' was added
      if ($c[$f] =~ /A|C|E/)
      {
        if ($fields [$f] > $MonthlyStatsHigh {$wp.$c[$f]})
        {
          $MonthlyStatsHigh {$wp.$c[$f]} = $fields [$f] ;
          $MonthlyStatsHighMonth {$wp.$c[$f]} = $m ;
        }
      }

#      if ($f == 14)
#      {
#        $links = $fields [$f] ;
#        if (! defined ($max_links {$wp}))
#        { $max_links {$wp} = $links ; }
#        elsif ($max_links {$wp} < $links)
#        { $max_links {$wp} = $links }
#      }
      $max_key = "$wp-$f" ;
      $value   = $fields [$f] ;

      if (! defined ($max_value {$max_key}))
      { $max_value {$max_key} = $value ; }
      elsif ($max_value {$max_key} < $value)
      { $max_value {$max_key} = $value }

      if ($max_value_f {$f} < $value)
      { $max_value_f {$f} = $value }
    }

    if (! defined ($MonthlyStatsWpStart {$wp}))
    {
      $MonthlyStatsWpStart {$wp} = $m ;
      $MonthlyStatsWpStartPerMonth {$m} .= "$wp," ;
      if ($MonthlyStatsWpStart {"zz"} > $m)
      { $MonthlyStatsWpStart {"zz"} = $m ; }
    }

    if ($m > $MonthlyStatsWpStop {"zz"})
    {
      $MonthlyStatsWpStop {"zz"} = $m ;
      $MonthlyStatsWpDate {"zz"} = $date ;
    }

    if ($m > $MonthlyStatsWpStop {$wp})
    {
      $MonthlyStatsWpStop {$wp} = $m ;
      $MonthlyStatsWpIncomplete {$wp} = ($day < days_in_month ($year, $month)) ;
      $MonthlyStatsWpDate {$wp} = $date ;
    }

    if (($MonthlyStatsWp100Articles {$wp} eq "") && ($fields [4] >= 100))
    { $MonthlyStatsWp100Articles {$wp} = $m ; }
    if (($MonthlyStatsWp1000Articles {$wp} eq "") && ($fields [4] >= 1000))
    { $MonthlyStatsWp1000Articles {$wp} = $m ; }
    if (($MonthlyStatsWp10000Articles {$wp} eq "") && ($fields [4] >= 10000))
    { $MonthlyStatsWp10000Articles {$wp} = $m ; }
    if (($MonthlyStatsWp100000Articles {$wp} eq "") && ($fields [4] >= 100000))
    { $MonthlyStatsWp100000Articles {$wp} = $m ; }

    if ($m > $month_max)
    {
      $month_max = $m ;
      $recent_dates [4] = $date ; # this month may be incomplete
      $month_max_incomplete = ($day < days_in_month ($year, $month)) ;
    }
  }
  close "FILE_IN" ;

  foreach $wp (keys %languages)
  {
    if ($mode_wx && (($wp eq "strategy") || ($wp eq "usability") || ($wp eq "outreach"))) # show incomplete month as well
    { last ; }

    if (($MonthlyStatsWpStop {$wp} < $MonthlyStatsWpStop {"zz"}) &&
         $MonthlyStatsWpIncomplete {$wp} &&
        ($MonthlyStatsWpStop {$wp} > $MonthlyStatsWpStart {$wp}))
    {
      $MonthlyStatsWpStop {$wp}-- ;
      $MonthlyStatsWpIncomplete {$wp} = $false ;
    }
  }

  if ($pageviews || $wikimedia)
  {
    $sort_pageviews = $true ;
    &ReadFileCsv ($file_csv_pageviewsmonthly, "") ;
    foreach $line (@csv)
    {
      chomp $line ;
      my ($lang,$date,$count) = split (',', $line) ;
      my ($year,$month,$day)  = split ('/', $date) ;
      if ($day > 5) # q&d: use most recent month, unless month less than 5 days old
      {
        ($lang2 = $lang) =~ s/-/_/g ;
        $PageViewsPerHour {$lang2} = $count / (24 * $day) ;
      }
    }
    # if ($mode_wp)
    # { $f = 14 ; } # sort on 'internal links' ;
    # else
    # { $f =  4 ; } # sort on 'article counts' ;
  }
  else
  {
    $sort_pageviews = $false ;
    $f = $sort_column ;
  }

  if ($sort_pageviews)
  {
    @languages  = sort { $PageViewsPerHour {&Underscore($b)} <=> $PageViewsPerHour {&Underscore($a)} } keys %languages ;
    foreach $lang (@languages2)
    { $lang =~ s/-/_/g ; }
    @languages2 = @languages ;
  }
  else
  {
    @languages  = sort { @MonthlyStats {$b.$MonthlyStatsWpStop{$b}.$c[$f]} <=> @MonthlyStats {$a.$MonthlyStatsWpStop{$a}.$c[$f]} } keys %languages ;
    @languages2 = sort { @MonthlyStats {$b.$MonthlyStatsWpStop{$b}.$c[4]}  <=> @MonthlyStats {$a.$MonthlyStatsWpStop{$a}.$c[4]}  } keys %languages ;
  }
  @languages_speakers = sort { $out_speakers {$b} <=> $out_speakers {$a} } keys %languages ;

  $language_ndx = 1 ;
  foreach $wp (@languages)
  { $sort_languages {$wp} = chr ($language_ndx ++) ; }
  $sort_languages {"zz"} = chr (0) ;

if ($false)
{
  open "FILE_IN", "<", $file_csv_webalizer_monthly ;
  while ($line = <FILE_IN>)
  {
    chomp ($line) ;

    ($wp, $date, @fields) = split (",", $line) ;
    # $date = &FixDateMonthlyStats ($date) ;
    $day   = substr ($date,3,2) ;
    $month = substr ($date,0,2) ;
    $year  = substr ($date,6,4) ;
    $m     = ord (&yyyymm2b ($year, $month)) ;

    # figures for current month are ignored when month has just begun
    #                          were
    # if ($day < 7)
    # { next ; }

    $MonthlyStats {$wp.$m.$c[$fmax-1]} = $fields [0] ;
    $MonthlyStats {$wp.$m.$c[$fmax  ]} = $fields [1] ;
  }
  close "FILE_IN" ;
}
  if (! $pageviews)
  {
    # collect dates to display for recent months
    $year  = substr ($recent_dates [4],6,4) ;
    $month = substr ($recent_dates [4],0,2) ;

    for ($i = 3 ; $i >= 0 ; $i--)
    {
      $month-- ;
      if ($month == 0)
      { $month = 12 ; $year-- ; }
      $recent_dates [$i] = sprintf ("%02d", $month) . "/" .
                           sprintf ("%02d", days_in_month ($year, $month)). "/" .
                           sprintf ("%04d", $year) ;
    }
  }

  #collect totals
  if ($mode_wb) { $m1 = ord (&yyyymm2b (2001, 1)) ; }
  if ($mode_wk) { $m1 = ord (&yyyymm2b (2002,12)) ; }
  if ($mode_wn) { $m1 = ord (&yyyymm2b (2004, 7)) ; }
  if ($mode_wp) { $m1 = ord (&yyyymm2b (2001, 1)) ; }
  if ($mode_wq) { $m1 = ord (&yyyymm2b (2001, 1)) ; }
  if ($mode_ws) { $m1 = ord (&yyyymm2b (2001, 1)) ; }
  if ($mode_wx) { $m1 = ord (&yyyymm2b (2001, 1)) ; }

  foreach $wp (@languages)
  {
    $LargeWiki {$wp} = $false ;
    if ($MonthlyStatsHigh {$wp."E"} > ($MonthlyStatsHigh {$wp_1st ."E"} / 50))
    { $LargeWiki {$wp} = $true ; }
  }

# $MonthlyStatsWpStart {"zz"} = $m1 ;
  $m2 = $md ;

  # count active projects per month (#articles > 0)
  for ($m = $m1 ; $m <= $m2 ; $m++)
  {
    $projects = 0 ;
    foreach $wp (@languages)
    {
      if (($wp ne "zz") && ($MonthlyStatsWpStart {$wp} <= $m))
      { $projects++ ; }
    }
    $MonthlyStatsProjects {$m} = $projects ;
  }

  if ($region eq '')
  { $max_check_largest_wikis = 20 ;}
  else
  { $max_check_largest_wikis = 5 ;}

  $MonthlyStatsWpStopLo  = 999 ;
  $MonthlyStatsWpStopLo2 = 999 ; # temp for mode_wp without $wp_1st

  for ($m = $m1 ; $m <= $m2 ; $m++)
  {
    for ($f = 0 ; $f <= $fmax ; $f++)
    {
      $zz  = 0 ;
      $zzz = 0 ;
      $LargeWikiDataMissing  = $false ;
      $LargeWikiDataMissing2 = $false ;
      $LargeWikiDataMissing3 = $false ;
      $wpndx = 0 ;
      foreach $wp (@languages)
      {
        if (! $pageviews)
        {
          $wpndx ++ ;
          if (((! $mode_wp) && ($wpndx <= $max_check_largest_wikis)) || $LargeWiki {$wp})
          {
            if ($m > $MonthlyStatsWpStop {$wp})
            {
              $LargeWikiDataMissing = $true ;
              $LargeWikisDataMissing {$wp}++ ;
              if ($MonthlyStatsWpStop {$wp} < $MonthlyStatsWpStopLo)
              { $MonthlyStatsWpStopLo = $MonthlyStatsWpStop {$wp} ; }

              if ($mode_wp && ($wp ne $wp_1st)) #  && ($wp ne $wp_2nd))
              {
                $LargeWikiDataMissing2 = $true ;
                if ($MonthlyStatsWpStop {$wp} < $MonthlyStatsWpStopLo2)
                { $MonthlyStatsWpStopLo2 = $MonthlyStatsWpStop {$wp} ; }
              }
            }
            if (($m == $MonthlyStatsWpStop {$wp}) && $MonthlyStatsWpIncomplete {$wp})
            {
              $LargeWikiDataMissing = $true ;
              $LargeWikisDataMissing {$wp}++ ;
              if ($MonthlyStatsWpStop {$wp} < $MonthlyStatsWpStopLo)
              { $MonthlyStatsWpStopLo = $MonthlyStatsWpStop {$wp} ; }

              if ($mode_wp && ($wp ne $wp_1st)) # && ($wp ne $wp_2nd))
              {
                $LargeWikiDataMissing2 = $true ;
                if ($MonthlyStatsWpStop {$wp} < $MonthlyStatsWpStopLo2)
                { $MonthlyStatsWpStopLo2 = $MonthlyStatsWpStop {$wp} ; }
              }
            }
          }
          # data may be missing for large wikis that were processed in edits_only mode (to speed process)
          if ($mode_wp && ($wpndx <= $max_check_largest_wikis))
          {
            if (($MonthlyStats {$wp.$m.$c[4]} > 10000) && # article count substantial but not word count -> edit_only mode
                ($MonthlyStats {$wp.$m.$c[13]} == 0))
            { $LargeWikiDataMissing3 = $true ; }
          }
        }

        # except for pageviews, for last 12 months check if most prominent wiki has data
        # only for last 12 months: especially for region 'India' this is not so for early months
        if ($pageviews) 
	 { $zz += $MonthlyStats {$wp.$m.$c[$f]} ; }     
	elsif (($m <= $md - 12) || ($MonthlyStats {$wp_1st.$m.$c[$f]} > 0))
        {
          if (($f >= 7) && ($f <= 10))
          { $zz += $MonthlyStats {$wp.$m.$c[$f]} * $MonthlyStats {$wp.$m.$c[4]} ; }
          else
          { $zz += $MonthlyStats {$wp.$m.$c[$f]} ; }
        }

        # temporary measure to circumvent missing English dump: show totals for non English wikis
        if ($mode_wp && ($wp ne $wp_1st)) # && ($wp ne $wp_2nd))
        {
          if (($f >= 7) && ($f <= 10))
          { $zzz += $MonthlyStats {$wp.$m.$c[$f]} * $MonthlyStats {$wp.$m.$c[4]} ; }
          else
          { $zzz += $MonthlyStats {$wp.$m.$c[$f]} ; }
        }
      }

      if ($LargeWikiDataMissing)
      {
        $zz = 0 ;
        $ReportLargeWikiDataMissing = $true ;
        $ListLargeWikisDataMissing = join (',', keys %LargeWikisDataMissing) ;
      }
      if ($LargeWikiDataMissing2)
      {
        $zzz = 0 ;
        $ReportLargeWikiDataMissing2 = $true ;
      }
      # stats for en may be missing, this would effect totals too much
      # if ($wikimedia && ($MonthlyStats {$wp_1st.$m.$c[$f]} == 0))
      # { $zz = 0 ; }

      if ((! $LargeWikiDataMissing3) ||
         (($f < 5) || ($f == 6) || ($f == 7) || ($f == 11) || ($f == 18)))
      {
        $MonthlyStats {"zz".$m.$c[$f]} = $zz ;
        if ($mode_wp)
        { $MonthlyStats {"zzz".$m.$c[$f]} = $zzz ; }

        if ($zz > $MonthlyStatsHigh {$wp.$c[$f]})
        {
          $MonthlyStatsHigh {$wp.$c[$f]} = $zz ;
          $MonthlyStatsHighMonth {$wp.$c[$f]} = $m ;
        }
      }
    }

    $wp = "zz" ;
    my $articles = $MonthlyStats {$wp.$m.$c[4]} ;
    if (($articles == 0) || $LargeWikiDataMissing3)
    {
      $MonthlyStats {$wp.$m.$c[ 7]} = 0 ;
      $MonthlyStats {$wp.$m.$c[ 8]} = 0 ;
      $MonthlyStats {$wp.$m.$c[ 9]} = 0 ;
      $MonthlyStats {$wp.$m.$c[10]} = 0 ;
    }
    else
    {
      $MonthlyStats {$wp.$m.$c[ 7]} = sprintf ("%2.1f", ($MonthlyStats {$wp.$m.$c[ 7]} / $articles)) ;
      $MonthlyStats {$wp.$m.$c[ 8]} = sprintf ("%5.0f", ($MonthlyStats {$wp.$m.$c[ 8]} / $articles)) ;
      $MonthlyStats {$wp.$m.$c[ 9]} = sprintf ("%.0f\%",($MonthlyStats {$wp.$m.$c[ 9]} / $articles)) ;
      $MonthlyStats {$wp.$m.$c[10]} = sprintf ("%.0f\%",($MonthlyStats {$wp.$m.$c[10]} / $articles)) ;
    }

    if ($mode_wp)
    {
      $wp = "zzz" ;
      my $articles = $MonthlyStats {$wp.$m.$c[4]} ;
      if (($articles == 0) || $LargeWikiDataMissing3)
      {
        $MonthlyStats {$wp.$m.$c[ 7]} = 0 ;
        $MonthlyStats {$wp.$m.$c[ 8]} = 0 ;
        $MonthlyStats {$wp.$m.$c[ 9]} = 0 ;
        $MonthlyStats {$wp.$m.$c[10]} = 0 ;
      }
      else
      {
        $MonthlyStats {$wp.$m.$c[ 7]} = sprintf ("%2.1f", ($MonthlyStats {$wp.$m.$c[ 7]} / $articles)) ;
        $MonthlyStats {$wp.$m.$c[ 8]} = sprintf ("%5.0f", ($MonthlyStats {$wp.$m.$c[ 8]} / $articles)) ;
        $MonthlyStats {$wp.$m.$c[ 9]} = sprintf ("%.0f\%",($MonthlyStats {$wp.$m.$c[ 9]} / $articles)) ;
        $MonthlyStats {$wp.$m.$c[10]} = sprintf ("%.0f\%",($MonthlyStats {$wp.$m.$c[10]} / $articles)) ;
      }
    }
  }
  if ($MonthlyStatsWpStopLo == 999)
  { $MonthlyStatsWpStopLo  = $MonthlyStatsWpStop {"zz"} ; }
  if ($MonthlyStatsWpStopLo2 == 999)
  { $MonthlyStatsWpStopLo2 = $MonthlyStatsWpStop {"zz"} ; }
  unshift (@languages, "zz") ;


#  if ($mode_wp) # for tests only
#  {
#    print "zzz: Active editors\n" ;
#    for ($m = $m1 ; $m <= $m2 ; $m++)
#    { print &m2mmddyyyy($m) . ": " . $MonthlyStats {"zzz".$m.$c[ 2]} . " / " . $MonthlyStats {"zzz".$m.$c[ 3]} . "\n" ; }
#  }

  if ($pageviews)
  {
    $m2 = $dumpmonth_ord ;
    $m1 = $m2 - 12 ;
    for ($m = $m1 ; $m <= $m2 ; $m++)
    {
      $zz = $MonthlyStats {"zz".$m.$c[0]} ;
      if ($zz > $MonthlyStatsHigh {"zz".$c[0]})
      {
        $MonthlyStatsHigh      {"zz".$c[0]} = $zz ;
        $MonthlyStatsHighMonth {"zz".$c[0]} = $m ;
      }
    }
  }

  # rank monthly result per project
  # use for missing months largest result so far (if any results > 0 in earlier months)
  for ($f = 0 ; $f <= $fmax ; $f++)
  {
  # for ($m = $m1 ; $m <= $m2 ; $m++)
    for ($m = $m1 ; $m < $m2 ; $m++) # to do : test whther enough wikis have data for last month
    {
      $missing = 0 ;
      foreach $wp (@languages)
      {
        if ((($f < 2) || ($f > 3)) && ($m >= $MonthlyStatsWpStart {$wp}) && ($MonthlyStats {$wp.$m.$c[$f]} eq ""))
        { $missing ++ ; }
      }
      if ($missing > 10)
      { next ; }

      @list = () ;
      $rank = 0 ;
      foreach $wp (@languages)
      {
        if ($wp ne "zz")
        {
          # ignore smallest projects ( < 1000 articles ) when ranking averaged values: a project with just a
          # Main Page could have a meaningless but high average size and edit count per article
          if ((($f < 7) || ($f > 10)) || ($MonthlyStats {$wp.$m.$c[4]} >= 1000))
          {
            if ($MonthlyStats {$wp.$m.$c[$f]} eq "")
            {
              if ($m >= $MonthlyStatsWpStart {$wp})
              { push @list, $MonthlyStatsHigh {$wp.$c[$f]} . "$wp" ; }
            }
            else
            {
              if ($MonthlyStats {$wp.$m.$c[$f]} > 0)
              { push @list, $MonthlyStats {$wp.$m.$c[$f]} . ":$wp" ; }
            }
          }
        }
      }
      @list = sort {$b <=> $a} @list ;

      for ($ndx = 0 ; $ndx <= $#list ; $ndx++)
      {
        $rank = $ndx + 1 ; # does not yet set equal number for projects that rank ex equo
        ($wp = $list [$ndx]) =~ s/^.*?:// ;
        $MonthlyStatsRank {$wp.$m.$c[$f]} = $rank ;
      }

      foreach $wp (@languages)
      {
        if ($wp ne "zz")
        {
          if ($MonthlyStats {$wp.$m.$c[13]} > 0) # word count non zero ? if not WikiCounts ran with -e (edits_only)
          {
            if ($MonthlyStatsRank {$wp.$m.$c[$f]} eq "")
            { $MonthlyStatsRank {$wp.$m.$c[$f]} = $rank + 1 ; }
          }
        }
      }
    }
  }

  # forecasts
  if ($show_forecasts)
  {
    my $factor = days_in_month ($dumpyear, $dumpmonth) / ($dumpday-0.5) ;

    $m = $md ;
    foreach $wp (@languages)
    {
      for ($f = 0 ; $f <= $fmax ; $f++)
      {
        my $c = $c[$f] ; # column
        $prev = $MonthlyStats {$wp.($m-1).$c} ;
        $curr = $MonthlyStats {$wp. $m   .$c} ;
        if ($c eq 'C')
        { if ((! defined ($forecast_5)) || ($forecast_5 == 0))
          { $forecast = 0 ; }
          else
          { $forecast = $curr * 1/$forecast_5 ; }
        }
        elsif ($c eq 'D')
        { if ((! defined ($forecast_100)) || ($forecast_100 == 0))
          { $forecast = "-" ; }
          else
          { $forecast = $curr * 1/$forecast_100 ; }
        }
        elsif (($c eq 'G') || ($c eq 'H') || ($c eq 'I') || ($c eq 'T') || ($c eq 'U'))
        { $forecast = $curr ; }
        elsif (($c eq 'B') || ($c eq 'L') || ($c eq 'A' && $pageviews))
        { $forecast = $factor * $curr ; }
        elsif (index ($curr, "%") != -1)
        { $forecast = $curr ; }
        elsif ($curr < $prev)
        { $forecast = 0 ; }
        else
        { $forecast = $prev + $factor * ($curr - $prev) ; }
        $decimal = index ($curr, ".") ;
        if ($decimal != -1)
        { $forecast = sprintf ("%.1f", $forecast) ; }
        else
        { $forecast = sprintf ("%.0f", $forecast) ; }
        $perc = index ($curr, "%") ;
        if ($perc != -1)
        { $forecast .= "%" ; }
        $MonthlyStats {$wp.($m+1).$c[$f]} = $forecast ;
      }
    }
  }

  # recent percentual increases per month
  @fc = (0,2,3,4,5,6,11,12,13,14,15,16,17,18,19,20) ;
  foreach $wp (@languages)
  {
    $m1 = $md ;
  # $m2 = $m1 - 7 ;
  # if ($m2 < $MonthlyStatsWpStart {$wp})
  # { $m2 = $MonthlyStatsWpStart {$wp} ; }
    $m2 = $MonthlyStatsWpStart {$wp} ; # now do it for all months

    for ($m = $m1 ; $m >= $m2 ; $m--)
    {
      for ($i = 0 ; $i <= $#fc ; $i++)
      {
        $f = $fc [$i] ;
        $prev = $MonthlyStats {$wp.($m-1).$c[$f]} ;
        if (($m == $md) && $dumpmonth_incomplete) # compare with forecast
        { $curr = $MonthlyStats {$wp.($m+1).$c[$f]} ; }
        else
        { $curr = $MonthlyStats {$wp.($m)  .$c[$f]} ; }

        $percentage = 0 ;
        if (($curr >=   20) && ($prev >=   20))
        # if (((($f ==  2) || ($f == 3)) && ($curr >=   20) && ($prev >=   20)) ||
        #     (($f != 12)               && ($curr >=   50) && ($prev >=   50)) ||
        #     (($f == 12)               && ($curr >= 1000) && ($prev >= 1000)))
        {
          $percentage = sprintf ("%.0f", (100 * $curr / $prev) - 100) ;
          if ($percentage > 0)
          { $percentage = "+" . $percentage ; }
          $percentage .= "%" ;
          $MonthlyStats {$wp.($m).$c[$f].'p'} = $percentage ;
        }
        elsif ($m == $m2)
        {
          $MonthlyStats {$wp.($m).$c[$f].'p'} = '--%' ;
        }
      }
    }
  }

  # mean value for last five months (last may be incomplete)
  foreach $wp (@languages)
  {
    for ($f = 0 ; $f <= $fmax ; $f++)
    {
      $value_m = 0 ;
      $dayst_m = 0 ;
      $value_p = 0 ;
      $dayst_p = 0 ;
      $m1 = $md ;
      $m2 = $m1 - 4 ;
      $skip_growth = $false ;
      if ($m2 < $MonthlyStatsWpStart {$wp})
      { $m2 = $MonthlyStatsWpStart {$wp} ; }
      for ($m = $m1 ; $m >= $m2 ; $m--)
      {
        # $days = ($m < $m1) ? &daysinmonth2 ($m) : $dumpday ;
        if ($m < $m1)
        {
          my $date  = &m2mmddyyyy ($m) ;
          my $year  = substr ($date,6,4) ;
          my $month = substr ($date,0,2) ;
          $days = days_in_month ($year, $month) ;
        }
        else
        { $days = $dumpday ; }

        $dayst_m += $days ;
        $value_m += $days * @MonthlyStats {$wp.$m.$c[$f]} ;

        if (($m > $m2) && (! $skip_growth))
        {
          $value_new = @MonthlyStats {$wp.$m.$c[$f]} ;
          $value_old = @MonthlyStats {$wp.($m-1).$c[$f]} ;
          $value_min = ($f == 7) ? 1 : 10 ;
          if (($value_old > $value_min) and ($value_new > $value_min))
          {
            $dayst_p += $days ;
            $value_p += $days * (100 * (($value_new - $value_old) / $value_old)) ;
          }
          else
          {
            $dayst_p = 0 ;
            $skip_growth = $true ;
          }
        }
      }
      @MonthlyStats {$wp.$c[$f].'m'} = ($dayst_m == 0) ? 0 : $value_m / $dayst_m ;
      @MonthlyStats {$wp.$c[$f].'p'} = ($dayst_p == 0) ? 0 : $value_p / $dayst_p ;
    }
  }

  if (! $pageviews)
  {

  $m1 = $month_max ;
  $m2 = $m1 - 12 ;
  if ($month_max_incomplete) { $m2-- ; }
  $articles_plus_since = "1 " . &GetDateShort2 ($m2+1, $true) ;
  foreach my $wp (@languages)
  {
    foreach $f (0,4)
    {
      if ($m2 <= $MonthlyStatsWpStop {$wp})
      {
        @MonthlyStats {$wp.$c[$f].'+'} = @MonthlyStatsHigh {$wp.$c[$f]} -
                                        @MonthlyStats     {$wp.$m2.$c[$f]} ;
        if (@MonthlyStats {$wp.$c[$f].'+'} < 0)
        { @MonthlyStats {$wp.$c[$f].'+'} = 0 ; }

      # if (@MonthlyStats {$wp.$m2.$c[$f]} > 0)
        if (@MonthlyStatsHigh {$wp.$c[$f]} > 0)
        {
          @MonthlyStats {$wp.$c[$f].'%'} = sprintf ("%.0f" , 100 *@MonthlyStats {$wp.$c[$f].'+'} /
                                          # @MonthlyStats     {$wp.$m2.$c[$f]}) ;
                                          @MonthlyStatsHigh {$wp.$c[$f]}) ;
          if (@MonthlyStats {$wp.$m2.$c[$f]} > 0)
          { @MonthlyStats {$wp.$c[$f].'+%'} = 100 * (@MonthlyStats {$wp.$c[$f].'+'} / @MonthlyStats {$wp.$m2.$c[$f]}) ; }
          if (@MonthlyStats {$wp.$c[$f].'+%'} < 10)
          { @MonthlyStats {$wp.$c[$f].'+%'} = sprintf ("%.1f", @MonthlyStats {$wp.$c[$f].'+%'}) ; }
          else
          { @MonthlyStats {$wp.$c[$f].'+%'} = sprintf ("%.0f", @MonthlyStats {$wp.$c[$f].'+%'}) ; }
          if (@MonthlyStats {$wp.$c[$f].'+%'} >999)
          { @MonthlyStats {$wp.$c[$f].'+%'} = "" ; }
        }
      }
    }
    foreach $f (1,2,3)
    {
      $m3 = $MonthlyStatsWpStop {$wp} ;
      foreach $m ($m3, $m3-1, $m3-2)
      { @MonthlyStats {$wp.$c[$f].'avg3'} += @MonthlyStats {$wp.$m.$c[$f]} ; }
      @MonthlyStats {$wp.$c[$f].'avg3'} /= 3 ;
      @MonthlyStats {$wp.$c[$f].'avg3'} = sprintf ("%.0f", @MonthlyStats {$wp.$c[$f].'avg3'}) ;
    }

    $editstot = 0;
    $editsnew = 0;
    for ($m = $MonthlyStatsWpStart {$wp}; $m <= $MonthlyStatsWpStop {$wp} ; $m++)
    {
      $editstot += @MonthlyStats {$wp.$m.$c[11]} ;
      if ($m > $m2)
      { $editsnew += @MonthlyStats {$wp.$m.$c[11]} ; }
    }
    @MonthlyStats {$wp.$c[11].'tot'} = $editstot ;
    @MonthlyStats {$wp.$c[11].'+'}   = $editsnew ;
    # if ($editstot-$editsnew > 0)
    # { @MonthlyStats {$wp.$c[11].'%'}   = sprintf ("%.0f",100 * ($editsnew / ($editstot-$editsnew))) ; }
    if ($editstot > 0)
    {
      $perc  = 100 * ($editsnew / $editstot) ;
      if ($editstot-$editsnew > 0)
      {
        $perc2 = 100 * ($editsnew / ($editstot-$editsnew)) ;
        if ($perc2 > 999)
        { $perc2 = "" ; }
      }
      else
      { $perc2 = "" ; }
    # @MonthlyStats {$wp.$c[11].'%'}   = sprintf ("%.0f",100 * ($editsnew / $editstot)) ;
      @MonthlyStats {$wp.$c[11].'%'}   = sprintf ("%.0f",$perc) ;
      if ($perc2 < 10)
      { @MonthlyStats {$wp.$c[11].'+%'}  = sprintf ("%.1f",$perc2) ; }
      else
      { @MonthlyStats {$wp.$c[11].'+%'}  = sprintf ("%.0f",$perc2) ; }
    }
    # if (@MonthlyStats {$wp.$c[11].'%'} >999)
    # { @MonthlyStats {$wp.$c[11].'%'} = "&gt;999" ; }
  }
  }
  if (! $pageviews)
  {
    # skip sites with less than xx articles in last 6 months,
    # except when larger than yy articles in any month
    $skip_threshold  = 10 ;
    $skip_threshold2 = 10000 ;
    $not_skipped = 0 ;
    @languages_alpha  = sort { $a cmp $b } keys %languages ;
    foreach my $wp (@languages_alpha)
    {
      $skip {$wp} = $true ;
      if ($MonthlyStats {$wp.$MonthlyStatsWpStop {$wp}.$c[4]} >= $skip_threshold)
      {
        $skip {$wp} = $false ;
        $not_skipped ++ ;
      }

  #    for ($m = $m1 ; $m >= $m0 ; $m--)
  #    {
  #      if ($MonthlyStats {$wp.$m.$c[4]} >= $skip_threshold2)
  #      { @skip {$wp} = $false ; last ; }
  #    }

  #    if (@skip {$wp})
  #    {
  #      for ($m = $m1 ; $m >= $m2 ; $m--)
  #      {
  #        if ($MonthlyStats {$wp.$m.$c[4]} >= $skip_threshold)
  #        { @skip {$wp} = $false ; last ; }
  #      }
  #    }
      if ($skip {$wp})
      {
        if ($skipprojects ne "") { $skipprojects .= ", " ; }
        $skipprojects .= "$wp" ;
        if ($skipprojects2 ne "") { $skipprojects2 .= ", " ; }
        $skipprojects2 .= "$wp:<a href='" . $out_urls{$wp} . "'>".$out_languages {$wp}."</a>" ;
      }
    }
    if ($skipprojects ne "")
  # { &Log ("\n\nSkip projects with less than $skip_threshold articles between months $m2-$m1:\n$skipprojects\n") ; }
    { &Log ("\n\nSkip projects with less than $skip_threshold articles:\n$skipprojects\n") ; }
  }

  # cumulative value for largest languages
  if ($pageviews)
  {
    my ($wpfrom, $wptill, $wpcntfrom, $wpcntill, $wpheaders, $wprange1, $wprange2, $wpndx) ;

    $m1 = $md ;
    $m2 = $MonthlyStatsWpStart {"zz"} ;
    for ($m = $m1 ; $m >= $m2 ; $m--)
    {
      $wpcnt  = 0 ;
      $wpprev = 0 ;

      foreach $wp (@languages)
      {
        if ($wp eq "zz") { next ; }
        if ($wpcnt++ > 50) { last ; }

        if ($wpcnt == 0)
        { @MonthlyStats {$wp.$m.'c'} = $MonthlyStats {$wp.$m.$c[0]} ; }
        else
        { @MonthlyStats {$wp.$m.'c'} = @MonthlyStats {$wpprev.$m.'c'} + $MonthlyStats {$wp.$m.$c[0]} ; }
        $wpprev = $wp ;
      }
    }
  }


  # yearly growth in page views
  @csv = () ;
  if ($pageviews)
  {
    $m1 = $dumpmonth_ord ;
    if ($dumpmonth_incomplete)
    { $m1 -- ; }

    foreach $wp (@languages)
    {
      $MonthlyStats {$wp.$m1.'yg'} = "n.a." ;

      $views_m1 = $MonthlyStats {$wp.$m1.$c[0]} ;
      if ($views_m1 == 0) { next ; }

      $m2 = $m1 - 1 ;
      while (($MonthlyStats {$wp.($m2-1).$c[0]} > 0) && ($m2 > $m1 - 12))
      { $m2 -- ; }
      $views_m2 = $MonthlyStats {$wp.$m2.$c[0]} ;
      if ($views_m2 == 0) { next ; }

      $yearlygrowth = (sprintf ("%.0f", 100 * $views_m1 / $views_m2) - 100) ;
      if ($m2 > $m1 - 12)
      { $yearlygrowth = "($yearlygrowth)" ; }

      $MonthlyStats {$wp.$m1.'yg'} = $yearlygrowth ;

      push @csv, "$wp,$yearlygrowth\n" ;
    }

    @csv = sort @csv ;
    open  CSV_GROWTH, '>', $file_csv_views_yearly_growth ;
    print CSV_GROWTH @csv ;
    close CSV_GROWTH ;
  }
  else
  {
    open  CSV_GROWTH, '<', $file_csv_views_yearly_growth ;
    foreach $line (<CSV_GROWTH>)
    {
      chomp ($line) ;
      ($wp, $growth) = split (',', $line) ;
      $views_yearly_growth {$wp} = $growth ;
    }
    close CSV_GROWTH ;
  }

  $languagecount = $#languages ;
  $singlewiki = $false ;
  if ($languagecount == 1)
  { $singlewiki = $true ; }

  $MonthlyStatsWpStart {"zzz"} = $MonthlyStatsWpStart {$wp_2nd} ;
}

sub GetPercPageViewsMobile
{
  &Log ("GetPercPageViewsMobile\n") ;

  my (%regular,%mobile,$datemax) ;

  open "FILE_IN", "<", $file_csv_pageviewsmonthly ;
  while ($line = <FILE_IN>)
  {
    my ($wp, $date, $count) = split (",", $line) ;
    if ($wp =~ /\.m/)
    { $mobile {$date} += $count ; }
    else
    { $regular {$date} += $count ; }
  }
  &Log ("\nMobile page views:\n") ;
  foreach $date (sort keys %mobile)
  {
    next if substr ($date,8,2) < 14 ; # check day, month should contain data for at least two weeks
    if ($mobile {$date} > 0)
    {
      $perc_mobile     {$date} = sprintf ("%.1f", 100 * $mobile {$date} / ($mobile {$date} + $regular {$date})) ;
      $perc_non_mobile {$date} = sprintf ("%.1f", 100 - $perc_mobile     {$date}) ;
      &Log ("$date: ${mobile {$date}}/(${mobile {$date}} + ${regular {$date}}) = " . $perc_mobile {$date} ."%\n") ;
    }
    $maxdate = $date ;
  }

  if ($maxdate ne '')
  {
    my $year = substr ($maxdate,0,4) ;
    my $month = &month_english_short (substr ($maxdate,5,2)-1) ;
    $msg_perc_mobile = "$month $year: Mobile traffic represents ${perc_mobile {$maxdate}}% of total traffic.\n" ;
    $msg_perc_non_mobile = "$month $year: Non-mobile traffic represents ${perc_non_mobile {$maxdate}}% of total traffic.\n" ;
    print $msg_perc_mobile ;
    print $msg_perc_non_mobile ;
  }
}

sub Underscore
{
  my $text = shift ;
  $text =~ s/-/_/g ;
  return ($text) ;
}

sub IncludeLanguage
{
  my $wp = shift ;

}

1;
