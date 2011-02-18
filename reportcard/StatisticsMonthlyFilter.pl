#!/usr/bin/perl

# scratchpad script, kept for reuse

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;

  open IN,  "<", "StatisticsMonthly.csv" ;
  open OUT, ">", "StatisticsMonthlyExtract.csv" ;

  my ($sec,$min,$hour,$day,$month,$year,$wday,$yday,$isdst) = localtime (time);
  $month += 1 ;
  $year  += 1900 ;
  print "Now: " . sprintf ("%04d:%02d:%02d\n", $year, $month, $day) ;

  $month-- ;
  if ($month < 1) { $month == 12 ; $year-- ; }
  print "Extract from " . sprintf ("%04d:%02d", $year-1, $month) . " till " . sprintf ("%04d:%02d", $year, $month) . "\n" ;

  $month_lo = $month ;
  $year_lo  = $year - 1 ;

  $time_lo = timegm (0,0,0,1   ,$month-1,$year-1-1900) ;
  $time_hi = timegm (0,0,0,&daysinmonth($year,$month),$month-1,$year-1900) ;

  while ($line = <IN>)
  {
    ($wp, $date, $u1, $u2, $u3, $u4, $articles) = split (',', $line) ;
    if ($articles > $max_articles {$wp})
    { $max_articles {$wp} = $articles ; }
  }
  close IN ;

  $wikis = 0 ;
  foreach $wp (sort {$max_articles {$b} <=> $max_articles {$a}} keys %max_articles)
  {
    if (++$wikis > 25) { last ; }
    print "$wp: " . $max_articles {$wp} . "\n" ;
    $filter_wikis {$wp} ++ ;
  }

  open IN,  "<", "StatisticsMonthly.csv" ;
  while ($line = <IN>)
  {
    ($wp, $date, $u1, $u2, $u3, $u4, $articles) = split (',', $line) ;
    if ($filter_wikis {$wp} == 0) { next ; }

    $year  = substr ($date,6,4) ;
    $month = substr ($date,0,2) ;
    $day   = substr ($date,3,2) ;

    $time  = timegm (0,0,0,$day,$month-1,$year-1900) ;

    if (($time < $time_lo) || ($time > $time_hi)){ next ; }
    # print "$wp $date\n" ;
    $articles {"$wp:$date"} = $articles ;
  }
  close IN ;


  $wikis = 0 ;
  foreach $wp (sort {$max_articles {$b} <=> $max_articles {$a}} keys %max_articles)
  {
    if (++$wikis > 25) { last ; }
    $month = $month_lo ;
    $year  = $year_lo ;
    $line = "$wp," ;
    for ($m = 0 ; $m <= 12 ; $m++)
    {
      $date = sprintf ("%02d/%02d/%04d", $month, &daysinmonth($year,$month), $year) ;
      $count = $articles {"$wp:$date"} + 0 ; # force numeric
      $line .= "$count," ;
      $month++ ;
      if ($month > 12)
      { $month = 1 ; $year ++ ; }
    }
    $line =~ s/,$// ;
    print OUT "$line\n" ;
  }


  print "\nReady\n\n" ;
  exit ;

sub daysinmonth
{
  my $year = shift ;
  my $month = shift ;
  if ($month == 0)
  { return (0) ; }
  my $timegm1 = timegm (0,0,0,1,$month-1,$year-1900) ;
  $month++ ;
  if ($month > 12)
  { $month = 1 ; $year++ }
  my $timegm2 = timegm (0,0,0,1,$month-1,$year-1900) ;
  my $days = ($timegm2-$timegm1) / (24*60*60) ;
  return ($days) ;
}



