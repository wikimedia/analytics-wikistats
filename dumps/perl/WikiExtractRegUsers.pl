#!/usr/bin/perl

use CGI::Carp qw(fatalsToBrowser);
use Getopt::Std ;

getopt ("f", \%options) ;

if (-e "/home/ezachte/")
{
  $file_users = $options {"f"} ;
  if ($file_users eq "") { die "Specify -f inputfile" ; }

  $file_csv = $file_users ;
  $file_csv =~ s/^.*\/([^\/]*)$/$1/ ;
  $file_csv =~ s/^(.*\.)[^\.]*$/$1/ ;
  $file_csv .= 'csv' ;
}
else
{
  $file_users = "w:/# in dumps/fywiki-20090619-stub-meta-history.xml" ;
  $file_csv   = "w:/# in dumps/fywiki-20090619-stub-meta-history.csv" ;
}

print "Read  $file_users\n" ;
print "Write $file_csv\n" ;

if (! -e $file_users) { die "File $file_users not found" ; }

if ($file_users =~ /\.gz$/)
{ open XML, "-|", "gzip -dc \"$file_users\"" || abort ("Input file " . $file_users . " could not be opened.") ; }
elsif ($file_users =~ /\.bz2$/)
{ open XML, "-|", "bzip2 -dc \"$file_users\"" || abort ("Input file " . $file_users . " could not be opened.") ; }
elsif ($file_users =~ /\.7z$/)
{ open XML, "-|", "./7za e -so \"$file_users\"" || abort ("Input file " . $file_users . " could not be opened.") ; }
else
{ open XML, "<", $file_users || abort ("Input file " . $file_users . " could not be opened.") ; }

open CSV, ">", $file_csv ;

binmode XML ;
binmode CSV ;

while ($line = <XML>)
{
  &Log ("\nParse namespace tags\n\n") ;
  while ($line = <XML>)
  {
    $bytes_read += length ($line) ;
    if ($line =~ /<namespaces>/) { last ; }
  }

  while ($line = <XML>)
  {
    $bytes_read += length ($line) ;
    if ($line =~ /<namespace /)
    {
      chomp $line ;
      $key  = $line ;
      $name = $line ;
      $key  =~ s/^.*key="([^\)]*)".*$/$1/ ;

      if ($line =~ /<namespace[^>]*\/>\s*$/)
      { $name = "" ; }
      else
      { $name =~ s/^.*<namespace[^\]]*>([^\]]*)<.*$/$1/ ; }

      $log .= sprintf ("%4s",$key) . " -> '$name'\n" ;
      $namespaces    {$name} = $key ;
    }
    if ($line =~ /<\/namespaces>/) { last ; }
  }
  &Log ($log) ;

  while ($line = <XML>)
  {
    $bytes_read += length ($line) ;
    if ($line =~ /<\/siteinfo>/) { last ; }
  }

  &Log ("\nParse revisions\n\n") ;
  while ($line = <XML>)
  {
    $bytes_read += length ($line) ;
    if ($line =~ /<title>.*?<\/title>/)
    {
      chomp ($line) ;

      $title = $line ;
      $title =~ s/^.*<title>(.*)<\/title>.*$/$1/ ;

      $namespace = 0 ;
      if ($title =~ /\:./)
      {
        $name = $title ;
        $name =~ s/\:.*$// ;
        $namespace = $namespaces {$name} + 0 ; # enforce numeric
      }
    }

    if ($line =~ /<timestamp>.*?<\/timestamp>/)
    {
      chomp ($line) ;

      $time = $line ;
      $time =~ s/^.*<timestamp>(.*)<\/timestamp>.*$/$1/ ;
    }

    if ($line =~ /<username>.*?<\/username>/)
    {
      chomp ($line) ;

      $name = $line ;
      $name =~ s/^.*<username>(.*)<\/username>.*$/$1/ ;

      print CSV "$name,$time,$namespace\n" ;
    }

    if ($line =~ /<ip>.*?<\/ip>/)
    {
      chomp ($line) ;

      $ip = $line ;
      $ip =~ s/^.*<ip>(.*)<\/ip>.*$/$1/ ;

    #  print CSV "[ip],$time,$namespace\n" ;
    }
  }

  print "\n\nReady\n\n" ;
  exit ;
}

close XML ;
close OUT ;

#$file_users =~ s/.*\///g ;
#$file_users =~ s/\..*// ;

#if (-e "/home/ezachte/")
#{ $file_users = "/a/wikistats/csv_wp/$file_users\.csv" ; }
#else
#{ $file_users = "c:/$file_users\.csv" ; }

#open CSV, '>', $file_users ;
#foreach $month (sort keys %reg_months)
#{
#  print CSV "$month," . $reg_months {$month} . "\n" ;
#  print "$month," . $reg_months {$month} . "\n" ;
#}
#close CSV ;

sub Log
{
  my $msg = shift ;
  print $msg ;
}

