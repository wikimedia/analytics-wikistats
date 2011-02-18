#!/usr/local/bin/perl

# 27 April 2010 renamed from WikiStatsCollectViewsOneArticle.pl

  use CGI qw(:all);
  use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ; # install IO-Compress-Zlib
  use IO::Compress::Gzip     qw(gzip   $GzipError) ;   # install IO-Compress-Zlib

  $| = 1; # flush screen output
  $true  = 1 ;
  $false = 0 ;
  $mode = "H" ; # daily files as opposed to H

# $dir0 = "D:/Wikipedia_Visitors/full_day" ;
  $dir0 = "D:/Wikipedia_Visitors" ;
  chdir ($dir0) || die "Cannot chdir to $dir0\n";

# open TXT, ">", "JoeBiden.txt" ;
# open TXT, ">", "FalungGong.txt" ;
# &ProcessMonth (2008,7) ;
# &ProcessMonth (2008,8) ;
# close TXT ;

  &ProcessSelection ;

  exit ;

sub ProcessSelection
{
  open "IN",  "<", "FalungGong.txt" ;
  open "OUT", ">", "FalungGongTotals.csv" ;
  while ($line = <IN>)
  {
    chomp ($line) ;
    $line =~ s/\s+/ /g ;
    ($timestamp, $project, $count, $title) = split (' ', $line) ;
  # $timestamp =~ s/\d\d\d\d$// ; # discard minutes and seconds
    $timestamp =~ s/\-\d\d\d\d\d\d$// ; # discard hours, minutes and seconds
    if ($project eq "zh")
    { @counts_zh    {$timestamp} += $count ; }
    else
    { @counts_other {$timestamp} += $count ; }
  }
  close IN ;

foreach $date (sort keys %counts_zh)
{
  $year  = substr ($date,0,4) ;
  $month = substr ($date,4,2) ;
  $day   = substr ($date,6,2) ;
  $timestamp = sprintf ("%02d/%02d/%04d", $day, $month, $year) ;
  print OUT $timestamp . "," . (@counts_zh {$date}) . "\n" ;
}

if (0)
{
  $month = 7 ;
  for $day (1..31)
  {
    for $hour (0..23)
    {
      $timestamp  = sprintf ("%04d%02d%02d-%02d", 2008, 7, $day, $hour) ;
      $timestamp2 = sprintf ("%02d/%02d/%04d %02d:%02d", $day, 7, 2008, $hour, 0) ;
      print OUT $timestamp2 . "," . (@counts_zh {$timestamp}+0) . "," . (@counts_other {$timestamp}+0) . "\n" ;
    }
  }

  $month = 8 ;
  for $day (1..31)
  {
    for $hour (0..23)
    {
      $timestamp  = sprintf ("%04d%02d%02d-%02d", 2008, 8, $day, $hour) ;
      $timestamp2 = sprintf ("%02d/%02d/%04d %02d:%02d", $day, 8, 2008, $hour, 0) ;
      print OUT $timestamp2 . "," . (@counts_zh {$timestamp}+0) . "," . (@counts_other {$timestamp}+0) . "\n" ;
    }
  }

  $month = 9 ;
  for $day (1..14)
  {
    for $hour (0..23)
    {
      $timestamp  = sprintf ("%04d%02d%02d-%02d", 2008, 9, $day, $hour) ;
      $timestamp2 = sprintf ("%02d/%02d/%04d %02d:%02d", $day, 9, 2008, $hour, 0) ;
      print OUT $timestamp2 . "," . (@counts_zh {$timestamp}+0) . "," . (@counts_other {$timestamp}+0) . "\n" ;
    }
  }
}
  close OUT ;
}

sub ProcessMonth
{
  my $year  = shift ;
  my $month = sprintf ("%02d", shift) ;

  $dir0 =~ s/[\\\/]$// ;

  $dir_in = "$dir0/$year-$month-pagecounts" ;
  &Log ("Process year $year month $month from '$dir_in'\n") ;
  chdir ($dir_in) || die "Cannot chdir to $dir_in\n";
  local (*DIR);

  opendir (DIR, ".");
  @files = () ;
  while ($file_in = readdir (DIR))
  {
    if ($mode eq "H")
    {
      if ($file_in !~ /^pagecounts-\d{8,8}-\d{6,6}.gz$/)
      { next ; }
      if ($file_in lt "pagecounts-20080816-000000.gz")
      { next ; }
#     if ($file_in ge "pagecounts-20080831-000000.gz")
#     { next ; }
    }
    if ($mode eq "D")
    {
      if ($file_in !~ /^pagecounts-\d{8,8}_fd.gz$/)
      { next ; }
#     if ($file_in lt "pagecounts-20080801_fd.gz")
#     { next ; }
#     if ($file_in ge "pagecounts-20080831_fd.gz")
#     { next ; }
    }
    push @files, $file_in ;
  }
  closedir (DIR, ".");

  @files = sort {$a cmp $b} @files ;

  foreach $file (@files)
  { &ProcessFile ($file) ; }
}

sub ProcessFile
{
  my $file = shift ;
  $date = substr ($file, 11, 8) ;
  $time = substr ($file, 20, 6) ;
  print "ProcessFile ($file)\n" ;

  my $lines ;
  $in_gz = IO::Uncompress::Gunzip->new ($file) or die "IO::Uncompress::Gunzip failed for '$file': $GunzipError\n";
  binmode $in_gz ;
  while ($line = <$in_gz>)
  {
  #  if ($line ge "eo")
  #  { last ; }
  #  if ($line !~ /^en /)
  #  { next ; }
  #  if ($lines ++ == 0) { print "$line" ; }

#   if ($line =~ /sarah.*palin/i)
#   if ($line =~ /joe.*biden/i)
    if ($line =~ / \%E6\%B3\%95\%E8\%BD\%AE\%E5\%8A\%9F /)
    {
      if ($mode eq "H")
      {
        ($wiki,$title,$views,$bytes) = split (' ', $line) ;
        $line = sprintf ("%-10s", $wiki) . " " . sprintf ("%8d",$views) . " $title\n" ;
        print "$date-$time $line" ;
        print TXT "$date-$time $line" ;
      }
      if ($mode eq "D")
      {
        chomp ($line) ;

        ($wiki,$title,$views_all_day) = split (' ', $line) ;
        $wiki =~ s/\.z// ;
        $wiki =~ s/\.y/2/ ;
        $views_all_day =~ s/^\d+// ; # remove (redundant) preceding total
        while ($views_all_day ne "")
        {
          $letter = substr ($views_all_day,0,1) ;
          $views_all_day = substr ($views_all_day,1) ;
          ($views_one_hour = $views_all_day) =~ s/^(\d+).*$/$1/ ;
          $views_all_day =~ s/^\d+(.*)$/$1/ ;
          $time = sprintf ("%02d",ord ($letter) - ord ('A')) . "0000" ;

          $line = sprintf ("%-10s", $wiki) . " " . sprintf ("%8d",$views_one_hour) . " $title\n" ;
          print "$date-$time $line" ;
          print TXT "$date-$time $line" ;
        }
      }
    }
  }

  $in_gz->close() ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print LOG $msg ;
}

