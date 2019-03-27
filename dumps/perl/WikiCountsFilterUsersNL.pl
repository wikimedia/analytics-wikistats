#!/usr/bin/perl

  use Time::Local ;

  $|       = 1; # Flush output
  $verbose = 1 ;
  $true    = 1 ;
  $false   = 0 ;

  $file_csv_in  = "/home/ezachte/wikistats_data/dumps/csv/csv_wp/EditsPerUserPerMonthPerNamespaceNL.csv" ;
  $file_csv_out = "/home/ezachte/wikistats_data/dumps/csv/csv_wp/EditsPerUserPerMonthPerNamespaceNLFiltered.csv" ;

  die "Xml file not found!" if ! -e $file_csv_in ;

  open CSV_IN,  '<', $file_csv_in ;
  open CSV_OUT, '>', $file_csv_out ;

  binmode CSV_IN ;
  binmode CSV_OUT ;

  &Filter ;

  print "\nReady\n" ;
  exit ;

sub Filter
{
  my $user          = '' ;
  my $user_prev     = '' ;
  my $tot_edits     = 0 ;
  my $talk_edits    = 0 ;
  my $article_edits = 0 ;

  while ($line = <CSV_IN>)
  {
    ($user,$userid,$month,$namespace,$edits) = split (',', $line) ;
    next if $month lt '2017-11' ;
  # print $line ;
    if (($user ne $user_prev) && ($user_prev ne ''))
    { 
      if ($tot_edits >= 250) 
      { print CSV_OUT  "$user_prev,$tot_edits,$article_edits,$talk_edits\n" ; }
      $tot_edits     = 0 ;
      $article_edits = 0 ;
      $talk_edits    = 0 ;
    }
    # print CSV_OUT "1,$user,$month\n" ;
    
    if ($namespace % 2 == 0)
    { $article_edits += $edits ; }
    else
    { $talk_edits += $edits ; }
    $tot_edits += $edits ;

    $user_prev     = $user ;
  # last if $lines++ > 100 ;
  # print "1 $user,$tot_edits,$article_edits,$talk_edits\n" ; 
  }

  if ($tot_edits >= 250) 
  { print CSV_OUT  "$user_prev,$tot_edits,$article_edits,$talk_edits\n" ; }
}


