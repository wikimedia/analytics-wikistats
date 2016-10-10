#!/usr/bin/perl

# restructure along the lines of 
# ref http://www.explainingprogress.com/wp-content/uploads/datamaps/uploaded_gdpPerCapita2011_PWTrgdpe/gdpPerCapita2011_PWTrgdpe.html
# https://ourworldindata.org/

# cd /srv/stats.wikimedia.org/htdocs/archive/squid_reports/2016-06/draft	

# scaling iframe http://jsfiddle.net/Masau/7WRHM/

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

# sub ReadInputCountriesMonthly reads $path_csv_counts_monthly (/a/wikistats_git/squids/csv/SquidDataVisitsPerCountryMonthly.csv)

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

# 2016-07-17 minus
# ReadWikipediaCountriesByPopulation
# ReadWikipediaCountriesByInternetUsers

# 2016-07-18 minus
# CalcPercentages 
# WriteCsvCountriesTimed
# ReadCountryInfo  
# HtmlFormWithPerc
# also
# InitProjectNames -> ReadLanguageInfo (read from file instead of long inline hash file)

# 2016-08-09 minus
# ReadInputCountriesDaily
# ReadDate

  $| = 1; # Flush output

  use SquidReportArchiveConfig ;
  use EzLib ;
  $trace_on_exit = $false ;
  ez_lib_version (2) ;

  $path_upload    = "//upload.wikimedia.org/wikipedia/commons/thumb" ; 

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
                          
  our $out_billion  = 'B' ;
  our $out_million  = 'M' ;
  our $out_thousand = 'K' ;


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

  $reports_set_basic     = 0 ;
  $reports_set_countries = 1 ;

  $d3_csv_rows_max = 50 ; # max rows to show in hover box 
  $perc2bar  = 1.5 ; # one perc is x pixel
  $perc2bar2 = 1.5 ; # one perc is x pixel

  # periodically harvest updated metrics from
  # '//en.wikipedia.org/wiki/List_of_countries_by_population'
  # '//en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'
  if (defined ($options {"w"}))
  {
    use LWP::Simple qw($ua get);
    $ua->agent('Wikipedia Wikicounts job');
    $ua->timeout(60);


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

  &ReadLanguageInfo ;
  &ReadInputRegionCodes ;
  &ReadCountryCodesISO3 ;
  &ReadInputCountryNames ;
  &ReadInputCountryInfo ;
# &ReadCountryCodes ;

  if ($reportcountries)
  {
    $project_mode = "wp" ; # discard all log data from other projects than Wikipedia

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

  $days_in_month = &DaysInMonth (substr ($reportmonth,0,4), substr ($reportmonth,5,2)) ;

  $threshold_mime    = 0 ;
  $threshold_project = 10 ;

  $file_log               = "SquidReportArchive.log" ;

  $file_csv_countries_languages_visited = "SquidDataCountriesViews.csv" ;

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

  &WriteCsvCountriesGoTo ;

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

  $file_csv_counts_monthly        = "SquidData${selection2}PerCountryMonthly.csv" ; # LockePrev.csv" ;

  $file_html_per_country_breakdown      = "SquidReport${selection}PerCountryBreakdown.htm" ;
  $file_html_per_country_breakdown_huge = "SquidReport${selection}PerCountryBreakdownHuge.htm" ;
  $file_html_per_country_overview       = "SquidReport${selection}PerCountryOverview$quarter_only2.htm" ;
  $file_html_per_country_trends         = "SquidReport${selection}PerCountryTrends.htm" ;
  $file_html_per_language_breakdown     = "SquidReport${selection}PerLanguageBreakdown.htm" ;
  $file_csv_per_country_overview        = "SquidReport${selection}PerCountryOverview.csv" ; # output file
  $file_csv_per_country_density         = "SquidReport${selection}PerCountryDensity.csv" ;  # output file
  $file_csv_datamaps_info_per_country   = "DatamapsViewsPerCountry.csv" ; # output file

  # add prev/next for quarter reports # qqq
  $yyyy = substr ($quarter_only2,0,4) ;
  $q    = substr ($quarter_only2,5,1) ;
  if ($q == 1) { $q = 4 ; $yyyy-- ; } else  { $q-- ; }
  $link_html_per_country_overview_prev = "SquidReport${selection}PerCountryOverview${yyyy}Q$q.htm" ;

  $yyyy = substr ($quarter_only2,0,4) ;
  $q    = substr ($quarter_only2,5,1) ;
  if ($q == 4) { $q = 1 ; $yyyy++ ; } else  { $q++ ; }  
  $link_html_per_country_overview_next = "SquidReport${selection}PerCountryOverview${yyyy}Q$q.htm" ;

  $path_csv_counts_monthly  = "$path_csv/$file_csv_counts_monthly" ;
  if (! -e $path_csv_counts_monthly)  { abort ("Input file $path_csv_counts_monthly not found!") ; }

  &ReadInputCountriesMonthly ($project_mode) ;





  &WriteCsvDataMapInfoPerCountry ($title, $views_edits, &UnLink ($links,$offset_links+2),$cutoff_requests =  10, $cutoff_percentage = 0.1, $show_logcount = $true,  $sample_rate) ;
  &WriteCsvDataMapInfoPerRegion   ($sample_rate) ;
  &WriteCsvDataMapInfoPerLanguage ($sample_rate) ;

  # input for http://gunn.co.nz/map/, for now hardcoded quarter
  &WriteCsvFilePerCountryDensity ($views_edits, '2013 Q2', \%requests_per_quarter_per_country, $max_requests_per_connected_us_month, "Wikipedia " . lc $views_edits . " per person", $sample_rate) ;

  &PrepHtml ($reports_set_countries, $sample_rate) ;
  &SetPeriod ;

  &WriteJsFileVisualizationInfo ($recently_desc) ;  # for now only year and month of data, to be shown in viz.

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

  &LogDetail ("Sample period: $period => for daily averages multiplier = " . sprintf ("%.2f",$multiplier) . "\n\n") ;
}

sub PrepHtml
{
  my ($reports_set,$sample_rate) = @_ ;

  &LogSub ("PrepHtml\n\n") ;

  $language = "en" ;
  $header = &HtmlHead ;

  $body_top = &HtmlBodyTop ;

  if ($sample_rate == 1)
  { $header_sample_rate = "1:1 unsampled" ; }
  else
  { $header_sample_rate = "1:$sample_rate sampled" ; }

  $run_time = "<font color=#888877>" . date_time_english (time) . " UTC</font> " ;

  $header.=  "\n<body bgcolor='\#FFFFFF'>\n$body_top\n<hr>" .
            "$run_time<p>\nALSO<p>NOTICE" ;

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

  $dummy_countries   = "<font color=#000060>Countries</font>" ;

  $link_countries_overview = "<a href='SquidReportPageViewsPerCountryOverview.htm'>Overview</a>" ;
  $link_countries_projects = "<a href='SquidReportPageViewsPerCountryBreakdown.htm'>Projects</a>" ;
  $link_countries_trends = "<a href='//stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryTrends.htm'>Trends</a>" ;
  $link_trends_countries = "<a href='//stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryTrends.htm'>Countries</a>" ;
}

sub ReadCountryCodes
{
  &LogSub ("ReadCountryCodes\n") ;

  my @csv = ReadCsv ("$path_meta/$file_csv_country_codes") ;

  foreach $line (@csv)
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
}

sub ReadCountryCodesISO3
{
  &LogSub ("ReadCountryCodesISO3\n") ;
  
  my @csv = &ReadCsv ("$path_meta/CountryCodesISO3.csv") ;

  foreach $line (@csv)
  {
    if ($line =~ /^[A-Z]/)
    {
      chomp ($line) ;
      ($code,$name) = split (',',$line,2) ;
      $name =~ s/"//g ;
      $country_codes_iso3 {$code} = $name ;
      $country_names_iso3 {$name} = $code ;
    # print "$code => $name\n" ;
    }
  }
}

sub AddExtraCountryNames_iso3
{ 
# add entries for country names spelled differently in $file_csv_country_codes 
  $country_names_iso3 {'Bolivia'}                 = 'BOL' ;
  $country_names_iso3 {'Brunei'}                  = 'BRN' ;
  $country_names_iso3 {'Burma'}                   = 'MMR' ;
  $country_names_iso3 {'Cape Verde'}              = 'CPV' ;
  $country_names_iso3 {'Caribbean Netherlands'}   = 'XXX' ;
  $country_names_iso3 {'Congo Dem. Rep.'}         = 'COD' ;
  $country_names_iso3 {'Congo Rep.'}              = 'COG' ;
  $country_names_iso3 {"Cote d'Ivoire"}           = 'CIV' ;
  $country_names_iso3 {'Falkland Islands'}        = 'FLK' ;
  $country_names_iso3 {'Iran'}                    = 'IRN' ;
  $country_names_iso3 {'Laos'}                    = 'LAO' ;
  $country_names_iso3 {'Macedonia'}               = 'MKD' ;
  $country_names_iso3 {'Micronesia'}              = 'FSM' ;
  $country_names_iso3 {'Moldova'}                 = 'MDA' ;
  $country_names_iso3 {'Palestinian Territories'} = 'PSE' ;
  $country_names_iso3 {'Russia'}                  = 'RUS' ;
  $country_names_iso3 {'Sint Maarten'}            = 'SXM' ;
  $country_names_iso3 {'South Korea'}             = 'KOR' ;
  $country_names_iso3 {'Syria'}                   = 'SYR' ;
  $country_names_iso3 {'São Tomé and Príncipe'}   = 'STP' ;
  $country_names_iso3 {'Taiwan'}                  = 'TWN' ;
  $country_names_iso3 {'Tanzania'}                = 'TZA' ;
  $country_names_iso3 {'United States'}           = 'USA' ;
  $country_names_iso3 {'Vatican City'}            = 'VAT' ;
  $country_names_iso3 {'Venezuela'}               = 'VEN' ;
  $country_names_iso3 {'Vietnam'}                 = 'VNM' ;
  $country_names_iso3 {'Virgin Islands, UK'}      = 'VGB' ;
  $country_names_iso3 {'Virgin Islands, US'}      = 'VIR' ;
}

sub ReadCsv
{
  my $file_in = shift ;
  print "\&ReadCsv '$file_in'\n" ;

  my $lines ;
  my @csv ;
  
  die "Not file specified (path ends on '\/'): in '$file_in'" if $file_in =~ /\/\s*$/ ; 
  die "Input file '$file_in' not found!" if ! -e $file_in ; 
  open  CSV_IN, '<', $file_in || die "File '$file_in' could not be opened" ;
  binmode CSV_IN ;

  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;
    next if $line !~ /,/ ;

    $lines++ ;
    chomp $line ;
    push @csv, $line ;
  }

  die "File '$file_in' contains no valid data lines" if $lines == 0 ;
 
  print "Data lines: $lines\n" ;
  return (@csv) ;
}

sub ReadInputRegionCodes
{
  &LogSub ("ReadInputRegionCodes\n") ;

  my @csv = &ReadCsv ("$path_meta/RegionCodes.csv") ;

  foreach $line (@csv)
  {
    ($country_code,$region_code,$north_south_code) = split (',', $line) ;
    $region_codes      {$country_code} = $region_code ;
    $north_south_codes {$country_code} = $north_south_code ;
  }
}

sub ReadInputCountryNames
{
  &LogSub ("ReadInputCountryNames\n") ;

  my @csv = &ReadCsv ("$path_meta/CountryCodes.csv") ;

  $country_names {'-'}  = 'Unknown7' ;
  $country_names {'--'} = 'Unknown8' ;
  $country_names {'-P'} = 'IPv6' ;
  $country_names {'-X'} = 'Unknown9' ;
  $country_names {'AN'} = 'Netherlands Antilles' ; # not yet in MaxMind database
  $country_names {"XX"} = "Unknown10" ;

  foreach $line (@csv)
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
}

sub ReadInputCountryInfo
{
  &LogSub ("\&ReadInputCountryInfo\n") ;

  # http://en.wikipedia.org/wiki/List_of_countries_by_population
  # http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users

  my @csv = &ReadCsv ("$path_meta/CountryInfo.csv") ;

  foreach $line (@csv)
  {
    chomp $line ;
    $line =~ s/[\x00-\x1f]//g ;

    my ($country,$population,$connected,$article_url,$icon_url,$icon_width,$icon_height) = split ',', $line ;
  # $icon =~ s/\/\/upload.wikimedia.org\/wikipedia\/commons\/thumb///upload.wikimedia.org/wikipedia/commons/thumb/g ;
  # $icon =~ s/\/\/upload.wikimedia.org\/wikipedia\/en\/thumb///upload.wikimedia.org/wikipedia/en/thumb/g ;

    $country =~ s/\%2C/,/g ;

    if ($connected eq '-')
    { $ip_connections_unknown .= "$country, " ; }

    $connected =~ s/\-/../g ;

    $icon = "<img src='$icon_url' width=$icon_width height=$icon_height border=1>" ;

    $country_meta_info {$country} = "$article_url,$icon,$population,$connected" ;

    $country_alias = '' ;
 
    # name on wiki page                  # name on datamaps viz.
       if ($country eq 'The Gambia')     { $country_alias = 'Gambia' ; }
    elsif ($country eq 'The Bahamas')    { $country_alias = 'Bahamas' ; }
    elsif ($country eq 'Samoa')          { $country_alias = 'American Samoa' ; }
    elsif ($country eq 'American Samoa') { $country_alias = 'Samoa' ; }
    elsif ($country eq 'American American Samoa')         { $country_alias = 'American Samoa' ; }
    elsif ($country eq 'East Timor')     { $country_alias = 'Timor-Leste' ; }
    elsif ($country eq 'Macau')          { $country_alias = 'Macao' ; }
    elsif ($country =~ '^R..?union')     { $country_alias = 'Réunion' ; }

    if ($country_alias ne '')
    { $country_meta_info {$country_alias} = "$article_url,$icon,$population,$connected" ; }
   
    $code = $country_names_iso3 {$country} ;
    if ($code eq '')
    { print "No ISO3 code for country $country\n" ; }

    if ($country eq "United States")
    { ($connected_us = $connected) =~ s/_//g  ; }
  }

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

    next if $link =~ /^\*$/ ;
    my ($link,$icon,$population,$connected) = split (',', $country_meta) ;

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
  { print "No valid data found: population_tot = 0 for country $country_code = $country_name!\n" ; }
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

  &LogDetail ("Read monthly data (year $report_year, month $report_month) for project $project_mode (wp=Wikipedia, etc) from $path_csv_counts_monthly\n") ;

  $date_first = '9999-99' ;
  $date_last  = '0000-00' ;

  $invalid_country_codes = 0 ;
  $discarded_input = 0 ;

  my $lines = 0 ;
  &LogBreak ;
  &Log ("read from '$path_csv_counts_monthly'\n") ;

  open CSV_IN, '<', $path_csv_counts_monthly ;
  while ($line = <CSV_IN>)
  {
    $lines++ ;
    if ($lines % 200000 == 0)
    { &LogList ("lines: $lines\n") ; }

    chomp $line ;
    $line =~ s/,\s+/,/g ;
    $line =~ s/\s+,/,/g ;
    ($yyyymm,$project,$language,$code,$bot,$count) = split (',', $line) ;

    ($code,$language) = &NormalizeLanguageCodes ($code,$language) ;

    # next if $country =~ /\?/ ;
    next if &DiscardInput ($bot,$project,$project_mode,$code,$language) ;

    $country = &GetCountryName ($code) ;
    if ($country =~ /invalid/) # frequent parsing error in earlier years
    {
      $reason_discard {'$country =~ /invalid/'} ++ ;
      $discarded_input ++ ;
      next ;
    }

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
    # Dec 2013: quarterly report used to be avg monthly counts for last full 12 months, now it is data for one month 	    
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
  close CSV_IN ;

  if ($lines_selected == 0)
  { abort ("No lines selected from $path_csv_counts_monthly.\nRun step 'collect_country_stats' to add data for requested month.") ; }

  if ($lines > 0)
  {
    $perc_invalid_country_codes = sprintf ("%.1f", 100 * $invalid_country_codes / $lines) ;
    $perc_discarded_input       = sprintf ("%.1f", 100 * $discarded_input / $lines) ;
  }
  &LogList ("lines: $lines invalid country codes: $invalid_country_codes ($perc_invalid_country_codes\%), " . 
            "discard input: $discarded_input ($perc_discarded_input\%)\n") ;


  &LogList ("\nReasons for discarding input:\n") ;
  foreach $key (sort keys %reason_discard)
  { &LogList (sprintf ("%8s", $reason_discard {$key}) . ": $key\n") ; }

  &LogList ("\nTop 10 most found invalid country codes:\n") ;
  $codes_reported = 0 ;
  foreach $code (sort {$country_code_not_specified_reported {$b} <=> $country_code_not_specified_reported {$a}} keys %country_code_not_specified_reported)
  {
    &LogList ("Code $code: ${country_code_not_specified_reported {$code}}\n") ;
    last if $codes_reported++ == 10 ;
  }
  &LogBreak () ;
  &LogDetail ((0 + $lines) . " lines read from '$path_csv_counts_monthly'\n") ;

  if ($lines == 0)
  { abort ("No lines read from '$path_csv_counts_monthly'\n") ; }

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

sub NormalizeLanguageCodes
{
  # &LogSub ("NormalizeLanguageCodes\n") ;

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

sub DiscardInput
{
  # &LogSub ("DiscardInput\n") ;

  my ($bot,$project,$project_mode,$code,$language) = @_ ;

  $project =~ s/[^a-z\-\_]//g ; # remove %@ encoding for mobile etc
# print "$bot,$project,$project_mode,$code,$language\n" ;

  if ($bot ne "U") 
  {
    $reason_discard {"field bot not 'U' for 'user'"} ++ ;
    $discarded_input ++ ;
    return true ;
  }
  if ($project ne $project_mode)
  {
    $reason_discard {"project ne '$project_mode'"} ++ ;
    $discarded_input ++ ;
    return true ;
  }
  if ($language eq 'upload')
  {
    $reason_discard {"language eq 'upload'"} ++ ;
    $discarded_input ++ ;
    return true ;
  }
  if ($language =~ /mobile/i)
  {
    $reason_discard {"language =~ 'mobile'"} ++ ;
    $discarded_input ++ ;
    return true ;
  }
  if ($code =~ /deflate|520-18|sdch/)
  {
    $reason_discard {'$code =~ /deflate|520-18|sdch/'} ++ ;
    $discarded_input ++ ;
    return true ;
  }
   # $code eq "A1" or # Anonymous Proxy
   # $code eq "A2" or # Satellite Provider
   # $code eq "AP" or # Asia/Pacific Region
   # $code eq "EU")   # Europe

  return ($false) ;
}

sub GetCountryName
{
  my $code = shift ;
  if ($country_names {$code} eq "")
  {
    if ($code =~ /(?:=|Mozilla)/) # known frequent parsing error in earlier years, do not report
    { return ('country name invalid') ; }

    $country = "?? (code $code)" ;
    if ($country_code_not_specified_reported {$code}++ == 0)  
    { &LogList ("country name not specified for $code\n") ; }

    $invalid_country_codes++ ;
  }
  else
  { $country = $country_names {$code} ; }

  return ($country) ;
}


# https://en.wikipedia.org/wiki/ISO_3166-1_alpha-3
sub WriteCsvCountriesGoTo
{
  &LogSub ("WriteCsvCountriesGoTo: $path_csv/$file_csv_countries_languages_visited\n") ;

  open CSV_OUT, '>', "$path_csv/$file_csv_countries_languages_visited" ;

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

      last if $cnt_targets++ >= 100 ;
    }
    print CSV_OUT "$line\n" ;

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
      print CSV_OUT "$line\n" ;

      $line = "$bot,$country_name," ;
      $cnt_targets = 0 ;
      if ($tot_targets > 0)
      {
        foreach $target (@targets)
        {
          $line .= sprintf ("%.1f\%",100*$targets_totals {"$bot,$country"}{$target} / $tot_targets) . "," ;

          last if $cnt_targets++ >= 25 ;
        }
        print CSV_OUT "$line\n" ;
      }
    }
  }
  close CSV_OUT ;
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
  $html =~ s/ALSO// ;
  $html =~ s/LINKS/$links/ ;
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
    { $gif = "bluebar.gif" ; }
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
      $bar_width = int ($perc * $perc2bar) ;

      $bar_100 = "" ;
      if ($bars++ == 0)
      {
        $bar_width_100 = 600 - $bar_width ;
        $bar_100 = "<img src='white.gif' width=$bar_width_100 height=15>" ;
        $bar_100 = '' ; # until gif is added
      }
      if (($country =~ /Australia/) && ($language_name =~ /Japanese/) && ($perc > $perc2bar))
      { $perc .= " <b><a href='#anomaly' onclick='alert(\"Probably incorrectly assigned to this country.\\nOutdated Regional Internet Registry (RIR) administration may have caused this.\")';><font color='#FF0000'>(*)</font></a></b>" ; $anomaly_found = $true ;}
      $html .= "<tr><th class=l class=small nowrap>$country</th>" .
               "<td class=c>[$requests_this_country ]$perc</td>" .
               "<td class=l><img src='$gif' width=$bar_width height=15>$bar_100</td></tr>\n" ;
    }

    if ($perc_tot > 100) { $perc_tot = 100 ; }

    $perc_other = sprintf '%.1f', 100 - $perc_tot ;
    if ($perc_other > 0)
    {
      $bar_width = $perc_other * $perc2bar ;
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

  if ($views_edits =~ /edit/i)
  { $MPVE = 'MPE' ; } # monthly page edits
  else
  { $MPVE = 'MPV' ; } # monthly page views

  $html  = $header ;
  $html =~ s/WORLDMAP_D3// ;
  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/LINKS/$links/ ;
  $html =~ s/ALSO// ;
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
    # if ($perc_share_total2 =~ /0\.0/)
    # { $perc_share_total2 = '<font color=#CCC><small><&nbsp;0.1%</small></font>' ; }

    &Percentage ($requests_this_country / $requests_recently_all) ; 
    
    $perc_tot += $perc_share_total ;

    $bar = "&nbsp;" ;
    $bar2 = "&nbsp;" ;
    if (int ($perc_share_total * 10) > 0)
    { 
      $bar  = &Perc2Bar ($share_requests,'red',15) ;
      $bar2 = &Perc2Bar ($share_requests,'red',12) ;
    #  $bar  = "<img src='redbar.gif' width=" . (int ($perc_share_total * $perc2bar)) . " height=15>" ; 
    # $bar2 = "<img src='redbar.gif' width=" . (int ($perc_share_total * $perc2bar)) . " height=12>" ; 
    }

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

   # if ($perc_population =~ /\.0\d/)
   # { $perc_population = "<font color=#CCC><small>$perc_population</small></font>" ; }

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

  #  if (($region_code eq 'AF') || ($region_code eq 'AS') || ($region_code eq 'EU'))
  #  { $icon = "<sub><sub>$icon</sub></sub>" ; }
    
    $link_country =~ s/<\/?a[^>]*>//g ;
    $link_country =~ s/alt=['"]+ // ;
    $link_country =~ s/Democratic Republic of the Congo/Congo Dem. Rep./ ;
    
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


  $html_regions = '' ;
  foreach $key (qw (N S AF AS EU CA NA SA OC XX))
  {
    $region = $key ;
    $region2 = $region ;

    $region =~ &RegionCodeToText ($region) ; # e.g. $region =~ s/^N$/<font color=#000BF7><b>Global North<\/b><\/font>/ ;

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
  # if ($perc_share_total > 0)
    if (int ($perc_share_total * 3) > 0)
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
}

# input for http://gunn.co.nz/map/
sub WriteCsvFilePerCountryDensity
{
  my ($views_edits, $period, $ref_requests_per_period_per_country, $max_requests_per_connected_us, $desc_animation, $sample_rate) = @_ ;

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
    $country =~ s/Serbia/Republic of Serbia/ ;                                                # http://gunn.co.nz/map/

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

  &PrintCsv  ($header_csv_countries . join ('', sort @csv_countries), "$path_csv/$file_csv_per_country_density") ;
}

sub WriteReportPerCountryBreakdown
{
  &LogSub ("WriteReportPerCountryBreakDown\n") ;

  &AddExtraCountryNames_iso3 ;

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

  $html  = $header ;  

  $folder_scripts = "//stats.wikimedia.org/wikimedia/squids/scripts/" ;
  $html =~ s/WORLDMAP_D3/<script src="$folder_scripts\/d3.min.js"><\/script>\n<script src="$folder_scripts\/topojson.min.js"><\/script>\n<script src="$folder_scripts\/datamaps.world.hires.min.js"><\/script>\n<script src="$folder_scripts\/options.js"><\/script>\n/ ;

  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/LINKS/$links/ ;
  $html =~ s/ALSO/$report_version/ ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_recently_start - $requests_recently_stop<\/b>/ ;
  $html =~ s/DATE// ;

  $html .= "<p>'Portal' refers to url <a href='//www.wikipedia.org'>www.wikipedia.org</a><p>\n" ;

  &AddNoticeSurvey (22) ;

  $html .= "<p><table border=1 width=800>INDEX\n" ;

  $html .= &HtmlWorldMapsFixed ;

  my $anomaly_found ;

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

    my ($link,$icon,$population,$connected) = split (',', $country_meta) ;
    $population  =~ s/_//g ;
    $connected   =~ s/_//g ;
    $population2 = &i2KM ($population) ;
    $requests_this_country2 = &i2KM ($requests_this_country * 1000) ; # input is in 1000's 
    $connected2  = '--' ;
    $requests_per_capita = '--' ;
     
    if ($population> 0)
    { 
      $connected2 = sprintf ("%.0f", 100*$connected/$population) .'%' ; 
      $requests_per_capita = &i2SigDec ($requests_this_country * 1000 / $population) ;
    } 

    $perc = 'n.a.' ;
    if ($requests_recently_all > 0)
    { $perc = &Percentage ($requests_this_country / $requests_recently_all) ; }

    ($link_country,$icon,$population) = &CountryMetaInfo ($country) ;

    $code_iso3 = $country_names_iso3 {$country} ;
    if ($code_iso3 eq '')
    { 
      print "no iso3166 code for '$country'\n" ; 
      $code_iso3 = 'XXX' ; 
    }
    
    # print "country $country -> $code_iso3\n" ;

    $icon =~ s/"/'/g ;
 
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
      $bar_width  = int ($perc * $perc2bar) ;
      $bar_width2 = int ($perc * $perc2bar2) ;
      if ($bar_width2 < 1)
      { $barwidth2 = 1 ; }

      if (($country eq "Australia") && ($language eq "Japanese") && ($perc > $perc2bar))
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
      $bar_width = $perc_other * $perc_2bar ;
      $bar_width2 = int ($perc_other * * $perc2bar2) ;
      if ($bar_width2 < 1)
      { $barwidth2 = 1 ; }

      $html .= "<tr><th class=l class=small nowrap>Other</th>" .
               ($show_logcount ? "<td class=r>$requests_other</td>" : "") .
               "<td class=c>$perc_other%</td>" .
               "<td class=l><img src='yellowbar_hor.gif' width=$bar_width height=15></td></tr>\n" ;
    }

    if ($verbose)
    { push @index_countries, "<a href='#$country'>$country ($perc)</a> " ; }
    else
    { push @index_countries, "<a href='#$country'>$country</a> " ; }

  # print "\n" ;
  # $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  }
 
 
  $html .= "</table>" ;

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
  $html =~ s/LINKS/$links/ ;
  $html =~ s/ALSO// ;
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

sub LogBreak  { &Log ("\n") ; } # trivial sub just to be consistent
sub LogSub    { &Log ("\n> " . shift) ; }
sub LogDetail { &Log (". " . shift) ; }
sub LogList   { &Log ("* " . shift) ; }

sub ReadLanguageInfo
{
  &LogSub ("\&ReadLanguageInfo\n") ;

  my @csv = &ReadCsv ("$path_meta/LanguageInfo.csv") ;

  foreach $line (@csv)
  {
    next if $line =~ /^#/ ; # comments
    next if $line !~ /,/ ;

    chomp $line ;
    $line =~ s/ /\&nbsp;/g ;

    ($code,$name,$url,$speakers,$regions,$comment) = split (',', $line) ;

    $out_urls      {$code} = $url ;
    $out_languages {$code} = $name ;
    $out_article   {$code} = "://en.wikipedia.org/wiki/" . $out_languages {$key} . "_language" ;
    $out_article   {$code} =~ s/ /_/g ;
    $out_speakers  {$code} = $speakers ;
    $out_regions   {$code} = $regions ;
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

  $perc =~ s/\.\%/\.0\%/ ; # make sure there is always a decimal, to align value properly
  return ($perc) ;
}

sub Perc2Bar # qqqq
{
  my ($perc,$color,$height) = @_ ;
  my  $bar = "&nbsp;" ;

  $perc =~ s/\%// ;
  my $width = $perc * $perc2bar ;    
  if ($perc > 0)
  { $bar  = "<img src='${color}bar.gif' width=$width height=$height>" ; }

  return ($bar) ;
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

    return ($country,'','..','..') ;
  }
  else
  {
    ($link_country,$icon,$population,$connected) = split ',', $country_meta_info {$country} ;

    $population =~ s/_//g ;
    $connected =~ s/_//g ;

    $link_country =~ s/\%2C/,/g ;
    $icon         =~ s/\%2C/,/g ;

    return ($link_country,$icon,$population,$connected) ;
  }
}

sub i2KM
{
  my $v = shift ;

  return ("&nbsp;") if $v == 0 ;
  
     if ($v >= 100000000000) { $v = sprintf ("%.0f",($v / 1000000000)) . "&nbsp;" . $out_billion  ; $v =~ s/(\d+?)(\d\d\d[^\d])/$1,$2/ ; }
  elsif ($v >= 1000000000)   { $v = sprintf ("%.1f",($v / 1000000000)) . "&nbsp;" . $out_billion  ; }
  elsif ($v >= 100000000)    { $v = sprintf ("%.0f",($v / 1000000))    . "&nbsp;" . $out_million  ; $v =~ s/(\d+?)(\d\d\d[^\d])/$1,$2/ ; }
  elsif ($v >= 1000000)      { $v = sprintf ("%.1f",($v / 1000000))    . "&nbsp;" . $out_million  ; }
  elsif ($v >= 10000)        { $v = sprintf ("%.0f",($v / 1000))       . "&nbsp;" . $out_thousand ; }
  elsif ($v >= 1000)         { $v = sprintf ("%.1f",($v / 1000))       . "&nbsp;" . $out_thousand ; }

  return ($v) ;
}

sub i2KM2
{
  my $v = shift ;
  return $v if $v !~ /^\d*$/ ;

  return ("&nbsp;") if $v == 0 ;

     if ($v >= 10000000) { $v = sprintf ("%.0f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 1000000)  { $v = sprintf ("%.1f",($v / 1000000)) . "&nbsp;" . $out_million ; }
  elsif ($v >= 1000)     { $v = sprintf ("%.0f",($v / 1000))    . "&nbsp;" . $out_thousand ; }

  return ($v) ;
}

#   format: function(s) { return $.tablesorter.formatFloat(s.replace(/<[^>]*>/g,"").replace(/\\&nbsp\\;/g,"").replace(/M/i,"000000").replace(/&#1052;/,"000000").replace(/K/i,"000").replace(/&#1050;/i,"000")); },

# determine significant decimales (at most 3)
sub i2SigDec 
{
  my $i = shift ;
  
  if ($i >= 0.1)
  { $precision = "%.1f" ; }
  elsif ($i >= 0.01)
  { $precision = "%.2f" ; }
  else
  { $precision = "%.3f" ; }

  return (sprintf ($precision, $i)) ; 
}

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

  $html =~ s/and images// ; # all data [and images] onthis page are in the public domain
  open  HTML_OUT, '>', $path ;
  print HTML_OUT $html ;
  close HTML_OUT ;

  $ago = -M $path ;
  &Log ("Html file printed: $path\n") ;

}

sub PrintCsv
{
  my ($csv, $path) = @_ ;

  open  CSV_OUT, '>', $path ;
  print CSV_OUT $csv ;
  close CSV_OUT ;
}

sub PrintJson
{
  my ($json, $path) = @_ ;

  open  JSON_OUT, '>', $path ;
  print JSON_OUT $json ;
  close JSON_OUT ;
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
td    {font-size:12px ; white-space:wrap; text-align:right; vertical-align:middle ;
       padding-left:2px; padding-right:2px; padding-top:1px; padding-bottom:0px } 

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

th       {white-space:nowrap; text-align:right; 
          padding-left:2px; padding-right:2px; padding-top:1px; padding-bottom:0px ; 
          font-size:12px ; vertical-align:top ; font-width:bold}
th.small {white-space:wrap; text-align:right; 
          padding-left:2px; padding-right:2px; padding-top:1px; padding-bottom:0px ; 
          font-size:11px ; vertical-align:top ; font-width:bold}
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
  { setCookie ('select_period', (getCookie ('select_period') || 0) + 10) ; }
  else
  { setCookie ('select_period', element.selectedIndex) ; }

  // alert (document.cookie) ;
  window.location.reload();
}

function showCount (count, percentage)
{
  //  if (++ calls == 1)
  // { alert ('showCount() show_count_short '+show_count_short) ; }

  if (days_in_month == 0) // workaround, should not happen 
  { days_in_month = 30 ; }

       if (count == 0)                    { count = '-' ; }
  else if (show_count_daily)              { ; }
  else if (show_count_monthly_normalized) { count *= 30 ; }
  else if (show_count_monthly_raw)        { count *= days_in_month ; }

  if (show_count_short)
  {
         if (count >= 100000000)  { count = Math.round (count/1000000) + nbsp + char_million ; }
    else if (count >= 1000000)    { count = (Math.round  (count/100000) / 10) + nbsp + char_million ; }
    else if (count >= 10000)      { count = Math.round  (count/1000) + nbsp + char_thousand ; }
    else if (count >= 999)        { count = (Math.round  (count/100) / 10) + nbsp + char_thousand ; }
    else                          { count = Math.round (count) ; }

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

sub HtmlBodyTop
{
  my $html = <<__HTML_BODY_TOP__ ;

<table width=100%>
<tr>
<td class=hl>
  <h2>HEADER</h2>
  <b>DATE</b>
<p>LINKS

</td>
<td class=hr>
  <a href='://stats.wikimedia.org/archive/squid_reports'>Archive</a> / 
  <a href='://stats.wikimedia.org'>Wikistats main page</a>
</td>
</tr>
</table>

__HTML_BODY_TOP__

return ($html) ;
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

sub WriteJsFileVisualizationInfo
{
  my $yyyymm = shift ;
  my ($yyyy,$mm) = split ('-', $yyyymm) ;
  my @months = qw (January February March April May June July August September October November December) ;
  my $month_year = $months [$mm-1] . " $yyyy" ;  

  my $file_js = "$path_reports/datamaps-views-month.js" ;
  print "print to $file_js: 'data_month = \"$month_year\"'\n\n" ;
  open  JSFILE, '>', $file_js ; 
  print JSFILE "data_month = \"$month_year\"" ;
  close JSFILE ;
}

sub WriteCsvDataMapInfoPerCountry
{
  &LogSub ("WriteCsvDataMapInfoPerCountry\n") ;

  &AddExtraCountryNames_iso3 ;

  $folder_scripts = "//stats.wikimedia.org/wikimedia/squids/scripts/" ;
  $html =~ s/WORLDMAP_D3/<script src="$folder_scripts\/d3.min.js"><\/script>\n<script src="$folder_scripts\/topojson.min.js"><\/script>\n<script src="$folder_scripts\/datamaps.world.hires.min.js"><\/script>\n<script src="$folder_scripts\/options.js"><\/script>\n/ ;

  my $d3_csv_countries = "ISO,views_per_person,total_views_as_perc_of_world_views,total_views,population,perc_people_connected,flag_icon,breakdown_per_language\n" ; 

  my $json_flags = "[\n" ;
  my $csv_flags  = "country_iso3,flag_image\n" ;

  foreach $country (keys_sorted_by_value_num_desc %requests_recently_per_country)
  {
    %requests_per_language = %{$requests_recently_per_country_per_language {$country}} ;
    @languages = keys_sorted_by_value_num_desc %requests_per_language ;

    $requests_this_country  = $requests_recently_per_country {$country} ;

    $country_meta = $country_meta_info {$country} ;

    my ($link,$icon,$population,$connected) = split (',', $country_meta) ;

    $population  =~ s/_//g ;
    $connected   =~ s/_//g ;
    $requests_this_country2 = &i2KM ($requests_this_country * 1000) ; # input is in 1000's 
    $connected2  = '--' ;
    $requests_per_capita = '--' ;
     
    if ($population> 0)
    { 
      $connected2 = sprintf ("%.0f", 100*$connected/$population) .'%' ; 
      $requests_per_capita = &i2SigDec ($requests_this_country * 1000 / $population) ;
    } 

    $perc = 'n.a.' ;
    if ($requests_recently_all > 0)
    { $perc = &Percentage ($requests_this_country / $requests_recently_all) ; }

    ($link_country,$icon,$population) = &CountryMetaInfo ($country) ;
    $population2 = &i2KM ($population) ;

    $code_iso3 = $country_names_iso3 {$country} ;
    if ($code_iso3 eq '')
    { 
      print "no iso3166 code for '$country'\n" ; 
      $code_iso3 = 'XXX' ; 
    }
    
    ($perc2 = $perc) =~ s/\%// ; 

    $icon =~ s/"/'/g ;
    $d3_csv_countries  .= "$code_iso3,$requests_per_capita,$perc2,$requests_this_country2,$population2,$connected2,," ;  

    $json_flags .= "{ \"ISO3\": \"$code_iso3\", \"flag\": \"$icon\" },\n" ;
    $icon =~ s/,/\%2C/g ;
    $csv_flags  .= "$code_iso3,$icon\n" ;

    $perc_tot = 0;
    $requests_used = 0 ;
    $lines = 0 ;
    for ($l = 0 ; $l < 100 ; $l++)
    {
      $lines ++ ;
   #  $odd_even = $lines % 2 == 0 ? 'even' : 'odd' ;

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
      ($perc2 = $perc) =~ s/\%// ;
  
      if ($perc2 >= 0.1)     
      { $requests_perc {$languages [$l]} .= "$code_iso3:$perc2;" ; }

      $language = $languages [$l] ;
      if ($out_languages {$language} ne "")
      { $language = $out_languages {$language} ; }
      if (length ($language) > 20)
      { $language =~ s/ .*$// ; }

 #    $bar = &Perc2Bar ($perc,'green',10) ;

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

      $d3_csv_countries  .= "${languages [$l]}:$language2:$perc|" ; 
    }

    if ($perc_tot > 100) { $perc_tot = 100 ; }
    $requests_other = $requests_all_languages - $requests_used ;
    $perc_other = sprintf '%.1f', 100 - $perc_tot ;
    if (($requests_other > 0) && ($perc_other > 0))
    { $d3_csv_countries  .= "&nbsp;:Other:$perc_other\%" ; }

    $d3_csv_countries  =~ s/\|$// ; 
    $d3_csv_countries .= "\n" ;
  }
 
  $d3_csv_countries  =~ s/\|$// ; 

  $json_flags =~ s/,$// ;
  $json_flags .= "]\n" ;

  &PrintJson ($json_flags, "$path_reports/datamaps-flags.json") ; # no longer used (but kept) as d3.json is async 
  &PrintCsv  ($csv_flags,  "$path_reports/datamaps-flags.csv") ;  

  $d3_csv_countries =~ s/\&nbsp;/^/g ; # compact further
  &PrintCsv ($d3_csv_countries, "$path_reports/datamaps-views-per-country.csv") ; 
}

sub WriteCsvDataMapInfoPerRegion
{
  &LogSub ("WriteCsvDataMapInfoPerRegion\n") ;

  my ($sample_rate) = @_ ;
  my ($link_country,$population,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot) ;
  my (@index_countries,@csv_countries) ;
  my $views_edits_lc = lc $views_edits ;
  my $views_edits_lcf = ucfirst $views_edits_lc ;

  my $d3_csv_rows_max = 50 ;

  $requests_tot = 0 ;

  undef %requests_per_region ;

  foreach $country_code (keys_sorted_by_value_num_desc %requests_recently_per_country_code)
  {
    my ($country,$code) = split ('\|', $country_code) ;
    my $code_iso3 = $country_names_iso3 {$country} ;

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
  # $north_south_name =~ s/^N$/<font color=#000BF7><b>N<\/b><\/font>/ ;
  # $north_south_name =~ s/^S$/<font color=#FE0B0D><b>S<\/b><\/font>/ ;

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
    #if ($perc_share_total2 =~ /0\.0/)
    #{ $perc_share_total2 = '<font color=#CCC><small><&nbsp;0.1%</small></font>' ; }

    &Percentage ($requests_this_country / $requests_recently_all) ; 
    
    $perc_tot += $perc_share_total ;

    # $bar  = "&nbsp;" ;
    # $bar2 = "&nbsp;" ;
    # if (int ($perc_share_total * 10) > 0)
    # {
    #   $bar = "<img src='redbar.gif' width=" . (int ($perc_share_total * 10)) . " height=15>" ; 
    #   $bar2 = "<img src='redbar.gif' width=" . (int ($perc_share_total * 10)) . " height=12>" ;
    # } 

    $perc_connected = ".." ;
    if ($population > 0)
    { $perc_connected = sprintf ("%.0f", 100 * $connected / $population) .'%' ; }

    $country2 = &ShortenForHoverbox ($country) ;

    push @csv_countries, "$country2,$code,$requests_this_country2,$population,$connected,$perc_connected,$requests_per_connected_person,$perc\n" ;

    $population2 = &i2KM2 ($population) ;
    $connected2  = &i2KM2 ($connected) ;
    $requests_this_country2 = &i2KM2 ($requests_this_country2) ;

    if ($population_tot > 0)
    { $perc_population = &Percentage ($population / $population_tot) ; }

  #  if (($region_code eq 'AF') || ($region_code eq 'AS') || ($region_code eq 'EU'))
  #  { $icon = "<sub><sub>$icon</sub></sub>" ; }
    
    $link_country =~ s/<\/?a[^>]*>//g ;
    $link_country =~ s/alt=['"]+ // ;
    $link_country =~ s/Democratic Republic of the Congo/Congo Dem. Rep./ ;

#    $bar = &Perc2Bar ($perc_share_total,'red',10) ;

    $d3_csv_entries {$region_code} ++ ;
    $index =  $d3_csv_entries {$region_code} ;
    
    $d3_csv_regions2 {$region_code} .= 
      "$index:$code_iso3:$country2:$north_south_name:$population2:$perc_population:$perc_connected:$requests_this_country2:$perc_share_total2|" ;
   
    $d3_csv_entries {'W'} ++ ;
    if ($d3_csv_entries {'W'} <= $d3_csv_rows_max)
    {
      $index =  $d3_csv_entries {'W'} ;

      $d3_csv_regions2 {'W'} .= 
      "$index:$code_iso3:$country2:$north_south_name:$population2:$perc_population:$perc_connected:$requests_this_country2:$perc_share_total2|" ;
    }

    $d3_csv_entries {$north_south_code} ++ ;
    if ($d3_csv_entries {$north_south_code} <= $d3_csv_rows_max)
    {
      $index =  $d3_csv_entries {$north_south_code} ;

      $d3_csv_regions2 {$north_south_code} .= 
        "$index:$code_iso3:$country2:$north_south_name:$population2:$perc_population:$perc_connected:$requests_this_country2:$perc_share_total2|" ;
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
    $precision = $views_edits =~ /edit/i ? "%.4f" : "%.1f" ; 
    $requests_per_connected_person_tot = sprintf ($precision, $requests_tot / $connected_tot) ; 
  }

  $perc_connected_tot = ".." ;
  if ($population_tot > 0)
  { $perc_connected_tot = sprintf ("%.0f", 100 * $connected_tot / $population_tot) .'%' ; }

  push @csv_countries, "world,*,$requests_tot,$population_tot,$connected_tot,$perc_connected_tot,$requests_per_connected_person_tot,100%\n" ;

  $requests_tot2   = &i2KM2 ($requests_tot) ;
  $population_tot2 = &i2KM2 ($population_tot) ;
  $connected_tot2  = &i2KM2 ($connected_tot) ;

  $d3_csv_regions2 {'W'} =~ s/"/'/g ; 
  $d3_csv_regions  {'W'} = "$population_tot2,100%,$connected_tot2,$perc_connected_tot,$requests_tot2,$requests_per_connected_person_tot,100%," .
                                $d3_csv_regions2 {'W'} . "\n" ; 
  foreach my $region (qw (N S AF AS EU CA NA SA OC XX))
  {
    $d3_csv_regions2 {$region} =~ s/\|$// ; 

    $population_region = $population_per_region {$region} ;
    $connected_region  = $connected_per_region  {$region} ;
    $requests_region   = $requests_per_region   {$region} ;
    $requests_region2  = $requests_per_region2  {$region} ; 

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

    if ($region ne 'XX')
    { $d3_csv_regions {$region} = "$population_region,$perc_population_region,$connected_region,$perc_connected_region,$requests_region2,$requests_per_connected_person,$perc_share_total," . $d3_csv_regions2 {$region} . "\n" ; }
  }

  # for best contrast some colors differ per bubble (we know their position and hence the color of their background, e.g. ocean, dark country) 
  $d3_csv_regions  = "name,label,latitude,longitude,borderColor,highlightBorderColor,population,perc_population,connected,perc_connected,requests,requests_per_connected_person,perc_share_total,breakdown_by_country,viewfreq_per_country\n" ; 

  $d3_csv_regions .= "World,W,44,-175,black,black,"              . $d3_csv_regions {'W'}  . "\n" ;
  $d3_csv_regions .= "Global North,GN,34,-175,black,black,"      . $d3_csv_regions {'N'}  . "\n" ;
  $d3_csv_regions .= "Global South,GS,34,-157,black,black,"      . $d3_csv_regions {'S'}  . "\n" ;
  $d3_csv_regions .= "North America,NA,49,-104,black,blue,"      . $d3_csv_regions {'NA'} . "\n" ;
  $d3_csv_regions .= "Central America,CA,12.6,-88,black,black,"  . $d3_csv_regions {'CA'} . "\n" ;
  $d3_csv_regions .= "South America,SA,-13.5,-62,black,black,"   . $d3_csv_regions {'SA'} . "\n" ;
  $d3_csv_regions .= "Europe,EU,52.4,13.4,black,black,"          . $d3_csv_regions {'EU'} . "\n" ;
  $d3_csv_regions .= "Asia,AS,42.3,102.7,white,white,"           . $d3_csv_regions {'AS'} . "\n" ;
  $d3_csv_regions .= "Africa,AF,15.3,22.8,white,white,"          . $d3_csv_regions {'AF'} . "\n" ;
  $d3_csv_regions .= "Oceania,OC,-25,130,white,black,"           . $d3_csv_regions {'OC'} . "\n" ;
  $d3_csv_regions =~ s/\n$// ; # avoid empty line at end

  $d3_csv_regions =~ s/\&nbsp;/^/g ; # compact further
  &PrintCsv ($d3_csv_regions, "$path_reports/datamaps-views-per-region.csv") ;
}

sub WriteCsvDataMapInfoPerLanguage
{
  my ($sample_rate) = @_ ;

  my ($link_country,$population,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot) ;

  foreach $country_code_iso2 (keys %country_names)
  { 
    $country_name = $country_names {$country_code_iso2} ;
    $country_codes_iso2 {$country_name}  = $country_code_iso2 ; 
  # print "1 code $country_code_iso2 name $country_name\n" ;
  }

  # for best contrast some colors differ per bubble (we know their position and hence the color of their background, e.g. ocean, dark country) 
# $d3_csv_languages  = "name,label,population,perc_population,connected,perc_connected,requests,requests_per_connected_person,perc_share_total,breakdown_by_language,viewfreq_per_country\n" ; 
  $d3_csv_languages  = "name,label,population,perc_population,requests,breakdown_by_language,viewfreq_per_country\n" ; 

  print "\n" ;
  for $lang (sort {$requests_recently_per_language {$b} <=> $requests_recently_per_language {$a}} keys %requests_recently_per_language)
  {
    $count_languages++ ;
    last if $count_languages > 200 ; # approximate number of active wikipedias, adjust when needed

    ($table_rows_per_country, $viewfreq_per_country) = &PrepLanguageBubbleDetailsPerCountry ($lang, $sample_rate) ;
    $lang_uc = uc ($lang) ;
 #   $out_urls      {$code} = $url ;
    $language_name = $out_languages {$lang} ;
 #   $out_article   {$code} = "://en.wikipedia.org/wiki/" . $out_languages {$key} . "_language" ;
 #   $out_article   {$code} =~ s/ /_/g ;
 #   $out_speakers  {$code} = $speakers ;
 #   $out_regions   {$code} = $regions ;
    
    $speakers = &i2KM (1000000 * $out_speakers {$lang}) ;
    $perc_speakers = &Percentage (1000000 * $out_speakers {$lang} / $population_tot) . ' of ' . &i2KM ($population_tot) ;
    $requests = &i2KM ($sample_rate * $requests_recently_per_language {$lang}) ;
   
    # print "$count_languages $lang:" . $requests_recently_per_language {$lang} . "\n" ; 

    $perc_per_country = $requests_perc {$lang} ;

    next if $perc_per_country eq '' ; # no country where this language scores >= 0.1% of page views? skip! 
    # print "lang $lang perc_per_country $perc_per_country\n" ;

    $d3_csv_languages .= "\#$count_languages: $language_name Wikipedia,$lang_uc," . 
                       "$speakers,$perc_speakers,$requests,$table_rows_per_country,$perc_per_country\n" ;
  }

  $d3_csv_languages =~ s/\&nbsp;/^/g ; # compact further
  &PrintCsv ($d3_csv_languages, "$path_reports/datamaps-views-per-language.csv") ;
}

sub PrepLanguageBubbleDetailsPerCountry 
{
  my ($language,$sample_rate) = @_ ;
  my ($html, $viewfreq_per_country) ; ;

  my %totals_per_country  = %{$requests_recently_per_language_per_country {$language}} ;
  my $totals_per_language = $requests_recently_per_language {$language} * $sample_rate ;

  my $countries = 0 ;
# print "\n\nlang $language\n" ; 
  foreach $country_name (sort {$totals_per_country {$b} <=> $totals_per_country {$a}} keys %totals_per_country)
  {

    $countries ++ ;
    $odd_even = $countries % 2 == 0 ? 'even' : 'odd' ;  
    last if $countries > $d3_csv_rows_max ; # max rows to show in hover box 
    
    $country_meta = $country_meta_info {$country_name} ;
    my ($link,$icon,$population,$connected) = split (',', $country_meta) ;

    $country_code_iso2 = $country_codes_iso2 {$country_name} ;
    $country_code_iso3 = $country_names_iso3 {$country_name} ;

    $region_code      = $region_codes      {$country_code_iso2} ;
    $north_south_code = $north_south_codes {$country_code_iso2} ;

    $requests = $requests_recently_per_language_per_country {$language} {$country_name} * $sample_rate ;
    
    $share_requests = '-' ;
    if ($totals_per_language > 0)
    { $share_requests = &Percentage ($requests / $totals_per_language) ; }
    ($share_requests2 = $share_requests) =~ s/\%// ;

    $requests = i2KM ($requests) ;

    $country2 = &ShortenForHoverbox ($country_name) ;

    $html .= "$countries:$country_code_iso3:$country2:$north_south_code:$region_code:$requests:$share_requests|" ;

    $viewfreq_per_country .= "$country_code_iso3:$share_requests2;" ; # qqqq
  }

  $viewfreq_per_country =~ s/;$// ;
  $html =~ s/\|$// ;

  return ($html, $viewfreq_per_country) ;
}

sub RegionCodeToText
{
  my $region = shift ;

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

  return $region ;
}


sub ShortenForHoverbox
{
  my $country = shift ;

  $country =~ s/Unknown\d+/Unknown/ ; # variations for debug only
  $country =~ s/Moldova, Republic of/Moldova/ ;
# $country =~ s/Korea, Republic of/South Korea/ ;
# $country =~ s/Korea, Democratic People's Republic of/North Korea/ ;
  $country =~ s/Iran, Islamic Republic of/Iran/ ;
  $country =~ s/United Arab Emirates/UAE/ ;
  $country =~ s/Bosnia and Herzegovina/Bosnia/ ;
  $country =~ s/Congo - The Democratic Republic of the/Dem. Rep. of the Congo/ ;
# $country =~ s/Congo - The Democratic Republic of the/Congo Dem. Rep./ ;
# $country =~ s/^Congo$/Republic of the Congo/ ;
  $country =~ s/Syrian Arab Republic/Syria/ ;
  $country =~ s/Tanzania, United Republic of/Tanzania/ ;
  $country =~ s/Libyan Arab Jamahiriya/Libya/ ;
  $country =~ s/C..?te d'Ivoire/C&ocirc;te d'Ivoire/ ;
  $country =~ s/Serbia/Republic of Serbia/ ;
  $country =~ s/Lao People's Democratic Republic/Laos/ ;
# $country =~ s/S.?o Tom.? and Pri.?ncipe/S&#227;o Tom&#233; and Pr&#237;ncipe/ ;
  $country =~ s/S.*?o Tom.*? and Pr.*?ncipe/S&#227;o Tom&#233; and P../ ;
  $country =~ s/R.*?union/Réunion/ ;
  $country =~ s/R..?union/Réunion/ ;
  $country =~ s/Cura..?ao/Cura&#231;ao/ ;
  $country =~ s/United States/US/ ;
  $country =~ s/United Kingdom/UK/ ;
  $country =~ s/Democratic/Dem./ ;
  $country =~ s/Republic/Rep./ ;
  $country =~ s/Territories/Terr./ ;
  $country =~ s/Northern Mariana Islands/Northern Mariana Is./ ;

  return $country ;
}

