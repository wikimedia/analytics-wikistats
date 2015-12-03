#!/usr/bin/perl

$file_in  = '/a/wikistats_git/dumps/csv/csv_wp/EditsPerUserPerMonthPerNamespaceAllWikisTemp_285_ENsorted.csv' ;
$file_csv = '/a/wikistats_git/dumps/csv/csv_wp/UsersPerEditFreqWikipedia.csv' ;
die "input not found" if ! -e $file_in ;
open IN, '<', $file_in ;
open CSV, '>', $file_csv ;
$user_prev = '' ;
$total = 0 ;
while ($line = <IN>)
{
  chomp $line ;
  ($user,$yyyymm,$count,$count2) = split (',', $line) ; # count2 is for first 28 days (normalization)
  if (($user ne $user_prev) && ($user_prev ne '')) 
  {
    $edits {$total} ++ ;
    $total = 0 ;
  }
  $total += $count ;
  $user_prev = $user ;
}
$user_count {$total} ++ ;

foreach $total (sort {$edits {$b} <=> $edits {$a}} keys %edits)
{
  if ($total <= 100) 
  { print "$total: " . $edits {$total} . "\n" ; }
  print CSV "$total," . $edits {$total} . "\n" ;
}




