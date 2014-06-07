#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit_concise = $true ;


# Copyright (C) 2003-2005 Erik Zachte , email erikzachte\@xxx.com (nospam: xxx=infodisiac)
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, at
# http://www.fsf.org/licenses/gpl.html

  # use warnings ;
  # use strict 'vars' ;

  $search = "anquetil" ;
# $search = "(?:tessiture|instruments)" ;
# $search = "451\.\*455" ;
# $search = "Adams.*Wilson" ;
#  $search = "Clement" ;
  $showcode   = $false ;
  $horizontal = $true ;

  &Scan ("D:/Wikipedia/\@out_wp/EN", $search) ;
  exit ;

sub Scan
{
  $dir = shift ;
  if (!-e $dir)
  {
    print "dir $dir no found\n" ;
    return ;
  }

  open "FILE_OUT", ">", "TimelinesSelection.htm" ;
  if ($horizontal)
  { print FILE_OUT "<table><tr>" ; }

  chdir ($dir) || die "Cannot chdir to $dir\n";
  local (*DIR);
  opendir (DIR, ".");
  while ($file = readdir (DIR))
  {
#   if ($file eq "." || $file eq "..")
#   { next ; }
    if ((-d $file) || ($file !~ /Timelines[A-Z]+\.htm/))
    { next ; }
    @stats = stat ($file) ;
    if ($#stats < 0) { next ; }

    $filecnt++ ;
    print "$filecnt\: $file\n";

    &ScanFile ($file) ;
  }

  closedir(DIR);
  chdir("..");
  print "\n\nFiles $filecnt Dirs $dircnt\n\n" ;

  if ($horizontal)
  { print FILE_OUT "</tr></table>" ; }
  close "FILE_OUT" ;
}

sub ScanFile
{
  my $file = shift ;

  open "FILE_IN", "<", $file ;
  while ($line = <FILE_IN>)
  {
    if ($line =~ /<hr>/)
    { undef ($html) ; }
    $html .= $line ;
    if ($line =~ /<\/pre><\/div>/)
    {
      &Test ($html) ;
      undef ($html) ;
    }
  }
}

sub Test
{
  if ($html !~ /$search/is)
  { return ; }

  if (! $showcode)
  { $html =~ s/<pre>.*$//s ; }

  $html =~ s/<p>// ;
  $html =~ s/<td align='right'><a href='#top'>.*?<\/td>// ;
  $html =~ s/<br><div style='background-color: #FFDEAD'>// ;
  if ($horizontal)
  {
    $html =~ s/<br>// ;
    print FILE_OUT "<td valign='top'>$html</td>" ;
  }
  else
  { print FILE_OUT $html ; }
}
