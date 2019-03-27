#!/usr/bin/perl

$file_csv1 = "/home/ezachte/wikistats_data/dumps/csv/csv_wp/TraceEditsDE.csv" ;
$file_csv2 = "/home/ezachte/wikistats_data/dumps/csv/csv_wp/EditsTimestampsTitlesDE_2004_05_ns0.csv" ;
$file_missing_titles = "/home/ezachte/wikistats_data/dumps/csv/csv_wp/EditsTitlesMissingDE_2004_05_ns0.csv" ;

#$file_csv1 = "/home/ezachte/wikistats_data/dumps/csv/csv_wp/TraceEditsDE.csv" ;
#$file_csv2 = "/home/ezachte/wikistats_data/dumps/csv/csv_wp/TraceEditsDE2.csv" ;
#$file_missing_titles = "/home/ezachte/wikistats_data/dumps/csv/csv_wp/TraceEditsDiffDE.csv" ;

die "File not found '$file_csv1'" if ! -e $file_csv1 ;
die "File not found '$file_csv2'" if ! -e $file_csv2 ;

open CSV1, '<', $file_csv1 ;
while ($line = <CSV1>)
{
# next if $line !~ /Urbanus/ ;
  chomp $line ;
# print "$line\n" ;
# exit if ++$lines > 10 ;
  my ($namespace,$timestamp,$title,$user) = split (',', $line) ;
# next if $namespace ne '0' ;
#  next if $timestamp !~ /\-/ ;
  $title =~ s/ .*$// ;
# print "CSV1: '$title'\n" ;

# $timestamp2 = substr ($timestamp, 0,4) . '-' .
#               substr ($timestamp, 4,2) . '-' . 
#               substr ($timestamp, 6,2) . 'T' .
#               substr ($timestamp, 8,2) . ':' .
#               substr ($timestamp,10,2) . ':' .
#               substr ($timestamp,12,2) . 'Z' ;


# print "$timestamp,$timestamp2\n" ;
  $edits1  {"$title,$timestamp"} ++ ;
  $titles1 {$title} ++ ;
}

open CSV2, '<', $file_csv2 ;
while ($line = <CSV2>)
{
# next if $line !~ /Urbanus/ ;
  chomp $line ;
# print "$line\n" ;
# exit if ++$lines > 10 ;
  my ($namespace,$timestamp,$title,$user) = split (',', $line) ;
  next if $namespace ne '0' ;
  next if $timestamp !~ /\-/ ;
  $title =~ s/ .*$// ;
# print "CSV2: '$title'\n" ;

# $timestamp2 = substr ($timestamp, 0,4) . '-' .
#               substr ($timestamp, 4,2) . '-' . 
#               substr ($timestamp, 6,2) . 'T' .
#               substr ($timestamp, 8,2) . ':' .
#               substr ($timestamp,10,2) . ':' .
#               substr ($timestamp,12,2) . 'Z' ;


# print "$timestamp,$timestamp2\n" ;
  $edits2  {"$title,$timestamp"} ++ ;
  $titles2 {$title} ++ ;
}

if (0)
{
$lines = 0 ;
open CSV2, '<', $file_csv2 ;
open OUT,  '>', $file_missing_titles ;
while ($line = <CSV2>)
{
# next if $line !~ /Urbanus/ ;
  next if $line =~ /^#/ ;
  chomp $line ;
# print "$line\n" ;
# exit if ++$lines > 10 ;
  my ($wiki,$edit,$type,$timestamp,$timestamp2,$namespace,$namespace_text,$title,$user) = split (',', $line) ;
#  next if $namespace ne '0' ;
  next if $timestamp !~ /^2004-05/ ;
  $title =~ s/ .*$// ;
# print "CSV2: '$title'\n" ;

  $edits2  {"$title,$timestamp"} ++ ;
  $titles2 {$title} ++ ;

  if ($titles1 {$title} == 0)
  { 
    if ($title ne $prev_title)
    { 
      print "missing title in csv1: $title\n" ; 
      print OUT "$title\n" ;
    # last if ++$titles_missing > 50 ;
    }
  }
  $prev_title = $title ;
}
}

@edits1 = keys %edits1 ;
@edits2 = keys %edits2 ;

print "edits1: " . ($#edits1 + 1) . "\n" ;
print "edits2: " . ($#edits2 + 1) . "\n" ;

@titles1 = keys %titles1 ;
@titles2 = keys %titles2 ;

print "titles1: " . ($#titles1 + 1) . "\n" ;
print "titles2: " . ($#titles2 + 1) . "\n" ;


