#!/usr/bin/perl
#
#Q&D POC script to produce data for iPad app 'Status Board'
#
  &ReadData ('wb') ;
  &ReadData ('wk') ;
  &ReadData ('wn') ;
  &ReadData ('wo') ;
  &ReadData ('wp') ;
  &ReadData ('wq') ;
  &ReadData ('ws') ;
  &ReadData ('wv') ;
  &ReadData ('wx') ;
  &WritePageviewsTrend ;
  &WritePageviewsRecent ;
  print "\nReady\n\n" ;
  exit ;

sub ReadData
{
  my ($project) = @_ ;

  open CSV_IN, '<', "/a/wikistats_git/dumps/csv/csv_$project/PageViewsPerDayAll.csv";
  while ($line = <CSV_IN>)
  {
    chomp $line ;
    ($lang,$date,$count) = split (',', $line) ; 
    # $yy = substr ($date,0,4) ;
    # $mm = substr ($date,5,2) ;
    # $dd = substr ($date,8,2) ;

    if ($lang =~ /\.m/)
    { $mobile = 'M' ; }
    else
    { $mobile = '-' ; }
    $totals {"$project,$mobile,$date"} += $count ;

    $dates {$date} ++ ;
  }

  close CSV_IN ;
}

sub WritePageviewsTrend
{
  @dates = sort keys %dates ;
  my ($days,$date,$main,$mobile,$total) ;
  open CSV_OUT, '>', '/a/wikistats_git/dumps/csv/csv_wp/PageViewsPerDay-SB-Trend.csv' ;
  print CSV_OUT "Page views Wikipedia - weekly avg (MM),total,main site,mobile site\n" ;
# foreach $date (sort keys %totals)
  foreach $date (@dates) # for (d = $#dates - 7 * 365 ; $d <= $#dates ; $d++)
  { 
  # $date = $dates [$d] ;
    $main   += &MM ($totals {"wp,-,$date"}) ;
    $mobile += &MM ($totals {"wp,M,$date"}) ;
    $total  += &MM ($totals {"wp,-,$date"}) + &MM ($totals {"wp,M,$date"}); 

    if (++$days % 7 == 0)
    {
      $main   = sprintf ("%.0f", $main   / 7) ;	    
      $mobile = sprintf ("%.0f", $mobile / 7) ;	    
      $total  = sprintf ("%.0f", $total  / 7) ;	    
      print CSV_OUT "$date,$total,$main,$mobile\n" ;
      $main   = 0 ;
      $mobile = 0;
      $total  = 0 ;
    }
  # if ($lines++ == 0)
  # $total = 1000 ; }
  }
  print CSV_OUT "colors,mediumGray,blue,green\n" ;
  close CSV_OUT ;

  print "\nReady\n\n" ;
}

sub WritePageviewsRecent
{
  @dates = sort keys %dates ;
  my ($days,$date,$main,$mobile,$total,$lines) ;
  open CSV_OUT, '>', '/a/wikistats_git/dumps/csv/csv_wp/PageViewsPerDay-SB-Recent.csv' ;
  print CSV_OUT "Page views Wikipedia - daily (MM),total,main site,mobile site\n" ;
# foreach $date (sort keys %totals)
  for ($d = $#dates - 90 ; $d <= $#dates ; $d++)
  { 
    $date = $dates [$d] ;
    $main   = &MM ($totals {"wp,-,$date"}) ;
    $mobile = &MM ($totals {"wp,M,$date"}) ;
    $total  = $main + $mobile ; 
  # $max = $lines++ == 0 ? 1000 : 0 ;
    print CSV_OUT "$date,$total,$main,$mobile\n" ;
  }
# print CSV_OUT "yAxis,1500\n" ;
  print CSV_OUT "colors,mediumGray,blue,green\n" ;
  close CSV_OUT ;

  print "\nReady\n\n" ;
}

sub MM
{
  return (sprintf "%.0f", (shift) / 1000000) ;
}  
