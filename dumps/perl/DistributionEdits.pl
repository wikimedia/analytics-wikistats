#!/usr/bin/perl

  my $sqrt10 = sqrt (10) ;
  my $bins = 15 ;
  my $users_tot = 0 ;
  my $edits_tot = 0 ;
  my (@edits_min, @edits, @users) ;
  $j = 1 ;
  for ($i = 0 ; $i < $bins ; $i++)
  { @edits_min [$i] = $j - 0.01 ; $j *= $sqrt10 ; }

# &Tally ("D:/WikiStats/# Out Bayes/csv_wp") ;
  &Tally ("/a/wikistats/csv_wb") ;
  &Tally ("/a/wikistats/csv_wk") ;
  &Tally ("/a/wikistats/csv_wn") ;
  &Tally ("/a/wikistats/csv_wp") ;
  &Tally ("/a/wikistats/csv_wq") ;
  &Tally ("/a/wikistats/csv_ws") ;
  &Tally ("/a/wikistats/csv_wv") ;
  &Tally ("/a/wikistats/csv_wx") ;

  exit ;

sub Tally
{
  $dir = shift ;
  chdir $dir || die "Could not change to $dir\n" ;
  $file_in = "$dir/StatisticsUsers.csv" ;
  if (! -e $file_in) { die "File $file_in not found\n" ; }
  print "Tally $file_in\n" ;

  $file_out = "StatisticsEditDistribution.csv" ;
  open OUT, '>', $file_out ;

  $langprev = "" ;
  open IN, '<', $file_in ;
  while ($line = <IN>)
  {
    if ($line =~ /^\s*$/) { last ; }
    my ($lang, $edits_namespace_0) = split (',', $line) ;
    if (($lang =~ /^\s*$/) || ($edits_namespace_0 =~ /^\s*$/)){ next ; }
    if (($lang ne $langprev) && ($langprev ne ""))
    {
      for ($i = 0 ; $i < $bins ; $i++)
      {
        if (@users [$i] == 0) { last ; }

        $line = &csv($langprev) .
                &csv($i) .
                &csv(sprintf ("%.0f", @edits_min [$i])) .
                &csv(@users [$i]) .
                &csv(sprintf ("%.1f\%", 100 * (@users [$i] / $users_tot))) .
                &csv(@edits [$i]) .
                &csv(sprintf ("%.1f\%", 100 * (@edits [$i] / $edits_tot))) ;
        $line =~ s/,$// ;
        print OUT "$line\n" ;
      }

      $users_tot = 0 ;
      $edits_tot = 0 ;
      @users = () ;
      @edits = () ;
    }

    $users_tot ++ ;
    $edits_tot += $edits_namespace_0 ;

    for ($i = 0 ; $i < $bins ; $i++)
    {
      if (@edits_min [$i] <= $edits_namespace_0)
      {
        @users [$i] ++ ;
        @edits [$i] += $edits_namespace_0 ;
      }
    }
    $langprev = $lang ;
  }

  for ($i = 0 ; $i < $bins ; $i++)
  {
    if (@users [$i] == 0) { last ; }

    $line = &csv($langprev) .
            &csv($i) .
            &csv(sprintf ("%.0f", @edits_min [$i])) .
            &csv(@users [$i]) .
            &csv(sprintf ("%.1f\%", 100 * (@users [$i] / $users_tot))) .
            &csv(@edits [$i]) .
            &csv(sprintf ("%.1f\%", 100 * (@edits [$i] / $edits_tot))) ;
    $line =~ s/,$// ;
    print OUT "$line\n" ;
  }

  close IN ;
  close OUT ;
}

sub csv
{
  my $s = shift ;
  return (&csv2($s) . ",") ;
}

sub csv2
{
  my $s = shift ;
  if (defined ($s))
  {
    $s =~ s/^\s+// ;
    $s =~ s/\s+$// ;
    $s =~ s/\,/&#44;/g ;
  }
  if ((! defined ($s)) || ($s eq ""))
  { $s = 0 ; } # not all fields are numeric, but those that aren't are never empty
  return ($s) ;
}
