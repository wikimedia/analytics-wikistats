#!/usr/bin/perl

# Rather quick and simple script to collect browserstats for Excel chart, see for Excel output example:
# http://infodisiac.com/blog/2012/02/wikimedia-usage-share-per-browserstraffic-breakdown-by-browser/

use Time::Local ;

$mode_all_pages = 0 ; # to do: make runtime argument

if ($mode_all_pages)
{ $time  = timegm (0,0,0,1,2,109) ; } # start 2009-3-1 - oldest month with counts
else
{ $time  = timegm (0,0,0,1,4,111) ; } # start 2011-5-1 - oldest month with mime-type column (page,image,other)

  if ($mode_all_pages)
  { $mime_filter = "AllRequests" ; }
  else
  { $mime_filter = "HtmlRequests" ; }

  open CSV_OUT_DAILY ,  '>', "SquidScanClientsDaily$mime_filter.csv" ;
  open CSV_OUT_WEEKLY,  '>', "SquidScanClientsWeekly$mime_filter.csv" ;
  open CSV_OUT_MONTHLY, '>', "SquidScanClientsMonthly$mime_filter.csv" ;

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

    # next if $yyyy_mm eq "2011-09" and $yyyy_mm_dd ge "2011-09-08" ; # " Sep 2011: varnish bug could not be repaired, as logs were gone when bug was found Dec 2011

    $days {$yyyy_mm_dd}++ ; # collect days found
    $dates_ascii {$yyyy_mm_dd} = $yyyy_mm_dd ;
    $dates_excel {$yyyy_mm_dd} = $date_excel ;
    $dates_ascii {$yyyy_mm}    = $yyyy_mm_dd ;
    $dates_excel {$yyyy_mm}    = $date_excel ;

    print "$yyyy_mm_dd\n" ;

    $folder = "/a/ezachte/$yyyy_mm/$yyyy_mm_dd" ;

    if ($yyyy_mm ge "2010-07")
    { $folder .= "/public" ; }

    $file = "$folder/SquidDataClients.csv" ;

    $count = '-' ;
    if (-e $file)
    {
      $files {$weeknum} ++ ;

      open CSV_IN, '<', $file ;

      while ($line = <CSV_IN>)
      {
        chomp $line ;
        @fields = split (',', $line) ;
        next if $fields [0] ne 'G' ; # grouped stats only (irrespective of version)


        if ($mode_all_pages)
        {
          if ($yyyy_mm ge "2011-05")
          { $count = $fields [4] ; }
          else
          { $count = $fields [3] ; }
        }
        else
        {
          next if $fields [3] ne 'page' ; # html requests only

          $count = $fields [4] ;
        }

      # next if $count < 1000 ; # request count in 1:1000 sampled file, so less than 1 million per day

        $totals_weekly  {$weeknum} += $count ;
        $totals_monthly {$yyyy_mm} += $count ;

        $group = ucfirst (lc ($fields [2])) ;

        if ($fields [1] eq 'M')
        {
          if ($group !~ /^(?:safari|android|opera)$/i)
          { $group = 'other' ; }
          $group = "$group (Mobile)" ;

          $mobile_weekly  {$weeknum} += $count ;
          $mobile_monthly {$yyyy_mm} += $count ;

          $group_daily    {"Mobile,$yyyy_mm_dd"} += $count ;
          $group_weekly   {"Mobile,$weeknum"}    += $count ;
          $group_monthly  {"Mobile,$yyyy_mm"}    += $count ;
        }
        else
        {
          if ($group !~ /^(?:msie|firefox|chrome|opera)$/i)
          { $group = 'other' ; }
          $group = "$group" ;

          $non_mobile_weekly  {$weeknum} += $count ;
          $non_mobile_monthly {$yyyy_mm} += $count ;

          $group_daily    {"Non-Mobile,$yyyy_mm_dd"} += $count ;
          $group_weekly   {"Non-Mobile,$weeknum"}    += $count ;
          $group_monthly  {"Non-Mobile,$yyyy_mm"}    += $count ;
        }
      # next if $fields [2] eq 'NetFront' ; # skip, occurs on few days only


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
#  push @group_list, "Non-Mobile" ;
  push @group_list, "Mobile" ;
  for $group (sort {$totals {$b} <=> $totals {$a}} keys %totals)
  {
    print "$group: " . $totals {$group} . "\n" ;
    last if ++$groups > 15   ;
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
      { print CSV_OUT_WEEKLY int ($group_weekly {"$group,$weeknum"}/$files {$weeknum}) . ',' ; }
    }

    print CSV_OUT_WEEKLY "\n" ;
  }

