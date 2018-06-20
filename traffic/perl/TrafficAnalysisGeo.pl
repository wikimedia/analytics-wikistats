#!/usr/bin/perl

# restructure along the lines of 
# ref http://www.explainingprogress.com/wp-content/uploads/datamaps/uploaded_gdpPerCapita2011_PWTrgdpe/gdpPerCapita2011_PWTrgdpe.html
# https://ourworldindata.org/

# cd /srv/stats.wikimedia.org/htdocs/archive/squid_reports/2016-06/draft	

# scaling iframe http://jsfiddle.net/Masau/7WRHM/

# derived from stat1005:../perl/SquidReportArchive.pl
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
# hsv2rgb
# hsv_to_rgb
# isMobile

# 2016-07-18 minus
# CalcPercentages 
# HtmlFormWithPerc
# also
# InitProjectNames -> ReadLanguageInfo (read from file instead of long inline hash file)

# 2016-08-09 minus
# ReadInputCountriesDaily
# ReadDate

# 2018-04 csv_shorten_demographics: no longer shorten demographics for csv files (still do for html files)  
# csv files are now also post processed into json file, which could benefit from more detailed figures
# so for WiViVi shortening needs to be done in javascript 
# for request data (= page views) shortening still provides some fuzziness on purpose 

  $| = 1; # Flush output

  use lib "/home/ezachte/wikistats/traffic/perl" ; # hmm Q&A fix, on stat1002 no hard coded path was needed (?)
  use SquidReportArchiveConfig ;

  use JSON ;

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $false ;
  ez_lib_version (2) ;

  use TrafficAnalysisGeoDataIn ;
  use TrafficAnalysisGeoDataOut ;
  use TrafficAnalysisGeoHtml ;

  $path_upload    = "//upload.wikimedia.org/wikipedia/commons/thumb" ; 

  $label_fill_region   = "<font color=#66F>region</font>" ;
  $label_fill_language = "<font color=#A0A>language</font>" ;

  default_argv ($cfg_default_argv) ;

  use Time::Local ;
  use Cwd;

  $data_for_yyyymm = '2018-04';

  $ratio_sqrt   = $true ;
  $ratio_linear = $false ;

  getopt ("dmaqiolxb", \%options) ;

  undef %country_code_not_specified_reported ;

  $path_csv       = $options {"i"} ;
  $path_reports   = $options {"o"} ;
  $path_log       = $options {"l"} ;
  $path_meta      = $options {"a"} ; # m already taken, a for 'about' ~ 'meta'
  $file_worldbank = $options {"b"} ; # json file data from world bank
  $sample_rate    = $options {"x"} ;

  $file_csv_geocodes = "GeoInfo.csv" ;

  print "sample rate $sample_rate\n" ;

  die ("Specify input folder as -i [..]")   if not defined $path_csv ;
  die ("Specify output folder as -i [..]")  if not defined $path_reports ;
  die ("Specify log folder as -i [..]")     if not defined $path_log ;
  die ("Specify meta folder as -a [..]")    if not defined $path_meta ;
  die ("Specify sample rate -x [..]")       if not defined $sample_rate ;

  die ("Input folder not found")                       if ! -d $path_csv ;
  die ("Output folder not found")                      if ! -d $path_reports ;
  die ("Log folder not found")                         if ! -d $path_log ;
  die ("Meta folder not found")                        if ! -d $path_meta ;
  die ("World Bank data not found: '$file_worldbank'") if ! -e $file_worldbank ;

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
  $perc2bar  = 6 ; # 1.5 ; # one perc is x pixel
  $perc2bar2 = 6 ; # 1.5 ; # one perc is x pixel

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

  if ($quarter_only ne '')   { $path_reports = "$path_reports/$quarter_only" ; }
  elsif ($reportmonth ne '') { $path_reports = "$path_reports/$reportmonth" ; }
  elsif ($reportcountries)   { $path_reports = "$path_reports/countries" ; }

  &LogDetail ("Write report to $path_reports\n") ;

  if (! $os_windows)
  { $path_reports =~ s/ /-/g ; }

  if (! -d $path_reports)
  {
  #  print "mkdir $path_reports\n" ;
    mkdir ($path_reports) || die "Unable to create directory $path_reports\n" ;
  }

  &ReadWorldBankDemographics ($file_worldbank) ;

  &ReadLanguageInfo ;

# &ReadInputRegionCodes ;
# &ReadCountryCodesISO3 ;
# &ReadInputCountryNames ;
# &ReadInputCountryInfo ;
# # &ReadCountryCodes ;
# &WriteCsvGeoInfo ; # one time: merge these csv input files into one csv file, henceforth to be maintained manually

  &ReadCsvGeoInfo ; # from now on use this more complete csv file
exit ;

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





  &WriteCsvDataMapInfoPerCountry ($title, $views_edits, &UnLink ($links,$offset_links+2),$cutoff_requests =  10, 
                                  $cutoff_percentage = 0.1, $show_logcount = $true,  $sample_rate) ;
  &WriteCsvDataMapInfoPerRegion   ($sample_rate) ;
  &WriteCsvDataMapInfoPerLanguage ($sample_rate) ;

  # input for http://gunn.co.nz/map/, for now hardcoded quarter
  &WriteCsvFilePerCountryDensity ($views_edits, '2013 Q2', \%requests_per_quarter_per_country, 
                                  $max_requests_per_connected_us_month, "Wikipedia " . lc $views_edits . " per person", 
                                  $sample_rate) ;

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
    &WriteReportPerCountryBreakdown ($title, $views_edits, &UnLink ($links,$offset_links+2),$cutoff_requests = 100, 
                                     $cutoff_percentage = 1, $show_logcount = $false, $sample_rate) ;
    &WriteReportPerCountryBreakdown ($title, $views_edits, &UnLink ($links,$offset_links+2),$cutoff_requests =  10, 
                                     $cutoff_percentage = 0.1, $show_logcount = $true, $sample_rate) ;
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

sub OpenLog
{
  open "FILE_LOG", ">>", "$path_log/$file_log" || abort ("Log file '$file_log' could not be opened.") ;
  &LogDetail ("\n\n===== Wikimedia Sampled Visitors Log Report / " . date_time_english (time) . " =====\n\n") ;
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

sub Perc2Bar 
{
  my ($perc,$color,$height) = @_ ;
  my  $bar = "&nbsp;" ;

  $perc =~ s/\%// ;
  my $width = int ($perc * $perc2bar) ;    
# my $width = int ($perc_share_total * $perc2bar) ;    
  if ($perc > 0)
  { $bar  = "<img src='${color}bar.gif' width=$width height=$height>" ; }

  return ($bar) ;
}

# format: function(s) { return $.tablesorter.formatFloat(s.replace(/<[^>]*>/g,"").replace(/\\&nbsp\\;/g,"").replace(/M/i,"000000").replace(/&#1052;/,"000000").replace(/K/i,"000").replace(/&#1050;/i,"000")); },


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

