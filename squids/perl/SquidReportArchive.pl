#!/usr/bin/perl

# for country reports fix:
# https://bugzilla.wikimedia.org/show_bug.cgi?id=46205   fixed
# https://bugzilla.wikimedia.org/show_bug.cgi?id=46267
# https://bugzilla.wikimedia.org/show_bug.cgi?id=46277
# https://bugzilla.wikimedia.org/show_bug.cgi?id=46289   fixed

# -v -q 2012q3 -c -i "w:/# out stat1/squid/csv" -o "w:/# out test/squid/reports" -l . -a "w:/# out stat1/squid/csv/meta"

# sub ReadInputCountriesMonthly reads $path_csv_squid_counts_monthly (/a/wikistats_git/squids/csv/SquidDataVisitsPerCountryMonthly.csv)

  $| = 1; # Flush output

  use lib "/home/ezachte/wikistats/squids/perl" ;
  use SquidReportArchiveConfig ;
  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (2) ;

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
  # 'http://en.wikipedia.org/wiki/List_of_countries_by_population'
  # 'http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'
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

  $file_html_crawlers     = "SquidReportCrawlers.htm" ;
  $file_html_methods      = "SquidReportMethods.htm" ;
  $file_html_origins      = "SquidReportOrigins.htm" ;
  $file_html_opsys        = "SquidReportOperatingSystems.htm" ;
# $file_html_opsys_html   = "SquidReportOperatingSystemsHtmlOnly.htm" ;
  $file_html_scripts      = "SquidReportScripts.htm" ;
  $file_html_skins        = "SquidReportSkins.htm" ;
  $file_html_user_agents  = "SquidReportUserAgents.htm" ;
  $file_html_devices      = "SquidReportDevices.htm" ;
  $file_csv_user_agents_out = "SquidReportUserAgents.csv" ;
  $file_html_requests     = "SquidReportRequests.htm" ;
  $file_html_google       = "SquidReportGoogle.htm" ;
  $file_html_clients      = "SquidReportClients.htm" ;
# $file_html_clients_html = "SquidReportClientsHtmlOnly.htm" ;
  $file_html_countries_info = "SquidReportCountryData.htm" ;
  $file_html_countries_browser = "SquidReportCountryBrowser.htm" ;
  $file_html_countries_os = "SquidReportCountryOs.htm" ;
# $file_html_countries_device = "SquidReportCountryDevice.htm" ;
  $file_html_user_agents_timed = "SquidReportUserAgentsTimed.htm" ;
  $file_html_browsers_timed = "SquidReportBrowsersTimed.htm" ;
  $file_html_devices_timed = "SquidReportDevicesTimed.htm" ;
  $file_csv_user_agents   = "SquidReportUserAgents.csv" ;
# names till 2010-07-01
#
#  $file_csv_crawlers      = "SquidDataCrawlers.csv" ;
#  $file_csv_methods       = "SquidDataMethods.csv" ;
#  $file_csv_origins       = "SquidDataOrigins.csv" ;
#  $file_csv_opsys         = "SquidDataOpSys.csv" ;
#  $file_csv_requests      = "SquidDataRequests.csv" ;
#  $file_csv_scripts       = "SquidDataScripts.csv" ;
#  $file_csv_google        = "SquidDataSearch.csv" ;
#  $file_csv_skins         = "SquidDataSkins.csv" ;
#  $file_csv_clients       = "SquidDataClients.csv" ;
#  $file_csv_google_bots   = "SquidDataGoogleBots.csv" ;
#  $file_csv_indexphp      = "SquidDataIndexPhp.csv" ;
#  $file_csv_countries_languages_visited = "SquidDataCountriesLanguagesVisited.csv" ;
#  $file_csv_countries_timed   = "SquidDataCountriesTimed.csv" ;
#  $file_csv_browser_languages = "SquidDataLanguages.csv" ;

  $file_csv_crawlers      = "public/SquidDataCrawlers.csv" ;
  $file_csv_methods       = "public/SquidDataMethods.csv" ;
  $file_csv_origins       = "public/SquidDataOrigins.csv" ;
  $file_csv_opsys         = "public/SquidDataOpSys.csv" ;
  $file_csv_requests      = "public/SquidDataRequests.csv" ;
  $file_csv_scripts       = "public/SquidDataScripts.csv" ;
  $file_csv_google        = "public/SquidDataSearch.csv" ;
  $file_csv_skins         = "public/SquidDataSkins.csv" ;
  $file_csv_clients       = "public/SquidDataClients.csv" ;
  $file_csv_google_bots   = "public/SquidDataGoogleBots.csv" ;
  $file_csv_indexphp      = "public/SquidDataIndexPhp.csv" ;
  $file_csv_browser_languages = "public/SquidDataLanguages.csv" ;
  $file_csv_user_agents   = "public/SquidDataUserAgents.csv" ;
  $file_csv_devices       = "public/SquidDataDevices.csv" ;
  $file_csv_countries_info= "public/SquidDataCountriesInfo.csv" ;
# $file_csv_useragents_time= "SquidDataUserAgentsMonths.csv" ;

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

  $google_ip_ranges = "<b>IP ranges:</b> known ip ranges for Google are 64.233.[160.0-191.255], 66.249.[64.0-95.255], 66.102.[0.0-15.255], 72.14.[192.0-255.255], <br>74.125.[0.0-255.255], " .
  "209.085.[128.0-255.255], 216.239.[32.0-63.255] and a few minor other subranges</small><p>\n" ;

  &OpenLog ;
  &PrepHtml ($reports_set_basic, $sample_rate) ;
  &SetPeriod ; # now date range derived from which folders found

# &ReadDate ; date range was read from csv file
  $ShowDevices      = $false ; # disabled on request of Mobile Team
  $ShowDevicesTimed = $false ; # disabled on request of Mobile Team

  foreach $path_process (@dirs_process)
  {
    $days_input_found ++ ;

    &LogDetail ("\nRead input from $path_process\n") ;
    &ReadInputClients ;
  # &ReadInputCrawlers ; # 16 April, 2015, report broken, much too many odd user agent strings
    &ReadInputMethods ;
    &ReadInputMimeTypes ;
    &ReadInputOpSys ;
    if ($ShowDevices || $ShowDevicesTimed)
    { 
      my $DevicesRead = &ReadInputDevices ;
      if (! $DevicesRead)
      {
        $ShowDevices      = $false ;
        $ShowDevicesTimed = $false ;	
      }
    } 
    &ReadInputOrigins ;
    &ReadInputScripts ;
    &ReadInputGoogle ;
    &ReadInputSkins ;
    &ReadInputIndexPhp ;
    &ReadInputBrowserLanguages ;
    &ReadInputCountriesTimed ;
    &ReadInputUseragents ;
    &ReadInputCountriesInfo ;
  }

  &ReadCountryCodes ;
  if ($days_input_found > 0)
  {
    &LogDetail ("\nDays input = $days_input_found\n") ;
    $multiplier = 1 / $days_input_found ;
    &LogDetail ("\nMultiplier = " . sprintf ("%.4f", $multiplier) . "\n") ;
  }
  else { &LogDetail ("\nDays input = 0 (zero!)\n") ; }

  &WriteCsvCountriesTimed ;
  &WriteCsvCountriesGoTo ;

  foreach $key (keys_sorted_alpha_desc %edit_submit)
  { &LogDetail ("YYY " . sprintf ("%5d", $edit_submit {$key}) . ": $key\n") ; }

  foreach $total (keys_sorted_by_value_num_desc %edit_submits)
  { &LogDetail ("total $total: ${edit_submits {$total}} \n") ; }

  &LogDetail ("\n\n") ;

  foreach $domain (keys_sorted_by_value_num_desc %edit_submit_bot_sort)
  {
    $cnt = $edit_submit_bot_sort {$domain} ;

    last if $cnt < 100 ;

    &LogDetail ("DOMAIN $domain total $cnt\n") ;
    foreach $key (sort keys %{$edit_submit_bot {$domain}})
    { &LogDetail (sprintf ("%5d", $edit_submit_bot {$domain} {$key}) . ": $key\n") ; }
  # { print "$key: ${edit_submit_bot {$domain} {$key}}, " ; }
    &LogDetail ("\n") ;
  }
  &LogDetail ("\n\n") ;
  foreach $agent (keys_sorted_by_value_num_desc %edit_submit_bot_agent_sort)
  {
    $cnt = $edit_submit_bot_agent_sort {$agent} ;

    last if $cnt < 25 ;

    &LogDetail ("AGENT $agent total $cnt\n") ;
    foreach $key (sort keys %{$edit_submit_bot_agent {$agent}})
    { &LogDetail (sprintf ("%5d", $edit_submit_bot_agent {$agent} {$key}) . ": $key\n") ; }
  # { print "$key: ${edit_submit_bot {$domain} {$key}}, " ; }
    &LogDetail ("\n") ;
  }



#  foreach $key (keys_sorted_by_value_num_desc %edit_submit_bot_agent)
# { print "AGENT: " .sprintf ("%5d", $edit_submit_bot_agent {$key}) . ": $key\n" ; }
#  print "\n\n" ;
#  foreach $key (keys_sorted_by_value_num_desc %edit_submit_subparms)
#  {
#    $count = $edit_submit_subparms {$key} ;
#
#    last if $count < 5 ;
#
#    ($subparm, $referer) = split (',', $key) ;
#    print "ZZZ " . sprintf ("%5d", $count) . ": $referer, $subparm\n" ;
#  }
  &CalcPercentages ;
  &NormalizeCounts ;
  &SortCounts ;

  &WriteReportClients ;
  &WriteReportCrawlers ;

  &WriteReportMethods ;
  &WriteReportMimeTypes ;
  &WriteReportOpSys ;
  if ($ShowDevices) 
  { &WriteReportDevices } ;
  &WriteReportOrigins ;
  &WriteReportScripts ;
  &WriteReportGoogle ;
  &WriteReportSkins ;
  &WriteReportUserAgents ;
  &WriteReportCountriesInfo ;
  &WriteReportCountryOpSys ;
  &WriteReportCountryBrowser ;
  &WriteReportUserAgentsTimed ;
  &WriteReportBrowsersTimed ;
  if ($ShowDevicesTimed) 
  { &WriteReportDevicesTimed } ;
  &WriteCsvGoogleBots ;
  &WriteCsvBrowserLanguages;

# &WriteCsvCountriesTimed ;
# &WriteCsvCountriesTargets ;
  close "FILE_LOG" ;

  print "\nSuspect mime codes skipped:\n\n" ;
  foreach $mime (sort keys %suspect_mime_codes)
  {
    print $suspect_mime_codes {$mime} . ': ' . $mime . "\n" ; 
  } 
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

  if ($render_svg_input) # undefined = false
  {
    foreach $week (sort {$a <=> $b} keys %changes_per_week_per_country_code)
    { &WriteCsvSvgFilePerCountryOverview ($views_edits, $week, \%changes_per_week_per_country_code, 200, "Wikipedia " . lc $views_edits . ", weekly trend") } ;

    foreach $week (sort {$a <=> $b} keys %requests_per_week_per_country_code)
    { &WriteCsvSvgFilePerCountryOverview ($views_edits, $week, \%requests_per_week_per_country_code, $max_requests_per_connected_us_week, "Wikipedia " . lc $views_edits . " per person") } ;
    foreach $yyyymm (sort keys %yyyymm_)
    { &WriteCsvSvgFilePerCountryOverview ($views_edits, $yyyymm, \%requests_per_month_per_country_code, $max_requests_per_connected_us_month, "Wikipedia " . lc $views_edits . " per person") } ;
  }

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
           "<font color=red>No data available</font> / " .
           "<b>Page Edits Per Wikipedia Language - </b> " .
           "<font color=red>No data available</font>" ;

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

  $header.=  "<body bgcolor='\#FFFFDD'>\n$form\n<hr>" .
          # "&nbsp;This analysis is based on a 1:1000 sampled server log (squids) X1000\nALSO<br>" ; # X1000 obsolete (may become a toggle ?)
          # "$run_time&nbsp;This analysis is based on a $header_sample_rate server log (squids)<p>\nALSO<p>&nbsp;<a href='#errata'>Notes on reliability of these data<\/a><br><br>NOTICE" ;
            "$run_time<p>\nALSO<p>NOTICE" ;

  $headerwithperc.=  "<body bgcolor='\#FFFFDD'>\n$formwithperc\n<hr>" .
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
  #           "</font><p>" ;
  }
  else
  {
    $notice = "<font color=red>" .
            # "<h3>Warning: all recent Wikimedia traffic analysis reports have been generated from old scripts.</h3><p>" .
	    # "The scripts are orphaned, and have not been maintained for at least 6 months. Many bugs are considerably older.<br></font>" .
              "&nbsp;<a href='https://phabricator.wikimedia.org/maniphest/query/iJTKCpmjB0A9/#R'>Unresolved bugs</a></font> " .
              "<p>" ;
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
  $out_myname_ae = "André Engels" ;
  $out_mymail_ez = "ezachte\@### (no spam: ### = wikimedia.org)" ;
  $out_mymail_ae = "analytics\@lists.wikimedia.org" ;
  $out_mysite_ez = "http://infodisiac.com/" ;

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


  $errata = 'No data loss or anomalies reported' ; # remove when also applicable to André's report (all reports show same text about input anomalies)

  $colophon_ae = "<p><a id='errata' name='errata'><b>Errata:</b> $errata</a><p>\n" .
               $out_generated . date_time_english (time) . "\n<br>" .
               $out_author . ":" . $out_myname_ae . '<br>' .
               "$out_mail: $out_mymail_ae<br>\n" .
               "$out_license<p>" .
               "$out_explorer" .
               "</small>\n" .
               "</body>\n" .
               "</html>\n" ;

  $dummy_requests    = "<font color=#808080>Destination/Mime</font>" ;
  $dummy_origins     = "<font color=#000060>Origin</font>" ;
  $dummy_methods     = "<font color=#000060>Methods</font>" ;
  $dummy_scripts     = "<font color=#000060>Scripts</font>" ;
  $dummy_skins       = "<font color=#000060>Skins</font>" ;
  $dummy_user_agents = "<font color=#000060>User Agents</font>" ;
  $dummy_crawlers    = "<font color=#000060>Crawlers</font>" ;
  $dummy_opsys       = "<font color=#000060>Op.Sys.</font>" ;
  $dummy_browsers    = "<font color=#000060>Browsers</font>" ;
  $dummy_devices     = "<font color=#000060>Devices</font>" ;
  $dummy_google      = "<font color=#000060>Google</font>" ;
  $dummy_countries   = "<font color=#000060>Country data</font>" ;
  $dummy_ua_trends   = "<font color=#000060>Traffic trends</font>" ;
  $dummy_countries_useragents   = "<font color=#000060>User agents</font>" ;
  $dummy_countries_browsers     = "<font color=#000060>Browsers</font>" ;
  $dummy_countries_os           = "<font color=#000060>Operating systems</font>" ;
  $dummy_countries_devices      = "<font color=#000060>Mobile devices</font>" ;
  $dummy_countries              = "<font color=#000060>Countries</font>" ;

  $link_requests    = "<a href='$file_html_requests'>Destination/Mime</a>" ;
  $link_origins     = "<a href='$file_html_origins'>Origin</a>" ;
  $link_methods     = "<a href='$file_html_methods'>Methods</a>" ;
  $link_scripts     = "<a href='$file_html_scripts'>Scripts</a>" ;
  $link_skins       = "<a href='$file_html_skins'>Skins</a>" ;
  $link_user_agents = "<a href='$file_html_user_agents'>User agents</a>" ;
  $link_crawlers    = "<a href='$file_html_crawlers'>Crawlers</a>" ;
  $link_opsys       = "<a href='$file_html_opsys'>Op.Sys.</a>" ;
  $link_browsers    = "<a href='$file_html_clients'>Browsers</a>" ;
  $link_devices     = "<a href='$file_html_devices'>Mobile devices</a>" ;
  $link_google      = "<a href='$file_html_google'>Google</a>" ;
  $link_countries   = "<a href='$file_html_countries_info'>Country data</a>" ;
  $link_ua_trends   = "<a href='$file_html_user_agents_timed'>Traffic trends</a>" ;
  $link_countries_useragents =  "<a href='$file_html_countries_info'>User agents</a>" ;
  $link_countries_browsers =  "<a href='$file_html_countries_browser'>Browsers</a>" ;
  $link_countries_os =  "<a href='$file_html_countries_os'>Operating systems</a>" ;
  $link_countries_devices =  "<a href='$file_html_countries_device'>Mobile devices</a>" ;
  $link_countries_overview = "<a href='SquidReportPageViewsPerCountryOverview.htm'>Overview</a>" ;
  $link_countries_projects = "<a href='SquidReportPageViewsPerCountryBreakdown.htm'>Projects</a>" ;
  $link_countries_trends = "<a href='http://stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryTrends.htm'>Trends</a>" ;
  $link_trends_useragents = "<a href='$file_html_user_agents_timed'>User agents</a>" ;
  $link_trends_countries = "<a href='http://stats.wikimedia.org/wikimedia/squids/SquidReportPageViewsPerCountryTrends.htm'>Countries</a>" ;
  $link_trends_browsers = "<a href='$file_html_browsers_timed'>Browsers</a>" ;
  $link_trends_devices = "<a href='$file_html_devices_timed'>Devices</a>" ;
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

sub ReadInputClients
{
  &LogSub ("ReadInputClients\n") ;

  my $file_csv = "$path_process/$file_csv_clients" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputClients: file $file_csv not found!!!") ; }
  open CSV_CLIENTS, '<', $file_csv ;

  while ($line = <CSV_CLIENTS>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp ($line) ;

    $mimecat = '' ; # page/image/other
    if ($line =~ /^E/)
    {
      ($rectype, $engine, $count,$mimecat) = split (',', $line) ;

      #next if ($engine !~ /^Gecko/) && ($engine !~ /^AppleWebKit/) ;

      if ($engine !~ / \d/)
      { $engine =~ s/\// / ; }

      #if ($engine =~ /AppleWebKit/)
      #{
      #  $engine =~ s/AppleWebKit\//AppleWebKit / ; # fix
      #  $engine =~ s/Safari\/\d+/Safari/ ; # fix input
      #  $engine =~ s/(?:|iPad|iPod|iPhone) Mozilla.*$/iPod)/i ; # fix input
      #  ($engine2 = $engine) =~ s/\s*\/?\d\d\d// ;
      #  $webkit_engines {$engine2} += $count ;

      # $webkit_total_engines {$engine} += $count ;
      #}

      $engines {$engine} += $count ;
      $engine =~ s/\/.*$// ;
      $engine =~ s/ .*$// ;
      $total_engines {$engine} += $count ;
    }
    elsif ($line =~ /^G/)
    {
      if ($line =~ /,(?:page|image|other),/)
      { ($rectype, $mobile, $group, $mimecat, $count, $perc) = split (',', $line) ; }
      else
      { ($rectype, $mobile, $group, $count, $perc) = split (',', $line) ; }

      $total_clientgroups {$mobile} += $count ;
      $total_all_clientgroups += $count ;

      $group =~ s/^KDDI.*$/KDDI/ ;
      $group =~ s/^MOT.*$/MOT/ ;
      $group =~ s/^LG-.*$/LG/i ;
      $group =~ s/^LGE.*$/LGE/i ;
      $group =~ s/^KWC.*$/KWC/i ;
      $group =~ s/^Nokia.*$/Nokia/i ;
      $group =~ s/^Samsung.*$/Samsung/i ;
      $group =~ s/^Motorola.*$/Motorola/i ;
      $group =~ s/^SonyEricsson.*$/SonyEricsson/i ;
      $group =~ s/^PANTECH.*$/PanTech/i ;
      $group =~ s/^Palm_Pre/Palm Pre/i ;
      $clientgroups {"$mobile,$group"} += $count ;
      $rawclients {"$mobile,$group"} += $count ;

      if ($mimecat eq 'page')
      {
        $total_clientgroups_html_only {$mobile} += $count ;
        $clientgroups_html_only {"$mobile,$group"} += $count ;
        $total_all_clientgroups_html_only += $count ;
      }
    }
    else
    {
      if ($line =~ /,(?:page|image|other),/)
      { ($rectype, $client, $mimecat, $count, $perc) = split (',', $line) ; }
      else
      { ($rectype, $client, $count, $perc) = split (',', $line) ; }

      $total_clients += $count ;

      $client =~ s/_/./g ;
      $client =~ s/\.\./Other/g ;
      if ($client !~ / \d/)
      { $client =~ s/\// / ; }
      if ($rectype eq "-") { $total_clients_non_mobile += $count ; }
      if ($rectype eq "M") { $total_clients_mobile     += $count ; }
      if ($rectype eq "T") { $total_clients_tablet     += $count ; }
      if ($rectype eq "P") { $total_clients_wap        += $count ; }
      if ($rectype eq "W") { $total_clients_wiki_mobile+= $count ; }

      $clients {"$rectype,$client"} += $count ;

      if ($mimecat eq 'page')
      {
        $total_clients_html_only += $count ;
        if ($rectype eq "-") { $total_clients_non_mobile_html_only  += $count ; }
        if ($rectype eq "M") { $total_clients_mobile_html_only      += $count ; }
        if ($rectype eq "T") { $total_clients_tablet_html_only      += $count ; }
        if ($rectype eq "P") { $total_clients_wap_html_only         += $count ; }
        if ($rectype eq "W") { $total_clients_wiki_mobile_html_only += $count ; }
        $clients_html_only {"$rectype,$client"} += $count ;
      }
    }
  }
  close CSV_CLIENTS ;

#  foreach $key (sort keys %clientgroups)
#  {
#    next if $clientgroups {$key} < 50000 ; }
#    next if $key =~ /^M/ ; }

#    print "$key:" . $clientgroups {$key} . "\n" ;
#  }
#  print "\n" ;
#  foreach $key (sort keys %total_clientgroups)
#  {
#    print "$key:" . $total_clientgroups {$key} . "\n" ;
#  }
#  print "\n" ;
}

sub ReadInputCrawlers
{
  &LogSub ("ReadInputCrawlers\n") ;

  my $file_csv = "$path_process/$file_csv_crawlers" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputCrawlers: file $file_csv not found!!!\n") ; }
  open  CSV_CRAWLERS, '<', $file_csv ;
  while ($line = <CSV_CRAWLERS>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp ($line) ;
    ($count, $mime, $agent) = split (',', $line,3) ;


    $mime2 = $mime ;
    $mime =~ s/^image\/.*$/image\/../ ;
    $mime =~ s/^text\/.*$/text\/../ ;
    $agent =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/seg;

    next if $agent =~ /<\s*script\s*>/i ;
    next if $agent =~ /MSIE \d+\.\d+/ ; # most likely false positives

    if ($agent =~ /\|Google ip add?ress/) # typo
    {
      $agent =~ s/\|Google ip add?ress// ;
      $agent =~ s/GoogleBot/<b><font color=green>GoogleBot<\/font><\/b>/gi ;
    }
    if ($agent =~ / \|no Google ip address/)
    {
      $agent =~ s/ \|no Google ip address// ;
      $agent =~ s/GoogleBot/<b><font color=red>GoogleBot<\/font><\/b>/gi ;
    }
    if ($agent =~ /www\.teesoft\.info/)
    {
      $agent =~ s/(\((?:X11|Windows|Macintosh);[^;]*;)[^;]*;[^\)]*\)/$1 [lang code]; rv:[..]\)/ ;
      $agent =~ s/Gecko\/\d+/Gecko\/../ ;
      $agent =~ s/Firefox\/\d+\.\d*\.?\d*/Firefox\/../ ;
      $agent =~ s/(Gecko\/\.\.).*?\(http/$1 etc \(http/ ;
    }

    $agent =~ s/\+//g ;
#   $agent =~ s/^Mozilla\/\d+\.\d+\s*\(compatible\s*;\s*([^\)]*)\)\s*/$1/ ; # Mozilla/5.0 (compatible; xxx) -> xxx
#   $agent =~ s/^Mozilla\/\d+\.\d+\s*\(\s*([^\)]*)\)\s*/$1/ ; # Mozilla/5.0 (xxx) -> xxx
    $agent =~ s/\((http:.*?feedfetcher.html)[^\)]*\)/($1)/ ;  # (http://www.google.com/feedfetcher.html; 1 subscribers; feed-id=1894739019218796495)
    $agent =~ s/FeedFetcher-Google/FeedFetcher-Google/i ;
    if ($agent !~ /http:/)
    { $agent =~ s/(bot|spider|crawl(?:er)?)/<b>$1<\/b>/gi ; }
    if ($mime2 eq "text/html")
    { $total_page_crawlerrequests += $count ; }
    $crawlers {"$mime|$agent"} += $count ; # April 16, 2015, unsually wide variety in user agents bloats report, show -- instead
  }
  close CSV_CRAWLERS ;
}

sub ReadInputMethods
{
  &LogSub ("ReadInputMethods\n") ;

  my $file_csv = "$path_process/$file_csv_methods" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputMethods: file $file_csv not found!!!") ; }
  open CSV_METHODS, '<', $file_csv ;
  while ($line = <CSV_METHODS>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    ($method, $status, $count) = split (',', $line) ;
    $statusses {"$method,$status"} += $count ;
    $methods   {$method}           += $count ;
  }
  close CSV_METHODS ;
}

sub ReadInputMimeTypes
{
  &LogSub ("ReadInputMimeTypes\n") ;

  my $file_csv = "$path_process/$file_csv_requests" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputMimeTypes: file $file_csv not found!!!") ; }
  open CSV_REQUESTS, '<', $file_csv ;
  while ($line = <CSV_REQUESTS>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp $line ;
    ($project, $origin, $ext, $mime, $parm, $count) = split (',', $line) ;

    if (($mime =~ /https?:/) || (length ($mime) > 40)) # Q&D sanitizing which actually should occur in count job 
    {
      $suspect_mime_codes {$mime} ++ ;
      next ; 
    }
    $project = &ExpandAbbreviation ($project) ;

    $mime =~ s/(\w+\.)(\w+\.)(\w+)/$1$2<br>$3/ ;
    $mime =~ s/opensearchdescription/opensearch-<br>description/ ;
    if ($project =~ /\./)
    {
      $project = '!invalid!' ;
      if ($origin ne "external")
      { $origin = 'internal' ; }
      $ext  = ".." ;
      $mime = ".." ;
      next ;
    }

    if ($parms eq "")
    { $parms = "&nbsp;" ; }
    $ext =~ s/^([a-z\[\]]*)[^a-z\[\]].*$/$1/g ;
    $ext =~ s/\((.*)\)/ ($1.php)/ ;
    if ($project eq $origin)
    { $origin = '&lArr;' ; }

    if ($project ne "upload")
    { @counts_prem {"$project,$origin,$ext,$mime"} += $count ; }
    # if ($project ne "upload")
    # { @counts_pm {"$project,$mime"} += $count ; }

    $counts_pm {"$project,$mime"} += $count ;
    ($domain = $project) =~ s/\:.*$// ;
    $counts_dm  {"$domain,$mime"} += $count ;
    $mimetypes {$mime} += $count ;
    $projects  {$project} += $count ;
    $domains   {$domain} += $count ;

    if ($mime =~ /image\/(?:png|jpeg|gif)/)
    {
      $images_project {$project} += $count ;
      $images_domain  {$domain} += $count ;
    }
    $mimetypes_found {$mime} ++ ;
    # @counts_prem {"$project,$origin,$ext,$mime"} += $count ;

    $total_mimes += $count ;
  }
  close CSV_REQUESTS ;

#  $html .= "<tr><th class=c>counts</th><th class=l>project</th><th class=l>origin</th><th class=l>extension</th><th class=l>mime</th></tr>\n" ;
#  $rows = 0 ;
#  foreach $key (sort keys %counts_prem)
#  {
#    ($project, $origin, $ext, $mime) = split (',', $key) ;
#    $count = $counts_prem {$key} ;
#    $count =~ s/^(\d+?)(\d\d\d)$/$1,$2/ ;
#    $html .= "<tr><td class=r>${count},000</td><td class=l>$project</td><td class=l>$origin</td><td class=l>$ext</td><td class=l>$mime</td></tr>\n" ;
#    $rows++ ;
#  }
#  $html .= "</table>\n" ;
#  $html .= "<small>$rows rows written</small><p>" ;

#  $html .= "<table border=1>\n" ;
#  $html .= "<tr><th class=c>counts</th><th class=l>project</th><th class=l>mime</th></tr>\n" ;
#  $rows = 0 ;
#  foreach $key (sort keys %counts_pm)
#  {
#    ($project, $mime) = split (',', $key) ;
#    $count = $counts_pm {$key} ;
#    $count =~ s/^(\d+?)(\d\d\d)$/$1,$2/ ;
#    $html .= "<tr><td class=r>${count},000</td><td class=l>$project</td><td class=l>$mime</td></tr>\n" ;
#    $rows++ ;
#  }
#  $html .= "</table>\n" ;
#  $html .= "<small>$rows rows written</small><p>" ;
}

sub ReadInputOpSys
{
  &LogSub ("ReadInputOpSys\n") ;

  my $file_csv = "$path_process/$file_csv_opsys" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputOpSys: file $file_csv not found!!!") ; }
  open CSV_OPSYS, '<', $file_csv ;
  while ($line = <CSV_OPSYS>)
  {
    if ($line =~ /^#/) # comments
    {
      if ($line =~ /^# mobile:/)
      {
        $line =~ s/^.*?: // ;
        ($month_upd_keywords_mobile = $line) =~ s/^.*?\(([^\)]+)\).*$/$1/ ;
        ($keywords_mobile = $line)           =~ s/ \([^\)]+\).*$// ;
        ($keywords_wiki_mobile = $line)      =~ s/ \([^\)]+\).*$// ;
        $keywords_mobile =~ s/\|/, /g ;
        $keywords_mobile =~ s/((?:[^,]+,){10})/$1<br>/g ;
        $keywords_wiki_mobile =~ s/((?:[^,]+,){10})/$1<br>/g ;
        next ;
      }
      next ;
    }
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp $line ;

    $mimecat = '' ;
    if ($line !~ /,(?:page|image|other),/)
    { ($rectype, $os, $count, $perc) = split (',', $line) ; }
    else
    { ($rectype, $os, $mimecat, $count, $perc) = split (',', $line) ; }

    next if $count !~ /^\d+$/ ; # -,Linux Gentoo,,2,0.00% (extra comma !)

    $os =~ s/_/./g ;
    $os =~ s/\.\./Other/g ;
    if ($rectype ne "G")
    {
      if ($os =~ / \d/)
      { ; }
      else
      { $os =~ s/\// / ; }
    }

    if ($rectype eq "-") { $total_opsys_non_mobile += $count ; }
    if ($rectype eq "M") { $total_opsys_mobile     += $count ; }

    $opsys {"$rectype,$os"} += $count ;

    if ($mimecat eq 'page')
    {
      $opsys_html_only {"$rectype,$os"} += $count ;
      if ($rectype eq "-") { $total_opsys_non_mobile_html_only += $count ; }
      if ($rectype eq "M") { $total_opsys_mobile_html_only     += $count ; }
    }
  }
}


sub ReadInputOrigins
{
  &LogSub ("ReadInputOrigins\n") ;

  my $file_csv = "$path_process/$file_csv_origins" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputOrigins: file $file_csv not found!!!") ; }
  open CSV_ORIGINS, '<', $file_csv ;
  while ($line = <CSV_ORIGINS>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp $line ;
    ($source, $origin, $toplevel, $mimecat, $count) = split (',', $line) ;

# test:
     if (($source eq "external") && ($origin !~ /^google/))
     { $origin .= $toplevel ; }

#    ~ s/xx:upload/upload (~css)/;
#   $origin =~ s/wb:/wikibooks:/;
#   $origin =~ s/wk:/wiktionary:/;
#   $origin =~ s/wn:/wikinews:/;
#   $origin =~ s/wp:/wikipedia:/;
#   $origin =~ s/wq:/wikiquote:/;
#   $origin =~ s/ws:/wikisource:/;
#   $origin =~ s/wv:/wikiversity:/;
#    $origin =~ s/wx://;
#    $origin =~ s/mw:/mediawiki:/;
#    $origin =~ s/wm:/wikimedia:/;
#    $origin =~ s/wmf:/foundation:/;
#    $origin =~ s/:www$/:portal/;
#    $origin =~ s/:mw$/:mediawiki/;

    if ($source eq "internal")
    {
      $origin = &ExpandAbbreviation ($origin) ;
      ($project,$subproject) = split (':', $origin) ;
      $origin_int_top_split  {"$mimecat:$origin"} += $count ;
      $origin_int_top        {$origin} += $count ;
      $project_int_top_split {"$mimecat:$project"} += $count ;
      $project_int_top       {$project} += $count ;
    }
    else
    {
#      $origin2 = $origin ;
#      $origin2 =~ s/^google.*?\|/google:ext|/ ;
#      $origin2 =~ s/^yahoo.*\|/yahoo:ext|/ ;
#      if (($origin2 !~ /^google/) && ($origin2 !~ /^yahoo/))
#      { $origin2 =~ s/^.*?\|/other:ext|/ ; }
#       ($prefix,$code) = split ('\:', $origin2) ;
#       print "$origin -> $origin2\n" ;
#      $origin_ext_top_split {$origin} += $count ;
#      $origin_ext_top       {$code}     += $count ;

#      if ($origin =~ /\|page/)
#      {
#       ($prefix,$code) = split ('\:', $origin) ;
#        $code     =~ s/\|.*$// ;
#        $origin =~ s/\|.*$// ;
#        $origin_ext_page_top_split {$origin} += $count ;
#        $origin_ext_page_top       {$code}     += $count ;
#      }
      if ($origin eq "unmatched ip address")
      { $origin = "origin unknown" ; }

      if ($mimecat eq "page")
      { $total_page_requests_external += $count ; }

      $origin_ext_top_split {"$mimecat:$origin"} += $count ;
      $origin_ext_top       {$origin} += $count ;
      $total_origins_external_counted += $count ;
    # if ($origin =~ /^google/)
    # {
    #   $origin = "google (total)" ;
    #   $origin_ext_top_split {"$mimecat:$origin"} += $count ;
    #   $origin_ext_top       {$origin} += $count ;
    # }
    }
  }

  close CSV_ORIGINS ;
}

sub ReadInputScripts
{
  &LogSub ("ReadInputScripts\n") ;

  my $file_csv = "$path_process/$file_csv_scripts" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputScripts: file $file_csv not found!!!") ; }
  open CSV_SCRIPTS, '<', $file_csv ;
  while ($line = <CSV_SCRIPTS>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp $line ;
    $line =~ s/\%3B/;/gi ;
    $line =~ s/\&amp;/\&/gi ;
    ($ext, $script, $parm, $count) = split (',', $line) ;
    if ($script =~ /\%/)
    { $script = "other" ; }
    if ($parm =~ /\%/)
    { $parm = "other" ; }

    if (($ext eq "php") && ($parm =~ /action=/) && ($parm !~ /search=/)) # action can occur as parm after search
    {
      @parms = split ('\&', $parm) ;
      foreach $parm (@parms)
      {
        ($keyword,$data) = split ('\=', $parm) ;
        if ($keyword eq "action")
        { @actions {"$script,$data"} += $count }
      }
    }
  }
  close CSV_SCRIPTS ;

# foreach $key (keys_sorted_by_value_num_desc %actions)
# { print "$key: " . $actions {$key} . "\n" ; }

  open  CSV_SCRIPTS, '<', "$path_process/$file_csv_scripts" ;
  read_script:
  while ($line = <CSV_SCRIPTS>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp $line ;
    $line =~ s/\%3B/;/gi ;
    $line =~ s/\%5B/[/gi ;
    $line =~ s/\%5D/]/gi ;
    $line =~ s/\&amp;/\&/gi ;
    ($ext, $script, $parm, $count) = split (',', $line) ;

    # incomplete validation check on valid names, but captures already lot of rubbish
    if ($script =~ /\%/)
    { $script = "other" ; }
    if ($parm =~ /\%/)
    { $parm = "other" ; }

    if (($parm =~ /amp;amp;/) ||
        ($parm =~ /feed=.*feed=/))
    { next read_script ; }

    if (($ext eq "php") && ($parm =~ /action=/))
    {
      @parms = split ('\&', $parm) ;
      foreach $parm (@parms)
      {
        ($keyword,$data) = split ('\=', $parm) ;
        if ($keyword eq "action")
        {
          if (@actions {"$script,$data"} < 2)
          { next read_script ; }
        }
      }
    }
    if ($ext eq "php")
    {
      # generalize ns10 -> ns.. + remove all ns..=.. but one
      $parm =~ s/\&ns\d+/\&ns../g ;
      $parm =~ s/\&ns\.\.=\.\./-*^-*^/ ;
      $parm =~ s/\&ns\.\.=\.\.//g ;
      $parm =~ s/\-\*\^\-\*\^/\&ns\.\.=\.\./g ;

      # generalize nsargs[]= -> remove all but one
      $parm =~ s/\&rsargs\[\]=\.\./-*^-*^/ ;
      $parm =~ s/\&rsargs\[\]=\.\.//g ;
      $parm =~ s/\-\*\^\-\*\^/\&rsargs\[n\]=\.\./g ;

      if (length ($parm) > 100)
      { $parm =~ s/(.{100}[^\&]*\&)/$1<br>/g ; }

      $parms   {"$script,$parm"} += $count ;
      $scripts_php {$script}     += $count ;
    }
    elsif ($ext eq "js")
    { $scripts_js {$script}      += $count ; }
    elsif ($ext eq "css")
    { $scripts_css {$script}     += $count ; }
  }
  close CSV_SCRIPTS ;
}

sub ReadInputGoogle
{
  &LogSub ("ReadInputGoogle\n") ;

  my $file_csv = "$path_process/$file_csv_google" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputGoogle: file $file_csv not found!!!") ; }
  open CSV_SEARCH, '<', $file_csv ;
  while ($line = <CSV_SEARCH>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp $line ;
    ($matches, $site, $origin, $service, $agent, $mimecat, $toplevel, $count) = split (',', $line) ;

    if ($service eq "Imposters?")
    { $service = "GoogleBot?" ; }
    if ($service eq "GoogleBotNot?")
    { $service = "GoogleBot?" ; }
    if ($service eq "Crawler")
    { $service = "GoogleBot" ; }

    if ($matches =~ /x/)
    { $googleIp = 'Y' ; }
    else
    { $googleIp = 'N' ; }

    next if $site ne "google" ;

    if ($toplevel eq "-")
    { $toplevel = "undefined" ; }
    if (length ($toplevel) > 3)
    { $toplevel = "_$toplevel" ; } # sort on top

    $searches_crawlers {$service}    += $count ;
    $searches_service  {"$service,$googleIp"} += $count ;
    $searches_toplevel  {$toplevel}  += $count ;
    $searches_service_mimecat  {"$service,$mimecat,$googleIp"} += $count ;
    $searches_service_mimecat  {"$service,total,$googleIp"} += $count ;
    $searches_service_matches  {"$service,$matches"} += $count ;

#    if ($origin =~ /search/i)
    if ($toplevel =~ /^[a-zA-Z0-9-]+$/)
    { $searches_toplevel_tld_found {$toplevel} += $count ; } # print "$line\n" ;}
    else
    {
      $searches_mimecat_tld_not_found {$mimecat} += $count ;
      $searches_mimecat_tld_not_found {"total"}  += $count ;
    }

    $searches_toplevel_mimecat {"$toplevel,$mimecat"} += $count ;
    $searches_toplevel_mimecat {"$toplevel,total"} += $count ;

#  if ($toplevel !~ /:/) { print "invalid toplevel $toplevel\n" ; }
  }
  close CSV_SEARCH ;
}

sub ReadInputSkins
{
  &LogSub ("ReadInputSkins\n") ;

  my $file_csv = "$path_process/$file_csv_skins" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputSkins: file $file_csv not found!!!") ; }
  open CSV_SKINS, '<', $file_csv ;
  while ($line = <CSV_SKINS>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp $line ;
    ($skins, $count) = split (',', $line) ;

    $skins {$skins} += $count ;
    ($name,$rest) = split ('\/', $skins, 2) ;
    $skin_set {$name}+= $count ;
  }
  close CSV_SCRIPTS ;
}

sub ReadInputIndexPhp
{
  &LogSub ("ReadInputIndexPhp\n") ;

  my $file_csv = "$path_process/$file_csv_indexphp" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputIndexPhp: file $file_csv not found!!!") ; }
  open CSV_INDEXPHP, '<', $file_csv ;
  while ($line = <CSV_INDEXPHP>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp $line ;
    ($bot,$domain,$referer,$ext,$status,$mime,$parm,$agent) = split (',', $line) ;

    my $action = "" ;
    if ($parm =~ /action=edit/)
    { $action = 'edit' ; }
    if ($parm =~ /action=submit/)
    { $action = 'submit' ; }

    next if $ext !~ /index.php/ ;
    next if $parm !~ /action=(?:edit|submit)(?:$|\&)/ ; # submit or submit&.., not submitlogin
    next if $mime ne "text/html" ;  # excludes mime - (undefined), application/x-external-editor on action=edit
                                    # and text/plain, text/xml, application/xml on action=submit

    if ($bot =~ /Y/)
    {
      $intent = "" ;

      if ($agent =~ /DotNetWikiBot/i)
      { $agent = "DotNetWikiBot" ; }
      $agent =~ s/\%27/\'/g ;
      # $agent =~ s/\(.*?\)//g;

      if ($action eq "edit")
      {
        if ($referer =~ /^\w\w:/)
        { $referer = "int" ; }
        $edit_submit_bot       {$domain} {"edit,$referer"} ++ ;
        $edit_submit_bot_sort  {$domain} ++ ;
        $edit_submit_bot_agent      {$agent} {"$action,$referer"}++ ;
        $edit_submit_bot_agent_sort {$agent}++ ;
      }

      if ($action eq "submit")
      {
        if ($referer =~ /^\w\w:/)
        { $referer = "int" ; }

        $intent = 'unknown' ;
           if ($status eq "TCP_MISS/302") { $intent = 'save' ; }
        elsif ($status eq "TCP_MISS/200") { $intent = 'preview' ; }
      # next if $intent ne 'save' ;

        $edit_submit_bot      {$domain} {"$intent,$referer"} ++ ;
        $edit_submit_bot_sort {$domain} ++ ;

        # if ($referer eq "-") { $edit_submit_bot_agent {$agent}++ ; }
        $edit_submit_bot_agent      {$agent} {"$intent,$referer"}++ ;
        $edit_submit_bot_agent_sort {$agent}++ ;
      }
    }

    next if $bot =~ /N/ ;  # 2009-05 /N/ -> total oldid: 127, total other: 54, total redlink: 4
    next if $bot =~ /Y/ ;  # 2009-05 /N/ -> total oldid: 127, total other: 54, total redlink: 4
    next if $domain ne "wp:en" ; # 2009-05 ne -> total other: 26, total redlink: 22
    # if (($referer ne "-") && ($referer ne "ext") && ($referer ne "wp:en")) { next ; }
    # if (($referer ne "-") && ($referer !~ /^..:/)) { $referer = "ext" ; }
    #  if ($referer eq "-") { $referer = "-    " ; }
    next if $referer ne "wp:en" ; # 2009-05 eq -> # total other: 2014, total redlink: 1031, total oldid: 47, total undo: 30

    my $filter = '' ;
    if ($parm =~ /action=edit/)
    {
      $filter = 'other' ;
      if ($parm =~ /redlink/) { $filter = 'redlink' ; }
      if ($parm =~ /oldid=/)  { $filter = 'oldid' ; }
      if ($parm =~ /undo=/)   { $filter = 'undo' ; }

      $edit_submit {"[$bot $referer $action $filter] $parm"}++ ;
      $edit_submits {"$filter"}++ ;
    }
    if ($parm =~ /action=submit/)
    {
       $edit_submit {"$bot $referer $action $status"}++ ;
    }

 #   my @subparms = split ('\&', $parm) ;
 #   foreach $subparm (@subparms)
 #   { $edit_submit_subparms {"[$action] [$filter] $subparm"}++ ; }
  }
  close CSV_INDEXPHP ;

#  next if $bot =~ /N/ ; # + any referrer ->
# Sample period: 1 May 2009 - 31 May 2009 => for daily averages multiplier = 0.03
#   9: [bot=Y - edit oldid] action=edit&oldid=&section=&title=..
#   3: [bot=Y - edit oldid] action=edit&oldid=..&title=..
#  17: [bot=Y - edit oldid] action=edit&oldid=..&title=..&useskin=..
#   1: [bot=Y - edit other] _herbs&action=edit&title=..
#  65: [bot=Y - edit other] action=edit&section=..&title=..
#   1: [bot=Y - edit other] action=edit&stub&title=..
#   2: [bot=Y - edit other] action=edit&title=
# 188: [bot=Y - edit other] action=edit&title=..
#  31: [bot=Y - edit other] action=edit&title=..&useskin=..
#  30: [bot=Y - edit redlink] action=edit&redlink=..&title=..
#   5: [bot=Y - edit undo] action=edit&title=..&undo=..&undoafter=..
#  14: [bot=Y ext edit other] action=edit&section=..&title=..
#   5: [bot=Y ext edit other] action=edit&title=..
#  11: [bot=Y ext edit redlink] action=edit&redlink=..&title=..
#   2: [bot=Y ext edit undo] action=edit&title=..&undo=..&undoafter=..
# 107: [bot=Y wp:en edit oldid] action=edit&oldid=&section=&title=..
#   3: [bot=Y wp:en edit oldid] action=edit&oldid=..&section=&title=..
#  17: [bot=Y wp:en edit oldid] action=edit&oldid=..&title=..
#   1: [bot=Y wp:en edit other] action=edit&articleget=..&dykcredittab=..&editintro=..&preload=..&preloadtitle=..&section=..&title=..
#   5: [bot=Y wp:en edit other] action=edit&section=..&title=..
#  48: [bot=Y wp:en edit other] action=edit&title=..
#   4: [bot=Y wp:en edit redlink] action=edit&redlink=..&title=..
#   9: bot=Y - submit TCP_MISS/200
#  62: bot=Y - submit TCP_MISS/302
#  31: bot=Y wp:en submit TCP_MISS/302
#  total other: 361
#  total oldid: 156
#  total redlink: 45
#  total undo: 7
}

sub ReadInputCountriesTimed
{
  &LogSub ("ReadInputCountriesTimed\n") ;

  my $file_csv = "$path_process/public/$file_csv_countries_timed" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputSkins: file $file_csv not found!!! ") ; }
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
    $icon =~ s/\"\/\/upload/\"http:\/\/upload/g ;

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
    }
    else
    {
    # Dec 2013: no quarterly report used to be avg monthly counts for last full 12 months, now it is data for one month 	    
    # if ((($year == $report_year) && ($month <= $report_month)) or # EZ 10/2012, skip current month
    #     (($year == $report_year - 1) && ($month > $report_month)))
      if (($year == $report_year) && ($month == $report_month))
      { $recently = $true ; }
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
  # { $requests_unknown_per_quarter {$quarter} += $count ; next ; }
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
# if ($months_recently == 0) { abort ("\$months_recently == 0\n") ; }

  $requests_recently_start = substr ($requests_recently_start,0,4) . '/' . substr ($requests_recently_start,5,2);
  $requests_recently_stop  = substr ($requests_recently_stop ,0,4) . '/' . substr ($requests_recently_stop ,5,2) ;
  $requests_start          = substr ($requests_start,0,4)          . '/' . substr ($requests_start,5,2) ;
  $requests_stop           = substr ($requests_stop ,0,4)          . '/' . substr ($requests_stop ,5,2) ;

  foreach $yyyymm (keys %$yyyymm)
  {
    if ($requests_per_month_us {$week} > $max_requests_per_month_us)
    { $max_requests_per_month_us = $requests_per_month_us {$week} ; }
  }

  # die "\$connected_us == 0" if $connected_us == 0 ;
  if ($connected_us > 0)
  { $max_requests_per_connected_us_month = sprintf ("%.1f", $max_requests_per_month_us / $connected_us) ; }

#  foreach $country_code (sort keys %country_codes_all)
#  {
#    $200907 = ${$requests_per_month_per_country_code {"200907"}} {$country_code} ;
#    $200908 = ${$requests_per_month_per_country_code {"200908"}} {$country_code} ;
#    $200909 = ${$requests_per_month_per_country_code {"200909"}} {$country_code} ;
#    $200910 = ${$requests_per_month_per_country_code {"200910"}} {$country_code} ;
#    $200911 = ${$requests_per_month_per_country_code {"200911"}} {$country_code} ;
#    $200912 = ${$requests_per_month_per_country_code {"200912"}} {$country_code} ;
#    print "$country_code, $200907, $200908, $200909, $200910, $200911, $200912\n" ;
#  }
#  exit ;
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

sub ReadInputBrowserLanguages
{
  &LogSub ("ReadInputBrowserLanguages\n") ;

  my $file_csv = "$path_process/$file_csv_browser_languages" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputBrowserLanguages: file $file_csv not found!!! ") ; }
  open CSV_BROWSER_LANGUAGES, '<', $file_csv ;
  while ($line = <CSV_BROWSER_LANGUAGES>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp $line ;
    ($browser,$language,$count) = split (',', $line) ;

    $browser_languages {"$browser,$language"} += $count ;
  }
  close CSV_BROWSER_LANGUAGES ;
}

sub ReadInputUseragents
{
  &LogSub ("ReadInputUseragents\n") ;

  my $file_csv = "$path_process/$file_csv_user_agents" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputUseragents: file $file_csv not found!!!") ; }
  open CSV_AGENTS, '<', $file_csv ;

  while ($line = <CSV_AGENTS>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)
    next if $line =~ /^[^,]*,?[^,]*$ / ; # lines with at most one comma - caused by an error in the input procedure

    chomp ($line) ;

    (my $agent, my $site, my $page, my $api, my $count) = split (',', $line) ;

    if ($site =~ /^%/)
      { $site = 'M' ; }
    elsif (substr($site, 1, 1) eq 'w')
      { $site = 'W' ; }
    else
      { $site = 'X' ; }

    $countua {$agent, '.', '.', '.'} += $count ;
    $countua {$agent, '.', '.', $api} += $count ;
    $countua {$agent, $site, $page, '.'} += $count ;
    $countua {$agent, $site, '.', '.'} += $count ;
    $countua {$agent, '.', $page, '.'} += $count ;
    $countua {'.', '.', '.', '.'} += $count ;
    $countua {'.', '.', '.', $api} += $count ;
    $countua {'.', $site, $page, '.'} += $count ;
    $countua {'.', $site, '.', '.'} += $count ;
    $countua {'.', '.', $page, '.'} += $count ;

    if ($agent ne 'B' && $agent ne '-')
    {
      $countua {'Z', '.', '.', '.'} += $count ;
      $countua {'Z', '.', '.', $api} += $count ;
      $countua {'Z', $site, $page, '.'} += $count ;
      $countua {'Z', $site, '.', '.'} += $count ;
      $countua {'Z', '.', $page, '.'} += $count ;
      if ($agent ne 'N')
      {
        $countua {'S', '.', '.', '.'} += $count ;
        $countua {'S', '.', '.', $api} += $count ;
        $countua {'S', $site, $page, '.'} += $count ;
        $countua {'S', $site, '.', '.'} += $count ;
        $countua {'S', '.', $page, '.'} += $count ;
      if ($agent eq 'M' || $agent eq 'T' || $agent eq 'P')
        {
          $countua {'C', '.', '.', '.'} += $count ;
          $countua {'C', '.', '.', $api} += $count ;
          $countua {'C', $site, $page, '.'} += $count ;
          $countua {'C', $site, '.', '.'} += $count ;
          $countua {'C', '.', $page, '.'} += $count ;
        }
      else
        {
          $countua {'Q', '.', '.', '.'} += $count ;
          $countua {'Q', '.', '.', $api} += $count ;
          $countua {'Q', $site, $page, '.'} += $count ;
          $countua {'Q', $site, '.', '.'} += $count ;
          $countua {'Q', '.', $page, '.'} += $count ;
        }
      }
    }
  }
  close CSV_AGENTS ;
}

sub ReadInputDevices
{
  &LogSub ("ReadInputDevices\n") ;

  my $file_csv = "$path_process/$file_csv_devices" ;
  if (! -e $file_csv)
  {
    &LogDetail ("Missing file $file_csv - devices screen will not be generated.\n") ;
    return $false ;
  }
  open CSV_DEVICES, '<', $file_csv ;

  while ($line = <CSV_DEVICES>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp ($line) ;

    (my $device, my $category, my $count) = split (',', $line) ;
    $devices { $device } += $count ;
    $catfordevice { $device } = $category ;
    $devicecats { $category } += $count ;
    $alldevices += $count ;
  }
  return $true ;
}

sub ReadInputCountriesInfo
{
  &LogSub ("ReadInputCountriesInfo\n") ;

  my $file_csv = "$path_process/$file_csv_countries_info" ;
  if (! -e $file_csv)
  { abort ("Function ReadInputCountryInfo: file $file_csv not found!!!") ; }
  open CSV_COUNTRIES_INFO, '<', $file_csv ;
  while ($line = <CSV_COUNTRIES_INFO>)
  {
    next if $line =~ /^#/ ; # comments
    next if $line =~ /^:/ ; # csv header (not a comment)

    chomp ($line) ;

    my ($type, $country, $value, $count) = split (',', $line) ;

    if ($type eq 'M')
    {
      $allcountrytotal += $count ;
    # $countrytotal { $country } += $count ;
      if ($value ne '-')
      {
      # $allcountrymobile += $count ;
        $countrymobile { $country } += $count ;
      }
    }
    elsif ($type eq 'B')
    {
      $countrybrowser { $country, $value } += $count ;
      $allcountrybrowser { $value } += $count ;
      $countryallbrowser { $country } += $count ;
    }
    elsif ($type eq 'O')
    {
      if ($value !~ /^[a-zA-Z0-9\-\.]+$/)
      {
        print "Invalid OS $value -> 'Error'\n" ;
        $value = 'Error' ;
      }
      $countryos { $country, $value } += $count ;
      $allcountryos { $value } += $count ;
      $countryallos { $country } += $count ;
    }
    elsif ($type eq 'D')
    {
      $countrydevice { $country, $value } += $count ;
      $countryalldevice { $country } += $count ;
      $countrydevice { '.', $value } += $count ;
      $countryalldevice { '.' } += $count ;
    }
    elsif ($type eq 'C')
    {
      my ($client, $domain, $mimecat, $api) = split (';', $value) ;
      if ($domain =~ /^%/)
      { $domain = 'M' ; }
      elsif (substr($domain, 1, 1) eq 'w')
      { $domain = 'W' ; }
      else
      { $domain = 'X' ; }
      if ($client eq 'a' || $client eq 'i')
      {
        $client = 'W' ;
      }
      if ($mimecat eq 'page' && $domain ne 'X')
      {
        $countrycount { $country } += $count ;
        $countryua { '.', '.', '.' } += $count ;
        $countryua { $country, '.', '.' } += $count ;
        $countryua { '.', $client, '.' } += $count ;
        $countryua { $country, $client, '.' } += $count ;
        $countryua { '.', '.', $domain } += $count ;
        $countryua { $country, '.', $domain } += $count ;
        $countryua { '.', $client, $domain } += $count ;
        $countryua { $country, $client, $domain } += $count ;
      }
    }
  }
  close CSV_COUNTRIES_INFO ;
}

sub CalcPercentages
{
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

sub NormalizeCounts
{
  &LogSub ("NormalizeCounts\n") ;

  $total_all_clientgroups = &Normalize ($total_all_clientgroups) ;
  $total_all_clientgroups_html_only = &Normalize ($total_all_clientgroups_html_only) ;

  foreach $key (keys %engines)
  { $engines {$key} = &Normalize ($engines {$key}) ; }

  foreach $key (keys %clientgroups)
  { $clientgroups {$key} = &Normalize ($clientgroups {$key}) ; }

  foreach $key (keys %clientgroups_html_only)
  { $clientgroups_html_only {$key} = &Normalize ($clientgroups_html_only {$key}) ; }

  foreach $key (keys %clients)
  { $clients {$key} = &Normalize ($clients {$key}) ; }

  foreach $key (keys %clients_html_only)
  { $clients_html_only {$key} = &Normalize ($clients_html_only {$key}) ; }

  foreach $key (keys %clientgroups_other)
  { $clientgroups_other {$key} = &Normalize ($clientgroups_other {$key}) ; }

  foreach $key (keys %clientgroups_other_html_only)
  { $clientgroups_other_html_only {$key} = &Normalize ($clientgroups_other_html_only {$key}) ; }

  foreach $key (keys %total_clientgroups)
  { $total_clientgroups {$key} = &Normalize ($total_clientgroups {$key}) ; }

  foreach $key (keys %total_clientgroups_html_only)
  { $total_clientgroups_html_only {$key} = &Normalize ($total_clientgroups_html_only {$key}) ; }

  foreach $key (keys %total_engines)
  { $total_engines {$key} = &Normalize ($total_engines {$key}) ; }

  #foreach $key (keys %webkit_engines)
  #{ $webkit_engines {$key} = &Normalize ($webkit_engines {$key}) ; }

  $total_clients            = &Normalize ($total_clients) ;
  $total_clients_mobile     = &Normalize ($total_clients_mobile) ;
  $total_clients_tablet     = &Normalize ($total_clients_tablet) ;
  $total_clients_wap        = &Normalize ($total_clients_wap) ;
  $total_clients_wiki_mobile= &Normalize ($total_clients_wiki_mobile) ;
  $total_clients_non_mobile = &Normalize ($total_clients_non_mobile) ;

  $total_clients_html_only             = &Normalize ($total_clients_html_only) ;
  $total_clients_mobile_html_only      = &Normalize ($total_clients_mobile_html_only) ;
  $total_clients_tablet_html_only      = &Normalize ($total_clients_tablet_html_only) ;
  $total_clients_wap_html_only         = &Normalize ($total_clients_wap_html_only) ;
  $total_clients_non_mobile_html_only  = &Normalize ($total_clients_non_mobile_html_only) ;
  $total_clients_wiki_mobile_html_only = &Normalize ($total_clients_wiki_mobile_html_only) ;

# ReadInputCrawlers
  foreach $key (keys %crawlers)
  { $crawlers {$key} = &Normalize ($crawlers {$key}) ; }

  $total_page_crawlerrequests  = &Normalize ($total_page_crawlerrequests) ;

# ReadInputMethods
  foreach $key (keys %statusses)
  { $statusses {$key} = &Normalize ($statusses {$key}) ; }
  foreach $key (keys %methods)
  { $methods {$key} = &Normalize ($methods {$key}) ; }

# ReadInputMimeTypes
  foreach $key (keys %mimetypes)
  { $mimetypes {$key} = &Normalize ($mimetypes {$key}) ; }
  foreach $key (keys %projects)
  { $projects {$key} = &Normalize ($projects {$key}) ; }
  foreach $key (keys %domains)
  { $domains {$key}  = &Normalize ($domains {$key}) ; }
  foreach $key (keys %images_project)
  { $images_project {$key}  = &Normalize ($images_project {$key}) ; }
  foreach $key (keys %images_domain)
  { $images_domain {$key}  = &Normalize ($images_domain {$key}) ; }
  foreach $key (keys %mimetypes_found)
  { $mimetypes_found {$key}  = &Normalize ($mimetypes_found {$key}) ; }
  foreach $key (keys %counts_pm)
  { $counts_pm {$key}  = &Normalize ($counts_pm {$key}) ; }
  foreach $key (keys %counts_dm)
  { $counts_dm {$key}  = &Normalize ($counts_dm {$key}) ; }
  foreach $key (keys %counts_prem)
  { $counts_prem {$key}  = &Normalize ($counts_prem {$key}) ; }

  $total_mimes = &Normalize ($total_mimes) ;

# ReadInputOpSys
  foreach $key (keys %opsys)
  { $opsys {$key} = &Normalize ($opsys {$key}) ; }

  $total_opsys_non_mobile = &Normalize ($total_opsys_non_mobile) ;
  $total_opsys_mobile     = &Normalize ($total_opsys_mobile) ;

# ReadInputOrigins
  foreach $key (keys %origin_int_top)
  { $origin_int_top {$key} = &Normalize ($origin_int_top {$key}) ; }
  foreach $key (keys %origin_int_top_split)
  { $origin_int_top_split {$key} = &Normalize ($origin_int_top_split {$key}) ; }
  foreach $key (keys %origin_ext_top)
  { $origin_ext_top {$key} = &Normalize ($origin_ext_top {$key}) ; }
  foreach $key (keys %origin_ext_top_split)
  { $origin_ext_top_split {$key} = &Normalize ($origin_ext_top_split {$key}) ; }
  foreach $key (keys %origin_ext_page_top)
  { $origin_ext_page_top {$key} = &Normalize ($origin_ext_page_top {$key}) ; }
  foreach $key (keys %project_int_top)
  { $project_int_top {$key} = &Normalize ($project_int_top {$key}) ; }
  foreach $key (keys %project_int_top_split)
  { $project_int_top_split {$key} = &Normalize ($project_int_top_split {$key}) ; }

  $total_page_requests_external = &Normalize ($total_page_requests_external) ;
  $total_origins_external_counted = &Normalize ($total_origins_external_counted) ;

# ReadInputScripts
  foreach $key (keys %actions)
  { $actions {$key} = &Normalize ($actions {$key}) ; }
  foreach $key (keys %parms)
  { $parms {$key} = &Normalize ($parms {$key}) ; }
  foreach $key (keys %scripts_php)
  { $scripts_php {$key} = &Normalize ($scripts_php {$key}) ; }
  foreach $key (keys %scripts_js)
  { $scripts_js {$key} = &Normalize ($scripts_js {$key}) ; }
  foreach $key (keys %scripts_css)
  { $scripts_css {$key} = &Normalize ($scripts_css {$key}) ; }

# ReadInputGoogle
  foreach $key (keys %searches_service)
  { $searches_service {$key} = &Normalize ($searches_service {$key}) ; }
  foreach $key (keys %searches_crawlers)
  { $searches_crawlers {$key} = &Normalize ($searches_crawlers {$key}) ; }
  foreach $key (keys %searches_toplevel)
  { $searches_toplevel {$key} = &Normalize ($searches_toplevel {$key}) ; }
  foreach $key (keys %searches_toplevel_tld_found)
  { $searches_toplevel_tld_found {$key} = &Normalize ($searches_toplevel_tld_found {$key}) ; }
  foreach $key (keys %searches_service_mimecat)
  { $searches_service_mimecat {$key} = &Normalize ($searches_service_mimecat {$key}) ; }
  foreach $key (keys %searches_service_matches)
  { $searches_service_matches {$key} = &Normalize ($searches_service_matches {$key}) ; }
  foreach $key (keys %searches_toplevel_mimecat)
  { $searches_toplevel_mimecat {$key} = &Normalize ($searches_toplevel_mimecat {$key}) ; }
  foreach $key (keys %searches_mimecat_tld_not_found)
  { $searches_mimecat_tld_not_found {$key} = &Normalize ($searches_mimecat_tld_not_found {$key}) ; }

# ReadInputSkins
  foreach $key (keys %skins)
  { $skins {$key} = &Normalize ($skins {$key}) ; }
  foreach $key (keys %skin_set)
  { $skin_set {$key} = &Normalize ($skin_set {$key}) ; }

# ReadInputBrowserLanguages
  foreach $key (keys %browser_languages)
  { $browser_languages {$key} = &Normalize ($browser_languages {$key}) ; }
}

sub SortCounts
{
  &LogSub ("SortCounts\n") ;

# ReadInputClients
# @engines_sorted_count              = keys_sorted_by_value_num_desc %engines ;
  @engines_sorted_alpha              = keys_sorted_alpha_asc %engines ;
# @webkit_engines_sorted_alpha       = keys_sorted_alpha_asc %webkit_engines ;
  @clientgroups_sorted_count         = keys_sorted_by_value_num_desc %clientgroups ;
  @clientgroups_sorted_alpha         = keys_sorted_alpha_asc %clientgroups ;
  @clients_sorted_count              = keys_sorted_by_value_num_desc %clients ;
  @clients_sorted_alpha              = keys_sorted_alpha_asc %clients ;

# ReadInputCrawlers
# @crawlers_sorted_count             = keys_sorted_by_value_num_desc %crawlers ;
# @crawlers_sorted_alpha             = keys_sorted_alpha_asc %crawlers ;

# ReadInputMethods
  @statusses_sorted_count            = keys_sorted_by_value_num_desc %statusses ;
  @statusses_sorted_method           = keys_sorted_alpha_desc           %statusses ;
  @methods_sorted_count              = keys_sorted_by_value_num_desc %methods ;
  @methods_sorted_method             = keys_sorted_alpha_desc           %methods ;

# ReadInputMimeTypes
  @mimetypes_sorted                  = sort {&SortMime ($b) <=> &SortMime ($a)} keys %mimetypes ;
  @projects_sorted                   = keys_sorted_by_value_num_desc %projects ;
  @domains_sorted                    = keys_sorted_by_value_num_desc %domains ;

# ReadInputOpSys
  @opsys_sorted_alpha                = sort {lc($a) cmp lc($b)} keys %opsys ;
  @opsys_sorted_count                = keys_sorted_by_value_num_desc %opsys ;

# ReadInputOrigins
  @origin_int_top_sorted_alpha       = keys_sorted_alpha_desc           %origin_int_top ;
  @origin_ext_top_sorted_alpha       = keys_sorted_alpha_desc           %origin_ext_top ;
  @origin_ext_page_top_sorted_alpha  = keys_sorted_alpha_desc           %origin_ext_page_top ;
  @origin_int_top_sorted_count       = keys_sorted_by_value_num_desc %origin_int_top ;
  @origin_ext_top_sorted_count       = keys_sorted_by_value_num_desc %origin_ext_top ;
  @origin_ext_page_top_sorted_count  = keys_sorted_by_value_num_desc %origin_ext_page_top ;

  @project_int_top_sorted_alpha      = keys_sorted_alpha_desc           %project_int_top ;
  @project_int_top_sorted_count      = keys_sorted_by_value_num_desc %project_int_top ;

# ReadInputScripts
  @parms_sorted_count                = keys_sorted_by_value_num_desc %parms ;
  @parms_sorted_script               = keys_sorted_alpha_desc        %parms ;

  @scripts_php_sorted_count          = keys_sorted_by_value_num_desc %scripts_php ;
  @scripts_php_sorted_script         = keys_sorted_alpha_asc         %scripts_php ;
  @scripts_js_sorted_count           = keys_sorted_by_value_num_desc %scripts_js ;
  @scripts_js_sorted_script          = keys_sorted_alpha_asc         %scripts_js ;
  @scripts_css_sorted_count          = keys_sorted_by_value_num_desc %scripts_css ;
  @scripts_css_sorted_script         = keys_sorted_alpha_asc         %scripts_css ;

# ReadInputGoogle
  @searches_service_count            = keys_sorted_by_value_num_desc %searches_service ;
  @searches_service_alpha            = keys_sorted_alpha_desc           %searches_service ;
  @searches_toplevel_count           = keys_sorted_by_value_num_desc %searches_toplevel_tld_found ;
  @searches_toplevel_alpha           = keys_sorted_alpha_asc           %searches_toplevel_tld_found ;
  @searches_service_matches_alpha    = keys_sorted_alpha_asc           %searches_service_matches ;

# ReadInputSkins
  @skins_sorted_skin  = keys_sorted_alpha_asc %skins ;
}


#
# isMobile checks M,W,T,P and if $val is one of those then we have a mobile device
# if the record is a group aggregate, then we check the agent string again to see if we have
# a mobile device or not
#


sub isMobile {
  my ($val,$agent) = @_;
  if($val =~ /^[MWTP]$/) {
    return 1;
  } elsif( $val eq 'G') {
    #warn $tags_mobile;
    return $agent =~ /(?:$tags_mobile|$tags_tablet)/io;
  };
  return 0;
}

sub WriteReportClients
{
  &LogSub ("WriteReportClients -> $path_reports/$file_html_clients\n") ;

  open FILE_HTML_CLIENTS, '>', "$path_reports/$file_html_clients" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Browsers e.a./ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Browsers e.a./ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  $html =~ s/LINKS/&ListLinksExcept ($link_browsers)/e ; 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;

  &AddNoticeSurvey (1) ;

# test code, all counts from csv files are in thousands (from 1:1000 sampled page file) and will be scaled x 1000
# thus scale these test figures in reverse direction first
# $html .= &ShowCountTd (891234567890/1000) . "<br>" ;
# $html .= &ShowCountTd (91234567890/1000) . "<br>" ;
# $html .= &ShowCountTd (1234567890/1000) . "<br>" ;
# $html .= &ShowCountTd (234567890/1000) . "<br>" ;
# $html .= &ShowCountTd (34567890/1000) . "<br>" ;
# $html .= &ShowCountTd (4567890/1000) . "<br>" ;
# $html .= &ShowCountTd (567890/1000) . "<br>" ;
# $html .= &ShowCountTd (67890/1000) . "<br>" ;
# $html .= &ShowCountTd (7890/1000) . "<br>" ;
# $html .= &ShowCountTd (890/1000) . "<br>" ;
# $html .= &ShowCountTd (90/1000) . "<br>" ;
# $html .= &ShowCountTd (1/1000) . "<br>" ;
# $html .= &ShowCountTd (0)     . "<br>" ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><td class=l colspan=99 wrap>The following overview of page requests per client (~browser) application is based on the <a href='http://en.wikipedia.org/wiki/User_agent'>user agent</a> information that accompanies most server requests.<br>" .
           "Please note that agent information does not follow strict guidelines and some programs may provide wrong information on purpose.<br>" .
           "This report ignores all requests where agent information is missing, or contains any of the following: bot, crawl(er) or spider.<p>" .
           "<b>Recommended reading:</b> <a href='http://en.wikipedia.org/wiki/Usage_share_of_web_browsers'>Wikipedia article</a> on usage share of web browsers and measurement methodology." .
           "</td></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY
  $html .= "<tr><td width=50% valign=top style='vertical-align:top'>" ;
  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In order of popularity</h3></th></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY, BROWSERS, NON MOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Browsers, non mobile</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  $perc_total_nonmobile = 0 ;
  $perc_total_html_only_nonmobile = 0 ;
  foreach $key (@clientgroups_sorted_count)
  {
    $count = $clientgroups {$key} ;
    next if $count == 0 ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    next if $mobile ne '-' ;
  # next if isMobile($mobile);
    $count = &FormatCount ($count) ;

    $count_html_only = $clientgroups_html_only {$key} ;
    $perc_html_only  = $clientgroups_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$group</a></td>" . &ShowCountTd($count) . "<td class=r>$perc</td>" . &ShowCountTd($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;

    $perc =~ s/\%// ;
    $perc_html_only =~ s/\%// ;

    $perc_total_nonmobile += $perc ;
    $perc_total_html_only_nonmobile += $perc_html_only ;
  }

  $perc = ".." ;
  $count = $clientgroups_other {'-'} ;
  if ($total_all_clientgroups > 0)
  {
    $perc = sprintf ("%.2f", 100 * $clientgroups_other {'-'} / $total_all_clientgroups) ;
    $perc_total_nonmobile += $perc ;
  }
  $perc_html_only = ".." ;
  $count_html_only = $clientgroups_other_html_only {'-'} ;
  if ($total_all_clientgroups > 0)
  {
    $perc_html_only = sprintf ("%.2f", 100 * $clientgroups_other_html_only {'-'} / $total_all_clientgroups_html_only) ;
    $perc_total_html_only_nonmobile += $perc_html_only ;
  }

  $html .= "<tr><td class=l>Other</th>" . &ShowCountTd ($count) . "<td class=r>$perc\%</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only\%</td></tr>\n" ;

  $total = &FormatCount ($total_clientgroups {'-'}) ;
  $perc_total_nonmobile = sprintf ("%.1f", $perc_total_nonmobile) ;

  $total_html_only = &FormatCount ($total_clientgroups_html_only {'-'}) ;
  $perc_total_html_only_nonmobile = sprintf ("%.1f", $perc_total_html_only_nonmobile) ;

  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_nonmobile\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_nonmobile\%</th></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY, BROWSERS, TABLET
  $html .= "<tr><th class=l>&nbsp;<br>Browsers, tablets</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  $perc_total_tablet = 0 ;
  $perc_total_html_only_tablet = 0 ;
  foreach $key (@clientgroups_sorted_count)
  {
    $count = $clientgroups {$key} ;
    next if $count == 0 ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    next if $mobile ne 'T' ;
    $count = &FormatCount ($count) ;

    $count_html_only = $clientgroups_html_only {$key} ;
    $perc_html_only  = $clientgroups_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$group</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
    $perc =~ s/\%// ;
    $perc_html_only =~ s/\%// ;

    $perc_total_tablet += $perc ;
    $perc_total_html_only_tablet += $perc_html_only ;
  }

  $count = $clientgroups_other {'T'} ;
  $perc = ".." ;
  if ($total_all_clientgroups> 0)
  { $perc = sprintf ("%.2f", 100 * $count / ($total_all_clientgroups )) ; }

  $count_html_only = $clientgroups_other_html_only {'T'} ;
  $perc_html_only = ".." ;
  if ($total_all_clientgroups > 0)
  { $perc_html_only = sprintf ("%.2f", 100 * $count_html_only / ($total_all_clientgroups)) ; }

  $perc_total_mobile = sprintf ("%.1f", $perc_total_mobile) ;
  $total = &FormatCount ($total_clientgroups {'T'}) ;
  $perc_total_html_only_mobile = sprintf ("%.1f", $perc_total_html_only_tablet) ;

  $total_html_only = &FormatCount ($total_clientgroups_html_only {'T'}) ;

  $html .= "<tr><td class=l>Other</th>" . &ShowCountTd ($count) . "<td class=r>$perc\%</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_tablet\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_tablet\%</th></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY, BROWSERS, MOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Browsers, other mobile</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  $perc_total_mobile = 0 ;
  $perc_total_html_only_mobile = 0 ;
  foreach $key (@clientgroups_sorted_count)
  {
    $count = $clientgroups {$key} ;
    next if $count == 0 ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    next if $mobile ne 'M' ;
  # next if !isMobile($mobile);

    $count = &FormatCount ($count) ;

    $count_html_only = $clientgroups_html_only {$key} ;
    $perc_html_only  = $clientgroups_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$group</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
    $perc =~ s/\%// ;
    $perc_html_only =~ s/\%// ;

    $perc_total_mobile += $perc ;
    $perc_total_html_only_mobile += $perc_html_only ;
  }

  $count = $clientgroups_other {'M'} ;
  $perc = ".." ;
  if ($total_all_clientgroups> 0)
  { $perc = sprintf ("%.2f", 100 * $count / ($total_all_clientgroups )) ; }

  $count_html_only = $clientgroups_other_html_only {'M'} ;
  $perc_html_only = ".." ;
  if ($total_all_clientgroups > 0)
  { $perc_html_only = sprintf ("%.2f", 100 * $count_html_only / ($total_all_clientgroups)) ; }

  $perc_total_mobile = sprintf ("%.1f", $perc_total_mobile) ;
  $total = &FormatCount ($total_clientgroups {'M'}) ;
  $perc_total_html_only_mobile = sprintf ("%.1f", $perc_total_html_only_mobile) ;

  $total_html_only = &FormatCount ($total_clientgroups_html_only {'M'}) ;

  $html .= "<tr><td class=l>Other</th>" . &ShowCountTd ($count) . "<td class=r>$perc\%</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_mobile\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_mobile\%</th></tr>\n" ;


  # CLIENTS SORTED BY FREQUENCY, BROWSERS, WAP
  $html .= "<tr><th class=l>&nbsp;<br>Browsers, WAP</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  $perc_total_wap = 0 ;
  $perc_total_html_only_wap = 0 ;
  foreach $key (@clientgroups_sorted_count)
  {
    $count = $clientgroups {$key} ;
    next if $count == 0 ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    next if $mobile ne 'P' ;
    $count = &FormatCount ($count) ;

    $count_html_only = $clientgroups_html_only {$key} ;
    $perc_html_only  = $clientgroups_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$group</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
    $perc =~ s/\%// ;
    $perc_html_only =~ s/\%// ;

    $perc_total_wap += $perc ;
    $perc_total_html_only_wap += $perc_html_only ;
  }

  $count = $clientgroups_other {'P'} ;
  $perc = ".." ;
  if ($total_all_clientgroups> 0)
  { $perc = sprintf ("%.2f", 100 * $count / ($total_all_clientgroups )) ; }

  $count_html_only = $clientgroups_other_html_only {'P'} ;
  $perc_html_only = ".." ;
  if ($total_all_clientgroups > 0)
  { $perc_html_only = sprintf ("%.2f", 100 * $count_html_only / ($total_all_clientgroups)) ; }

  $perc_total_mobile = sprintf ("%.1f", $perc_total_mobile) ;
  $total = &FormatCount ($total_clientgroups {'P'}) ;
  $perc_total_html_only_mobile = sprintf ("%.1f", $perc_total_html_only_mobile) ;

  $total_html_only = &FormatCount ($total_clientgroups_html_only {'P'}) ;

  $html .= "<tr><td class=l>Other</th>" . &ShowCountTd ($count) . "<td class=r>$perc\%</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_wap\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_wap\%</th></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY, BROWSERS, WIKIMOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Mobile applications</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  $perc_total_wiki = 0 ;
  $perc_total_html_only_wiki = 0 ;

  foreach $key (@clientgroups_sorted_count)
  {
    $count = $clientgroups {$key} ;
    next if $count == 0 ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    next if $mobile ne 'W' ;
    $count = &FormatCount ($count) ;

    $count_html_only = $clientgroups_html_only {$key} ;
    $perc_html_only  = $clientgroups_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$group</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
    $perc =~ s/\%// ;
    $perc_html_only =~ s/\%// ;
    $perc_total_wiki += $perc ;
    $perc_total_html_only_wiki += $perc_html_only ;
  }

  $count = $clientgroups_other {'W'} ;
  $perc = ".." ;
  if ($total_all_clientgroups> 0)
  { $perc = sprintf ("%.2f", 100 * $count / $total_all_clientgroups) ; }

  $count_html_only = $clientgroups_other_html_only {'W'} ;
  $perc_html_only = ".." ;
  if ($total_all_clientgroups > 0)
  { $perc_html_only = sprintf ("%.2f", 100 * $count_html_only / ($total_all_clientgroups)) ; }

  $total = &FormatCount ($total_clientgroups {'W'}) ;

  $perc_total_wiki = sprintf ("%.1f", $perc_total_wiki) ;
  $perc_total_html_only_wiki = sprintf ("%.1f", $perc_total_html_only_wiki) ;

  $total_html_only = &FormatCount ($total_clientgroups_html_only {'W'}) ;

  $html .= "<tr><td class=l>Other</th>" . &ShowCountTd ($count) . "<td class=r>$perc\%</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_wiki\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_wiki\%</th></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY, BROWSER VERSIONS, NON MOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Browser versions, non mobile</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;

  foreach $key (@clients_sorted_count)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    next if $rectype ne '-' ; # group
    $perc  = $clients_perc {$key} ;
    next if $perc lt "0.02%" ;
    $count = &FormatCount ($count) ;

    $count_html_only = $clients_html_only {$key} ;
    $perc_html_only  = $clients_perc_html_only {$key} ;

    $html .= "<tr><td class=l>$client</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
    $perc =~ s/\%// ;
  }

  $total = &FormatCount ($total_clients_non_mobile) ;

  $total_html_only = &FormatCount ($total_clients_non_mobile_html_only) ;

  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_nonmobile\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_nonmobile\%</th></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY, BROWSER VERSIONS, TABLET
  $html .= "<tr><th class=l>&nbsp;<br>Browser versions, tablet</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  foreach $key (@clients_sorted_count)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    next if $rectype ne 'T' ; # group
    $perc  = $clients_perc {$key} ;
    next if $perc lt "0.005%" ;
    $count = &FormatCount ($count) ;

    $perc_html_only  = $clients_perc_html_only {$key} ;
    $count_html_only = $clients_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$client</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
  }

  $total = &FormatCount ($total_clients_tablet) ;
  $perc  = sprintf ("%.1f", $perc_total_tablet) ;

  $total_html_only = &FormatCount ($total_clients_tablet_html_only) ;
  $perc_html_only  = sprintf ("%.1f", ($perc_total_html_only_tablet)) ;

  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_html_only\%</th></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY, BROWSER VERSIONS, MOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Browser versions, mobile</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  foreach $key (@clients_sorted_count)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    next if $rectype ne 'M' ; # group
  # next if !isMobile($rectype) ; # group
    $perc  = $clients_perc {$key} ;
    next if $perc lt "0.005%" ;
    $count = &FormatCount ($count) ;

    $perc_html_only  = $clients_perc_html_only {$key} ;
    $count_html_only = $clients_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$client</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
  }

  $total = &FormatCount ($total_clients_mobile) ;
  $perc  = sprintf ("%.1f", $perc_total_mobile) ;

  $total_html_only = &FormatCount ($total_clients_mobile_html_only) ;
  $perc_html_only  = sprintf ("%.1f", ($perc_total_html_only_mobile)) ;

  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_html_only\%</th></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY, BROWSER VERSIONS, WAP
  $html .= "<tr><th class=l>&nbsp;<br>Browser versions, WAP</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  foreach $key (@clients_sorted_count)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    next if $rectype ne 'P' ; # group
    $perc  = $clients_perc {$key} ;
    next if $perc lt "0.005%" ;
    $count = &FormatCount ($count) ;

    $perc_html_only  = $clients_perc_html_only {$key} ;
    $count_html_only = $clients_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$client</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
  }

  $total = &FormatCount ($total_clients_wap) ;
  $perc  = sprintf ("%.1f", $perc_total_wap) ;

  $total_html_only = &FormatCount ($total_clients_wap_html_only) ;
  $perc_html_only  = sprintf ("%.1f", ($perc_total_html_only_wap)) ;

  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_html_only\%</th></tr>\n" ;

  # CLIENTS SORTED BY FREQUENCY, BROWSER VERSIONS, WIKIMOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Mobile application versions</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  foreach $key (@clients_sorted_count)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    next if $rectype ne 'W' ; # group
    $perc  = $clients_perc {$key} ;
    next if $perc lt "0.001%" ;
    $count = &FormatCount ($count) ;

    $perc_html_only  = $clients_perc_html_only {$key} ;
    $count_html_only = $clients_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$client</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
  }

  $total = &FormatCount ($total_clients_wiki_mobile) ;
  $perc  = sprintf ("%.1f", $perc_total_wiki) ;

  $total_html_only = &FormatCount ($total_clients_wiki_mobile_html_only) ;
  $perc_html_only  = sprintf ("%.1f", $perc_total_html_only_wiki) ;

  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_html_only\%</th></tr>\n" ;

  $html .= "</table>\n" ;

  # CLIENTS IN ALPHABETHICAL ORDER
  $html .= "</td><td width=50% valign=top>" ;
  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In alphabetical order</h3></th></tr>\n" ;

  # CLIENTS IN ALPHABETHICAL ORDER, BROWSERS, NON MOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Browsers, non mobile</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  foreach $key (@clientgroups_sorted_alpha)
  {
    $count = $clientgroups {$key} ;
    next if $count == 0 ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    next if $mobile ne '-' ;
  # next if isMobile($mobile);
    $count = &FormatCount ($count) ;

    $count_html_only = $clientgroups_html_only {$key} ;
    $perc_html_only  = $clientgroups_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$group</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;

    $perc =~ s/\%// ;
    $perc_html_only =~ s/\%// ;
   }

  $count = $clientgroups_other {'-'} ;
  $total = &FormatCount ($total_clientgroups {'-'}) ;
  $perc = ".." ;
  if ($total_all_clientgroups> 0)
  { $perc = sprintf ("%.2f", 100 * $count / $total_all_clientgroups) ; }

  $count_html_only = $clientgroups_other_html_only {'-'} ;
  $total_html_only = &FormatCount ($total_clientgroups_html_only {'-'}) ;
  $perc_html_only = ".." ;
  if ($total_all_clientgroups > 0)
  { $perc_html_only = sprintf ("%.2f", 100 * $count_html_only / ($total_all_clientgroups)) ; }

  $html .= "<tr><td class=l>Other</th>" . &ShowCountTd ($count) . "<td class=r>$perc\%</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_nonmobile\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_nonmobile\%</th></tr>\n" ;

  # CLIENTS IN ALPHABETHICAL ORDER, BROWSERS, TABLET
  $html .= "<tr><th class=l>&nbsp;<br>Browsers, tablet</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  foreach $key (@clientgroups_sorted_alpha)
  {
    $count = $clientgroups {$key} ;
    next if $count == 0 ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    next if $mobile ne 'T' ;
    $count = &FormatCount ($count) ;

    $count_html_only = $clientgroups_html_only {$key} ;
    $perc_html_only  = $clientgroups_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$group</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
    $perc =~ s/\%// ;
  }

  $count = $clientgroups_other {'T'} ;
  $total = &FormatCount ($total_clientgroups {'T'}) ;
  $perc = sprintf ("%.2f", 100 * $count / $total_all_clientgroups) ;

  $count_html_only = $clientgroups_other_html_only {'T'} ;
  $total_html_only = &FormatCount ($total_clientgroups_html_only {'T'}) ;
  $perc_html_only = sprintf ("%.2f", 100 * $count_html_only / ($total_all_clientgroups)) ;

  $html .= "<tr><td class=l>Other</th>" . &ShowCountTd ($count) . "<td class=r>$perc\%</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_tablet\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_tablet\%</th></tr>\n" ;

  # CLIENTS IN ALPHABETHICAL ORDER, BROWSERS, MOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Browsers, other mobile</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  foreach $key (@clientgroups_sorted_alpha)
  {
    $count = $clientgroups {$key} ;
    next if $count == 0 ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    next if $mobile ne 'M' ;
  # next if !isMobile($mobile);
    $count = &FormatCount ($count) ;

    $count_html_only = $clientgroups_html_only {$key} ;
    $perc_html_only  = $clientgroups_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$group</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
    $perc =~ s/\%// ;
  }

  $count = $clientgroups_other {'M'} ;
  $total = &FormatCount ($total_clientgroups {'M'}) ;
  $perc = sprintf ("%.2f", 100 * $count / $total_all_clientgroups) ;

  $count_html_only = $clientgroups_other_html_only {'M'} ;
  $total_html_only = &FormatCount ($total_clientgroups_html_only {'M'}) ;
  $perc_html_only = sprintf ("%.2f", 100 * $count_html_only / ($total_all_clientgroups)) ;

  $html .= "<tr><td class=l>Other</th>" . &ShowCountTd ($count) . "<td class=r>$perc\%</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_mobile\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_mobile\%</th></tr>\n" ;

  # CLIENTS IN ALPHABETHICAL ORDER, BROWSERS, WAP
  $html .= "<tr><th class=l>&nbsp;<br>Browsers, WAP</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  foreach $key (@clientgroups_sorted_alpha)
  {
    $count = $clientgroups {$key} ;
    next if $count == 0 ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    next if $mobile ne 'P' ;
    $count = &FormatCount ($count) ;

    $count_html_only = $clientgroups_html_only {$key} ;
    $perc_html_only  = $clientgroups_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$group</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
    $perc =~ s/\%// ;
  }

  $count = $clientgroups_other {'P'} ;
  $total = &FormatCount ($total_clientgroups {'P'}) ;
  $perc = sprintf ("%.2f", 100 * $count / $total_all_clientgroups) ;

  $count_html_only = $clientgroups_other_html_only {'P'} ;
  $total_html_only = &FormatCount ($total_clientgroups_html_only {'P'}) ;
  $perc_html_only = sprintf ("%.2f", 100 * $count_html_only / ($total_all_clientgroups)) ;

  $html .= "<tr><td class=l>Other</th>" . &ShowCountTd ($count) . "<td class=r>$perc\%</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_wap\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_wap\%</th></tr>\n" ;

  # CLIENTS IN ALPHABETHICAL ORDER, BROWSERS, WIKIMOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Mobile applications</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  foreach $key (@clientgroups_sorted_alpha)
  {
    $count = $clientgroups {$key} ;
    next if $count == 0 ;
    $perc  = $clientgroups_perc {$key} ;
    ($mobile,$group) = split (',', $key) ;
    next if $mobile ne 'W' ;
    $count = &FormatCount ($count) ;

    $count_html_only = $clientgroups_html_only {$key} ;
    $perc_html_only  = $clientgroups_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$group</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
    $perc =~ s/\%// ;
  }

  $count = $clientgroups_other {'W'} ;
  $total = &FormatCount ($total_clientgroups {'W'}) ;
  $perc = sprintf ("%.2f", 100 * $count / $total_all_clientgroups) ;

  $count_html_only = $clientgroups_other_html_only {'W'} ;
  $total_html_only = &FormatCount ($total_clientgroups_html_only {'W'}) ;
  $perc_html_only = sprintf ("%.2f", 100 * $count_html_only / ($total_all_clientgroups)) ;

  $html .= "<tr><td class=l>Other</th>" . &ShowCountTd ($count) . "<td class=r>$perc\%</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only\%</td></tr>\n" ;
  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc_total_wiki\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_total_html_only_wiki\%</th></tr>\n" ;

  # CLIENTS IN ALPHABETHICAL ORDER, BROWSER VERSIONS, NON MOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Browser versions, non mobile</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;

  foreach $key (@clients_sorted_alpha)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    next if $rectype ne '-' ; # group
  # next if isMobile($rectype); # group
    $perc  = $clients_perc {$key} ;
    next if $perc lt "0.005%" ;
    $count = &FormatCount ($count) ;

    $count_html_only = $clients_html_only {$key} ;
    $perc_html_only  = $clients_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$client</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
  }
  $total = &FormatCount ($total_clients_non_mobile) ;
  $perc = sprintf ("%.1f",100*$total_clients_non_mobile / ($total_clients_mobile + $total_clients_non_mobile + $total_clients_wiki_mobile)) ;

  $total_html_only = &FormatCount ($total_clients_non_mobile_html_only) ;
  $perc_html_only = sprintf ("%.1f",100*$total_clients_non_mobile_html_only / ($total_clients_mobile_html_only + $total_clients_non_mobile_html_only + $total_clients_wiki_mobile_html_only)) ;

  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_html_only\%</th></tr>\n" ;

  # CLIENTS IN ALPHABETHICAL ORDER, BROWSER VERSIONS, MOBILE
  $html .= "<tr><th class=l>&nbsp;<br>Browser versions, mobile</th><th colspan=2 class=c>&nbsp;<br>All requests</th><th colspan=2 class=c>&nbsp;<br>Html pages</th></tr>\n" ;
  foreach $key (@clients_sorted_alpha)
  {
    $count = $clients {$key} ;
    ($rectype, $client) = split (',', $key,2) ;
    next if $rectype ne 'M' && $rectype ne 'W' && $rectype ne 'T' && $rectype ne 'P'; # group
  # next if !isMobile($rectype); # group
    $perc  = $clients_perc {$key} ;
    next if $perc lt "0.02%" ;
    $count = &FormatCount ($count) ;

    $count_html_only = $clients_html_only {$key} ;
    $perc_html_only  = $clients_perc_html_only {$key} ;
    $count_html_only = &FormatCount ($count_html_only) ;

    $html .= "<tr><td class=l>$client</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td>" . &ShowCountTd ($count_html_only) . "<td class=r>$perc_html_only</td></tr>\n" ;
  }
  $total = &FormatCount ($total_clients_mobile) ;
  $perc = sprintf ("%.1f",100*$total_clients_mobile / ($total_clients_mobile + $total_clients_non_mobile + $total_clients_wiki_mobile)) ;

  $total_html_only = &FormatCount ($total_clients_mobile_html_only) ;
  $perc_html_only = sprintf ("%.1f",100*$total_clients_mobile_html_only / ($total_clients_mobile_html_only + $total_clients_non_mobile_html_only + $total_clients_wiki_mobile_html_only)) ;

  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total) . "<th class=r>$perc\%</th>" . &ShowCountTh ($total_html_only) . "<th class=r>$perc_html_only\%</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;<br>Browser engines</th></tr>\n" ;

  #$engine_prev = "" ;
  #foreach $engine (@webkit_engines_sorted_alpha)
  #{
  #  $total = $webkit_engines {$engine} ;

  #  next if $total < 5 ;

  #  $engine2 = $engine ;
  #  $engine2 =~ s/\/.*$// ;
  #  $engine2 =~ s/ .*$// ;
  #  if (($engine2 ne $engine_prev) && ($engine_prev ne ""))
  #  {
  #    $total_engine = $total_engines {$engine_prev} ;
  #    $perc_engine = sprintf ("%.1f", 100 * $total_engine / ($total_clients_mobile + $total_clients_non_mobile + $total_clients_wiki_mobile)) ;
  #    $total_engine = &FormatCount ($total_engine) ;
  #    $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total_engine) . "<th class=r>$perc_engine\%</th></tr>\n" ;
  #  }
  #  $engine_prev = $engine2 ;
  #  $total = &FormatCount ($total) ;
  #  $html .= "<tr><td class=l>$engine</td>" . &ShowCountTd ($total) . "<td class=r>&nbsp;</td></tr>\n" ;
  #}
  #$total_engine = $total_engines {$engine_prev} ;
  #$perc_engine = sprintf ("%.1f", 100 * $total_engine / ($total_clients_mobile + $total_clients_non_mobile + $total_clients_wiki_mobile)) ;
  #$total_engine = &FormatCount ($total_engine) ;
  #$html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total_engine) . "<th class=r>$perc_engine\%</th></tr>\n" ;

  $engine_prev = "" ;
  foreach $engine (@engines_sorted_alpha)
  {
    $total = $engines {$engine} ;

    next if $total < 5 ;

    $engine2 = $engine ;
    $engine2 =~ s/\/.*$// ;
    $engine2 =~ s/ .*$// ;
    if (($engine2 ne $engine_prev) && ($engine_prev ne ""))
    {
      $total_engine = $total_engines {$engine_prev} ;
      $perc_engine = sprintf ("%.1f", 100 * $total_engine / ($total_clients_mobile + $total_clients_non_mobile + $total_clients_wiki_mobile)) ;
      $total_engine = &FormatCount ($total_engine) ;
      $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total_engine) . "<th class=r>$perc_engine\%</th></tr>\n" ;
    }
    $engine_prev = $engine2 ;
    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$engine</td>" . &ShowCountTd ($total) . "<td class=r>&nbsp;</td></tr>\n" ;
  }
  $total_engine = $total_engines {$engine_prev} ;
  $perc_engine = sprintf ("%.1f", 100 * $total_engine / ($total_clients_mobile + $total_clients_non_mobile + $total_clients_wiki_mobile)) ;
  $total_engine = &FormatCount ($total_engine) ;
  $html .= "<tr><th class=l>Total</th>" . &ShowCountTh ($total_engine) . "<th class=r>$perc_engine\%</th></tr>\n" ;

  $html .= "</table>\n" ;
  $html .= "</td></tr>\n" ;

  $html .= "<tr><td colspan=99 class=l wrap>Requests from mobile devices are recognized as follows:<br>" .
           "Agent string contains any of the following terms (last upd: $month_upd_keywords_mobile):<br>" .
           "<i>$keywords_mobile</i></td></tr>" ;

  $html .= "</table>\n" ;

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon_ez ;

  print FILE_HTML_CLIENTS $html ;
  close FILE_HTML_CLIENTS ;
}

sub ListLinksExcept
{
  my ($link_skip) = @_ ;

  my $links = "&nbsp;Requests: " ;
  
  $links .= ($link_skip ne $link_requests    ? $link_requests    : $dummy_requests)    . " - " ;
  $links .= ($link_skip ne $link_origins     ? $link_origins     : $dummy_origins)     . " - " ;
  $links .= ($link_skip ne $link_methods     ? $link_methods     : $dummy_methods)     . " - " ;
  $links .= ($link_skip ne $link_scripts     ? $link_scripts     : $dummy_scripts)     . " - " ;
  $links .= ($link_skip ne $link_user_agents ? $link_user_agents : $dummy_user_agents) . " - " ;
  $links .= ($link_skip ne $link_skins       ? $link_skins       : $dummy_skins)       . " - " ;
  $links .= ($link_skip ne $link_crawlers    ? $link_crawlers    : $dummy_crawlers)    . " - " ;
  $links .= ($link_skip ne $link_opsys       ? $link_opsys       : $dummy_opsys)       . " - " ;
  $links .= ($link_skip ne $link_browsers    ? $link_browsers    : $dummy_browsers)    . " - " ;
  $links .= ($link_skip ne $link_google      ? $link_google      : $dummy_google)      . " - " ;
  $links .= ($link_skip ne $link_countries   ? $link_countries   : $dummy_countries) ;
# $links .= ($link_skip ne $link_ua_trends   ? $link_ua_trends   : $dummy_ua_trends) ;
  if ($ShowDevices)
  { $links .= ($link_skip ne $link_devices     ? " - " . $link_devices     : " - " . $dummy_devices) ; }

  return $links ;
}

sub ListLinksGeoExcept
{
  my ($link_skip) = @_ ;

  my $links = "&nbsp;Geographical info: " ;
  
  $links .= ($link_skip ne $link_countries_overview   ? $link_countries_overview   : $dummy_countries_overview)   . " - " ;
  $links .= ($link_skip ne $link_countries_useragents ? $link_countries_useragents : $dummy_countries_useragents) . " - " ;
  $links .= ($link_skip ne $link_countries_browsers   ? $link_countries_browsers   : $dummy_countries_browsers)   . " - " ;
  $links .= ($link_skip ne $link_countries_os         ? $link_countries_os         : $dummy_countries_os)         . " - " ;
  $links .= ($link_skip ne $link_countries_projects   ? $link_countries_projects   : $dummy_countries_projects)   . " - " ;
  $links .= ($link_skip ne $link_countries_trends     ? $link_countries_trends     : $dummy_countries_trends) ;

  return $links ;
}

sub ListLinksTrendsExcept
{
  my ($link_skip) = @_ ;

  my $links = "&nbsp;Trends: " ;
  
  $links .= ($link_skip ne $link_user_agents      ? $link_user_agents      : $dummy_user_agents) . " - " ;
# $links .= ($link_skip ne $link_trends_countries ? $link_trends_countries : $dummy_countries)   . " - " ;
  $links .= ($link_skip ne $link_trends_browsers  ? $link_trends_browsers  : $dummy_browsers)    . " - " ;
  $links .= ($link_skip ne $link_trends_devices   ? $link_trends_devices   : $dummy_devices) ;

  return $links ;
}

sub WriteReportCrawlers
{
  &LogSub ("WriteReportCrawlers\n") ;

  open FILE_HTML_CRAWLERS, '>', "$path_reports/$file_html_crawlers" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Crawler requests/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Crawler requests/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  
  $html =~ s/LINKS/&ListLinksExcept ($link_crawlers)/e ; 

  &AddNoticeSurvey (8) ;

  $html .= "<h2><font color=#A00>April 2015: report broken</h2><p>See <a href='https://phabricator.wikimedia.org/T96372?workflow=create'>Phabricator T96372</a>" ;

if ($crawler_report_repaired)
{ 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><td class=l colspan=99>The following overview of crawler (aka bot) page requests is based on the <a href='http://en.wikipedia.org/wiki/User_agent'>user agent</a> information that accompanies most server requests." .
           " Unfortunately this user agent information follows rather loosely defined guidelines." .
           "<br>Also please bear in mind than the most popular crawler names may be somewhat overrepresented." .
           " This is the result of so called <i>user agent spoofing</i> (where a requester supplies false credentials, e.g. to bypass web servers filters)." .
           "<br>GoogleBot seems to be a favorite for spoofing. Therefore requests from an ip address registered by Google (see below) are color coded <b><font color=green>GoogleBot</font></b>, others <b><font color=red>GoogleBot</font></b>" .
           "<p>For this report page requests are considered to be issued by a crawler in two cases:" .
           "<br>1 The user agent string contains a web address (only crawlers should have that, but there a some false positives, " .
           "  where a browser sends a user agent string with a web address (ill behaved plug-in, main offenders have been eliminated)" .
           "<br>2 The user agent string contains the term bot, spider or crawl[er]'" .
           "PERC_GOOGLE\n" .
           "</td></tr>\n" ;


  $total_crawlers = 0 ;
# $html .= "<tr><th class=l>Count<br><small>x 1000</small></th><th class=l>Secondary domain<br>(~site) name</th><th class=l>Mime type</th><th class=l>User agent</th></tr>\n" ;
  foreach $mime_agent (keys_sorted_by_value_num_desc %crawlers)
  {
    $count = $crawlers {$mime_agent} ;
    ($mime, $agent) = split ('\|', $mime_agent,2) ;
    $agent =~ s/([^,;\(\)\s]+?\@[^,;\(\)\s]+)/ <font color=#808080>mail address<\/font> /g ;
    $agent =~ s/([\w-]+\s*.?at.?\s*[\w-]+\s*.?dot.?\s*[\w-]+)/ <font color=#808080>mail address<\/font> /gi ;
    $site = "-" ;
    if ($agent =~ /http:/)
    {
      $site = $agent ;
      $site =~ s/^.*?http:/http:/ ;
      $site =~ s/&gt;/>/gi ;
      $site =~ s/&lt;/</gi ;
      $site =~ s/^(.*?)[,;\)\<\>\s)].*$/$1/ ;
    }
    $agent =~ s/\Q$site\E/<b>$site<\/b>/ ;
 #  $agent =~ s/\Q$site\E// ;

    $secondary_domain = &GetSecondaryDomain ($site) ;
    if (($secondary_domain eq "google") and ($agent =~ /color=red>GoogleBot</))
    { $secondary_domain .= "?" ; }

    $secondary_domains {$secondary_domain} += $count ;

    if ($secondary_domain ne "-")
    { $crawlers_per_domain {$secondary_domain} {$mime_agent} += $count ; }
    else
    {
      $crawlers_no_url  {$agent} {$mime} += $count ;
      $crawlers_no_url_agent {$agent} += $count ;
    }

    $total_crawlers += $count ;

    next if $count <= 2 ;

    # $count = &FormatCount ($count) ;
    # $html .= "<tr>" . &ShowCountTd ($count) . "<td class=l><a href='$site'>$secondary_domain</a></td><td class=l>$mime</td><td class=l>$agent</td></tr>\n" ;
    # $rows++ ;
  }

  $perc_crawlers = ".." ;
  if ($total_page_requests_external > 0)
  { $perc_crawlers = sprintf ("%.1f",100 * $total_page_crawlerrequests/$total_page_requests_external) ; }

  $total_page_requests_external2 = &FormatCount ($total_page_requests_external*1000) ;
  $total_page_crawlerrequests2 = &FormatCount ($total_page_crawlerrequests*1000) ;
  $html =~ s/PERC_GOOGLE/<p>In total $total_page_crawlerrequests2 page requests (mime type <a href='SquidReportRequests.htm'>text\/html<\/a> only!) per day are considered crawler requests, out of $total_page_requests_external2 external requests, which is $perc_crawlers%/ ;

  $total_crawlers = &FormatCount ($total_crawlers) ;
# $html .= "<tr><th class=l>$total_crawlers</th><th class=l colspan=2>total</th></tr>\n" ;
# $html .= "</table><p>\n" ;

#  $html .= "<table border=1>\n" ;
#  $html .= "<tr><th class=l colspan=99>Top 25 secondary domains<br>(~ sites) mentioned</th></tr>\n" ;
#  foreach $secondary_domain (keys_sorted_by_value_num_desc %secondary_domains)
#  {
#    next if $secondary_domain eq ".." ;
#    last if ++$secondary_domains_listed > 25 ;
#
#    $count = $secondary_domains {$secondary_domain} ;
#    $count = &FormatCount ($count) ;
#    $html .= "<tr>" . &ShowCountTd ($count) . "<td class=l colspan=2>$secondary_domain</td></tr>\n" ;
#  }
#  $html .= "</table>\n" ;

  $html .= "<tr><th class=lh3 colspan=99>Page requests for crawlers that specify a url in the agent string</th></tr>\n" ;
  $html .= "<tr><th class=l>Count<br><small>x 1000</small></th><th class=l>Secondary domain<br>(~site) name</th><th class=l>URL</th><th class=l>Mime type</th><th class=l>User agent</th></tr>\n" ;
  foreach $secondary_domain (keys_sorted_by_value_num_desc %secondary_domains)
  {
    next if $secondary_domain eq "-" ;

    $total = $secondary_domains {$secondary_domain} ;
    $total_crawlers_url += $total ;

    last if $total < 10 ;

    $total = &FormatCount ($total) ;
    $html .= "<tr>" . &ShowCountTh ($total) . "<th class=l colspan=99>$secondary_domain</th></tr>\n" ;
    foreach $mime_agent (sort {$crawlers_per_domain {$secondary_domain} {$b} <=> $crawlers_per_domain {$secondary_domain} {$a}} keys %{$crawlers_per_domain {$secondary_domain}})
    {
      ($mime, $agent) = split ('\|', $mime_agent,2) ;
      $agent =~ s/([^,;\(\)\s]+?\@[^,;\(\)\s]+)/ <font color=#808080>mail address<\/font> /g ;
      $agent =~ s/([\w-]+\s*.?at.?\s*[\w-]+\s*.?dot.?\s*[\w-]+)/ <font color=#808080>mail address<\/font> /gi ;
      $site = "-" ;
      if ($agent =~ /http:/)
      {
        $site = $agent ;
        $site =~ s/^.*?http:/http:/ ;
        $site =~ s/&gt;/>/gi ;
        $site =~ s/&lt;/</gi ;
        $site =~ s/^(.*?)[,;\)\<\>\s)].*$/$1/ ;
      }
    # $agent =~ s/\Q$site\E/<b>$site<\/b> <a href='$site'>x<\/a>/ ;
      if ($site ne "-")
      { $agent =~ s/\Q$site\E/<b>url<\/b>/ ; }
      $count = $crawlers_per_domain {$secondary_domain} {$mime_agent} ;

      next if $count <= 2 ;

    # print "[$secondary_domain] [$mime_agent] : $count\n" ;
      $count = &FormatCount ($count) ;
      ($site2 = $site) =~ s/^http:\/\/// ;
      $html .= "<tr>" . &ShowCountTd ($count) . "<td class=l>&nbsp;</td><td class=l><a href='$site' ref='nofollow'>$site2<\/a></td><td class=l>$mime</td><td class=l>$agent</td></tr>\n" ;
      $rows++ ;
    }
  }
  $total_crawlers_url = &FormatCount ($total_crawlers_url) ;
  $html .= "<tr><th class=l>$total_crawlers_url</th><th class=l colspan=99>total</th></tr>\n" ;
  $html .= "</table><p>\n" ;

  $total_crawlers_no_url = 0 ;
  $html .= "<table border=1>\n" ;
  $html .= "<tr><th class=lh3 colspan=99>Page requests for probable crawlers, recognized by keyword</th></tr>\n" ;
  $html .= "<tr><th class=l width=40>Count<br><small>x 1000</small></th><th class=l colspan=99>Agent string</th></tr>\n" ;
  $html .= "<tr><th class=l width=40>&nbsp;</td><th class=l width=40>&nbsp;</td><th class=l>Mime type (count &ge; 3)</th></tr>\n" ;
  foreach $agent (keys_sorted_by_value_num_desc %crawlers_no_url_agent)
  {
    $total = $crawlers_no_url_agent {$agent} ;
    $total_crawlers_no_url += $total ;

    last if $total < 3 ;

    $total = &FormatCount ($total) ;
    $html .= "<tr>" . &ShowCountTh ($total) . "<td class=l colspan=99>$agent</td></tr>\n" ;
    foreach $mime (sort {$crawlers_no_url {$agent} {$b} <=> $crawlers_no_url {$agent} {$a}} keys %{$crawlers_no_url {$agent}})
    {
      $agent =~ s/([^,;\(\)\s]+?\@[^,;\(\)\s]+)/ <font color=#808080>mail address<\/font> /g ;
      $agent =~ s/([\w-]+\s*.?at.?\s*[\w-]+\s*.?dot.?\s*[\w-]+)/ <font color=#808080>mail address<\/font> /gi ;
      $count = $crawlers_no_url {$agent} {$mime} ;
      $count = &FormatCount ($count) ;
      ($site2 = $site) =~ s/^http:\/\/// ;
      $html .= "<tr>" . &ShowCountTd ($count) . "<td>&nbsp;</td><td class=l colspan=99>$mime</td></tr>\n" ;
      $rows++ ;
    }
  }

  $total_crawlers_no_url = &FormatCount ($total_crawlers_no_url) ;
  $html .= "<tr><th class=l>$total_crawlers_no_url</th><th class=l colspan=99>total</th></tr>\n" ;
  $html .= "</table><p>\n" ;

  $html .= "<p>$google_ip_ranges" ;

  $html .= $colophon_ez ;

}
  print FILE_HTML_CRAWLERS $html ;
  close FILE_HTML_CRAWLERS ;
}

sub WriteReportMethods
{
  &LogSub ("WriteReportMethods\n") ;

  open FILE_HTML_METHODS, '>', "$path_reports/$file_html_methods" ;

  $html  = $headerwithperc ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Request Methods/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Request Methods/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  $html =~ s/LINKS/&ListLinksExcept ($link_methods)/e ; 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;

  &AddNoticeSurvey (7) ;

  $html .= "<table border=0>\n" ;
  $html .= "<tr><td>" ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In order of request volume</h3></th></tr>\n" ;
  $html .= "<tr><th colspan=2 class=l>Method</th><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $rows = 0 ;
  $total_methods = 0 ;
  foreach $method (@methods_sorted_count)
  {
    $total_methods += $methods {$method} ;
  }
  foreach $method (@methods_sorted_count)
  {
    $total = $methods {$method} ;
    $total = &FormatCount ($total) ;
    $html .= "<tr><td colspan=2 class=l>$method</td>" . &ShowCountTd ($total, '', $total_methods) . "</tr>\n" ;
  }
  $total_methods_format = &FormatCount ($total_methods) ;
  $html .= "<tr><th colspan=2 class=l>Total</th>" . &ShowCountTh ($total_methods_format) . "</tr>\n" ;
  $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><td class=l>Method</th><th class=l>Result</th><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $total_statusses = 0 ;
  foreach $status (@statusses_sorted_count)
  {
    $total_statusses += $statusses {$status} ;
  }
  foreach $status (@statusses_sorted_count)
  {
    $total = $statusses {$status} ;
    $total = &FormatCount ($total) ;
    ($method,$result) = split (',', $status, 2) ;

    $html .= "<tr><td class=l>$method</td><td class=l>$result</td>" . &ShowCountTd ($total,'',$total_statusses) . "</tr>\n" ;
    $rows++ ;
  }
  $total_statusses_format = &FormatCount ($total_statusses) ;
  $html .= "<tr><th colspan=2 class=l>Total</th>" . &ShowCountTh ($total_statusses_format) . "</tr>\n" ;
  $html .= "</table>\n" ;

  $html .= "</td><td>&nbsp;&nbsp;&nbsp;</td><td>" ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In alphabetical order: method+result</h3></th></tr>\n" ;
  $html .= "<tr><th colspan=2 class=l>Method</th><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $rows = 0 ;
  foreach $method (@methods_sorted_method)
  {
    $total = $methods {$method} ;
    $total = &FormatCount ($methods {$method}) ;
    $html .= "<tr><td colspan=2 class=l>$method</td>" . &ShowCountTd ($total,'',$total_methods) . "</tr>\n" ;
  }
  $html .= "<tr><th colspan=2 class=l>Total</th>" . &ShowCountTh ($total_methods_format) . "</tr>\n" ;
  $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><th class=l>Method</th><th class=l>Result</th><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  foreach $status (@statusses_sorted_method)
  {
    $total = &FormatCount ($statusses {$status}) ;
    ($method,$result) = split (',', $status, 2) ;

    $html .= "<tr><td class=l>$method</td><td class=l>$result</td>" . &ShowCountTd ($total,'',$total_statusses) . "</tr>\n" ;
    $rows++ ;
  }
  $html .= "<tr><th colspan=2 class=l>Total</th>" . &ShowCountTh ($total_statusses_format) . "</tr>\n" ;
  $html .= "</table>\n" ;

  $html .= "</td></tr></table>\n" ;
  $html .= "&nbsp;<small>$rows rows written</small><p>" ;

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon_ez ;

  print FILE_HTML_METHODS $html ;
  close FILE_HTML_METHODS ;
}

sub WriteReportMimeTypes
{
  &LogSub ("WriteReportMimeTypes\n") ;

  open FILE_HTML_REQUESTS, '>', "$path_reports/$file_html_requests" ;

  $html = $header ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Requests by destination/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Requests by destination/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  $html =~ s/NOTES/<br>&nbsp;This report shows where requests are sent to. Report 'Requests by origin' shows where requests come from.<br>&nbsp;Those numbers bear no direct relation.<br>/ ;
  $html =~ s/LINKS/&ListLinksExcept ($link_requests)/e ; 

  &AddNoticeSurvey (4) ;

  $html .= "<table border=1>\n" ;

  $header1 = "<tr><th colspan=2 class=l><small>x 1000</small></th><th colspan=2 class=c>Totals</th><th class=c><font color=#008000>Pages</font></th><th colspan=3 class=c><font color=#900000>Images</font></th><th colspan=99 class=c>Other</th></tr>\n" ;
  $header2 = "<tr><th colspan=2 class=l>&nbsp;</th><th class=c>total<br>all</th><th class=c><font color=#900000>total<br>images</font></th>\n" ;
  $columns = 0 ;
  foreach $mimetype (@mimetypes_sorted)
  {
    $columns++ ;

    next if $mimetypes_found {$mimetype} < $threshold_mime ;

    $mimetype2 = $mimetype ;
    if ($mimetype2 eq "text/html")
    { $mimetype2 .= "<br><small>(page)</small> " ; }
    if ($mimetype2 =~ /image\/(?:png|jpeg|gif)/)
    { $mimetype2 .= "<br><small>(img)</small> " ; }
    if ($columns == 1)
    { $mimetype2 = "<font color=#008000>$mimetype2</font>" ; }
    elsif (($columns >= 2) && ($columns <= 4))
    { $mimetype2 = "<font color=#900000>$mimetype2</font>" ; }
    ($mime1,$mime2) = split ('\/', $mimetype2, 2) ;
    $header2 .= "<th class=c>$mime1<br>$mime2</th>\n" ;
  }
  $header2 .= "</tr>\n" ;
  $html .= $header1 . $header2 ;

  $rows = 0 ;
  $total_mimes2  = 0 ;
  $total_images1 = 0 ;
  foreach $domain (@domains_sorted)
  {
    $html .= "<tr><td colspan=2 class=l>" . ucfirst($domain) . "</td>\n" ;
    $total = $domains {$domain} ;
    $total_mimes2 += $total ;
    $total = &FormatCount ($total) ;
    $total_images = $images_domain {$domain} ;
    $total_images1 += $total_images ;

    $html .= &ShowCountTh ($total) . &ShowCountTh ($total_images,"#900000") . "\n" ;
    $columns = 0 ;
    foreach $mimetype (@mimetypes_sorted)
    {
      $columns++ ;

      next if $mimetypes_found {$mimetype} < $threshold_mime ;

      $count = &FormatCount ($counts_dm {"$domain,$mimetype"}) ;
      if ($columns == 1)
      { $html .= &ShowCountTd ($count,"#008000") . "\n" ; }
      elsif (($columns >= 2) && ($columns <= 4))
      { $html .= &ShowCountTd ($count,"#900000") . "\n" ; }
      else
      { $html .= &ShowCountTd ($count) . "\n" ; }
    }
    $html .= "</tr>\n" ;
    $rows++ ;
  }

  if ($total_mimes != $total_mimes2)
  {
    print ERR "total_mimes $total_mimes != total_mimes2 $total_mimes2\n" ;
    print     "total_mimes $total_mimes != total_mimes2 $total_mimes2\n" ;
  }

  $total_mimes1  = &FormatCount ($total_mimes) ;
  $total_images1 = &FormatCount ($total_images1) ;
  $html .= "<tr><th colspan=2 class=l>Total</th>" . &ShowCountTh ($total_mimes1) . &ShowCountTh ($total_images1,"#900000") . "\n" ;
  $columns = 0 ;
  foreach $mimetype (@mimetypes_sorted)
  {
    $columns++ ;

    next if $mimetypes_found {$mimetype} < $threshold_mime ;

    $count = &FormatCount ($mimetypes {$mimetype}) ;
    if ($columns == 1)
    { $html .= &ShowCountTh ($count,"#008000") . "\n" ; }
    if (($columns >= 2) && ($columns <= 4))
    { $html .= &ShowCountTh ($count,"#900000") . "\n" ; }
    else
    { $html .= &ShowCountTh ($count) . "\n" ; }
  }
  $html .= "</tr>\n" ;

  $html .= "<tr><th colspan=99>&nbsp;</th></tr>\n" ;
  $html .= "<tr><td colspan=99 class=l><b>Per project / language subproject</b> (top 50)</td></tr>\n" ;
  $total_mimes3 = 0 ;
  $total_mimes4 = 0 ;
  $cnt_projects = 0 ;
  foreach $project (@projects_sorted)
  {
    last if ++ $cnt_projects > 50 ;

    $total = $projects {$project} ;
    $total_mimes3 += $total ;

    next if $total < $threshold_project ;

    $total_mimes4 += $total ;
    ($domain,$language) = split ('\:', $project,2) ;
    $html .= "<tr><td class=l>" . ucfirst($domain) . "</td><td class=l>$language</td>\n" ;

    $total = &FormatCount ($total) ;
    $total_images = &FormatCount ($images_project {$project}) ;
    $html .= &ShowCountTh ($total) . &ShowCountTh ($total_images,"#900000") . "\n" ;

    $columns = 0 ;
    foreach $mimetype (@mimetypes_sorted)
   {
      $columns++ ;

      next if $mimetypes_found {$mimetype} < $threshold_mime ;

      $count = &FormatCount ($counts_pm {"$project,$mimetype"}) ;
      if ($columns == 1)
      { $html .= &ShowCountTd ($count,"#008000") ; }
      elsif (($columns >= 2) && ($columns <= 4))
      { $html .= &ShowCountTd ($count,"#900000") ; }
      else
      { $html .= &ShowCountTd ($count) . "\n" ; }
    }
    $html .= "</tr>\n" ;
    $rows++ ;
  }
  $html .= $header2 . $header1 ;
  $html .= "</table>\n" ;
  $html .= "&nbsp;<small>$rows rows written</small><p>" ;

  if ($total_mimes != $total_mimes3)
  {
    print ERR "total_mimes $total_mimes != total_mimes3 $total_mimes3\n" ;
    &LogDetail ("total_mimes $total_mimes != total_mimes3 $total_mimes3\n") ;
  }

  if ($threshold_mime > 0)
  {
    $html .= "<b>Mime types that are found on less than $threshold_mime projects:</b> (again 1 = 1000)<p>" ;
    foreach $mimetype (@mimetypes_sorted)
    {
      next if $mimetypes_found {$mimetype} >= $threshold_mime ;

      $count = $mimetypes {$mimetype} ;
      $count =~ s/^(\d{1,3})(\d\d\d)$/$1,$2/ ;
      $count =~ s/^(\d{1,3})(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
      $html .= "<b>$mimetype</b> $count total<br>" ;
    }
  }

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon_ez ;

  print FILE_HTML_REQUESTS $html ;
  close FILE_HTML_REQUESTS ;
}

sub WriteReportOpSys
{
  &LogSub ("WriteReportOpSys\n") ;

  open FILE_HTML_OPSYS, '>', "$path_reports/$file_html_opsys" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Operating Systems/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Operating Systems/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  $html =~ s/LINKS/&ListLinksExcept ($link_opsys)/e ; 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;

  &AddNoticeSurvey (2) ;

  $total_all2 = &FormatCount ($total_opsys_mobile + $total_opsys_non_mobile) ;
  $total_opsys_mobile2 = &FormatCount ($total_opsys_mobile) ;
  $total_opsys_non_mobile2 = &FormatCount ($total_opsys_non_mobile) ;
  $total_perc_mobile = sprintf ("%.1f", 100 * $total_opsys_mobile / ($total_opsys_mobile + $total_opsys_non_mobile)) ;
  $total_perc_non_mobile = 100 - $total_perc_mobile ;
  $line_total_all        = "<tr><th class=l>Total</th>" . &ShowCountTh ($total_all2) . "<th class=r>100\%</th></tr>\n" ;
  $line_total_mobile     = "<tr><th class=l>Total</th>" . &ShowCountTh ($total_opsys_mobile2) . "<th class=r>$total_perc_mobile\%</th></tr>\n" ;
  $line_total_non_mobile = "<tr><th class=l>Total</th>" . &ShowCountTh ($total_opsys_non_mobile2) . "<th class=r>$total_perc_non_mobile\%</th></tr>\n" ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><td class=l colspan=99>The following overview of page requests by operating system is based on the <a href='http://en.wikipedia.org/wiki/User_agent'>user agent</a> information that accompanies most server requests.<br>" .
           "Please note that agent information does not follow strict guidelines and some programs may provide wrong information on purpose.<br>" .
           "This report ignores all requests where agent information is missing, or contains any of the following: bot, crawl(er) or spider.<p>" .
           "<a href='http://en.wikipedia.org/wiki/Windows_NT#Releases'>Wikipedia</a>: NT 5.0: Windows 2000, NT 5.1/5: XP/Srv 2003, NT 6.0: VISTA/Srv 2008, NT 6.1: Windows 7, NT 6.2: Windows 8/Srv 2012, NT6.3: Windows 8.1/Srv 2012 R2.<br> " .
           "<a href='http://en.wikipedia.org/wiki/Mac_OS_X#Versions'>Wikipedia</a>: OS X 10.4: Tiger, 10.5: Leopard, 10.6: Snow Leopard, 10.7: Lion, 10.8: Mountain Lion, 10.9: Mavericks.<br> " .
           "<a href='http://en.wikipedia.org/wiki/List_of_Linux_distributions'>Wikipedia</a>: Linux distributions." .
           "</td></tr>\n" ;

# $html .= "<tr><th class=l>Count<br><small>x 1000</small></th><th class=l>Secondary domain<br>(~site) name</th><th class=l>Mime type</th><th class=l>User agent</th></tr>\n" ;

  $html .= "<tr><td width=50% valign=top>" ;

  # OS SORTED BY FREQUENCY
  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><td colspan=99 class=l><h3>In order of popularity</h3></td></tr>" ;
  $html .= "<tr><th class=l>Operating System</th><th class=r>Requests</th><th class=r>Percentage</th></tr>\n" ;
  foreach $key (@opsys_sorted_count)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    ($rectype, $os) = split (',', $key,2) ;

    next if $rectype ne 'G' ; # group
    next if $key     =~ / / ; # subgroup

    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }
  $html .= $line_total_all ;

  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per platform for Mac and Linux</th></tr>\n" ;
  foreach $key (@opsys_sorted_count)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    ($rectype, $os) = split (',', $key,2) ;

    next if $rectype ne 'G' ; # group
    next if $key     !~ / / ; # subgroup

    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }

  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per OS version, non mobile</th></tr>\n" ;
  foreach $key (@opsys_sorted_count)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;

    next if $perc lt "0.02%" ;

    ($rectype, $os) = split (',', $key,2) ;

    next if $rectype ne '-' ; # group
  # next if isMobile($rectype,$os) ; # group


    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }
  $html .= $line_total_non_mobile ;

  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per OS version, mobile</th></tr>\n" ;
  foreach $key (@opsys_sorted_count)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;

    next if $perc lt "0.02%" ;

    ($rectype, $os) = split (',', $key,2) ;

    next if $rectype ne 'M' ; # group
  # next if !isMobile($rectype,$os) ; # group


    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }
  $html .= $line_total_mobile ;
  $html .= "</table>\n" ;

  $html .= "</td><td width=50% valign=top>" ;

  # IN ALPHABETICAL ORDER
  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><td colspan=99 class=l><h3>In alphabetical order</h3></td></tr>" ;
  $html .= "<tr><th class=l>Operating System</th><th class=r>Requests</th><th class=r>Percentage</th></tr>\n" ;
  foreach $key (@opsys_sorted_alpha)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    ($rectype, $os) = split (',', $key,2) ;

    next if $rectype ne 'G' ; # group
    next if $key     =~ / / ; # subgroup

    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }
  $html .= $line_total_all ;

  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per platform for Mac and Linux</th></tr>\n" ;
  foreach $key (@opsys_sorted_alpha)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;
    ($rectype, $os) = split (',', $key,2) ;

    next if $rectype ne 'G' ; # group
    next if $key     !~ / / ; # subgroup

    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }

  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per OS version, non mobile</th></tr>\n" ;
  foreach $key (@opsys_sorted_alpha)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;

    next if $perc lt "0.02%" ;

    ($rectype, $os) = split (',', $key,2) ;

    next if $rectype ne '-' ; # group
  # next if isMobile($rectype,$os); # group


    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }

  $html .= $line_total_non_mobile ;
  $html .= "<tr><th class=l colspan=99>&nbsp;<br>Breakdown per OS version, mobile</th></tr>\n" ;
  foreach $key (@opsys_sorted_alpha)
  {
    $count = $opsys {$key} ;
    $perc  = $opsys_perc {$key} ;

    next if $perc lt "0.02%" ;

    ($rectype, $os) = split (',', $key,2) ;

    next if $rectype ne 'M' ; # group
  # next if !isMobile($rectype,$os); # group

    $count = &FormatCount ($count) ;
    $html .= "<tr><td class=l>$os</a></td>" . &ShowCountTd ($count) . "<td class=r>$perc</td></tr>\n" ;
    # $rows++ ;
  }
  $html .= $line_total_mobile ;
  $html .= "</table>\n" ;
  $html .= "</td></tr>" ;

  $html .= "<tr><td colspan=99 class=l wrap>Requests from mobile devices are recognized as follows:<br>" .
           "Agent string contains any of the following terms (last upd: $month_upd_keywords_mobile):<br>" .
           "<i>$keywords_mobile</i></td></tr>" ;

  $html .= "</table><p>" ;

#  $perc_crawlers               = sprintf ("%.1f",100 * $total_page_crawlerrequests/$total_page_requests_external) ;
#  $total_page_requests_external2 = &FormatCount ($total_page_requests_external*1000) ;
#  $total_page_crawlerrequests2 = &FormatCount ($total_page_crawlerrequests*1000) ;
#  $html =~ s/PERC_GOOGLE/<p>In total $total_page_crawlerrequests2 page requests (mime type <a href='SquidReportRequests.htm'>text\/html<\/a> only!) per day are considered crawler requests, out of $total_page_requests_external2 external requests, which is $perc_crawlers%/ ;

#  $total_crawlers = &FormatCount ($total_crawlers) ;

# $html .= "<tr><th class=l>$total_crawlers</th><th class=l colspan=2>total</th></tr>\n" ;
# $html .= "</table><p>\n" ;

#  $html .= "<table border=1>\n" ;
#  $html .= "<tr><th class=l colspan=99>Top 25 secondary domains<br>(~ sites) mentioned</th></tr>\n" ;
#  foreach $secondary_domain (keys_sorted_by_value_num_desc %secondary_domains)
#  {
#    next if $secondary_domain eq ".." ;
#    last if ++$secondary_domains_listed > 25 ;
#
#    $count = $secondary_domains {$secondary_domain} ;
#    $count = &FormatCount ($count) ;
#    $html .= "<tr>" . &ShowCountTd ($count) . "<td class=l colspan=2>$secondary_domain</td></tr>\n" ;
#  }
#  $html .= "</table>\n" ;

  $html .= $colophon_ez ;

  print FILE_HTML_OPSYS $html ;
  close FILE_HTML_OPSYS ;
}

# http://en.wikipedia.org/wiki/Domain_name
sub WriteReportOrigins
{
  &LogSub ("WriteReportOrigins\n") ;

  open FILE_HTML_ORIGINS, '>', "$path_reports/$file_html_origins" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Requests by origin/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Requests by origin/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  $html =~ s/LINKS/&ListLinksExcept ($link_origins)/e ; 
  $html =~ s/NOTES/<br>&nbsp;This report shows where requests come from. Report 'Requests by destination' shows where requests are serviced.<br>&nbsp;Those numbers bear no direct relation.<br>/ ;

  &AddNoticeSurvey (5) ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><td colspan=99>" ;


  $html .= "<table border=0 width=100%>\n" ;
# $html .= "<tr><td colspan=99 class=c>traffic from yahoo is allocated as if yahoo used same domain naming scheme as google: <b>search.yahoo.ca</b> instead of <b>ca.search.yahoo.com</b></td></tr>\n" ;
# $html .= "<tr><td colspan=99 class=c><small>All counts x 1000</small></td></tr>\n" ;

  # INTERNAL ORIGINS

  $html .= "<tr><td colspan=99 class=c><h3>Requests with internal origins</h3></td></tr>\n" ;
  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><td width=50% valign=top>" ;
  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><td colspan=2 class=l><b>Internal origins<br>sorted by<br>frequency</b></td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;

  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $project (@project_int_top_sorted_count)
  {
    $total  = $project_int_top {$project} ;
    $page   = $project_int_top_split {"page:$project"} ;
    $image  = $project_int_top_split {"image:$project"} ;
    $rest   = $project_int_top_split {"other:$project"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td colspan=2 class=l>" . ucfirst($project) . "</td>" . &ShowCountTh ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th colspan=2 class=l>Total</th>" . &ShowCountTh ($total_total) . "" . &ShowCountTh ($total_page) . "" . &ShowCountTh ($total_image) . "" . &ShowCountTh ($total_rest) . "</tr>\n" ;

  $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><td colspan=99 class=l><b>Per project language / subproject</b> (top 50)</td></tr>\n" ;
  $projects    = 0 ;
  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;

  foreach $origin (@origin_int_top_sorted_count)
  {
    if (++$projects > 50)
    {
      $origin_int_top_other {"all"}   += $origin_int_top       {$origin} ; ;
      $origin_int_top_other {"page"}  += $origin_int_top_split {"page:$origin"}  ;
      $origin_int_top_other {"image"} += $origin_int_top_split {"image:$origin"}  ;
      $origin_int_top_other {"other"} += $origin_int_top_split {"other:$origin"}  ;
      next ;
    }
    $top100_internal_origins {$origin} ++ ;
    $total  = $origin_int_top {$origin} ;
    $page   = $origin_int_top_split {"page:$origin"} ;
    $image  = $origin_int_top_split {"image:$origin"} ;
    $rest   = $origin_int_top_split {"other:$origin"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    ($project,$subproject) = split (':', $origin) ;
    $html .= "<tr><td class=l>" . ucfirst($project) . "</td><td class=l>$subproject</td>" . &ShowCountTh ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;

  }
  $total  = $origin_int_top_other {"all"} ;
  $page   = $origin_int_top_other {"page"} ;
  $image  = $origin_int_top_other {"image"} ;
  $rest   = $origin_int_top_other {"other"} ;
  $total_total  += $total ;
  $total_page   += $page ;
  $total_image  += $image ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $page   = &FormatCount ($page) ;
  $image  = &FormatCount ($image) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td colspan=2 class=l>Other</td>" . &ShowCountTh ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  $grand_grand_total  = $total_total ;
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th colspan=2 class=l>Total</th>" . &ShowCountTh ($total_total) . &ShowCountTh ($total_page) . &ShowCountTh ($total_image) . &ShowCountTh ($total_rest) . "</tr>\n" ;
  $html .= "</table>" ;

  # BY ALPHABET
  $html .= "</td><td width=50% valign=top>" ;

  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><td colspan=2 class=l><b>Internal origins<br>sorted by<br>alphabet</b></td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;

  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $project (@project_int_top_sorted_alpha)
  {
    $total  = $project_int_top {$project} ;
    $page   = $project_int_top_split {"page:$project"} ;
    $image  = $project_int_top_split {"image:$project"} ;
    $rest   = $project_int_top_split {"other:$project"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td colspan=2 class=l>$project</td>" . &ShowCountTh ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th colspan=2 class=l>total</th>" . &ShowCountTh ($total_total) . &ShowCountTh ($total_page) . &ShowCountTh ($total_image) . &ShowCountTh ($total_rest) . "</tr>\n" ;

  $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><td colspan=99 class=l><b>Per project language / subproject</b> (top 50)</td></tr>\n" ;
  $projects    = 0 ;
  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $origin (@origin_int_top_sorted_alpha)
  {
    next if $top100_internal_origins {$origin} == 0 ;

    $total  = $origin_int_top {$origin} ;
    $page   = $origin_int_top_split {"page:$origin"} ;
    $image  = $origin_int_top_split {"image:$origin"} ;
    $rest   = $origin_int_top_split {"other:$origin"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    ($project,$subproject) = split (':', $origin) ;
    $html .= "<tr><td class=l>$project</td><td class=l>$subproject</td>" . &ShowCountTh ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;

  }
  $total  = $origin_int_top_other {"all"} ;
  $page   = $origin_int_top_other {"page"} ;
  $image  = $origin_int_top_other {"image"} ;
  $rest   = $origin_int_top_other {"other"} ;
  $total_total  += $total ;
  $total_page   += $page ;
  $total_image  += $image ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $page   = &FormatCount ($page) ;
  $image  = &FormatCount ($image) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td colspan=2 class=l>other</td>" . &ShowCountTh ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th colspan=2 class=l>total</th>" . &ShowCountTh ($total_total) . &ShowCountTh ($total_page) . &ShowCountTh ($total_image) . &ShowCountTh ($total_rest) . "</tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td></tr>" ;
  $html .= "</table>" ;

  # REQUESTS WITH EXTERNAL ORIGINS

  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><td colspan=99 class=c>&nbsp;</td></tr>\n" ;
  $html .= "<tr><td colspan=99 class=c><h3>Requests with external origins</h3></td></tr>\n" ;
  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><td width=50% valign=top>" ;
  $html .= "<table border=1 width=100%>\n" ;
# $html .= "<tr><td class=l><b><a href='http://..'>External origins</a><br>sorted by<br>frequency</b><br>top 100</td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  $html .= "<tr><td class=l><b>External origins<br>sorted by<br>frequency</b><br>top 100</td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;

  $projects     = 0 ;
  $total_total  = 0 ;
  $total_page   = 0 ;
  $total_image  = 0 ;
  $total_rest   = 0 ;
  foreach $origin (@origin_ext_top_sorted_count)
  {
    $total  = $origin_ext_top {$origin} ;
    $page   = $origin_ext_top_split {"page:$origin"} ;
    $image  = $origin_ext_top_split {"image:$origin"} ;
    $rest   = $origin_ext_top_split {"other:$origin"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;

    if (++$projects > 100)
    {
      $origin_ext_top_other {"all"}   += $origin_ext_top       {$origin} ; ;
      $origin_ext_top_other {"page"}  += $origin_ext_top_split {"page:$origin"}  ;
      $origin_ext_top_other {"image"} += $origin_ext_top_split {"image:$origin"}  ;
      $origin_ext_top_other {"other"} += $origin_ext_top_split {"other:$origin"}  ;
      next ;
    }
    $top100_internal_origins {$origin} ++ ;

    if ($origin =~ /\./)
    { $link_origin = "<a href='http://$origin' ref='nofollow'>$origin</a>" ; }
    else
    { $link_origin = $origin ; }
    $html .= "<tr><td class=l>$link_origin</td>" . &ShowCountTh ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $total  = $origin_ext_top_other {"all"} ;
  $page   = $origin_ext_top_other {"page"} ;
  $image  = $origin_ext_top_other {"image"} ;
  $rest   = $origin_ext_top_other {"other"} ;
  $total  = &FormatCount ($total) ;
  $page   = &FormatCount ($page) ;
  $image  = &FormatCount ($image) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>other</td>" . &ShowCountTh ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  $grand_grand_total  = $total_total ;
  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th>" . &ShowCountTh ($total_total) . &ShowCountTh ($total_page) . &ShowCountTh ($total_image) . &ShowCountTh ($total_rest) . "</tr>\n" ;
  $html .= "</table>" ;

  # BY ALPHABET
  $html .= "</td><td width=50% valign=top>" ;

  $html .= "<table border=1 width=100%>\n" ;
# $html .= "<tr><td class=l><b><a href='http://..'>External origins</a><br>sorted by<br>alphabet</b><br>top 100</td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  $html .= "<tr><td class=l><b>External origins<br>sorted by<br>alphabet</b><br>top 100</td><th class=r>&nbsp;Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;

  $projects     = 0 ;
  $total_total  = 0 ;
  $total_page   = 0 ;
  $total_image  = 0 ;
  $total_rest   = 0 ;
  foreach $origin (@origin_ext_top_sorted_alpha)
  {

    $total  = $origin_ext_top {$origin} ;
    $page   = $origin_ext_top_split {"page:$origin"} ;
    $image  = $origin_ext_top_split {"image:$origin"} ;
    $rest   = $origin_ext_top_split {"other:$origin"} ;
    $total_total  += $total ;
    $total_page   += $page ;
    $total_image  += $image ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;

    next if $top100_internal_origins {$origin} == 0 ;

    $html .= "<tr><td class=l>$origin</td>" . &ShowCountTh ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;

  }
  $total  = $origin_ext_top_other {"all"} ;
  $page   = $origin_ext_top_other {"page"} ;
  $image  = $origin_ext_top_other {"image"} ;
  $rest   = $origin_ext_top_other {"other"} ;
  $total  = &FormatCount ($total) ;
  $page   = &FormatCount ($page) ;
  $image  = &FormatCount ($image) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>other</td>" . &ShowCountTh ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;

  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th>" . &ShowCountTh ($total_total) . &ShowCountTh ($total_page) . &ShowCountTh ($total_image) . &ShowCountTh ($total_rest) . "</tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td></tr>" ;
# $html .= "<tr><td colspan=99 class=c>For presentation conciseness the top level domain (.org, .com, ..) is ignored here. There is a theoretical<br> possibility that figures for two unrelated sites which are both popular are presented as one here.<p>" .
#          "'Unmatched ip address': all requests without explicit referer url that were not allocated <br>to a site based on known ip range, e.g. google (by ip) or agent string, e.g. google (by agent)</td></tr>" ;
  $html .= "<tr><td colspan=99 class=c>'Origin unknown': all requests without explicit referer url, without known ip range and without identity clue in the agent string.<br>Note that right now only ip ranges for Google and Yahoo are recognized by the script (manual input Feb 2009)</td></tr>" ;
  $html .= "</table>" ;

  # EXTERNAL ORIGINS
  $html .= "<tr><td colspan=99 class=c>&nbsp;</td></tr>\n" ;
  $html .= "<tr><td colspan=99 class=c><h3>External origins</h3></td></tr>\n" ;
  $html .= "<tr><td width=50% valign=top>" ;


  $html .= "<table border=1 width=100%>\n" ;
  $html .= "<tr><td class=l><b><a href='http://en.wikipedia.org/wiki/Top-level_domain'>Top level domains</a> (tld)<br>sorted by<br>frequency</b></td><th class=r>&nbsp;Total</th><th class=r>Google</th><th class=r>Yahoo</th><th class=r>Other</th></tr>\n" ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b><a href='http://en.wikipedia.org/wiki/Generic_top-level_domain'>Generic</a> and <a href='http://en.wikipedia.org/wiki/Sponsored_top-level_domains'>Sponsored</a> tld's</a></b></td></tr>\n" ;
  foreach $toplevel (@origin_ext_page_top_sorted_count)
  {
    next if (length ($toplevel) <= 2) || ($toplevel =~ /^(?:address|local|rest|unspecified)$/) ;

    $total  = $origin_ext_page_top {$toplevel} ;
    $google = $origin_ext_page_top_split {"google:$toplevel"} ;
    $yahoo  = $origin_ext_page_top_split {"yahoo:$toplevel"} ;
    $rest   = $origin_ext_page_top_split {"other:$toplevel"} ;
    $total_total  += $total ;
    $total_google += $google ;
    $total_yahoo  += $yahoo ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $google = &FormatCount ($google) ;
    $yahoo  = &FormatCount ($yahoo) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$toplevel</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $grand_total  += $total_total ;
  $grand_google += $total_google ;
  $grand_yahoo  += $total_yahoo ;
  $grand_rest   += $total_rest ;
  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th>" . &ShowCountTh ($total_total) . &ShowCountTh ($total_google) . &ShowCountTh ($total_yahoo) . &ShowCountTh ($total_rest) . "</tr>\n" ;

  $total_total  = 0 ;
  $total_google = 0 ;
  $total_yahoo  = 0 ;
  $total_rest   = 0 ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b><a href='http://en.wikipedia.org/wiki/Country_code_top-level_domain'>Country code tld's</a></b></td></tr>\n" ;
  foreach $toplevel (@origin_ext_page_top_sorted_count)
  {
    next if length ($toplevel) != 2 ;

    $total  = $origin_ext_page_top {$toplevel} ;
    $google = $origin_ext_page_top_split {"google:$toplevel"} ;
    $yahoo  = $origin_ext_page_top_split {"yahoo:$toplevel"} ;
    $rest   = $origin_ext_page_top_split {"other:$toplevel"} ;
    $total_total  += $total ;
    $total_google += $google ;
    $total_yahoo  += $yahoo ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $google = &FormatCount ($google) ;
    $yahoo  = &FormatCount ($yahoo) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$toplevel</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $grand_total  += $total_total ;
  $grand_google += $total_google ;
  $grand_yahoo  += $total_yahoo ;
  $grand_rest   += $total_rest ;
  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th>" . &ShowCountTh ($total_total) . &ShowCountTh ($total_google) . &ShowCountTh ($total_yahoo) . &ShowCountTh ($total_rest) . "</tr>\n" ;

  $total_total  = 0 ;
  $total_google = 0 ;
  $total_yahoo  = 0 ;
  $total_rest   = 0 ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b>Remainder</th></tr>\n" ;
  $total  = $origin_ext_page_top {"local"} ;
  $google = $origin_ext_page_top_split {"google:local"} ; # always zero
  $yahoo  = $origin_ext_page_top_split {"yahoo:local"} ; # always zero
  $rest   = $origin_ext_page_top_split {"other:local"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>localhost</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;

  $total  = $origin_ext_page_top {"address"} ;
  $google = $origin_ext_page_top_split {"google:address"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:address"} ;
  $rest   = $origin_ext_page_top_split {"other:address"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>ip address</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;

  $total  = $origin_ext_page_top {"rest"} ;
  $google = $origin_ext_page_top_split {"google:rest"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:rest"} ;
  $rest   = $origin_ext_page_top_split {"other:rest"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>other</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;

  $total  = $origin_ext_page_top {"unspecified"} ;
  $google = $origin_ext_page_top_split {"google:unspecified"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:unspecified"} ;
  $rest   = $origin_ext_page_top_split {"other:unspecified"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>anonymous</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;

  $grand_total  += $total_total ;
  $grand_google += $total_google ;
  $grand_yahoo  += $total_yahoo ;
  $grand_rest   += $total_rest ;
  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_google</td><td class=r>$total_yahoo</td><td class=r>$total_rest</td></tr>\n" ;

  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b>Grand total external</th></tr>\n" ;
  $grand_total  = &FormatCount ($grand_total) ;
  $grand_google = &FormatCount ($grand_google) ;
  $grand_yahoo  = &FormatCount ($grand_yahoo) ;
  $grand_rest   = &FormatCount ($grand_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$grand_total</th><td class=r>$grand_google</td><td class=r>$grand_yahoo</td><td class=r>$grand_rest</td></tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td><td width=50% valign=top>" ;

  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><th class=l>Top level domains<br>sorted by<br>alphabet</th><th class=r>Total<th class=r>Google<th class=r>Yahoo<th class=r>Other</th></tr>\n" ;
# $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b><a href='http://en.wikipedia.org/wiki/Top-level_domain'>generic/sponsored tld's</a></b></th></tr>\n" ;
  $total_total  = 0 ;
  $total_google = 0 ;
  $total_yahoo  = 0 ;
  $total_rest   = 0 ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b>Generic and sponsored tld's</b></td></tr>\n" ;

  foreach $toplevel (@origin_ext_page_top_sorted_alpha)
  {
    next if (length ($toplevel) <= 2) || ($toplevel =~ /^(?:address|local|rest|unspecified)$/) ;

    $total  = $origin_ext_page_top {$toplevel} ;
    $google = $origin_ext_page_top_split {"google:$toplevel"} ;
    $yahoo  = $origin_ext_page_top_split {"yahoo:$toplevel"} ;
    $rest   = $origin_ext_page_top_split {"other:$toplevel"} ;
    $total_total  += $total ;
    $total_google += $google ;
    $total_yahoo  += $yahoo ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $google = &FormatCount ($google) ;
    $yahoo  = &FormatCount ($yahoo) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$toplevel</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_google</td><td class=r>$total_yahoo</td><td class=r>$total_rest</td></tr>\n" ;

  $total_total  = 0 ;
  $total_google = 0 ;
  $total_yahoo  = 0 ;
  $total_rest   = 0 ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b><a href='http://en.wikipedia.org/wiki/Country_code_top-level_domain'>Country code tld's</a></b></td></tr>\n" ;
  foreach $toplevel (@origin_ext_page_top_sorted_alpha)
  {
    next if length ($toplevel) != 2 ;

    $total  = $origin_ext_page_top {$toplevel} ;
    $google = $origin_ext_page_top_split {"google:$toplevel"} ;
    $yahoo  = $origin_ext_page_top_split {"yahoo:$toplevel"} ;
    $rest   = $origin_ext_page_top_split {"other:$toplevel"} ;
    $total_total  += $total ;
    $total_google += $google ;
    $total_yahoo  += $yahoo ;
    $total_rest   += $rest ;
    $total  = &FormatCount ($total) ;
    $google = &FormatCount ($google) ;
    $yahoo  = &FormatCount ($yahoo) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$toplevel</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th><th class=r>$total_total</th><td class=r>$total_google</td><td class=r>$total_yahoo</td><td class=r>$total_rest</td></tr>\n" ;

  $total_total  = 0 ;
  $total_google = 0 ;
  $total_yahoo  = 0 ;
  $total_rest   = 0 ;
  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b>Remainder</th></tr>\n" ;
  $total  = $origin_ext_page_top {"local"} ;
  $google = $origin_ext_page_top_split {"google:local"} ; # always zero
  $yahoo  = $origin_ext_page_top_split {"yahoo:local"} ; # always zero
  $rest   = $origin_ext_page_top_split {"other:local"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>localhost</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;

  $total  = $origin_ext_page_top {"address"} ;
  $google = $origin_ext_page_top_split {"google:address"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:address"} ;
  $rest   = $origin_ext_page_top_split {"other:address"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>ip address</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;

  $total  = $origin_ext_page_top {"rest"} ;
  $google = $origin_ext_page_top_split {"google:rest"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:rest"} ;
  $rest   = $origin_ext_page_top_split {"other:rest"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>other</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;

  $total  = $origin_ext_page_top {"unspecified"} ;
  $google = $origin_ext_page_top_split {"google:unspecified"} ;
  $yahoo  = $origin_ext_page_top_split {"yahoo:unspecified"} ;
  $rest   = $origin_ext_page_top_split {"other:unspecified"} ;
  $total_total  += $total ;
  $total_google += $google ;
  $total_yahoo  += $yahoo ;
  $total_rest   += $rest ;
  $total  = &FormatCount ($total) ;
  $google = &FormatCount ($google) ;
  $yahoo  = &FormatCount ($yahoo) ;
  $rest   = &FormatCount ($rest) ;
  $html .= "<tr><td class=l>anonymous</td>" . &ShowCountTh ($total) . &ShowCountTd ($google) . &ShowCountTd ($yahoo) . &ShowCountTd ($rest) . "</tr>\n" ;

  $total_total  = &FormatCount ($total_total) ;
  $total_google = &FormatCount ($total_google) ;
  $total_yahoo  = &FormatCount ($total_yahoo) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>total</th>" . &ShowCountTh ($total_total) . &ShowCountTh ($total_google) . &ShowCountTh ($total_yahoo) . &ShowCountTh ($total_rest) . "</tr>\n" ;

  $html .= "<tr><td colspan=99 class=l>&nbsp;<br><b>Grand total external</th></tr>\n" ;
  $html .= "<tr><th class=l>total</th>" . &ShowCountTh ($grand_total) . &ShowCountTh ($grand_google) . &ShowCountTh ($grand_yahoo) . &ShowCountTh ($grand_rest) . "</tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td></tr>" ;
  $html .= "</table>" ;
  $html .= "</td></tr>" ;

  $html .= "</table>\n" ;

  $html .= "</td></tr></table>\n" ;
# $html .= "&nbsp;<small>$rows rows written</small><p>" ;

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon_ez ;

  print FILE_HTML_ORIGINS $html ;
  close FILE_HTML_ORIGINS ;
}

sub WriteReportScripts
{
  &LogSub ("WriteReportScripts\n") ;

  open FILE_HTML_SCRIPTS, '>', "$path_reports/$file_html_scripts" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Scripts/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Scripts/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  $html =~ s/LINKS/&ListLinksExcept ($link_scripts)/e ; 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;

  &AddNoticeSurvey (9) ;

  $html .= "<table border=1>\n" ;
  $html .= "<tr><td colspan=99>" ;


  $html .= "<table border=0 width=100%>\n" ;
  $html .= "<tr><td width=50% valign=top>" ;
  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><td class=l><h3>In order of request volume</h3></td><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>css</b></th></tr>\n" ;
  foreach $script (@scripts_css_sorted_count)
  {
    $total = $scripts_css {$script} ;

    next if $total < 3 ;

    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td>" . &ShowCountTd ($total) . "</tr>\n" ;
  }
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>js</b></th></tr>\n" ;
  foreach $script (@scripts_js_sorted_count)
  {
    $total = $scripts_js {$script} ;

    next if $total < 3 ;

    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td>" . &ShowCountTd ($total) . "</tr>\n" ;
  }
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>php</b></th></tr>\n" ;
  $total_php = 0 ;
  foreach $script (@scripts_php_sorted_count)
  {
    $total = $scripts_php {$script} ;

    next if $total < 3 ;

    $total_php += $total ;
    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td>" . &ShowCountTd ($total) . "</tr>\n" ;
    foreach $key (keys_sorted_by_value_num_desc %actions)
    {
      ($script2,$action) = split (',', $key) ;
      if (($script eq $script2) && ($actions {$key} < $scripts_php {$script}))
      { $html .= "<tr><td class=l>&nbsp;&nbsp;&nbsp;- $action</td>" . &ShowCountTd (&FormatCount ($actions {$key})) . "</tr>\n" ; }
    }
  }
  $total_php = &FormatCount ($total_php) ;
  $html .= "<tr><th class=l>total php</th>" . &ShowCountTh ($total_php) . "</tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td><td width=50% valign=top>" ;

  $html .= "<table border=1 width=100%>\n" ;

  $html .= "<tr><td class=l><h3>In alphabetical order</h3></td><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>css</b></th></tr>\n" ;
  foreach $script (@scripts_css_sorted_script)
  {
    $total = $scripts_css {$script} ;

    next if $total < 3 ;

    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td>" . &ShowCountTd ($total) . "</tr>\n" ;
  }
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>js</b></th></tr>\n" ;
  foreach $script (@scripts_js_sorted_script)
  {
    $total = $scripts_js {$script} ;

    next if $total < 3 ;

    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td>" . &ShowCountTd ($total) . "</tr>\n" ;
  }
  $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>php</b></th></tr>\n" ;
  foreach $script (@scripts_php_sorted_script)
  {
    $total = $scripts_php {$script} ;

    next if $total < 3 ;

    $total_php += $total ;
    $total = &FormatCount ($total) ;
    $html .= "<tr><td class=l>$script</td>" . &ShowCountTd ($total) . "</tr>\n" ;
    foreach $key (sort keys %actions)
    {
      ($script2,$action) = split (',', $key) ;
      if (($script eq $script2) && ($actions {$key} < $scripts_php {$script}))
      { $html .= "<tr><td class=l>&nbsp;&nbsp;&nbsp;- $action</td>" . &ShowCountTd (&FormatCount ($actions {$key})) . "</tr>\n" ; }
    }
  }
  $html .= "<tr><th class=l>total php</th>" . &ShowCountTh ($total_php) . "</tr>\n" ;
  $html .= "</table>" ;

  $html .= "</td></tr>" ;
  $html .= "</table>" ;
  $html .= "</td></tr>" ;

  $html .= "<tr><td colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>PHP scripts and generalized arguments, sorted by frequency, top 25</h3></th></tr>\n" ;
  $html .= "<tr><th class=l>Script</th><th class=l>Parameters</th><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $rows = 0 ;
  foreach $parm (@parms_sorted_count)
  {
    $total = &FormatCount ($parms {$parm}) ;
    ($name,$parms) = split (',', $parm) ;
    if ($parms eq "")
    { $parms = "-" ; }
    $html .= "<tr><td class=l>$name</td><td class=l>$parms</td>" . &ShowCountTd ($total) . "</tr>\n" ;
    $rows++ ;

    last if $rows == 25 ;
  }
# $html .= "</table>\n" ;
#  $html .= "</td><td>&nbsp;&nbsp;&nbsp;</td><td>" ;
# $html .= "<table border=1>\n" ;
  $html .= "<tr><th colspan=99 class=l>&nbsp;</th></tr>\n" ;

  $html .= "<tr><th colspan=99 class=l><h3>PHP scripts and generalized arguments, in alphabetical order <small>(&ge; 3)</small></h3></small></th></tr>\n" ;

  $html .= "<tr><td colspan=2 class=l><b>Script</b><br>Parameters</td><th class=r>Count<br><small>x 1000</small></th></tr>\n" ;
  $rows = 0 ;
  $nameprev = "" ;
  foreach $parm (@parms_sorted_script)
  {
    ($name,$parms) = split (',', $parm, 2) ;

    $total = &FormatCount ($parms {$parm}) ;
    if ($name ne $nameprev)
    {
      $total = &FormatCount ($scripts_php {$name}) ;

      next if $total < 3 ;

      if ($nameprev ne "")
      { $html .= "<tr><th colspan=99 class=l>&nbsp;</th></tr>\n" ; }
      if (($name eq "api.php") || ($name eq "index.php"))
      { $html .= "<tr><td colspan=2 class=l><b>$name</b> <small>(&ge; 3)</small></td>" . &ShowCountTh ($total) . "</tr>\n" ; }
      else
      { $html .= "<tr><td colspan=2 class=l><b>$name</b></td>" . &ShowCountTh ($total) . "</tr>\n" ; }
    }
    $total = $parms {$parm} ;

    next if (($name eq "api.php") || ($name eq "index.php")) && ($total <= 2) ;

    $total = &FormatCount ($total) ;
    if ($parms eq "")
    { $parms = "-" ; }
    $html .= "<tr><td colspan=2 class=l>$parms</td>" . &ShowCountTd ($total) . "</tr>\n" ;
    $rows++ ;
    $nameprev = $name ;
  }
  $html .= "</table>\n" ;

  $html .= "</td></tr></table>\n" ;
  $html .= "&nbsp;<small>$rows rows written</small><p>" ;

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon_ez ;

  print FILE_HTML_SCRIPTS $html ;
  close FILE_HTML_SCRIPTS ;
}

sub WriteReportGoogle
{
  &LogSub ("WriteReportGoogle\n") ;

  open FILE_HTML_SEARCH, '>', "$path_reports/$file_html_google" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Google requests/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Google requests/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  $html =~ s/LINKS/&ListLinksExcept ($link_google)/e ; 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;

  &AddNoticeSurvey (3) ;

  $html .= "<table border=1 width=500 wrap>\n" ;
#  $html .= "<tr><td colspan=99 class=l>&nbsp;<br>This report shows <b>all requests to Wikimedia servers where a Google server of service was involved in any way</b>,<br> " .
#           "be it the <a href='http://en.wikipedia.org/wiki/Googlebot'>GoogleBot</a> crawler or <a href='http://www.google.com/feedfetcher.html'>FeedFetcher</a> collector scripts that run on Google servers,<br> " .
#           "or a user that follows a link from a Google Web or Google Desktop search results page, or " .
#           "from Google Maps or Google Earth etcetera. <p>Technically speaking three fields in the <a href='http://wikitech.wikimedia.org/view/Squid_log_format'>squid log records</a> are checked for this: " .
#           "client ip address, referer header and user agent header.<br>A request can originate from an ip address which has been registered by Google and/or it can carry a referer tag that tells us<br>a user clicked a link " .
#           "on a Google results page and/or it can carry an agent string that mentions a Google application which<br>can reasonably be assumed to be genuinely Google's. See bottom of page for <a href='#details'>further details</a>." .
#           "PERC_GOOGLE\n" ;
  $html .= "<tr><td colspan=99 class=l wrap>&nbsp;<br>This report shows <b>all requests to Wikimedia servers where a Google server of service was involved in any way</b>, " .
           "be it the <a href='http://en.wikipedia.org/wiki/Googlebot'>GoogleBot</a> crawler or <a href='http://www.google.com/feedfetcher.html'>FeedFetcher</a> collector scripts that run on Google servers, " .
           "or a user that follows a link from a Google Web or Google Desktop search results page, or " .
           "from Google Maps or Google Earth etcetera. <p>Technically speaking three fields in the <a href='http://wikitech.wikimedia.org/view/Squid_log_format'>squid log records</a> are checked for this: " .
           "client ip address, referer header and user agent header. A request can originate from an ip address which has been registered by Google and/or it can carry a referer tag that tells us a user clicked a link " .
           "on a Google results page and/or it can carry an agent string that mentions a Google application which can reasonably be assumed to be genuinely Google's. See bottom of page for <a href='#details'>further details</a>." .
           "PERC_GOOGLE\n" ;

  $html .= "<tr><td width=50%>\n" ;

  # SORTED BY FREQUENCY
  $html .= "<table border=1>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In order of request volume</h3></th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>Requests originating from a Google ip address</th></tr>\n" ;
# $html .= "<tr><th colspan=99 class=l><small>x 1000</small></th>\n" ;
  my $total_total_direct ;
  my $total_page_direct ;
  my $total_image_direct ;
  my $total_rest_direct ;
  $html .= "<tr><th class=l>Service</a><th class=r>Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  foreach $key (@searches_service_count)
  {
    next if $key !~ /Y$/ ; # googleIp

    ($key2 = $key) =~ s/,[YN]$// ;
    $total = $searches_service_mimecat {"$key2,total,Y"} ;
    $page  = $searches_service_mimecat {"$key2,page,Y"} ;
    $image = $searches_service_mimecat {"$key2,image,Y"} ;
    $rest  = $searches_service_mimecat {"$key2,other,Y"} ;
    $total_total_direct += $total ;
    $total_page_direct  += $page ;
    $total_image_direct += $image ;
    $total_rest_direct  += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$key2</a></td>" . &ShowCountTd ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $total_page_all = $total_page_direct ;

# $total_page_requests_external_fmt = &FormatCount ($total_page_requests_external*1000) ;

  $perc_google_direct = ".." ;
  if ($total_page_requests_external > 0)
  { $perc_google_direct = sprintf ("%.1f",100 * $total_page_direct/$total_page_requests_external) ; }
  $total_page_direct_fmt = &FormatCount ($total_page_direct*1000) ;
  $perc_google_msg_direct = "<p>Including all of its different search crawlers and services hosted on its servers, Google itself requested another $total_page_direct_fmt page pages per day, representing $perc_google_direct% of our external page requests.\n" ;

  $total_total_direct = &FormatCount ($total_total_direct) ;
  $total_page_direct  = &FormatCount ($total_page_direct) ;
  $total_image_direct = &FormatCount ($total_image_direct) ;
  $total_rest_direct  = &FormatCount ($total_rest_direct) ;

  $html .= "<tr><th class=l>Total</a></th>" . &ShowCountTh ($total_total_direct) . &ShowCountTh ($total_page_direct) . &ShowCountTh ($total_image_direct) . &ShowCountTh ($total_rest_direct) . "</tr>\n" ;

  my $total_total_indirect ;
  my $total_page_indirect ;
  my $total_image_indirect ;
  my $total_rest_indirect ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;</th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>Requests originating from elsewhere</th></tr>\n" ;
  $html .= "<tr><th class=l>Service</a><th class=r>Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  foreach $key (@searches_service_count)
  {
    next if $key =~ /Y$/ ; # googleIp

    ($key2 = $key) =~ s/,[YN]$// ;
    $total = $searches_service_mimecat {"$key2,total,N"} ;
    $page  = $searches_service_mimecat {"$key2,page,N"} ;
    $image = $searches_service_mimecat {"$key2,image,N"} ;
    $rest  = $searches_service_mimecat {"$key2,other,N"} ;
    $total_total_indirect += $total ;
    $total_page_indirect  += $page ;
    $total_image_indirect += $image ;
    $total_rest_indirect  += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    $html .= "<tr><td class=l>$key2</a></td>" . &ShowCountTd ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $total_page_all += $total_page_indirect ;

  $perc_google_indirect  = ".." ;
  if ($total_page_requests_external > 0)
  { $perc_google_indirect = sprintf ("%.1f",100 * $total_page_indirect/$total_page_requests_external) ; }
  $total_page_indirect_fmt = &FormatCount ($total_page_indirect*1000) ;
  $perc_google_msg_indirect = "<p>Google referred to our sites, through its services including search, maps, and Google Earth, $total_page_indirect_fmt page views per day, representing $perc_google_indirect% of our external page requests.\n" ;

  $total_total_indirect = &FormatCount ($total_total_indirect) ;
  $total_page_indirect  = &FormatCount ($total_page_indirect) ;
  $total_image_indirect = &FormatCount ($total_image_indirect) ;
  $total_rest_indirect  = &FormatCount ($total_rest_indirect) ;

  $html .= "<tr><th class=l>Total</a></th>" . &ShowCountTd ($total_total_indirect) . &ShowCountTd ($total_page_indirect) . &ShowCountTd ($total_image_indirect) . &ShowCountTd ($total_rest_indirect) . "</tr>\n" ;
  $html .= "<tr><th class=l colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l><a href='http://en.wikipedia.org/wiki/List_of_Internet_top-level_domains'>Top level domains</a></th></tr>\n" ;

# $total_page_all_fmt = &FormatCount ($total_page_all*1000) ;

  $perc_google = ".." ;
  if ($total_page_requests_external > 0)
  { $perc_google  = sprintf ("%.1f",100 * $total_page_all/$total_page_requests_external) ; }

  $perc_google_msg_all = "<p>In total Google was somehow involved in $perc_google\% of daily external page<sup>*<\/sup> requests \n" ;
  $html =~ s/PERC_GOOGLE/<hr width=90%>$perc_google_msg_all $perc_google_msg_indirect $perc_google_msg_direct<p><small>* = mime type <a href='SquidReportRequests.htm'>text\/html<\/a> only<\/small>/ ;

  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $key (@searches_toplevel_count)
  {
    $total = $searches_toplevel_mimecat {"$key,total"} ;
    $page  = $searches_toplevel_mimecat {"$key,page"} ;
    $image = $searches_toplevel_mimecat {"$key,image"} ;
    $rest  = $searches_toplevel_mimecat {"$key,other"} ;
    $total_total += $total ;
    $total_page  += $page ;
    $total_image += $image ;
    $total_rest  += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    if ($key !~ /^[\_\.]/)
    { $key = ".$key" ; }
#   else
#   { $key =~ s/^[\.]// ; }
    if ($key =~ /^\_/)
    { $key = "<i>" . substr ($key,1) . "</i>" ; }
    $html .= "<tr><td class=l>$key</a></td>" . &ShowCountTd ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $total_no_tld = $searches_mimecat_tld_not_found {"total"}  ;
  $page_no_tld  = $searches_mimecat_tld_not_found {"page"}  ;
  $image_no_tld = $searches_mimecat_tld_not_found {"image"}  ;
  $other_no_tld = $searches_mimecat_tld_not_found {"other"}  ;

  $total_total += $total_no_tld ;
  $total_page  += $page_no_tld ;
  $total_image += $image_no_tld ;
  $total_rest  += $other_no_tld ;

  $total_no_tld = &FormatCount ($total_no_tld)  ;
  $page_no_tld  = &FormatCount ($page_no_tld)  ;
  $image_no_tld = &FormatCount ($image_no_tld)  ;
  $other_no_tld = &FormatCount ($other_no_tld)  ;
  $html .= "<tr><td class=l>undefined</a></td>" . &ShowCountTd ($total_no_tld) . &ShowCountTd ($page_no_tld) . &ShowCountTd ($image_no_tld) . &ShowCountTd ($other_no_tld) . "</tr>\n" ;

  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>Total</a></th>" . &ShowCountTh ($total_total) . &ShowCountTh ($total_page) . &ShowCountTh ($total_image) . &ShowCountTh ($total_rest) . "</tr>\n" ;

  $html .= "</table>\n" ;

  $html .= "</td><td width=50%>\n" ;

  # SORTED BY ALPHABETICALLY
  $html .= "<table border=1>\n" ;
  $html .= "<tr><th colspan=99 class=l><h3>In alphabetical order</h3></th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>Requests originating from a Google ip address</th></tr>\n" ;
# $html .= "<tr><th colspan=99 class=l><small>x 1000</small></th>\n" ;
  $html .= "<tr><th class=l>Service</a><th class=r>Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  foreach $key (@searches_service_alpha)
  {
    next if $key !~ /Y$/ ; # googleIp

    ($key2 = $key) =~ s/,[YN]$// ;
    $total = $searches_service_mimecat {"$key2,total,Y"} ;
    $page  = $searches_service_mimecat {"$key2,page,Y"} ;
    $image = $searches_service_mimecat {"$key2,image,Y"} ;
    $rest  = $searches_service_mimecat {"$key2,other,Y"} ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    if ($key !~ /(?:undefined|unspecified|crawler|feedfetcher|wireless transcoder)/)
    { $key = ucfirst ($key) ; }
    else
    { $key = "<i>$key</i>" ; }
    $html .= "<tr><td class=l>$key2</a></td>" . &ShowCountTd ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $html .= "<tr><th class=l>Total</a></th>" . &ShowCountTh ($total_total_direct) . &ShowCountTh ($total_page_direct). &ShowCountTh ($total_image_direct). &ShowCountTh ($total_rest_direct). "</tr>\n" ;

  $html .= "<tr><th colspan=99 class=l>&nbsp;</th></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>Requests originating from elsewhere</th></tr>\n" ;
  $html .= "<tr><th class=l>Service</a><th class=r>Total</th><th class=r>Pages</th><th class=r>Images</th><th class=r>Other</th></tr>\n" ;
  foreach $key (@searches_service_alpha)
  {
    next if $key =~ /Y$/ ; # googleIp

    ($key2 = $key) =~ s/,[YN]$// ;
    $total = $searches_service_mimecat {"$key2,total,N"} ;
    $page  = $searches_service_mimecat {"$key2,page,N"} ;
    $image = $searches_service_mimecat {"$key2,image,N"} ;
    $rest  = $searches_service_mimecat {"$key2,other,N"} ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    if ($key !~ /(?:undefined|unspecified|crawler|feedfetcher|wireless transcoder)/)
    { $key = ucfirst ($key) ; }
    else
    { $key = "<i>$key</i>" ; }
    $html .= "<tr><td class=l>$key2</a></td>" . &ShowCountTd ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $html .= "<tr><th class=l>Total</a></th>" . &ShowCountTh ($total_total_indirect) . &ShowCountTh ($total_page_indirect) . &ShowCountTh ($total_image_indirect) . &ShowCountTh ($total_rest_indirect) . "</tr>\n" ;
  $html .= "<tr><th class=l colspan=99>&nbsp;</td></tr>\n" ;
  $html .= "<tr><th colspan=99 class=l>Top level domains</th></tr>\n" ;

  $total_total = 0 ;
  $total_page  = 0 ;
  $total_image = 0 ;
  $total_rest  = 0 ;
  foreach $key (@searches_toplevel_alpha)
  {
    $total = $searches_toplevel_mimecat {"$key,total"} ;
    $page  = $searches_toplevel_mimecat {"$key,page"} ;
    $image = $searches_toplevel_mimecat {"$key,image"} ;
    $rest  = $searches_toplevel_mimecat {"$key,other"} ;
    $total_total += $total ;
    $total_page  += $page ;
    $total_image += $image ;
    $total_rest  += $rest ;
    $total  = &FormatCount ($total) ;
    $page   = &FormatCount ($page) ;
    $image  = &FormatCount ($image) ;
    $rest   = &FormatCount ($rest) ;
    if ($key !~ /^[\_\.]/)
    { $key = ".$key" ; }
    if ($key =~ /^\_/)
    { $key = "<i>" . substr ($key,1) . "</i>" ; }
    $html .= "<tr><td class=l>$key</a></td>" . &ShowCountTd ($total) . &ShowCountTd ($page) . &ShowCountTd ($image) . &ShowCountTd ($rest) . "</tr>\n" ;
  }
  $total_no_tld = $searches_mimecat_tld_not_found {"total"}  ;
  $page_no_tld  = $searches_mimecat_tld_not_found {"page"}  ;
  $image_no_tld = $searches_mimecat_tld_not_found {"image"}  ;
  $other_no_tld = $searches_mimecat_tld_not_found {"other"}  ;

  $total_total += $total_no_tld ;
  $total_page  += $page_no_tld ;
  $total_image += $image_no_tld ;
  $total_rest  += $other_no_tld ;

  $total_no_tld = &FormatCount ($total_no_tld)  ;
  $page_no_tld  = &FormatCount ($page_no_tld)  ;
  $image_no_tld = &FormatCount ($image_no_tld)  ;
  $other_no_tld = &FormatCount ($other_no_tld)  ;
  $html .= "<tr><td class=l>undefined</a></td>" . &ShowCountTd ($total_no_tld) . &ShowCountTd ($page_no_tld) . &ShowCountTd ($image_no_tld) . &ShowCountTd ($other_no_tld) . "</tr>\n" ;

  $total_total  = &FormatCount ($total_total) ;
  $total_page   = &FormatCount ($total_page) ;
  $total_image  = &FormatCount ($total_image) ;
  $total_rest   = &FormatCount ($total_rest) ;
  $html .= "<tr><th class=l>Total</a></th>" . &ShowCountTh ($total_total) . &ShowCountTh ($total_page) . &ShowCountTh ($total_image) . &ShowCountTh ($total_rest) . "</tr>\n" ;

  $html .= "</table>\n" ;
  $html .= "</td></tr>\n" ;


  $breakdown = "Here is detailed breakdown per service of indicators that pointed to Google <small>(total &ge; 3)</small><br>&nbsp;<br>" .
               "<table width=100%><tr><th class=l>Service</th><th class=c>Total</th><th class=c>Originating from<br>Google ip address</th><th class=c>Referer mentions<br>Google url</th><th class=c>Agent mentions<br>Google service</th></tr>\n" ;
  foreach $key (@searches_service_matches_alpha)
  {
    $count = $searches_service_matches {$key} ;

    next if $count <= 2 ;

    $count = &FormatCount ($count) ;
    ($service,$matches) = split (',', $key) ;
    if ($matches =~ /x/) { $x = 'Y' } else { $x = '-' } ;
    if ($matches =~ /y/) { $y = 'Y' } else { $y = '-' } ;
    if ($matches =~ /z/) { $z = 'Y' } else { $z = '-' } ;
    $breakdown .= "<tr><td class=l>$service</td>" . &ShowCountTd ($count) . "<td class=c>$x</td><td class=c>$y</td><td class=c>$z</td></tr>" ;
  }
  $breakdown .= "</table><br.&bsp;<br>\n" ;


  $html .= "<tr><td class=l colspan=99><a name='details' id='details'></a>&nbsp;<p>" .
  $google_ip_ranges .
  "<b>Agents</b>: as for genuine agent strings: too many crawlers indentify themselves as 'GoogleBot' to take this at face value. " .
  "They are accepted as genuine Google crawler requests only when the ip address matches a known range (see above). " .
  "Other records that mention GoogleBot are counted as GoogleBot? (question mark, as this may include partners, like DoCoMo). " .
  "However when the agent string mentions Google Desktop or Google Earth this is always accepted" .
  "<p><b>Service</b>: the service name is based on the agent string (plus for GoogleBot check for ip address, see above), if this is inconclusive it is based on the referer string." .
  "<p>$breakdown" .
  "<p><b>Top Level Domain 'undefined'</b>: requests with top level domain 'undefined' are nearly all requests from anonymous ip addresses (crawler and other services)" .
  "<p><b>Note</b>: averages below 1 are always rounded up to 1\n" .
  "</small></td></tr>\n";

  $html .= "</table>\n" ;

  $html .= $colophon_ez ;

  print FILE_HTML_SEARCH $html ;
  close FILE_HTML_SEARCH ;
}

sub WriteReportSkins
{
  &LogSub ("WriteReportSkins\n") ;

  open FILE_HTML_SKINS, '>', "$path_reports/$file_html_skins" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Skins/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Skins/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  $html =~ s/LINKS/&ListLinksExcept ($link_skins)/e ; 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;

  &AddNoticeSurvey (10) ;

  $html .= "<table border=1>\n" ;

  $html .= "<tr><td colspan=99 class=l><b>Skin</b><br>Files (&ge; 3)</td></tr>\n" ;
  $rows = 0 ;
  $nameprev = "" ;
  foreach $skin (@skins_sorted_skin)
  {
    $count = &FormatCount ($skins {$skin}) ;

    next if $count < 3 ;

    $skin =~ s/^skins\/// ;
    ($name,$rest) = split ('\/', $skin, 2) ;

    next if $skin_set {$name} < 3 ;

    if ($name ne $nameprev)
    { $html .= "<tr><th colspan=99 class=l>&nbsp;<br><b>" . ucfirst ($name) . "</b></th></tr>\n" ; }
    $nameprev = $name ;
    $html .= "<tr><td class=l>$skin</td>" . &ShowCountTd ($count) . "</tr>\n" ;
    $rows++ ;
  }
  $html .= "</table>\n" ;

  $html .= "&nbsp;<small>$rows rows written</small><p>" ;

#  $html .= "<p><b>Explanation:</b><br>'osd' = opensearchdescription / 'php.ser' = vnd.php.serialized" ;
  $html .= $colophon_ez ;

  print FILE_HTML_SKINS $html ;
  close FILE_HTML_SKINS ;
}

sub UserAgentField
{
   my ($value, $ismarked) = @_;
   if ($ismarked)
   { $shownumber = &ShowCount ($value * $multiplier, $ismarked) ; }
   else
   { $shownumber = &ShowCount ($value * $multiplier) ; }
   return "<td class=rt>$shownumber</td>" ;
}

sub UserAgentFieldPerc
{
   my ($value, $compare, $showperc, $ismarked) = @_;
   if (!$showperc)
   { return "<td>&nbsp;</td>" ; }
   if ($value < 1)
   { $shownumber = '-' }
   elsif ($ismarked)
   { $shownumber = &ShowPerc (100 * $value * $multiplier / $compare, $ismarked) ; }
   else
   { $shownumber = &ShowPerc (100 * $value * $multiplier / $compare) ; }
   return "<td class=rt>$shownumber</td>" ;
}

sub UserAgentFieldNew
{
   my ($value, $ismarked, $percbase) = @_;
   if ($ismarked)
   { $shownumber = &ShowCount ($value * $multiplier, $ismarked, $percbase) ; }
   else
   { $shownumber = &ShowCount ($value * $multiplier, '', $percbase) ; }
   return "<td class=rt>$shownumber</td>" ;
}

sub UserAgentLine
{
  my ($title, $code, $showperc, $ismarked, $depth, $sharecol) = @_ ;
  my $result = "<tr>";
  if ($sharecol > 0)
  { $ result .= "<td rowspan=$sharecol>&nbsp;&nbsp;</td>" ; }
  my $colspan = 4 - $depth;
  if ($ismarked)
  { $ismarked = $marker_color ; }
  if ($ismarked)
  { $result .= "<td class=lt colspan=$colspan><b>$title</b></td>" ; }
  else
  { $result .= "<td class=lt colspan=$colspan>$title</td>" ; }
  $result .= UserAgentFieldNew($countua {$code, 'M', 'page', '.'} + $countua {$code, 'W', 'page', '.'}, $ismarked, $total_html) ;
  $result .= UserAgentFieldNew($countua {$code, 'M', 'page', '.'}, $ismarked, $total_html) ;
  $result .= UserAgentFieldNew($countua {$code, 'W', 'page', '.'}, $ismarked, $total_html) ;
  $result .= UserAgentFieldPerc($countua {$code, '.', '.', 'opensearch'}, $total_opensearch, $showperc, '#808080') ;
  $result .= UserAgentFieldNew($countua {$code, '.', '.', '.'}, $ismarked, $total_count) ;
  $result .= UserAgentFieldNew($countua {$code, 'M', '.', '.'}, $ismarked, $total_count) ;
  $result .= UserAgentFieldNew($countua {$code, 'W', '.', '.'}, $ismarked, $total_count) ;
  $result .= UserAgentFieldNew($countua {$code, 'X', '.', '.'}, $ismarked, $total_count) ;
  return $result ;
}

sub UserAgentMobileLine
{
  my ($title, $code, $ismarked, $depth, $sharecol) = @_ ;
  my $result = "<tr>";
  if ($sharecol > 0)
  { $ result .= "<td rowspan=$sharecol>&nbsp;&nbsp;</td>" ; }
  my $colspan = 2 - $depth;
  if ($ismarked)
  { $ismarked = $marker_color ; }
  if ($ismarked)
  { $result .= "<td class=lt colspan=$colspan><b>$title</b></td>" ; }
  else
  { $result .= "<td class=lt colspan=$colspan>$title</td>" ; }
  $result .= UserAgentFieldPerc($countua {$code, 'M', 'page', '.'} + $countua {$code, 'W', 'page', '.'}, $total_mobile_html, $true, $ismarked) ;
  $result .= UserAgentFieldPerc($countua {$code, '.', '.', '.'}, $total_mobile, $true, $ismarked) ;
  $result .= UserAgentFieldPerc($countua {$code, '.', '.', 'opensearch'}, $mobile_opensearch, $true, '#808080') ;
  return $result ;
}

sub UserAgentCsvLine
{
  my ($title, $code, $showperc) = @_ ;
  my $result = $title,
  $value = 1000 * ($countua {$code, 'M', 'page', '.'} + $countua {$code, 'W', 'page', '.'}) * $multiplier ;
  $writevalue = sprintf("%.0f", $value) ;
  $result .= ",$writevalue" ;
  if ($showperc)
  {
    $perc = 0.1 * $value / $total_html ;
    $perc = sprintf("%.2f", $perc) ;
    $result .= ",$perc" ;
    $perc = 100 * $countua {$code, 'M', 'page', '.'} * $multiplier / $total_html ;
    $perc = sprintf("%.2f", $perc) ;
    $result .= ",$perc" ;
    $perc = 100 * $countua {$code, 'W', 'page', '.'} * $multiplier / $total_html ;
    $perc = sprintf("%.2f", $perc) ;
    $result .= ",$perc" ;
    if ($total_opensearch > 0)
    {
      $perc = 100 * $countua {$code, '.', '.', 'opensearch'} * $multiplier / $total_opensearch ;
      $perc = sprintf("%.2f", $perc) ;
      $result .= ",$perc" ;
    }
    else
    {
      $result .= ",0" ;
    }
  }
  else
  {
    $result .= ",,,," ;
  }
  $value = 1000 * $countua {$code, '.', '.', '.'} * $multiplier ;
  $writevalue = sprintf("%.0f", $value) ;
  $result .= ",$writevalue" ;
  if ($showperc)
  {
    $perc = 0.1 * $value / $total_count ;
    $perc = sprintf("%.2f", $perc) ;
    $result .= ",$perc" ;
    $perc = 100 * $countua {$code, 'M', '.', '.'} * $multiplier / $total_count ;
    $perc = sprintf("%.2f", $perc) ;
    $result .= ",$perc" ;
    $perc = 100 * $countua {$code, 'W', '.', '.'} * $multiplier / $total_count ;
    $perc = sprintf("%.2f", $perc) ;
    $result .= ",$perc" ;
    $perc = 100 * $countua {$code, 'X', '.', '.'} * $multiplier / $total_count ;
    $perc = sprintf("%.2f", $perc) ;
    $result .= ",$perc" ;
  }
  else
  {
    $result .= ",,,," ;
  }
  $result .= "\n" ;
  return $result ;
}

sub WriteReportUserAgents
{
  &LogSub ("WriteReportUserAgents\n") ;

  $marker_color = '#8000FF' ;
  $bgcolor = '#FFFFDD' ;
# $altbgcolor = '#DDFFDD' ;

  open FILE_HTML_USER_AGENTS, '>', "$path_reports/$file_html_user_agents" ;
  open FILE_CSV_USER_AGENTS, '>', "$path_reports/$file_csv_user_agents_out" ;

  $csv_out = "# category, pageviews total, pageviews percentage, mobile, main, search_estimate, all total, percentage, mobile, main, other\n" ;
  $html  = $headerwithperc ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - User Agent Overview/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - User Agent Overview/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  $html =~ s/LINKS/&ListLinksExcept ($link_user_agents)/e ; 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;
  
  &AddNoticeSurvey (11) ;

  $html .= "<table border=1>\n" ;

  $html .= "<tr><th class=l valign='top' rowspan=2 colspan=4>&nbsp;</th><th rowspan=15>&nbsp;</th><th class=c colspan=4>Page views</th><th rowspan=15>&nbsp;</th><th class=c colspan=4>All requests</th></tr>\n" ;
  $html .= "<tr><th class=c>Total</th><th class=c>To mobile</th><th class=c>To main site</th><th class=c>Search-based estimate<a href='#explain_search'>[1]</a></th>" ;
  $html .= "<th class=c>Total</th><th class=c>To mobile</th><th class=c>To main site</th><th class=c>To other servers<a href='#explain_other'>[2]</a></th></tr>\n" ;
  $total_count                   = $countua {'Z', '.', '.', '.'} * $multiplier ;
  $total_html                    = ($countua {'Z', 'M', 'page', '.'} + $countua {'Z', 'W', 'page', '.'}) * $multiplier ;
  $total_opensearch              = $countua {'Z', '.', '.', 'opensearch'} * $multiplier ;
  $total_mobile                  = $countua {'S', '.', '.', '.'} * $multiplier ;
  $total_mobile_html             = ($countua {'S', 'M', 'page', '.'} + $countua {'S', 'W', 'page', '.'}) * $multiplier ;
  $mobile_opensearch             = $countua {'S', '.', '.', 'opensearch'} * $multiplier ;

  $html .= &UserAgentLine("From all sources", 'Z', $false, $true, 0, 0) ;
  $csv_out .= &UserAgentCsvLine("From all sources", '.', $false) ;
  $html .= &UserAgentLine("From mobile devices", 'S', $true, $true, 1, 13) ;
  $csv_out .= &UserAgentCsvLine("From mobile devices", 'S', $true) ;
  $html .= &UserAgentLine("From mobile browsers", 'C', $true, $true, 2, 10) ;
  $csv_out .= &UserAgentCsvLine("From mobile sources", 'C', $true) ;
  $html .= &UserAgentLine("From tablet browsers", 'T', $true, $false, 3, 3) ;
  $csv_out .= &UserAgentCsvLine("From tablet sources", 'T', $true) ;
  $html .= &UserAgentLine("From other mobile browsers", 'M', $true, $false, 3, 0) ;
  $csv_out .= &UserAgentCsvLine("From other mobile browsers", 'M', $true) ;
  $html .= &UserAgentLine("Through WAP access", 'P', $true, $false, 3, 0) ;
  $csv_out .= &UserAgentCsvLine("Through WAP access", 'P', $true) ;
  $html .= &UserAgentLine("From mobile apps", 'Q', $true, $true, 2, 0) ;
  $csv_out .= &UserAgentCsvLine("From mobile apps", 'Q', $true) ;
  $html .= &UserAgentLine("Wikimedia Android apps", 'A', $true, $false, 3, 5) ;
  $csv_out .= &UserAgentCsvLine("Wikimedia Android apps", 'A', $true) ;
  $html .= &UserAgentLine("Other Android apps", 'a', $true, $false, 3, 0) ;
  $csv_out .= &UserAgentCsvLine("Other Android apps", 'a', $true) ;
  $html .= &UserAgentLine("Wikimedia iOS apps", 'I', $true, $false, 3, 0) ;
  $csv_out .= &UserAgentCsvLine("Wikimedia iOS apps", 'I', $true) ;
  $html .= &UserAgentLine("Other iOS apps", 'i', $true, $false, 3, 0) ;
  $csv_out .= &UserAgentCsvLine("Other iOS apps", 'i', $true) ;
  $html .= &UserAgentLine("Unspecified apps", 'W', $true, $false, 3, 0) ;
  $csv_out .= &UserAgentCsvLine("Unspecified apps", 'W', $true) ;
  $html .= &UserAgentLine("From non-mobile devices", 'N', $true, $true, 1, 0) ;
  $csv_out .= &UserAgentCsvLine("From non-mobile devices", 'N', $true) ;
  $html .= "</table>\n" ;
  $html .= "<p>&nbsp;</p>\n" ;
  $html .= "<table border=1>\n" ;
  $html .= "<tr><th class=l colspan=2>Breakdown of traffic from mobile devices</th><th>Page views</th><th>Total requests</th><th>Search-based estimate<a href='#explain_search'>[1]</a></th></tr>\n" ;
  $html .= &UserAgentMobileLine("From mobile browsers", 'C', $true, 0, 0) ;
  $html .= &UserAgentMobileLine("From tablet browsers", 'T', $false, 1, 3) ;
  $html .= &UserAgentMobileLine("From other mobile browsers", 'M', $false, 1, 0) ;
  $html .= &UserAgentMobileLine("Through WAP access", 'P', $false, 1, 0) ;
  $html .= &UserAgentMobileLine("From mobile apps", 'Q', $true, 0, 0) ;
  $html .= &UserAgentMobileLine("Wikimedia Android apps", 'A', $false, 1, 5) ;
  $html .= &UserAgentMobileLine("Other Android apps", 'a', $false, 1, 0) ;
  $html .= &UserAgentMobileLine("Wikimedia iOS apps", 'I', $false, 1, 0) ;
  $html .= &UserAgentMobileLine("Other iOS apps", 'i', $false, 1, 0) ;
  $html .= &UserAgentMobileLine("Unspecified apps", 'W', $false, 1, 0) ;
  $html .= "</table>\n" ;
  $html .= "<p><a name='explain_search'>[1]: Various mobile apps use the user's browser to show most Wikipedia pages. This includes Wikimedia's own iOS app upto early April 2012. Thus, in the data here they are underrepresented. The percentages in the 'estimate' column are based on the search-related api which <i>is</i> visible, at least for the iOS app. Thus they give a more reliable estimate of the actual use of applications on Wikipedia.</a></p>" ;
  $html .= "<p><a name='explain_other'>[2]: The great majority of the traffic to 'other' servers is images from upload.wikimedia.org.</a></p>\n" ;
  $html .= $colophon_ae ;

  print FILE_HTML_USER_AGENTS $html ;
  print FILE_CSV_USER_AGENTS $csv_out ;
  close FILE_HTML_USER_AGENTS ;
  close FILE_CSV_USER_AGENTS ;
}

sub SectionReportDevices
{
  my ($section, $section_name) = @_ ;
  $value = &ShowCount ( $devicecats { $section } * $multiplier ) ;
  $perc = &ShowPerc ( 100 * $devicecats { $section } / $alldevices ) ;
  my $result = "<tr><td class=lt rowspan=@@>$section_name</td><td class=rt rowspan=@@>$value</td><td class=rt rowspan=@@>$perc</td>\n" ;
  $devcounter = 0 ;
  foreach $device (keys_sorted_by_value_num_desc %devices)
  {
    next if ( $catfordevice { $device } ne $section ) ;
    $value = &ShowCount ( $devices { $device } * $multiplier ) ;
    $perc = &ShowPerc ( 100 * $devices { $device } / $alldevices ) ;
    if ($devcounter ne 0)
    { $result .= "<tr>"; }
    $result .= "<td class=lt>$device</td><td class=rt>$value</td><td class=rt>$perc</td></tr>\n" ;
    $devcounter++ ;
  }
  $result =~ s/@@/$devcounter/g ;
  return $result ;
}

sub WriteReportDevices
{
  &LogSub ("WriteReportDevices\n") ;

  $marker_color = '#8000FF' ;

  open FILE_HTML_DEVICES, '>', "$path_reports/$file_html_devices" ;

  $html  = $header ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Mobile Device Types/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Mobile Device Types/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS<\/b>/ ;
  $html =~ s/LINKS/&ListLinksExcept ($link_devices)/e ; 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;
  $html .= "<table border=1>\n" ;
  $html .= "<tr><th class=l>Device class</th><th class=c>Count</th><th class=c>Percentage</th><th class=l>Device</th><th class=c>Count</th><th class=c>Percentage</th></tr>" ;
  $html .= &SectionReportDevices ( "iOS", "iOS" ) ;
  $html .= &SectionReportDevices ( "Android", "Android" ) ;
  $html .= &SectionReportDevices ( "Blackberry", "BlackBerry" ) ;
  $html .= &SectionReportDevices ( "Windows", "Windows Mobile" ) ;
  $html .= &SectionReportDevices ( "Symbian", "Symbian/other Nokia" ) ;
  $html .= &SectionReportDevices ( "Bada", "Bada/other Samsung" ) ;
  $html .= &SectionReportDevices ( "Playstation", "Playstation" ) ;
  $html .= &SectionReportDevices ( "Nintendo", "Nintendo" ) ;
  $html .= &SectionReportDevices ( "Other", "Other/Unknown" ) ;
  $html .= "</table>\n" ;
  $html .= $colophon_ae ;
  print FILE_HTML_DEVICES $html ;
  close FILE_HTML_DEVICES ;
}

sub ReportLineCountriesInfoTypes
{
    my $country = shift ;
    $rowvalue = $countryua { $country, '.', '.'} * $multiplier ;
    $rowvaluemobile = $countryua { $country, '.', 'M'} * $multiplier ;
    $result = "<td/>" ;
    $result .= &UserAgentField( $countryua { $country, '.', '.' }, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'I', '.'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'A', '.'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'W', '.'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'T', '.'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'M', '.'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'P', '.'}, $false, $rowvalue) ;
    $result .= &UserAgentField( $countryua { $country, '.', '.'} - $countryua { $country, 'N', '.'}, $false) ;
    $result .= &UserAgentFieldPerc( $countryua { $country, '.', '.'} - $countryua { $country, 'N', '.'}, $countryua { $country, '.', '.'} * $multiplier, $true, $false) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'N', '.'}, $false, $rowvalue) ;
    $result .= "<td/>" ;
    $result .= &UserAgentFieldNew( $countryua { $country, '.', 'M'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'I', 'M'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'A', 'M'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'W', 'M'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'T', 'M'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'M', 'M'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'P', 'M'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, '.', 'M'} - $countryua { $country, 'N', 'M'}, $false, $rowvalue) ;
    $result .= &UserAgentFieldNew( $countryua { $country, 'N', 'M'}, $false, $rowvalue) ;
    return $result ;
}

sub WriteReportCountriesInfo
{
  &LogSub ("WriteReportCountriesInfo\n") ;
  
  open FILE_HTML_COUNTRIES_INFO, '>', "$path_reports/$file_html_countries_info" ;

  $html  = $headerwithperc ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Page view breakdown per Country/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Page view breakdown per Country/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS1<br\/>\nLINKS2<\/b>/ ;
  $html =~ s/LINKS1/&ListLinksExcept ($link_crawlers)/e ; 
  $html =~ s/LINKS2/&ListLinksGeoExcept ($link_countries_useragents)/e ; 

  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;

  $html .= "<p>Some remarks on these data\n" .
           "<ul><li>All data from the Wikimedia servers themselves is counted as 'unknown'. This includes much of the Wikimedia app data, which is often received, then resent with slight modification</li>" .
           "<li>Wikimedia iOS app is not recognized for versions older than 3.0</li>" .
           "</ul>" ;

  &AddNoticeSurvey (26) ;

  $html .= &HtmlSortTable ;

  $html .= "<p><table border=1 width=800 class=tablesorter id=table1>\n" ;
  $html .= "<thead>\n" ;

  $html .= "<tr><td class=hr colspan=3 rowspan=1><b>Location</b></td>" .
               "<td class=hc rowspan=3><b>Population</b></td>" .
               "<td class=hc colspan=2 rowspan=3><b>Internet<br>Users</b><br><small><font color=#404040>absolute count and percentage of country population</font></small></td>" .
               "<td rowspan=3>&nbsp;</td>" .
               "<td class=hc colspan=10><b>All pageviews</b></td>" .
               "<td rowspan=3>&nbsp;</td>" .
               "<td class=hc colspan=9><b>To mobile site</b></td></tr>\n" ;
  $html .= "<tr><td class=hr rowspan=2><b>Country</b></td><td class=hc rowspan=2><b>Region</b><br><img src='http://stats.wikimedia.org/Location_of_Continents2.gif'></td><td class=hc rowspan=2><b>N/S</b></td>" .
               "<td class=hc rowspan='2'>Total</td><td class=hc colspan='2'>Wikimedia apps</colspan><td class=hc rowspan='2'>Other apps</td><td class=hc colspan=3>mobile browsers</c><td class=hc colspan='2'>Total mobile</td><td class=hc rowspan='2'>Non-mobile</td><td class=hc rowspan='2'>Total</td><td class=hc colspan='2'>Wikimedia apps</colspan><td class=hc rowspan='2'>Other apps</td><td class=hc colspan=3>mobile browsers</c><td class=hc rowspan='2'>Total mobile</td><td class=hc rowspan='2'>Non-mobile</td></tr>\n" ;
  $html .= "<tr><td class=hc>iOS</td><td class=hc>Android</td><td class=hc>Tablets</td><td class=hc>Other</td><td class=hc>WAP</td><td class=hc>Count</td><td class=hc>Perc.</td><td class=hc>iOS</td><td class=hc>Android</td><td class=hc>Tablets</td><td class=hc>Other</td><td class=hc>WAP</td></tr>\n" ;
  $html .= "<tr><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th><th>&nbsp;</th></tr>\n" ;
  $html .= "</thead><tbody>\n" ;
  $html .= "\nTOTAL\nREGIONS\n" ;

  undef $population_tot ;
  undef $connected_tot ;
  undef %population_region ;
  undef %connected_region ;

  $countryua {'--', '.', '.' } += $countryua {'-X', '.', '.' } ;
  $countryua {'--', 'I', '.' } += $countryua {'-X', 'I', '.' } ;
  $countryua {'--', 'A', '.' } += $countryua {'-X', 'A', '.' } ;
  $countryua {'--', 'W', '.' } += $countryua {'-X', 'W', '.' } ;
  $countryua {'--', 'T', '.' } += $countryua {'-X', 'T', '.' } ;
  $countryua {'--', 'M', '.' } += $countryua {'-X', 'M', '.' } ;
  $countryua {'--', 'P', '.' } += $countryua {'-X', 'P', '.' } ;
  $countryua {'--', 'N', '.' } += $countryua {'-X', 'N', '.' } ;
  $countryua {'--', '.', 'M' } += $countryua {'-X', '.', 'M' } ;
  $countryua {'--', 'I', 'M' } += $countryua {'-X', 'I', 'M' } ;
  $countryua {'--', 'A', 'M' } += $countryua {'-X', 'A', 'M' } ;
  $countryua {'--', 'W', 'M' } += $countryua {'-X', 'W', 'M' } ;
  $countryua {'--', 'T', 'M' } += $countryua {'-X', 'T', 'M' } ;
  $countryua {'--', 'M', 'M' } += $countryua {'-X', 'M', 'M' } ;
  $countryua {'--', 'P', 'M' } += $countryua {'-X', 'P', 'M' } ;
  $countryua {'--', 'N', 'M' } += $countryua {'-X', 'N', 'M' } ;

  foreach $code (keys_sorted_by_value_num_desc %countrycount)
  {
    next if ($code eq '-X') ;
    my $country = $country_codes {$code} ;
    $country =~ s/\"//g ;
    $country =~ s/Korea, Republic of/South Korea/ ;
    $country =~ s/Cote d'Ivoire/Côte d'Ivoire/ ;
    $country =~ s/Palestinian Territory/Palestinian Territories/ ;
    $country =~ s/Virgin Islands, U.S./United States Virgin Islands/ ;
    $country =~ s/Congo - The Democratic Republic of the/Democratic Republic of the Congo/ ;
    $country =~ s/Reunion/Réunion/ ;
    $country =~ s/Virgin Islands, British/British Virgin Islands/ ;
    $country =~ s/Micronesia, Federated States of/Federated States of Micronesia/ ;
    $country =~ s/\(Malvinas\)// ;
    $country =~ s/Korea, Democratic People's Republic of/North Korea/ ;
    $country =~ s/^\s*Congo\s*$/Republic of the Congo/ ;
    $country =~ s/Sao Tome and Principe/São Tomé and Príncipe/ ;
    $country =~ s/^\s+// ;
    $country =~ s/\s+$// ;

    my $region_code      = $region_codes {$code} ;
    my $north_south_code = $north_south_codes {$code} ;

    $region_name = $region_code ;
    $region_name =~ s/^AF$/<font color=#028702><b>Africa<\/b><\/font>/ ;
    $region_name =~ s/^CA$/<font color=#249CA0><b>Central-America<\/b><\/font>/ ;
    $region_name =~ s/^SA$/<font color=#FCAA03><b>South-America<\/b><\/font>/ ;
    $region_name =~ s/^NA$/<font color=#C802CA><b>North-America<\/b><\/font>/ ;
    $region_name =~ s/^EU$/<font color=#0100CA><b>Europe<\/b><\/font>/ ;
    $region_name =~ s/^AS$/<font color=#E10202><b>Asia<\/b><\/font>/ ;
    $region_name =~ s/^OC$/<font color=#02AAD4><b>Oceania<\/b><\/font>/ ;

    $north_south_name = $north_south_code ;
    $north_south_name =~ s/^N$/<font color=#000BF7><b>N<\/b><\/font>/ ;
    $north_south_name =~ s/^S$/<font color=#FE0B0D><b>S<\/b><\/font>/ ;

    $countryua {'reg_'.$region_code, '.', '.' } += $countryua {$code, '.', '.' } ;
    $countryua {'reg_'.$region_code, 'I', '.' } += $countryua {$code, 'I', '.' } ;
    $countryua {'reg_'.$region_code, 'A', '.' } += $countryua {$code, 'A', '.' } ;
    $countryua {'reg_'.$region_code, 'W', '.' } += $countryua {$code, 'W', '.' } ;
    $countryua {'reg_'.$region_code, 'T', '.' } += $countryua {$code, 'T', '.' } ;
    $countryua {'reg_'.$region_code, 'M', '.' } += $countryua {$code, 'M', '.' } ;
    $countryua {'reg_'.$region_code, 'P', '.' } += $countryua {$code, 'P', '.' } ;
    $countryua {'reg_'.$region_code, 'N', '.' } += $countryua {$code, 'N', '.' } ;
    $countryua {'reg_'.$region_code, '.', 'M' } += $countryua {$code, '.', 'M' } ;
    $countryua {'reg_'.$region_code, 'I', 'M' } += $countryua {$code, 'I', 'M' } ;
    $countryua {'reg_'.$region_code, 'A', 'M' } += $countryua {$code, 'A', 'M' } ;
    $countryua {'reg_'.$region_code, 'W', 'M' } += $countryua {$code, 'W', 'M' } ;
    $countryua {'reg_'.$region_code, 'T', 'M' } += $countryua {$code, 'T', 'M' } ;
    $countryua {'reg_'.$region_code, 'M', 'M' } += $countryua {$code, 'M', 'M' } ;
    $countryua {'reg_'.$region_code, 'P', 'M' } += $countryua {$code, 'P', 'M' } ;
    $countryua {'reg_'.$region_code, 'N', 'M' } += $countryua {$code, 'N', 'M' } ;

    $countryua {'reg_'.$north_south_code, '.', '.' } += $countryua {$code, '.', '.' } ;
    $countryua {'reg_'.$north_south_code, 'I', '.' } += $countryua {$code, 'I', '.' } ;
    $countryua {'reg_'.$north_south_code, 'A', '.' } += $countryua {$code, 'A', '.' } ;
    $countryua {'reg_'.$north_south_code, 'W', '.' } += $countryua {$code, 'W', '.' } ;
    $countryua {'reg_'.$north_south_code, 'T', '.' } += $countryua {$code, 'T', '.' } ;
    $countryua {'reg_'.$north_south_code, 'M', '.' } += $countryua {$code, 'M', '.' } ;
    $countryua {'reg_'.$north_south_code, 'P', '.' } += $countryua {$code, 'P', '.' } ;
    $countryua {'reg_'.$north_south_code, 'N', '.' } += $countryua {$code, 'N', '.' } ;
    $countryua {'reg_'.$north_south_code, '.', 'M' } += $countryua {$code, '.', 'M' } ;
    $countryua {'reg_'.$north_south_code, 'I', 'M' } += $countryua {$code, 'I', 'M' } ;
    $countryua {'reg_'.$north_south_code, 'A', 'M' } += $countryua {$code, 'A', 'M' } ;
    $countryua {'reg_'.$north_south_code, 'W', 'M' } += $countryua {$code, 'W', 'M' } ;
    $countryua {'reg_'.$north_south_code, 'T', 'M' } += $countryua {$code, 'T', 'M' } ;
    $countryua {'reg_'.$north_south_code, 'M', 'M' } += $countryua {$code, 'M', 'M' } ;
    $countryua {'reg_'.$north_south_code, 'P', 'M' } += $countryua {$code, 'P', 'M' } ;
    $countryua {'reg_'.$north_south_code, 'N', 'M' } += $countryua {$code, 'N', 'M' } ;

    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;
    $population_tot += $population ;
    $connected_tot += $connected ;
    $population_region {$region_code} += $population ;
    $connected_region {$region_code } += $connected ;
    $population_region {$north_south_code} += $population ;
    $connected_region {$north_south_code } += $connected ;
    $perc_connected = ".." ;

    $regionpopulation = $population_region {$region_code} ;

    $population2 = &i2KM2 ($population) ;
    $connected2  = &i2KM2 ($connected) ;
    if ( $connected > 0 )
    { $penetration = sprintf ("%.0f", 100 * $connected / $population) .'%' ; }
    else
    { $penetration = '..' ; }

    if ($region_code ne 'XX' && $region_code ne 'QP' && $region_code ne '')
    {
      $html .= "<tr><th class=rh3><a id='$country' name='$country'></a>$link_country $icon</th>" .
                 "<td>$region_name</td>" .
                 "<td>$north_south_name</td>" .
                 "<td>$population2</td>" .
                 "<td>$connected2</td>" .
                 "<td>$penetration</td>" .
                 &ReportLineCountriesInfoTypes($code) .
                 "</tr>\n" ;
    }

  }
  
  $population_tot2 = &i2KM2 ($population_tot) ;
  $connected_tot2  = &i2KM2 ($connected_tot) ;

  if ( $connected_tot > 0 )
  { $penetration = sprintf ("%.0f", 100 * $connected_tot / $population_tot) .'%' ; }
  else
  { $penetration = '..' ; }

  $html_total = "<tr><th class=rh3>All countries in</td>" .
                    "<td><b>World</b></td>" .
                    "<td>&nbsp;</td>" .
                    "<td>$population_tot2</td>" .
                    "<td>$connected_tot2</td>" .
                    "<td>$penetration</td>" .
                    &ReportLineCountriesInfoTypes('.') .
                    "</tr>\n" ;
  $html_total .= "<tr><td colspan=999>&nbsp;</td></tr>" ;

  $html_regions = '' ;

  foreach $key (qw (N S QP XX AF AS EU CA NA SA OC))
# foreach $key (qw (N S       AF AS AU EU CA NA SA OC)) # skip IPv6 and Unknown till data are vetted
  {
    $region = $key ;

    $region =~ s/^N$/<font color=#000BF7><b>Global North<\/b><\/font>/ ;
    $region =~ s/^S$/<font color=#FE0B0D><b>Global South<\/b><\/font>/ ;
    $region =~ s/^QP$/<b>IPv6<\/b>/ ;
    $region =~ s/^XX$/<b>Unknown11<\/b>/ ;

    $region =~ s/^AF$/<font color=#028702><b>Africa<\/b><\/font>/ ;
    $region =~ s/^CA$/<font color=#249CA0><b>Central-America<\/b><\/font>/ ;
    $region =~ s/^SA$/<font color=#FCAA03><b>South-America<\/b><\/font>/ ;
    $region =~ s/^NA$/<font color=#C802CA><b>North-America<\/b><\/font>/ ;
    $region =~ s/^EU$/<font color=#0100CA><b>Europe<\/b><\/font>/ ;
    $region =~ s/^AS$/<font color=#E10202><b>Asia<\/b><\/font>/ ;
    $region =~ s/^OC$/<font color=#02AAD4><b>Oceania<\/b><\/font>/ ;

    $population_region  = $population_region {$key} ;
    $connected_region   = $connected_region  {$key} ;
    if ($connected_region > 0 )
    { $penetration = sprintf ("%.0f", 100 * $connected_region / $population_region) .'%' ; }
    else
    { $penetration = '..' ; }

    $population_region2 = &i2KM2 ($population_region) ;
    $connected_region2  = &i2KM2 ($connected_region) ;

    $html_regions .= "<tr><th>All countries in</th>" .
                     "</td><td>$region</td>" .
                     "<td>&nbsp;</td>" .
                     "<td>$population_region2</td>" .
                     "<td>$connected_region2</td>" .
                     "<td>$penetration</td>" .
                     &ReportLineCountriesInfoTypes('reg_' . $key) .
                     "</tr>\n" ;

    if (($key eq 'XX') || (($key eq 'OC')))
  # if (($key eq 'S' ) || (($key eq 'OC')))

    {   $html_regions .= "<tr><td colspan=999>&nbsp;</td></tr>" ; }
  }


  $html .= "</tbody>\n</table>\n" ;

  $html =~ s/TOTAL/$html_total/ ;
  $html =~ s/REGIONS/$html_regions/ ;

  # &PrintHtml ($html, "$path_reports/$file_html_per_country_overview") ;
  $html .= "<p>Visits by bots are not included." ;
  $html .= "Country meta data collected from English Wikipedia (<a href='http://en.wikipedia.org/wiki/List_of_countries_by_population'>population</a>, <a href='http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>internet users</a>)). " ;

  $html .= "<script type='text/javascript'>\n" .
           "\$('#table1').tablesorter({\n" .
           "// debug:true,\n" .
           "headers:{0:{sorter:'nohtml'},1:{sorter:'nohtml'},2:{sorter:'nohtml'},3:{sorter:'millions'},4: {sorter:'millions'},5:{sorter:'digitsonly'},7:{sorter:'showcount'},8:{sorter:'showcountswitch'},9: {sorter:'showcountswitch'}, 10: {sorter: 'showcountswitch'}, 11: {sorter: 'showcountswitch'}, 12: {sorter:  'showcountswitch'}, 13: {sorter: 'showcountswitch'}, 14: {sorter: 'showcount'}, 15: {sorter: 'digitsonly'},  16: {sorter: 'showcountswitch'}, 18: {sorter: 'showcountswitch'}, 19: {sorter: 'showcountswitch'}, 20:  {sorter: 'showcountswitch'}, 21: {sorter: 'showcountswitch'}, 22: {sorter: 'showcountswitch'}, 23: {sorter:  'showcountswitch'}, 24: {sorter: 'showcountswitch'}, 25: {sorter: 'showcountswitch'}, 26: {sorter:  'showcountswitch'}}});\n" .
           "</script>\n" ;
  $html .= $colophon_ae ;
  print FILE_HTML_COUNTRIES_INFO $html ;
  close FILE_HTML_COUNTRIES_INFO ;
}

sub WriteReportCountryOpSys
{
  &LogSub ("WriteReportCountryOpSys\n") ;

  open FILE_HTML_COUNTRIES_OPSYS, '>', "$path_reports/$file_html_countries_os" || die ("Can not write $path_reports/$file_html_countries_os\n") ;

  $html = $headerwithperc ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - OS breakdown per Country/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - OS breakdown per Country/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS1<br\/>\nLINKS2<\/b>/ ;
  $html =~ s/LINKS1/&ListLinksExcept ('')/e ; 
  $html =~ s/LINKS2/&ListLinksGeoExcept ($link_countries_os)/e ; 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;
  $html .= "<p>Note: Requests from Wikimedia servers themselves have been counted as 'unknown country', and in fact form by far the greatest part of those.</p>\n" ;

  &AddNoticeSurvey (27) ;

  $html .= &HtmlSortTable ;
  $html .= "<p><table border=1 width=800 class=tablesorter id=table1>\n" ;
  $html .= "<thead>\n" ;
  $html .= "<tr><td class=hr><b>Country</b></td><td class=hc><b>Region</b><br><img src='http://stats.wikimedia.org/Location_of_Continents2.gif'></td><td class=hc><b>N/S</b></td>" .
           "<td class=hc><b>Population</b></td><td class=hc colspan=2><b>Internet<br>Users</b><br><small><font color=#404040>absolute count and percentage of country population</font></small></td>" .
           "<td class=hc><b>Total</b></td>" ;
  $counter = 0 ;
  foreach $os (keys_sorted_by_value_num_desc %allcountryos)
  {
     next if ($os eq '..') ;
     next if ($counter++ > 12) ;
     $html .= "<td class=hc>$os</td>" ;
  }
  $html .= "<td class=hc>Other</td>" ;
  $html .= "</tr>\n" ;
  $html .= "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>\n" ;

  $html .= "\nTOTAL\nREGIONS\n" ;

  undef $population_tot ;
  undef $connected_tot ;
  undef %population_region ;
  undef %connected_region ;
  undef %country_total ;

  foreach $os (keys_sorted_by_value_num_desc %allcountryos)
  { $countryos {'--', $os} += $countryos {'-X', $os} ; }

  foreach $code (keys_sorted_by_value_num_desc %countryallos)
  {
    next if ($code eq '-X') ;
    my $country = $country_codes {$code} ;

  # $country =~ s/\"//g ;
  # $country =~ s/Korea, Republic of/South Korea/ ;
  # $country =~ s/Cote d'Ivoire/Côte d'Ivoire/ ;
  # $country =~ s/Palestinian Territory/Palestinian Territories/ ;
  # $country =~ s/Virgin Islands, U.S./United States Virgin Islands/ ;
  # $country =~ s/Congo - The Democratic Republic of the/Democratic Republic of the Congo/ ;
  # $country =~ s/Reunion/Réunion/ ;
  # $country =~ s/Virgin Islands, British/British Virgin Islands/ ;
  # $country =~ s/Micronesia, Federated States of/Federated States of Micronesia/ ;
  # $country =~ s/\(Malvinas\)// ;
  # $country =~ s/Korea, Democratic People's Republic of/North Korea/ ;
  # $country =~ s/^\s*Congo\s*$/Republic of the Congo/ ;
  # $country =~ s/Sao Tome and Principe/São Tomé and Príncipe/ ;
  # $country =~ s/^\s+// ;
  # $country =~ s/\s+$// ;

    my $region_code      = $region_codes {$code} ;
    if ($region_code eq '')
    { $region_code = 'XX' ; }
    my $north_south_code = $north_south_codes {$code} ;

    $region_name = $region_code ;
    $region_name =~ s/^AF$/<font color=#028702><b>Africa<\/b><\/font>/ ;
    $region_name =~ s/^CA$/<font color=#249CA0><b>Central-America<\/b><\/font>/ ;
    $region_name =~ s/^SA$/<font color=#FCAA03><b>South-America<\/b><\/font>/ ;
    $region_name =~ s/^NA$/<font color=#C802CA><b>North-America<\/b><\/font>/ ;
    $region_name =~ s/^EU$/<font color=#0100CA><b>Europe<\/b><\/font>/ ;
    $region_name =~ s/^AS$/<font color=#E10202><b>Asia<\/b><\/font>/ ;
    $region_name =~ s/^OC$/<font color=#02AAD4><b>Oceania<\/b><\/font>/ ;

    $north_south_name = $north_south_code ;
    $north_south_name =~ s/^N$/<font color=#000BF7><b>N<\/b><\/font>/ ;
    $north_south_name =~ s/^S$/<font color=#FE0B0D><b>S<\/b><\/font>/ ;

    $counter = 0 ;
    foreach $os (keys_sorted_by_value_num_desc %allcountryos)
    {
      next if ($os eq '..') ;
      if ($counter++ > 12)
      {
        $countryos {$code, '..'} += $countryos{$code, $os} ;
        next;
      }
      $countryos {'reg_'.$region_code, $os} += $countryos {$code, $os} ;
      $countryos {'reg_'.$north_south_code, $os} += $countryos {$code, $os} ;
      $country_total {$code} += $countryos {$code, $os} ;
    }
    $countryos {'reg_'.$region_code, '..'} += $countryos {$code, '..'} ;
    $countryos {'reg_'.$north_south_code, '..'} += $countryos {$code, '..'} ;
    $country_total {$code} += $countryos {$code, '..'} ;
    $country_total {'reg_'.$region_code} += $country_total {$code} ;
    $country_total {'reg_'.$north_south_code} += $country_total {$code} ;

    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;
    $icon =~ s/\"\/\/upload/\"http:\/\/upload/ ;
    $population_tot += $population ;
    $connected_tot += $connected ;
    $population_region {$region_code} += $population ;
    $connected_region {$region_code } += $connected ;
    $population_region {$north_south_code} += $population ;
    $connected_region {$north_south_code } += $connected ;
    $perc_connected = ".." ;

    $regionpopulation = $population_region {$region_code} ;

    $population2 = &i2KM2 ($population) ;
    $connected2  = &i2KM2 ($connected) ;
    if ( $connected > 0 )
    { $penetration = sprintf ("%.0f", 100 * $connected / $population) .'%' ; }
    else
    { $penetration = '..' ; }

    if ($region_code ne 'XX' && $region_code ne 'QP' && $region_code ne '')
    {
      $html .= "<tr><th class=rh3><a id='$country' name='$country'></a>$link_country $icon</th>" .
                 "<td>$region_name</td>" .
                 "<td>$north_south_name</td>" .
                 "<td>$population2</td>" .
                 "<td>$connected2</td>" .
                 "<td>$penetration</td>" ;
      $html .= UserAgentField( $country_total { $code } ) ;
      $counter = 0 ;
      foreach $os (keys_sorted_by_value_num_desc %allcountryos)
      {
        next if ($os eq '..') ;
        next if ($counter++ > 12) ;
        $html .= UserAgentFieldNew($countryos {$code, $os}, $false, $country_total { $code } * $multiplier ) ;
      }
      $html .= UserAgentFieldNew($countryos {$code, '..'}, $false, $country_total { $code } * $multiplier ) ;
      $html .= "</tr>\n" ;
    }

  }

  $population_tot2 = &i2KM2 ($population_tot) ;
  $connected_tot2  = &i2KM2 ($connected_tot) ;

  if ( $connected_tot > 0 )
  { $penetration = sprintf ("%.0f", 100 * $connected_tot / $population_tot) .'%' ; }
  else
  { $penetration = '..' ; }

  $counter = 0 ;
  foreach $os (keys_sorted_by_value_num_desc %allcountryos)
  {
    next if ($os eq '..') ;
    if ($counter++ > 12)
    { $allcountryos {'..'} += $allcountryos {$os} ; }
    else
    { $allcountriesallos += $allcountryos {$os} ; }
  }
  $allcountriesallos += $allcountryos {'..'} ;

  $html_total = "<tr><th class=rh3>All countries in</th>" .
                    "<td><b>World</b></td>" .
                    "<td>&nbsp;</td>" .
                    "<td>$population_tot2</td>" .
                    "<td>$connected_tot2</td>" .
                    "<td>$penetration</td>" ;
  $html_total .= UserAgentField( $allcountriesallos ) ;

  $counter = 0 ;
  foreach $os (keys_sorted_by_value_num_desc %allcountryos)
  {
    next if ($os eq '..') ;
    next if ($counter++ > 12) ;
    $html_total .= UserAgentFieldNew($allcountryos {$os}, $false, $allcountriesallos * $multiplier ) ;
  }
  $html_total .= UserAgentFieldNew($allcountryos {'..'}, $false, $allcountriesallos * $multiplier ) ;

  $html_total .= "</tr>\n" ;
  $html_total .= "<tr><td colspan=99>&nbsp;</td></tr>" ;

  $html_regions = '' ;

  foreach $key (qw (N S QP XX AF AS EU CA NA SA OC))
# foreach $key (qw (N S       AF AS AU EU CA NA SA OC)) # skip IPv6 and Unknown till data are vetted
  {
    $region = $key ;

    $region =~ s/^N$/<font color=#000BF7><b>Global North<\/b><\/font>/ ;
    $region =~ s/^S$/<font color=#FE0B0D><b>Global South<\/b><\/font>/ ;
    $region =~ s/^QP$/<b>IPv6<\/b>/ ;
    $region =~ s/^XX$/<b>Unknown12<\/b>/ ;

    $region =~ s/^AF$/<font color=#028702><b>Africa<\/b><\/font>/ ;
    $region =~ s/^CA$/<font color=#249CA0><b>Central-America<\/b><\/font>/ ;
    $region =~ s/^SA$/<font color=#FCAA03><b>South-America<\/b><\/font>/ ;
    $region =~ s/^NA$/<font color=#C802CA><b>North-America<\/b><\/font>/ ;
    $region =~ s/^EU$/<font color=#0100CA><b>Europe<\/b><\/font>/ ;
    $region =~ s/^AS$/<font color=#E10202><b>Asia<\/b><\/font>/ ;
    $region =~ s/^OC$/<font color=#02AAD4><b>Oceania<\/b><\/font>/ ;
    $region =~ s/^XX$/<font color=#666666><b>Unknown13<\/b><\/font>/ ;


    $population_region  = $population_region {$key} ;
    $connected_region   = $connected_region  {$key} ;
    if ($connected_region > 0 )
    { $penetration = sprintf ("%.0f", 100 * $connected_region / $population_region) .'%' ; }
    else
    { $penetration = '..' ; }

    $population_region2 = &i2KM2 ($population_region) ;
    $connected_region2  = &i2KM2 ($connected_region) ;

    $html_regions .= "<tr><th>All countries in</th>" .
                     "</td><td>$region</td>" .
                     "<td>&nbsp;</td>" .
                     "<td>$population_region2</td>" .
                     "<td>$connected_region2</td>" .
                     "<td>$penetration</td>" ;
    $html_regions .= UserAgentField( $country_total { "reg_" . $key } ) ;

    $counter = 0 ;
    foreach $os (keys_sorted_by_value_num_desc %allcountryos)
    {
       next if ($os eq '..') ;
       next if ($counter++ > 12) ;
       $html_regions .= UserAgentFieldNew($countryos { "reg_" . $key, $os }, $false, $country_total { "reg_" . $key } * $multiplier ) ;
    }
    $html_regions .= UserAgentFieldNew($countryos { "reg_" . $key, '..' }, $false, $country_total { "reg_" . $key } * $multiplier ) ;

    $html_regions .= "</tr>\n" ;

    if (($key eq 'XX') || (($key eq 'OC')))
  # if (($key eq 'S') || (($key eq 'OC')))
    { $html_regions .= "<tr><td colspan=99>&nbsp;</td></tr>" ; }
  }
  $html .= "</tbody>\n</table>" ;
# $html .= "<script type='text/javascript'>\n" .
#           "\$('#table1').tablesorter({\n" .
#           "// debug:true,\n" .
#           "headers:{0:{sorter:'nohtml'},1:{sorter:'nohtml'},2:{sorter:'nohtml'},4:{sorter:'millions'},5:{sorter:'millions'},6:{sorter:'digitsonly'},8:{sorter:'millions'},9:{sorter:'millions'},10:{sorter:'millions'},11:{sorter:'millions'},12:{sorter:'millions'},13:{sorter:'millions'},14:{sorter:'millions'},15:{sorter:'millions'},16:{sorter:'digitsonly'},17:{sorter:'millions'},19:{sorter:'millions'},20:{sorter:'millions'},21:{sorter:'millions'},22:{sorter:'millions'},23:{sorter:'millions'},24:{sorter:'millions'},25:{sorter:'millions'},26:{sorter:'millions'},27:{sorter:'millions'}});\n" .
#           "</script>\n" ;

  $html .= "<p>Edits by bots are not included." ;
  $html .= "Country meta data collected from English Wikipedia (<a href='http://en.wikipedia.org/wiki/List_of_countries_by_population'>population</a>, <a href='http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>internet users</a>)). " ;

 #$html .= &HtmlSortTableColumns; ;

  $html =~ s/TOTAL/$html_total/ ;
  $html =~ s/REGIONS/$html_regions/ ;
 #&PrintHtml ($html, "$path_reports/$file_html_per_country_overview") ;

  $html .= "</table>\n" ;
  $html .= $colophon_ae ;
  print FILE_HTML_COUNTRIES_OPSYS $html ;
  close FILE_HTML_COUNTRIES_OPSYS ;
}

sub WriteReportCountryBrowser
{
  &LogSub ("WriteReportCountryBrowser\n") ;

  open FILE_HTML_COUNTRIES_BROWSER, '>', "$path_reports/$file_html_countries_browser" ;
  $html = $headerwithperc ;
  $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Browser breakdown per country/ ;
  $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Browser breakdown per country/ ;
  $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS1<br\/>\nLINKS2<\/b>/ ;
  $html =~ s/LINKS1/&ListLinksExcept ('')/e ; 
  $html =~ s/LINKS2/&ListLinksGeoExcept ($link_countries_browsers)/e ; 
  $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;

  $html .= "<p>Note: Requests from Wikimedia servers themselves have been counted as 'unknown country', and in fact form by far the greatest part of those.</p>\n" ;

  &AddNoticeSurvey (25) ;

  $html .= &HtmlSortTable ;
  $html .= "<p><table border=1 width=800 class=tablesorter id=table1>\n" ;
  $html .= "<thead>\n" ;
  $html .= "<tr><td class=hr><b>Country</b></td><td class=hc><b>Region</b><br><img src='http://stats.wikimedia.org/Location_of_Continents2.gif'></td><td class=hc><b>N/S</b></td>" .
           "<td class=hc><b>Population</b></td><td class=hc colspan=2><b>Internet<br>Users</b><br><small><font color=#404040>absolute count and percentage of country population</font></small></td>" .
           "<td class=hc><b>Total</b></td>" ;
  $counter = 0 ;
  foreach $browser (keys_sorted_by_value_num_desc %allcountrybrowser)
  {
     next if ($browser eq '..') ;
     next if ($counter++ > 12) ;
     $html .= "<td class=hc>$browser</td>" ;
  }
  $html .= "<td class=hc>Other</td>" ;
  $html .= "</tr>\n" ;
  $html .= "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>\n" ;

  $html .= "\nTOTAL\nREGIONS\n" ;

  undef $population_tot ;
  undef $connected_tot ;
  undef %population_region ;
  undef %connected_region ;
  undef %country_total ;

  foreach $browser (keys_sorted_by_value_num_desc %allcountrybrowser)
  { $countrybrowser {'--', $browser} += $countrybrowser {'-X', $browser} ; }

  foreach $code (keys_sorted_by_value_num_desc %countryallbrowser)
  {
    next if ($code eq '-X') ;
    my $country = $country_codes {$code} ;

  # $country =~ s/\"//g ;
  # $country =~ s/Korea, Republic of/South Korea/ ;
  # $country =~ s/Cote d'Ivoire/Côte d'Ivoire/ ;
  # $country =~ s/Palestinian Territory/Palestinian Territories/ ;
  # $country =~ s/Virgin Islands, U.S./United States Virgin Islands/ ;
  # $country =~ s/Congo - The Democratic Republic of the/Democratic Republic of the Congo/ ;
  # $country =~ s/Reunion/Réunion/ ;
  # $country =~ s/Virgin Islands, British/British Virgin Islands/ ;
  # $country =~ s/Micronesia, Federated States of/Federated States of Micronesia/ ;
  # $country =~ s/\(Malvinas\)// ;
  # $country =~ s/Korea, Democratic People's Republic of/North Korea/ ;
  # $country =~ s/^\s*Congo\s*$/Republic of the Congo/ ;
  # $country =~ s/Sao Tome and Principe/São Tomé and Príncipe/ ;
  # $country =~ s/^\s+// ;
  # $country =~ s/\s+$// ;

    my $region_code      = $region_codes {$code} ;
    if ($region_code eq '')
    { $region_code = 'XX' ; }
    my $north_south_code = $north_south_codes {$code} ;

    $region_name = $region_code ;
    $region_name =~ s/^AF$/<font color=#028702><b>Africa<\/b><\/font>/ ;
    $region_name =~ s/^CA$/<font color=#249CA0><b>Central-America<\/b><\/font>/ ;
    $region_name =~ s/^SA$/<font color=#FCAA03><b>South-America<\/b><\/font>/ ;
    $region_name =~ s/^NA$/<font color=#C802CA><b>North-America<\/b><\/font>/ ;
    $region_name =~ s/^EU$/<font color=#0100CA><b>Europe<\/b><\/font>/ ;
    $region_name =~ s/^AS$/<font color=#E10202><b>Asia<\/b><\/font>/ ;
    $region_name =~ s/^OC$/<font color=#02AAD4><b>Oceania<\/b><\/font>/ ;
    $region_name =~ s/^XX$/<font color=#666666><b>Unknown14<\/b><\/font>/ ;

    $north_south_name = $north_south_code ;
    $north_south_name =~ s/^N$/<font color=#000BF7><b>N<\/b><\/font>/ ;
    $north_south_name =~ s/^S$/<font color=#FE0B0D><b>S<\/b><\/font>/ ;

    $counter = 0 ;
    foreach $browser (keys_sorted_by_value_num_desc %allcountrybrowser)
    {
      next if ($browser eq '..') ;
      if ($counter++ > 12)
      {
        $countrybrowser {$code, '..'} += $countrybrowser{$code, $browser} ;
        next;
      }
      $countrybrowser {'reg_'.$region_code, $browser} += $countrybrowser {$code, $browser} ;
      $countrybrowser {'reg_'.$north_south_code, $browser} += $countrybrowser {$code, $browser} ;
      $country_total {$code} += $countrybrowser {$code, $browser} ;
    }
    $countrybrowser {'reg_'.$region_code, '..'} += $countrybrowser {$code, '..'} ;
    $countrybrowser {'reg_'.$north_south_code, '..'} += $countrybrowser {$code, '..'} ;
    $country_total {$code} += $countrybrowser {$code, '..'} ;
    $country_total {'reg_'.$region_code} += $country_total {$code} ;
    $country_total {'reg_'.$north_south_code} += $country_total {$code} ;

    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;

    $icon =~ s/\"\/\/upload/\"http:\/\/upload/ ;
    $population_tot += $population ;
    $connected_tot += $connected ;
    $population_region {$region_code} += $population ;
    $connected_region {$region_code } += $connected ;
    $population_region {$north_south_code} += $population ;
    $connected_region {$north_south_code } += $connected ;
    $perc_connected = ".." ;

    $regionpopulation = $population_region {$region_code} ;

    $population2 = &i2KM2 ($population) ;
    $connected2  = &i2KM2 ($connected) ;
    if ( $connected > 0 )
    { $penetration = sprintf ("%.0f", 100 * $connected / $population) .'%' ; }
    else
    { $penetration = '..' ; }

    if ($region_code ne 'XX' && $region_code ne 'QP' && $region_code ne '')
    {
      $html .= "<tr><th class=rh3><a id='$country' name='$country'></a>$link_country $icon</th>" .
                 "<td>$region_name</td>" .
                 "<td>$north_south_name</td>" .
                 "<td>$population2</td>" .
                 "<td>$connected2</td>" .
                 "<td>$penetration</td>" ;
      $html .= UserAgentField( $country_total { $code } ) ;
      $counter = 0 ;
      foreach $browser (keys_sorted_by_value_num_desc %allcountrybrowser)
      {
        next if ($browser eq '..') ;
        next if ($counter++ > 12) ;
        $html .= UserAgentFieldNew($countrybrowser {$code, $browser}, $false, $country_total { $code } * $multiplier) ;
      }
      $html .= UserAgentFieldNew($countrybrowser {$code, '..'}, $false, $country_total { $code } * $multiplier ) ;
     $html .= "</tr>\n" ;
    }

  }
  
  $population_tot2 = &i2KM2 ($population_tot) ;
  $connected_tot2  = &i2KM2 ($connected_tot) ;

  if ( $connected_tot > 0 )
  { $penetration = sprintf ("%.0f", 100 * $connected_tot / $population_tot) .'%' ; }
  else
  { $penetration = '..' ; }

  $counter = 0 ;
  foreach $browser (keys_sorted_by_value_num_desc %allcountrybrowser)
  {
    next if ($browser eq '..') ;
    if ($counter++ > 12)
    { $allcountrybrowser {'..'} += $allcountrybrowser {$browser} ; }
    else
    { $allcountriesallbrowser += $allcountrybrowser {$browser} ; }
  }
  $allcountriesallbrowser += $allcountrybrowser {'..'} ;

  $html_total = "<tr><th class=rh3>All countries in</th>" .
                    "<td><b>World</b></td>" .
                    "<td>&nbsp;</td>" .
                    "<td>$population_tot2</td>" .
                    "<td>$connected_tot2</td>" .
                    "<td>$penetration</td>" ;
  $html_total .= UserAgentField( $allcountriesallbrowser ) ;

  $counter = 0 ;
  foreach $browser (keys_sorted_by_value_num_desc %allcountrybrowser)
  {
    next if ($browser eq '..') ;
    next if ($counter++ > 12) ;
    $html_total .= UserAgentFieldNew($allcountrybrowser {$browser}, $false, $allcountriesallbrowser * $multiplier ) ;
  }
  $html_total .= UserAgentFieldNew($allcountrybrowser {'..'}, $false, $allcountriesallbrowser * $multiplier ) ;

  $html_total .= "</tr>\n" ;
  $html_total .= "<tr><td colspan=99>&nbsp;</td></tr>" ;

  $html_regions = '' ;

  foreach $key (qw (N S QP XX AF AS EU CA NA SA OC))
# foreach $key (qw (N S       AF AS AU EU CA NA SA OC)) # skip IPv6 and Unknown till data are vetted
  {
    $region = $key ;

    $region =~ s/^N$/<font color=#000BF7><b>Global North<\/b><\/font>/ ;
    $region =~ s/^S$/<font color=#FE0B0D><b>Global South<\/b><\/font>/ ;
    $region =~ s/^QP$/<b>IPv6<\/b>/ ;
    $region =~ s/^XX$/<b>Unknown15<\/b>/ ;

    $region =~ s/^AF$/<font color=#028702><b>Africa<\/b><\/font>/ ;
    $region =~ s/^CA$/<font color=#249CA0><b>Central-America<\/b><\/font>/ ;
    $region =~ s/^SA$/<font color=#FCAA03><b>South-America<\/b><\/font>/ ;
    $region =~ s/^NA$/<font color=#C802CA><b>North-America<\/b><\/font>/ ;
    $region =~ s/^EU$/<font color=#0100CA><b>Europe<\/b><\/font>/ ;
    $region =~ s/^AS$/<font color=#E10202><b>Asia<\/b><\/font>/ ;
    $region =~ s/^OC$/<font color=#02AAD4><b>Oceania<\/b><\/font>/ ;

    $population_region  = $population_region {$key} ;
    $connected_region   = $connected_region  {$key} ;
    if ($connected_region > 0 )
    { $penetration = sprintf ("%.0f", 100 * $connected_region / $population_region) .'%' ; }
    else
    { $penetration = '..' ; }

    $population_region2 = &i2KM2 ($population_region) ;
    $connected_region2  = &i2KM2 ($connected_region) ;

    $html_regions .= "<tr><th>All countries in</th>" .
                     "</td><td>$region</td>" .
                     "<td>&nbsp;</td>" .
                     "<td>$population_region2</td>" .
                     "<td>$connected_region2</td>" .
                     "<td>$penetration</td>" ;
    $html_regions .= UserAgentField( $country_total { "reg_" . $key } ) ;

    $counter = 0 ;
    foreach $browser (keys_sorted_by_value_num_desc %allcountrybrowser)
    {
       next if ($browser eq '..') ;
       next if ($counter++ > 12) ;
       $html_regions .= UserAgentFieldNew($countrybrowser { "reg_" . $key, $browser }, $false, $country_total { "reg_" . $key } * $multiplier ) ;
    }
    $html_regions .= UserAgentFieldNew($countrybrowser { "reg_" . $key, '..' }, $false, $country_total { "reg_" . $key } * $multiplier ) ;

    $html_regions .= "</tr>\n" ;

    if (($key eq 'XX') || (($key eq 'OC')))
  # if (($key eq 'S') || (($key eq 'OC')))

    { $html_regions .= "<tr><td colspan=99>&nbsp;</td></tr>" ; }
  }
  $html .= "</tbody>\n</table>" ;
# $html .= "<script type='text/javascript'>\n" .
#           "\$('#table1').tablesorter({\n" .
#           "// debug:true,\n" .
#           "headers:{0:{sorter:'nohtml'},1:{sorter:'nohtml'},2:{sorter:'nohtml'},4:{sorter:'millions'},5:{sorter:'millions'},6:{sorter:'digitsonly'},8:{sorter:'millions'},9:{sorter:'millions'},10:{sorter:'millions'},11:{sorter:'millions'},12:{sorter:'millions'},13:{sorter:'millions'},14:{sorter:'millions'},15:{sorter:'millions'},16:{sorter:'digitsonly'},17:{sorter:'millions'},19:{sorter:'millions'},20:{sorter:'millions'},21:{sorter:'millions'},22:{sorter:'millions'},23:{sorter:'millions'},24:{sorter:'millions'},25:{sorter:'millions'},26:{sorter:'millions'},27:{sorter:'millions'}});\n" .
#           "</script>\n" ;

  $html .= "<p>Edits by bots are not included." ;
  $html .= "Country meta data collected from English Wikipedia (<a href='http://en.wikipedia.org/wiki/List_of_countries_by_population'>population</a>, <a href='http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>internet users</a>)). " ;

 #$html .= &HtmlSortTableColumns; ;

  $html =~ s/TOTAL/$html_total/ ;
  $html =~ s/REGIONS/$html_regions/ ;

 #&PrintHtml ($html, "$path_reports/$file_html_per_country_overview") ;

  $html .= "</table>\n" ;
  $html .= $colophon_ae ;
  print FILE_HTML_COUNTRIES_BROWSER $html ;
  close FILE_HTML_COUNTRIES_BROWSER ;
}

sub PreviousMonth
{
  my $month = shift ;
  my $year = substr $month, 0, 4 ;
  $month = substr $month, -2 ;
  $month -= 1 ;
  if ($month == 0)
  {
    $month = 12 ;
    $year -=1 ;
  }
  $month = sprintf("%02d", $month) ;
  return "$year-$month" ;
}

sub ShowMonth
{
  my $value = shift ;
  $value =~ s/(\d{4})-01/January&nbsp;$1/ ;
  $value =~ s/(\d{4})-02/February&nbsp;$1/ ;
  $value =~ s/(\d{4})-03/March&nbsp;$1/ ;
  $value =~ s/(\d{4})-04/April&nbsp;$1/ ;
  $value =~ s/(\d{4})-05/May&nbsp;$1/ ;
  $value =~ s/(\d{4})-06/June&nbsp;$1/ ;
  $value =~ s/(\d{4})-07/July&nbsp;$1/ ;
  $value =~ s/(\d{4})-08/August&nbsp;$1/ ;
  $value =~ s/(\d{4})-09/September&nbsp;$1/ ;
  $value =~ s/(\d{4})-10/October&nbsp;$1/ ;
  $value =~ s/(\d{4})-11/November&nbsp;$1/ ;
  $value =~ s/(\d{4})-12/December&nbsp;$1/ ;
  return $value ;
}

sub UserAgentsTimedRow
{
  my $month = shift ;
  $month = &ShowMonth ($month) ;
  my $rowvalue = $countua { '.', '.', 'page', '.' } * $multiplier ;
  my $result = "<tr>" ;
  $result .= "<td class=l>$month</td>" ;
  $result .= "<td/>" ;
  $result .= &UserAgentFieldNew( $countua { 'Z', 'M', 'page', '.'} + $countua { 'Z', 'W', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'I', 'M', 'page', '.'} + $countua { 'I', 'W', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'A', 'M', 'page', '.'} + $countua { 'A', 'W', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'W', 'M', 'page', '.'} + $countua { 'W', 'W', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'T', 'M', 'page', '.'} + $countua { 'T', 'W', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'M', 'M', 'page', '.'} + $countua { 'M', 'W', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'P', 'M', 'page', '.'} + $countua { 'P', 'W', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentField( $countua { 'S', 'M', 'page', '.'} + $countua { 'S', 'W', 'page', '.'} , $false, $rowvalue ) ;
  $result .= &UserAgentFieldPerc( $countua { 'S', 'M', 'page', '.'} + $countua { 'S', 'W', 'page', '.'} , $rowvalue, $true, $false) ;
  $result .= &UserAgentFieldNew( $countua { 'N', 'M', 'page', '.'} + $countua { 'N', 'W', 'page', '.'}, $false, $rowvalue ) ;
  $result .= "<td/>" ;
  $result .= &UserAgentFieldNew( $countua { 'Z', 'M', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'I', 'M', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'A', 'M', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'W', 'M', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'T', 'M', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'M', 'M', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'P', 'M', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'S', 'M', 'page', '.'}, $false, $rowvalue ) ;
  $result .= &UserAgentFieldNew( $countua { 'N', 'M', 'page', '.'}, $false, $rowvalue ) ;
  $result .= "</tr>\n" ;
  return $result ;
}

sub WriteReportUserAgentsTimed
{
  &LogSub ("WriteReportUserAgentsTimed\n") ;

  open FILE_HTML_USERAGENTS_TIMED, '>', "$path_reports/$file_html_user_agents_timed" ;
  $html = "" ;

  $prevmonth = &PreviousMonth($reportmonth) ;
  ($prevfile = "$path_reports/$file_html_user_agents_timed") =~ s/$reportmonth/$prevmonth/ ;

  if (-e $prevfile)
  {
     my $newrow = &UserAgentsTimedRow ($reportmonth) ;
     open FILE_HTML_USERAGENTS_TIMED_OLD, '<', $prevfile ;
     while ($line = <FILE_HTML_USERAGENTS_TIMED_OLD>)
     {
        $line =~ s/<tbody>/<tbody>\n$newrow/ ;
        $line =~ s/$out_generated.*?<br>/"Updated on" . date_time_english (time) . "\n<br>"/e ;
        $html .= $line ;
     }
     close FILE_HTML_USERAGENTS_TIMED_OLD ;
  }

  else
  {
    $html = $headerwithperc ;
    $html =~ s/TITLE/Wikimedia Traffic Analysis Report - User agents temporal development/ ;
    $html =~ s/HEADER/Wikimedia Traffic Analysis Report - User agents temporal development/ ;
    $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS1<br\/>\nLINKS2<\/b>/ ;
    $html =~ s/LINKS1/&ListLinksExcept ('')/e ; 
    $html =~ s/LINKS2/&ListLinksTrendsExcept ($link_user_agents)/e ; 

    $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;
  
    &AddNoticeSurvey (12) ;

    $html .= "<p><table border=1 width=800>\n" ;
    $html .= "<thead>\n" ;

    $html .= "<tr><td class=hc rowspan=3 rowspan=1><b>Month</b></td>" .
                 "<td rowspan=3>&nbsp;</td>" .
                 "<td class=hc colspan=10><b>All pageviews</b></td>" .
                 "<td rowspan=3>&nbsp;</td>" .
                 "<td class=hc colspan=9><b>To mobile site</b></td></tr>\n" ;
    $html .= "<tr><td class=hc rowspan='2'>Total</td><td class=hc colspan='2'>Wikimedia apps</colspan><td class=hc rowspan='2'>Other apps</td><td class=hc colspan=3>mobile browsers</c><td class=hc colspan='2'>Total mobile</td><td class=hc rowspan='2'>Non-mobile</td><td class=hc rowspan='2'>Total</td><td class=hc colspan='2'>Wikimedia apps</colspan><td class=hc rowspan='2'>Other apps</td><td class=hc colspan=3>mobile browsers</c><td class=hc rowspan='2'>Total mobile</td><td class=hc rowspan='2'>Non-mobile</td></tr>\n" ;
    $html .= "<tr><td class=hc>iOS</td><td class=hc>Android</td><td class=hc>Tablets</td><td class=hc>Other</td><td class=hc>WAP</td><td class=hc>Count</td><td class=hc>Perc.</td><td class=hc>iOS</td><td class=hc>Android</td><td class=hc>Tablets</td><td class=hc>Other</td><td class=hc>WAP</td></tr>\n" ;
    $html .= "</thead><tbody>\n" ;
    $html .= &UserAgentsTimedRow ( $reportmonth ) ;
    $html .= "</tbody></table>" ;
    $html .= $colophon_ae ;
  }

  print FILE_HTML_USERAGENTS_TIMED $html ;
  close FILE_HTML_USERAGENTS_TIMED ;
}

sub BrowsersTimedRow
{
  my $month = shift ;
  my $result = "<tr>" ;
  $month = &ShowMonth ($month) ;

  foreach $key (%rawclients)
  {
    $count = $rawclients {$key} ;
    ($mobile,$group) = split (',', $key) ;
    if ($mobile eq '-')
    {
      if ($group =~ /^(MSIE|Chrome|Firefox|Safari|Opera)$/ )
      { $nonmobiletimed {$group} += $count ; }
      else
      { $nonmobiletimed {'Other'} += $count ; }
    }
    else
    {
      if ($mobile eq 'W')
      { $mobiletimed {'App'} += $count ; }
      elsif ($group =~ /^(Safari|Android|Opera|MSIE)$/ )
      { $mobiletimed {$group} += $count ; }
      else
      { $mobiletimed {'Other'} += $count ; }
    }
    $totaltimed += $count ;
  }
  my $rowvalue = $totaltimed * $multiplier ;
  $result = "<tr>" ;
  $result .= "<td class=l>$month</td>" ;
  $result .= "<td/>" ;
  $result .= &UserAgentFieldNew( $nonmobiletimed {'MSIE'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $nonmobiletimed {'Chrome'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $nonmobiletimed {'Firefox'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $nonmobiletimed {'Safari'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $nonmobiletimed {'Opera'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $nonmobiletimed {'Other'}, $false, $rowvalue) ;
  $result .= "<td/>" ;
  $result .= &UserAgentFieldNew( $mobiletimed {'Safari'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $mobiletimed {'Android'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $mobiletimed {'Opera'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $mobiletimed {'MSIE'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $mobiletimed {'App'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $mobiletimed {'Other'}, $false, $rowvalue) ;
  $result .= "</tr>" ;
  return $result ;
}

sub WriteReportBrowsersTimed
{
  &LogSub ("WriteReportBrowsersTimed\n") ;

  open FILE_HTML_BROWSERS_TIMED, '>', "$path_reports/$file_html_browsers_timed" ;
  $html = "" ;

  $prevmonth = &PreviousMonth($reportmonth) ;
  ($prevfile = "$path_reports/$file_html_browsers_timed") =~ s/$reportmonth/$prevmonth/ ;

  if (-e $prevfile)
  {
     my $newrow = &BrowsersTimedRow ($reportmonth) ;
     open FILE_HTML_BROWSERS_TIMED_OLD, '<', $prevfile ;
     while ($line = <FILE_HTML_BROWSERS_TIMED_OLD>)
     {
        $line =~ s/<tbody>/<tbody>\n$newrow/ ;
        $html .= $line ;
     }
     close FILE_HTML_BROWSERS_TIMED_OLD ;
  }

  else
  {
    $html = $headerwithperc ;
    $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Browsers temporal development/ ;
    $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Browsers temporal development/ ;
    $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS1<br\/>\nLINKS2<\/b>/ ;
    $html =~ s/LINKS1/&ListLinksExcept ('')/e ; 
    $html =~ s/LINKS2/&ListLinksTrendsExcept ($link_trends_browsers)/e ; 
    $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;
    
    &AddNoticeSurvey (13) ;

    $html .= "<p><table border=1 width=800>\n" ;
    $html .= "<thead>\n" ;

    $html .= "<tr><td class=hc rowspan=2><b>Month</b></td>" .
                 "<td rowspan=2>&nbsp;</td>" .
                 "<td class=hc colspan=6>Non-mobile</td><td rowspan=2>&nbsp;</td><td class=hc colspan=6>Mobile</td></tr>\n";
    $html .= "<tr><td class=hc>MSIE</td><td class=hc>Chrome</td><td class=hc>Firefox</td><td class=hc>Safari</td><td class=hc>Opera</td><td class=hc>Other</td><td class=hc>Safari</td><td class=hc>Android</td><td class=hc>Opera</td><td class=hc>MSIE</td><td class=hc>Apps</td><td class=hc>Other</td></tr>\n" ;
    $html .= "</thead><tbody>\n" ;
    $html .= &BrowsersTimedRow ( $reportmonth ) ;
    $html .= "</tbody></table>" ;
    $html .= $colophon_ae ;
  }

  print FILE_HTML_BROWSERS_TIMED $html ;
  close FILE_HTML_BROWSERS_TIMED ;
}


sub DevicesTimedRow
{
  my $month = shift ;
  $month = &ShowMonth ($month) ;

  &LogDetail ("Working on devices timed!\n") ;

  foreach $device (keys_sorted_by_value_num_desc %devices)
  {
    $catdevicesection { $catfordevice { $device} } += $devices { $device } ;
    $totaldevicetimed += $devices { $device} ;
  }

  my $rowvalue = $totaldevicetimed * $multiplier ;
  my $result = "<tr>" ;

  $result .= "<td class=l>$month</td>" ;
  $result .= "<td/>" ;
  $result .= &UserAgentFieldNew( $catdevicesection {'iOS'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $catdevicesection {'Android'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $catdevicesection {'Blackberry'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $catdevicesection {'Windows'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $catdevicesection {'Symbian'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $catdevicesection {'Bada'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $catdevicesection {'Playstation'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $catdevicesection {'Nintendo'}, $false, $rowvalue) ;
  $result .= &UserAgentFieldNew( $catdevicesection {'Other'}, $false, $rowvalue) ;
  $result .= "</tr>" ;

  return $result ;
}


sub WriteReportDevicesTimed
{
  &LogSub ("WriteReportDevicesTimed\n") ;

  open FILE_HTML_DEVICES_TIMED, '>', "$path_reports/$file_html_devices_timed" ;
  $html = "" ;

  $prevmonth = &PreviousMonth($reportmonth) ;
  ($prevfile = "$path_reports/$file_html_devices_timed") =~ s/$reportmonth/$prevmonth/ ;

  if (-e $prevfile)
  {
     my $newrow = &DevicesTimedRow ($reportmonth) ;
     open FILE_HTML_DEVICES_TIMED_OLD, '<', $prevfile ;
     while ($line = <FILE_HTML_DEVICES_TIMED_OLD>)
     {
        $line =~ s/<tbody>/<tbody>\n$newrow/ ;
        $html .= $line ;
     }
     close FILE_HTML_DEVICES_TIMED_OLD ;
  }

  else
  {
    $html = $headerwithperc ;
    $html =~ s/TITLE/Wikimedia Traffic Analysis Report - Devices temporal development/ ;
    $html =~ s/HEADER/Wikimedia Traffic Analysis Report - Devices temporal development/ ;
    $html =~ s/ALSO/&nbsp;Other reports:<br><b>LINKS1<br\/>\nLINKS2<\/b>/ ;
    $html =~ s/LINKS1/&ListLinksExcept ('')/e ; 
    $html =~ s/LINKS2/&ListLinksTrendsExcept ($link_trends_devices)/e ;

    $html =~ s/X1000/&rArr; <font color=#008000><b>all counts x 1000<\/b><\/font>.<br>/ ;

    $html .= "<p><table border=1 width=800>\n" ;
    $html .= "<thead>\n" ;

    $html .= "<tr><td class=hc><b>Month</b></td>" .
                 "<td>&nbsp;</td>" .
                 "<td class=hc>iOS</td><td class=hc>Android</td><td class=hc>BlackBerry</td><td class=hc>Windows Mobile</td><td class=hc>Symbian/Nokia</td><td class=hc>Bada/Samsung</td><td class=hc>Playstation</td><td class=hc>Nintendo</td><td class=hc>Other</td></tr>\n" ;
    $html .= "</thead><tbody>\n" ;
    $html .= &DevicesTimedRow ( $reportmonth ) ;
    $html .= "</tbody></table>" ;
    $html .= $colophon_ae ;
  }

  print FILE_HTML_DEVICES_TIMED $html ;
  close FILE_HTML_DEVICES_TIMED ;
}

sub WriteCsvGoogleBots
{
  &LogSub ("WriteCsvGoogleBots\n") ;

  open CSV_GOOGLE_BOTS_OUT, '>', "$path_reports/$file_csv_google_bots" ;
  print CSV_GOOGLE_BOTS_OUT "Date Time,Ip Range,Hits\n" ;
  foreach $path_process (@dirs_process)
  {
    open CSV_GOOGLE_BOTS_IN, '<', "$path_process/$file_csv_google_bots" ;
    while ($line = <CSV_GOOGLE_BOTS_IN>)
    {
      next if $line =~ /^#/ ; # comments
      next if $line =~ /^:/ ; # csv header (not a comment)

      chomp $line ;
      ($datetime,$range,$hits) = split (',', $line) ;
      ($date,$time) = split (' ', $datetime) ;
      my ($year,$month,$day) = split ('\/', $date) ;
      my $hour = substr ($time,0,2) ;
      my $datetime = "\"=DATE($year,$month,$day)+TIME($hour,0,0)\"" ;
      print CSV_GOOGLE_BOTS_OUT "$datetime,$hits,$range\n" ;
      $googlebots {$datetime} += $hits ;
    }
    close CSV_GOOGLE_BOTS_IN ;
  }
  foreach $datetime (sort keys %googlebots)
  { print CSV_GOOGLE_BOTS_OUT "$datetime,${googlebots{$datetime}},*\n" ; }
  close CSV_GOOGLE_BOTS_OUT ;
}

sub WriteCsvBrowserLanguages
{
  &LogSub ("WriteCsvBrowserLanguages\n") ;

  open CSV_BROWSER_LANGUAGES, '>', "$path_reports/$file_csv_browser_languages" ;
  print CSV_BROWSER_LANGUAGES "Browser,Languages,Hits\n" ;
  foreach $key (keys_sorted_alpha_asc %browser_languages)
  { print CSV_BROWSER_LANGUAGES "$key,${browser_languages {$key}}\n" ; }
  close CSV_BROWSER_LANGUAGES ;
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
  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/ALSO/$links/ ;
  $html =~ s/LINKS// ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_recently_start - $requests_recently_stop<\/b>/ ;
  $html =~ s/DATE// ;

  $html .= "<p>Portal is <a href='http://www.wikipedia.org'>www.wikipedia.org</a><p>\n" ;

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

    $html .= "<tr><th colspan=8 class=lh3><a id='$anchor_language' name='$anchor_language'></a><br>$language_name ($language) <small>($perc_global share of global total)</small></th></tr>" ;

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
        $bar_100 = "<img src='background.gif' width=$bar_width_100 height=15>" ;
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
  $html .= "<p><b>Share<\/b> is the percentage of requesting ip addresses (out of the global total) which originated from this country" .
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

  $html  = $header ;
  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/LINKS// ;
  $html =~ s/ALSO/$links/ ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_recently_start - $requests_recently_stop<\/b>/ ;
  $html =~ s/DATE// ;
  
  &AddNoticeSurvey (21) ;

  $html .= &HtmlSortTable ;

  $html .= "<p>Portal is <a href='http://www.wikipedia.org'>www.wikipedia.org</a>\n" ;

  $html .= "<p><table border=1 width=800 class=tablesorter id=table1>\n" ;
  $html .= "<thead>\n" ;
  $html .= "INDEX\n" ;

  $html .= &HtmlWorldMaps ;

  $html .= "<tr><td class=hr colspan=3 rowspan=1><b>Location</b></td>" .
               "<td class=hc colspan=2 rowspan=2><b>Population</b><br><small><font color=#404040>absolute count and percentage of world population</font></small></td>" . # <td class=hc rowspan=2><b>$MPVE's<br>Per<br>Person</b></td>" .
               "<td class=hc colspan=2 rowspan=2><b>Internet<br>Users</b><br><small><font color=#404040>absolute count and percentage of country population</font></small></td>" .
               "<td class=hl colspan=4 rowspan=1><b>Monthly $views_edits</b></td></tr>\n" ;
#  $html .= "<tr>" .
#             # "<td class=hc><b>${MPVE}'s<br>Per<br>I U</b></td>" .
#               "<td colspan=99 class=hc><b>Share in Global Monthly $views_edits</b><br><small><font color=#808080>red and blue bars have different scale</font></small></td></tr>\n" ;
  $html .= "<tr><td class=hr><b>Country</b></td><td class=hc><b>Region</b><br><img src='http://stats.wikimedia.org/Location_of_Continents2.gif'></td><td class=hc><b>N/S</b></td><td class=hc colspan=2><small><font color=#404040>absolute count and monthly ${views_edits}s per internet user</font></small></td><td class=hl colspan=2><small>share of global total<font color=#808080><p>note:blue and red bars have different scale</font></small></td></tr>\n" ;
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
    $perc_tot += $perc_share_total ;

    $bar = "&nbsp;" ;
    if ($perc_share_total > 0)
    { $bar = "<img src='redbar_hor.gif' width=" . (int ($perc_share_total * 10)) . " height=15>" ; }

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
    { $perc_population = "<small>$perc_population</small>" ; }

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
    { $requests_per_connected_person_tot = sprintf ("%.0f", $requests_tot / $connected_tot) ; }
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
  $html .= "Country meta data collected from English Wikipedia (<a href='http://en.wikipedia.org/wiki/List_of_countries_by_population'>population</a>, <a href='http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>internet users</a>)). " ;
# $html .= "<br>Monthly $views_edits_lc per person is calculated over total population, regardless of age and internet connectivity" ; # how come, misplaced here ?!

  $html .= &HtmlSortTableColumns; ;
  $html .= $colophon_ez ;

  $index = &HtmlIndex (join '/ ', sort (@index_countries)) ;
  $html =~ s/INDEX/$index/ ;
  $html =~ s/TOTAL/$html_total/ ;
  $html =~ s/REGIONS/$html_regions/ ;

  &PrintHtml ($html, "$path_reports/$file_html_per_country_overview") ;
}

#sub WriteReportPerCountryOverviewLine
#{
#  my ($name,$region,$hemisphere,$population,$connected,$requests) = @_ ;
#  my ($perc_requests, $perc_connected, $requests_per_connected_person) ;
#  my $html ;
#  $html = "<tr><th>$name</th></td><td>$region</td><td>$hemisphere</td><td>$requests</td>" .
#          "<td>$population</td>" . # <td>$requests_per_person_tot</td>" .
#          "<td>$connected</td><td>$perc_connected</td><td>$requests_per_connected_person</td>" .
#          "<td>$perc_requests</th><td class=l>&nbsp;</td></tr>\n" ;
#  return ($html) ;
#}

# input for http://gunn.co.nz/map/
sub WriteCsvFilePerCountryDensity
{
  my ($views_edits, $period, $ref_requests_per_period_per_country, $max_requests_per_connected_us, $desc_animation) = @_ ;

  &LogSub ("WriteCsvFilePerCountryDensity (input for input for http://gunn.co.nz/map/) $views_edits\n\n") ;

  my %requests_per_country_code = %{$ref_requests_per_period_per_country -> {$period}} ;

  my $description = $descriptions_per_period {$period} ;
  my $postfix     = $descriptions_per_period {$period} ;
# $test = join '', sort values %requests_per_country_code ;
# print $test . "\n\n" ;

  my ($link_country,$country,$code,$population,$connected,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot,$requests_max,$requests_this_country,$requests_this_country2) ;
  my (@index_countries,@csv_countries,%svg_groups,%percentage_of_total_pageviews,%requests_per_connected_persons) ;

  undef @csv_countries ;
  $header_csv_countries = "# Wikimedia Traffic Analysis Report - Wikipedia $views_edits Per Country Per Internet User\n" .
                          "# Data file is input for http://gunn.co.nz/map/\n" .
                          "# See also http://infodisiac.com/blog/2012/02/wikipedia-readers/\n" .
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

    # now use country names that are suitable for http://gunn.co.nz/map/
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

sub WriteCsvSvgFilePerCountryOverview
{
  &LogSub ("WriteCsvSvgFilePerCountryOverview\n") ;

  my ($views_edits, $period, $ref_requests_per_period_per_country_code, $max_requests_per_connected_user, $desc_animation) = @_ ;

  my %requests_per_country_code      = %{$ref_requests_per_period_per_country_code -> {$period}} ;

  my $description = $descriptions_per_period {$period} ;
  my $postfix     = $descriptions_per_period {$period} ;
# $test = join '', sort values %requests_per_country_code ;
# print $test . "\n\n" ;

  my ($link_country,$country,$code,$population,$connected,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot,$requests_max,$requests_this_country,$requests_this_country2) ;
  my (@index_countries,@csv_countries,%svg_groups,%percentage_of_total_pageviews,%requests_per_connected_persons) ;

  undef @csv_countries ;
  $header_csv_countries = "# Wikimedia Traffic Analysis Report - Wikipedia $views_edits Per Country - Overview\n" .
                          "# Report based on data from $description\n" .
                          "country,code,views,population,internet users,%connected,views per user,%global views\n" ;

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
    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;

    $requests_this_country  = ($requests_per_country_code      {$country_code} +
                               4*$requests_per_country_code_prev {$country_code}) / 5 ;
    ($requests_svg,$ratio_svg,$fill_svg) = RatioAndFillColor2 ($code, $requests_this_country,  200, $ratio_linear) ;
  }
  &WriteWorldMapSvg ("$period-1", $description) ;

  foreach $country_code (keys_sorted_by_value_num_desc %requests_per_country_code)
  {
    ($country,$code) = split ('\|', $country_code) ;
    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;

    $requests_this_country  = (2*$requests_per_country_code      {$country_code} +
                               3*$requests_per_country_code_prev {$country_code}) / 5 ;
    ($requests_svg,$ratio_svg,$fill_svg) = RatioAndFillColor2 ($code, $requests_this_country,  200, $ratio_linear) ;
  }
  &WriteWorldMapSvg ("$period-2", $description) ;

  foreach $country_code (keys_sorted_by_value_num_desc %requests_per_country_code)
  {
    ($country,$code) = split ('\|', $country_code) ;
    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;

    $requests_this_country  = (3*$requests_per_country_code      {$country_code} +
                               2*$requests_per_country_code_prev {$country_code}) / 5 ;
    ($requests_svg,$ratio_svg,$fill_svg) = RatioAndFillColor2 ($code, $requests_this_country,  200, $ratio_linear) ;
  }
  &WriteWorldMapSvg ("$period-3", $description) ;

  foreach $country_code (keys_sorted_by_value_num_desc %requests_per_country_code)
  {
    ($country,$code) = split ('\|', $country_code) ;
    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;

    $requests_this_country  = (4*$requests_per_country_code      {$country_code} +
                               $requests_per_country_code_prev {$country_code}) / 5 ;
    ($requests_svg,$ratio_svg,$fill_svg) = RatioAndFillColor2 ($code, $requests_this_country,  200, $ratio_linear) ;
  }
  &WriteWorldMapSvg ("$period-4", $description) ;


# print "$code, $country: $requests_this_country\n" ;


  foreach $country_code (keys_sorted_by_value_num_desc %requests_per_country_code)
  {
    ($country,$code) = split ('\|', $country_code) ;
    ($link_country,$icon,$population,$connected) = &CountryMetaInfo ($country) ;

# print "$code, $country: $requests_this_country\n" ;
    $requests_this_country  = $requests_per_country_code {$country_code} ;
    ($requests_svg,$ratio_svg,$fill_svg) = RatioAndFillColor2 ($code, $requests_this_country,  200, $ratio_linear) ;

next ;
    $requests_this_country  = &CorrectForMissingDays ($period, $requests_per_country_code {$country_code} * 1000, $code, "\$requests_this_country") ;

    $requests_tot += $requests_this_country ;

    $requests_per_person = ".." ;
    if ($population > 0)
    { $requests_per_person    = sprintf ("%.1f", $requests_this_country / $population) ; }

    $requests_per_connected_person = ".." ;
    if ($connected > 0)
    {
    # if ($requests_this_country / $connected >= 1.95)
    # { $requests_per_connected_person = sprintf ("%.0f", $requests_this_country / $connected) ; }
    #  else
    #  { $requests_per_connected_person = sprintf ("%.1f", $requests_this_country / $connected) ; }
      $requests_per_connected_person = sprintf ("%.1f", $requests_this_country / $connected) ;
    }

    $perc = '..' ;
    $requests_all = &CorrectForMissingDays ($period, $requests_all_per_period {$period} * 1000, $code, "\$requests_all") ;
    if ($requests_all > 0)
    { $perc = &Percentage ($requests_this_country / $requests_all) ; }
    $perc_tot += $perc ;

    $perc_connected = ".." ;
    if ($population > 0)
    { $perc_connected = sprintf ("%.1f", 100 * $connected / $population) .'%' ; }

    # now use country names that are suitable for http://gunn.co.nz/map/
    $country =~ s/Moldova, Republic of/Moldova/ ;
    $country =~ s/Korea, Republic of/South Korea/ ;
    $country =~ s/Korea, Democratic People's Republic of/North Korea/ ;
    $country =~ s/Iran, Islamic Republic of/Iran/ ;
    $country =~ s/UAE/United Arab Emirates/ ;
    $country =~ s/Congo - The Democratic Republic of the/Democratic Republic of the Congo/ ;
  # $country =~ s/^Congo$/Republic of the Congo/ ;
    $country =~ s/Syrian Arab Republic/Syria/ ;
    $country =~ s/Tanzania, United Republic of/Tanzania/ ;
    $country =~ s/Libyan Arab Jamahiriya/Libya/ ;
    $country =~ s/C..?te d'Ivoire/C&ocirc;te d'Ivoire/ ;
    $country =~ s/Serbia/republic of serbia/ ;
    $country =~ s/Lao People's Democratic Republic/Laos/ ;

  # ($requests_svg,$ratio_svg,$fill_svg) = RatioAndFillColor ($code, $requests_per_connected_person, $max_requests_per_connected_user, $ratio_sqrt) ;
    ($requests_svg,$ratio_svg,$fill_svg) = RatioAndFillColor ($code, $requests_per_person,  3, $ratio_sqrt) ;
    $ratio_svg = sprintf ("%.1f", $ratio_svg) ;
    push @csv_countries, "\"$country\",$code,$requests_this_country,$population,$connected,$perc_connected,$requests_per_connected_person,$perc,$requests_svg,$ratio_svg,$fill_svg\n" ;

    $requests_per_connected_persons {lc $code} = $requests_per_connected_person ;
    $requests_per_persons           {lc $code} = $requests_per_person ;
    $percentage_of_total_pageviews  {lc $code} = $perc ;
  }
  &WriteWorldMapSvg ("$period-5", $description) ;

  $requests_per_person_tot =  '..' ;

  if ($population_tot > 0)
  { $requests_per_person_tot = sprintf ("%.1f", $requests_tot / $population_tot) ; }

  if ($connected_tot > 0)
  { $requests_per_connected_person_tot = sprintf ("%.1f", $requests_tot / $connected_tot) ; }

  $perc_connected_tot = ".." ;
  if ($population_tot > 0)
  { $perc_connected_tot = sprintf ("%.1f", 100 * $connected_tot / $population_tot) .'%' ; }

  push @csv_countries, "world,*,$requests_tot,$population_tot,$connected_tot,$perc_connected_tot,$requests_per_connected_person_tot,100%\n" ;
  &LogDetail ("$period $requests_tot\n") ;

  $file_csv_per_country_overview2 =  $file_csv_per_country_overview ;
  $file_csv_per_country_overview2 =~ s/\.csv/-$postfix.csv/ ;
  &PrintCsv  ($header_csv_countries . join ('', sort @csv_countries), "$path_csv/svg/$file_csv_per_country_overview2") ;

#  $perc_tot = 0 ;
#  foreach $code (keys_sorted_by_value_num_desc %requests_per_connected_persons)
#  {
#    $perc     = $percentage_of_total_pageviews  {$code} ;
#    $requests = $requests_per_connected_persons {$code} ;
#    $perc =~ s/\%// ;
#    $perc_tot += $perc ;
#    print "$code $requests $perc $perc_tot\n" ;
#    if ($perc_tot > 30)
#    {
#      $requests_max = $requests ;
#      print "Max requests = $requests_max\n " ;
#      last ;
#    }
#  }

# for svg with prefined styles (InkScape only ?)
# foreach $code (keys %requests_per_connected_persons)
# {
#   $requests = $requests_per_connected_persons {$code} ;
#   if ($requests >  $max_requests_per_connected_user)
#   { $requests = $max_requests_per_connected_user ; }
#   $svg_groups {$requests} .= "." . lc ($code) . ", " ;
# }

#foreach $code (keys %requests_per_connected_persons)
#  {
#    $requests = $requests_per_connected_persons {$code} ;
#    if ($requests >  $max_requests_per_connected_user)
#    { $requests = $max_requests_per_connected_user ; }

#    $ratio = sqrt ($requests / $max_requests_per_connected_user) ;
#    if ($ratio >= 0.20)
#    {
#      $green = 180 ;
#      $red   = 180 - int (0.5 + 180 * 5/4 * ($ratio-0.20)) ;
#      $blue  = int ($green / 3) ;
#    }
#    else
#    {
#      $red   = 220 ;
#      $green = int (0.5 + 220 * 5 * $ratio) ;
#      $blue  = 0 ; #int ($green / 2) ;
#    }
#    $fill  = "\#" . sprintf ("%02x%02x%02x",$red,$green,$blue) ;
#    $fill = lc hsv2rgb($ratio*120,1,1) ;

#    $fills {$code} = $fill ;
#  }
}

sub WriteWorldMapSvg
{
  &LogSub ("WriteWorldMapSvg\n") ;

  ($period, $description) = @_ ;

  open SVG_IN, "world_map_blank_plain2.svg" ;
# open SVG_IN, "BlankMap-World6,_compact with text box.svg" ;
  @lines = <SVG_IN> ;
  close SVG_IN ;

# foreach $line (@lines)
#  { $line =~ s/COUNTRY_STYLES/$svg_text/ ; }

  ($text1,$text2) = split ' - ', $description ;
  &LogDetail ("Animation description: $description -> $text1 | $text2\n") ;

  my $lines ;

  $lines = join '', @lines ;
  $lines =~ s/<circle[^>]*?>//gs ;
  $lines =~ s/Yyyy/$text2/ ;
  $lines =~ s/Xxxx/$text1/ ;
# $lines =~ s/Zzzz/Wikipedia views per internet user/ ;
  $lines =~ s/Zzzz/$desc_animation/ ;

  $linenum = 0 ;
  @lines = split '<g', $lines ;
  foreach $line (@lines)
  {
    @lines2 = split '<path', $line ;

    ($code = $lines2 [0]) =~ s/^.*?id=\"(\w+)\".*$/$1/s ;
    $code = substr ($code,0,2) ;

    if (defined $fills {$code})
    {
      $fill = $fills {$code} ;
      $lines2 [0] =~ s/(id="$code[x-]?")(?:\s*\n\s*style="[^"]*")?/$1\n       style="fill:$fill;fill-opacity:1;stroke:#000000;stroke-width:2.5"/s ;
    }
    $linenum = 0 ;
    foreach $line2 (@lines2)
    {
      ($code = $line2) =~ s/^.*?id=\"(\w+)\".*$/$1/s ;
      $code = substr ($code,0,2) ;

      next if ! defined $fills {$code} ;
      $fill = $fills {$code} ;

      # $trace_svg = $false ;
      # if (($code eq 'ne') && ($line2 =~ /id=\"$code/i))
      # { $trace_svg = $true ; }
      # print "A " . $line2 . "\n\n" if $trace_svg ;

      next if $linenum ++ == 0 ;
      $line2 =~ s/style="[^"]*"/style="fill:$fill;fill-opacity:1;stroke:#000000;stroke-width:2.5"/s;

      # print "B " . $line2 [0] . "\n\n" if $trace_svg ;
    }
    $line = join '<path', @lines2 ;
  }
  $lines = join '<g', @lines ;

  @lines = split '<path', $lines ;
  foreach $line (@lines)
  {
    ($code = $line) =~ s/^.*?id=\"([\w-]+)\".*$/$1/s ;
    next if ! defined $requests_per_persons {$code} ;
  # print "A $line\n" ;
    $fill = $fills {$code} ;
    $line =~ s/(id="$code[x-]?")\s*\n\s*style="fill:#b9b9b9[^"]*"/$1\n      style="fill:$fill;fill-opacity:1;stroke:#000000;stroke-width:2.5"/sg ;
  # print "B $line\n" ;
  }
  $lines = join '<path', @lines ;

  # if (! defined $fills {$code}) { if ($code =~ /^.{2,3}$/) { print uc($code) . ",\"CODE NOT FOUND\"\n" ; } }

  $lines =~ s/fill:#b9b9b9;stroke:#ffffff;stroke-width:[\d\.]*/fill:#606060;stroke:#000000;stroke-width:2.5/g ;

  @lines = split ("\n", $lines) ;
  open SVG_OUT, '>', "svg/world_map_$period.svg" ;
  foreach $line (@lines)
  {
    chomp $line ;
    print SVG_OUT "$line\n" ;
  }
  close SVG_OUT ;

  &LogDetail ("Convert world_map_$period.svg to png\n") ;
  `svg/convert.exe svg/world_map_$period.svg png:svg/world_map_$period.png` ;
# print "Convert world_map_$period.svg to jpg\n" ;
# `svg/convert.exe svg/world_map_$period.svg jpg:svg/world_map_$period.jpg` ;
# print "Convert world_map_$period.svg to gif\n" ;
# `svg/convert.exe svg/world_map_$period.svg gif:svg/world_map_$period.gif` ;

#  exit ;
# exit ;
#  sleep (2) ; # until computer fan fixed
}

sub RatioAndFillColor
{
  my ($code, $requests,$requests_max, $ratio_sqrt) = @_ ;
  my ($ratio,$green,$red,$blue,$fill) ;

  if ($requests >  $requests_max)
  { $requests = $requests_max ; }

  $ratio = $requests / $requests_max ;

  if ($ratio_sqrt && ($ratio > 0))
  { $ratio = sqrt ($ratio) ; }

# if ($ratio >= 0.20)
# {
#   $green = 180 ;
#   $red   = 180 - int (0.5 + 180 * 5/4 * ($ratio-0.20)) ;
#   $blue  = int ($green / 3) ;
# }
# else
# {
#   $red   = 220 ;
#   $green = int (0.5 + 220 * 5 * $ratio) ;
#   $blue  = 0 ; #int ($green / 2) ;
# }

# $fill  = "\#" . sprintf ("%02x%02x%02x",$red,$green,$blue) ;
# $fill = lc hsv2rgb($ratio*150,0.67+$ratio*0.33,0.8-0.2*$ratio) ;
  $fill = lc hsv2rgb($ratio*120,1,1) ;

  $fills {lc $code} = $fill ;
  return ($requests,$ratio,$fill) ;
}

sub RatioAndFillColor2
{
  my ($code, $requests,$requests_max, $ratio_sqrt) = @_ ;
  my ($ratio,$green,$red,$blue,$fill,$value) ;

  if ($requests >  $requests_max)
  { $requests = $requests_max ; }

  $ratio = $requests / $requests_max ;

# if ($ratio_sqrt && ($ratio > 0))
# { $ratio = sqrt ($ratio) ; }

  if ($ratio >= 0.5)
  {
    $value = $ratio * 2 - 1 ; # 0.5 - 1 -> 0 - 1
    $fill = lc hsv2rgb(60+$value*60,0.5+$value/2,0.5+$value/2) ;
    $fill = lc hsv2rgb(120,0+$value,0.5+$value/2) ;
  }
  else
  {
    $value = 1 - $ratio * 2 ; # 0 - 0.5 -> 1 - 0
    $fill = lc hsv2rgb(60-$value*60,0.5+$value/2,0.5+$value/2) ;
    $fill = lc hsv2rgb(0,0+$value,0.5+$value/2) ;
  } # lc hsv2rgb($ratio*150,0.67+$ratio*0.33,0.8-0.2*$ratio) ; }
# print "ratio $ratio: requests $requests max requests $requests_max $fill\n" ;

  $fills {lc $code} = $fill ;
  return ($requests,$ratio,$fill) ;
}


sub WriteReportPerCountryBreakdown
{
  &LogSub ("WriteReportPerCountryBreakDown\n") ;

  my ($title,$views_edits,$links,$cutoff_requests, $cutoff_percentage, $show_logcount, $sample_rate) = @_ ;
  my ($link_country,$population,$icon,$bar,$bars,$bar_width,$perc,$perc_tot,$perc_global,$requests_tot) ;
  my ($requests_this_language, $requests_all_languages, $requests_used, $requests_other) ;
  my @index_countries ;
  my $views_edits_lc = lc $views_edits ;

  if ($sample_rate == 1) # edits
  { $report_version = '' ; }
  else
  {
    if ($show_logcount)
    { $report_version = "<p>Showing even small percentages (> $cutoff_percentage\%) (read <a href='#more'>more</a>). " .
               "Switch to <a href='$file_html_per_country_breakdown'>concise version</a>" ; }
    else
    { $report_version = "<p>Showing only only major percentages (> $cutoff_percentage\%) (read <a href='#more'>more</a>). " .
               " Switch to <a href='$file_html_per_country_breakdown_huge'>detailed version</a>" ; }
  }     

  $html  = $header ;
  $html =~ s/TITLE/$title/ ;
  $html =~ s/HEADER/$title/ ;
  $html =~ s/LINKS// ;
  $html =~ s/ALSO/$links$report_version/ ;
  $html =~ s/NOTES// ;
  $html =~ s/X1000/.&nbsp;Period <b>$requests_recently_start - $requests_recently_stop<\/b>/ ;
  $html =~ s/DATE// ;

  $html .= "<p>Portal is <a href='http://www.wikipedia.org'>www.wikipedia.org</a><p>\n" ;

  &AddNoticeSurvey (22) ;

  $html .= "<p><table border=1 width=800>INDEX\n" ;

  $html .= &HtmlWorldMaps ;

  my $anomaly_found ;

  foreach $country (keys_sorted_by_value_num_desc %requests_recently_per_country)
  {
    # Q&D fix, if condition is enabled prints just 2 countries in SquidReportPageEditsPerCountryBreakdown.htm
    # now that we returned to sampled edits

    # next if $requests_recently_per_country {$country} < $cutoff_requests ; 

    %requests_per_language = %{$requests_recently_per_country_per_language {$country}} ;
    @languages = keys_sorted_by_value_num_desc %requests_per_language ;

    $requests_this_country  = $requests_recently_per_country {$country} ;

    $perc = 'n.a.' ;
    if ($requests_recently_all > 0)
    { $perc = &Percentage ($requests_this_country / $requests_recently_all) ; }

    ($link_country,$icon,$population) = &CountryMetaInfo ($country) ;

    $html .= "<tr><th colspan=99 class=lh3><a id='$country' name='$country'></a><br>$icon $link_country <small>($perc share of global total)</small></th></tr>\n" ;

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
      $bar_width = int ($perc * 6) ;

      if (($country eq "Australia") && ($language eq "Japanese") && ($perc > 5))
      { $language .= " <b><a href='#anomaly' onclick='alert(\"Probably incorrectly assigned to this country.\\nOutdated Regional Internet Registry (RIR) administration may have caused this.\")';><font color='#FF0000'>(*)</font></a></b>" ; $anomaly_found = $true ;}

      $bar_100 = "" ;
      if ($bars++ == 0)
      {
        $bar_width_100 = 600 - $bar_width ;
        $bar_100 = "<img src='background.gif' width=$bar_width_100 height=15>" ;
      }

      if ($language !~ /Portal/)
      { $language .= " Wp" ; }

      $perc =~ s/(\.\d)0/$1/ ; # 0.10% -> 0.1%
      if ($show_logcount && ($requests_this_language < 5 * $months_recently)) # show in grey to discuss threshold on foundation-l
      { $perc = "<font color=#800000>$perc</font>" ; }

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
  $html .= "<p><a name='more' id='more'></a><b>Share<\/b> is the percentage of requesting ip addresses (out of the global total) which originated from this country" .
           "<br>&nbsp;Further percentages show per country share of $views_edits_lc per Wikipedia visited" ;
  if ($sample_rate > 1)
  { $html .= "<p><b>Countries</b> are only included if the number of requests in the period exceeds " . ($cutoff_requests * $sample_rate) . "($cutoff_requests matching records in 1:$sample_rate sampled log)" ; }
  $html .= "<p><b>Wikipedia's</b> are only listed for some country if the share of visitors for that particular country exceeds $cutoff_percentage\%." ;
  if ($show_logcount)
  {
    $html .= "<p>The second column displays the actual <b>numbers of records</b> found in the 1:$sample_rate sampled log on which the percentage is based." ;
    if ($sample_rate > 1)
    { $html .= "<br>Multiply by $sample_rate for actual $views_edits_lc over the whole period of $months_recently months." ; }
    $html .= "<br>If the number of records in the sampled log does not reach the (arbitrary) number of 5 per sampled month, the percentage is flagged dark red to extra emphasize high inaccuracy." ;
  }

  $html .= "<p>Page requests by bots are not included. Also all ip addresses that occur more than once on a given day are discarded for that day." ;
  $html .= "<br> A few false negatives are taken for granted. " .
           "Country meta data collected from <a href='http://en.wikipedia.org/wiki/List_of_countries_by_population'>English Wikipedia</a>. " .
           "Portal = <a href='http://www.wikipedia.org'>www.wikipedia.org</a>" ;
# if ($anomaly_found)
# { $html .= "<p><a id='anomaly' name='anomaly'>Probably anomaly caused by outdated <a href='http://en.wikipedia.org/wiki/Regional_Internet_Registry'>Regional Internet Registry</a> administration.\n" ; }

  $html .= $colophon_ez ;

  $index = &HtmlIndex (join '/ ', sort (@index_countries)) ;
  $html =~ s/INDEX/$index/ ;

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

  $html .= "<p>Portal is <a href='http://www.wikipedia.org'>www.wikipedia.org</a><p>\n" ;

  &AddNoticeSurvey (24) ;

  $html .= "<p><table border=1 width=800>INDEX\n" ;

  $html .= &HtmlWorldMaps ;

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
  $html .= "<p><b>Share<\/b> is the percentage of requesting ip addresses (out of the global total) which originated from this country" .
           "<br>&nbsp;Further percentages show per country per quarter share of $views_edits_lc per Wikipedia visited" ;
  $html .= "<p>Countries are only included if the number of requests in the period exceeds 100,000 (100 matching records in 1:1000 sampled log)" ;
  $html .= "<br>Page requests by bots are not included. Also all ip addresses that occur more than once on a given day are discarded for that day." ;
  $html .= "<br> A few false negatives are taken for granted. " .
           "Country meta data collected from <a href='http://en.wikipedia.org/wiki/List_of_countries_by_population'>English Wikipedia</a>. " .
           "Portal = <a href='http://www.wikipedia.org'>www.wikipedia.org</a>" ;
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

sub FormatCount
{
  my $count = shift ;
  if ($count eq "")
  { return ("0") ; }
  if ($count < 1)
  { return ("1") ; }
  $count =~ s/^(\d{1,3})(\d\d\d)$/$1,$2/ ;
  $count =~ s/^(\d{1,3})(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
  $count =~ s/^(\d{1,3})(\d\d\d)(\d\d\d)(\d\d\d)$/$1,$2,$3,$4/ ;
  return ($count) ;
}

sub ShowPerc
{
  my ($num,$color) = @_ ;
  $num =~ s/,//g ;
  $num = sprintf("%.2f", $num) ;

  if ($color eq '')
  { return ("$num\%") ; }
  else
  { return ("<font color=$color>$num\%</font>") ; }
}


sub ShowCount
{
  my ($num,$color,$percbase) = @_ ;
  $num =~ s/,//g ;

  if (($num eq '&nbsp;') || ($num == 0))# to do: remove &nbsp;'s from perl code, send 0 instead, formatting in javascript
  { $num = '-' ; }
  else
  {
    my $percentage = '' ;
    if ($percbase ne '')
    {
      $percentage = &ShowPerc(100 * $num / $percbase) ;
    }

    if ($num =~ /^[\d\.]+$/) # numeric string
    { $num = ceil( 1000 * $num - 0.5) ; }

    if ($num =~ /\D/) # contains non-digit ? enclose in double quotes
    { $num ="\"$num\"" ; }

    $num = "<script>showCount($num, '$percentage');</script>" ;
  }

  if ($color eq '')
  { return ($num) ; }
  else
  { return ("<font color=$color>$num</font>") ; }
}

sub ShowCountTd
{
  my ($num,$color,$percbase) = @_ ;

  return ("<td class=r>" . &ShowCount ($num,$color,$percbase) . "</td>") ;
}

sub ShowCountTh
{
  my ($num,$color,$percbase) = @_ ;
  $num = &ShowCountTd ($num,$color,$percbase) ;
  $num =~ s/td/th/g ;
  return ($num) ;
}


sub SortMime
{
  my $mime = shift ;
  if ($mime eq "text/html")
  { return (2000000000 + $mimetypes {$mime}) ; }
  elsif ($mime =~ /image\/(?:png|jpeg|gif)/)
  { return (1000000000 + $mimetypes {$mime}) ; }
  else
  { return ($mimetypes {$mime}) ; }
}

sub ExpandAbbreviation
{
  my $text = shift ;
  # reverse (more or less) abbreviations
  $text =~ s/^[\@\*]// ;
  $text =~ s/^xx:upload/upload:&nbsp;/;
  $text =~ s/^wb:/wikibooks:/;
  $text =~ s/^wk:/wiktionary:/;
  $text =~ s/^wn:/wikinews:/;
  $text =~ s/^wp:/wikipedia:/;
  $text =~ s/^wq:/wikiquote:/;
  $text =~ s/^ws:/wikisource:/;
  $text =~ s/^wv:/wikiversity:/;
  $text =~ s/^wx:/wikispecial:/;
  $text =~ s/^mw:/wikispecial:/; # eg bugzilla
  $text =~ s/:!mw/:mediawiki/;
  $text =~ s/^wm:/wikimedia:/;
  $text =~ s/:wm$/:wikimedia/;
  $text =~ s/^wmf:/foundation:/;
  $text =~ s/:www$/:portal/;
# $text =~ s/^wikispecial:(.*)$/$1:&nbsp;/;
  return ($text) ;
}

sub GetSecondaryDomain
{
  $pattern_url_post = "\\.(?:biz|com|info|name|net|org|pro|aero|asia|cat|coop|edu|gov|int|jobs|mil|mobi|museum|tel|travel|arpa|[a-zA-Z0-9-]{2}|(?:com?|ne)\\.[a-zA-Z0-9-]{2})\$" ;

  my $domain = shift ;
  $domain =~ s/http:\/\/// ;
  $domain =~ s/\/.*$// ;

  if ($domain !~ /\./)
  { return ($domain) ; }

  $domain =~ s/$pattern_url_post// ;
  $domain =~ s/^.*?\.([^\.]+)$/$1/ ;
  return ($domain) ;
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
    $out_urls {$key} =~ s/(^[^\s]+).*$/$1/ ;
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
  $out_million  = 'M' ;
  $out_thousand = 'K' ;

  my $v = shift ;

  if ($v == 0)
  { return ("&nbsp;") ; }
  if ($v >= 100000000)
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

  $verbose = $false ;
  if ($verbose)
  { $html =~ s/\[([^\]]*)\]/$1/g ; }
  else
  { $html =~ s/\[([^\]]*)\]//g ; }

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

<style type='text/css'>
<!--
body  {font-family:arial,sans-serif; font-size:12px }
h2    {margin:0px 0px 3px 0px; font-size:18px}
table {font-size:12px ;}
td    {white-space:wrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:middle}

td.hl  {text-align:left;vertical-align:top;}
td.hr  {text-align:right;vertical-align:top;}
td.hc  {text-align:center;vertical-align:top;}
td.r   {text-align:right;  border: inset 1px #FFFFFF}
td.c   {text-align:center; border: inset 1px #FFFFFF}
td.l   {text-align:left;   border: inset 1px #FFFFFF}
td.lt  {text-align:left;   border: inset 1px #FFFFFF ; vertical-align:top}
td.rt  {text-align:right;  border: inset 1px #FFFFFF ; vertical-align:top}

th       {white-space:nowrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:12px ; vertical-align:top ; font-width:bold}
th.small {white-space:wrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px ; font-size:11px ; vertical-align:top ; font-width:bold}
th.c     {text-align:center; border: inset 1px #FFFFFF}
th.l     {text-align:left;   border: inset 1px #FFFFFF}
th.r     {text-align:right;  border: inset 1px #FFFFFF}
th.lh3   {text-align:left;   border: inset 1px #FFFFFF ; font-size:14px}

a:link { color:blue;text-decoration:none;}
a:visited {color:#0000FF;text-decoration:none;}
a:active  {color:#0000FF;text-decoration:none;}
a:hover   {color:#FF00FF;text-decoration:underline}
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

    element = document.getElementById ('form_show_perc');

    if (checked == 'true')
    { element.checked = true ; show_percentage = true ; }
    else
    { element.checked = false ; show_percentage = false ; }

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

  if (count == 0)
  { count = '-' ; }

  else if (show_count_daily)
  { ; }
  else if (show_count_monthly_normalized)
  { count *= 30 ; }
  else if (show_count_monthly_raw)
  { count *= $days_in_month ; }

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

  <input type='button' value=' Archive ' onclick='window.location=\"http://stats.wikimedia.org/archive/squid_reports\"'>
  <input type='button' value=' Wikimedia Statistics ' onclick='window.location=\"http://stats.wikimedia.org\"'>
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
<tr><td class=l colspan=99><span id='index' style="display:none">\n$index\n</span></td></tr>
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

sub hsv_to_rgb {

   my $h = shift;
   my $s = shift;
   my $v = shift;

   # limit this to h values between 0 and 360 and s/v values
   # between 0 and 1

   unless (defined($h) && defined($s) && defined($v) &&
          $h >= 0 && $s >= 0 && $v >= 0 &&
          $h <= 360 && $s <= 1 && $v <= 1) {
     return (undef, undef, undef);
   }

   my $r;
   my $g;
   my $b;

   # 0.003 is less than 1/255; use this to make the floating point
   # approximation of zero, since the resulting rgb values will
   # normally be used as integers between 0 and 255.  Feel free to
   # change this approximation of zero to something else, if this
   # suits you.

   if ($s < 0.003) {
     $r = $g = $b = $v;
   }
   else {

     $h /= 60;
     my $sector = int($h);
     my $fraction = $h - $sector;

     my $p = $v * (1 - $s);
     my $q = $v * (1 - ($s * $fraction));
     my $t = $v * (1 - ($s * (1 - $fraction)));

        if ($sector == 0) { $r = $v; $g = $t; $b = $p; }
     elsif ($sector == 1) { $r = $q; $g = $v; $b = $p; }
     elsif ($sector == 2) { $r = $p; $g = $v; $b = $t; }
     elsif ($sector == 3) { $r = $p; $g = $q; $b = $v; }
     elsif ($sector == 4) { $r = $t; $g = $p; $b = $v; }
     else                 { $r = $v; $g = $p; $b = $q; }
   }

   # Convert the r/g/b values to all be between 0 and 255; use the
   # ol' 0.003 approximation again, with the same comment as above.

   $r = ($r < 0.003 ? 0.0 : $r * 255);
   $g = ($g < 0.003 ? 0.0 : $g * 255);
   $b = ($b < 0.003 ? 0.0 : $b * 255);

   return ($r, $g, $b);
 }

sub hsv2rgb
{
  my ($h,$s,$v) = @_;
  my ($p,$q) ;
  ($v,$p,$q) = hsv_to_rgb ($h,$s,$v) ;
  my $color = "\#" . sprintf ("%02X", int($v)) . sprintf ("%02X", int($p)) . sprintf ("%02X", int($q)) ;
  return ($color) ;
}

sub HtmlWorldMaps
{
my $html_worldmaps = <<__HTML_WORLD_MAPS__ ;
<tr><td colspan=99 align=center>
<table width='100%' align=center><td align=left>
<small>
<img src='http://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/World_population.PNG/400px-World_population.PNG' border='1'>
<br><a href='http://en.wikipedia.org/wiki/List_of_countries_by_population'>Countries by population</a> - English Wikipedia
</small>
</td><td>
<small>
<img src='http://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Internet_Penetration.png/400px-Internet_Penetration.png' border='1'>
<br><a href='http://en.wikipedia.org/wiki/List_of_countries_by_number_of_Internet_users'>Internet penetration</a> (% of population) - English Wikipedia
</small>
</td></tr>
<tr><td>
<small>
<img src='http://upload.wikimedia.org/wikipedia/commons/thumb/4/46/North_South_divide.svg/400px-North_South_divide.svg.png' border='1'>
<br><a href='http://en.wikipedia.org/wiki/North-South_divide'>Global North South</a> - English Wikipedia
</small>
</td></tr>
</table>
</td></tr>
__HTML_WORLD_MAPS__

return $html_worldmaps ;
}

# yeah, changing a global yet again
sub AddNoticeSurvey
{
  my $report_id = shift ;

# $html .= "<font color=#F00><b><big>Aug 2015: This report has been discontinued until further notice, due to lack of maintenance.</big></font><br><font color=#A00>Only some of the Wikistats traffic reports will be migrated to Wikimedia Foundation's new hadoop-based infrastructure. See them <a target='_blank' href='https://analytics.wikimedia.org/dashboards/browsers/'>here</a>.<br>If you want this particular report included in the migration <a href='https://www.mediawiki.org/w/index.php?title=Analytics/Wikistats/TrafficReports/Future_per_report_B2'>let us know</a> (id for this report is '$report_id').<br>Read more <a href='https://www.mediawiki.org/wiki/Analytics/Wikistats/TrafficReports/Future'>here</a>.</b></font><br>&nbsp;<br>" ;
if (($quarter_only ne '') && ($quarter_only lt "2015 Q2"))
{
  $html .= "<font color=#080><b><big>Feb 2016: This report has been upgraded, and does now include mobile views. But still is based on pre-hadoop data stream (squid logs)</big></b></font>" ;
}    
else 
{ 
  $html .= "<font color=#080><b><big>Feb 2016: This report has been upgraded, and is now based on Wikimedia Foundations's new hadoop-based infrastructure.<br>Earlier versions of this report have been republished with new data, starting May 2015. Thanks so much for your patience!<p>" . 
           "Mar 2016: Non-regional Wikistats traffic reports which were marked by users in <a href='https://www.mediawiki.org/wiki/Analytics/Wikistats/TrafficReports/Future_per_report_B2'>this survey</a> as particularly valuable<br>
have also been migrated to Wikimedia Foundation's new hadoop-based infrastructure. See <a href='https://analytics.wikimedia.org/dashboards/browsers/#all-sites-by-os'>here</a></big></b></font><br>&nbsp;<br>" ;  
}    
#if ($report_id > 20)
#{
# $html .= "<p><font color=#A00><b><big>Aug 2015: Warning, data are unreliable!</big><p>Wikistats traffic reports with a breakdown by geography (like this one) are currently unreliable and for some countries totally wrong. Please ignore data until further notice. We are investigating. Our apologies for any inconvenience caused.</b></font><p>" ; 
#}

}
