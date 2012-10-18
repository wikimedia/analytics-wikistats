#!/usr/local/bin/perl
# bayes:/a/dammit.lt/dammit_scan_pagecounts.sh:

#!/bin/sh
#ulimit -v 8000000
#dir_input="/mnt/data/xmldatadumps/public/other/pagecounts-raw/2012/2012-01"
#zgrep -H "Wikipedia:SOPA_initiative/Learn_more " $dir_input/pagecounts-201201*.gz > scan_pagecounts.csv
#grep "gz:en" scan_pagecounts.csv > scan_pagecounts_en.csv

  &RankPagesViewedWk ;
  # &RankSearchTerms ;
  print "\nReady" ;
  exit ;

sub sub1
{
  open IN, '<','scan_pagecounts.txt' ;
  open OUT,'>','scan_pagecounts.csv' ;

  while ($line = <IN>)
  {
    $line =~ s/^.*?pagecounts.*pagecounts-// ;
    $line =~ s/ /,/g ;
    $yyyy = substr ($line,0,4) ;
    $mm = substr ($line,4,2) ;
    $dd = substr ($line,6,2) ;
    $hh = substr ($line,9,2) ;
    $nn = substr ($line,11,2) ;
    $ss = substr ($line,13,2) ;
    $line =~ s/^.*?gz:// ;

    chomp $line ;
    @fields = split (',', $line) ;
    if (($fields [1] ne 'Wikipedia:SOPA_initiative/Learn_more') || ($fields [2] !~ /^\d+$/))
    {
      print "Skip ${fields [2]} requests for ${fields [1]}\n" ;
      next ;
    }

    $lang     = $fields [0] ;
    $requests = $fields [2] ;
    $time = "\"=DATE($yyyy,$mm,$dd)+$hh/24\"" ;

    print OUT "$lang,$time,$requests\n" ;
  }
}

sub RankSearchTerms
{

# open IN, '<','scan_pagecounts2.txt' ;
# open OUT,'>','scan_pagecounts3.csv' ;
  open IN, '<','scan_congress.txt' ;
  open OUT,'>','scan_congress.csv' ;

  while ($line = <IN>)
  {
    $line =~ s/^.*?pagecounts.*pagecounts-// ;
    $line =~ s/ /,/g ;

    $yyyy = substr ($line,0,4) ;
    $mm   = substr ($line,4,2) ;
    $dd   = substr ($line,6,2) ;
    $hh   = substr ($line,9,2) ;
    $yyyy_mm_dd_hh = "$yyyy-$mm-$dd-$hh" ;
    $date_excel = "\"=DATE($yyyy,$mm,$dd)+$hh/24\"" ;
    $hours {$yyyy_mm_dd_hh}++ ;
    $dates_excel {$yyyy_mm_dd_hh} = $date_excel ;
    # next if $yyyy_mm_dd_hh lt "2012-01-18-05" ;
    # next if $yyyy_mm_dd_hh gt "2012-01-19-04" ;
    $line =~ s/^.*?gz:// ;

    chomp $line ;
    @fields = split (',', $line) ;

    $lang     = $fields [0] ;
    $term     = $fields [1] ;
    $requests = $fields [2] ;

    $pages       {"$lang $term"}                += $requests ;
    $pages_timed {"$lang $term $yyyy_mm_dd_hh"} += $requests ;

    # print "$yyyy_mm_dd_hh $lang $term $requests\n" ;

    $hours {$yyyy_mm_dd_hh}++ ;
  }

  for $key (sort keys %hours)
  { print "$key: " . $hours {$key} . " lines\n" ; }

  for $page (sort {$pages {$b} <=> $pages {$a}} keys %pages)
  {
    push @pages, $page ;
    print OUT $pages{$page} . ",$page\n" ;
    last if ++$pages_most_popular >= 20 ;
  # last if ++$pages {$page} < 1000 ;
  }

  for $page (@pages)
  {
    print     "\"$page\"," ;
    print OUT "\"$page\"," ;
  }
  print OUT "\n" ;
  for $hour (sort keys %hours)
  {
    print OUT "$hour," . $dates_excel{$hour} . "," ;
    for $page (@pages)
    {
      print OUT $pages_timed {"$page $hour"} . "," ;
    }
    print OUT "\n" ;
  }
}

sub RankPagesViewedWk
{
  open IN, '<','scan_pagecounts_wk.txt' ;
  open OUT,'>','scan_pagecounts_wk_sorted.txt' ;

  while ($line = <IN>)
  {
    chomp $line ;
    ($project,$page,$requests,$bytes) = split (' ', $line) ;

    $requests {"$project $page"} = $requests ;
  }

  for $page (sort {$requests {$b} <=> $requests {$a}} keys %requests)
  {
    print OUT $requests {$page} . ": $page\n" ;

    last if $lines++ > 1000 ;
  }
}
