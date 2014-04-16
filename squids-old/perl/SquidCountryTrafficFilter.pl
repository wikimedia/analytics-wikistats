#!/usr/bin/perl

# About RegionCodes.csv:
# Global North as defined by Sue for strategic plan:  Australia, Canada, Israel, Hong Kong, Macau, New Zealand, Japan, Singapore, South Korea, Taiwan, the United States and all of Europe (including Russia)
# Global South Asia (with the exception of Japan, Hong Kong,Macau, Singapore, South Korea and Taiwan),Central America, South America, Mexico, Africa, and the Middle East(with the exception of Israel).
#
# Global South - Catalyst (not used here) Adopted from the UN classifications of "developing countries;" see notes for variances. http://www.itu.int/ITU-D/ict/definitions/regions/index.html
# As defined by the WM strategic plan, focusing on Brazil, India, and Arab States (see http://www.itu.int/ITU-D/ict/definitions/regions/index.html for Arab States)
#
# see also Google Doc: https://docs.google.com/a/wikimedia.org/spreadsheet/ccc?key=0Au8PHt8_RuNedENfdVJtS19INHE4VjZTLTVrVFhRblE&pli=1#gid=1

# input expected as "yyyy-mm-dd,project code,language code,country code,bot flag,count", e.g. "2009-07-05,wb,fr,US,B,23"
# local test args: -w -c 1000 -i "csv/SquidDataVisitsPerCountryDaily.csv" -o "csv/DailyVisitsPerCountryFiltered.csv" -f "csv/DailyVisitsPerCountryFilter.txt" -l "visits" -m "csv/meta"

  use Time::Local ;
  use Getopt::Std ;

  use lib '..' ;
  use SquidReportGeoData ;

  $false = 0 ;
  $true  = 1 ;

# $min_yyyymmdd = '2011-10-01' ; # uncomment for tests
# $max_yyyymmdd = '2011-12-31' ; # uncomment for tests

  $min_yyyymmdd = '2011-07-01' ; # uncomment for tests
  $max_yyyymmdd = '2011-07-31' ; # uncomment for tests

  if ($min_yyyymmdd eq '')
  { $min_yyyymmdd = '2000-01-01' ; }
  if ($max_yyyymmdd eq '')
  { $max_yyyymmdd = '2100-12-31' ; }
  print "Period: $min_yyyymmdd - $max_yyyymmdd\n" ;

  my %options ;
  getopt ("iolmfcr", \%options) ;

  my (%visits_monthly, %visits_daily, %visits_per_project, %visits_per_language, %visits_per_country, %visits_per_day) ;
  my (%visits_per_proj_lang_country_req_site, %yyyymmdd_found) ;
  my ($visits_total, $visits_per_day, $visits_other) ;

  $file_input     = $options {"i"} ;
  $file_output    = $options {"o"} ;
  $file_filter    = $options {"f"} ;
  $path_meta      = $options {"m"} ; # country/region meta data
  $data_label     = lc ($options {"l"}) ;
  $max_columns    = $options {"c"} ;
  $min_fraction   = $options {"r"} ;
  $weekly         = defined ($options {"w"}) ;
  $bad_data_days  = defined ($options {"b"}) ;
  $percentages    = defined ($options {"p"}) ;

  if ($file_input  eq '') { die "\nError: specify input file as -i [path]" ; }
  if ($file_output eq '') { die "\nError: specify output file as -o [path]" ; }
  if ($file_filter eq '') { die "\nError: specify filter file as -f [path]" ; }
  if ($path_meta   eq '') { die "\nError: specify path for meta data as -m [path]" ; }

  if ($data_label  eq '') { die "\nError: specify data label as -l [visits|edits]" ; }
  if ($data_label !~ /^(?:visits|edits)$/) { die "\nError: specify data label as -l [visits|edits], not '$data_label'" ; }

  if ($max_columns eq '')
  {
    $max_columns = 1000 ;
    print "No max number of columns specified (with -c [nnn]), assume default $max_columns\n\n" ;
  }
  elsif ($max_columns !~ /^\d+$/) { die ("\nError: specify max columns as -c [nnn]") ; }
  elsif ($max_columns < 1) { die ("\nError: specify max columns as -c [nnn], nnn as positive integer") ; }

  if ($min_ratio eq '')
  {
    $min_ratio = 0.0002 ;
    print "No min ratio specified (threshold for total count per column), assume $min_ratio\n\n" ;
  }
  elsif ($min_ratio !~ /^0\.0+\d+$/) { die ("\nError: specify min ratio as -r [0.nnn]") ; }
  elsif ($min_ratio > 1) { die ("\nError: specify min ratio as -r [0.nnn], 0.nnn as positive number <= 1") ; }

  &ReadFilter   ($file_filter) ;

  &ReadCountryNames ("$path_meta/CountryCodes.csv") ;
  &ReadRegionCodes  ("$path_meta/RegionCodes.csv") ;
  &PrintListOfGlobalNorthSouth ;

  &ReadInput    ($file_input) ;
  &WriteOutput  ($file_output, $data_label) ;

  print "\n\nReady\n\n" ;

  exit ;

sub ReadFilter
{
  my ($file_filter) = @_ ;

  if (! -e $file_filter) { die "\nError: filter file '$file_filter' not found!" ; }

  open CSV_FILTER, '<', $file_filter || die ("\nError: filter file $file_filter could not be opened!") ;

  $do_filter_countries  = $false ;
  $do_filter_languages  = $false ;
  $do_filter_projects   = $false ;
  $do_filter_requesters = $false ;
  $do_filter_sites      = $false ;

  $do_total_regions     = $false ;
  $do_total_countries   = $false ;
  $do_total_languages   = $false ;
  $do_total_projects    = $false ;
  $do_total_requesters  = $false ;
  $do_total_sites       = $false ;

  my $lines = 0 ;
  while ($line = <CSV_FILTER>)
  {
    $lines++ ;
    next if $line =~ /^#/ ;

    if ($line !~ /^[^=]+=[^=]+$/) { die ("\nError: invalid line $lines in filter file '$file_filter':\n" .
                                         "Use format '[projects|countries|languages|requester] = value1[,value2]..' instead of:\n\n" .
                                         "'$line'\n") ; }

    $line =~ s/\s//g ;
    $line =~ s/,$//g ;

    # if a filter is specified from some metric columns with totals will be added implicitly
    if ($line =~ /total[s]=/i)
    {
      $line =~ s/#.*$// ; # remove comments
      $line =~ s/.*?=// ;
      @total_metrics = split (',', lc ($line)) ;
      $line_total_metrics = 'Add totals for: ' ;
      foreach $metric (@total_metrics)
      {
        $line_total_metrics .= "$metric," ;
           if ($metric =~ 'project')          { $do_total_projects   = $true ; }
        elsif ($metric =~ 'language')         { $do_total_languages  = $true ; }
        elsif ($metric =~ 'region')           { $do_total_regions    = $true ; }
        elsif ($metric =~ 'countr(?:y|ies)')  { $do_total_countries  = $true ; }
        elsif ($metric =~ 'requester')        { $do_total_requesters = $true ; }
        elsif ($metric =~ 'site')             { $do_total_sites      = $true ; }
        else { die ("\nError in filter file: '$metric' is not a valid metric, choose from projects|languages|countries|requesters|sites\n") ; }
      }
      $line_total_metrics =~ s/,$// ;
      print "$line_total_metrics\n" ;
    }

    elsif ($line =~ /(?:country|countries)=/i)
    {
      $line =~ s/.*?=// ;
      @filter_countries = split (',', uc ($line)) ;
      $line_filter_countries = 'Include countries: ' ;
      foreach $country (@filter_countries)
      {
        $do_filter_countries = $true ;
        $filter_countries {$country}++ ;
        $line_filter_countries .= "$country," ;
      }
      $line_filter_countries =~ s/,$// ;
      if ($line_filter_countries =~ /,/)
      { $do_total_countries = $true ; }
      print "$line_filter_countries\n" ;
    }

    elsif ($line =~ /language[s]?=/i)
    {
      $line =~ s/.*?=// ;
      @filter_languages = split (',', lc ($line)) ;
      $line_filter_languages = 'Include languages: ' ;
      foreach $language (@filter_languages)
      {
        $do_filter_languages = $true ;
        $filter_languages {$language}++ ;
        $line_filter_languages .= "$language," ;
      }
      $line_filter_languages =~ s/,$// ;
      if ($line_filter_languages =~ /,/)
      { $do_total_languages = $true ; }
      print "$line_filter_languages\n" ;
    }

    elsif ($line =~ /project[s]?=/i)
    {
      $line =~ s/.*?=// ;
      @filter_projects = split (',', lc ($line)) ;
      $line_filter_projects = 'Include projects: ' ;
      foreach $project (@filter_projects)
      {
        $do_filter_projects  = $true ;
        if ($project !~ /^(?:wb|wk|wn|wp|wq|ws|wv|wx|wm|wmf|xx|other)$/) { die ("\nError in filter file: '$project' is not a valid project code, choose from wb|wk|wn|wp|wq|ws|wv|wx|wm|wmf|xx|other\n") ; }
        $filter_projects {$project}++ ;
        $line_filter_projects .= "$project," ;
      }
      $line_filter_projects =~ s/,$// ;
      if ($line_filter_projects =~ /,/)
      { $do_total_projects = $true ; }
      print "$line_filter_projects\n" ;
    }

    elsif ($line =~ /requester[s]?=/i)
    {
      $line =~ s/.*?=// ;
      @filter_requesters = split (',', lc ($line)) ;
      $line_filter_requesters = 'Include requesters: ' ;
      foreach $requester (@filter_requesters)
      {
        $do_filter_requesters  = $true ;
        if ($requester !~ /^(?:bot|user)$/) { die ("\nError in filter file: '$requester' is not a valid requester code, choose from bot|user\n") ; }
        $filter_requesters {$requester}++ ;
        $line_filter_requesters .= "$requester," ;
      }
      $line_filter_requesters =~ s/,$// ;
      if ($line_filter_requesters =~ /,/)
      { $do_total_requesters = $true ; }
      print "$line_filter_requesters\n" ;
    }

    elsif ($line =~ /site[s]?=/i)
    {
      $line =~ s/.*?=// ;
      @filter_sites = split (',', lc ($line)) ;
      $line_filter_sites = 'Include sites: ' ;
      foreach $site (@filter_sites)
      {
        $do_filter_sites  = $true ;
        if ($site !~ /^(?:main|mobile)$/) { die ("\nError in filter file: '$site' is not a valid site code, choose from main|mobile\n") ; }
        $filter_sites {$site}++ ;
        $line_filter_sites .= "$site," ;
      }
      @filter_sites = keys %filter_sites ;
      $line_filter_sites =~ s/,$// ;
      if ($line_filter_sites =~ /,/)
      { $do_total_sites = $true ; }
      print "$line_filter_sites\n" ;
    }

    else
    {
      ($keyword = $line) =~ s/=.*$// ;
      die ("\nError: invalid line $lines in filter file '$file_filter':\nUnrecognized keyword: '$keyword'") ;
    }

  }
  print "\n" ;
  close CSV_FILTER ;

  if ($do_total_regions && $do_filter_regions)
  {
    $do_filter_regions = $false ;
    print "Show totals per region always show both main and mobile sites\n" ;
  }
}

sub ReadInput
{
  my ($file_input) = @_ ;

  my ($yyyymmdd, $yyyymm) ;
  my ($project,$language,$country,$proj_lang_country_req_site,$proj_lang_country_req_site2,$requester,$wiki) ;
  my ($day,$month,$year,$days_in_month) ;
  my ($dir,$file,$line) ;
  my ($total, $correction, $total_corrected, $total_corrected_share) ;

  if (! -e $file_input) { die "\nError: input file '$file_input' not found!" ; }

  $filesize_in = -s $file_input ;

  open CSV_IN,  '<', $file_input  || die ("\nError: input file '$file_input' could not be opened!") ;

  my $lines ;
  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;
    $lines++ ;

    if ($lines % 100000 == 0)
    {
      $lines2 = $lines ;
      $lines2 =~ s/(.*?\d)(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
      $lines2 =~ s/(.*?\d)(\d\d\d)$/$1,$2/ ;
      print "Date $yyyymmdd, $lines2 lines read\n" ;
    }

    last if $max_lines > 0 and $lines > $max_lines ;

    chomp $line ;

    ($yyyymmdd,$project,$language,$country,$requester,$count) = split (',', $line) ;

    if ($bad_data_days)
    {
      if ($do_total_regions or $do_total_countries)
      {
        next if $yyyymmdd lt '2010-01-01' ;     # too much country 'Unknown'
        if (! $percentages)
        { next if $yyyymmdd le '2010-07-21' ; } # server overload -> absolute numbers too low
      }
      else
      { next if $yyyymmdd ge '2009-11-15' and $yyyymmdd le '2010-07-21' ; } # server overload

      next if $yyyymmdd ge '2011-11-01' and $yyyymmdd le '2011-11-15' ; # server overload
      next if $yyyymmdd ge '2012-07-02' and $yyyymmdd le '2012-07-02' ; # major dip, cause unknown
    }

    next if $yyyymmdd lt '2009-07-01' ; # nice start date for monthly/quarterly grid in Excel
    next if $yyyymmdd lt $min_yyyymmdd ;
    last if $yyyymmdd gt $max_yyyymmdd ;

    if ($weekly) # store whole week on Sunday
    {
      my $weekday = &GetWeekDay ($yyyymmdd) ;
      ($dd,$mm,$yyyy)  = (gmtime (&GetDateAsSeconds ($yyyymmdd) - 24 * 60 * 60 * $weekday)) [3,4,5] ;
      $yyyymmdd = sprintf ("%4d-%02d-%02d", $yyyy+1900,$mm+1,$dd) ;
      if ($days_found {$yyyymmdd} !~ /$weekday/)
      { $days_found {$yyyymmdd} .= $weekday ; }
    }

    if    ($requester eq 'B') { $requester = 'bot' ; }
    elsif ($requester eq 'U') { $requester = 'user' ; }
    else                      { $requester = 'unknown' ; }

    $site = 'main' ;
    if ($project =~ /\%/)
    {
      $project =~ s/\%// ;
      $site = 'mobile' ;
    }

    if ($do_filter_countries  && ! $filter_countries  {$country})   { $skipped_countries  {$country}   += $count ; next ; }
    if ($do_filter_languages  && ! $filter_languages  {$language})  { $skipped_languages  {$language}  += $count ; next ; }
    if ($do_filter_projects   && ! $filter_projects   {$project})   { $skipped_projects   {$project}   += $count ; next ; }
    if ($do_filter_requesters && ! $filter_requesters {$requester}) { $skipped_requesters {$requester} += $count ; next ; }
    if ($do_filter_sites      && ! $filter_sites      {$site})      { $skipped_sites      {$site}      += $count ; next ; }

  # print "$line\n" ;
    $yyyymmdd_found {$yyyymmdd} ++ ;

    $yyyymm = substr ($yyyymmdd,0,7) ;

    $visits_monthly {"$yyyymm,$project,$language,$country,$requester,$site"  } += $count ;
    $visits_daily   {"$yyyymmdd,$project,$language,$country,$requester,$site"} += $count ;

    if ($do_total_regions)
    {
      $region = &RegionName ($region_codes {$country}) ;
      if ($region =~ /(?:Africa|Asia|Europe|North America|South America)/)
      { $region = "2$region" ; }  # sort key
      else
      { $region = "3$region" ; }  # sort key
      if ($region !~ /Other/)
      {
        $keys_totals  {"$region $site"}           += $count ;
        $totals_daily {"$yyyymmdd,$region $site"} += $count ;
      }

      $ns = $north_south_codes {$country} ;
      if ($ns ne 'N' and $ns ne 'S')
      { $ns = 'U' ; } # unclassified
      $region = &RegionName ($ns) ;
      $region = "1$region" ; # sort key
      $keys_totals  {"$region $site"}           += $count ;
      $totals_daily {"$yyyymmdd,$region $site"} += $count ;
    }

    if ($do_total_countries || $do_total_sites)
    {
      if ($do_total_countries && $do_total_sites)
      {
        $keys_totals  {"country $country total"}           += $count ;
        $totals_daily {"$yyyymmdd,country $country total"} += $count ;
        $keys_totals  {"country $country $site"}           += $count ;
        $totals_daily {"$yyyymmdd,country $country $site"} += $count ;
      }
      elsif ($do_total_countries)
      {
        $keys_totals  {"country $country"}           += $count ;
        $totals_daily {"$yyyymmdd,country $country"} += $count ;
      }
      else
      {
        $keys_totals  {"aite $site"}               += $count ;
        $totals_daily {"$yyyymmdd,site $site"} += $count ;
      }
    }

    if ($do_total_languages)
    {
      $keys_totals  {"language $language"}           += $count ;
      $totals_daily {"$yyyymmdd,language $language"} += $count ;
    }

    if ($do_total_projects)
    {
      $keys_totals  {"project $project"}           += $count ;
      $totals_daily {"$yyyymmdd,project $project"} += $count ;
    }

    if ($do_total_requesters)
    {
      $keys_totals  {"requester $requester"}           += $count ;
      $totals_daily {"$yyyymmdd,requester $requester"} += $count ;
    }

    if ($requester ne 'unknown')
    {
      $visits_per_day       {$yyyymmdd}  += $count ;
      $visits_per_project   {$project}   += $count ;
      $visits_per_language  {$language}  += $count ;
      $visits_per_country   {$country}   += $count ;
      $visits_per_requester {$requester} += $count ;
      $visits_per_site      {$site}      += $count ;

      $visits_per_proj_lang_country_req_site  {"$project,$language,$country,$requester,$site"} += $count ;
    # $visits_per_proj_lang_country_req_site   {"total site $site"} += $count ;
    }

    $visits_total += $count ;
  }

  close CSV_IN ;

  $lines2 = $lines ;
  $lines2 =~ s/(.*?\d)(\d\d\d)(\d\d\d)$/$1,$2,$3/ ;
  $lines2 =~ s/(.*?\d)(\d\d\d)$/$1,$2/ ;
  print "Data lines read: $lines2\n" ;
  print "All input read\n\n" ;

  if ($do_filter_countries)
  {
    print "Countries skipped (code:count):\n" ;
    $line = '' ;
    foreach $country (sort keys %skipped_countries)
    {
      if (length ($line) > 70)
      {  print $line ; $line = '' ; }
      $line .= $country . ':' . $skipped_countries {$country} . ', ' ;
    }
    $line =~ s/,\s*$// ;
    print "$line\n" if $line ne '' ;
  }

  if ($do_filter_languages)
  {
    print "\n\nLanguages skipped (code:count):\n" ;
    $line = '' ;
    foreach $language (sort keys %skipped_languages)
    {
      if (length ($line) > 70)
      {  print $line ; $line = '' ; }
      $line .= $language . ':' . $skipped_languages {$language} . ', ' ;
    }
    $line =~ s/,\s*$// ;
    print "$line\n" if $line ne '' ;
  }

  if ($do_filter_projects)
  {
    print "\n\nProjects skipped (code:count):\n" ;
    $line = '' ;
    foreach $project (sort keys %skipped_projects)
    {
      if (length ($line) > 70)
      {  print $line ; $line = '' ; }
      $line .= $project . ':' . $skipped_projects {$project} . ', ' ;
    }
    $line =~ s/,\s*$// ;
    print "$line\n" if $line ne '' ;
  }

  if ($do_filter_requesters)
  {
    print "\n\nRequesters skipped (code:count):\n" ;
    $line = '' ;
    foreach $requester (sort keys %skipped_requesters)
    { $line .= $requester . ':' . $skipped_requesters {$requester} . ', ' ; }
    $line =~ s/,\s*$// ;
    print "$line\n" if $line ne '' ;
  }

  if ($do_filter_sites)
  {
    print "\n\nSites skipped (code:count):\n" ;
    $line = '' ;
    foreach $site (sort keys %skipped_sites)
    { $line .= $site . ':' . $skipped_sites {$site} . ', ' ; }
    $line =~ s/,\s*$// ;
    print "$line\n" if $line ne '' ;
  }

  die "No records match all criteria, nothing to report" if $visits_total == 0 ;

  print "\nAll input read\n\n" ;
}

sub WriteOutput
{
  my ($file_output, $data_label) = @_ ;

  print "Write output\n\n" ;

  die "No valid data found, counts = 0\n" if $visits_total == 0 ;

  open CSV_OUT,'>', $file_output || die ("\nError: output file '$file_output' could not be opened!") ;

  my $threshold   = int ($visits_total * $min_fraction) ;
  my $bot_perc    = sprintf ("%.1f", 100 * (1 - $visits_total/$visits_total)) ;

  print "\nWrite raw details for projects, countries, wikis with over > $min_fraction of total views (> $threshold)\n\n" ;

  my ($perc,$perc2,$perc_total,$perc2_total) ;
  foreach $project (sort keys %visits_per_project)
  {
    $perc = sprintf ("%.2f", 100 * ($visits_per_project {$project} / $visits_total)) ;
    $perc_total += $perc ;
    print "\nproject $project: $perc\% (total for projects inluded: $perc_total\%)\n\n" ;
    next if $visits_per_project {$project} < $threshold ;

    foreach $country (sort keys %visits_per_country)
    {
      next if $visits_per_country {$country} < $threshold ;

      foreach $language (sort keys %visits_per_language)
      {
        next if $visits_per_language {$language} < $threshold ;

        foreach $requester (sort keys %visits_per_requester)
        {
          next if $visits_per_requester {$requester} < $threshold ;

          foreach $site (sort keys %visits_per_site)
          {
            next if $visits_per_site {$site} < $threshold ;

            next if $visits_per_proj_lang_country_req_site  {"$project,$language,$country,$requester,$site"} < $threshold ;
            $perc2= sprintf ("%.2f", 100 * $visits_per_proj_lang_country_req_site  {"$project,$language,$country,$requester,$site"}/$visits_total) ;
            $perc2_total += $perc2 ;

            next if $language eq 'www' and $site eq 'mobile' ; # always zero
            push @proj_lang_country_req_site, "$project,$language,$country,$requester,$site" ;
          }
        }
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
    $yyyymmdd {$yyyymmdd_now} ++ ;
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
  @yyyymmdd = sort keys %yyyymmdd ;

  @keys_totals = sort {$keys_totals {$b} <=> $keys_totals {$a}} keys %keys_totals ;
  @keys_totals = sort keys %keys_totals ;

  foreach $key (@keys_totals)
  { print "$key: " . $keys_totals {$key} . "\n" ; }

  print "\nShow columns with most page views\n\n" ;
  @proj_lang_country_req_site = sort {$visits_per_proj_lang_country_req_site {$b} <=> $visits_per_proj_lang_country_req_site  {$a}} @proj_lang_country_req_site ;
# @proj_lang_country_req_site = sort @proj_lang_country_req_site ;

  print CSV_OUT ",,,,Wikimedia page $mode per day / based on 1:1000 sampled log server -> multiply all counts by 1000\n" ;
  print CSV_OUT ",,,,mobile site e.g 'en.m.wikipedia.org' - main site e.g 'en.wikipedia.org' / max columns=$max_columns / threshold=column total > $min_fraction of overall total\n" ;
  print CSV_OUT ",,,,If data were omitted due to #columns constraint you can see how much in unlisted (absolute count) and %listed\n" ;
  print CSV_OUT ",,,,All totals are generated after application of filters for projects/countries/languages/requesters/sites !!\n\n" ;

  print CSV_OUT ",,,,Global North countries: $line_global_N\n" ;
  print CSV_OUT ",,,,Global South countries: $line_global_S\n" ;
  print CSV_OUT ",,,,Unclassified countries: $line_global_U\n\n" ;

  if ($line_filter_projects   ne '') { print CSV_OUT ",,,,\"$line_filter_projects\"\n" ; }
  if ($line_filter_languages  ne '') { print CSV_OUT ",,,,\"$line_filter_languages\"\n" ; }
  if ($line_filter_countries  ne '') { print CSV_OUT ",,,,\"$line_filter_countries\"\n" ; }
  if ($line_filter_requesters ne '') { print CSV_OUT ",,,,\"$line_filter_requesters\"\n" ; }
  if ($line_filter_sites      ne '') { print CSV_OUT ",,,,\"$line_filter_sites\"\n" ; }

  print CSV_OUT ",,,,," ;
  foreach $key_total (@keys_totals)
  { print CSV_OUT "," ; }
  print CSV_OUT "% of total," ;

  my $columns = 0 ;
  foreach $proj_lang_country_req_site (@proj_lang_country_req_site)
  {
    $perc = sprintf ("%.2f", 100 * $visits_per_proj_lang_country_req_site {$proj_lang_country_req_site}/ $visits_total) ;
    print CSV_OUT "$perc\%," ;
  # print "$proj_lang_country_req_site: $perc\n" ;

    last if ++$columns >= $max_columns ;
  }
  print CSV_OUT "\n\n" ;

  for ($row = 0 ; $row <= 5 ; $row++)
  {
    $columns = 0 ;

       if ($row == 0) { print CSV_OUT ",,,,project,," ; }
    elsif ($row == 1) { print CSV_OUT ",,,,language,," ; }
    elsif ($row == 2) { print CSV_OUT ",,,,country,," ; }
    elsif ($row == 3) { print CSV_OUT ",,,,req by,," ; }
    elsif ($row == 4) { print CSV_OUT ",,,,site,," ; }
    elsif ($row == 5) { print CSV_OUT "date,unlisted,% listed ->,,date Excel,total," ; }

    foreach $key_total (@keys_totals)
    {
      if ($row < 5)
      { print CSV_OUT "," ; }
      else
      {
        $key_total2 = $key_total ;
        $key_total2 =~ s/^[^-]+-[^-]+-/(1):(2) / ; # wp-en -> wp:en
        $key_total2 =~ s/language www/portal www/ ;
        $key_total2 =~ s/language/lang/ ;
        $key_total2 =~ s/site main/main site/ ;
        $key_total2 =~ s/site mobile/mobile site/ ;
        $key_total2 =~ s/requester bot/bots/ ;
        $key_total2 =~ s/requester user/users/ ;
        $key_total2 =~ s/^glb // ;
        $key_total2 =~ s/^reg // ;
        $key_total2 =~ s/^reg // ;
        $key_total2 =~ s/^\d// ;

        if ($key_total2 =~ /country/)
        {
          $key_total2 =~ s/country\s*// ;
          $name = $country_names {$key_total2} ;
          if ($name ne '')
          { $key_total2 = $name ; }
          else
          {
            push @unknown_countrycodes, $key_total2 ;
            $key_total2 = "$key_total2 (?)" ;
          }
        }
        print CSV_OUT "$key_total2," ;
      }

      last if ++$columns >= $max_columns ;
    }

    foreach $proj_lang_country_req_site (@proj_lang_country_req_site)
    {
      last if $columns >= $max_columns ;

      # ($proj_lang_country_req_site2 = $proj_lang_country_req_site) =~ s/,/-/g ;
      @headers = split (',', $proj_lang_country_req_site) ;
      if ($row < 5)
      { print CSV_OUT $headers [$row] . ', ' ; }
      else
      {
        $proj_lang_country_req_site2 = $proj_lang_country_req_site ;
        $proj_lang_country_req_site2 =~ s/,user,/,/ ; # only show site label when 'mobile'
        $proj_lang_country_req_site2 =~ s/,/ /g ; # 'wp,nl,NL,user,main' is now 'wp:nl NL main'

        print CSV_OUT $proj_lang_country_req_site2 . ', ' ;
      }

      #if ($proj_lang_country_req_site2 =~ /\%/)
      #{
      #  $proj_lang_country_req_site2 =~ s/\%// ;
      #  $proj_lang_country_req_site2 .= '-mob' ;
      #}
      #print CSV_OUT "$proj_lang_country_req_site2," ;
   #  print "$proj_lang_country_req_site2: " . sprintf ("%.2f", 100 * $visits_per_proj_lang_country_req_site {$proj_lang_country_req_site}/ $visits_total) . "\%\n" ;

      last if ++$columns >= $max_columns ;
    }
    print CSV_OUT "\n" ;
  }


  my ($perc_included,$cells_csv,$cells_total,$yyyymmdd_excel) ;
  $yyyymmdd_prev = '' ;
  for $yyyymmdd ( sort @yyyymmdd )
  {
    next if $yyyymmdd eq $yyyymmdd_prev ;
    $yyyymmdd_prev = $yyyymmdd ;

    if ($weekly) # store whole week on Sunday
    {  next if &GetWeekDay ($yyyymmdd) > 0 ; }

    $columns = 0 ;
    $yyyymmdd_excel = "\"=date(" . substr($yyyymmdd,0,4) . "," . substr($yyyymmdd,5,2) . "," . substr($yyyymmdd,8,2) . ")\"" ;

    if ($weekly)
    {
      $days_found = length ($days_found {$yyyymmdd}) ; # contains string with day numbers [0-6]*, '012346'
      print "$yyyymmdd: " . (0 + $days_found) . " days found\n" ;
      if ($days_found == 0)
      {
        print CSV_OUT "$yyyymmdd,,,,$yyyymmdd_excel\n" ;
        next ;
      }
    }

    $visits_per_day = $visits_per_day {$yyyymmdd} ;
    if ($weekly)
    { $visits_per_day = sprintf ("%.0f", $visits_per_day / $days_found) ; }

    if ($visits_per_day == 0)
    {
      print CSV_OUT "$yyyymmdd,,,,$yyyymmdd_excel\n" ;
      next ;
    }

    $cells_csv   = '' ;
    $cells_total = 0 ;

    foreach $key_total (@keys_totals)
    {
      $count = $totals_daily {"$yyyymmdd,$key_total"} ;
      if ($weekly)
      { $count = sprintf ("%.0f", $count / $days_found) ; }

      if ($percentages)
      { $count = sprintf ("%.2f\%", 100 * $count / $visits_per_day) ; }

      $cells_csv .= $count . "," ;

      last if ++$columns >= $max_columns ;
    }

    foreach $key_proj_lang_country_req_site (@proj_lang_country_req_site)
    {
      last if $columns >= $max_columns ;

      $count = $visits_daily {"$yyyymmdd,$key_proj_lang_country_req_site"} ;

      if ($weekly)
      { $count = sprintf ("%.0f", $count / $days_found) ; }
      if ($count == 0)
      { $count = '' ; }
    # $cells_csv .= (0 + $count) . "," ;

      $cells_total += $count ;

      if ($percentages)
      { $count = sprintf ("%.2f\%", 100 * $count / $visits_per_day) ; }

      $cells_csv .= $count . "," ;

      last if ++$columns >= $max_columns ;
    }

    $visits_other = $visits_per_day - $cells_total ;
    $perc_included = sprintf ("%.1f", 100 *  $cells_total / $visits_per_day) ;
    print CSV_OUT "$yyyymmdd,$visits_other,$perc_included\%,,$yyyymmdd_excel,$visits_per_day,$cells_csv\n" ;
  }

  print CSV_OUT "\nSheet contains $columns columns with basic data\n\n" ;
  close CSV_OUT ;

  print "\nUnknown country codes: " . join ('|', sort @unknown_countrycodes) . "\n\n" ;
  $filesize_out = -s $file_output ;
  print "File reduced from $filesize_in to $filesize_out = " . sprintf ("%.3f", 100 * $filesize_out / $filesize_in) . "\%\n" ;
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

sub GetWeekDay
{
  my ($yyyymmdd) = @_ ;
  my $yyyy = substr ($yyyymmdd,0,4) ;
  my $mm   = substr ($yyyymmdd,5,2) ;
  my $dd   = substr ($yyyymmdd,8,2) ;

  my $time  = timegm (0,0,0,$dd, $mm-1, $yyyy-1900) ;
  my ($weekday) = (gmtime ($time)) [6] ;
  return ($weekday) ;
}

sub GetDateAsSeconds
{
  my ($yyyymmdd) = @_ ;
  my $yyyy = substr ($yyyymmdd,0,4) ;
  my $mm   = substr ($yyyymmdd,5,2) ;
  my $dd   = substr ($yyyymmdd,8,2) ;

  my $time  = timegm (0,0,0,$dd, $mm-1, $yyyy-1900) ;

  return ($time) ;
}
