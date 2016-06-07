
&calc ('wp','IL','he') ;
&calc ('wp','IL','en') ;
&calc ('wp','SA','ar') ;
&calc ('wp','SA','en') ;
&calc ('wp','NL','nl') ;
&calc ('wp','NL','en') ;


sub calc
{
  my ($filter_project, $filter_country, $filter_language) = @_ ;
  print "\n\nproject=$filter_project, country=$filter_country, language=$filter_language\n\n" ;

  open IN, '<', "/a/wikistats_git/squids/csv/SquidDataVisitsPerCountryMonthly.csv" ;
  while ($line = <IN>)
  {
    chomp $line ;

    ($yyyymm,$project,$language,$country,$user,$count) = split (',', $line) ;
    
    $project =~ s/[^a-z]//g ;
  
    next if $project ne $filter_project ;
    next if $country ne $filter_country ;
    next if $user ne 'U' ;
  
    # print "$project $language $country $count\n" ; 

    $yyyy = substr ($yyyymm,0,4) ;

    $years  {$yyyy}++ ;
    $months {$yyyymm}++ ;

    $totals {$yyyymm} += $count ;
    if ($language eq $filter_language)
    { $part {$yyyymm} += $count ; }
  
    $totals {$yyyy} += $count ;
    if ($language eq $filter_language)
    { $part {$yyyy} += $count ; }
  }

  my ($filter_project, $filter_country, $filter_language) = @_ ;
  open OUT, '>', "/a/wikistats_git/squids/csv/SquidDataVisitsPerCountryMonthly_proj-${filter_project}_country-${filter_country}_lang-${filter_language}.csv" ;

  foreach $key (sort keys %years)
  {
    $share = sprintf ("%.1f", 100 * $part {$key} / $totals {$key}) . "\%" ;
    print "$key,$share\n" ;
    print OUT "$key,$share\n" ;
  }
  
  print OUT "\n" ;

  foreach $key (sort keys %months)
  {
    $share = sprintf ("%.1f", 100 * $part {$key} / $totals {$key}) . "\%" ;
  # print "$key,$share\n" ;
    print OUT "$key,$share\n" ;
  }
}
