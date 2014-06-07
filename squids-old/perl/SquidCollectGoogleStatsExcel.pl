#!/usr/bin/perl

# quick almost throwaway variation on existing script to collect googlestats for Excel chart

  use Getopt::Std ;
  use File::Path ;
  use Time::Local ;
  getopt ("io", \%options) ;

  print "\nQuick script to collect crawlerstats for Excel chart, see example Excel chart:\n" ;
  print "http://infodisiac.com/blog/2012/02/wikimedia-usage-share-per-browserstraffic-breakdown-by-browser/\n" ;

  $path_csv_in = $options {'i'} ;
  die "Specify input path (squids csv top folder) as -i [path]" if $path_csv_in eq '' ;
  die "Input path '$path_csv_in' not found (squids csv top folder)" if ! -d $path_csv_in ;

  $path_csv_out = $options {'o'} ;
  die "Specify output path as -o [path]" if $path_csv_out eq '' ;
  if (! -d $path_csv_out)
  {
    mkpath $path_csv_out ;
    die "Path '$path_csv_out' could not be created" if ! -d $path_csv_out ;
  }


  $mode_all_pages = 0 ; # to do: make runtime argument

  if ($mode_all_pages)
  { $time  = timegm (0,0,0,1,2,109) ; } # start 2009-3-1 - oldest month with counts
  else
  { $time  = timegm (0,0,0,1,4,111) ; } # start 2011-5-1 - oldest month with mime-type column (page,image,other)

  if ($mode_all_pages)
  { $mime_filter = "AllRequests" ; }
  else
  { $mime_filter = "HtmlRequests" ; }

  open CSV_OUT_DAILY ,  '>', "$path_csv_out/SquidScanGoogleDaily$mime_filter.csv" ;
  open CSV_OUT_WEEKLY,  '>', "$path_csv_out/SquidScanGoogleWeekly$mime_filter.csv" ;
  open CSV_OUT_MONTHLY, '>', "$path_csv_out/SquidScanGoogleMonthly$mime_filter.csv" ;

  $days_done = 0 ;
  while ($time < time)
  {
    ($day,$month,$year,$yearday) = (gmtime ($time))[3,4,5,7] ;
    $yyyy_mm_dd = sprintf ("%04d-%02d-%02d", $year+1900, $month+1, $day) ;
    $yyyy_mm    = sprintf ("%04d-%02d",      $year+1900, $month+1) ;
    $date_excel = sprintf ("\"=DATE(%d,%d,%d)\"", $year+1900, $month+1, $day) ;

    $days_done++ ;
    $weeknum = int ($days_done / 7) ;

    # remember first day of week
    if ($weeknums {$weeknum} eq '')
    { $weeknums {$weeknum} = $yyyy_mm_dd ; }
    $months {$yyyy_mm} ++ ;
    
    $days {$yyyy_mm_dd}++ ; # collect days found
    $dates_ascii {$yyyy_mm_dd} = $yyyy_mm_dd ;
    $dates_excel {$yyyy_mm_dd} = $date_excel ;
    $dates_ascii {$yyyy_mm}    = $yyyy_mm_dd ;
    $dates_excel {$yyyy_mm}    = $date_excel ;

    print "$yyyy_mm_dd\n" ;

    # same invalid dates as in WikiCountsSummarizeProjectCounts.pl
    if (($yyyy_mm_dd ge "2010-06-11" and $yyyy_mm_dd lt "2010-06-17") || # bad measurements on these dates
        ($yyyy_mm_dd ge "2010-06-27" and $yyyy_mm_dd lt "2010-06-28") || # bad measurements on these dates
        ($yyyy_mm_dd ge "2011-09-08" and $yyyy_mm_dd lt "2011-09-15") || # bad measurements on these dates
        ($yyyy_mm_dd ge "2011-12-23" and $yyyy_mm_dd lt "2011-12-26") || # bad measurements on these dates
        ($yyyy_mm_dd ge "2012-04-13" and $yyyy_mm_dd lt "2012-04-17") || # bad measurements on these dates
        ($yyyy_mm_dd ge "2012-07-02" and $yyyy_mm_dd lt "2012-07-03") || # bad measurements on these dates
        ($yyyy_mm_dd ge "2012-11-01" and $yyyy_mm_dd lt "2012-11-02") || # bad measurements on these dates
        ($yyyy_mm_dd ge "2012-12-14" and $yyyy_mm_dd lt "2013-01-08") || # bad measurements on these dates
        ($yyyy_mm_dd ge "2013-07-23" and $yyyy_mm_dd lt "2013-07-24") || # bad measurements on these dates
        ($yyyy_mm_dd ge "2014-01-05" and $yyyy_mm_dd lt "2014-01-07"))    # bad measurements on these dates
    {
      $time += 3600 * 24 ; # next day
      next ;
    }   

    $folder = "$path_csv_in/$yyyy_mm/$yyyy_mm_dd" ;

    if ($yyyy_mm ge "2010-07")
    { $folder .= "/public" ; }

    $file = "$folder/SquidDataSearch.csv" ;

    $count = '-' ;
    if (! -e $file)
    { print "File not found: '$file'\n" ; }
    else
    {
      $files {$weeknum} ++ ;
      $files {$yyyy_mm} ++ ;

      open CSV_IN, '<', $file ;

      while ($line = <CSV_IN>)
      {
        chomp $line ;
        ($detect_flags, $firm, $action, $source, $dummy, $mime_cat, $langcode, $count) = split (',', $line) ;

	#   next if (! $mode_all_pages) and ($mime_cat ne 'page') ; 
        
	next if $firm ne 'google' ; # does not happen yet
        next if $action ne 'web search' ;
        next if $source ne 'Web search' ;
        next if $mime_cat ne 'page' ;

	$useragents {$useragent} += $count ;

      # next if $count < 1000 ; # request count in 1:1000 sampl:ed file, so less than 1 million per day

        $totals_weekly  {$weeknum} += $count ;
        $totals_monthly {$yyyy_mm} += $count ;

        $group = 'total' ;

  	# $group_daily    {"Non-Mobile,$yyyy_mm_dd"} += $count ;
      # $group_weekly   {"Non-Mobile,$weeknum"}    += $count ;
      # $group_monthly  {"Non-Mobile,$yyyy_mm"}    += $count ;

        $groups         {$group}++ ;
        $group_daily    {"$group,$yyyy_mm_dd"} += $count ;
        $group_weekly   {"$group,$weeknum"}    += $count ;
        $group_monthly  {"$group,$yyyy_mm"}    += $count ;
        $totals         {$group}               += $count ;
        
	$group = $langcode ;

	$groups         {$group}++ ;
        $group_daily    {"$group,$yyyy_mm_dd"} += $count ;
        $group_weekly   {"$group,$weeknum"}    += $count ;
        $group_monthly  {"$group,$yyyy_mm"}    += $count ;
        $totals         {$group}               += $count ;

        # print "$group,$count\n" ;
      }
    }

    $time += 3600 * 24 ; # next day
  }

  $groups = 0 ;
  for $group (sort {$totals {$b} <=> $totals {$a}} keys %totals)
  {
    print "$group: " . $totals {$group} . "\n" ;
#   last if ++$groups > 15   ;
    push @group_list, $group ;
  }

  # daily counts
  print CSV_OUT_DAILY 'date ascii,date,' ;
  for $group (@group_list)
  { print CSV_OUT_DAILY "$group," ; }

  print CSV_OUT_DAILY "\n" ;

  for $yyyy_mm_dd (sort keys %days)
  {
    print CSV_OUT_DAILY $dates_ascii {$yyyy_mm_dd} . ',' ;
    print CSV_OUT_DAILY $dates_excel {$yyyy_mm_dd} . ',' ;

    for $group (@group_list)
    {
      print CSV_OUT_DAILY $group_daily {"$group,$yyyy_mm_dd"} . ',' ;
    }

    print CSV_OUT_DAILY "\n" ;
  }

  # monthly counts
#if (0) # no points for breakdown in percentages as long as there is only 'total' # this was useful in browser breakdown script version, here not yet
#{
  print CSV_OUT_MONTHLY 'date ascii,date,' ;
  for $group (@group_list)
  { print CSV_OUT_MONTHLY "$group," ; }
  print CSV_OUT_MONTHLY "\n" ;

  for $month (sort {$a cmp $b} keys %months)
  {
    print CSV_OUT_MONTHLY $dates_ascii {$month} . ',' ;
    print CSV_OUT_MONTHLY $dates_excel {$month} . ',' ;

    last if $totals_monthly {$month} == 0 ;

    for $group (@group_list)
    {
      if ($totals_monthly {$month} > 0)
      { print CSV_OUT_MONTHLY sprintf ("%.2f", 100 * $group_monthly {"$group,$month"}/$totals_monthly {$month}) . ',' ; } }

    print CSV_OUT_MONTHLY "\n" ;
  }
#}

  # monthly counts
  print CSV_OUT_MONTHLY "\n\n" ;
  print CSV_OUT_MONTHLY 'date ascii,date,monthly avg,days valid input,days in month, monthly total counted,monthly total extrapolated' ;
# for $group (@group_list)
# { print CSV_OUT_MONTHLY ",$group" ; }
  print CSV_OUT_MONTHLY "\n" ;

  for $month (sort {$a cmp $b} keys %months)
  {
    print CSV_OUT_MONTHLY $dates_ascii {$month} . ',' ;
    print CSV_OUT_MONTHLY $dates_excel {$month} . ',' ;

    last if $totals_monthly {$month} == 0 ;

    for $group (@group_list)
    {
	    #$group = 'total' ; 
      my $counted       = $group_monthly {"$group,$month"} ; 
      my $days_valid    = $files {$month} ;    
      my $days_in_month = &days_in_month ($month) ;
      my $average       = $counted / $days_valid ;
      my $extrapolated  = int ($average * $days_in_month + 0.5	) ;
      my $average       = int ($average + 0.5) ;
      
      if ($days_valid > 0)
    # { print CSV_OUT_MONTHLY "$average,$days_valid,$days_in_month,$counted,$extrapolated" ; }
      { print CSV_OUT_MONTHLY "$average," ; }
    }

    print CSV_OUT_MONTHLY "\n" ;
  }

  # weekly counts
  print CSV_OUT_WEEKLY 'date ascii,date,' ;
  for $group (@group_list)
  { print CSV_OUT_WEEKLY "$group," ; }
  print CSV_OUT_WEEKLY "\n" ;

  for $weeknum (sort {$a <=> $b} keys %weeknums)
  {
    print CSV_OUT_WEEKLY $dates_ascii {$weeknums {$weeknum}} . ',' ;
    print CSV_OUT_WEEKLY $dates_excel {$weeknums {$weeknum}} . ',' ;

    if ($files {$weeknum} > 0)
    {
      for $group (@group_list)
      {
        if ($totals_weekly {$weeknum} == 0)
        { print CSV_OUT_WEEKLY ',' ; }
        else
        { print CSV_OUT_WEEKLY sprintf ("%.2f", 100 * $group_weekly {"$group,$weeknum"}/$totals_weekly {$weeknum}) . ',' ; }
      }
    }

    print CSV_OUT_WEEKLY "\n" ;
  }


  # daily averages from weekly counts, adjusted for missing days
  print CSV_OUT_WEEKLY "\n\n" ;
  print CSV_OUT_WEEKLY 'date ascii,date,weekly avg,days input, weekly total' ;
  for $group (@group_list)
  { print CSV_OUT_WEEKLY "$group," ; }
  print CSV_OUT_WEEKLY "\n" ;

  for $weeknum (sort {$a <=> $b} keys %weeknums)
  {
    print CSV_OUT_WEEKLY $dates_ascii {$weeknums {$weeknum}} . ',' ;
    print CSV_OUT_WEEKLY $dates_excel {$weeknums {$weeknum}} . ',' ;

    if ($files {$weeknum} > 0)
    {
      for $group (@group_list)
     { print CSV_OUT_WEEKLY int ($group_weekly {"$group,$weeknum"}/$files {$weeknum}) . ',' ; }
     #  { print CSV_OUT_WEEKLY  int ($group_weekly {"$group,$weeknum"}/$files {$weeknum}) . ',' . $files {$weeknum} . ',' . int ($group_weekly {"$group,$weeknum"}) . ',' ; }

    }  
    print CSV_OUT_WEEKLY "\n" ;
  }

  foreach $useragent (sort {$useragents {$b} <=> $useragents {$a}} keys %useragents)
  { 
    print sprintf ("%10d", $useragents {$useragent}) . ": $useragent\n" ;	  
    last if ++ $count_useragent > 25 ; 	    
  }


sub days_in_month
{
  my $yyyy_mm = shift ;
  my $year  = substr ($yyyy_mm,0,4) ;
  my $month = substr ($yyyy_mm,5,2) ;
  my $days = $days_in_month_cached {"$year $month"} ;
  return $days if $days > 0 ;

  my $month2 = $month+1 ;
  my $year2  = $year ;
  if ($month2 > 12)
  { $month2 = 1 ; $year2++ }

  my $timegm1 = timegm (0,0,0,1,$month-1,$year-1900) ;
  my $timegm2 = timegm (0,0,0,1,$month2-1,$year2-1900) ;
  $days = ($timegm2-$timegm1) / (24*60*60) ;

  $days_in_month_cached {"$year $month"} = $days ;
  return ($days) ;
}

