#!/usr/local/bin/perl

use URI::Escape;

open IN, '<', "/a/dammit.lt/pagecounts/temp/x" ;
# open OUT1, '>', "/a/dammit.lt/pagecounts/temp/x1" ;
open OUT2, '>', "/a/dammit.lt/pagecounts/temp/x2b" ;

while ($title = <IN>)
{
  chomp $line ;
  ($lang,$title,$bytes) = split (' ', $title) ;
# $title1 = uri_escape   $title ;
  $title2 = uri_unescape $title ;
  $title2 = uri_unescape $title2 ;
# $title3 = uri_escape   $title2 ;

# $title1 =~ s/\%([a-fA-F0-9]{2})/ 

# print "\no $title\n" ;
# print "1 $title1\n" ;
# print "2 $title2\n" ;
# print "2b$title3\n" ;

# print OUT1 "$lang $title1 $bytes\n" ;
  print OUT2 "$lang $title2 $bytes\n" ;

# print      "$lang $title1 $bytes\n" ;
# print      "$lang $title2 $bytes\n" ; 

# last if $titles++ > 20 ;
  $titles++ ;
  print "$titles\n" if $titles % 1000000 == 0 ; 
}

