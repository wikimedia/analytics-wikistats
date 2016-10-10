#!/usr/bin/perl
# derived from stat1002:/a/wikistats_git/squids/perl/SquidReportArchive.pl
# removed all code for obsolete reports  

# general remarks:lots of html is built
# place holders in full caps in the html will be replaced later on with separately built html
# example: scan for occurences of WORLDMAP_D3

# for country reports fix:
# https://bugzilla.wikimedia.org/show_bug.cgi?id=46205   fixed
# https://bugzilla.wikimedia.org/show_bug.cgi?id=46267
# https://bugzilla.wikimedia.org/show_bug.cgi?id=46277
# https://bugzilla.wikimedia.org/show_bug.cgi?id=46289

# -v -q 2012q3 -c -i "w:/# out stat1/squid/csv" -o "w:/# out test/squid/reports" -l . -a "w:/# out stat1/squid/csv/meta"

# sub ReadInputCountriesMonthly reads $path_csv_squid_counts_monthly (/a/wikistats_git/squids/csv/SquidDataVisitsPerCountryMonthly.csv)


# 2016-07-09 minus
# ExpandAbbreviation
# FormatCount
# GetSecondaryDomain
# ListLinksExcept
# ListLinksGeoExcept
# ListLinksTrendsExcept
# NormalizeCounts
# RatioAndFillColor
# RatioAndFillColor2
# ReadInputBrowserLanguages
# ReadInputClients
# ReadInputCountriesInfo
# ReadInputCountriesTimed
# ReadInputCrawlers
# ReadInputGoogle
# ReadInputIndexPhp
# ReadInputMethods
# ReadInputMimeTypes
# ReadInputOpSys
# ReadInputOrigins
# ReadInputScripts
# ReadInputSkins
# ReadInputUseragents
# ShowCount
# ShowCountTd
# ShowCountTh
# ShowMonth
# ShowPerc
# SortCounts
# UserAgentCsvLine
# UserAgentField
# UserAgentFieldNew
# UserAgentFieldPerc
# UserAgentLine
# UserAgentMobileLine
# UserAgentsTimedRow
# WriteCsvBrowserLanguages
# WriteCsvGoogleBots
# WriteCsvSvgFilePerCountryOverview
# WriteReportBrowsersTimed
# WriteReportClients
# WriteReportCountriesInfo
# WriteReportCountryBrowser
# WriteReportCountryOpSys
# WriteReportCrawlers
# WriteReportDevices
# WriteReportDevicesTimed
# WriteReportGoogle
# WriteReportMethods
# WriteReportMimeTypes
# WriteReportOpSys
# WriteReportOrigins
# WriteReportScripts
# WriteReportSkins
# WriteReportUserAgents
# WriteReportUserAgentsTimed
# hsv2rgb
# hsv_to_rgb
# isMobile

  $| = 1; # Flush output

  use SquidReportArchiveConfig ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (2) ;

  $path_upload    = "//upload.wikimedia.org/wikipedia/commons/thumb" ; 
  $icon_people    = "<sub><img src='$path_upload/9/9d/Community_Noun_project_2280.svg/20px-Community_Noun_project_2280.svg.png'></sub>" ;
  $icon_connected = "<sub><img src='$path_upload/5/59/Plug-in_Noun_project_4032.svg/20px-Plug-in_Noun_project_4032.svg.png'></sub>" ;  
  $icon_wikipedia = "<sub><img src='$path_upload/5/5a/Wikipedia%27s_W.svg/23px-Wikipedia%27s_W.svg.png'></sub>" ;
  $icon_views     = "<sub><img src='$path_upload/e/eb/PICOL_icon_View.svg/23px-PICOL_icon_View.svg.png'></sub>" ;
  $icon_person    = "<sub><img src='$path_upload/7/7f/Community_Noun_project_7345.svg/20px-Community_Noun_project_7345.svg.png'></sub>" ;
  $icon_world     = "<sub><sup><img src='$path_upload/8/85/World_icon.svg/20px-World_icon.svg.png'></sup></sub>" ;
  $icon_total     = "<font size=+1><strong><b>&Sigma;</b></strong></font>" ;

  $label_fill_region   = "<font color=#66F>region</font>" ;
  $label_fill_language = "<font color=#A0A>language</font>" ;

  default_argv ($cfg_default_argv) ;

  use Time::Local ;
  use Cwd;

  $ratio_sqrt   = $true ;
  $ratio_linear = $false ;

  getopt ("dmaqiolx", \%options) ;

  undef %country_code_not_specified_reported ;

  $path_csv     = $options {"i"} ;
  $path_reports = $options {"o"} ;
  $path_log     = $options {"l"} ;
  $path_meta    = $options {"a"} ; # m already taken, a for 'about' ~ 'meta'
  $sample_rate  = $options {"x"} ;

  print "sample rate $sample_rate\n" ;

  die ("Specify input folder as -i [..]")   if not defined $path_csv ;
  die ("Specify output folder as -i [..]")  if not defined $path_reports ;
  die ("Specify log folder as -i [..]")     if not defined $path_log ;
  die ("Specify meta folder as -a [..]")    if not defined $path_meta ;
  die ("Specify sample rate -x [..]")       if not defined $sample_rate ;

  die ("Input folder not found")      if ! -d $path_csv ;
  die ("Output folder not found")     if ! -d $path_reports ;
  die ("Log folder not found")        if ! -d $path_log ;
  die ("Meta folder not found")       if ! -d $path_meta ;
  die ("Specify numeric sample rate") if $sample_rate !~ /^\d+$/ ; 

# $job_runs_on_production_server ? $cfg_path_csv     : $cfg_path_csv_test ;
# $path_reports = $job_runs_on_production_server ? $cfg_path_reports : $cfg_path_reports_test ;
# $path_log     = $job_runs_on_production_server ? $cfg_path_log     : $cfg_path_log_test ;

  &LogDetail ("Path csv     = $path_csv\n") ;
  &LogDetail ("Path reports = $path_reports\n") ;
  &LogDetail ("Path log     = $path_log\n") ;
  &LogDetail ("Path meta    = $path_meta\n") ;

# following test needs to change -> remove server name dependency (new run argument ?)
# elsif ($hostname eq 'bayes')
# {
#   &LogDetail ("\n\nJob runs on server $hostname\n\n") ;
#   $path_csv  = "/home/ezachte/wikistats/animation" ;
#   $path_reports = "/home/ezachte/wikistats/animation" ;
# }

  $file_csv_country_meta_info = "SquidReportCountryMetaInfo.csv" ;

  $reports_set_basic     = 0 ;
  $reports_set_countries = 1 ;

  # periodically harvest updated metrics from
  # '//en.wikipedia.org/wiki/List_of_countries_by_population'
  # '//en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'
  if (defined ($options {"w"}))
  {
    use LWP::Simple qw($ua get);
    $ua->agent('Wikipedia Wikicounts job');
    $ua->timeout(60);

    &ReadWikipediaCountriesByPopulation ;
    &ReadWikipediaCountriesByInternetUsers ;

    &LogSub ("Ready\n\n") ;
    exit ;
  }
  elsif (defined ($options {"c"}))
  {
    $reportcountries = $true ;
    &LogSub ("Generate report per country\n\n") ;

    if (defined ($options {"q"}))
    {
      $quarter_only = uc ($options {"q"}) ;  # process for this quarter only
      if ($quarter_only !~ /^2\d\d\dQ\d$/)
      { abort ("Specify run for one single quarter as -q yyyyQ[1-4], e.g. -q 2011Q3, not '$quarter_only'\n") ; }
      $quarter_only =~ s/^(\d\d\d\d)(Q\d)$/$1 $2/ ;
      &LogDetail ("\nRun for one quarter only: $quarter_only\n\n") ;
    }
    else
    {
      if (! defined ($options {"m"}))
      { &LogDetail ("Specify month as -m yyyy-mm") ; exit ; }
    
      if ($options {"m"} !~ /^\d\d\d\d-\d\d$/) 
      { &LogDetail ("Specify month as -m yyyy-mm") ; exit ; }

      $reportmonth = $options {"m"} ;
      &LogDetail ("Report month = $reportmonth\n") ;
    }  
  }
  elsif (defined ($options {"m"}) || defined ($options {"d"}))
  {
    if (($options {"m"} !~ /^\d\d\d\d-\d\d$/) && ($options {"d"} !~ /^-\d+$/))
    { &LogDetail ("Specify month as -m yyyy-mm or days back as -d -[days] (e.g. -d -1 for yesterday)") ; exit ; }

    $reportdaysback  = $options {"d"} ;
    $reportmonth     = $options {"m"} ;

    if ($reportdaysback =~ /^-\d+$/)
    {
      ($sec,$min,$hour,$day,$month,$year) = localtime (time+$reportdaysback*86400) ;
      $reportmonth = sprintf ("%04d-%02d",$year+1900,$month+1) ;
    }
    &LogDetail ("Report month = $reportmonth\n") ;
  }
  else { &LogDetail ("No valid run option found. Specify -c [-q ..]| -m ..| -d ..| -w") ; exit ; }


  # date range used to be read from csv file with ReadDate, now there are daily csv files
  # if earlier methods still is useful it needs to be tweaked
  # if (($reportmonth ne "") && ($reportmonth !~ /^\d{6}$/))

  if ($quarter_only ne '')
  { $path_reports = "$path_reports/$quarter_only" ; }
  elsif ($reportmonth ne '')
  { $path_reports = "$path_reports/$reportmonth" ; }
  elsif ($reportcountries)
  { $path_reports = "$path_reports/countries" ; }

  &LogDetail ("Write report to $path_reports\n") ;

  if (! $os_windows)
  { $path_reports =~ s/ /-/g ; }

  if (! -d $path_reports)
  {
  #  print "mkdir $path_reports\n" ;
    mkdir ($path_reports) || die "Unable to create directory $path_reports\n" ;
  }

  &InitProjectNames ;

  &ReadInputRegionCodes ;
  &ReadInputCountriesNames ;
  &ReadInputCountriesMeta ;
  &ReadCountryCodes ;
  &ReadCountryCodes_3166_1_alpha_3 ;

  if ($reportcountries)
  {
    $project_mode = "wp" ; # discard all log data from other projects than Wikipedia

    &ReadInputCountriesMeta ;

    &CollectRegionCounts ;

    if (! defined ($options {"e"}) && ! defined ($options {"v"}))
    {
      &Log ("Specify '-e' for edits and/or '-v for views\n") ;
      exit ;
    }

    if (defined ($options {"e"})) # edits == saves
    { &ReportCountries ('Saves',$sample_rate); }
    if (defined ($options {"v"})) # views
    { &ReportCountries ('Views',$sample_rate); }


    exit ;
  }

  &ReadInputCountriesMeta ; # also necessary for countriesdata report

  $days_in_month = &DaysInMonth (substr ($reportmonth,0,4), substr ($reportmonth,5,2)) ;

  $threshold_mime    = 0 ;
  $threshold_project = 10 ;

  $file_log               = "SquidReportArchive.log" ;

  $file_html_countries_info = "SquidReportCountryData.htm" ;
  $file_html_countries_browser = "SquidReportCountryBrowser.htm" ;
  $file_html_countries_os = "SquidReportCountryOs.htm" ;

#  $file_csv_countries_languages_visited = "SquidDataCountriesLanguagesVisited.csv" ;
#  $file_csv_countries_timed   = "SquidDataCountriesTimed.csv" ;
#  $file_csv_browser_languages = "SquidDataLanguages.csv" ;

  $file_csv_countries_info= "public/SquidDataCountriesInfo.csv" ;

  $file_csv_countries_languages_visited = "SquidDataCountriesViews.csv" ;
  $file_csv_countries_timed             = "SquidDataCountriesViewsTimed.csv" ;

  &LogDetail ("\n\nJob SquidReportArchive.pl\n\n") ;

  if (! -d "$path_csv/$reportmonth")
  { &LogDetail ("Directory not found: $path_csv\/$reportmonth\n") ; exit ; }

# for ($month = 4 ; $month <= 10 ; $month ++)
# {
#   $reportmonth = "2009-" . sprintf ("%02d", $month) ;

    for ($day = 1 ; $day <= 31 ; $day ++)
    {
#     last if ($month == 10) && ($day > 24) # temp code stay with DST summer time zone for SV

      $date = $reportmonth . "-".  sprintf ("%02d", $day) ;
      $dir  = "$path_csv/$reportmonth/$date" ;

      if (-d $dir)
      {
        if  (-e "$dir/#Ready")
        {
          if ($date_first eq "")
          { $date_first = $date ; }
          $date_last = $date ;
          &LogDetail ("Process dir $dir\n") ;
          push @dirs_process, $dir ;
        }
        else
        { &LogDetail ("Empty or incomplete dir $dir!\n") ; }
      }
      else
      { &LogDetail ("Missing dir $dir!\n") ; }
    }
# }
  if ($#dirs_process < 0)
  { &LogDetail ("No valid data to process.\n") ; exit ; }

  &OpenLog ;
  &PrepHtml ($reports_set_basic, $sample_rate) ;
  &SetPeriod ; # now date range derived from which folders found

  foreach $path_process (@dirs_process)
  {
    $days_input_found ++ ;

    &LogDetail ("\nRead input from $path_process\n") ;
  }

  if ($days_input_found > 0)
  {
    &LogDetail ("\nDays input = $days_input_found\n") ;
    $multiplier = 1 / $days_input_found ;
    &LogDetail ("\nMultiplier = " . sprintf ("%.4f", $multiplier) . "\n") ;
  }
  else { &LogDetail ("\nDays input = 0 (zero!)\n") ; }

  &WriteCsvCountriesTimed ;
  &WriteCsvCountriesGoTo ;

  &CalcPercentages ;


  close "FILE_LOG" ;

  &LogDetail ("\nReady\n\n") ;
  exit ;

sub ReportCountries
{
  my ($mode_report,$sample_rate) = @_ ;
  &LogSub ("ReportCountries $mode_report, sample rate $sample_rate\n") ;

  if ($mode_report eq 'Views')
  {
    $selection   = 'PageViews' ;
    $selection2  = 'Visits' ;
    $views_edits = 'Page Views' ;
    $offset_links = 0 ;
  }
  else
  {
    $selection   = 'PageEdits' ;
    $selection2  = 'Saves' ;
    $views_edits = 'Page Edits' ;
    $offset_links = 4 ;
  }

  ($quarter_only2 = $quarter_only) =~ s/ // ;

  $file_csv_squid_counts_monthly        = "SquidData${selection2}PerCountryMonthly.csv" ; # LockePrev.csv" ;
  $file_csv_squid_counts_daily          = "SquidData${selection2}PerCountryPerWikiDaily.csv" ;

  $file_html_per_country_breakdown      = "SquidReport${selection}PerCountryBreakdown.htm" ;
  $file_html_per_country_breakdown_huge = "SquidReport${selection}PerCountryBreakdownHuge.htm" ;
  $file_html_per_country_overview       = "SquidReport${selection}PerCountryOverview$quarter_only2.htm" ;
  $file_html_per_country_trends         = "SquidReport${selection}PerCountryTrends.htm" ;
  $file_html_per_language_breakdown     = "SquidReport${selection}PerLanguageBreakdown.htm" ;
  $file_csv_per_country_overview        = "SquidReport${selection}PerCountryOverview.csv" ; # output file
  $file_csv_per_country_density         = "SquidReport${selection}PerCountryDensity.csv" ;  # output file

  # add prev/next for quarter reports # qqq
  $yyyy = substr ($quarter_only2,0,4) ;
  $q    = substr ($quarter_only2,5,1) ;
  if ($q == 1) { $q = 4 ; $yyyy-- ; } else  { $q-- ; }
  $link_html_per_country_overview_prev = "SquidReport${selection}PerCountryOverview${yyyy}Q$q.htm" ;

  $yyyy = substr ($quarter_only2,0,4) ;
  $q    = substr ($quarter_only2,5,1) ;
  if ($q == 4) { $q = 1 ; $yyyy++ ; } else  { $q++ ; }  
  $link_html_per_country_overview_next = "SquidReport${selection}PerCountryOverview${yyyy}Q$q.htm" ;

  $path_csv_squid_counts_monthly  = "$path_csv/$file_csv_squid_counts_monthly" ;
  if (! -e $path_csv_squid_counts_monthly)  { abort ("Input file $path_csv_squid_counts_monthly not found!") ; }
  $path_csv_squid_counts_daily  = "$path_csv/$file_csv_squid_counts_daily" ;
  if (! -e $path_csv_squid_counts_daily)  { abort ("Input file $path_csv_squid_counts_daily not found!") ; }

  &ReadInputCountriesMonthly ($project_mode) ;
# &ReadInputCountriesDaily   ($project_mode) ;

  # input for http://gunn.co.nz/map/, for now hardcoded quarter
  &WriteCsvFilePerCountryDensity ($views_edits, '2013 Q2', \%requests_per_quarter_per_country, $max_requests_per_connected_us_month, "Wikipedia " . lc $views_edits . " per person") ;

  &PrepHtml ($reports_set_countries, $sample_rate) ;
  &SetPeriod ;

# $comment = "<p>&nbsp;See also: <a href='SquidReportTrafficPerCountry.htm'>Wikipedia $views_edits per Country</a> / <a href='SquidReportLanguagesVisitedDetailed.htm'>Breakdown per Country of Wikipedia's Visited (detailed)</a> / <a href='SquidReportTrafficPerWikipediaOverview.htm'>Breakdown per Wikipedia of Requesting Countries</a>" ;

  $title_main = "Wikimedia Traffic Analysis Report" ;

  $links = "<p>&nbsp;<b>Page Views Per Country</b> - " .
           "<a href='$file_html_per_country_overview'>Overview</a> / " .
           "<a href='$file_html_per_country_breakdown'>Breakdown</a> / " .
         # "<a href='$file_html_per_country_trends'>Trends</a>,&nbsp;&nbsp;&nbsp;&nbsp;" . # deprecated, too unreliable
           "<b>Page Views Per Wikipedia Language - </b> " .
           "<a href='$file_html_per_language_breakdown'>Breakdown</a>" ;

  ($links_views = $links) =~ s/Edits/Views/g ;
# ($links_edits = $links) =~ s/Views/Edits/g ;

  $links_edits = "<p>&nbsp;<b>Page Edits Per Country</b> - " .
           "<font color=red>Data no longer available</font> / " .
           "<b>Page Edits Per Wikipedia Language - </b> " .
           "<font color=red>Data no longer available</font>" ;

  $links = "$links_views\n$links_edits\n" ;

  $title = "$title_main - Wikipedia <font color=#008000>$views_edits Per Country</font> - Overview" ; 
  &WriteReportPerCountryOverview ($title, $views_edits, &UnLink ($links,$offset_links+1),$sample_rate) ;

  $title = "$title_main - Wikipedia <font color=#008000>$views_edits Per Country</font> - Breakdown" ;

  if ($sample_rate == 1)
  { &WriteReportPerCountryBreakdown ($title, $views_edits, &UnLink ($links,$offset_links+2),$cutoff_requests = 10000, $cutoff_percentage = 0.1, $show_logcount = $false, $sample_rate) ; }
  else
  {
    &WriteReportPerCountryBreakdown ($title, $views_edits, &UnLink ($links,$offset_links+2),$cutoff_requests = 100, $cutoff_percentage =   1, $show_logcount = $false, $sample_rate) ;
    &WriteReportPerCountryBreakdown ($title, $views_edits, &UnLink ($links,$offset_links+2),$cutoff_requests =  10, $cutoff_percentage = 0.1, $show_logcount = $true,  $sample_rate) ;
  }

# $title = "$title_main - Wikipedia <font color=#008000>$views_edits Per Country</font> - Trends" ; # deprecated, too unreliable
# &WriteReportPerCountryTrends ($title, $views_edits, &UnLink ($links,$offset_links+3)) ;

# $links =~ s/,.*$// ;
  $title = "$title_main - <font color=#008000>$views_edits Per Wikipedia Language</font> - Breakdown" ;
  &WriteReportPerLanguageBreakDown ($title, $views_edits, &UnLink ($links,$offset_links+4)) ;
}

sub ReadDate
{
  &LogSub ("ReadDate\n") ;

  &LogDetail ("Read from $path_process/$file_csv_crawlers") ;

  open  CSV_CRAWLERS, '<', "$path_process/$file_csv_crawlers" ;
  $line = <CSV_CRAWLERS> ;
  close CSV_CRAWLERS ;
# print "DATE LINE $line\n" ;
  chomp ($line) ;
  $line =~ s/^.*?(\d\d\d\d\-\d\d\-\d\d(?:T\d\d)?).*?(\d\d\d\d\-\d\d\-\d\d(?:T\d\d)?).*$/$1.",".$2/e ;
  ($timefrom,$timetill) = split (',', $line) ;
  if (($timefrom eq "") || ($timetill eq ""))
  { abort ("$file_csv_crawlers does not contain valid date range on first line\n") ; }

  $yearfrom  = substr ($timefrom,0,4) ;
  $monthfrom = substr ($timefrom,5,2) ;
  $dayfrom   = substr ($timefrom,8,2) ;
  $hourfrom  = substr ($timefrom,11,2) ;

  $yeartill  = substr ($timetill,0,4) ;
  $monthtill = substr ($timetill,5,2) ;
  $daytill   = substr ($timetill,8,2) ;
  $hourtill  = substr ($timetill,11,2) ;

  $period = sprintf ("%d %s %d %d:00 - %d %s %d %d:00", $dayfrom, month_english_short ($monthfrom-1), $yearfrom, $hourfrom, $daytill, month_english_short ($monthtill-1), $yeartill, $hourtill) ;

  $timefrom  = timegm (0,0,$hourfrom,$dayfrom,$monthfrom-1,$yearfrom-1900) ;
  $timetill  = timegm (0,0,$hourtill,$daytill,$monthtill-1,$yeartill-1900) ;

  $timespan   = ($timetill - $timefrom) / 3600 ;
  $multiplier = (24 * 3600) / ($timetill - $timefrom) ;
  &LogDetail ("Multiplier = $multiplier\n") ;
  $header =~ s/DATE/Monthly requests or daily averages, for period: $period (yyyy-mm-dd)/ ;
# $header =~ s/DATE/Monthly requests or daily averages, for period: $period (yyyy-mm-dd) <a href='$link_html_per_country_overview_prev'>prev<\/a>\/<a href='$link_html_per_country_overview_next'>next<\/a>/ ;
  $headerwithperc =~ s/DATE/Monthly requests or daily averages, for period: $period (yyyy-mm-dd)/ ;
# $headerwithperc =~ s/DATE/Monthly requests or daily averages, for period: $period (yyyy-mm-dd)  <a href='$link_html_per_country_overview_prev'>prev<\/a>\/<a href='$link_html_per_country_overview_next'>next<\/a>/ ;
  $link_html_per_country_overview_prev = "SquidReport${selection}PerCountryOverview${yyyy}Q$q.htm" ;
}

sub SetPeriod
{
  &LogSub ("SetPeriod\n") ;

  $year_first  = substr ($date_first,0,4) ;
  $month_first = substr ($date_first,5,2) ;
  $day_first   = substr ($date_first,8,2) ;

  $year_last   = substr ($date_last,0,4) ;
  $month_last  = substr ($date_last,5,2) ;
  $day_last    = substr ($date_last,8,2) ;

  print "date_first $date_first, date_last $date_last\n" ;
  
  if ($day_first eq '')
  { $day_first = 1 ; }
  if ($day_last eq '')
  { $day_last = &DaysInMonth ($year_last, $month_last) ; }

  $timefrom  = timegm (0,0,0,$day_first,$month_first-1,$year_first-1900) ;
  $timetill  = timegm (0,0,0,$day_last,$month_last-1,$year_last-1900) + 86400 ; # date_last + 1 day (in seconds)

  $timespan   = ($timetill - $timefrom) / 3600 ;
  $multiplier = (24 * 3600) / ($timetill - $timefrom) ;

  $period = sprintf ("%d %s %d - %d %s %d", $day_first, month_english_short ($month_first-1), $year_first, $day_last, month_english_short ($month_last-1), $year_last) ;
  if ($quarter_only ne '')
  { $period .= " ($quarter_only) " ; }
# else
# { $period .= " (last 12 months) " ; }

  $header =~ s/DATE/Monthly requests or daily averages, for period: $period/ ;
# $header =~ s/DATE/Monthly requests or daily averages, for period: $period <a href='$link_html_per_country_overview_prev'>prev<\/a>\/<a href='$link_html_per_country_overview_next'>next<\/a>/ ;
  $headerwithperc =~ s/DATE/Monthly requests or daily averages, for period: $period/ ;
# $headerwithperc =~ s/DATE/Monthly requests or daily averages, for period: $period <a href='$link_html_per_country_overview_prev'>prev<\/a>\/<a href     ='$link_html_per_country_overview_next'>next<\/a>/ ;

  &LogDetail ("Sample period: $period => for daily averages multiplier = " . sprintf ("%.2f",$multiplier) . "\n\n") ;
}

sub PrepHtml
{
  my ($reports_set,$sample_rate) = @_ ;

  &LogSub ("PrepHtml\n\n") ;

  $language = "en" ;
  $header = &HtmlHead ;
  $headerwithperc = $header ;
  $header =~ s/SHOWPERC// ;
  $headerwithperc =~ s/SHOWPERC/var element = document.getElementById ('form_show_perc');\n  if (element.checked)\n  { setCookie ('show_perc', 'true') ; }\n  else\n  { setCookie ('show_perc', 'false') ; }/ ;

  $form   = &HtmlForm ;
  $formwithperc = &HtmlFormWithPerc ;

  if ($sample_rate == 1)
  { $header_sample_rate = "1:1 unsampled" ; }
  else
  { $header_sample_rate = "1:$sample_rate sampled" ; }

  $run_time = "<font color=#888877>" . date_time_english (time) . " UTC</font> " ;

  $header.=  "\n<body bgcolor='\#FFFFFF'>\n$form\n<hr>" .
          # "&nbsp;This analysis is based on a 1:1000 sampled server log (squids) X1000\nALSO<br>" ; # X1000 obsolete (may become a toggle ?)
          # "$run_time&nbsp;This analysis is based on a $header_sample_rate server log (squids)<p>\nALSO<p>&nbsp;<a href='#errata'>Notes on reliability of these data<\/a><br><br>NOTICE" ;
            "$run_time<p>\nALSO<p>NOTICE" ;

  $headerwithperc.=  "/n<body bgcolor='\#FFFFFF'>\n$formwithperc\n<hr>" .
          # "&nbsp;This analysis is based on a 1:1000 sampled server log (squids) X1000\nALSO<br>" ; # X1000 obsolete (may become a toggle ?)
          # "$run_time&nbsp;This analysis is based on a $header_sample_rate server log (squids)<p>\nALSO<p>&nbsp;<a href='#errata'>Notes on reliability of these data<\/a><br><br>" ;
            "$run_time<p>\nALSO<br><br>" ;

  if ($set_reports eq 'country_reports')
  {
    $errata .= "<p><p>&nbsp;<font color=#900000>WMF traffic logging service suffered from server capacity problems from Nov 2009 till July 2010 and again in Aug/Sep/Oct 2011.<br>" .
               "&nbsp;Data loss only occurred during peak hours. It therefore may have had somewhat different impact for traffic from different parts of the world." ;
  }
  else
  {
    $errata .= "<font color=#900000>WMF traffic logging service suffered from server capacity problems in Aug/Sep/Oct 2011.<br>" .
               "Absolute traffic counts for October 2011 are approximatly 7% too low.<br>" .
               "Data loss only occurred during peak hours. It therefore may have had somewhat different impact for traffic from different parts of the world.<br>" .
               "and may have also skewed relative figures like share of traffic per browser or operating system.</font><p>" ;
    $errata .= "<font color=#900000>From mid September till late November squid log records for mobile traffic were in invalid format.<br>" .
               "Data could be repaired for logs from mid October onwards. Older logs were no longer available.</font><p>" ;
    $errata .= "<font color=#900000>In a an unrelated server outage precisely half of traffic to WMF mobile sites was not counted from Oct 16 - Nov 29 (one of two load-balanced servers did not report traffic).<br>" .
               "WMF has since improved server monitoring, so that similar outages should be detected and fixed much faster from now on.</font><p>" ;
  }

  if ($reports_set eq $reports_set_countries)
  {
  # $notice = "<p><font color=red>" .
  #           "&nbsp;Unresolved Bugzilla bugs: " .
  #           "<a href='https://bugzilla.wikimedia.org/show_bug.cgi?id=55443'>55443</a>" .
  #           "</font><p><font color=green>" .
  #            "Recently resolved bugs: " .
  #           "<a href='https://bugzilla.wikimedia.org/show_bug.cgi?id=46205'>46205</a> (Aug 2013)" .
  #           "<a href='https://bugzilla.wikimedia.org/show_bug.cgi?id=46289'>46289</a> (Nov 2013)" .
  #           "</font><p>" ;
  }
  $header =~ s/NOTICE/$notice/ ;

  # to be localized some day like any reports
  $out_explorer     = "<font color=#800000>Note: page may load slower on Microsoft Internet explorer than on other major browsers</font>" ;
  $out_license      = "All data and images on this page are in the public domain." ;
  $out_generated    = "Generated on " ;
  $out_author       = "Author" ;
  $out_mail         = "Mail" ;
  $out_site         = "Web site" ;

  $out_myname_ez = "Erik Zachte" ;
  $out_mymail_ez = "ezachte\@### (no spam: ### = wikimedia.org)" ;
  $out_mysite_ez = "//infodisiac.com/" ;

  $colophon_ez = "<p><a id='errata' name='errata'><b>Errata:</b> $errata<p>\n" .
               $out_generated . date_time_english (time) . "\n<br>" .
               $out_author . ":" . $out_myname_ez . ' ' .
               " (<a href='" . $out_mysite_ez . "'>" . $out_site . "</a>)<br>" .
               "$out_mail: $out_mymail_ez<br>\n" .
               "$out_license<p>" .
               "$out_explorer" .
               "</small>\n" .
               "</body>\n" .
               "</html>\n" ;


  $errata = 'No data loss or anomalies reported' ; 

  $dummy_countries   = "<font color=#000060>Country data</font>" ;
  $dummy_countries              = "<font color=#000060>Countries</font>" ;

  $link_countries   = "<a href='$file_html_countries_info'>Country data</a>" ;
  $link_countries_overview = "<a href='SquidReportPageViewsPerCountryOverview.htm'>Overview</a>" ;
  $link_countries_projects = "<a href='SquidReportPageViewsPerCountryBreakdown.htm'>Projects</a>" ;
  $link_countries_trends = "<a href='//stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryTrends.htm'>Trends</a>" ;
  $link_trends_countries = "<a href='//stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryTrends.htm'>Countries</a>" ;
}

sub ReadCountryCodes
{
  &LogSub ("ReadCountryCodes\n") ;

  open CODES, '<', "$path_meta/$file_csv_country_codes" ;
  while ($line = <CODES>)
  {
    if ($line =~ /^[A-Z]/)
    {
      chomp ($line) ;
      ($code,$name) = split (',',$line,2) ;
      $country_codes {$code} = unicode_to_html ($name) ;
      # print "$code => $name\n" ;
    }
  }
  $country_codes {'-'}  = 'Unknown3' ;
  $country_codes {'--'} = 'Unknown4' ;
  $country_codes {'XX'} = 'Unknown5' ;
  $country_codes {'-P'} = 'IPv6' ;
  $country_codes {'-X'} = 'Unknown6' ;
  $country_codes {'AN'} = 'Netherlands Antilles' ; # not yet in MaxMind database
  close CODES ;
}

sub ReadCountryCodes_3166_1_alpha_3
{
  &LogSub ("ReadCountryCodes_3166_1_alpha_3\n") ;
  
  open CODES, '<', "$path_meta/CountryCodes_3166-1_alpha-3.csv" ;
  while ($line = <CODES>)
  {
    if ($line =~ /^[A-Z]/)
    {
      chomp ($line) ;
      ($code,$name) = split (',',$line,2) ;
      $name =~ s/"//g ;
      $country_codes_3166_1_alpha_3 {$code} = $name ;
      $country_names_3166_1_alpha_3 {$name} = $code ;
    # print "$code => $name\n" ;
    }
  }
  close CODES ;
}

sub AddExtraCountryNames_3166_1_alpha_3
{ 
# add entries for country names spelled differently in $file_csv_country_codes 
  $country_names_3166_1_alpha_3 {'Bolivia'}                 = 'BOL' ;
  $country_names_3166_1_alpha_3 {'Brunei'}                  = 'BRN' ;
  $country_names_3166_1_alpha_3 {'Burma'}                   = 'MMR' ;
  $country_names_3166_1_alpha_3 {'Cape Verde'}              = 'CPV' ;
  $country_names_3166_1_alpha_3 {'Caribbean Netherlands'}   = 'XXX' ;
  $country_names_3166_1_alpha_3 {'Congo Dem. Rep.'}         = 'COD' ;
  $country_names_3166_1_alpha_3 {'Congo Rep.'}              = 'COG' ;
  $country_names_3166_1_alpha_3 {"Cote d'Ivoire"}           = 'CIV' ;
  $country_names_3166_1_alpha_3 {'Falkland Islands'}        = 'FLK' ;
  $country_names_3166_1_alpha_3 {'Iran'}                    = 'IRN' ;
  $country_names_3166_1_alpha_3 {'Laos'}                    = 'LAO' ;
  $country_names_3166_1_alpha_3 {'Macedonia'}               = 'MKD' ;
  $country_names_3166_1_alpha_3 {'Micronesia'}              = 'FSM' ;
  $country_names_3166_1_alpha_3 {'Moldova'}                 = 'MDA' ;
  $country_names_3166_1_alpha_3 {'Palestinian Territories'} = 'PSE' ;
  $country_names_3166_1_alpha_3 {'Russia'}                  = 'RUS' ;
  $country_names_3166_1_alpha_3 {'Sint Maarten'}            = 'SXM' ;
  $country_names_3166_1_alpha_3 {'South Korea'}             = 'KOR' ;
  $country_names_3166_1_alpha_3 {'Syria'}                   = 'SYR' ;
  $country_names_3166_1_alpha_3 {'São Tomé and Príncipe'}   = 'STP' ;
  $country_names_3166_1_alpha_3 {'Taiwan'}                  = 'TWN' ;
  $country_names_3166_1_alpha_3 {'Tanzania'}                = 'TZA' ;
  $country_names_3166_1_alpha_3 {'United States'}           = 'USA' ;
  $country_names_3166_1_alpha_3 {'Vatican City'}            = 'VAT' ;
  $country_names_3166_1_alpha_3 {'Venezuela'}               = 'VEN' ;
  $country_names_3166_1_alpha_3 {'Vietnam'}                 = 'VNM' ;
  $country_names_3166_1_alpha_3 {'Virgin Islands, UK'}      = 'VGB' ;
  $country_names_3166_1_alpha_3 {'Virgin Islands, US'}      = 'VIR' ;
}

sub ReadInputCountriesTimed
{
  &LogSub ("ReadInputCountriesTimed\n") ;

  my $file_csv = "$path_process/public/$file_csv_countries_timed" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputCountriesTimed: file $file_csv not found!!! ") ; }
  open CSV_COUNTRIES, '<', $file_csv ;
  while ($line = <CSV_COUNTRIES>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp $line ;
    ($bot,$target,$country,$time,$count) = split (',', $line) ;

    next if $target !~ /^wp/ ; # wikipedia only

    if ($bot =~ /Y/)
    { $bot = 'Y' }
    else
    { $bot = 'N' }
    $countries {$country} ++ ;
    $targets   {$target} ++ ;
    $times     {$time} ++ ;
    $countries_timed  {"$bot,$target,$country,$time"} += $count ;
    $countries_totals {"$bot,$target"}{$country} += $count ;
    $targets_totals   {"$bot,$country"}{$target} += $count ;
  }
  close CSV_COUNTRIES ;
}

sub ReadInputRegionCodes
{
  &LogSub ("ReadInputRegionCodes\n") ;

  $file_csv_region_codes = "RegionCodes.csv" ;
  $path_csv_region_codes = "$path_meta/$file_csv_region_codes" ;
  if (! -e $path_csv_region_codes) { abort ("Input file $path_csv_region_codes not found!") ; }

  open    CSV_REGION_CODES, '<', $path_csv_region_codes ;

  binmode CSV_REGION_CODES ;
  while ($line = <CSV_REGION_CODES>)
  {
    chomp $line ;
    ($country_code,$region_code,$north_south_code) = split (',', $line) ;
    $region_codes      {$country_code} = $region_code ;
    $north_south_codes {$country_code} = $north_south_code ;
  }

  close CSV_REGION_CODES ;
}

sub ReadInputCountriesNames
{
  &LogSub ("ReadInputCountriesNames\n") ;

  $file_csv_country_codes = "CountryCodes.csv" ;
  $path_csv_country_codes = "$path_meta/$file_csv_country_codes" ;
  if (! -e $path_csv_country_codes) { abort ("Input file $path_csv_country_codes not found!") ; }

  open    CSV_COUNTRY_CODES, '<', $path_csv_country_codes ;

  binmode CSV_COUNTRY_CODES ;

  $country_names {'-'}  = 'Unknown7' ;
  $country_names {'--'} = 'Unknown8' ;
  $country_names {'-P'} = 'IPv6' ;
  $country_names {'-X'} = 'Unknown9' ;
  $country_names {'AN'} = 'Netherlands Antilles' ; # not yet in MaxMind database
  $country_names {"XX"} = "Unknown10" ;

  while ($line = <CSV_COUNTRY_CODES>)
  {
    chomp $line ;

    next if $line =~ /^#/ ;

    $line =~ s/\"//g ;

    $line =~ s/[\x00-\x1f]//g ;
    $line =~ s/UNDEFINED/Undefined/g ;
    $line =~ s/territories/Territories/ ;
    $line =~ s/(Falkland Islands).*$/$1/g ; # - (Malvinas)
    $line =~ s/Reunion/Réunion/ ;
    $line =~ s/Aland Islands/Åland Islands/ ;
    $line =~ s/Bonaire, Saint Eustatius and Saba/Caribbean Netherlands/ ;
    $line =~ s/Congo, The Democratic Republic of the/Congo Dem. Rep./ ;
    $line =~ s/Congo$/Congo Rep./ ;
    $line =~ s/Curacao/Curaçao/ ;
    $line =~ s/Brunei Darussalam/Brunei/ ;
    $line =~ s/Holy See.*$/Vatican City/ ;
    $line =~ s/Iran, Islamic Republic of/Iran/ ;
    $line =~ s/Korea, Democratic People's Republic of/North Korea/ ;
    $line =~ s/Korea, Republic of/South Korea/ ;
    $line =~ s/Lao People's Democratic Republic/Laos/ ;
    $line =~ s/Libyan Arab Jamahiriya/Libya/ ;
    $line =~ s/Micronesia, Federated States of/Micronesia/ ;
    $line =~ s/Moldova, Republic of/Moldova/ ;
    $line =~ s/Myanmar/Burma/ ;
    $line =~ s/Palestinian Territory/Palestinian Territories/ ;
    $line =~ s/Pitcairn/Pitcairn Islands/ ;
    $line =~ s/Russian Federation/Russia/ ;
    $line =~ s/American American Samoa/American Samoa/ ;
    $line =~ s/Saint Bartelemey/Saint Barthélemy/ ;
    $line =~ s/Sao Tome and Principe/São Tomé and Príncipe/ ;
    $line =~ s/Syrian Arab Republic/Syria/ ;
    $line =~ s/Tanzania, United Republic of/Tanzania/ ;
    $line =~ s/Virgin Islands, British/Virgin Islands, UK/ ;
    $line =~ s/Virgin Islands, U.S./Virgin Islands, US/ ;

    # ($country_code,$region_code,$north_south_code,$country_name) = split (',', $line,4) ;
    ($country_code,$country_name) = split (',', $line,2) ;

    $country_name =~ s/"//g ;

    # next if $country_name eq "Anonymous Proxy" ;
    # next if $country_name eq "Satellite Provider" ;
    # next if $country_name eq "Other Country" ;
    # next if $country_name eq "Asia/Pacific Region" ;
    # next if $country_name eq "Europe" ;

#    if ($country_meta_info {$country}  eq "")
#    {
#      if ($country_meta_info_not_found_reported {$country} ++ == 0)
#      { print "Meta info not found for country '$country'\n" ; }
#    }

    $country_names_found {$country_name} ++ ;
    $country_names       {$country_code} = $country_name ;
    $country_codes_all   {"$country_name|$country_code"} ++ ;
  }

  close CSV_COUNTRY_CODES ;
}

sub ReadInputCountriesMeta
{
  &LogSub ("ReadInputCountriesMeta\n") ;

  # http://en.wikipedia.org/wiki/List_of_countries_by_population
  # http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users
  &LogDetail ("Read $path_meta/$file_csv_country_meta_info\n") ;
  open    COUNTRY_META_INFO, '<', "$path_meta/$file_csv_country_meta_info" ;
  binmode COUNTRY_META_INFO ;
  while ($line = <COUNTRY_META_INFO>)
  {
    chomp $line ;
    $line =~ s/[\x00-\x1f]//g ;

    ($country,$link,$population,$connected,$icon) = split ',', $line ;
    $icon =~ s/\"\/\/upload/\"\/\/upload/g ;
    $icon =~ s/data\-file\-width=\"\d+\"//g ;
    $icon =~ s/data\-file\-height=\"\d+\"//g ;  
    $icon =~ s/\s*>/>/g ;

    # print "COUNTRY $country\nLINK $link\nPOPULATION $population\nCONNECTED $connected\n\n" ;
    $country =~ s/&comma;/,/g ;

    $country =~ s/territories/Territories/ ;
    $country =~ s/American American Samoa/American Samoa/ ;
    $country =~ s/C..?te d'Ivoire/Cote d'Ivoire/g ;
    $country =~ s/Democratic Republic of the Congo/Congo Dem. Rep./ ;
    $country =~ s/^Republic of the Congo/Congo Rep./ ;
    $country =~ s/East timor/Timor-Leste/ ;
    $country =~ s/Guyane/French Guiana/ ;
    $country =~ s/Ivory Coast/Cote d'Ivoire/ ;
    $country =~ s/^.*Micronesia/Micronesia/ ; # - Federated States of
    $country =~ s/Macau/Macao/ ;
    $country =~ s/Saint Helena.*$/Saint Helena/ ;  # - , Ascension and Tristan da Cunha
    $country =~ s/United States Virgin Islands/Virgin Islands, US/ ;
    $country =~ s/British Virgin Islands/Virgin Islands, UK/ ;

    if ($connected eq 'connected')
    { $ip_connections_unknown .= "$country, " ; }

    $connected =~ s/connected/../g ;

    $country_meta_info {$country} = "$link,$population,$connected,$icon" ;
    if ($country eq "United States")
    { ($connected_us = $connected) =~ s/_//g  ; }
  }

  close COUNTRY_META_INFO ;

  if ($ip_connections_unknown ne '')
  {
    $ip_connections_unknown =~ s/, $// ;
    &LogDetail ("IP connections unknown for:\n$ip_connections_unknown\n\n") ;
  }

  &ValidateCountryNames ;
}

sub ValidateCountryNames
{
  &LogSub ("ValidateCountryNames\n") ;

  &LogDetail ("Compare country names in two hash arrays:\n\n") ;
  &LogDetail ("Countries in \%country_names_found not found in \%country_meta_info:\n\n") ;

  &LogBreak ;
  foreach $country (sort keys %country_names_found)
  {
    if ($country_meta_info {$country} eq '')
    { &LogList ("$country\n") ; }
  }
  &LogBreak ;

  &LogDetail ("Countries in \%country_meta_info not found in \%country_names_found:\n\n") ;
  &LogBreak ;
  foreach $country (sort keys %country_meta_info)
  {
    if ($country_names_found {$country} eq '')
    { &LogList ("$country\n") ; }
  }
  &LogBreak ;
}

sub CollectRegionCounts
{
  &LogSub ("CollectRegionCounts\n") ;

  my ($country_code, $region_code, $north_south_code, $country_name) ;
  foreach $country_code (keys %country_names)
  {
    $country_name = $country_names {$country_code} ;
    $country_meta = $country_meta_info {$country_name} ;

    my ($link,$population,$connected,$icon) = split (',', $country_meta) ;

  # debug only:
  # &LogList ("code $country_code\n") ;
  # &LogList ("name $country_name\n") ;
  # &LogList ("meta $country_meta\n") ;

    $region_code      = $region_codes      {$country_code} ;
    $north_south_code = $north_south_codes {$country_code} ;

    $population =~ s/_//g ;
    $connected  =~ s/_//g ;

    $population_tot += $population ;
    $connected_tot  += $connected ;

    $population_per_region {$region_code}      += $population ;
    $connected_per_region  {$region_code}      += $connected ;

    $population_per_region {$north_south_code} += $population ;
    $connected_per_region  {$north_south_code} += $connected ;

    # print "CODE $country_code NAME $country_name POP $population, $CONN $connected REGION $region_code NS $north_south_code PPR ${population_per_region {$region_code}}\n" ;
  }

  if ($population_tot == 0)
  { abort ("No valid data found: population_tot = 0 !") ; }
}

sub ReadInputCountriesMonthly
{
  &LogSub ("ReadInputCountriesMonthly\n") ;

  my $project_mode = shift ;

  undef %yyyymm_ ;
  undef %quarters ;
  undef %requests_unknown_per_quarter ;
# undef %country_codes ;
  undef %requests_all ;
  undef %requests_all_per_period ;
  undef %requests_per_quarter ;
  undef %requests_per_country ;
  undef %requests_per_quarter_per_country ;
  undef %requests_per_country_per_language ;
  undef %requests_per_language_per_country ;
  undef %requests_per_quarter_per_country_per_language ;
  undef %requests_per_month_per_country_code ;
  undef %requests_per_month_us ;
  undef %descriptions_per_period ;
  undef %requests_recently_all ;
  undef %requests_recently_per_country_code ;
  undef %requests_recently_per_country ;
  undef %requests_recently_per_country_per_language ;
  undef %requests_recently_per_language_per_country ;
  undef %requests_recently_per_language ;
  undef %months_recently ;

  $requests_recently_start = "999999" ;
  $requests_recently_stop  = "000000" ;
  $requests_start          = "999999" ;
  $requests_stop           = "000000" ;

  $requests_all            = 0 ;
  $requests_recently_all   = 0 ;

  # global reportmonth and local report_month is a bit confusing, to be fixed
  if ($reportmonth ne '')
  {
    &LogDetail ("Month $reportmonth specified as cmd line argument\n") ;
    $report_year  = substr ($reportmonth,0,4) ;	  
    $report_month = substr ($reportmonth,5,2) ;	  
  }
  else
  {
    my ($sec,$min,$hour,$day,$report_month,$report_year) = localtime (time) ;
    $report_year  += 1900 ;
  # $report_month ++ ;
    if ($report_month == 0) # EZ 10/2012 report till end of last month
    {
      $report_month = 12 ;
      $report_year-- ;
    }
  }   

  &LogDetail ("Read monthly data (year $report_year, month $report_month) for project $project_mode (wp=Wikipedia, etc) from $path_csv_squid_counts_monthly\n") ;

  $date_first = '9999-99' ;
  $date_last  = '0000-00' ;

  $invalid_country_codes = 0 ;
  $discarded_input = 0 ;

  my $lines = 0 ;
  &LogBreak ;
  &Log ("read from '$path_csv_squid_counts_monthly'\n") ;

  open CSV_SQUID_COUNTS_MONTHLY, '<', $path_csv_squid_counts_monthly ;
  while ($line = <CSV_SQUID_COUNTS_MONTHLY>)
  {
    $lines++ ;
    if ($lines % 100000 == 0)
    { &LogList ("lines: $lines\n") ; }

    chomp $line ;
    $line =~ s/,\s+/,/g ;
    $line =~ s/\s+,/,/g ;
    ($yyyymm,$project,$language,$code,$bot,$count) = split (',', $line) ;

    ($code,$language) = &NormalizeSquidInput ($code,$language) ;

    $country = &GetCountryName ($code) ;
    next if $country =~ /invalid/i ; # frequent parsing error in earlier years

    # next if $country =~ /\?/ ;
    next if &DiscardSquidInput ($bot,$project,$project_mode,$code,$language) ;

  #  $yyyymm = "2009-12" ;
    $yyyymm_ {$yyyymm} ++ ;

    $year    = substr ($yyyymm,0,4) ;
    $month   = substr ($yyyymm,5,2) ;

    $recently = $false ;

       if ($month <= 3) { $quarter = $year . ' Q1' ; }
    elsif ($month <= 6) { $quarter = $year . ' Q2' ; }
    elsif ($month <= 9) { $quarter = $year . ' Q3' ; }
    else                { $quarter = $year . ' Q4' ; }

    if ($quarter_only ne '')
    {
      next if $quarter ne $quarter_only ;
      $recently = $true ;
      $recently_desc = $quarter_only ;
    }
    else
    {
    # Dec 2013: no quarterly report used to be avg monthly counts for last full 12 months, now it is data for one month 	    
    # if ((($year == $report_year) && ($month <= $report_month)) or # EZ 10/2012, skip current month
    #     (($year == $report_year - 1) && ($month > $report_month)))
      if (($year == $report_year) && ($month == $report_month))
      { 
        $recently = $true ; 
        $recently_desc = "$year-$month" ;
      }
      else
      { next ; }
      # if ($lines % 1000 == 0) # debug only
      # {  print "year $year, month $month, report_year $report_year, report_month $report_month\n" ; }	    
    }
    $lines_selected ++ ;

    # if ($views_edits eq 'Page Edits')

    $quarters {$quarter} ++ ;

# parse country data # qqq 

    if (($country =~ /\?/) || ($country =~ /unknown/i))
    { $requests_unknown_per_quarter {$quarter} += $count ; }
    $country_codes {"$country|$code"}++ ;
    $requests_all                                                                     += $count ;
    $requests_all_per_period                       {$yyyymm}                          += $count ;
    $requests_per_quarter                          {$quarter}                         += $count ;
    $requests_per_country                                     {$country}              += $count ;

    $requests_per_quarter_per_country              {$quarter} {$country}              += $count ;
    $requests_per_country_per_language                        {$country}  {$language} += $count ;
    $requests_per_language_per_country                        {$language} {$country}  += $count ;
    $requests_per_quarter_per_country_per_language {$quarter} {$country}  {$language} += $count ;
    $requests_per_month_per_country_code           {$yyyymm}  {"$country|$code"}      += $count ;

    if ($code eq "US")
    {$requests_per_month_us                        {$yyyymm}                          += $count ; }

    $descriptions_per_period {$yyyymm} = $yyyymm ;
    if ($yyyymm lt $requests_start) { $requests_start = $yyyymm ; }
    if ($yyyymm gt $requests_stop)  { $requests_stop  = $yyyymm ; }

    if ($yyyymm lt $date_first)
    { $date_first = $yyyymm ; }
    if ($yyyymm gt $date_last)
    { $date_last = $yyyymm ; }

    if ($recently)
    {
      if ($yyyymm lt $requests_recently_start) { $requests_recently_start = $yyyymm ; }
      if ($yyyymm gt $requests_recently_stop)  { $requests_recently_stop  = $yyyymm ; }

      $months_recently {$yyyymm}++ ;
      $requests_recently_all                                                         += $count ;
      $requests_recently_per_country_code                    {"$country|$code"}      += $count ;
      $requests_recently_per_country                         {$country}              += $count ;
      $requests_recently_per_country_per_language            {$country}  {$language} += $count ;
      $requests_recently_per_language_per_country            {$language} {$country}  += $count ;
      $requests_recently_per_language                        {$language}             += $count ;
    }
  }

  if ($lines_selected == 0)
  { abort ("No lines selected from $path_csv_squid_counts_monthly.\nRun step 'collect_country_stats' to add data for requested month.") ; }

  if ($lines > 0)
  {
    $perc_invalid_country_codes = sprintf ("%.1f", 100 * $invalid_country_codes / $lines) ;
    $perc_discarded_input       = sprintf ("%.1f", 100 * $discarded_input / $lines) ;
  }
  &LogList ("lines: $lines invalid country codes: $invalid_country_codes ($perc_invalid_country_codes\%), discard input: $discarded_input ($perc_discarded_input\%)\n") ;


  &LogList ("Top 10 most found invalid country codes:\n") ;
  &LogBreak () ;
  $codes_reported = 0 ;
  foreach $code (sort {$country_code_not_specified_reported {$b} <=> $country_code_not_specified_reported {$a}} keys %country_code_not_specified_reported)
  {
    &LogList ("Code $code: ${country_code_not_specified_reported {$code}}\n") ;
    last if $codes_reported++ == 10 ;
  }
  &LogBreak () ;
  &LogDetail ((0 + $lines) . " lines read from '$path_csv_squid_counts_monthly'\n") ;

  if ($lines == 0)
  { abort ("No lines read from '$path_csv_squid_counts_monthly'\n") ; }

  @quarters = keys_sorted_alpha_asc %quarters ;
  &LogBreak ;
  foreach $quarter (@quarters)
  {
    my $quarter2 = substr ($quarter,0,4) . 'q' . substr ($quarter,4,1) ;
    &LogList ("quarter $quarter: requests: " . (0+$requests_per_quarter {$quarter}) . "\n") ;

    if ($requests_per_quarter {$quarter} == 0)
    { abort ("No known requests found for quarter $quarter") ; }
  }
  &LogBreak ;

  $months_recently = keys %months_recently ;

  $requests_recently_start = substr ($requests_recently_start,0,4) . '/' . substr ($requests_recently_start,5,2);
  $requests_recently_stop  = substr ($requests_recently_stop ,0,4) . '/' . substr ($requests_recently_stop ,5,2) ;
  $requests_start          = substr ($requests_start,0,4)          . '/' . substr ($requests_start,5,2) ;
  $requests_stop           = substr ($requests_stop ,0,4)          . '/' . substr ($requests_stop ,5,2) ;

  foreach $yyyymm (keys %$yyyymm)
  {
    if ($requests_per_month_us {$week} > $max_requests_per_month_us)
    { $max_requests_per_month_us = $requests_per_month_us {$week} ; }
  }

  if ($connected_us > 0)
  { $max_requests_per_connected_us_month = sprintf ("%.1f", $max_requests_per_month_us / $connected_us) ; }
}

sub ReadInputCountriesDaily
{
  &LogSub ("ReadInputCountriesDaily\n") ;

  # http://en.wikipedia.org/wiki/List_of_countries_by_population
  # http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users

  my $project_mode = shift ;

  undef %country_codes_found ;
  undef %weeknum_this_years ;
  undef %descriptions_per_period ;
  undef %days_in_input_for_week ;
  undef %requests_all_per_period ;
  undef %requests_per_week_per_country_code ;
  undef %requests_per_week_us ;
  undef %missing_days ;
  undef %correct_for_missing_days ;
  undef %changes_per_week_per_country_code ;

# $requests_recently_start = "999999" ;
# $requests_recently_stop  = "000000" ;

# $time_2000_01_01 = timegm(0,0,0,1,1-1,2000-1900) ;
  $sec_per_day = 24 * 60 * 60 ;

  my ($sec,$min,$hour,$day,$report_month,$report_year) = localtime (time) ;
  $report_year  += 1900 ;
  $report_month ++ ;

  &LogDetail ("Read daily data for project mode $project_mode from $path_csv_squid_counts_daily\n") ;

  $yyyymmdd_prev = "" ;
  open CSV_SQUID_COUNTS_DAILY, '<', $path_csv_squid_counts_daily ;

  $invalid_country_codes = 0 ;
  $discarded_input = 0 ;

  my $lines = 0 ;
  while ($line = <CSV_SQUID_COUNTS_DAILY>)
  {
    $lines++ ;
    if ($lines % 100000 == 0)
    { &LogList ("lines: $lines\n") ; }

    chomp $line ;
    ($yyyymmdd,$project,$language,$code,$bot,$count) = split (',', $line) ;

    abort ("\$yyyymmdd $yyyymmdd lt \$yyyymmdd_prev $yyyymmdd_prev") if $yyyymmdd lt $yyyymmdd_prev ;
    $yyyymmdd_prev = $yyyymmdd ;

    ($code,$language) = &NormalizeSquidInput ($code,$language) ;
    $country = &GetCountryName ($code) ;
    next if $country =~ /invalid/i ; # frequent parsing error in earlier years
  # next if $country =~ /\?/ ;

    $country_codes_found {"$country|$code"} ++ ;

    next if &DiscardSquidInput ($bot,$project,$project_mode,$code,$language) ;

  # $yyyymmdd = "2009-12-01" ;
    $yyyymmdd_ {$yyyymmdd} ++ ;

    $year    = substr ($yyyymmdd,0,4) ;
    $month   = substr ($yyyymmdd,5,2) ;
    $day     = substr ($yyyymmdd,8,2) ;
# qqqq
    $time = timegm(0,0,0,$day,$month-1,$year-1900) ;
  # $days_since_2000 = int (($time - $time_2000_01_01) / $sec_per_day) ;
    $days_this_year  = (gmtime $time) [7] ;
    $weeknum_this_year  = int ($days_this_year  / 7) + 1  ;
    $weeknum_since_2000 = $year . 'w' . sprintf ("%02d",$weeknum_this_year) ; # * int ($days_since_2000 / 7) + 1  ;

    $weeknum_this_years {$weeknum_since_2000}++ ;

    $descriptions_per_period {$weeknum_since_2000} = "week $weeknum_this_year - " . month_english_short ($month-1) . " $year" ;
    $days_in_input_for_week  {$weeknum_since_2000} {$yyyymmdd} ++ ;

    $requests_all_per_period            {$weeknum_since_2000}                    += $count ;
    $requests_per_week_per_country_code {$weeknum_since_2000} {"$country|$code"} += $count ;

    if ($code eq "US")
    {$requests_per_week_us {$weeknum_since_2000}  += $count ; }

    # last if ($weeknum_since_2000 == 501) ; # test
  }
  if ($lines > 0)
  { $perc_invalid_country_codes = sprintf ("%.1f", 100 * $invalid_country_codes / $lines) ; }
  &LogList ("lines: $lines invalid country codes: $invalid_country_codes ($perc_invalid_country_codes\%)\n") ;

  &LogBreak ;
  foreach $week (sort keys %weeknum_this_years)
  { &LogList ("week $week: lines " . $weeknum_this_years {$week} . "\n") ; }
  &LogBreak ;

  foreach $week (sort {$a <=> $b} keys %days_in_input_for_week)
  {
    @keys = keys %{$requests_per_week_per_country_code {$week-1}} ;
    if (@keys == 0)
    {
      # print "skip week $week: no data for previous week available.\n" ;
      next ;
    }

    if ($requests_per_week_us {$week} > $max_requests_per_week_us)
    { $max_requests_per_week_us = $requests_per_week_us {$week} ; }

    $desc= $week_descriptions {$week} ;
    @days = keys %{$days_in_input_for_week {$week}} ;
    $daycount = @days ;
    $missing_days {$week} = 7 - $daycount ;
    $correct_for_missing_days {$week} = 7 / $daycount ;
    # print "Week $week: $desc: $daycount " . (join ' - ', @days) . " ${correct_for_missing_days {$week}}\n" ;
  # foreach $country_code (keys %{$requests_per_week_per_country_code {$week}})

    foreach $country_code (keys %country_codes_all)
    {
      $new = &CorrectForMissingDays ($week  , ${$requests_per_week_per_country_code {$week  }} {$country_code}) ;
      $old = &CorrectForMissingDays ($week-1, ${$requests_per_week_per_country_code {$week-1}} {$country_code}) ;

      if ($old == 0)
      {
        if ($new > 0)
        {
          # print "$country_code: no data for prev week\n" ;
          $changes_per_week_per_country_code {$week} {$country_code} = 100 ;
        }
      }
      else
      {
        $delta = sprintf ("%.1f", 100 * sqrt ($new / $old)) ;
        if ($delta <   0) { $delta =   0 ; }
        if ($delta > 200) { $delta = 200 ; }
        $changes_per_week_per_country_code {$week} {$country_code} = $delta ;
        $country_code =~ s/,/;/g ;
        push @trace, "$country_code, $week, $old, $new, $delta\n" ;
      }

    }
  }
  open TRACE, '>', "svg/SquidReportPageViewsPerCountryTrend.csv" ;
  print TRACE sort @trace ;
  close TRACE ;

  # abort ("\$connected_us == 0") if $connected_us == 0 ;
  if ($connected_us > 0)
  { $max_requests_per_connected_us_week = sprintf ("%.1f", (($max_requests_per_week_us * 1000) / $connected_us)) ; }
}

sub NormalizeSquidInput
{
  # &LogSub ("NormalizeSquidInput\n") ;

  my ($code,$language) = @_ ;

  if ($language eq "jp") { $language = "ja" ; }
  if ($language eq "cz") { $language = "cs" ; }

  # following are part of France, according to Wikipedia, List_of_countries_by_population
  if ($code eq 'BL') { $code = 'FR' ; } # Saint Barthélemy
  if ($code eq 'MF') { $code = 'FR' ; } # Saint Martin
  if ($code eq 'MQ') { $code = 'FR' ; } # Martinique
  if ($code eq 'NC') { $code = 'FR' ; } # New Caledonia
  if ($code eq 'PF') { $code = 'FR' ; } # French Polynesia
  if ($code eq 'PM') { $code = 'FR' ; } # Saint Pierre and Miquelon
  if ($code eq 'WF') { $code = 'FR' ; } # Wallis and Futuna
  if ($code eq 'YT') { $code = 'FR' ; } # Mayotte

  return ($code,$language) ;
}

sub DiscardSquidInput
{
  # &LogSub ("DiscardSquidInput\n") ;

  my ($bot,$project,$project_mode,$code,$language) = @_ ;

  $project =~ s/[^a-z\-\_]//g ; # remove %@ encoding for mobile etc
# print "$bot,$project,$project_mode,$code,$language\n" ;
  if ($bot ne "U"  or # user
      $project ne $project_mode or # eg 'wp'
      $language eq "upload" or
      $language =~ /mobile/i)
   # $code eq "A1" or # Anonymous Proxy
   # $code eq "A2" or # Satellite Provider
   #  $code eq "AP" or # Asia/Pacific Region
   #  $code eq "EU")    # Europe
  {
  # print "bot $bot project '$project' project_mode $project_mode code $code language $language\n" ;
    $discarded_input ++ ;
#if (($project eq 'wp') && ($bot eq 'U')) # debug # qqq
#{
#  print "discard bot $bot, project $project, mode $project_mode, code $code, language $language\n" ;
#}
    return ($true) ;
  }

  return ($false) ;
}

sub GetCountryName
{
  my $code = shift ;
  if ($country_names {$code} eq "")
  {
    if ($code =~ /(?:=|Mozilla)/) # known frequent parsing error in earlier years, do not report
    { return ('country name invalid') ; }

    $country = "Unknown (code $code)" ;
    if ($country_code_not_specified_reported {$code}++ == 0)  
    { &LogList ("country name not specified for $code\n") ; }

    $invalid_country_codes++ ;
  }
  else
  { $country = $country_names {$code} ; }

  return ($country) ;
}

  &LogSub ("CalcPercentages\n") ;

  my $total_opsys           = $total_opsys_mobile           + $total_opsys_non_mobile ;
  my $total_opsys_html_only = $total_opsys_mobile_html_only + $total_opsys_non_mobile_html_only ;
  foreach $key (keys %opsys)
  { $opsys_perc {$key} = sprintf ("%.2f",(100*$opsys {$key}/$total_opsys)) . "%" ; }
  foreach $key (keys %opsys_html_only)
  { $opsys_perc_html_only {$key} = sprintf ("%.2f",(100*$opsys_html_only {$key}/$total_opsys_html_only)) . "%" ; }

  foreach $key (keys %clients)
  { $clients_perc {$key} = sprintf ("%.2f",(100*$clients {$key}/$total_clients)) . "%" ; }
  foreach $key (keys %clients_html_only)
  { $clients_perc_html_only {$key} = sprintf ("%.2f",(100*$clients_html_only {$key}/$total_clients_html_only)) . "%" ; }

  foreach $key (keys %clientgroups)
  {
    $perc           = 100*$clientgroups           {$key}/$total_clients ;
    $perc_html_only = 100*$clientgroups_html_only {$key}/$total_clients_html_only ;
    if ($key =~ /^M/)
    { $perc_threshold = 0.005 ; }
    elsif ($key =~ /^W/ || $key =~ /^P/)
    { $perc_threshold = 0.001 ; }
    else
    { $perc_threshold = 0.02 ; }

    if ($perc > $perc_threshold)
    {
      $precision = ($key =~ /^W/) ? "%.3f" : "%.2f" ;
      $clientgroups_perc           {$key} = sprintf ($precision,$perc)           . "%" ;
      $clientgroups_perc_html_only {$key} = sprintf ($precision,$perc_html_only) . "%" ;
    }
    else
    {
      ($mobile,$group) = split (',', $key) ;

      $clientgroups_other           {$mobile} += $clientgroups           {$key} ;
      $clientgroups_other_html_only {$mobile} += $clientgroups_html_only {$key} ;

      $clientgroups           {$key} = 0 ;
      $clientgroups_html_only {$key} = 0 ;
    }
  }
}

sub WriteCsvCountriesTimed
{
  &LogSub ("WriteCsvCountriesTimed: $path_csv/$file_csv_countries_timed\n") ;

  $multiplier_1000 = 1000 * $multiplier ;
  open CSV_COUNTRIES_TIMED, '>', "$path_csv/$file_csv_countries_timed" ;

  foreach $target (sort keys %targets)
  {
    @countries = sort {$countries_totals {"N,$target"}{$b} <=> $countries_totals {"N,$target"}{$a}} keys %{$countries_totals {"N,$target"}} ;

    foreach $bot ("N","Y")
    {
      $line = "\nBot,Wiki,Time," ;
      $cnt_countries = 0 ;
      foreach $country (@countries)
      {
        $line .= sprintf ("%.0f", $multiplier_1000 * $countries_totals {"$bot,$target"}{$country}) . "," ;

        last if $cnt_countries++ >= 25 ;
      }
      print CSV_COUNTRIES_TIMED "$line\n" ;

      $line = "\nBot,Wiki,Time," ;
      $cnt_countries = 0 ;
      foreach $country (@countries)
      {
        $country_name = $country_names {$country} ;
        $line .= "$country_name," ;

        last if $cnt_countries++ >= 25 ;
      }
      print CSV_COUNTRIES_TIMED "$line\n" ;

      my ($time, $time2, $hrs, $min, $line) ;
      foreach $time (sort {$a <=> $b} keys %times)
      {
        $hrs = $time / 60 ;
        $min = $time % 60 ;
        $time2 = "\"=Time($hrs,$min,0)\"" ;
        $line = "$bot,$target,$time2," ;
        $cnt_countries = 0 ;
        foreach $country (@countries)
        {
          $line .= sprintf ("%.0f", $multiplier_1000 * $countries_timed {"$bot,$target,$country,$time"}) . "," ;

          last if $cnt_countries++ >= 25 ;
        }
        print CSV_COUNTRIES_TIMED "$line\n" ;
      }
    }
  }
  close CSV_COUNTRIES_TIMED ;
}

# http://www.maxmind.com/app/iso3166 country codes
sub WriteCsvCountriesGoTo
{
  &LogSub ("WriteCsvCountriesGoTo: $path_csv/$file_csv_countries_languages_visited\n") ;

  open CSV_COUNTRIES_LANGUAGES_VISITED, '>', "$path_csv/$file_csv_countries_languages_visited" ;

  foreach $country (sort keys %countries)
  {
    @targets = sort {$targets_totals {"N,$country"}{$b} <=> $targets_totals {"N,$country"}{$a}} keys %{$targets_totals {"N,$country"}} ;

    $line = "\nBot,Country," ;
    $cnt_targets = 0 ;
    foreach $target (@targets)
    {
      $target2 = $target ;
      $target2 =~ s/^.*?:// ;
      $target3 = $out_languages {$target2} ;
      if ($target3 eq "")
      { $target3 = "[$target2]" ; }
      $line .= "$target3," ;

      last if $cnt_targets++ >= 25 ;
    }
    print CSV_COUNTRIES_LANGUAGES_VISITED "$line\n" ;

    foreach $bot ("N","Y")
    {
      $country_name = $country_names {$country} ;
      $country_name =~ s/\n//gs ;
      $country_name =~ s/[\x00-\x1F]//gs ;

      $cnt_targets = 0 ;
      $tot_targets = 0 ;
      foreach $target (@targets)
      {
        $tot_targets += $targets_totals {"$bot,$country"}{$target} ;
      }

      $line = "$bot,$country_name," ;
      $cnt_targets = 0 ;
      foreach $target (@targets)
      {
        $line .= $targets_totals {"$bot,$country"}{$target} . "," ;

        last if $cnt_targets++ >= 25 ;
      }
      print CSV_COUNTRIES_LANGUAGES_VISITED "$line\n" ;

      $line = "$bot,$country_name," ;
      $cnt_targets = 0 ;
      if ($tot_targets > 0)
      {
        foreach $target (@targets)
        {
          $line .= sprintf ("%.1f\%",100*$targets_totals {"$bot,$country"}{$target} / $tot_targets) . "," ;

          last if $cnt_targets++ >= 25 ;
        }
        print CSV_COUNTRIES_LANGUAGES_VISITED "$line\n" ;
      }
    }
  }
  close CSV_COUNTRIES_LANGUAGES_VISITED ;
}

sub WriteReportPerLanguageBreakDown
{
  &LogSub ("WriteReportPerLanguageBreakDown\n") ;

  my ($title,$views_edits,$links) = @_ ;
  my ($link_country,$population,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot) ;
  my @index_countries ;
  my $views_edits_lc = lc $views_edits ;

  $html  = $header ;
  $html =~ s/WORLDMAP_D3// ;
  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/ALSO/$links/ ;
  $html =~ s/LINKS// ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_recently_start - $requests_recently_stop<\/b>/ ;
  $html =~ s/DATE// ;

  $html .= "<p>'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a><p>\n" ;

  &AddNoticeSurvey (23) ;

  $html .= "<p><table border=1 width=800>INDEX\n" ;

  my $languages_reported ;

  foreach $language (keys_sorted_by_value_num_desc %requests_recently_per_language)
  {
    next if $requests_recently_per_language {$language} < 100 ;

    ($language_name,$anchor_language) = &GetLanguageInfo ($language) ;

    my %requests_per_country = %{$requests_recently_per_language_per_country {$language}} ;
    @countries = keys_sorted_by_value_num_desc %requests_per_country ;

    my $requests_this_language = $requests_recently_per_language {$language} ;

    $perc_global = '..' ;
    if ($requests_recently_all > 0)
    { $perc_global = &Percentage ($requests_this_language / $requests_recently_all) ; }

    $html_total .= "<tr><td colspan=6>&nbsp;</td><td colspan=8>&nbsp;</td><td colspan=8>&nbsp;</td></tr>" ;

    $html .= "<tr><th colspan=8 class=lh3><a id='$anchor_language' name='$anchor_language'></a><br>$language_name ($language) <small>($perc_global share of world total)</small></th></tr>" ;

    if ($languages_reported % 2 == 0)
    { $gif = "bluebar_hor2.gif" ; }
    else
    { $gif = "greenbar_hor2.gif" ; }

    $perc_tot = 0;
    for ($l = 0 ; $l < 50 ; $l++)
    {
      my $requests_this_country  = $requests_recently_per_language_per_country {$language} {$countries [$l]} ;
      my $requests_all_countries = $requests_recently_per_language             {$language} ;
      $perc = 0 ;
      if ($requests_all_countries > 0)
      {
        $perc = &Percentage ($requests_this_country / $requests_all_countries) ;

        last if ($perc < 0.5) || (($perc_global < 0.1) && ($perc < 1) || (($perc_global < 0.01) && ($perc < 3)) || (($perc_global < 0.001) && ($perc < 5))) ;

        $perc_tot += $perc ;
      }

      $country = $countries [$l] ;
      $country =~ s/ .*$// if length ($country) > 20 ;
      $bar_width = int ($perc * 6) ;

      $bar_100 = "" ;
      if ($bars++ == 0)
      {
        $bar_width_100 = 600 - $bar_width ;
        $bar_100 = "<img src='white.gif' width=$bar_width_100 height=15>" ;
        $bar_100 = '' ; # until gif is added
      }
      if (($country =~ /Australia/) && ($language_name =~ /Japanese/) && ($perc > 5))
      { $perc .= " <b><a href='#anomaly' onclick='alert(\"Probably incorrectly assigned to this country.\\nOutdated Regional Internet Registry (RIR) administration may have caused this.\")';><font color='#FF0000'>(*)</font></a></b>" ; $anomaly_found = $true ;}
      $html .= "<tr><th class=l class=small nowrap>$country</th>" .
               "<td class=c>[$requests_this_country ]$perc</td>" .
               "<td class=l><img src='$gif' width=$bar_width height=15>$bar_100</td></tr>\n" ;
    }

    if ($perc_tot > 100) { $perc_tot = 100 ; }

    $perc_other = sprintf '%.1f', 100 - $perc_tot ;
    if ($perc_other > 0)
    {
      $bar_width = $perc_other * 6 ;
      $html .= "<tr><th class=l class=small nowrap>Other</th>" .
               "<td class=c>$perc_other%</td>" .
               "<td class=l><img src='$gif' width=$bar_width height=15></td></tr>\n" ;
    }

    push @index_languages, "<a href='#$anchor_language'>$language_name</a> " ;

  # print "\n" ;
  # $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  }
  $html .= "</table>" ;
  $html .= "<p><b>Share<\/b> is the percentage of requesting ip addresses (out of the world total) which originated from this country" .
           "<br>&nbsp;Further percentages show per country share of requests per Wikipedia visited" ;
  $html .= "<p>Countries are only included if the number of requests in the period exceeds 100,000 (100 matching records in 1:1000 sampled log)" ;
  $html .= "<br>Page requests by bots are not included. Also all ip addresses that occur more than once on a given day are discarded for that day." ;
  $html .= "<br> A few false negatives are taken for granted. " ;
  $html .= $colophon_ez ;

  $index = &HtmlIndex (join '/ ', sort (@index_languages)) ;
  $html =~ s/INDEX/$index/ ;

  &PrintHtml ($html, "$path_reports/$file_html_per_language_breakdown") ;
}

sub WriteReportPerCountryOverview
{
  &LogSub ("WriteReportPerCountryOverview\n") ;

  my ($title,$views_edits,$links,$sample_rate) = @_ ;
  my ($link_country,$population,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot) ;
  my (@index_countries,@csv_countries) ;
  my $views_edits_lc = lc $views_edits ;
  my $views_edits_lcf = ucfirst $views_edits_lc ;
# ($views_edits2 = $views_edits) =~ s/ /\<br\>/ ;
  if ($views_edits =~ /edit/i)
  { $MPVE = 'MPE' ; } # monthly page edits
  else
  { $MPVE = 'MPV' ; } # monthly page views

  my $d3_data_entries_max = 25 ;

  $html  = $header ;
  $html =~ s/WORLDMAP_D3// ;
  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/LINKS// ;
  $html =~ s/ALSO/$links/ ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_recently_start - $requests_recently_stop<\/b>/ ;
  $html =~ s/DATE// ;
  
  &AddNoticeSurvey (21) ;

  $html .= &HtmlSortTable ;

  $html .= "<p>'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a>\n" ;

  $html .= "<p><table border=1 width=800 class=tablesorter id=table1>\n" ;
  $html .= "<thead>\n" ;
  $html .= "INDEX\n" ;

  $html .= &HtmlWorldMapsFixed ;

  $html .= "<tr><td class=hr colspan=3 rowspan=1><b>Location</b></td>" .
               "<td class=hc colspan=2 rowspan=2><b>Population</b><br><small><font color=#404040>absolute count and percentage of world population</font></small></td>" . # <td class=hc rowspan=2><b>$MPVE's<br>Per<br>Person</b></td>" .
               "<td class=hc colspan=2 rowspan=2><b>Internet<br>Users</b><br><small><font color=#404040>absolute count and percentage of country population</font></small></td>" .
               "<td class=hl colspan=4 rowspan=1><b>Monthly $views_edits</b></td></tr>\n" ;
#  $html .= "<tr>" .
#             # "<td class=hc><b>${MPVE}'s<br>Per<br>I U</b></td>" .
#               "<td colspan=99 class=hc><b>Share in Global Monthly $views_edits</b><br><small><font color=#808080>red and blue bars have different scale</font></small></td></tr>\n" ;
  $html .= "<tr><td class=hr><b>Country</b></td><td class=hc><b>Region</b><br><img src='//stats.wikimedia.org/Location_of_Continents2.gif'></td><td class=hc><b>N/S</b></td><td class=hc colspan=2><small><font color=#404040>absolute count and monthly ${views_edits}s per internet user</font></small></td><td class=hl colspan=2><small>share of world total<font color=#808080><p>note:blue and red bars have different scale</font></small></td></tr>\n" ;
  $html .= "<tr><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th colspan=2>&nbsp;</th></tr>\n" ;
  $html .= "</thead><tbody>\n" ;
  $html .= "TOTAL\nREGIONS\n" ;

  push @csv_countries, "# Wikimedia Traffic Analysis Report - Wikipedia $views_edits Per Country - Overview\n" .
                       "# Report based on data from $requests_recently_start - $requests_recently_stop\n" .
                       "country name, country code, monthly $views_edits_lc,population,internet users,internet penetration,monthly $views_edits_lc per internet user,share of global $views_edits_lc\n" ;

  $requests_tot = 0 ;

  undef %requests_per_region ;

  foreach $country_code (keys_sorted_by_value_num_desc %requests_recently_per_country_code)
  {
    my ($country,$code) = split ('\|', $country_code) ;

    my $region_code      = $region_codes {$code} ;

    if ($region_code eq '')
    { $region_code = 'XX' ; } 

  #  if ($region_code eq 'XX')
  # { print "$code $country $region_code\n" ; exit ; } # debug only # qqq 

    my $north_south_code = $north_south_codes {$code} ;

    $region_name = $region_code ;
    $region_name =~ s/^AF$/<font color=#028702><b>Africa<\/b><\/font>/ ;
    $region_name =~ s/^CA$/<font color=#249CA0><b>Central-America<\/b><\/font>/ ;
    $region_name =~ s/^SA$/<font color=#FCAA03><b>South-America<\/b><\/font>/ ;
    $region_name =~ s/^NA$/<font color=#C802CA><b>North-America<\/b><\/font>/ ;
    $region_name =~ s/^EU$/<font color=#0100CA><b>Europe<\/b><\/font>/ ;
    $region_name =~ s/^AS$/<font color=#E10202><b>Asia<\/b><\/font>/ ;
    $region_name =~ s/^OC$/<font color=#02AAD4><b>Oceania<\/b><\/font>/ ;
    $region_name =~ s/^XX$/<font color=#808080><b>Unknown1<\/b><\/font>/ ;

    $north_south_name = $north_south_code ;
    $north_south_name =~ s/^N$/<font color=#000BF7><b>N<\/b><\/font>/ ;
    $north_south_name =~ s/^S$/<font color=#FE0B0D><b>S<\/b><\/font>/ ;

    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;
     
    my $requests_this_country  = $requests_recently_per_country {$country} ;
    my $requests_this_country2 = int ($requests_this_country * $sample_rate / $months_recently) ;
    $requests_tot += $requests_this_country2  ;

    $requests_per_region {$region_code}      += $requests_this_country ;
    $requests_per_region {$north_south_code} += $requests_this_country ;
    $requests_per_region2 {$region_code}      += $requests_this_country2 ;
    $requests_per_region2 {$north_south_code} += $requests_this_country2 ;

    $requests_per_person = ".." ;
    if ($population > 0)
    { $requests_per_person    = sprintf ("%.0f", $requests_this_country2 / $population) ; }

    $requests_per_connected_person = ".." ;
    if ($connected > 0)
    {
      if ($views_edits =~ /edit/i)
      { $requests_per_connected_person = sprintf ("%.4f", $requests_this_country2 / $connected) ; }
      else
      {
        if ($requests_this_country2 / $connected >= 1.95)
        { $requests_per_connected_person = sprintf ("%.0f", $requests_this_country2 / $connected) ; }
        else
        { $requests_per_connected_person = sprintf ("%.1f", $requests_this_country2 / $connected) ; }
      }
    }

    $perc_share_total = '..' ;
    if ($requests_recently_all > 0)
    { $perc_share_total = &Percentage ($requests_this_country / $requests_recently_all) ; }
    $perc_share_total2 = $perc_share_total ;    
    if ($perc_share_total2 =~ /0\.0/)
    { $perc_share_total2 = '<font color=#CCC><small><&nbsp;0.1%</small></font>' ; }

    &Percentage ($requests_this_country / $requests_recently_all) ; 
    
    $perc_tot += $perc_share_total ;

    $bar = "&nbsp;" ;
    if ($perc_share_total > 0)
    { $bar = "<img src='redbar_hor.gif' width=" . (int ($perc_share_total * 10)) . " height=15>" ; }
    $bar2 = "&nbsp;" ;
    if ($perc_share_total > 0)
    { $bar2 = "<img src='redbar_hor.gif' width=" . (int ($perc_share_total * 10)) . " height=12>" ; }

    $perc_connected = ".." ;
    if ($population > 0)
    { $perc_connected = sprintf ("%.0f", 100 * $connected / $population) .'%' ; }

    # now use country names that are suitable for http://gunn.co.nz/map/
    $country2 = $country ;
    $country2 =~ s/Moldova, Republic of/Moldova/ ;
  # $country2 =~ s/Korea, Republic of/South Korea/ ;
  # $country2 =~ s/Korea, Democratic People's Republic of/North Korea/ ;
    $country2 =~ s/Iran, Islamic Republic of/Iran/ ;
    $country2 =~ s/UAE/United Arab Emirates/ ;
    $country2 =~ s/Congo - The Democratic Republic of the/Democratic Republic of the Congo/ ;
  # $country2 =~ s/Congo - The Democratic Republic of the/Congo Dem. Rep./ ;
  # $country2 =~ s/^Congo$/Republic of the Congo/ ;
    $country2 =~ s/Syrian Arab Republic/Syria/ ;
    $country2 =~ s/Tanzania, United Republic of/Tanzania/ ;
    $country2 =~ s/Libyan Arab Jamahiriya/Libya/ ;
    $country2 =~ s/C..?te d'Ivoire/C&ocirc;te d'Ivoire/ ;
    $country2 =~ s/Serbia/republic of serbia/ ;
    $country2 =~ s/Lao People's Democratic Republic/Laos/ ;


    push @csv_countries, "$country2,$code,$requests_this_country2,$population,$connected,$perc_connected,$requests_per_connected_person,$perc\n" ;

    $population2 = &i2KM2 ($population) ;
    $connected2  = &i2KM2 ($connected) ;
    $requests_this_country2 = &i2KM2 ($requests_this_country2) ;

    if ($population_tot > 0)
    { $perc_population = &Percentage ($population / $population_tot) ; }

    if ($perc_population =~ /\.0\d/)
    { $perc_population = "<font color=#CCC><small>$perc_population</small></font>" ; }

    $html .= "<tr><th class=rh3><a id='$country' name='$country'></a>$link_country $icon</td>" .
                 "<td>$region_name</td>" .
                 "<td>$north_south_name</td>" .
                 "<td>$population2</td>" . # <td>$requests_per_person</td>" .
                 "<td>$perc_population</td>" . # <td>$requests_per_person</td>" .
                 "<td>$connected2</td>" .
                 "<td>$perc_connected</td>" .
                 "<td>$requests_this_country2</td>" .
                 "<td>$requests_per_connected_person</td>" .
                 "<td>$perc_share_total</td>" .
                 "<td class=l>$bar</td></tr>\n" ;

    if ($d3_data_regions2 {$region_code} eq '')
    { 
      $d3_data_regions2 {$region_code} .= 
                 "<tr class=bubbles>" . 
                 "<th>&nbsp;</th>" . 
                 "<th class=l>flag/country</th>" .
                 "<th>N/S</th>" .
                 "<th>$icon_people</th>" . 
                 "<th>% $icon_world $icon_people</th>" . 
                 "<th>$icon_connected</th>" .
                 "<th>$icon_wikipedia $icon_views</th>" .
               # "<th>$requests_per_connected_person</th>" .
                 "<th>&nbsp;</th>" . 
                 "<th class=l>% $icon_world$icon_views</th></tr>" ;
    }
    if ($d3_data_regions2 {'world'} eq '')
    { 
      $d3_data_regions2 {'world'} .= 
                 "<tr class=bubbles><th>&nbsp;</th>" . 
                 "<th class=l>flag/country</th>" .
                 "<th>N/S</th>" .
                 "<th>$icon_people</th>" . 
                 "<th>% $icon_world $icon_people</th>" . 
                 "<th>$icon_connected</th>" .
                 "<th>$icon_wikipedia $icon_views</th>" .
                 "<th>&nbsp;</th>" . 
               # "<th>$requests_per_connected_person</th>" .
                 "<th class=l>% $icon_world$icon_views</th></tr>" ;
    }

    if ($d3_data_regions2 {$north_south_code} eq '')
    { 
      $d3_data_regions2 {$north_south_code} .= 
                 "<tr class=bubbles><th>&nbsp;</th>" . 
                 "<th class=l>flag/country</th>" .
                 "<th>N/S</th>" .
                 "<th>$icon_people</th>" . 
                 "<th>% $icon_world $icon_people</th>" . 
                 "<th>$icon_connected</th>" .
                 "<th>$icon_wikipedia $icon_views</th>" .
                 "<th>&nbsp;</th>" . 
               # "<th>$requests_per_connected_person</th>" .
                 "<th class=l>% $icon_world$icon_views</th></tr>" ;
    }


    if (($region_code eq 'AF') || ($region_code eq 'AS') || ($region_code eq 'EU'))
    { $icon = "<sub><sub>$icon</sub></sub>" ; }
    
    if ($d3_data_regions3 {$region_code} eq 'odd')
    { $d3_data_regions3 {$region_code} = 'even' ; }
    else
    { $d3_data_regions3 {$region_code} = 'odd' ; }
    $odd_even = $d3_data_regions3 {$region_code} ; 

    
    $link_country =~ s/<\/?a[^>]*>//g ;
    $link_country =~ s/alt=['"]+ // ;
    $link_country =~ s/Democratic Republic of the Congo/Congo Dem. Rep./ ;

    $d3_data_entries {$region_code} ++ ;
    $index =  $d3_data_entries {$region_code} ;
    $d3_data_regions2 {$region_code} .= 
                 "<tr class='bubbles_$odd_even'>" .
                 "<td class=r>$index</td>" .
                 "<th class=l>$icon $link_country</th>" .
                 "<td>$north_south_name</td>" .
                 "<td>$population2</td>" . # <td>$requests_per_person</td>" .
                 "<td>$perc_population</td>" . # <td>$requests_per_person</td>" .
                 "<td>$perc_connected</td>" .
                 "<td>$requests_this_country2</td>" .
               # "<td>$requests_per_connected_person</td>" .
                 "<td>$perc_share_total2</td>" .
                 "<td class=l>$bar2</td></tr>" ;
   
    $d3_data_entries {'world'} ++ ;
    if ($d3_data_entries {'world'} <= $d3_data_entries_max)
    {
      if ($d3_data_regions3 {'world'} eq 'odd')
      { $d3_data_regions3 {'world'} = 'even' ; }
      else
      { $d3_data_regions3 {$world} = 'odd' ; }
      $odd_even = $d3_data_regions3 {$world} ; 
      $index =  $d3_data_entries {'world'} ;
      $d3_data_regions2 {'world'} .= 
                   "<tr class='bubbles_$odd_even'>" .
                   "<td class=r>$index</td>" .
                   "<th class=l>$icon $link_country</th>" .
                   "<td>$north_south_name</td>" .
                   "<td>$population2</td>" . # <td>$requests_per_person</td>" .
                   "<td>$perc_population</td>" . # <td>$requests_per_person</td>" .
                   "<td>$perc_connected</td>" .
                   "<td>$requests_this_country2</td>" .
                 # "<td>$requests_per_connected_person</td>" .
                   "<td>$perc_share_total2</td>" .
                   "<td class=l>$bar2</td></tr>" ;
    }

    $d3_data_entries {$north_south_code} ++ ;
    if ($d3_data_entries {$north_south_code} <= $d3_data_entries_max)
    {
      if ($d3_data_regions3 {$north_south_code} eq 'odd')
      { $d3_data_regions3 {$north_south_code} = 'even' ; }
      else
      { $d3_data_regions3 {$north_south_code} = 'odd' ; }
      $odd_even = $d3_data_regions3 {$north_south_code} ; 
      $index =  $d3_data_entries {$north_south_code} ;

      $d3_data_regions2 {$north_south_code} .= 
                   "<tr class='bubbles_$odd_even'>" .
                   "<td class=r>$index</td>" .
                   "<th class=l>$icon $link_country</th>" .
                   "<td>$north_south_name</td>" .
                   "<td>$population2</td>" . # <td>$requests_per_person</td>" .
                   "<td>$perc_population</td>" . # <td>$requests_per_person</td>" .
                   "<td>$perc_connected</td>" .
                   "<td>$requests_this_country2</td>" .
                 # "<td>$requests_per_connected_person</td>" .
                   "<td>$perc_share_total2</td>" .
                   "<td class=l>$bar2</td></tr>" ;
    }
    
    if ($verbose)
    { push @index_countries, "<a href=#$country>$country ($perc)</a>\n " ; }
    else
    { push @index_countries, "<a href=#$country>$country</a>\n " ; }
  }

  $requests_per_person_tot =  '..' ;

  if ($population_tot > 0)
  { $requests_per_person_tot = sprintf ("%.0f", $requests_tot / $population_tot) ; }

  if ($connected_tot > 0)
  {
    if ($views_edits =~ /edit/i)
    { $requests_per_connected_person_tot = sprintf ("%.4f", $requests_tot / $connected_tot) ; }
    else
    { $requests_per_connected_person_tot = sprintf ("%.1f", $requests_tot / $connected_tot) ; }
  }
  
  $d3_data_regions2 {'world'} .= "<tr><td colspan=99 class=l><font color=#AAA>Etc (only top $d3_data_entries_max countries with most page views are shown)</font></td></tr>" ;
  $d3_data_regions2 {'N'} .= "<tr><td colspan=99 class=l><font color=#AAA>Etc (only top $d3_data_entries_max countries with most page views are shown)</font></td></tr>" ;
  $d3_data_regions2 {'S'} .= "<tr><td colspan=99 class=l><font color=#AAA>Etc (only top $d3_data_entries_max countries with most page views are shown)</font></td></tr>" ;

  $perc_connected_tot = ".." ;
  if ($population_tot > 0)
  { $perc_connected_tot = sprintf ("%.0f", 100 * $connected_tot / $population_tot) .'%' ; }

  push @csv_countries, "world,*,$requests_tot,$population_tot,$connected_tot,$perc_connected_tot,$requests_per_connected_person_tot,100%\n" ;

  $requests_tot2   = &i2KM2 ($requests_tot) ;
  $population_tot2 = &i2KM2 ($population_tot) ;
  $connected_tot2  = &i2KM2 ($connected_tot) ;

  $html_total = "<tr><th class=rh3>All countries in</td>" .
                    "<td><b>World</b></td>" .
                    "<td>&nbsp;</td>" .
                    "<td>$population_tot2</td>" .
                    "<td>100%</td>" .
                    "<td>$connected_tot2</td>" .
                    "<td>$perc_connected_tot</td>" .
                    "<td>$requests_tot2</td>" .
                    "<td>$requests_per_connected_person_tot</td>" .
                    "<td>100%</th>" .
                    "<td class=l>&nbsp;</td></tr>\n" ;
  $html_total .= "<tr><td colspan=99>&nbsp;</td></tr>" ;


  $d3_data_regions2 {'world'} =~ s/"/'/g ; 
  $d3_data_regions  {'world'} = "population_abs  : '$population_tot2',\n" .
                                "    population_perc : '100%',\n" .
                                "    connected_abs   : '$connected_tot2',\n" .  
                                "    connected_perc  : '$perc_connected_tot',\n" .   
                                "    requests_abs    : '$requests_tot2',\n" .
                                "    requests_pp     : '$requests_per_connected_person_tot',\n" .
                                "    requests_perc   : '100%',\n" .
                                "    breakdown       :\"" . 
                                $d3_data_regions2 {'world'} . "\"," ; 
  $html_regions = '' ;
  foreach $key (qw (N S AF AS EU CA NA SA OC XX))
  {
    $region = $key ;
    $region2 = $region ;

    $region =~ s/^N$/<font color=#000BF7><b>Global North<\/b><\/font>/ ;
    $region =~ s/^S$/<font color=#FE0B0D><b>Global South<\/b><\/font>/ ;

    $region =~ s/^AF$/<font color=#028702><b>Africa<\/b><\/font>/ ;
    $region =~ s/^CA$/<font color=#249CA0><b>Central-America<\/b><\/font>/ ;
    $region =~ s/^SA$/<font color=#FCAA03><b>South-America<\/b><\/font>/ ;
    $region =~ s/^NA$/<font color=#C802CA><b>North-America<\/b><\/font>/ ;
    $region =~ s/^EU$/<font color=#0100CA><b>Europe<\/b><\/font>/ ;
    $region =~ s/^AS$/<font color=#E10202><b>Asia<\/b><\/font>/ ;
    $region =~ s/^OC$/<font color=#02AAD4><b>Oceania<\/b><\/font>/ ;
    $region =~ s/^XX$/<font color=#808080><b>Unknown2<\/b><\/font>/ ;

    $population_region = $population_per_region {$key} ;
    $connected_region  = $connected_per_region  {$key} ;
    $requests_region   = $requests_per_region   {$key} ;
    $requests_region2  = $requests_per_region2  {$key} ; # qqq

    $perc_connected_region = ".." ;
    if ($population_region > 0)
    { $perc_connected_region = sprintf ("%.0f", 100 * $connected_region / $population_region) .'%' ; }

    $perc_share_total = '..' ;
    if ($requests_recently_all > 0)
    { $perc_share_total = &Percentage ($requests_region / $requests_recently_all) ; }

    $perc_population_region = ".." ;
    if ($population_region > 0)
    { $perc_population_region = &Percentage ($population_region / $population_tot) ; }

 #  $requests_region2 = int ($requests_region * 1000 / $months_recently) ;

    $requests_per_connected_person = '..' ;
    if ($connected_region > 0)
    {
      if ($views_edits =~ /edit/i)
      { $requests_per_connected_person = sprintf ("%.4f", $requests_region2 / $connected_region) ; }
      else
      { $requests_per_connected_person = sprintf ("%.0f", $requests_region2 / $connected_region) ; }
    }

    $population_region = &i2KM2 ($population_region) ;
    $connected_region  = &i2KM2 ($connected_region) ;
    $requests_region   = &i2KM2 ($requests_region) ;
    $requests_region2  = &i2KM2 ($requests_region2) ;

    $bar = "&nbsp;" ;
    if ($perc_share_total > 0)
    { $bar = "<img src='bluebar_hor.gif' width=" . (int ($perc_share_total * 3)) . " height=15>" ; }

 #  $html_regions .= &WriteReportPerCountryOverviewLine ("All countries in", $region, '', $requests, $population) ;

    if ($key ne 'XX')
    {
      $html_regions .= "<tr><th>All countries in</th>" .
                       "</td><td>$region</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>$population_region</td>" .
                       "<td>$perc_population_region</td>" .
                       "<td>$connected_region</td>" .
                       "<td>$perc_connected_region</td>" .
                       "<td>$requests_region2</td>" .
                       "<td>$requests_per_connected_person</td>" .
                       "<td>$perc_share_total</th>" .
                       "<td class=l>$bar</td></tr>\n" ;

      $d3_data_regions2 {$region2} =~ s/"/'/g ; 
      $d3_data_regions {$region2}  = "population_abs  : '$population_region',\n" .
                                     "    population_perc : '$perc_population_region',\n" .
                                     "    connected_abs   : '$connected_region',\n" .  
                                     "    connected_perc  : '$perc_connected_region',\n" .   
                                     "    requests_abs    : '$requests_region2',\n" .
                                     "    requests_pp     : '$requests_per_connected_person',\n" .
                                     "    requests_perc   : '$perc_share_total',\n" .
                                     "    breakdown       :\"" . 
                                     $d3_data_regions2 {$region2} . "\"," ; 
    }
    else
    {
      $html_regions .= "<tr><th>Remainder</th>" .
                       "</td><td>$region</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>$requests_region2</td>" .
                       "<td>&nbsp;</td>" .
                       "<td>$perc_share_total</th>" .
                       "<td class=l>$bar</td></tr>\n" ;
    }

    if (($key eq 'S') || (($key eq 'XX')))
    { $html_regions .= "<tr><td colspan=99>&nbsp;</td></tr>" ; }
  }


  $html .= "</tbody>\n</table>" ;
  $html .= "<br>$views_edits_lcf by bots are not included. Also all ip addresses that occur more than once on a given day are discarded for that day." ;
  $html .= "<br> A few false negatives are taken for granted. " ;
  $html .= "Country meta data collected from English Wikipedia (<a href='//en.wikipedia.org/wiki/List_of_countries_by_population'>population</a>, <a href='//en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>internet users</a>)). " ;
# $html .= "<br>Monthly $views_edits_lc per person is calculated over total population, regardless of age and internet connectivity" ; # how come, misplaced here ?!

  $html .= &HtmlSortTableColumns; ;
  $html .= $colophon_ez ;

  $index = &HtmlIndex (join '/ ', sort (@index_countries)) ;
  $html =~ s/INDEX/$index/ ;
  $html =~ s/TOTAL/$html_total/ ;
  $html =~ s/REGIONS/$html_regions/ ;

  &PrintHtml ($html, "$path_reports/$file_html_per_country_overview") ;


  $d3_data_languages {'en'} =
     "breakdown: " ; 
   # "<tr class=bubbles>" . 
   # "<th>&nbsp;</th>" . 
   # "<th class=l>flag/country</th>" .
   # "<th>N/S</th>" .
   # "<th>$icon_people</th>" . 
   # "<th>% $icon_world $icon_people</th>" . 
   # "<th>$icon_connected</th>" .
   # "<th>$icon_wikipedia $icon_views</th>" .
   # "<th>&nbsp;</th>" . 
   # "<th class=l>% English views</th></tr> + " ; 

  $d3_data_languages {'en'} .= 
     "\"<tr class=bubbles>" . 
     "<td><img alt='' src='//upload.wikimedia.org/wikipedia/en/thumb/a/a4/Flag_of_the_United_States.svg/23px-Flag_of_the_United_States.svg.png' width='23' height='12' border=1></td>" . 
     "<td>United States</th>" .
     "<th><font color=#F00><small>N</small></font></th>" .
     "<td class=lnb>42.6%</td>" . 
     "<td class=lnb><img src='bluebar_hor2.gif' width=60 height=15></tr>" ;

  $d3_data_languages {'en'} .= 
     "<tr class=bubbles>" . 
     "<td><img alt='' src='//upload.wikimedia.org/wikipedia/en/thumb/a/ae/Flag_of_the_United_Kingdom.svg/23px-Flag_of_the_United_Kingdom.svg.png' width='23' height='12' border=1></td>" . 
     "<td>United Kingdom</th>" .
     "<th><font color=#F00><small>N</small></font></th>" .
     "<td class=lnb>10.1%</td>" . 
     "<td class=lnb><img src='bluebar_hor2.gif' width=15 height=15></tr>" ;

  $d3_data_languages {'en'} .= 
     "<tr class=bubbles>" . 
     "<td><img alt='' src='//upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/23px-Flag_of_India.svg.png' width='23' height='12' border=1></td>" . 
     "<td>India</th>" .
     "<th><font color=#00F><small>S</small></font></th>" .
     "<td class=lnb>6.5%</td>" . 
     "<td class=lnb><img src='bluebar_hor2.gif' width=8 height=15></tr>\"," ;
}

# input for http://gunn.co.nz/map/
sub WriteCsvFilePerCountryDensity
{
  my ($views_edits, $period, $ref_requests_per_period_per_country, $max_requests_per_connected_us, $desc_animation) = @_ ;

  &LogSub ("WriteCsvFilePerCountryDensity (input for input for //gunn.co.nz/map/) $views_edits\n\n") ;

  my %requests_per_country_code = %{$ref_requests_per_period_per_country -> {$period}} ;

  my $description = $descriptions_per_period {$period} ;
  my $postfix     = $descriptions_per_period {$period} ;
# $test = join '', sort values %requests_per_country_code ;
# print $test . "\n\n" ;

  my ($link_country,$country,$code,$population,$connected,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot,$requests_max,$requests_this_country,$requests_this_country2) ;
  my (@index_countries,@csv_countries,%svg_groups,%percentage_of_total_pageviews,%requests_per_connected_persons) ;

  undef @csv_countries ;
  $header_csv_countries = "# Wikimedia Traffic Analysis Report - Wikipedia $views_edits Per Country Per Internet User\n" .
                          "# Data file is input for //gunn.co.nz/map/\n" .
                          "# See also //infodisiac.com/blog/2012/02/wikipedia-readers/\n" .
                          "country,requests,population,monthly views per inhabitant,internet users,%connected,requests per user\n" ;
                        # "country,code,views,population,internet users,%connected,views per user,%global views\n" ;

  $requests_tot = 0 ;
  undef %fills ;

#  # normalize to 100% average
#  $requests_cnt = 0 ;
#  $requests_tot = 0 ;
#  foreach $country_code (keys %requests_per_country_code)
#  {
#    $requests_cnt ++ ;
#    $requests_tot += $requests_per_country_code {$country_code} ;
#  }

#  abort ("\$requests_cnt == 0") if $requests_cnt == 0 ;
#  $requests_avg = $requests_tot / $requests_cnt ;
#  print "requests cnt: $requests_cnt, tot: $requests_tot, avg: $requests_avg\n" ;

#  abort ("\$requests_avg == 0") if $requests_avg == 0 ;
#  foreach $country_code (keys %requests_per_country_code)
#  { $requests_per_country_code {$country_code} *= 100/$requests_avg ; }
#  # normalize complete

# print "$code, $country: $requests_this_country\n" ;
  $requests_this_country  = $requests_per_country_code {$country_code} ;

  foreach $country_code (keys_sorted_by_value_num_desc %requests_per_country_code)
  {
    ($country,$code) = split ('\|', $country_code) ;

    $country =~ s/Korea, Republic of/South Korea/ ;

    if ($country =~ /korea/i)
    { $a = 1 ; }
    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;

    $requests_this_country  = $requests_per_country_code {$country_code} ;

    $requests_this_country  = &CorrectForMissingDays ($period, $requests_per_country_code {$country_code} * 1000, $code, "\$requests_this_country") ;

    $requests_this_country  = sprintf ("%.1f", $requests_this_country) ; # quarterly -> monthly average
    $requests_tot += $requests_this_country ;

    $requests_per_person = ".." ;
    if ($population > 0)
    { $requests_per_person    = sprintf ("%.4f", $requests_this_country / $population) ; }

    $requests_per_connected_person = ".." ;
    if ($connected > 0)
    {
    # if ($requests_this_country / $connected >= 1.95)
    # { $requests_per_connected_person = sprintf ("%.0f", $requests_this_country / $connected) ; }
    #  else
    #  { $requests_per_connected_person = sprintf ("%.1f", $requests_this_country / $connected) ; }
      $requests_per_connected_person = sprintf ("%.4f", $requests_this_country / $connected) ;
    }

    $perc = '0.0' ;
    $requests_all = &CorrectForMissingDays ($period, $requests_all_per_period {$period} * 1000, $code, "\$requests_all") ;
    if ($requests_all > 0)
    { $perc = &Percentage ($requests_this_country / $requests_all) ; }
    $perc_tot += $perc ;

    $perc_connected = ".." ;
    if ($population > 0)
    { $perc_connected = sprintf ("%.1f", 100 * $connected / $population) .'%' ; }

    # now use country names that are suitable for //gunn.co.nz/map/
    $country =~ s/UAE/United Arab Emirates/ ;                                                 # http://gunn.co.nz/map/
    $country =~ s/Congo Dem. Rep./Democratic Republic of the Congo/ ;                         # http://gunn.co.nz/map/
  # $country =~ s/^Congo$/Republic of the Congo/ ;                                            # http://gunn.co.nz/map/
  # $country =~ s/Cote d'Ivoire/Côte d'Ivoire/ ;                                              # http://gunn.co.nz/map/
    $country =~ s/Serbia/republic of serbia/ ;                                                # http://gunn.co.nz/map/

  # $country =~ s/Moldova, Republic of/Moldova/ ;
  # $country =~ s/Korea, Republic of/South Korea/ ;
  # $country =~ s/Korea, Democratic People's Republic of/North Korea/ ;
  # $country =~ s/Iran, Islamic Republic of/Iran/ ;
  # $country =~ s/UAE/United Arab Emirates/ ;
  # $country =~ s/Congo - The Democratic Republic of the/Democratic Republic of the Congo/ ;
 ## $country =~ s/^Congo$/Republic of the Congo/ ;
  # $country =~ s/Syrian Arab Republic/Syria/ ;
  # $country =~ s/Tanzania, United Republic of/Tanzania/ ;
  # $country =~ s/Libyan Arab Jamahiriya/Libya/ ;
 ## $country =~ s/Cote d'Ivoire/Côte d'Ivoire/ ;
  # $country =~ s/Serbia/republic of serbia/ ;
  # $country =~ s/Lao People's Democratic Republic/Laos/ ;
  #  $country =~ s/,/./g ;

#Missing values for large countries (large as visible on http://gunn.co.nz/map/)
#Democratic Republic of the Congo,372000.0,..,..,..,..
#Sudan,1917000.0,30894000,..,0.0%,..
#Somalia,35000.0,9557000,..,0.0%,..
#Republic of the Congo,114000.0,4140000,..,0.0%,..
#Myanmar,663000.0,48337000,..,0.0%,..
#North Korea,10000.0,..,..,..,..
#South Korea,61397000.0,48219000,..,0.0%,..
#Sierra Leone,65000.0,5997000,..,0.0%,..

  # push @csv_countries, "\"$country\",$code,$requests_this_country,$population,$connected,$perc_connected,$requests_per_connected_person,$perc,$requests_svg,$ratio_svg,$fill_svg\n" ;
    # for http://gunn.co.nz/map/
    push @csv_countries,"$country,$requests_this_country,$population,$requests_per_person,$connected,$perc_connected,$requests_per_connected_person\n" ;

    $requests_per_connected_persons {lc $code} = $requests_per_connected_person ;
    $requests_per_persons           {lc $code} = $requests_per_person ;
    $percentage_of_total_pageviews  {lc $code} = $perc ;
  }

  $requests_per_person_tot =  '..' ;

  if ($population_tot > 0)
  { $requests_per_person_tot = sprintf ("%.1f", $requests_tot / $population_tot) ; }

  if ($connected_tot > 0)
  { $requests_per_connected_person_tot = sprintf ("%.1f", $requests_tot / $connected_tot) ; }

  $perc_connected_tot = ".." ;
  if ($population_tot > 0)
  { $perc_connected_tot = sprintf ("%.1f", 100 * $connected_tot / $population_tot) .'%' ; }

# push @csv_countries, "world,*,$requests_tot,$population_tot,$connected_tot,$perc_connected_tot,$requests_per_connected_person_tot,100%\n" ;
  &LogDetail ("$period $requests_tot\n") ;

# $file_csv_per_country_overview2 =  $file_csv_per_country_overview ;
# $file_csv_per_country_overview2 =~ s/\.csv/-$postfix.csv/ ;
  &PrintCsv  ($header_csv_countries . join ('', sort @csv_countries), "$path_csv/$file_csv_per_country_density") ;
}

sub WriteReportPerCountryBreakdown
{
  &LogSub ("WriteReportPerCountryBreakDown\n") ;

  &AddExtraCountryNames_3166_1_alpha_3 ;

  my @index_countries ;
  my $views_edits_lc = lc $views_edits ;

  if ($sample_rate == 1) # edits
  { $report_version = '' ; }
  else
  {
    if ($show_logcount)
    { $report_version = "<p>Showing even small percentages (> $cutoff_percentage\%). " .
               "Switch to <a href='$file_html_per_country_breakdown'>concise version</a>" ; }
    else
    { $report_version = "<p>Showing only only major percentages (> $cutoff_percentage\%). " .
               " Switch to <a href='$file_html_per_country_breakdown_huge'>detailed version</a>" ; }
  }     

  $html  = $header ;  # qqqq

  $folder_scripts = "//stats.wikimedia.org/wikimedia/squids/scripts/" ;
  $html =~ s/WORLDMAP_D3/<script src="$folder_scripts\/d3.min.js"><\/script>\n<script src="$folder_scripts\/topojson.min.js"><\/script>\n<script src="$folder_scripts\/datamaps.world.hires.min.js"><\/script>\n<script src="$folder_scripts\/options.js"><\/script>\n/ ;

  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/LINKS// ;
  $html =~ s/ALSO/$links$report_version/ ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_recently_start - $requests_recently_stop<\/b>/ ;
  $html =~ s/DATE// ;

  $html .= "<p>'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a><p>\n" ;

  &AddNoticeSurvey (22) ;

  $html .= "<p><table border=1 width=800>INDEX\n" ;

  $html .= &HtmlWorldMapsHover ($d3_data_countries,%d3_regions) ;

  $html .= &HtmlWorldMapsFixed ;

  my $anomaly_found ;
  my $d3_data_countries = '' ;

  foreach $country (keys_sorted_by_value_num_desc %requests_recently_per_country)
  {
    # Q&D fix, if condition is enabled prints just 2 countries in SquidReportPageEditsPerCountryBreakdown.htm
    # now that we returned to sampled edits

    # next if $requests_recently_per_country {$country} < $cutoff_requests ;
    
    %requests_per_language = %{$requests_recently_per_country_per_language {$country}} ;
    @languages = keys_sorted_by_value_num_desc %requests_per_language ;

    $requests_this_country  = $requests_recently_per_country {$country} ;

#   $country_name = $country_names {$country_code} ;
#   $country_meta = $country_meta_info {$country_name} ;
    $country_meta = $country_meta_info {$country} ;

    my ($link,$population,$connected,$icon) = split (',', $country_meta) ;
    $population  =~ s/_//g ;
    $connected   =~ s/_//g ;
    $population2 = &i2KM ($population) ;
    $requests_this_country2 = &i2KM ($requests_this_country * 1000) ; # input is in 1000's 
    $connected2  = '--' ;
    $requests_per_capita = '--' ;
     
    if ($population> 0)
    { 
      $connected2 = sprintf ("%.0f", 100*$connected/$population) .'%' ; 
      if ($requests_this_country * 1000 / $population >= 0.1)
      { $requests_per_capita = sprintf ("%.1f", ($requests_this_country * 1000) / $population) ; }
      elsif ($requests_this_country * 1000 / $population >= 0.01)
      { $requests_per_capita = sprintf ("%.2f", ($requests_this_country * 1000) / $population) ; }
      else
      { $requests_per_capita = sprintf ("%.3f", ($requests_this_country * 1000) / $population) ; }
    } 

    $perc = 'n.a.' ;
    if ($requests_recently_all > 0)
    { $perc = &Percentage ($requests_this_country / $requests_recently_all) ; }

    ($link_country,$icon,$population) = &CountryMetaInfo ($country) ;

    $code_3166_1_alpha_3 = $country_names_3166_1_alpha_3 {$country} ;
    if ($code_3166_1_alpha_3 eq '')
    { 
      print "no 3166 code for '$country'\n" ; 
      $code_3166_1_alpha_3 = 'XXX' ; 
    }
    
    # print "country $country -> $code_3166_1_alpha_3\n" ;

    ($perc2 = $perc) =~ s/\%// ; 

#      if ($perc2 <= 0.25) { $fillkey = "below 0.25%" ; }
#   elsif ($perc2 <= 1.0)  { $fillkey = "0.25% - 0.99%" ; }
#   elsif ($perc2 <= 2.5)  { $fillkey = "1.0% - 2.49%" ; }
#   elsif ($perc2 <= 5.0)  { $fillkey = "2.5% - 4.99%" ; }
#   else                   { $fillkey = "5.0% and up" ; }

       if ($requests_per_capita < 0.25) { $fillkey = "&nbsp;&nbsp;<sub><sub>$icon_views</sub></sub> per <sub><sub>$icon_person</sub></sub> 0 - 0.25" ; }
    elsif ($requests_per_capita < 1.0)  { $fillkey = "0.25 - 0.99" ; }
    elsif ($requests_per_capita < 2.5)  { $fillkey = "1 - 2.49" ; }
    elsif ($requests_per_capita < 5.0)  { $fillkey = "2.5 - 4.99" ; }
    elsif ($requests_per_capita < 10)   { $fillkey = "5 - 9.99" ; }
    else                                { $fillkey = "10 and up" ; }

    $icon =~ s/"/'/g ;
    $d3_data_countries .= "$code_3166_1_alpha_3:{\n" . 
                          "    \"fillKey\": \"$fillkey\"\n" . 
                          "    ,\"icon\": \"$icon\"\n" . 
                          "    ,\"perc_total\": $perc2\n" .  
                          "    ,\"requests\": \"$requests_this_country2\"\n" .  
                          "    ,\"requests_per_capita\": \"$requests_per_capita\"\n" .  
                          "    ,\"population\":\"$population2\"\n" . 
                          "    ,\"connected\":\"$connected2\"\n" . 
                          "    ,\"breakdown\":\n" , 

 
    $html .= "<tr><th colspan=99 class=lh3><a id='$country' name='$country'></a><br>$icon $link_country <small> $population2 people ($connected2 with internet) issued $requests_this_country2 requests ($perc of world total), or $requests_per_capita per person per month</small></th></tr>\n" ;

    $perc_tot = 0;
    $requests_used = 0 ;
    for ($l = 0 ; $l < 50 ; $l++)
    {
      $requests_this_language = $requests_recently_per_country_per_language {$country} {$languages [$l]} ;
      $requests_all_languages = $requests_recently_per_country              {$country} ;

      last if $requests_this_language == 0 ;

      $requests_used += $requests_this_language ;

      $perc = 0 ;
      if ($requests_recently_all > 0)
      {
        $perc = &Percentage ($requests_this_language / $requests_all_languages) ;

        last if $perc < $cutoff_percentage ;

        $perc_tot += $perc ;
      }

      $language = $languages [$l] ;
      if ($out_languages {$language} ne "")
      { $language = $out_languages {$language} ; }
      if (length ($language) > 20)
      { $language =~ s/ .*$// ; }
      $bar_width  = int ($perc * 6) ;
      $bar_width2 = int ($perc * 2) ;
      if ($bar_width2 < 1)
      { $barwidth2 = 1 ; }

      if (($country eq "Australia") && ($language eq "Japanese") && ($perc > 5))
      { $language .= " <b><a href='#anomaly' onclick='alert(\"Probably incorrectly assigned to this country.\\nOutdated Regional Internet Registry (RIR) administration may have caused this.\")';><font color='#FF0000'>(*)</font></a></b>" ; $anomaly_found = $true ;}

      $bar_100 = "" ;
      if ($bars++ == 0)
      {
        $bar_width_100 = 600 - $bar_width ;
        $bar_100 = "<img src='white.gif' width=$bar_width_100 height=15>" ;
        $bar_100 = '' ; # until gif is added
      }

      if ($language !~ /Portal/)
      { $language .= " Wp" ; }

      $perc =~ s/(\.\d)0/$1/ ; # 0.10% -> 0.1%
      if ($show_logcount && ($requests_this_language < 5 * $months_recently)) # show in grey to discuss threshold on foundation-l
      { $perc = "<font color=#800000>$perc</font>" ; }

      ($language2 = $language) =~ s/ Wp// ;

      $d3_data_countries .= "\"<tr>" . 
                            "<td class=lnb><font color=#888>" . $languages [$l] . "</font></td>" . 
                            "<td class=lnb>$language2</td>" . 
                            "<td class=rnb>$perc</td>" . 
                            "<td class=lnb><img src='yellowbar_hor.gif' width=$bar_width2 height=10></td>" . 
                             "</tr>\" + \n" ; 

    # $d3_data_countries .= "row_country ('" . $languages [$l] . "','" . $language2 . "','" . $perc . "'," . $bar_width2 . ") + \n" ;

      $html .= "<tr><th class=l class=small nowrap>$language</th>" .
               ($show_logcount ? "<td class=r>$requests_this_language</td>" : "") .
               "<td class=c>$perc</td>" .
               "<td class=l><img src='yellowbar_hor.gif' width=$bar_width height=15>$bar_100</td></tr>\n" ;
    }

    if ($perc_tot > 100) { $perc_tot = 100 ; }
    $requests_other = $requests_all_languages - $requests_used ;
    $perc_other = sprintf '%.1f', 100 - $perc_tot ;
    if (($requests_other > 0) && ($perc_other > 0))
    {
      $bar_width = $perc_other * 6 ;
      $bar_width2 = int ($perc_other * 2) ;
      if ($bar_width2 < 1)
      { $barwidth2 = 1 ; }

      $d3_data_countries .= "\"<tr>" . 
                            "<td class=lnb>&nbsp;</td>" . 
                            "<td class=lnb>Other</td>" . 
                            "<td class=rnb>$perc_other\%</td>" . 
                            "<td class=lnb><img src='yellowbar_hor.gif' width=$bar_width2 height=10></td>" . 
                            "</tr>\" + \n" ; 

      $html .= "<tr><th class=l class=small nowrap>Other</th>" .
               ($show_logcount ? "<td class=r>$requests_other</td>" : "") .
               "<td class=c>$perc_other%</td>" .
               "<td class=l><img src='yellowbar_hor.gif' width=$bar_width height=15></td></tr>\n" ;
    }
    $d3_data_countries .= "\"\"},\n" ;

    if ($verbose)
    { push @index_countries, "<a href='#$country'>$country ($perc)</a> " ; }
    else
    { push @index_countries, "<a href='#$country'>$country</a> " ; }

  # print "\n" ;
  # $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  }
 
 
  $html .= "</table>" ;

  $d3_data_countries =~ s/,\n$// ; 
  $html =~ s/WORLDMAP_D3_DATA/$d3_data_countries/ ;

# print $d3_data_countries ;
#  $html .= "<p><a name='more' id='more'></a><b>Share<\/b> is the percentage of requesting ip addresses (out of the world total) which originated from this country" .
#           "<br>&nbsp;Further percentages show per country share of $views_edits_lc per Wikipedia visited" ;
  if ($sample_rate > 1)
  { $html .= "<p>Countries are only included if the number of requests in the period exceeds " . ($cutoff_requests * $sample_rate) . "\n" ; } 
# . "($cutoff_requests matching records in 1:$sample_rate sampled log)" ; }
  $html .= "<p>Wikipedia languages are only listed for some country if the share of requests from that particular country to that specific Wikipedia exceeds $cutoff_percentage\%." ;
  if ($show_logcount)
  {
    $html .= "<p>The second column displays the actual <b>numbers of records</b> found in the 1:$sample_rate sampled log on which the percentage is based." ;
    if ($sample_rate > 1)
    { $html .= "<br>Multiply by $sample_rate for actual $views_edits_lc over the whole period of $months_recently months." ; }
    $html .= "<br>If the number of records in the sampled log does not reach the (arbitrary) number of 5 per sampled month, the percentage is flagged dark red to extra emphasize high inaccuracy." ;
  }

  $html .= "<p>Page requests by search engine crawlers (aka bots) are not included.\n" . 
           "Country meta data collected from <a href='//en.wikipedia.org/wiki/List_of_countries_by_population'>English Wikipedia</a>. " .
           "'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a>" ;
# if ($anomaly_found)
# { $html .= "<p><a id='anomaly' name='anomaly'>Probably anomaly caused by outdated <a href='//en.wikipedia.org/wiki/Regional_Internet_Registry'>Regional Internet Registry</a> administration.\n" ; }

  
  $html .= $colophon_ez ;
  $html =~ s/<a id='errata'.*?from now on.<\/font><p>// ; # Q&D fix: errata not on this report, which is not about historic data
# $html =~ s/<body bgcolor='#FFFFDD'>/<body>/ ; # Q#D fix: abandon Wikistats page coloring for reports to be continued after 2016  

  $index = &HtmlIndex (join '/ ', sort (@index_countries)) ;
  $html =~ s/INDEX/$index/ ;
  $html =~ s/http://g ;

  if (! $show_logcount)
  { &PrintHtml ($html, "$path_reports/$file_html_per_country_breakdown") ; }
  else
  { &PrintHtml ($html, "$path_reports/$file_html_per_country_breakdown_huge") ; }
}

sub WriteReportPerCountryTrends
{
  exit ; # deprecated, too unreliable

  &LogSub ("WriteReportPerCountryTrends\n") ;

  my ($title,$views_edits,$links) = @_ ;
  my ($link_country,$population,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot) ;
  my @index_languages ;
  my $views_edits_lc = lc $views_edits ;

  $html  = $header ;
  $html =~ s/WORLDMAP_D3// ;
  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/LINKS// ;
  $html =~ s/ALSO/$links/ ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_start - $requests_stop<\/b>/ ;
  $html =~ s/DATE// ;

  $html =~ s/\(last 12 months\)// ; # only report for all known months

  if ($views_edits eq 'Page Views')
  {
    $html .= "<p><font color=#800000>Nov 2011: For some countries the share of page views on the English Wikipedia was significantly higher in 2010 than in 2009 and 2011,<br>" .
           "especially in Q1 and Q2. We don't know yet what caused this, this might be an artifact. Please be cautious to draw conclusions from this.</font>" ;
  }

  $html .= "<p>'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a><p>\n" ;

  &AddNoticeSurvey (24) ;

  $html .= "<p><table border=1 width=800>INDEX\n" ;

  $html .= &HtmlWorldMapsFixed ;

  foreach $country (keys_sorted_by_value_num_desc %requests_per_country)
  {
    next if $requests_per_country {$country} < 50 * ($#quarters + 1) ;

    %requests_per_language = %{$requests_per_country_per_language {$country}} ;
    @languages = keys_sorted_by_value_num_desc %requests_per_language ;

    ($link_country,$icon,$population) = &CountryMetaInfo ($country) ;

    $html .= "<tr><th colspan=99 class=lh3><a id='$country' name='$country'></a><br>$icon $link_country</th></tr>\n" ;

    if ($views_edits eq 'Page Edits')
    { $rowspan = $#quarters+2 ; }
    else
    { $rowspan = $#quarters+3 ; }

    $html .= "<tr><th class=small>Quarter</th>[<th class=small>Total</th>]<th class=small>Share</th><th rowspan=$rowspan>&nbsp;</th>\n" ;
    for ($l = 0 ; $l < 10 ; $l++)
    {
      $language = $languages [$l] ;
      if ($out_languages {$language} ne "")
      { $language = $out_languages {$language} ; }
      if (length ($language) > 20)
      { $language =~ s/ .*$// ; }
      $html .= "<th class=c class=small>$language</th>\n" ;
      # print " [$language] " ;
    }
    $html .= "<th>other</th>\n" ;
    $html .= "</tr>\n" ;
    # print "\n" ;

    my $lines = 0 ;
    foreach $quarter (reverse @quarters)
    {
      next if $views_edits eq 'Page Edits' and $quarter =~ /2009.*?Q3/ ; # strange results, to be researched

      $line1 = "<tr>\n" ;
      $line2 = "<tr>\n" ;

      my $requests_this_country  = $requests_per_quarter_per_country {$quarter} {$country} ;
      my $requests_all_countries = $requests_per_quarter            {$quarter} ;

      $perc = 'n.a.' ;
      if ($requests_all_countries > 0)
      {
        $perc = &Percentage ($requests_this_country / $requests_all_countries) ;
        # print "$quarter: " . sprintf ("%9d", $requests_this_country) . " = $perc\% $country\n" ;
        $line1 .= "<th class=c nowrap>&nbsp;$quarter&nbsp;</th>[<td align=right>$requests_this_country</td>]<td align=center>$perc</td>" ;
        $line2 .= "<th nowrap>&nbsp;$quarter&nbsp;</th>[<td align=right>$requests_this_country</td>]<td align=center>$perc</td>" ;
      }

      $perc_tot = 0;
      for ($l = 0 ; $l < 10 ; $l++)
      {
        my $requests_this_language = $requests_per_quarter_per_country_per_language {$quarter} {$country} {$languages [$l]} ;
        my $requests_all_languages = $requests_per_quarter_per_country              {$quarter} {$country} ;
        $perc = 0 ;
        if ($requests_all_languages > 0)
        {
          $perc = &Percentage ($requests_this_language / $requests_all_languages) ;
          $perc_tot += $perc ;
        }
        # print "[" . sprintf ("%9d", $requests_this_language) . " = $perc\%]" ;
        if ($perc != 0)
        { $line2 .= "<td class=c><img src='yellowbar_hor.gif' width=$perc height=15></td>" ; }
        else
        { $line2 .= "<td class=l>&nbsp;</td>" ; }

        if (($country eq "Australia") && (($perc < 50) && ($perc > 5)))
        { $perc .= " <b><a href='#anomaly' onclick='alert(\"Probably incorrectly assigned to this country.\\nOutdated Regional Internet Registry (RIR) administration may have caused this.\")';><font color='#FF0000'>(*)</font></a></b>" ; $anomaly_found = $true ;}
        $line1 .= "<td class=c>[$requests_this_language]$perc</td>" ;
      }
      if ($perc_tot > 100) { $perc_tot = 100 ; }
      $perc_other = sprintf '%.1f', 100 - $perc_tot ;
      $line1 .= "<td class=c>$perc_other%</td>" ;

      $line1 .= "</tr>\n" ;
      $line2 .= "</tr>\n" ;
      $html .= $line1 ;
      if ($lines++ == $#quarters)
      { $html .= $line2 ; } # only for last quarter
    }

    if ($verbose)
    { push @index_countries, "<a href='#$country'>$country ($perc)</a> " ; }
    else
    { push @index_countries, "<a href='#$country'>$country</a> " ; }

  # print "\n" ;
  # $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  }
  $html .= "</table>" ;
  $html .= "<p><b>Share<\/b> is the percentage of requesting ip addresses (out of the world total) which originated from this country" .
           "<br>&nbsp;Further percentages show per country per quarter share of $views_edits_lc per Wikipedia visited" ;
  $html .= "<p>Countries are only included if the number of requests in the period exceeds 100,000 (100 matching records in 1:1000 sampled log)" ;
  $html .= "<br>Page requests by bots are not included. Also all ip addresses that occur more than once on a given day are discarded for that day." ;
  $html .= "<br> A few false negatives are taken for granted. " .
           "Country meta data collected from <a href='//en.wikipedia.org/wiki/List_of_countries_by_population'>English Wikipedia</a>. " .
           "'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a>" ;
  $html .= $colophon_ez ;

  $index = &HtmlIndex (join '/ ', sort (@index_countries)) ;
  $html =~ s/INDEX/$index/ ;

  &PrintHtml ($html, "$path_reports/$file_html_per_country_trends") ;
}

sub CorrectForMissingDays
{
  my ($period, $count, $code, $var) = @_ ;

  if ($missing_days {$period} > 0)
  {
    my $count_prev = $count ;
    $count = int (0.5 + $count * $correct_for_missing_days {$period}) ;
    if ($code =~ /us/i)
    { print "\nperiod $period: correct for ${missing_days {$period}} missing days = * ${correct_for_missing_days {$period}}, " .
            " e.g. for $code: $var $count_prev -> $count\n\n" ; }
  }
  return ($count) ;
}

sub OpenLog
{
# only shrink log when same log file is appended daily, is no longer the case
# $fileage  = -M "$path_reports/$file_log" ;
# if ($fileage > 5)
# {
#   open "FILE_LOG", "<", "$path_reports/$file_log" || abort ("Log file '$file_log' could not be opened.") ;
#   @log = <FILE_LOG> ;
#   close "FILE_LOG" ;
#   $lines = 0 ;
#   open "FILE_LOG", ">", "$path_reports/$file_log" || abort ("Log file '$file_log' could not be opened.") ;
#   foreach $line (@log)
#   {
#     if (++$lines >= $#log - 5000)
#     { print FILE_LOG $line ; }
#   }
#   close "FILE_LOG" ;
# }
# open "FILE_LOG", ">>", "$path_reports/$file_log" || abort ("Log file '$file_log' could not be opened.") ;
  open "FILE_LOG", ">>", "$path_log/$file_log" || abort ("Log file '$file_log' could not be opened.") ;
  &LogDetail ("\n\n===== Wikimedia Sampled Visitors Log Report / " . date_time_english (time) . " =====\n\n") ;
}

sub Normalize
{
  my $count = shift ;
  $count *= $multiplier ;
# if ($count < 1) { $count = 1 ; } -> do this at FormatCount
  return (sprintf ("%.2f", $count)) ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print FILE_LOG $msg ;
}

sub LogBreak
{
  &Log ("\n") ;
}

sub LogSub
{
  $msg = shift ;
  &Log ("> $msg") ;
}

sub LogDetail
{
  $msg = shift ;
  &Log (". $msg") ;
}

sub LogList
{
  $msg = shift ;
  &Log ("* $msg") ;
}

sub InitProjectNames
{
  &LogSub ("InitProjectNames\n") ;

  # copied from WikiReports.pl

  %wikipedias = (
# mediawiki=>"http://wikimediafoundation.org Wikimedia",
  nostalgia=>"http://nostalgia.wikipedia.org Nostalgia",
  sources=>"http://wikisource.org Old&nbsp;Wikisource",
  meta=>"http://meta.wikimedia.org Meta-Wiki",
  beta=>"http://beta.wikiversity.org Beta",
  species=>"http://species.wikipedia.org WikiSpecies",
  commons=>"http://commons.wikimedia.org Commons",
  foundation=>"http://wikimediafoundation.org Wikimedia&nbsp;Foundation",
  sep11=>"http://sep11.wikipedia.org In&nbsp;Memoriam",
  nlwikimedia=>"http://nl.wikimedia.org Wikimedia&nbsp;Nederland",
  plwikimedia=>"http://pl.wikimedia.org Wikimedia&nbsp;Polska",
  mediawiki=>"http://www.mediawiki.org MediaWiki",
  dewikiversity=>"http://de.wikiversity.org Wikiversit&auml;t",
  frwikiversity=>"http://fr.wikiversity.org Wikiversit&auml;t",
  wikimania2005=>"http://wikimania2005.wikimedia.org Wikimania 2005",
  wikimania2006=>"http://wikimania2006.wikimedia.org Wikimania 2006",
  aa=>"http://aa.wikipedia.org Afar",
  ab=>"http://ab.wikipedia.org Abkhazian",
  ace=>"http://ace.wikipedia.org Acehnese",
  af=>"http://af.wikipedia.org Afrikaans",
  ak=>"http://ak.wikipedia.org Akan", # was Akana
  als=>"http://als.wikipedia.org Alemannic", # was Elsatian
  am=>"http://am.wikipedia.org Amharic",
  an=>"http://an.wikipedia.org Aragonese",
  ang=>"http://ang.wikipedia.org Anglo-Saxon",
  ar=>"http://ar.wikipedia.org Arabic",
  arc=>"http://arc.wikipedia.org Aramaic",
  arz=>"http://arz.wikipedia.org Egyptian Arabic",
  as=>"http://as.wikipedia.org Assamese",
  ast=>"http://ast.wikipedia.org Asturian",
  av=>"http://av.wikipedia.org Avar", # was Avienan
  ay=>"http://ay.wikipedia.org Aymara",
  az=>"http://az.wikipedia.org Azeri", # was Azerbaijani
  ba=>"http://ba.wikipedia.org Bashkir",
  bar=>"http://bar.wikipedia.org Bavarian",
  bat_smg=>"http://bat-smg.wikipedia.org Samogitian",
  "bat-smg"=>"http://bat-smg.wikipedia.org Samogitian",
  bcl=>"http://bcl.wikipedia.org Central Bicolano",
  be=>"http://be.wikipedia.org Belarusian",
  "be-x-old"=>"http://be.wikipedia.org Belarusian (Tarashkevitsa)",
  be_x_old=>"http://be.wikipedia.org Belarusian (Tarashkevitsa)",
  bg=>"http://bg.wikipedia.org Bulgarian",
  bh=>"http://bh.wikipedia.org Bihari",
  bi=>"http://bi.wikipedia.org Bislama",
  bm=>"http://bm.wikipedia.org Bambara",
  bn=>"http://bn.wikipedia.org Bengali",
  bo=>"http://bo.wikipedia.org Tibetan",
  bpy=>"http://bpy.wikipedia.org Bishnupriya Manipuri",
  br=>"http://br.wikipedia.org Breton",
  bs=>"http://bs.wikipedia.org Bosnian",
  bug=>"http://bug.wikipedia.org Buginese",
  bxr=>"http://bxr.wikipedia.org Buryat",
  ca=>"http://ca.wikipedia.org Catalan",
  cbk_zam=>"http://cbk-zam.wikipedia.org Chavacano",
  "cbk-zam"=>"http://cbk-zam.wikipedia.org Chavacano",
  cdo=>"http://cdo.wikipedia.org Min Dong",
  ce=>"http://ce.wikipedia.org Chechen",
  ceb=>"http://ceb.wikipedia.org Cebuano",
  ch=>"http://ch.wikipedia.org Chamorro", # was Chamoru
  ckb=>"http://ckb.wikipedia.org Sorani",
  cho=>"http://cho.wikipedia.org Choctaw", # was Chotaw
  chr=>"http://chr.wikipedia.org Cherokee",
  chy=>"http://chy.wikipedia.org Cheyenne", # was Sets&ecirc;hest&acirc;hese
  co=>"http://co.wikipedia.org Corsican",
  cr=>"http://cr.wikipedia.org Cree",
  crh=>"http://crh.wikipedia.org Crimean Tatar",
  cs=>"http://cs.wikipedia.org Czech",
  csb=>"http://csb.wikipedia.org Cashubian", # was Kashubian
  cu=>"http://cv.wikipedia.org Old Church Slavonic",
  cv=>"http://cv.wikipedia.org Chuvash", # was Cavas
  cy=>"http://cy.wikipedia.org Welsh",
  da=>"http://da.wikipedia.org Danish",
  de=>"http://de.wikipedia.org German",
  diq=>"http://diq.wikipedia.org Zazaki",
  dk=>"http://dk.wikipedia.org Danish",
  dsb=>"http://dsb.wikipedia.org Lower Sorbian",
  dv=>"http://dv.wikipedia.org Divehi",
  dz=>"http://dz.wikipedia.org Dzongkha",
  ee=>"http://ee.wikipedia.org Ewe",
  el=>"http://el.wikipedia.org Greek",
  eml=>"http://eml.wikipedia.org Emilian-Romagnol",
  en=>"http://en.wikipedia.org English",
  eo=>"http://eo.wikipedia.org Esperanto",
  es=>"http://es.wikipedia.org Spanish",
  et=>"http://et.wikipedia.org Estonian",
  eu=>"http://eu.wikipedia.org Basque",
  ext=>"http://ext.wikipedia.org Extremaduran",
  fa=>"http://fa.wikipedia.org Persian",
  ff=>"http://ff.wikipedia.org Fulfulde",
  fi=>"http://fi.wikipedia.org Finnish",
  "fiu-vro"=>"http://fiu-vro.wikipedia.org Voro",
  fiu_vro=>"http://fiu-vro.wikipedia.org Voro",
  fj=>"http://fj.wikipedia.org Fijian",
  fo=>"http://fo.wikipedia.org Faroese", # was Faeroese
  fr=>"http://fr.wikipedia.org French",
  frp=>"http://frp.wikipedia.org Arpitan",
  fur=>"http://fur.wikipedia.org Friulian",
  fy=>"http://fy.wikipedia.org Frisian",
  ga=>"http://ga.wikipedia.org Irish",
  gan=>"http://gan.wikipedia.org Gan",
  gay=>"http://gay.wikipedia.org Gayo",
  gd=>"http://gd.wikipedia.org Scots Gaelic", # was Scottish Gaelic
  gl=>"http://gl.wikipedia.org Galician", # was Galego
  glk=>"http://glk.wikipedia.org Gilaki",
  gn=>"http://gn.wikipedia.org Guarani",
  got=>"http://got.wikipedia.org Gothic",
  gu=>"http://gu.wikipedia.org Gujarati",
  gv=>"http://gv.wikipedia.org Manx", # was Manx Gaelic
  ha=>"http://ha.wikipedia.org Hausa",
  hak=>"http://hak.wikipedia.org Hakka",
  haw=>"http://haw.wikipedia.org Hawai'ian", # was Hawaiian
  he=>"http://he.wikipedia.org Hebrew",
  hi=>"http://hi.wikipedia.org Hindi",
  hif=>"http://hif.wikipedia.org Fiji Hindi",
  ho=>"http://ho.wikipedia.org Hiri Motu",
  hr=>"http://hr.wikipedia.org Croatian",
  hsb=>"http://hsb.wikipedia.org Upper Sorbian",
  ht=>"http://ht.wikipedia.org Haitian",
  hu=>"http://hu.wikipedia.org Hungarian",
  hy=>"http://hy.wikipedia.org Armenian",
  hz=>"http://hz.wikipedia.org Herero",
  ia=>"http://ia.wikipedia.org Interlingua",
  iba=>"http://iba.wikipedia.org Iban",
  id=>"http://id.wikipedia.org Indonesian",
  ie=>"http://ie.wikipedia.org Interlingue",
  ig=>"http://ig.wikipedia.org Igbo",
  ii=>"http://ii.wikipedia.org Yi",
  ik=>"http://ik.wikipedia.org Inupiak",
  ilo=>"http://ilo.wikipedia.org Ilokano",
  io=>"http://io.wikipedia.org Ido",
  is=>"http://is.wikipedia.org Icelandic",
  it=>"http://it.wikipedia.org Italian",
  iu=>"http://iu.wikipedia.org Inuktitut",
  ja=>"http://ja.wikipedia.org Japanese",
  jbo=>"http://jbo.wikipedia.org Lojban",
  jv=>"http://jv.wikipedia.org Javanese",
  ka=>"http://ka.wikipedia.org Georgian",
  kaa=>"http://kaa.wikipedia.org Karakalpak",
  kab=>"http://ka.wikipedia.org Kabyle",
  kaw=>"http://kaw.wikipedia.org Kawi",
  kg=>"http://kg.wikipedia.org Kongo",
  ki=>"http://ki.wikipedia.org Kikuyu",
  kj=>"http://kj.wikipedia.org Kuanyama", # was Otjiwambo
  kk=>"http://kk.wikipedia.org Kazakh",
  kl=>"http://kl.wikipedia.org Greenlandic",
  km=>"http://km.wikipedia.org Khmer", # was Cambodian
  kn=>"http://kn.wikipedia.org Kannada",
  ko=>"http://ko.wikipedia.org Korean",
  kr=>"http://kr.wikipedia.org Kanuri",
  ks=>"http://ks.wikipedia.org Kashmiri",
  ksh=>"http://ksh.wikipedia.org Ripuarian",
  ku=>"http://ku.wikipedia.org Kurdish",
  kv=>"http://kv.wikipedia.org Komi",
  kw=>"http://kw.wikipedia.org Cornish", # was Kornish
  ky=>"http://ky.wikipedia.org Kirghiz",
  la=>"http://la.wikipedia.org Latin",
  lad=>"http://lad.wikipedia.org Ladino",
  lb=>"http://lb.wikipedia.org Luxembourgish", # was Letzeburgesch
  lbe=>"http://lbe.wikipedia.org Lak",
  lg=>"http://lg.wikipedia.org Ganda",
  li=>"http://li.wikipedia.org Limburgish",
  lij=>"http://lij.wikipedia.org Ligurian",
  lmo=>"http://lmo.wikipedia.org Lombard",
  ln=>"http://ln.wikipedia.org Lingala",
  lo=>"http://lo.wikipedia.org Laotian",
  ls=>"http://ls.wikipedia.org Latino Sine Flexione",
  lt=>"http://lt.wikipedia.org Lithuanian",
  lv=>"http://lv.wikipedia.org Latvian",
  mad=>"http://mad.wikipedia.org Madurese",
  mak=>"http://mak.wikipedia.org Makasar",
  map_bms=>"http://map-bms.wikipedia.org Banyumasan",
  "map-bms"=>"http://map-bms.wikipedia.org Banyumasan",
  mdf=>"http://mdf.wikipedia.org Moksha",
  mg=>"http://mg.wikipedia.org Malagasy",
  mh=>"http://mh.wikipedia.org Marshallese",
  mhr=>"http://mhr.wikipedia.org Eastern Mari",
  mi=>"http://mi.wikipedia.org Maori",
  min=>"http://min.wikipedia.org Minangkabau",
  minnan=>"http://minnan.wikipedia.org Minnan",
  mk=>"http://mk.wikipedia.org Macedonian",
  ml=>"http://ml.wikipedia.org Malayalam",
  mn=>"http://mn.wikipedia.org Mongolian",
  mo=>"http://mo.wikipedia.org Moldavian",
  mr=>"http://mr.wikipedia.org Marathi",
  ms=>"http://ms.wikipedia.org Malay",
  mt=>"http://mt.wikipedia.org Maltese",
  mus=>"http://mus.wikipedia.org Muskogee",
  mwl=>"http://mwl.wikipedia.org Mirandese",
  my=>"http://my.wikipedia.org Burmese",
  myv=>"http://myv.wikipedia.org Erzya",
  mzn=>"http://mzn.wikipedia.org Mazandarani",
  na=>"http://na.wikipedia.org Nauruan", # was Nauru
  nah=>"http://nah.wikipedia.org Nahuatl",
  nap=>"http://nap.wikipedia.org Neapolitan",
  nds=>"http://nds.wikipedia.org Low Saxon",
  nds_nl=>"http://nds-nl.wikipedia.org Dutch Low Saxon",
  "nds-nl"=>"http://nds-nl.wikipedia.org Dutch Low Saxon",
  ne=>"http://ne.wikipedia.org Nepali",
  new=>"http://new.wikipedia.org Nepal Bhasa",
  ng=>"http://ng.wikipedia.org Ndonga",
  nl=>"http://nl.wikipedia.org Dutch",
  nov=>"http://nov.wikipedia.org Novial",
  nrm=>"http://nrm.wikipedia.org Norman",
  nn=>"http://nn.wikipedia.org Nynorsk", # was Neo-Norwegian
  no=>"http://no.wikipedia.org Norwegian",
  nv=>"http://nv.wikipedia.org Navajo", # was Avayo
  ny=>"http://ny.wikipedia.org Chichewa",
  oc=>"http://oc.wikipedia.org Occitan",
  om=>"http://om.wikipedia.org Oromo",
  or=>"http://or.wikipedia.org Oriya",
  os=>"http://os.wikipedia.org Ossetic",
  pa=>"http://pa.wikipedia.org Punjabi",
  pag=>"http://pag.wikipedia.org Pangasinan",
  pam=>"http://pam.wikipedia.org Kapampangan",
  pap=>"http://pap.wikipedia.org Papiamentu",
  pdc=>"http://pdc.wikipedia.org Pennsylvania German",
  pi=>"http://pi.wikipedia.org Pali",
  pih=>"http://pih.wikipedia.org Norfolk",
  pl=>"http://pl.wikipedia.org Polish",
  pms=>"http://pms.wikipedia.org Piedmontese",
  pnb=>"http://pnb.wikipedia.org Western Panjabi",
  pnt=>"http://pnt.wikipedia.org Pontic",
  ps=>"http://ps.wikipedia.org Pashto",
  pt=>"http://pt.wikipedia.org Portuguese",
  qu=>"http://qu.wikipedia.org Quechua",
  rm=>"http://rm.wikipedia.org Romansh", # was Rhaeto-Romance
  rmy=>"http://rmy.wikipedia.org Romani",
  rn=>"http://rn.wikipedia.org Kirundi",
  ro=>"http://ro.wikipedia.org Romanian",
  roa_rup=>"http://roa-rup.wikipedia.org Aromanian",
  "roa-rup"=>"http://roa-rup.wikipedia.org Aromanian",
  roa_tara=>"http://roa-tara.wikipedia.org Tarantino",
  "roa-tara"=>"http://roa-tara.wikipedia.org Tarantino",
  ru=>"http://ru.wikipedia.org Russian",
  ru_sib=>"http://ru-sib.wikipedia.org Siberian",
  "ru-sib"=>"http://ru-sib.wikipedia.org Siberian",
  rw=>"http://rw.wikipedia.org Kinyarwanda",
  sa=>"http://sa.wikipedia.org Sanskrit",
  sah=>"http://sah.wikipedia.org Sakha",
  sc=>"http://sc.wikipedia.org Sardinian",
  scn=>"http://scn.wikipedia.org Sicilian",
  sco=>"http://sco.wikipedia.org Scots",
  sd=>"http://sd.wikipedia.org Sindhi",
  se=>"http://se.wikipedia.org Northern Sami",
  sg=>"http://sg.wikipedia.org Sangro",
  sh=>"http://sh.wikipedia.org Serbo-Croatian",
  si=>"http://si.wikipedia.org Sinhala", # was Singhalese
  simple=>"http://simple.wikipedia.org Simple English",
  sk=>"http://sk.wikipedia.org Slovak",
  sl=>"http://sl.wikipedia.org Slovene",
  sm=>"http://sm.wikipedia.org Samoan",
  sn=>"http://sn.wikipedia.org Shona",
  so=>"http://so.wikipedia.org Somali", # was Somalian
  sq=>"http://sq.wikipedia.org Albanian",
  sr=>"http://sr.wikipedia.org Serbian",
  srn=>"http://srn.wikipedia.org Sranan",
  ss=>"http://ss.wikipedia.org Siswati",
  st=>"http://st.wikipedia.org Sesotho",
  stq=>"http://stq.wikipedia.org Saterland Frisian",
  su=>"http://su.wikipedia.org Sundanese",
  sv=>"http://sv.wikipedia.org Swedish",
  sw=>"http://sw.wikipedia.org Swahili",
  szl=>"http://szl.wikipedia.org Silesian",
  ta=>"http://ta.wikipedia.org Tamil",
  te=>"http://te.wikipedia.org Telugu",
  test=>"http://test.wikipedia.org Test",
  tet=>"http://tet.wikipedia.org Tetum",
  tg=>"http://tg.wikipedia.org Tajik",
  th=>"http://th.wikipedia.org Thai",
  ti=>"http://ti.wikipedia.org Tigrinya",
  tk=>"http://tk.wikipedia.org Turkmen",
  tl=>"http://tl.wikipedia.org Tagalog",
  tlh=>"http://tlh.wikipedia.org Klingon", # was Klignon
  tn=>"http://tn.wikipedia.org Setswana",
  to=>"http://to.wikipedia.org Tongan",
  tokipona=>"http://tokipona.wikipedia.org Tokipona",
  tpi=>"http://tpi.wikipedia.org Tok Pisin",
  tr=>"http://tr.wikipedia.org Turkish",
  ts=>"http://ts.wikipedia.org Tsonga",
  tt=>"http://tt.wikipedia.org Tatar",
  tum=>"http://tum.wikipedia.org Tumbuka",
  turn=>"http://turn.wikipedia.org Turnbuka",
  tw=>"http://tw.wikipedia.org Twi",
  ty=>"http://ty.wikipedia.org Tahitian",
  udm=>"http://udm.wikipedia.org Udmurt",
  ug=>"http://ug.wikipedia.org Uighur",
  uk=>"http://uk.wikipedia.org Ukrainian",
  ur=>"http://ur.wikipedia.org Urdu",
  uz=>"http://uz.wikipedia.org Uzbek",
  ve=>"http://ve.wikipedia.org Venda", # was Lushaka
  vec=>"http://vec.wikipedia.org Venetian",
  vi=>"http://vi.wikipedia.org Vietnamese",
  vls=>"http://vls.wikipedia.org West Flemish",
  vo=>"http://vo.wikipedia.org Volap&uuml;k",
  wa=>"http://wa.wikipedia.org Walloon",
  war=>"http://war.wikipedia.org Waray-Waray",
  wo=>"http://wo.wikipedia.org Wolof",
  wuu=>"http://wuu.wikipedia.org Wu",
  xal=>"http://xal.wikipedia.org Kalmyk",
  xh=>"http://xh.wikipedia.org Xhosa",
  yi=>"http://yi.wikipedia.org Yiddish",
  yo=>"http://yo.wikipedia.org Yoruba",
  za=>"http://za.wikipedia.org Zhuang",
  zea=>"http://zea.wikipedia.org Zealandic",
  zh=>"http://zh.wikipedia.org Chinese",
  zh_min_nan=>"http://zh-min-nan.wikipedia.org Min Nan",
  "zh-min-nan"=>"http://zh-min-nan.wikipedia.org Min Nan",
  zh_classical=>"http://zh-classical.wikipedia.org Classical Chinese",
  "zh-classical"=>"http://zh-classical.wikipedia.org Classical Chinese",
  zh_yue=>"http://zh-yue.wikipedia.org Cantonese",
  "zh-yue"=>"http://zh-yue.wikipedia.org Cantonese",
  zu=>"http://zu.wikipedia.org Zulu",
  zz=>"&nbsp; All&nbsp;languages",
  zzz=>"&nbsp; All&nbsp;languages except English"
  );

  foreach $key (keys %wikipedias)
  {
    my $wikipedia = $wikipedias {$key} ;
    $out_urls      {$key} = $wikipedia ;
    $out_languages {$key} = $wikipedia ;
    $out_urls      {$key} =~ s/(^[^\s]+).*$/$1/ ;
    $out_languages {$key} =~ s/^[^\s]+\s+(.*)$/$1/ ;
    $out_article   {$key} = "http://en.wikipedia.org/wiki/" . $out_languages {$key} . "_language" ;
    $out_article   {$key} =~ s/ /_/g ;
    $out_urls      {$key} =~ s/(^[^\s]+).*$/$1/ ;
    $out_urls      {$key} =~ s/http:// ;
  }
  $out_languages {"www"} = "Portal" ;
}


sub Percentage
{
  my $perc = shift ;
  $perc = 100 * $perc ;
     if ($perc == 100)     { $perc = '100%' ; }
     if ($perc == 0)       { $perc = '&nbsp;' ; }
  elsif ($perc < 0.00001) { $perc = '0.00001%' ; }
  elsif ($perc < 0.0001)  { $perc = sprintf ("%.5f%", $perc) ; }
  elsif ($perc < 0.001)   { $perc = sprintf ("%.4f%", $perc) ; }
  elsif ($perc < 0.01)    { $perc = sprintf ("%.3f%", $perc) ; }
  elsif ($perc < 0.1)     { $perc = sprintf ("%.2f%", $perc) ; }
  else                    { $perc = sprintf ("%.1f%", $perc) ; }
  return ($perc) ;
}

sub ReadWikipediaCountriesByPopulation
{
  &LogSub ("ReadWikipediaCountriesByPopulation\n") ;
  my $url = 'http://en.wikipedia.org/wiki/List_of_countries_by_population';
  $html = get $url || abort ("Timed out!") ;

# open TEST, '<', 'List_of_countries_by_population.html' ;
# @lines = <TEST> ;
# $html = join "\n", @lines ;
# close TEST ;

  # split file on <tr>'s, remove all behind </tr>
  $html =~ s/\n/\\n/gs ;
  foreach $line (split "(?=<tr)", $html)
  {
    next if $line !~ /^<tr/ ;
    next if $line !~ /class=\"flagicon\"/ ;

    $line =~ s/(?<=<\/tr>).*$// ;
  # print "$line\n\n" ;

    @cells = split "(?=<td)", $line ;
   # foreach $cell (@cells)
   # { print "CELL $cell\n" ; }

    if ($cells [2] =~ /<img /)
    {
      $icon = $cells [2] ;
      $icon =~ s/srcset=\"[^\"]+\"// ;
      $icon =~ s/^.*?(<img[^>]*>).*$/$1/ ;
      $icon =~ s/class=\"[^\"]*\"// ;
      $icon =~ s/\s*\/>/>/ ;
      $icon =~ s/http:// ; 
    # print "ICON '$icon'\n" ;
    }
    else
    { $icon = "n.a." ; }

    if ($cells [2] =~ /title/)
    {
      $country = $cells [2] ;
      $country =~ s/^.*?<a [^>]*>([^<]*)<.*$/$1/ ;
      # print "COUNTRY '$country'\n" ;
    }
    else
    { $title = "n.a." ; }

    if ($cells [2] =~ /<a /)
    {
      $link = $cells [2] ;
      $link =~ s/^.*?(<a [^>]*>.*?<\/a>).*$/$1/ ;
      $link =~ s/\/wiki/http:\/\/en.wikipedia.org\/wiki/ ;
      # print "LINK '$link'\n" ;
    }
    else
    { $title = "n.a." ; }

    ($population = $cells [3]) =~ s/<td[^>]*>(.*?)<.*$/$1/, $population =~ s/,/_/g ;
    # print "POP $population\n\n" ;

    $country =~ s/,/&comma;/g ;
    $link    =~ s/,/&comma;/g ;
    $icon    =~ s/,/&comma;/g ;

    $country =~ s/Bosnia-Herzegovina/Bosnia and Herzegovina/ ;
    $country =~ s/C.*.+te d'Ivoire/Cote d'Ivoire/ ;
    $country =~ s/Macao/Macau/ ; # will be changed back later
    $country =~ s/Samoa/American Samoa/ ;
    $country =~ s/Timor Leste/Timor-Leste/ ;
    $country =~ s/UAE/United Arab Emirates/ ;
    $country =~ s/Korea, South/South Korea/ ;
    $country =~ s/Congo, Democratic Republic of/Democratic Republic of the Congo/ ;
  # $country =~ s/Congo, Democratic Republic of/Dem. Rep. Congo/ ;

    $country =~ s/Congo, Republic of/Republic of the Congo/ ;
  # $country =~ s/Congo, Republic of/Rep. Congo/ ;

    $country =~ s/Macedonia, Republic of/Republic of Macedonia/ ;
    $country =~ s/Gambia, The/Gambia/ ;
    $country =~ s/Bahamas, The/The Bahamas/ ;
    $country =~ s/Myanmar/Burma/ ;
    $country =~ s/Republic of Ireland/Ireland/ ;
    $country =~ s/Palestin.*/Palestinian Territories/ ;
    $country =~ s/Georgia_.*country.*/Georgia/ ;
    $country =~ s/,/&comma;/g ;

    # print "country: $country\nlink: $link\npopulation: $population\nconnected: $connected\nicon: $icon\n\n" ;
    $countries {$country} = "$country,$link,$population,connected,$icon\n" ;
  }
}

sub ReadWikipediaCountriesByInternetUsers
{
  &LogSub ("ReadWikipediaCountriesByInternetUsers\n") ;

  $url = 'http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users';
  $html = get $url || abort ("Timed out!") ;

  # split file on <tr>'s, remove all behind </tr>
  $html =~ s/\n/\\n/gs ;
  foreach $line (split "(?=<tr)", $html)
  {
    next if $line !~ /^<tr/ ;
    next if $line !~ /class=\"flagicon\"/ ;

    $line =~ s/(?<=<\/tr>).*$// ;
  # print "$line\n\n" ;

    @cells = split "(?=<td)", $line ;

    if ($cells [1] =~ /title/)
    {
      $country = $cells [1] ;
      $country =~ s/^.*?title=\"([^\"]+)".*$/$1/ ;
    # print "COUNTRY '$country'\n" ;
    }
    else
    { $country = "n.a." ; }

    $country =~ s/Bosnia-Herzegovina/Bosnia and Herzegovina/ ;
    $country =~ s/C.*.+te d'Ivoire/Cote d'Ivoire/ ;
    $country =~ s/Macao/Macau/ ; # will be changed back later
    $country =~ s/Samoa/American Samoa/ ;
    $country =~ s/Timor Leste/Timor-Leste/ ;
    $country =~ s/UAE/United Arab Emirates/ ;
    $country =~ s/Korea, South/South Korea/ ;
    $country =~ s/Congo, Democratic Republic of/Democratic Republic of the Congo/ ;
    $country =~ s/Congo, Republic of/Republic of the Congo/ ;
  # $country =~ s/Congo, Democratic Republic of/Dem. Rep. Congo/ ;
  # $country =~ s/Congo, Republic of/Rep. Congo/ ;
  # $country =~ s/Macedonia, Republic of/Macedonia/ ;
    $country =~ s/Gambia, The/Gambia/ ;
    $country =~ s/Bahamas, The/The Bahamas/ ;
    $country =~ s/Republic of Ireland/Ireland/ ;
    $country =~ s/Republic of Macedonia/Macedonia/ ;
    $country =~ s/Georgia.*country.*/Georgia/ ;
    $country =~ s/The Gambia/Gambia/ ;
    $country =~ s/Palestin.*/Palestinian Territories/ ;
    $country =~ s/Myanmar/Burma/ ;
    $country =~ s/,/&comma;/g ;

    $connected = $cells [2] ;
    $connected =~ s/<td[^>]*>(.*?)<.*$/$1/, $connected =~ s/,/_/g ;
    # print "POP $population\n\n" ;

    # print "Country: $country\nconnected: '$connected'\n\n" ;

    $countries {$country} =~ s/connected/$connected/ ;
  }

  &LogDetail ("Metric 'connected' unknown for:\n\n") ;
  foreach $country (sort keys %countries)
  {
    $data = $countries {$country} ;

    if ($data =~ /connected/)
    { &LogDetail ("$country\n") ; }
  }

  &LogDetail ("Write $path_meta/$file_csv_country_meta_info\n\n") ;
  open COUNTRY_META_INFO, '>', "$path_meta/$file_csv_country_meta_info" ;
  foreach $country (sort keys %countries)
  { print COUNTRY_META_INFO $countries {$country} ; }
  close COUNTRY_META_INFO ;
}

sub GetLanguageInfo
{
  my $language = shift ;
  my ($language_name,$anchor_language) ;
  $language_name = "$language (?)" ;
  if ($out_languages {$language} ne "")
  { $language_name = $out_languages {$language} ; }
  ($anchor_language = $language_name) =~ s/ /_/g ;
  return ($language_name,$anchor_language) ;
}

sub CountryMetaInfo
{
  my $country = shift ;
  $country =~ s/"//g ;
  my ($link_country,$icon,$population) ;
  if ($country_meta_info {$country}  eq "")
  {
    $country_meta_info_not_found_reported {$country} ++ ;
    if ($country_meta_info_not_found_reported {$country} == 1)
    { &LogDetail ("Meta info not found for country $country\n") ; }
    $link_country = $country ;
    return ($country,'','..','..') ;
  }
  else
  {
    ($link_country,$population,$connected,$icon) = split ',', $country_meta_info {$country} ;
    $population =~ s/_//g ;
    $connected =~ s/_//g ;
    $link_country =~ s/&comma;/,/g ;
    $icon =~ s/&comma;/,/g ;
    $icon =~ s/>/ border=1>/ ;
    return ($link_country,$icon,$population,$connected) ;
  }
}

sub i2KM
{
  $out_billion  = 'G' ;
  $out_million  = 'M' ;
  $out_thousand = 'K' ;

  my $v = shift ;

  if ($v == 0)
  { return ("&nbsp;") ; }
  
  if ($v >= 100000000000)
  {
    $v = sprintf ("%.0f",($v / 1000000000)) . "&nbsp;" . $out_billion ;
    $v =~ s/(\d+?)(\d\d\d[^\d])/$1,$2/ ;
  }
  elsif ($v >= 1000000000)
  { $v = sprintf ("%.1f",($v / 1000000000)) . "&nbsp;" . $out_billion ; }
  elsif ($v >= 100000000)
  {
    $v = sprintf ("%.0f",($v / 1000000)) . "&nbsp;" . $out_million ;
    $v =~ s/(\d+?)(\d\d\d[^\d])/$1,$2/ ;
  }
  elsif ($v >= 1000000)
  { $v = sprintf ("%.1f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 10000)
  { $v = sprintf ("%.0f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  elsif ($v >= 1000)
  { $v = sprintf ("%.1f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  return ($v) ;
}

sub i2KM2
{
  $out_million  = 'M' ;
  $out_thousand = 'K' ;

  my $v = shift ;
  return $v if $v !~ /^\d*$/ ;

#  return (sprintf ("%.1f",$v/1000000)) ;
  if ($v == 0)
  { return ("&nbsp;") ; }
  if ($v >= 10000000)
  { $v = sprintf ("%.0f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 1000000)
  { $v = sprintf ("%.1f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 1000)
  { $v = sprintf ("%.0f",($v / 1000)) . "&nbsp;" . $out_thousand ; }
  return ($v) ;
}

#   format: function(s) { return $.tablesorter.formatFloat(s.replace(/<[^>]*>/g,"").replace(/\\&nbsp\\;/g,"").replace(/M/i,"000000").replace(/&#1052;/,"000000").replace(/K/i,"000").replace(/&#1050;/i,"000")); },

sub UnLink
{
  my ($links,$index) = @_ ;
  # print "\n\nUnLink $index\n\n" ;
  my @segments = split '(?=<a )', $links ;
  # print "SEGMENT 1 $segments[$index]\n" ;
  $segments [$index] =~ s/^.*?<a .*?>([^<]*)<\/a>/<font color=#008000><b>$1<\/b><\/font>/ ;
  # print "SEGMENT 2 $segments[$index]\n" ;
  $links = join '', @segments ;
  return ($links) ;
}

sub PrintHtml
{
  ($html, $path) = @_ ;

# what was this for? I forgot
#  $verbose = $false ;
#  if ($verbose)
#  { $html =~ s/\[([^\]]*)\]/$1/g ; }
#  else
#  { $html =~ s/\[([^\]]*)\]//g ; }

  $html =~ s/and images// ; # all data [and images] onthis page are in the public domain
  open  HTML_OUT, '>', $path ;
  print HTML_OUT $html ;
  close HTML_OUT ;

  $ago = -M $path ;
  &Log ("Html file printed: $path\n") ;

}

sub PrintCsv
{
  ($csv, $path) = @_ ;

  open  HTML_CSV, '>', $path ;
  print HTML_CSV $csv ;
  close HTML_CSV ;
}

sub HtmlHead
{
# substitute      this                                with          this
  $regexp_from1 = '/(\d)(\d\d\d)$/' ;                 $regexp_to1 = '"$1,$2"' ;
  $regexp_from2 = '/(\d)(\d\d\d)(\d\d\d)$/' ;         $regexp_to2 = '"$1,$2,$3"' ;
  $regexp_from3 = '/(\d)(\d\d\d)(\d\d\d)(\d\d\d)$/' ; $regexp_to3 = '"$1,$2,$3,$4"' ;
  $regexp_from4 = '/(\d)(\d\d\d)\&/' ;                $regexp_to4 = '"$1,$2\&"' ;

  my $html = <<__HTML_HEAD__ ;

<!DOCTYPE FILE_HTML PUBLIC '-//W3C//DTD FILE_HTML 4.01 Transitional//EN' 'http://www.w3.org/TR/html4/loose.dtd'>
<html lang='en'>

<head>

<title>TITLE</title>

<meta http-equiv='Content-type' content='text/html; charset=iso-8859-1'>
<meta name='robots' content='index,follow'>
WORLDMAP_D3
<style type='text/css'>
<!--
body  {font-family:arial,sans-serif; font-size:12px }
h2    {margin:0px 0px 3px 0px; font-size:18px}
table {font-size:12px ;}
td    {white-space:wrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:middle}

tr.bubbles         {font-family:arial,sans-serif; font-size:11px; border:none} 
tr.bubbles_odd  td {font-size:11px; border:none} 
tr.bubbles_odd  th {font-size:11px; border:none} 
tr.bubbles      th {font-size:14px; border:none} 
tr.bubbles_even td {font-size:11px; border:none; background-color:#EEE ; } 
tr.bubbles_even th {font-size:11px; border:none; background-color:#EEE ; } 
 
td.hl   {text-align:left;vertical-align:top;}
td.hr   {text-align:right;vertical-align:top;}
td.hc   {text-align:center;vertical-align:top;}
td.r    {text-align:right;  border: inset 1px #FFFFFF}
td.c    {text-align:center; border: inset 1px #FFFFFF}
td.l    {text-align:left;   border: inset 1px #FFFFFF}
td.lt   {text-align:left;   border: inset 1px #FFFFFF ; vertical-align:top}
td.rt   {text-align:right;  border: inset 1px #FFFFFF ; vertical-align:top}
th.lnb  {text-align:left;   border: none; white-space:nowrap}
td.lnb  {text-align:left;   border: none; white-space:nowrap}
td.cnb  {text-align:center; border: none; white-space:nowrap}
td.rnb  {text-align:right;  border: none; white-space:nowrap}
th.cnb  {text-align:center; border: none; white-space:nowrap}

th       {white-space:nowrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:top ; font-width:bold}
th.small {white-space:wrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:11px ; vertical-align:top ; font-width:bold}
th.c     {text-align:center; border: inset 1px #FFFFFF}
th.l     {text-align:left;   border: inset 1px #FFFFFF}
th.r     {text-align:right;  border: inset 1px #FFFFFF}
th.lh3   {text-align:left;   border: inset 1px #FFFFFF ; font-size:14px}

a:link    {color:blue;    text-decoration:none;}
a:visited {color:#0000FF; text-decoration:none;}
a:active  {color:#0000FF; text-decoration:none;}
a:hover   {color:#FF00FF; text-decoration:underline}

img a:link    {color:#CCCCFF; text-decoration:none;}
img a:visited {color:#CCCCFF; text-decoration:none;}
img a:active  {color:#CCCCFF; text-decoration:none;}
img a:hover   {color:#FF00FF; text-decoration:none}
-->
</style>

<script>

var calls = 0 ;

var show_count_short              = (getCookie ('show_count_short') == 'true') || (getCookie ('show_count_short') == '') ;
var show_count_mode               = (getCookie ('select_period') || 0) ;
var show_count_monthly_normalized = (show_count_mode == 0) ;
var show_count_monthly_raw        = (show_count_mode == 1) ;
var show_count_daily              = (show_count_mode == 2) ;
var show_percentage               = (getCookie ('show_perc') == 'true') ;

var char_million  = 'M' ;
var char_thousand = 'k' ;
var nbsp = '&nbsp;' ;
var checked = false;
var element ;
var index ;

window.onload =
  function()
  {
    // alert ('window.onload') ;
    // alert (document.cookie) ;
    checked = getCookie ('show_count_short') ;
    element = document.getElementById ('form_show_count_short');

    if (checked == 'false')
    { element.checked = false ; show_count_short = false ; }
    else
    { element.checked = true ; show_count_short = true ; }

    checked = getCookie('show_perc') ;

    index = getCookie ('select_period') || 0 ;

    element = document.getElementById ('form_select_period');
    element.selectedIndex = parseInt(index);
  }

function setCookie (name, value, expires, path, domain, secure)
{
  var curCookie = name + "=" + escape(value) + ((expires) ? "; expires=" + expires.toGMTString() : "") + ((path) ? "; path=" + path : "") + ((domain) ? "; domain=" + domain : "") + ((secure) ? "; secure" : "");
  document.cookie = curCookie;
}

function getCookie (name)
{
  var prefix = name + "=" ;
  var cookieStartIndex = document.cookie.indexOf (prefix);
  if (cookieStartIndex == -1)
  { return "" ; }
  var cookieEndIndex = document.cookie.indexOf (";", cookieStartIndex + prefix.length);
  if (cookieEndIndex == -1)
  { cookieEndIndex = document.cookie.length ; }
  result = document.cookie.substring (cookieStartIndex + prefix.length, cookieEndIndex);
  return unescape (result) ;
}


function refreshPage ()
{
  // alert ('refreshPage') ;
  var element = document.getElementById ('form_select_period');

  if (element.selectedIndex == 3)
  {
  setCookie ('select_period', (getCookie ('select_period') || 0) + 10) ;
  }
  else
  {
  setCookie ('select_period', element.selectedIndex) ;
  }

  var element = document.getElementById ('form_show_count_short');
  if (element.checked)
  { setCookie ('show_count_short', 'true') ; }
  else
  { setCookie ('show_count_short', 'false') ; }

  SHOWPERC

  // alert (document.cookie) ;
  window.location.reload();
}

function showCount (count, percentage)
{
  //  if (++ calls == 1)
  // { alert ('showCount() show_count_short '+show_count_short) ; }

  if (days_in_month == 0) // workaround, should not happen 
  { days_in_month = 30 ; }

  if (count == 0)
  { count = '-' ; }

  else if (show_count_daily)
  { ; }
  else if (show_count_monthly_normalized)
  { count *= 30 ; }
  else if (show_count_monthly_raw)
  { count *= days_in_month ; }

  if (show_count_short)
  {
    if (count >= 100000000)
    { count = Math.round (count/1000000) + nbsp + char_million ; }
    else if (count >= 1000000)
    { count = (Math.round  (count/100000) / 10) + nbsp + char_million ; }
    else if (count >= 10000)
    { count = Math.round  (count/1000) + nbsp + char_thousand ; }
    else if (count >= 999)
    { count = (Math.round  (count/100) / 10) + nbsp + char_thousand ; }
    else
    { count = Math.round (count) ; }
    count += '' ; // make string
    count = count.replace ($regexp_from4,$regexp_to4) ;
  }
  else
  {
    // add 1000 separators
    count += '' ; // make string
    count = count.replace ($regexp_from3,$regexp_to3) ;
    count = count.replace ($regexp_from2,$regexp_to2) ;
    count = count.replace ($regexp_from1,$regexp_to1) ;
  }

  if (show_percentage && percentage != '' && count != '-')
  {
    count = percentage ;
  }

  document.write (count) ;
}

</script>

__HTML_HEAD__
  return ($html) ;
}

sub HtmlFormBase
{
  my $html = <<__HTML_FORM__ ;

<table width=100%>
<tr>
<td class=hl>
  <h2>HEADER</h2>
  <b>DATE</b>
</td>
<td class=hr>
<form name = 'form'>
<table>
<tr><td class=hl>
  <select name='period' id='form_select_period' size='1' onchange='refreshPage()'>
    <option value='1'>Monthly requests, normalized</option>
    <option value='2'>Monthly requests, raw</option>
    <option value='3'>Average daily requests</option>
  </select>

  <input type='checkbox' id='form_show_count_short' onchange='refreshPage()' /><strike>000</strike> &rArr; k

  <input type='button' value=' Archive ' onclick='window.location=\"//stats.wikimedia.org/archive/squid_reports\"'>
  <input type='button' value=' Wikimedia Statistics ' onclick='window.location=\"//stats.wikimedia.org\"'>
</td></tr>
<tr><td class=hl>PERCOPT</td></tr></table>
</form>
  </td>
  </tr>
</table>

__HTML_FORM__

return ($html) ;

}

sub HtmlForm
{
   my $html = &HtmlFormBase ;
   $html =~ s/PERCOPT/<!--<input type='checkbox' id='form_show_perc'\/>-->&nbsp;/ ;
   return $html ;
}

sub HtmlFormWithPerc
{
   my $html = &HtmlFormBase ;
   $html =~ s/PERCOPT/<input type='checkbox' id='form_show_perc' onchange='refreshPage()' \/> Show percentages/ ;
   return $html ;

}

sub HtmlSortTable
{
  my $html = <<__HTML_SORT_TABLE__ ;

<script src="jquery-1.3.2.min.js" type="text/javascript"></script>
<script src="jquery.tablesorter.js" type="text/javascript"></script>

<script type="text/javascript">
\$.tablesorter.addParser({
  id: "nohtml",
  is: function(s) { return false; },
  format: function(s) { return s.replace(/<.*?>/g,"").replace(/&nbsp;/g,""); },
  type: "text"
});

\$.tablesorter.addParser({
  id: "millions",
  is: function(s) { return false; },
//failed so far to turn 1.2M into 1200000, so figures with decimal point are sorted out of place
//format: function(s) { return \$.tablesorter.formatFloat(s.replace(/<[^>]*>/g,"").replace(/&nbsp;/g,"").replace(/\\.(\\d)M/,$1+"00000").replace(/M/,"000000").replace(/&#1052;/,"000000").replace(/K/,"000").replace(/&#1050;/i,"000")); },
  format: function(s) { return \$.tablesorter.formatFloat(s.replace(/<[^>]*>/g,"").replace(/&nbsp;/g,"").                                replace(/M/,"000000").replace(/&#1052;/,"000000").replace(/K/,"000").replace(/&#1050;/i,"000")); },
  type: "numeric"
});

\$.tablesorter.addParser({
  id: "digitsonly",
  is: function(s) { return false; },
  format: function(s) { return \$.tablesorter.formatFloat(s.replace(/<.*?>/g,"").replace(/&nbsp;/g,"").replace(/,/g,"").replace(/-/,"-1")); },
  type: "numeric"
});

\$.tablesorter.addParser({
  id: "showcount",
  is: function(s) { return false; },
  format: function(s) { return s.replace(/.*\\\(/,"").replace(/,.*/,""); },
  type: "numeric"
});

\$.tablesorter.addParser({
  id: "showcountswitch",
  is: function(s) { return false; },
  format: function(s) { return (show_percentage) ? (s.replace(/.*,\\s'/,"").replace(/%.*/,"").replace(/\\./,"")) : (s.replace(/.*\\\(/,"").replace(/,.*/,"")) ; },
  type: "numeric"
});
</script>

<style type="text/css">
table.tablesorter
{
/*
  font-family:arial;
  background-color: #CDCDCD;
  margin:10px 0pt 15px;
  font-size: 7pt;
  width: 80%;
  text-align: left;
*/
}
table.tablesorter thead tr th, table.tablesorter tfoot tr th
{
/*
  background-color: #99D;
  border: 1px solid #FFF;
  font-size: 8pt;
  padding: 4px;
*/
}
table.tablesorter thead tr .header
{
  background-color: #ffffdd;
  background-image: url(bg.gif);
  background-repeat: no-repeat;
  background-position: center right;
  cursor: pointer;
}
table.tablesorter tbody th
{
/*
  color: #3D3D3D;
  padding: 4px;
  background-color: #CCF;
  vertical-align: top;
*/
}
table.tablesorter tbody tr.odd th
{
  background-color:#eeeeaa;
  background-image:url(asc.gif);
}
table.tablesorter thead tr .headerSortUp
{
  background-color:#eeeeaa;
  background-image:url(asc.gif);
}
table.tablesorter thead tr .headerSortDown
{
  background-color:#eeeeaa;
  background-image:url(desc.gif);
}
table.tablesorter thead tr .headerSorthown, table.tablesorter thead tr .headerSortUp
{
  background-color: #eeeeaa;
}
</style>
__HTML_SORT_TABLE__
  return ($html) ;
}

sub HtmlSortTableColumns
{
  my $html = <<__HTML_SORT_TABLE_COLUMNS__ ;

<script type='text/javascript'>
\$('#table1').tablesorter({
  // debug:true,
  headers:{0:{sorter:'nohtml'},1:{sorter:'nohtml'},2:{sorter:'nohtml'},3:{sorter:'millions'},4:{sorter:'digitsonly'},5:{sorter:'millions'},6:{sorter:'digitsonly'},7:{sorter:'millions'},8:{sorter:'digitsonly'},9:{sorter:'digitsonly'}}
});
</script>
__HTML_SORT_TABLE_COLUMNS__
return ($html) ;
}

sub HtmlIndex
{
  $index = shift ;

  my $html = <<__HTML_INDEX__ ;

<script type="text/javascript">
<!--
function toggle_visibility_index()
{
  var index  = document.getElementById('index');
  var toggle = document.getElementById('toggle');
  if (index.style.display == 'block')
  {
    index.style.display = 'none';
    toggle.innerHTML = 'Show index';
  }
  else
  {
    index.style.display = 'block';
    toggle.innerHTML = 'Hide index';
  }
}
//-->
</script>

<tr><td class=r colspan=99><a href="#" id='toggle' onclick="toggle_visibility_index();">Show index</a></td></tr>
<tr><td class=l colspan=99><span id='index' style="display:none">\n$index\n<hr></span></td></tr>
__HTML_INDEX__

return ($html) ;
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

sub HtmlWorldMapsHover
{
my $d3_data = shift ;
my %d3_regions = shift ;

$requests_recently_all2 = i2KM ($requests_recently_all * 1000) . " $recently_desc" ; # input is still based on 1:1000 sampled log -> multiply * 1000 
$separator = "&nbsp;<font color=#888><b>|</b></font>&nbsp;" ;

#my $d3_region_world = $d3_regions {'world'} ;
#print $d3_region_world ;
#exit ;

# my $mapUSA    = "<tr><td colspan=99><img src='//upload.wikimedia.org/wikipedia/commons/2/21/US_population_map.png' width=400></td></tr>" ;
# my $mapCanada = "<tr><td colspan=99><img src='//upload.wikimedia.org/wikipedia/commons/7/77/Ca-map.png' width=400></td></tr>" ;
# my $mapMexico = "<tr><td colspan=99><img src='//upload.wikimedia.org/wikipedia/commons/c/c8/Mexico_estados_densidad.svg' width=400></td></tr>" ;
# my $mapWorldPopulationDensity = "<tr><td colspan=99><img src='//upload.wikimedia.org/wikipedia/commons/1/15/Countries_by_population_density.svg' width=400></td></tr>" ;
# my $mapPopulationDensityAfrica = "<tr><td colspan=99><img src='//upload.wikimedia.org/wikipedia/commons/4/4d/Africa_density.png' width=200></td></tr>" ;

#<div id="container" style="position: relative; width: 810px; height: 320px; background-color: #ffffff ;border:1px solid black;"></div>

print $d3_data_regions {'NA'} ; # qqq

my $html_worldmap_hover = <<__HTML_WORLD_MAP_HOVER__ ;
<tr>
<td colspan=99 class=lnb><b>Interactive map (use mouse): Wikipedia usage and demographics. 
Countries colored per page views per person per month</b><br>&nbsp;
</td>
</tr>

<tr>
<td colspan=99 class=lnb>
Legend: 
$icon_people = population&nbsp;&nbsp;&nbsp;
$icon_connected = connected to internet&nbsp;&nbsp;&nbsp;
<sub>$icon_wikipedia $icon_views</sub> = Wikipedia page views&nbsp;&nbsp;&nbsp;
<sub>$icon_world</sub> $icon_total = world total&nbsp;&nbsp;&nbsp;
$icon_person= per person
</td>
</tr>

<tr><td colspan=999>
<div id="container" style="position: relative; width: 810px; height: 320px; background-color: #ffffff"></div>

<script>
function row_country (lang_code,lang_name,perc_lang,width)
{
document.write (
"<tr>" + 
"<td class=lnb><font color=#888>" + lang_code + "</font></td>" + 
"<td class=lnb>" + lang_name + "</td>" + 
"<td class=rnb>" + perc_lang + "</td>" + 
"<td class=lnb><img src='yellowbar_hor.gif' width=" + width + " height=10></td>" + 
"</tr>") ; 
}

    var map = new Datamap({
    	element: document.getElementById('container'),

   // projection: 'mercator',
      done: function (map)
      {
        map.svg.call(d3.behavior.zoom().on("zoom", redraw));
        function redraw() { map.svg.selectAll("g").attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")"); }
      },
      projection: 'equirectangular', // http://davewood.me/blog/2014/04/09/drawing-a-world-map-with-d3/
    	fills: {
          defaultFill    : '#C00',
          "$label_fill_region"   : '#66F',
          "$label_fill_language" : '#A0A',
          "<font color=#C00>no data</font>"  : '#C00',
          "&nbsp;&nbsp;<sub><sub>$icon_views</sub></sub> per <sub><sub>$icon_person</sub></sub> 0 - 0.25"  : '#000', 
          "0.25 - 0.99" : '#250',
          "1 - 2.49"    : '#480',
          "2.5 - 4.99"  : '#5B0',
          "5 - 9.99"    : '#7E0',
          "10 and up"   : '#BF0'
        },
      geographyConfig: {
              highlightOnHover: true,
              borderColor: '#aaa',
              borderWidth: 1,
              highlightBorderColor: 'black',
              highlightBorderWidth: 1,
              highlightFillColor: '#FF4',

              popupTemplate: 
                function(geo,data) 
                {
                  return "<div class='hoverinfo' align=left style='white-space:nowrap'>" + 
                         data.icon + "&nbsp;<strong>" + geo.properties.name + "</strong><br>" +
                         "$icon_people " + data.population + 
                         "&nbsp;&nbsp;(" + data.connected + "$icon_connected)" +
                         "<br><sub>$icon_wikipedia$icon_views</sub> " + data.requests + "&nbsp;&nbsp;=&nbsp;&nbsp;" + 
                         data.perc_total + "% of <sub><sub><sup>$icon_world</sup></sub></sub>$icon_total" + 
                         "&nbsp;&nbsp;=&nbsp;&nbsp;" + data.requests_per_capita + " per$icon_person" + 
                         "</font><hr>" + 
                         "<table>" +
                         "<tr><th colspan=2 class=lnb>Language</th><th colspan=2 class=lnb>Share of total views</th></tr>" +  
                         data.breakdown +
                         "<tr><td class=lnb colspan=99><hr width='100%'>" +
                         "<font color=#888><small>Data for $recently_desc</small></font></td></tr>" + 
                      // (geo.properties.name == 'United States' ? "$mapUSA" : "") + 
                      // (geo.properties.name == 'Canada' ? "$mapCanada" : "") + 
                      // (geo.properties.name == 'Mexico' ? "$mapMexico" : "") + 
                         "</table></div>";
                },
            }, 
     data:{ // https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3
          WORLDMAP_D3_DATA
      }
		});
   map.legend () ;
// map.labels () ;

//   map.legend ({
//    legendTitle : "Monthly page views per person",
//    defaultFillName: "No data",
//    labels: 
//    {
//      q0: "one",
//      q1: "two",
//      q2: "three",
//      q3: "four",
//      q4: "five",
//      q5: "six,"
//    }
//    }) ;

//   window.setInterval(
//        function (map)
//        {
//          map.call (d3.behavior.zoom().on("zoom", redraw));
//          function redraw() 
//          {
//            map.selectAll("g").attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
//          }
//        }, 2000);

//   window.setInterval(
//     function() 
//     {
//       perc2 = Math.random (10) ;
//            if (perc2 <= 0.25) { fillkey = "below 0.25%" ; }
//       else if (perc2 <= 1.0)  { fillkey = "0.25% - 0.99%" ; }
//       else if (perc2 <= 2.5)  { fillkey = "1.0% - 2.49%" ; }
//       else if (perc2 <= 5.0)  { fillkey = "2.5% - 4.99%" ; }
//       else                    { fillkey = "5.0% and up" ; }
//       map.updateChoropleth(
//       {
//         USA: {'fillKey': fillkey}
//       }); 
//     }, 2000);

var regions = [
  {
    name: 'North-America',
    label: 'NA',
    type: 'region',
    radius: 8,
    fillKey: '$label_fill_region',
    latitude: 49,
    longitude:-104,
    borderColor: '#000',
    borderWidth: 2,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'black',
    ${d3_data_regions {'NA'}}
    dummy:0
  },
  {
    name: 'South-America',
    label: 'SA',
    type: 'region',
    radius: 8,
    fillKey: '$label_fill_region',
    latitude: -13.5,
    longitude: -62,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'black',
    ${d3_data_regions {'SA'}}
    dummy:0
  },
  {
    name: 'Europe',
    label: 'EU',
    type: 'region',
    radius: 8,
    fillKey: '$label_fill_region',
    latitude: 70,
    longitude: 0,
    borderColor: '#000',
    borderWidth: 2,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'black',
    ${d3_data_regions {'EU'}}
  },
  {
    name: 'Asia',
    label: 'AS',
    type: 'region',
    radius: 8,
    fillKey: '$label_fill_region',
    latitude:42.3,
    longitude:102.7,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'white',
    ${d3_data_regions {'AS'}}
    dummy:0
  },
  {
    name: 'Africa',
    label: 'AF',
    type: 'region',
    radius: 8,
    fillKey: '$label_fill_region',
    latitude: 15.3,
    longitude: 22.8,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'white',
    ${d3_data_regions {'AF'}}
    dummy:0
  },
  {
    name: 'Oceania',
    label: 'OC',
    type: 'region',
    radius: 8,
    fillKey: '$label_fill_region',
    latitude:-30.3,
    longitude:148,
    borderColor: '#000',
    borderWidth: 2,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'black',
    ${d3_data_regions {'OC'}}
    dummy:0
  },
  {
    name: 'Central America',
    label: 'CA',
    type: 'region',
    radius: 8,
    fillKey: '$label_fill_region',
    latitude:9.7,
    longitude:-98.3,
    borderColor: '#000',
    borderWidth: 2,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'black',
    ${d3_data_regions {'CA'}}
    dummy:0
  },
  {
    name: 'Global North',
    label: 'GN',
    type: 'region',
    radius: 8,
    fillKey: '$label_fill_region',
    latitude:34,
    longitude:-175,
    borderColor: '#000',
    borderWidth: 2,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'black',
    ${d3_data_regions {'N'}}
    dummy:0
  },
  {
    name: 'Global South',
    label: 'GS',
    type: 'region',
    radius: 8,
    fillKey: '$label_fill_region',
    latitude:24,
    longitude:-175,
    borderColor: '#000',
    borderWidth: 2,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'black',
    ${d3_data_regions {'S'}}
    dummy:0
  },
  {
    name: 'World',
    label: 'W',
    type: 'region',
    radius: 8,
    fillKey: '$label_fill_region',
    latitude:44,
    longitude:-175,
    borderColor: '#000',
    borderWidth: 2,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'black',
    ${d3_data_regions {'world'}}
    dummy:0
  },
  {
    name: 'English (mockup)',
    label: 'EN',
    type: 'language',
    radius: 8,
    fillKey: '$label_fill_language',
    latitude:0,
    longitude:-175,
    borderColor: '#000',
    borderWidth: 2,
    highlightFillColor: '#FF4',
    highlightBorderColor: 'black',
    ${d3_data_languages {'en'}}
    dummy:0
  },
  {
    name: 'Japanese (mockup)',
    label: 'JA',
    type: 'language',
    radius: 8,
    fillKey: '$label_fill_language',
    latitude:-10,
    longitude:-175,
    borderColor: '#000',
    borderWidth: 2,
    highlightFillColor: '#F4F',
    highlightBorderColor: 'black',
    ${d3_data_languages {'ja'}}
    dummy:0
  }
];

//draw bubbles for regions
map.bubbles(regions, {
    borderOpacity: 0.75,
    fillOpacity: 0.75,
    popupTemplate:
      function (geography, data) 
      { 
        if (data.name == 'Oceania')
        {
      //  map.updateChoropleth ({AUS: {borderColor : "white", borderWidth:3, fillKey: "$label_fill_region"}}) ;
      //  map.updateChoropleth ({AUS: {borderColor : "#F00", borderWidth:3}}) ;
        }

        if (data.type === 'language')
        { 
          return "<div class='hoverinfo' align=left style='white-space:nowrap'>" + 
                 "<strong>" + data.name + "</strong><br>" +
                 "<br><sub>$wikipedia$views</sub> " + data.requests + "&nbsp;&nbsp;=&nbsp;&nbsp;" + 
                 data.perc_total + "% of <sub><sub><sup>$icon_world</sup></sub></sub>$icon_total" + 
                 "<table>" +
                 data.breakdown +
                 "<tr><td class=lnb colspan=99><hr width='100%'>" +
             //  "<font color=#888><small>Data for $recently_desc</small></font></td></tr>" + 
                 "<font color=#C00><small>Mockup</small></font></td></tr>" + 
                 "</table></div>";
        }
        else
        { 
          return "<div class='hoverinfo' align=left style='white-space:nowrap'>" + "&nbsp;<strong>" + data.name + "</strong><br>" +
                 "$icon_people " + data.population_abs + 
                 "&nbsp;&nbsp;(" + data.connected_perc + "$icon_connected)" +
                 "<br><sub>$icon_wikipedia$icon_views</sub> " + data.requests_abs + "&nbsp;&nbsp;=&nbsp;&nbsp;" + 
                 data.requests_perc + " of <sub><sub><sup>$icon_world</sup></sub></sub>$icon_views" + 
                 "&nbsp;&nbsp;=&nbsp;&nbsp;" + data.requests_pp + " per$icon_person" + 
                 "</font><hr>" + 
                 "<table class=bubbles>" +
                 data.breakdown +
                 "<tr><td class=lnb colspan=99><font color=#888><hr width='100%'><small>Data for $recently_desc</small></font></td></tr></table>" + 
              // data.population_abs,
              // data.population_perc,
              // data.connected_abs,
              // data.connected_perc,
              // data.requests_abs,
              // data.requests_pp,
              // (data.name == 'World' ? "$mapWorldPopulationDensity" : ""),
              // (data.name == 'Africa' ? "$mapPopulationDensityAfrica" : ""),
                 "</div>" ;
        }
    }
});
//map.bubbles.labels() ;

//  http://jsbin.com/ociMiJu/1/edit?html,output
//  Custom Plugin for Bubble Labels 
//  Change this function all you want, just don't mess with the parameters.
          
function handleRegionLabels (layer, data, options) 
{
  var self = this;
  options = options || {};

  d3.selectAll(".datamaps-bubble")
  .attr("data-foo", function(datum) 
  {
    var coords = self.latLngToXY(datum.latitude, datum.longitude)
              
    layer.append("text")
         .attr("x", coords[0] + 12)
         .attr("y", coords[1] + 4)
      // .style("text-align", 'center')
      // .style("vertical-align", 'middle')
         .style("font-size", (options.fontSize || 11) + 'px')
         .style("font-family", options.fontFamily || "Verdana")
         .style("fill", options.labelColor || "#00F")
         .style('stroke', "#AAF")
         .text(datum[options.labelKey || 'fillKey']);
    return "bar";
  });
  }

map.addPlugin('regionLabels', handleRegionLabels);
map.regionLabels(regions, {labelColor: '#800', labelKey: 'label', fontSize: 10});
</script>

&nbsp;<p>&nbsp;
</td></tr>
__HTML_WORLD_MAP_HOVER__

return $html_worldmap_hover ;
}

sub HtmlWorldMapsFixed 
{
my $html_worldmaps_fixed = <<__HTML_WORLD_MAPS__ ;
<tr><td colspan=99 align=center>
<div style="text-align:left"><b>Static maps and chart for added context</b></div>
<table width='100%' style='vertical-align:text-top;' align=center valign='top'>
<td align=left style='background-color:#FFF; vertical-align: text-top;'>
<small>
<a href='//commons.wikimedia.org/wiki/File:Countries_and_Dependencies_by_Population_in_2014.svg'>
<img src='//upload.wikimedia.org/wikipedia/commons/4/41/Countries_and_Dependencies_by_Population_in_2014.svg' border='1' width='400px' height'205'>
</a>
<br>Countries and Dependencies by population in 2014<br>Based on data from <a href='https://www.cia.gov/library/publications/the-world-factbook/rankorder/2119rank.html'>The World Factbook</a>
<p>See also <a href='//en.wikipedia.org/wiki/List_of_countries_by_population'>Countries by population</a> - English Wikipedia
</small><p>&nbsp;
</td>
<td style='background-color:#FFF; vertical-align: text-top;'>
<small>
<a href='//commons.wikimedia.org/wiki/File:InternetPenetrationWorldMap.svg'>
<img src='//upload.wikimedia.org/wikipedia/commons/9/99/InternetPenetrationWorldMap.svg' border='1' width='400px'>
</a><br>
Internet users in 2012 as a percentage of a country's population<br>
Source: International Telecommunications Union.
<p>See also <a href='//en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>Internet penetration</a> (% of population) - English Wikipedia
</small><p>&nbsp;
</td>
</tr>
<tr>
<td style='background-color:"#EEE"; vertical-align: text-top;'>
<small>
<a href='//commons.wikimedia.org/wiki/File:North_South_divide.svg'>
<img src='//upload.wikimedia.org/wikipedia/commons/thumb/4/46/North_South_divide.svg/400px-North_South_divide.svg.png' border='1' height='205'>
</a>
<br>World map showing the modern definition of the North-South divide<br>&nbsp;
<p>See also <a href='//en.wikipedia.org/wiki/North-South_divide'>Global North South</a> - English Wikipedia
</small>
</td>
<td style='background-color:"#EEE"; vertical-align: text-top;'>
<small>
<a href='//commons.wikimedia.org/wiki/File:Internet_users_per_100_inhabitants_ITU.svg'>
<img src='//upload.wikimedia.org/wikipedia/commons/2/29/Internet_users_per_100_inhabitants_ITU.svg' border='1' width='400px' height='205'>
</a>
Internet users per 100 inhabitants<br>
Source: International Telecommunications Union.
<p>See also <a href='//en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>Internet penetration</a> (% of population) - English Wikipedia
</small>
</td>
</tr>
</table>
</td></tr>
__HTML_WORLD_MAPS__

return $html_worldmaps_fixed ;
}

# yeah, changing a global yet again
sub AddNoticeSurvey
{
  my $report_id = shift ;

if (($quarter_only ne '') && ($quarter_only lt "2015 Q2"))
{
  $html .= "<font color=#080><b><big>Feb 2016: This report has been upgraded, and does now include mobile views. But still is based on pre-hadoop data stream (squid logs)</big></b></font>" ;
}    
else 
{ 
  $html .= "<font color=#030><b><big>Feb 2016: This report has been upgraded, and is now based on Wikimedia Foundations's new hadoop-based infrastructure.<br>Earlier versions of this report have been republished with new data, starting May 2015. Thanks so much for your patience!</font><p>" . 
           "<font color=#030>Mar 2016: Non-regional Wikistats traffic reports which were marked by users in <a href='//www.mediawiki.org/wiki/Analytics/Wikistats/TrafficReports/Future_per_report_B2'>this survey</a> as particularly valuable<br>
have also been migrated to Wikimedia Foundation's new hadoop-based infrastructure. See <a href='//analytics.wikimedia.org/dashboards/browsers/#all-sites-by-os'>here</a><br>&nbsp;<br></font>" .  
           "<font color=#080>Jul 2016: New map added: the large world map is a visual presentation equivalent of the tabular data further down.</big></b>" ;
}    

}
