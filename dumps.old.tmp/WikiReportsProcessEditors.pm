 #!/usr/bin/perl

sub ProcessEditorStats
{
  &LogT ("\nProcessEditorStats\n\n") ;

  if (! $job_runs_on_production_server)
  {
    &LogT ("Not on Linux system, skip this step, which involves external sort.\n") ;
    return ;
  }

  my (@missing, @updated, $file_age, $merge_files) ;

  $file_csv_edits_user_month_zz          = $path_in . "EditsBreakdownPerUserPerMonthZZ.csv" ;
  $file_csv_edits_user_month_zz_sorted   = $path_in . "EditsBreakdownPerUserPerMonthZZsorted.csv" ;
  $file_csv_edits_user_month_zz_merged   = $path_in . "EditsBreakdownPerUserPerMonthZZmerged.csv" ;
  $file_csv_edits_user_month_zz_articles = $path_in . "EditsBreakdownPerUserPerMonthZZarticles.csv" ;

  $merge_files = $false ;

  if (! -e $file_csv_edits_user_month_zz)
  {
    &LogT ("No merged editor stats found\n") ;
    $merge_files = $true ;
  }
  else
  {
    $file_age_merged = -M $file_csv_edits_user_month_zz ;

    foreach $wp (@languages)
    {
      next if $wp =~ /^zz+$/ ;

      $file_csv_edits_user_month = $path_in . "EditsBreakdownPerUserPerMonth" . uc ($wp) . ".csv" ;
      if (! -e $file_csv_edits_user_month)
      {
        push @missing, $wp ;
        next ;
      }
      $file_age = -M $file_csv_edits_user_month ;
      if ($file_age < $file_age_merged)
      {
        push @updated, $wp ;
        $merge_files = $true ;
      }
    }

    if ($#missing > -1)
    { &LogT ("No editors breakdown file found for language codes: " . join (',', sort @missing) . "\n") ; }
    if ($#updated > -1)
    { &LogT ("New editors breakdown files for: " . join (',', sort @updated) . "\n") ; }
  }

  if ($merge_files)
  { &MergeEditorStats ; }
  else
  { &LogT ("Skip MergeEditorStats, merged editors stats file is up to date\n") ; }
}

sub MergeEditorStats
{
  &LogT ("MergeEditorStats\n\n") ;

  open    EDITS_USER_MONTH_MERGED , '>', $file_csv_edits_user_month_zz ;
  binmode EDITS_USER_MONTH_MERGED ;

  foreach $wp (@languages)
  {
    $file_csv_edits_user_month = $path_in . "EditsBreakdownPerUserPerMonth" . uc ($wp) . ".csv" ;
    next if ! -e $file_csv_edits_user_month ;

    open    EDITS_USER_MONTH_BREAKDOWN, '<', $file_csv_edits_user_month ;
    binmode EDITS_USER_MONTH_MERGED ;

    &Log ("$wp ") ;
    while ($line = <EDITS_USER_MONTH_BREAKDOWN>)
    {
      chomp $line ;
      print EDITS_USER_MONTH_MERGED "$line,$wp\n" ;
    }
    close EDITS_USER_MONTH_BREAKDOWN ;
  }
  close EDITS_USER_MONTH_MERGED ;

  &LogT ("\nSortMergedEditorStats\n") ;

  my $timestartsort = time ;
  $filesize_in = &i2KbMb (-s $file_csv_edits_user_month_zz) ;
  &LogT ("File size $filesize_in\n") ;
  $cmd = "sort $file_csv_edits_user_month_zz -o $file_csv_edits_user_month_zz_sorted -T $path_temp" ;
  $result = `$cmd` ;
  &LogT ("Cmd $cmd -> $result\n") ;
  &LogT ("\nSort took " . ddhhmmss (time - $timestartsort). ".\n") ;

  my ($user,$month,$namespace,$count,$count_28,$lang) ;

  if (! -e  $file_csv_edits_user_month_zz_sorted)
  { abort ("File not found: $file_csv_edits_user_month_zz_sorted") ; }

  open    EDITS_USER_MONTH_SORTED,    '<', $file_csv_edits_user_month_zz_sorted || abort ("File not found: $file_csv_edits_user_month_zz_sorted") ;
  open    EDITS_USER_MONTH_MERGED,    '>', $file_csv_edits_user_month_zz_merged ;
  open    EDITS_USER_MONTH_ARTICLES , '>', $file_csv_edits_user_month_zz_articles ;
  binmode EDITS_USER_MONTH_SORTED ;
  binmode EDITS_USER_MONTH_MERGED ;
  binmode EDITS_USER_MONTH_ARTICLES ;

  print EDITS_USER_MONTH_MERGED   "# Edit counts per registered user per month per namespace, produced by monthly wikistats job\n" ;
  print EDITS_USER_MONTH_MERGED   "# user, month, namespace, edits in whole month, edits in first 28 days (for normalized trends with equal length partial months)\n" ;
  print EDITS_USER_MONTH_ARTICLES "# Edit counts per registered user per month, for articles namespace(s) only, produced by monthly wikistats job\n" ;
  print EDITS_USER_MONTH_ARTICLES "# user, month, edits in whole month, edits in first 28 days (for normalized trends with equal length partial months)\n" ;

  $user_month_ns_prev = '' ;
  $user_month_prev = '' ;
  while ($line = <EDITS_USER_MONTH_SORTED>)
  {
    next if $line =~ /^#/ ;

    chomp $line ;
    my ($user,$month,$namespace,$count,$count_28,$lang) = split (',', $line) ;
    $namespace += 0 ; # remove leading zeroes, used to influence sort order

    if (("$user,$month,$namespace" ne $user_month_ns_prev) &&  ($user_month_ns_prev ne ''))
    {
      print EDITS_USER_MONTH_MERGED "$user_month_ns_prev,$count_all," . ($count_all_28+0) . "\n" ; # only second count can be zero
      $count_all    = $count ;
      $count_all_28 = $count_28 ;
    }
    else
    {
      $count_all    += $count ;
      $count_all_28 += $count_28 ;
    }

    if (&NameSpaceArticle ($wp,$namespace))
    {
      if (("$user,$month" ne $user_month_prev) &&  ($user_month_prev ne ''))
      {
        print EDITS_USER_MONTH_ARTICLES "$user_month_prev,$count_all_a," . ($count_all_28_a+0) . "\n" ; # only second count can be zero
        $count_all_a    = $count ;
        $count_all_28_a = $count_28 ;
      }
      else
      {
        $count_all_a    += $count ;
        $count_all_28_a += $count_28 ;
      }
    }

    $user_month_ns_prev = "$user,$month,$namespace" ;
    $user_month_prev    = "$user,$month" ;
  }
  print EDITS_USER_MONTH_MERGED   "$user_month_ns_prev,$count_all," . ($count_all_28+0) . "\n" ;
  print EDITS_USER_MONTH_ARTICLES "$user_month_prev,$count_all_a," . ($count_all_28_a+0) . "\n" ;

  close EDITS_USER_MONTH_SORTED ;
  close EDITS_USER_MONTH_MERGED ;
  close EDITS_USER_MONTH_ARTICLES ;
}

1;
