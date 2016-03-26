#!/usr/bin/perl

open BOTS, '<', "/a/wikistats_git/dumps/csv/csv_wp/BotsAll.csv" || die "Could not open input" ;
while ($line = <BOTS>)
{
  last if $line =~ /^nl/ ;
}
print "$line" ;
chomp $line ;
($lang,$bots) = split (',', $line) ;
@bots = split ('\|', $bots) ;
foreach $bot (@bots)
{
  $isbot {$bot} = 1 ;
}
close BOTS ;

open IN, '<', "/a/wikistats_git/dumps/csv/csv_wp/EditsPerUserPerMonthPerNamespaceNL.csv" || die "Could not open input" ;

while ($line = <IN>)
{
  next if $line =~ /^#/ ;
  chomp $line ;
  ($user,$userid,$yyyymm,$ns,$edits) = split (',', $line) ; 

  next if $user eq "an.on.ym.ous" ;  
  next if $yyyymm le '2015-01' ;
  next if $ns != 0 ;

  $edits {$user} += $edits ;
}
close IN ;

$ndx = 0 ;
open CSV, '>', "/home/ezachte/editors_with_75_plus_edits_last_year_NL.csv" ;
foreach $user (sort {$edits {$b} <=> $edits {$a}} keys %edits)
{
  $ndx++ ;
if ($isbot {$user})
{ print "bot $user: " . $edits {$user} . "\n" ; }
else
{ print CSV "$ndx,$user," . $edits {$user} . "\n" ; }

  last if $edits {$user} < 75 ;
}
close CSV ;

 

