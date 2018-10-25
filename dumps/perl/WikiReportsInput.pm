#!/usr/bin/perl

no warnings 'uninitialized';


sub ParseArguments
{
  my $options ;
  getopt ("ldijopmsvr", \%options) ;

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
  $path_pv       = $options {"j"} ;
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
  $dump_gallery  = $options {"G"} ;

  if ($mode eq "")
  { $mode = "wp" ; }
  if ($mode !~ /^(?:wb|wk|wn|wo|wp|wq|ws|wv|wx|wm)$/)
  { abort ("Specify mode as: -m [wb|wk|wn|wo|wp|wq|ws|wv|wx]\n(wp=wikipedia (default), wb=wikibooks, wk=wiktionary, wn=wikinews, wo=wikivoyage, wp=wikipedia, wq=wikiquote, ws=wikisource, wv=wikiversity, wx=wikispecial, , wm=wikimedia)") ; }

  if ($mode eq "wb") { $mode_wb = $true ; }
  if ($mode eq "wk") { $mode_wk = $true ; }
  if ($mode eq "wn") { $mode_wn = $true ; }
  if ($mode eq "wo") { $mode_wo = $true ; }
  if ($mode eq "wp") { $mode_wp = $true ; }
  if ($mode eq "wq") { $mode_wq = $true ; }
  if ($mode eq "ws") { $mode_ws = $true ; }
  if ($mode eq "wv") { $mode_wv = $true ; }
  if ($mode eq "wx") { $mode_wx = $true ; }
  if ($mode eq "wm") { $mode_wm = $true ; } # all projects

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
  if ($region =~ /^india$/i)
  {
    $region = lc $region ;
    $some_languages_only = $true ;
    my @langcodes = qw(as bn bh bpy en gu hi kn ks ml mr my ne new or pi pa sa sd si ta te ur) ; 
    foreach my $wp (@langcodes)
    {
      $include_language {$wp}     = $true ;
      $include_language {"$wp.m"} = $true ; # also mobile
      $languages_region .= "$wp," ;
    }

    $wp_1st = "ta" ;
    $wp_2nd = "hi" ;
  }
  elsif ($region =~ /^(?:africa|america|asia|europe|oceania|artificial)$/i)
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

  $langcode  = uc ($language) ;
  $testmode  = ((defined $options {"t"}) ? $true : $false) ;

# obsolete SP001
# $squidslog = ((defined $options {"q"}) ? $true : $false) ;

  if ($testmode)
  { print "Test mode\n" ; }

  if (defined $pageviews)
  {
    if ($pageviews eq 'n')
    {
      $pageviews_non_mobile = $true ;
      $keys_html_pageviews_all_projects = 'non-mobile,' ;
      print "Generate page views report for non-mobile site" ;
    }
    elsif ($pageviews eq 'm')
    {
      $pageviews_mobile = $true ;
      $keys_html_pageviews_all_projects = 'mobile,' ;
      print "Generate page views report for mobile site" ;
    }
    elsif ($pageviews eq 'c')
    {
      $pageviews_combined = $true ;
      $keys_html_pageviews_all_projects = 'combined,' ;
      print "Generate page views report for mobile + non-mobile site" ;
    }
    else { abort ("Invalid option for pageviews: specify '-v n' for non-mobile or '-v m' for mobile data or '-v c' for combination") ; }

    $pageviews = $true ;

    if ($normalize_days_per_month)
    { $keys_html_pageviews_all_projects .= 'normalized' ; }
    else
    { $keys_html_pageviews_all_projects .= 'not-normalized' ; }

    print "\nCollect pageviews for $keys_html_pageviews_all_projects\n\n" ;
  }

# May 2016 reports for mobile for non wikipedia projects seems long overdue: enable
# if ($pageviews && (! $pageviews_non_mobile) && (! $mode_wp))
# { abort ("For all projects expect Wikipedia only render page views reports for 'non-mobile' aka 'normal'\nif (\$pageviews && (! \$pageviews_non_mobile) && (! \$mode_wp)) ") ; }

  if (defined $animation)
  { undef $pageviews ; undef $categorytrees ; }

  if ($pageviews && $mode_wp && ($region eq '') && $pageviews_non_mobile && $keys_html_pageviews_all_projects =~ /not-normalized/)
  { $log_forecasts = $true ; }

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

  if ($path_pv =~ /\\/)
  { $path_pv  =~ s/[\\]*$/\\/ ; } # make sure there is one trailing (back)slash
  else
  { $path_pv  =~ s/[\/]*$/\// ; }

  if ($dump_gallery)
  {
    if ($path_out =~ /\\/)
    { $path_out  =~ s/[\\]*$/\\/ ; } # make sure there is one trailing (back)slash
    else
    { $path_out  =~ s/[\/]*$/\// ; }
    $path_in .= "csv_$mode\\" ;
  }
  else
  {
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

  if (! -d $path_pv)
  { abort ("Project views directory '" . $path_pv . "' not found.") ; }

  if (! -d $path_out)
  { mkdir $path_out, 0777 ; }

  if (($mode_wp) && $mediawiki)
  {
    if (! -d $path_out_timelines)
    { mkdir $path_out_timelines, 0777 ; }
  }

  if (! -d $path_out)
  { abort ("Output directory '" . $path_out . "' not found and could not be created") ; }

  $path_temp = "/a/tmp/wikistats" ;

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

  $file_csv_stats_ploticus          = $path_in . "StatisticsPlotInput.csv" ;
  $file_csv_monthly_stats           = $path_in . "StatisticsMonthly.csv" ;
  $file_csv_monthly_stats_full      = $path_in . "StatisticsMonthlyFullArchive.csv" ;
  $file_csv_namespace_stats         = $path_in . "StatisticsPerNamespace.csv" ;
  $file_csv_weekly_stats            = $path_in . "StatisticsWeekly.csv" ;
  $file_csv_users                   = $path_in . "StatisticsUsers.csv" ;
  $file_csv_active_users            = $path_in . "StatisticsActiveUsers.csv" ;
  $file_csv_bot_actions             = $path_in . "StatisticsBots.csv" ;
  $file_csv_bots                    = $path_in . "Bots.csv" ;
  $file_csv_access_levels           = $path_in . "StatisticsAccessLevels.csv" ;
  $file_csv_sleeping_users          = $path_in . "StatisticsSleepingUsers.csv" ;
  $file_csv_size_distribution       = $path_in . "StatisticsSizeDistribution.csv" ;
  $file_csv_edit_distribution       = $path_in . "StatisticsEditDistribution.csv" ;
  $file_csv_edits_per_day           = $path_in . "StatisticsEditsPerDay.csv" ;
  $file_csv_anonymous_users         = $path_in . "StatisticsAnonymousUsers.csv" ;
  $file_csv_webalizer_monthly       = $path_in . "StatisticsWebalizerMonthly.csv" ;
  $file_csv_web_requests_daily      = $path_in . "StatisticsWebRequestsDaily.csv" ;
  $file_csv_web_visits_daily        = $path_in . "StatisticsWebVisitsDaily.csv" ;
  $file_csv_timelines               = $path_in . "StatisticsTimelines.csv" ;
  $file_csv_log                     = $path_in . "StatisticsLog.csv" ;
  $file_csv_binaries_stats          = $path_in . "StatisticsPerBinariesExtension.csv" ;
  $file_csv_language_codes          = $path_in . "LanguageCodes.csv" ;
  $file_csv_zeitgeist               = $path_in . "ZeitGeist.csv" ;
  $file_csv_participation           = $path_in . "Participations.csv" ;

  $file_csv_pageviewsmonthly        = $path_pv . "projectviews_per_month_all.csv" ;
  $file_csv_pageviewsmonthly_merged = $path_pv . "projectviews_per_month_all_merged_mobile_zero.csv" ;

# obsolete SP001
# $file_csv_pageviewsmonthly_combi  = $path_pv . "PageViewsPerMonthAllCombi.csv" ;
  $file_csv_pageviewsmonthly_totals = $path_pv . "projectviews_per_month_all_totalled.csv" ;
  $file_csv_views_yearly_growth     = $path_pv . "projectviews_growth_last_year" ;
  $file_csv_views_log_forecast      = $path_pv . "PageViewsLogForecast.csv" ;
  $file_csv_perc_mobile             = $path_pv . "projectviews_per_month_mobile_trends.csv" ;
  $file_csv_pageviewsmonthly_html   = $path_pv . "projectviews_per_month_all_projects_html.csv" ;

  # use old names ?
  if (! -e $file_csv_pageviewsmonthly)
  {
    $file_csv_pageviewsmonthly        = $path_in . "PageViewsPerMonthAll.csv" ;
    $file_csv_pageviewsmonthly_merged = $path_in . "PageViewsPerMonthAllMergedMobileZero.csv" ;
  # obsolete SP001
  # $file_csv_pageviewsmonthly_combi  = $path_in . "PageViewsPerMonthAllCombi.csv" ;
    $file_csv_pageviewsmonthly_totals = $path_in . "PageViewsPerMonthAllTotalled.csv" ;
    $file_csv_views_yearly_growth     = $path_in . "PageViewsGrowthLastYear.csv" ;
    $file_csv_views_log_forecast      = $path_in . "PageViewsLogForecast.csv" ;
    $file_csv_perc_mobile             = $path_in . "PageViewsPerMonthMobileTrends.csv" ;
    $file_csv_pageviewsmonthly_html   = $path_in . "PageViewsPerMonthHtmlAllProjects.csv" ;
  }
  
  # combine counts for .m and .z   
  if (-e $file_csv_pageviewsmonthly)
  {
    my $lines_in, $lines_out, $size_in, $size_out, $count_in, $count_out ;

    open PV_IN, '<', $file_csv_pageviewsmonthly ;
    while ($line = <PV_IN>)
    {
      next if $line !~ /,/ ;
      $lines_in++ ;
      chomp $line ;
      ($lang,$date,$count) = split (',', $line) ;
      $count_in += $count ;
      $lang =~ s/\.z/\.m/ ;
      $pageviewsmonthly {"$lang,$date"} += $count ; 
    }     
    close PV_IN ;
    
    open PV_OUT, '>', $file_csv_pageviewsmonthly_merged ;
    foreach $key (sort keys %pageviewsmonthly)
    { 
      $lines_out++ ;
      $count = $pageviewsmonthly {$key} ;
      print PV_OUT "$key,$count\n" ;
      $count_out += $count ;
    }
    close PV_OUT ; 
    undef %pageviewsmonthly ;

    $size_in  = -s $file_csv_pageviewsmonthly ;
    print "\nMerge .m and .z counts\n" ;
    print "in: $file_csv_pageviewsmonthly lines $lines_in size $size_in count $count_in\n" ;
    $file_csv_pageviewsmonthly      = $file_csv_pageviewsmonthly_merged ;
    $size_out = -s $file_csv_pageviewsmonthly ;
    print "out: $file_csv_pageviewsmonthly lines $lines_out size $size_out count $count_out\n\n" ;
  }
  
  $file_csv_edits_per_article       = $path_in . "EditsPerArticle.csv" ;
  $file_csv_users_activity_spread   = $path_in . "StatisticsUserActivitySpread.csv" ;
  $file_csv_growth                  = $path_in . "WikimediaGrowthStats.csv" ;
  $file_txt_growth                  = $path_in . "WikimediaGrowthStats.txt" ;

  $file_csv_user_activity_trends    = $path_in . "UserActivityTrends.csv" ;
  $file_csv_namespaces              = $path_in . "Namespaces.csv" ;
  $file_edits_per_namespace         = $path_in . "StatisticsEditsPerNamespace.csv" ;
  $file_edits_per_usertype          = $path_in . "StatisticsEditsPerUsertype.csv" ;
  $file_pageviews_per_wiki          = $path_in . "StatisticsPageviewsPerWiki.csv" ;
  $file_editors_per_wiki            = $path_in . "StatisticsEditorsPerWiki.csv" ;
  $file_binaries_per_wiki           = $path_in . "StatisticsPlotBinariesPerWiki.csv" ;
  $file_csv_uploaders               = $path_in . "UserActivityTrendsNewBinariesCOMMONS.csv" ;

  $file_log                         = $path_in . "WikiReportsLog.txt" ;
  $file_errors                      = $path_in . "WikiReportsErrors.txt" ;

  $file_csv_participation           = $path_in . "Participation.csv" ;
  $file_csv_language_names_php      = $path_in . "LanguageNamesViaPhp.csv" ;
  $file_csv_language_names_wp       = $path_in . "LanguageNamesViaWpEn.csv" ;
  $file_csv_language_names_wp_cl    = $path_in . "LanguageNamesViaWpEnEdited.csv" ;
  $file_csv_language_names_diff     = $path_in . "LanguageNamesViaPhpAndWpCompared.csv" ;
  $file_csv_translatewiki           = $path_in . "TranslateWiki.csv" ;
  $file_csv_run_stats               = $path_in . "StatisticsLogRunTime.csv" ;

  $file_csv_whitelist_wikis         = $path_in . "WhiteListWikis.csv" ;
  $file_publish                     = $path_out . "#publish.txt" ;

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
  $file_animation_projects_growth = $path_out . "AnimationProjectsGrowthInit".ucfirst($mode).".js" ;
# $file_animation_projects_growth    = "W:/@ Visualizations/Animation Projects Growth/AnimationProjectsGrowthInit".ucfirst($mode).".js" ;
# $file_animation_size_and_community = "W:/@ Visualizations/Animation Size And Community/AnimationProjectsGrowthInit".ucfirst($mode).".js" ;

# if ($pageviews)
# {
    if (! -e $file_csv_pageviewsmonthly)
    { abort ("CSV file '" . $file_csv_pageviewsmonthly . "' not found or in use") ; }
#   return ;
# }

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
  { &Log ("Script runs for Wikimedia site") ; }
  else
  { &Log ("Script does not run for WikiMedia site") ; }
}

sub InitGlobals
{
  &Log ("InitGlobals\n") ;

  &SetScriptTrackerCode ;

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

  if (($dumpday < 5) || ($dumpday == days_in_month ($dumpyear, $dumpmonth)))
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

  $bot_mode_edits   = 'edits' ;
  $bot_mode_creates = 'creates' ;

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
  if ($wp eq '')
  { $wp = $language ; }

  if (! -e $file_csv)
  { &Log ("File $file_csv not found.\n") ; return ; }

  open FILE_IN, "<", $file_csv ;
  while ($line = <FILE_IN>)
  {
    if ($line =~ /^\s*$wp\,/)
    {
      chomp ($line) ;
      push @csv, $line ;
    }
  }
  close FILE_IN ;
}

sub ReadFileCsvExcept
{
  my ($file_csv,$wp) = @_ ;
  undef @csv  ;

  if (! -e $file_csv)
  { &LogT ("File $file_csv not found.\n") ; return ; }

  open FILE_IN, "<", $file_csv ;
  while ($line = <FILE_IN>)
  {
    if ($line !~ /^$wp\,/)
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
    my ($wp,$dumpdate,$parsedate,$dummy4,$dummy5, $factor_5, $factor_100, $active_users) = split (",", $line) ;
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
    $lastdump_long  {$wp} = &GetMonthLong (substr ($dumpdate,4,2)) . ' ' . substr ($dumpdate,0,4) ;
    $lastdump_short_month {$wp} = &GetMonthShort (substr ($dumpdate,4,2)) ;
    if ($dumpdate > $lastdump {"zz"})
    { $lastdump {"zz"} = $dumpdate ; }
    $parsedate {$wp} = substr ($parsedate,6,4) . substr ($parsedate,0,2) . substr ($parsedate,3,2) ;
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
  my @fields ;

  if (! -e $file_csv_bot_actions)
  { &Log ("$file_csv_bot_actions not found!\n") ; return ; }
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
        $BotEditsArticlesPerWikiPerBot {"$wp|$bot"} = 0 ;
        $BotEditsArticlesPerWikiPerBot {"$wp|$bot"} = 0 ;
      }
    }
  }

  &ReadFileCsv ($file_csv_bot_actions) ;

  foreach $line (@csv)
  {
    @fields = split (",", $line) ;

    if ($#fields < 11) # old format, without creates
    {
      ($wp, $bot, $edits_0, $edits_x) = split (",", $line) ;
      $creates_0 = $creates_x = 0 ;
    }
    else
    { ($wp, $bot, $edits_0, $edits_x, $creates_0, $creates_x) = split (",", $line) ; }

    $BotEditsArticlesPerWikiPerBot   {"$wp|$bot"}   = $edits_0 ;
    $BotEditsArticlesPerBot          {"$bot"}      += $edits_0 ;
    $BotEditsArticlesPerWiki         {"$wp"}       += $edits_0 ;
    $BotEditsArticlesTotal                         += $edits_0 ;
  # $BotEditsOtherPerWpPerBot        {"$wp|$bot"}   = $edits_x ;
  # $BotEditsOtherPerBot             {"$bot"}      += $edits_x ;
  # $BotEditsOtherPerWiki            {"$wp"}       += $edits_x ;
  # $BotEditsOtherTotal                            += $edits_x ;

    $BotCreatesArticlesPerWikiPerBot {"$wp|$bot"}   = $creates_0 ;
    $BotCreatesArticlesPerBot        {"$bot"}      += $creates_0 ;
    $BotCreatesArticlesPerWiki       {"$wp"}       += $creates_0 ;
    $BotCreatesArticlesTotal                       += $creates_0 ;
  # $BotCreatesOtherPerWpPerBot      {"$wp|$bot"}   = $creates_x ;
  # $BotCreatesOtherPerBot           {"$bot"}      += $creates_x ;
  # $BotCreatesOtherPerWiki          {"$wp"}       += $creates_x ;
  # $BotCreatesOtherTotal                          += $creates_x ;
  }
}

# WhiteListLanguages = filter acceptable language codes
# Note on coding practice:
# Read '$wp' as '$language' (naming relict from old days, when Wikistats script only knew Wikipedia project)
# @languages will contain sorted list of acceptable language codes
# expect following loop everywhere: "foreach $wp (@languages) ... "
sub WhiteListLanguages
{
# $threshold_articles = 0 ; # generate all reports (debug)
# $threshold_edits    = 0 ; # generate all reports (debug) 
  $threshold_articles = 100 ;
  $threshold_edits    = 10 ;

  &LogT ("\nWhiteListLanguages\n") ;
  my $file_monthly_stats ;

  &ReadFileCsv ($file_csv_log) ;
  foreach $line (@csv)
  {
    $line =~ s/,.*$// ;
    $wp = $line ;
    if ($wp =~ /mania|team|comcom|closed|chair|langcom|office|searchcom|sep11|nostalgia|stats|test/i)
    { $wp_ignore_keyword_prohibited {$wp}++ ; next ; }

    if ($wp =~ /^(?:dk|tlh|ru_sib)/i) # dk=dumps exist(ed?) but site not, tlh=Klignon, ru-sib=Siberian
    { $wp_ignore_wiki_obsolete {$wp}++ ; next ; }

    if ($mode_wk and ($wp eq "als" or $wp eq "tlh"))
    { $wp_ignore_wiki_obsolete {$wp}++ ; next ; }

    if (! $mode_wx and ($wp eq "commons"))
    { $wp_ignore_wrong_list {$wp}++ ; next ; }

    if ($wp =~ /^zz+/i) # blast!, zz and zzz are used for totals (zz=all, zzz=minus English), now language code zz[z] appeared ??!!
    { $wp_ignore_keyword_reserved {$wp}++ ; next ; }

    if ($some_languages_only and ! $include_language {$wp})
    { $wp_ignore_outside_selection {$wp}++ ; next ; }

    $wp_whitelist {$wp} = 1 ;
    $wp_whitelist {"$wp.m"} = 1 ; # relevant when processing page views, allow for mobile version
    # some day check all code for this ambiguity, for now white list 'roa-rup' and 'roa_rup' etc
    $wp =~ s/_/-/g ;
    $wp_whitelist {$wp} = 1 ;
    $wp_whitelist {"$wp.m"} = 1 ; # relevant when processing page views, allow for mobile version
  }
  # for pageviews once each day update white list, so that WikiCountsSummarizeProjectCounts.pl step in pageviews_monthly.sh can use this same list next day
  if (($pageviews) && ($region eq ''))
  {
    open CSV_WHITE_LIST, '>', $file_csv_whitelist_wikis ;
    foreach $key (sort keys %wp_whitelist)
    {
      next if $key =~ /\.m/ ;
      print CSV_WHITE_LIST "$mode,$key\n" ;
    }
    close CSV_WHITE_LIST ;
  }

  if ($pageviews)
  { $file_monthly_stats = $file_csv_pageviewsmonthly ; } # was "PageViewsPerMonthAll.csv" ; 
  else
  { $file_monthly_stats = "StatisticsMonthly.csv" ; }

  &ReadFileCsv ($path_in . $file_monthly_stats) ;
  foreach $line (@csv)
  {
    ($wp, $date, @fields) = split (",", $line) ;
    $line =~ s/,.*$// ;
    $line =~ s/_/-/g ;
    $wp = $line ;

    if ($wp ne lc $wp)
    { $wp_ignore_code_not_lowercase {$wp}++ ; next ; } ; # cruft

    if ($wp_whitelist {$wp} == 0)
    {
      if ($wp_ignore_keyword_prohibited {$wp} +
          $wp_ignore_wiki_obsolete      {$wp} +
          $wp_ignore_wrong_list         {$wp} +
          $wp_ignore_keyword_reserved   {$wp} +
          $wp_ignore_outside_selection  {$wp} == 0)
      { $wp_ignore_no_dump_processed {$wp}++ ; next ; } ;
    }

    if (! $pageviews)
    {
      $article_counts_last_month {$wp} = $fields  [4] ;
      $edit_counts_last_month    {$wp} = $fields [11] ;
    }
  }

  if (! $pageviews)
  {
    foreach $wp (keys %article_counts_last_month)
    {
      if (($wp_whitelist {$wp} > 0) && ($article_counts_last_month {$wp} < $threshold_articles))
      {
        print "Too few articles: $wp\n" ;	       
        $wp_whitelist {$wp} = 0 ;
        $wp_ignore_too_few_articles      {$wp}++ ;
        $wp_ignore_too_small_or_inactive {$wp}++ ;
      }
    }
  # foreach $wp (keys %edit_counts_last_month)
  # {
  #   if (($wp_whitelist {$wp} > 0) && ($edit_counts_last_month {$wp} < $threshold_edits))
  #   {
  #     print "Too few edits: $wp\n" ;	       
  #     $wp_whitelist {$wp} = 0 ;
  #     $wp_ignore_too_few_edits         {$wp}++ ;
  #     $wp_ignore_too_small_or_inactive {$wp}++ ;
  #   }
  #  }
  }

  if ($mode_wx)
  { $wp_whitelist {'wikidata'} = 1 ; } # no pageviews for this yet, Q&D add here

  # needed in ProcessEditorStats, before ReadMonthlyStats
  my %languages ;
  foreach $wp (sort keys %wp_whitelist)
  {
    if (($wp !~ /\./) && ($wp !~ /-/)) # skip mobile and alias
    { $languages {$wp}++ ; }
  }
  @languages = join (',', sort keys %languages) ;

  &Log ("\nProcess language codes $languages\n\n") ;

  &Log ("\nLanguage codes not accepted, but dump processing logged in StatisticsLog.csv:\n\n") ;
  &Log ("- Keyword prohibited: " . join (',', sort keys %wp_ignore_keyword_prohibited) . "\n") ;
  &Log ("- Keyword reserved: "   . join (',', sort keys %wp_ignore_keyword_reserved) . "\n") ;
  &Log ("- Wiki obsolete: "      . join (',', sort keys %wp_ignore_wiki_obsolete) . "\n") ;
  &Log ("- Wrong list: "         . join (',', sort keys %wp_ignore_wrong_list) . "\n") ;
  &Log ("- Outside selection: "  . join (',', sort keys %wp_ignore_outside_selection) . "\n") ;

  &Log ("\nLanguage codes not on white or black list, but monthly counts available in $file_monthly_stats:\n\n") ;
  &Log ("- Not lowercase: "      . join (',', sort keys %wp_ignore_not_lowercase) . "\n") ;
  &Log ("- No dump processed: "  . join (',', sort keys %wp_ignore_no_dump_processed) . "\n") ;

  if (! $pageviews)
  {
    &Log ("- < $threshold_articles articles: " . join (',', sort keys %wp_ignore_too_few_articles) . "\n") ;
    &Log ("- < $threshold_edits edits: "       . join (',', sort keys %wp_ignore_too_few_edits) . "\n\n") ;
  }

  if ($out_included ne '')
  {
    $out_included     = "Only wikis with at least {xxx} articles are listed. " ;
    $out_included =~ s/\{xxx\}/$threshold_articles/ ;
  # $out_included =~ s/\{yyy\}/$threshold_edits/ ;
    $out_included =~ s/articles/articles (A)/ ;
  # $out_included =~ s/edits/edits (E)/ ;

    $project_cnt = 0 ;
    foreach $wp (sort keys %wp_ignore_too_small_or_inactive)
    {
      my $reason = "<font color=#8888>\(" . (0+$article_counts_last_month {$wp}) . "\)</font>" ;
    # my $reason = "<font color=#8888>\(" . (0+$article_counts_last_month {$wp}) . "\/" . (0+$edits_last_month {$wp}) . "\)</font>" ;
      $projects_omitted .= "$wp:<a href='" . $out_urls{$wp} . "'>".$out_languages {$wp}."</a> $reason, " ;
      if (++ $project_cnt % 4 == 0)
      { $projects_omitted .= "<br>" ; }
    }

    if ($projects_omitted eq '')
    { $out_included = '' ; }
    else
    {
      $projects_omitted =~ s/, // ;
    # $out_included = "<small>$out_included<br>$out_not_included (A\/E): $projects_omitted</small>" ;
    # $out_included = "<small>$out_included<br>$out_not_included: $projects_omitted</small>" ;
      $out_included = "<small>$out_included<br>Not listed: $projects_omitted</small>" ;
    }
  }
}

sub ReadMonthlyStats
{
  my ($wp, $day, $month, $year, $days, $m, $prev, $curr, $forecast, @fc) ;

  &LogT ("\nReadMonthlyStats\n") ;

  my $md = $dumpmonth_ord ;
  my @oldest_month ;
  undef (@languages) ;
  undef (@max_links) ;

  # file is sorted by WikiCounts as {&csvkey_lang_date ($a) cmp &csvkey_lang_date ($b)}

  &ReadEditActivityLevels ('zz') ;

  $MonthlyStatsWpStart {"zz"} = 9999 ;

  $month_max = 0 ;
  $active_wikis_max_1 = 0 ;
  $active_wikis_max_3 = 0 ;

  if (! $pageviews)
  {
    # read some monthly metrics from another file than StatisticsMonthly.csv
    # namely StatisticsUserActivitySpread.csv, which has more precise data (broken out by user type)  	

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

      $month = substr ($date,0,2) ;
      $year  = substr ($date,6,4) ;
      $m = ord (&yyyymm2b ($year, $month)) ;

      $count_5   = $fields [2] ;
      $count_25  = $fields [4] ;
      $count_100 = $fields [7] ;

      $user_edits_5   {"$wp,$date"} = $count_5 ;
      $user_edits_100 {"$wp,$date"} = $count_100 ;

      $editors_5    {$wp.$m} = $count_5 ;
      $editors_25   {$wp.$m} = $count_25 ;
      $editors_100  {$wp.$m} = $count_100 ;

      if ($count_5 > $editors_max_5 {$wp})
      {
        $editors_max_5       {$wp} = $count_5 ;
        $editors_month_max_5 {$wp} = $m ;
      }
      if (($editors_month_lo_5 {$wp} == 0) || ($editors_month_lo_5 {$wp} > $m))
      { $editors_month_lo_5 {$wp} = $m ; }
      if ($editors_month_hi_5 {$wp} < $m)
      { $editors_month_hi_5 {$wp} = $m ; }

      # count wikis with x+ active editors (5+ edits each) per month
      if ($count_5 >= 1) { $wikis_with_editors_with_at_least_x_edits {"$m.1"} ++ ; } 
      if ($count_5 >= 3) { $wikis_with_editors_with_at_least_x_edits {"$m.3"} ++ ; }  
      if ($count_5 >= 5) { $wikis_with_editors_with_at_least_x_edits {"$m.5"} ++ ; } 

      if ($count_5 >= 3) { $last_month_active {"$wp"} = $m ; }  

      if ($wikis_with_editors_with_at_least_x_edits {"$m.1"} > $active_wikis_max_1)
      { 
        $active_wikis_max_1= $wikis_with_editors_with_at_least_x_edits {"$m.1"} ;
        $active_wikis_month_max_1 = $m ;
      }
      if ($wikis_with_editors_with_at_least_x_edits {"$m.3"} > $active_wikis_max_3)
      { 
        $active_wikis_max_3= $wikis_with_editors_with_at_least_x_edits {"$m.3"} ;
        $active_wikis_month_max_3 = $m ;
      }
    }
 
    close "FILE_IN" ;

    # read some more monthly metrics from another file than StatisticsMonthly.csv 
    # namely from StatisticsMonthlyFullArchive.csv, which has also data derived from article content, like word counts, avg article size, image and link counts 
    # (if it exists, which is only for Wikipedias right now, for other projects full archive is always used) 	
    # note: other data in StatisticsMonthlyFullArchive.csv differ somewhat from data in StatisticsMonthly.csv
    #       this is because for parsing of full archive file, existence of internal link is taken into account (part of official definition for proper article)
    #       those fields which exist in both files are always taken from StatisticsMonthly.csv also for Wikipedias, for consistency
    #       as full archive metrics will be gathered with lower frequency than once a month

    if (-e $file_csv_monthly_stats_full) # only for Wikipedia 
    {
      open "FILE_IN", "<", $file_csv_monthly_stats_full ;
      while ($line = <FILE_IN>)
      {
        chomp ($line) ;
        ($wp, $date, @fields) = split (",", $line) ;
        next if $wp_whitelist {$wp} == 0 ;

	if (($date eq '01/31/2014') && ($fields [5] > 0)) # has full archive dump for this wiki been processed lately?
	{ $monthly_stats_full_archive_input {$wp} = $true ; }	
                                                               # see top table in e.g. http://stats.wikimedia.org/EN/TablesWikipediaEN.htm 
	$metrics_full_archive {"$wp,$date,5"}  = $fields [ 5] ; # column F: Articles | count | > 200 ch 
	$metrics_full_archive {"$wp,$date,8"}  = $fields [ 8] ; # column I: Articles | mean  | bytes 
	$metrics_full_archive {"$wp,$date,9"}  = $fields [ 9] ; # column J: Articles | larger then | 0.5 Kb 
	$metrics_full_archive {"$wp,$date,10"} = $fields [10] ; # column K: Articles | larger then | 2   Kb 
	$metrics_full_archive {"$wp,$date,12"} = $fields [12] ; # column M: Database | larger then | 2   Kb 
	$metrics_full_archive {"$wp,$date,13"} = $fields [13] ; # column N: Database | larger then | 2   Kb 
	$metrics_full_archive {"$wp,$date,14"} = $fields [14] ; # column O: Links    | internal 
	$metrics_full_archive {"$wp,$date,15"} = $fields [15] ; # column P: Links    | interwiki 
	$metrics_full_archive {"$wp,$date,16"} = $fields [16] ; # column Q: Links    | image 
	$metrics_full_archive {"$wp,$date,17"} = $fields [17] ; # column R: Links    | external 
      }
      close "FILE_IN" ;
    } 	    
  }

  # find oldest month (to be skipped, probably incomplete)
  # $oldest_month_pageviews  = "9999/99/99" ;
  &Log ("\nRead page views from $file_csv_pageviewsmonthly\n") ;
  open "FILE_IN", "<", $file_csv_pageviewsmonthly ;
  $m_min = 999 ;
  $m_max = 0 ;
  while ($line = <FILE_IN>)
  {
    chomp $line ;
    ($wp, $date, $count) = split (",", $line) ;

    next if $wp_whitelist {$wp} == 0 ;

    if (($oldest_month_pageviews {$wp} eq "") || ($date lt $oldest_month_pageviews {$wp}))
    { $oldest_month_pageviews {$wp} = $date ; }

    $month = substr ($date,5,2) ;
    $year  = substr ($date,0,4) ;

    next if $year < 2001 ; # StatisticsMonthly.csv contains weird dates for tiny Wp's, to be fixed in counts job

    next if $wp eq "ar" and $year < 2003 ; # clearly erroneous record for arwiki pollutes TablesWikipediaGrowthSummaryContributors.htm

    $m = ord (&yyyymm2b ($year, $month)) ;
    if ($m < $m_min) { $m_min = $m ; }
    if ($m > $m_max) { $m_max = $m ; }

    next if $mode_wx and $m < 102 ; # oldest months are erroneous (incomplete)

    # figures for current month are ignored when month has just begun # 
    $days_in_month = days_in_month ($year, $month) ;
    $count_normalized = sprintf ("%.0f", 30/$days_in_month * $count) ;
    $pageviews     {$wp.$m} = $count_normalized ;
    $pageviews_raw {$wp.$m} = $count ;

    $pageviews_monthly_totals_raw        {"$year-$month"} += $count ; # 
    $pageviews_monthly_totals_normalized {"$year-$month"} += $count_normalized ;

    $wp_zz = 'zz' ; 
    if (($wp =~ /\.m/) || ($wp =~ /\.z/)) # new data file contains .z, not .zero
    { $wp_zz .= '.m' ; }
    $pageviews     {$wp_zz.$m} += $count_normalized ; 
    $pageviews_raw {$wp_zz.$m} += $count ;           

    if (($pageviews_month_lo {$wp} == 0) || ($pageviews_month_lo {$wp} > $m))
    { $pageviews_month_lo {$wp} = $m ; }
    if ($pageviews_month_hi {$wp} < $m)
    { $pageviews_month_hi {$wp} = $m ; }
    
    if (($pageviews_month_lo {'zz'} == 0) || ($pageviews_month_lo {'zz'} > $m))
    { $pageviews_month_lo {'zz'} = $m ; }
    if ($pageviews_month_hi {'zz'} < $m)
    { $pageviews_month_hi {'zz'} = $m ; }
  }
  close "FILE_IN" ;

  for ($m = $m_min ; $m <= $m_max ; $m++ )
  {
    $count_normalized_zz = $pageviews {$wp_zz.$m} ; 
    $count_zz = $pageviews_raw {$wp_zz.$m} ;        
  }

  open "FILE_TOTALS", ">", $file_csv_pageviewsmonthly_totals ;
  print FILE_TOTALS "date,page views raw,page views normalized\n" ;
  foreach $yyyymm (sort keys %pageviews_monthly_totals_raw)
  { print FILE_TOTALS "$yyyymm," . $pageviews_monthly_totals_raw {$yyyymm} . ',' . $pageviews_monthly_totals_normalized {$yyyymm} . "\n" ; }
  close "FILE_TOTALS" ;

  if ($pageviews)
  { open "FILE_IN", "<", $file_csv_pageviewsmonthly ; }
  else
  { open "FILE_IN", "<", $file_csv_monthly_stats ; }

  while ($line = <FILE_IN>) # qqq
  {
    chomp ($line) ;

    if ($pageviews)
    {
      ($wp, $date, @fields) = split (",", $line) ;
      next if $wp_whitelist {$wp} == 0 ;
      next if $pageviews_mobile and $wp !~ /\.m/ ;
      next if $pageviews_non_mobile and $wp =~ /\.m/ ;

      $wp =~ s/\.m// ; # mobile postix is .m

      if (! $mode_wo) # temp to see any data in report 
      { next if $date eq $oldest_month_pageviews {$wp} ; } # skip first month, probably incomplete

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
    {
      ($wp, $date, @fields) = split (",", $line) ;
      next if $wp_whitelist {$wp} == 0 ;

      # substitute data from StatisticsUserActivitySpread.csv
      $fields [2] = $user_edits_5   {"$wp,$date"} ;
      $fields [3] = $user_edits_100 {"$wp,$date"} ;

      # substitute data from StatisticsMonthlyFullArchive.csv, see above "if (-e $file_csv_monthly_stats_full)"
      if (defined ($metrics_full_archive {"$wp,$date,5"}))
      {
        $fields  [5] = $metrics_full_archive {"$wp,$date,5"}  ; # column F: Articles | count | > 200 ch 
	$fields  [8] = $metrics_full_archive {"$wp,$date,8"}  ; # column I: Articles | mean  | bytes 
	$fields  [9] = $metrics_full_archive {"$wp,$date,9"}  ; # column J: Articles | larger then | 0.5 Kb 
	$fields [10] = $metrics_full_archive {"$wp,$date,10"} ; # column K: Articles | larger then | 2   Kb 
	$fields [12] = $metrics_full_archive {"$wp,$date,12"} ; # column M: Database | larger then | 2   Kb 
	$fields [13] = $metrics_full_archive {"$wp,$date,13"} ; # column N: Database | larger then | 2   Kb 
	$fields [14] = $metrics_full_archive {"$wp,$date,14"} ; # column O: Links    | internal 
	$fields [15] = $metrics_full_archive {"$wp,$date,15"} ; # column P: Links    | interwiki 
	$fields [16] = $metrics_full_archive {"$wp,$date,16"} ; # column Q: Links    | image 
	$fields [17] = $metrics_full_archive {"$wp,$date,17"} ; # column R: Links    | external
      } 	
    }


    # $date = &FixDateMonthlyStats ($date) ;
    $day   = substr ($date,3,2) ;
    $month = substr ($date,0,2) ;
    $year  = substr ($date,6,4) ;

    next if $wp_whitelist {$wp} == 0 ;
    next if $year < 2001 ;  # StatisticsMonthly.csv contains weird dates for tiny Wp's, to be fixed in counts job
    next if $wp eq "ar" and $year < 2003 ;  # clearly erroneous record for arwiki pollutes TablesWikipediaGrowthSummaryContributors.htm

    $m = ord (&yyyymm2b ($year, $month)) ;

    next if $pageviews and $mode_wx and $m < 102 ; # oldest months are erroneous (incomplete)

    next if $wp eq 'commons' and $m < 58 ; # &yyyymm2b(2004,9) -> 59 ; there is stray record years earlier, ignore

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
      { $MonthlyStats {$wp.$m.$c[$f]}  += $fields [$f] ; } # += instead of = for combined page views: mobile + non-mobile
      else
      { $MonthlyStats {$wp.$m.$c[$f+2]} = $fields [$f] ; } # daily usage counts will be 'inserted' below,
                                                           # those used to be last columns in input,
                                                           # before 'perc. categorized' was added
      if ($c[$f] =~ /A|C|E/)
      {
        if ($fields [$f] > $MonthlyStatsHigh {$wp.$c[$f]})
        {
          $MonthlyStatsHigh {$wp.$c[$f]} = $fields [$f] ; # 
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
      # &Log ("wp $wp -> MonthlyStatsWpStop $m = $date\n") ;
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
  &Log ("\nRead page views done\n") ;
  
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

	# add count for non-mobile (input from csv_sp only has mobile stats)
        $lang2 =~ s/\.m// ;
        if (! defined $PageViewsPerHour {$lang2})
        { $PageViewsPerHour {$lang2} = $count / (24 * $day) ; }
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

  if ($pageviews || $wikimedia)
  {
    $sort_pageviews = $true ;

  # obsolete SP001
  # if ($squidslog)
  # { &ReadFileCsv ($file_csv_pageviewsmonthly_combi, "") ; }
  # else
  # { &ReadFileCsv ($file_csv_pageviewsmonthly, "") ; }
    &ReadFileCsv ($file_csv_pageviewsmonthly, "") ; 

    foreach $line (@csv)
    {
      chomp $line ;
      my ($lang,$date,$count) = split (',', $line) ;

      next if $lang =~ /\.m/ ; # only add count for non-mobile

      my ($year,$month,$day)  = split ('/', $date) ;
      if ($day > 5) # q&d: use most recent month, unless month less than 5 days old
      {
        ($lang2 = $lang) =~ s/-/_/g ;
	# add count for non-mobile
	$PageViewsPerHourSort {$lang2} = $count / (24 * $day) ;
      }
    }
  }  

    # if ($mode_wp)
  if ($sort_pageviews)
  {
    @languages  = sort { $PageViewsPerHourSort {&Underscore($b)} <=> $PageViewsPerHourSort {&Underscore($a)} } keys %languages ;
    # foreach $lang (@languages)
    # { $lang =~ s/-/_/g ; }
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

  push @languages,'zz' ;
  for $wp (@languages)
  {
    next if $wp_whitelist {$wp} == 0 and $wp !~ /^zz+$/ ; 

    ($wp2 = $wp) =~ s/\.m// ;
    for ($m = $m_min ; $m <= $m_max ; $m++ )
    {
      if ($pageviews_non_mobile)
      {
        $count_normalized = $pageviews     {$wp.$m} ;
        $count_raw        = $pageviews_raw {$wp.$m} ;
      }
      elsif ($pageviews_mobile)
      {
        $count_normalized = $pageviews     {"$wp.m".$m} ;
        $count_raw        = $pageviews_raw {"$wp.m".$m} ;
      }
      else # $pageviews_combined
      {
        $count_normalized = $pageviews     {$wp.$m} + $pageviews     {"$wp.m".$m} ;
        $count_raw        = $pageviews_raw {$wp.$m} + $pageviews_raw {"$wp.m".$m} ;
      }

      if ($normalize_days_per_month)
      {
      	if ($count_normalized > $pageviews_max {$wp})
        {
          $pageviews_max       {$wp} = $count_normalized ;
          $pageviews_month_max {$wp} = $m ;
          $MonthlyStatsHigh {$wp.$c[0]} = $count_normalized ;
          $MonthlyStatsHighMonth {$wp.$c[0]} = $m ;
        }
      }	
      else
      {
	if ($count_raw > $pageviews_max {$wp})
        {
          $pageviews_max       {$wp} = $count_raw ;
          $pageviews_month_max {$wp} = $m ;
          $MonthlyStatsHigh {$wp.$c[0]} = $count_raw ;
          $MonthlyStatsHighMonth {$wp.$c[0]} = $m ;
        }
      }
    }
  }

  if (! $pageviews)
  {
    # collect dates to display for recent months
    $year  = substr ($recent_dates [4],6,4) ;
    $month = substr ($recent_dates [4],0,2) ;

    if (($year eq '') || ($month eq ''))
    { abort "\@recent_dates not initialized, no valid counts found?" ; }

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
  if ($pageviews)
  {
    if ($mode_wp) { $m1 = ord (&yyyymm2b (2008, 1)) ; }
    else
    {               $m1 = ord (&yyyymm2b (2008, 6)) ; }
  }
  else
  {
    if ($mode_wb) { $m1 = ord (&yyyymm2b (2001, 1)) ; }
    if ($mode_wk) { $m1 = ord (&yyyymm2b (2002,12)) ; }
    if ($mode_wn) { $m1 = ord (&yyyymm2b (2004, 7)) ; }
    if ($mode_wo) { $m1 = ord (&yyyymm2b (2001, 1)) ; } # tbd
    if ($mode_wp) { $m1 = ord (&yyyymm2b (2001, 1)) ; }
    if ($mode_wq) { $m1 = ord (&yyyymm2b (2001, 1)) ; }
    if ($mode_ws) { $m1 = ord (&yyyymm2b (2001, 1)) ; }
    if ($mode_wx) { $m1 = ord (&yyyymm2b (2001, 1)) ; }
    if ($mode_wm) { $m1 = ord (&yyyymm2b (2001, 1)) ; }
  }

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
        if (($f < 2) || ($f > 3))
        {
          $MonthlyStats {"zz".$m.$c[$f]} = $zz ;
          if ($mode_wp)
          { $MonthlyStats {"zzz".$m.$c[$f]} = $zzz ; }
        }
        else
        {
        # totalling all editors for zz and zzz is not done in WikiCountsProcess sub CollectActiveUsersPerMonthsAllWikis
          if ($f == 2)
          {
            $MonthlyStats {"zz". $m.$c[$f]} = $editors_5 {'zz'.$m} ;
            $MonthlyStats {"zzz".$m.$c[$f]} = $editors_5 {'zzz'.$m} ;
          }
          else
          {
            $MonthlyStats {"zz". $m.$c[$f]} = $editors_100 {'zz'.$m} ;
            $MonthlyStats {"zzz".$m.$c[$f]} = $editors_100 {'zzz'.$m} ;
          }
        }

        if ($zz > $MonthlyStatsHigh {$wp.$c[$f]})
        {
          $MonthlyStatsHigh {$wp.$c[$f]} = $zz ;
          $MonthlyStatsHighMonth {$wp.$c[$f]} = $m ;
        }
      }
##########################################################################################################
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
  if ($log_forecasts)
  { open LOG_FORECASTS, '>>', $file_csv_views_log_forecast ; }

  if ($show_forecasts)
  {
    my $factor = days_in_month ($dumpyear, $dumpmonth) / ($dumpday-0.5) ;
    &Log ("Forecast factor: days in month ". days_in_month ($dumpyear, $dumpmonth) . ", dump day $dumpday -> $factor\n") ;

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
        {
          $forecast = $factor * $curr ;
          if ($log_forecasts && ($f == 0))
          {
            $factor2   = sprintf ("%.3f", $factor) ;
            $forecast2 = sprintf ("%.0f", $forecast) ;
            print LOG_FORECASTS "$datemax,$factor2,$wp,$curr,$forecast2\n" ;
          }
        }
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

  if ($log_forecasts)
  { close LOG_FORECASTS ; }

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
  if ($month_max_incomplete) { $m1-- ; $m2-- ; }

# debug code
  $m1-- ; 
  $m2-- ; 

  $articles_plus_since = "1 " . &GetDateShort2 ($m2+1, $true) ;
  foreach my $wp (@languages)
  {
    foreach $f (0,4)
    {
      if ($m2 <= $MonthlyStatsWpStop {$wp})
      {
# debug code
# if ($f == 0)
# { 
# print "A wp $wp: f:$f c[f]:" . $c[$f] . " m1:$m1 high: '" . @MonthlyStatsHigh {$wp.$c[$f]} . "' 12 months earlier: m2:$m2 " . @MonthlyStats {$wp.$m2.$c[$f]} . "\n" ; 
# print "B wp $wp: f:$f c[f]:" . $c[$f] . " m1:$m1 high: '" . @MonthlyStats {$wp.$m1.$c[$f]} . "' 12 months earlier: m2:$m2 " . @MonthlyStats {$wp.$m2.$c[$f]} . "\n" ;
# }
      # @MonthlyStats {$wp.$c[$f].'+'} = @MonthlyStatsHigh {$wp.$c[$f]} -
      #                                  @MonthlyStats     {$wp.$m2.$c[$f]} ;
        @MonthlyStats {$wp.$c[$f].'+'} = @MonthlyStats {$wp.$m1.$c[$f]} -
                                         @MonthlyStats {$wp.$m2.$c[$f]} ;
        if (@MonthlyStats {$wp.$c[$f].'+'} < 0)
        { @MonthlyStats {$wp.$c[$f].'+'} = 0 ; }

      # if (@MonthlyStatsHigh {$wp.$c[$f]} > 0)
        if (@MonthlyStats {$wp.$m1.$c[$f]} > 0)
        {
          @MonthlyStats {$wp.$c[$f].'%'} = sprintf ("%.0f" , 100 *@MonthlyStats {$wp.$c[$f].'+'} /
                                          @MonthlyStats     {$wp.$m1.$c[$f]}) ;
                                        # @MonthlyStatsHigh {$wp.$c[$f]}) ;
          if (@MonthlyStats {$wp.$m2.$c[$f]} > 0)
          {   @MonthlyStats {$wp.$c[$f].'+%'} = 100 * (@MonthlyStats {$wp.$c[$f].'+'} / @MonthlyStats {$wp.$m2.$c[$f]}) ; }
          if (@MonthlyStats {$wp.$c[$f].'+%'} < 10)
          {   @MonthlyStats {$wp.$c[$f].'+%'} = sprintf ("%.1f", @MonthlyStats {$wp.$c[$f].'+%'}) ; }
          else
          {   @MonthlyStats {$wp.$c[$f].'+%'} = sprintf ("%.0f", @MonthlyStats {$wp.$c[$f].'+%'}) ; }
          if (@MonthlyStats {$wp.$c[$f].'+%'} >999)
          {   @MonthlyStats {$wp.$c[$f].'+%'} = "" ; }
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

      foreach $m ($m3, $m3-1, $m3-2, $m3-3, $m3-4, $m3-5, $m3-6, $m3-7, $m3-8, $m3-9, $m3-10, $m3-11)
      { @MonthlyStats {$wp.$c[$f].'avg12'} += @MonthlyStats {$wp.$m.$c[$f]} ; }
      @MonthlyStats {$wp.$c[$f].'avg12'} /= 12 ;
      @MonthlyStats {$wp.$c[$f].'avg12'} = sprintf ("%.0f", @MonthlyStats {$wp.$c[$f].'avg12'}) ;
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

    # print "$m editstot $editstot, editsnew $editsnew\n" ; # qqqq
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

  if ($mode_wp)
  {
    open  CSV_PERC_MOBILE, '<', $file_csv_perc_mobile ;
    while ($line = <CSV_PERC_MOBILE>)
    {
    # next if $line =~ /^#/ ;
      next if $line !~ /^wp/ ;
      ($project,$dummy,$wp,$yyyymm,$perc_mobile) = split (',', $line) ; 
      $m = &yyyymmdd2i (substr ($yyyymm,0,4) . substr ($yyyymm,5,2)) ;
      $MonthlyStats {$wp.($m).'pm'} = $perc_mobile ;
    }
    close CSV_PERC_MOBILE ;
  }
  
  &LogT ("\nReadMonthlyStats done\n") ;
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
    $msg_perc_mobile = "$month $year: mobile traffic represents ${perc_mobile {$maxdate}}% of total traffic" ;
    $msg_perc_non_mobile = "$month $year: non-mobile traffic represents ${perc_non_mobile {$maxdate}}% of total traffic" ;
    print "$msg_perc_mobile\n" ;
    print "$msg_perc_non_mobile\n" ;
  }
}

sub ReadEditActivityLevels
{
# @thresholds = (1,3,5,10,25,32,50,100,250,316,500,1000,2500,3162,5000,10000,25000,31623,50000,100000,250000,316228,500000,1000000,2500000,3162278,500000,10000000,25000000,31622777,5000000,100000000) ;

  my ($wp) = @_ ;

# &LogT ("\nReadEditActivityLevels $wp from $file_csv_users_activity_spread\n") ;

  undef %user_activity_levels ;
  undef %user_activity_levels_max ;
  undef %activity_level_max ;

  if ($wp =~ /^zz/)
  { &ReadFileCsv ($file_csv_users_activity_spread) ; }      # no language code specified => data for all languages will be imported
  else
  { &ReadFileCsv ($file_csv_users_activity_spread, $wp) ; } # language code specified => data for that language only will be imported

  foreach $line (@csv)
  {
    chomp ($line) ;
    ($lang,$date,$usertype,$nscat,@counts) = split (',', $line) ;

    next if ! $mode_wx and $lang =~ /commons/i ; # occurs (still) also in wikipedia csv files (commons was on wikipedia input queue shortly, in start 2010, by error)

    $lang2 = $lang ;
    if (($wp =~ /^zz/) && ($lang !~ /^zz/)) # accumulate counts from all wikis (except from codes for totals zz/zzz/zz28) for legacy reporting
    { $lang2 = '!zz' ; }                      # so only counts left are for one language,or for 'zz', 'zz28' and remainder '!zz+'

  # next if $date ne '11/30/2011' ; # test only

    $month = substr ($date,0,2) ;
    $year  = substr ($date,6,4) ;
    $m = &yyyymm2b ("$year$month") ;

    for ($c = 0 ; $c <= $#counts ; $c ++)
    {
      $user_activity_levels {$lang2} {$date} {$usertype} {$nscat} {$c} += $counts [$c] ;

      if ($user_activity_levels {$lang2} {$date} {$usertype} {$nscat} {$c} > $user_activity_levels_max {$lang2} {$usertype} {$nscat} {$c})
      { $user_activity_levels_max {$lang2} {$usertype} {$nscat} {$c} = $user_activity_levels {$lang2} {$date} {$usertype} {$nscat} {$c} ; }
    }

  # if ($m % 3 < 999) # do only for visible months
    {
      if ($#counts > $activity_level_max {$usertype} {$nscat})
      { $activity_level_max {$usertype} {$nscat} = $#counts ; }
    }
  }
}

sub ReadDumpMetaData
{
  my $wp = shift ;

  # to do: do away with this clumsy global var $language
  $language_prev = $language ;
  $language = $wp ;
  &ReadFileCsvOnly ($file_csv_run_stats, $wp) ;
  $language = $language_prev ;

  # &Log ("language,process till,time now,time now english,file format,file size on disk,file size uncompressed,host name,time parse input,time total,edits namespace 0,other edits,dump type,dump file\n") ;

  my ($lang,$processed_till,$time_now,$time_now_english,$file_format,$dump_size_compressed,$dump_size_uncompressed,$server,$time_parse_input,$time_total,$edits_ns0,$edits_nsx,$dumptype,$dumpfile,$dumpdetails) ;
  my @months_en = qw (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);

  $dumptype = 'unknown' ;
  foreach $line (@csv)
  {
    ($lang,$processed_till,$time_now,$time_now_english,$file_format,$dump_size_compressed,$dump_size_uncompressed,$server,$time_parse_input,$time_total,$edits_ns0,$edits_nsx,$dumptype,$dumpfile) = split ',' ,$line ;
    if ($dumptype !~ /^(?:edits_only|full_dump)$/)
    { $dumptype .= ' = unknown' ; }
  }
  
  if ($dump_size_compressed > 0)
  {
    $dumptype =~ s/_/ /g ;
    $dumpfile =~ s/^.*?([^\/\\]*)$/$1/ ;

    $dump_size_compressed = &i2KbMb ($dump_size_compressed) ;
    $dump_size_uncompressed = &i2KbMb ($dump_size_uncompressed) ;

    $processed_till = $months_en [substr ($processed_till,4,2)-1] .' ' . substr ($processed_till,6,2) . ', ' . substr ($processed_till,0,4) ;

    $dumpdetails = "Dump file <b>$dumpfile</b> (<b>$dumptype</b>), size <b>$dump_size_compressed</b> as <b>$file_format</b> -> <b>$dump_size_uncompressed</b>\n<br>Dump processed till <b>$processed_till</b>, on server <b>$server</b>, ready at <b>$time_now_english</b> after <b>" . ddhhmmss ($time_total) . "</b>.\n" ;
    # $dumpdetails2 = $dumpdetails ;
    # $dumpdetails2 =~ s/<[^>]*>//g ;
    # $dumpdetails2 =~ s/\&nbsp;//g ;
    # &Log ("\n$dumpdetails2\n") ;
  }

  return ($dumptype,$dumpdetails) ;
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

