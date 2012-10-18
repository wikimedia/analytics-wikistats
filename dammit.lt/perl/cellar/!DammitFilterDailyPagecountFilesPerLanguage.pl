#!/usr/bin/perl

# 27 April 2010 renamed from WikiStatsFilterCompactedDammitFilesPerLanguage.pl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Net::Domain qw (hostname);

  $language  = "nl" ;
  $wikipedia = "$language.wikipedia.org" ;       # read from input

  $path_in  = "." ;
  $path_out = "." ;
  if ($hostname eq "bayes")
  {
    $path_in  = "/a/dammit.lt/pagecounts" ;
    $path_out = "/a/dammit.lt/pagecounts/languages/$language.z" ;
    if (! -d $path_out)
    { mkdir $path_out, 0777 ; }
    $path_7za = "/usr/lib/p7zip/7za" ;
  }

  $month = 8 ;
  $year = 2008 ;
  $yyyymm = sprintf ("%04d-%02d", $year, $month) ;
  $path_in_monthly = "$path_in/$yyyymm" ;
  while (-d $path_in_monthly)
  {
    print "\nCheck dir $path_in_monthly\n" ;

    $file_filtered = "$path_out/pagecounts-$yyyymm-$language-fdt.txt" ;

    if ($hostname eq "bayes")
    {
      $file_filtered_7z = "$file_filtered.7z" ;

      if (-e $file_filtered_7z)
      { print "File $file_filtered_7z already exists\n" ; }
      else
      { &FilterCounts ($yyyymm, $file_filtered) ; }
    }
    else
    { &FilterCounts ($yyyymm, $file_filtered) ; }

    $month++ ;
    if ($month > 12)
    { $month = 1 ; $year++ ; }
    $yyyymm = sprintf ("%04d-%02d", $year, $month) ;
    $path_in_monthly = "$path_in/$yyyymm" ;
  }

  print "\n\nReady\n\n" ;
  exit ;

sub FilterCounts
{
  my ($yyyymm, $file_filtered) = @_ ;
  ($yyyymm2 = $yyyymm) =~ s/-// ;

  open OUT, '>', $file_filtered ;

  print OUT "# Counts for articles with less than a few requests per full day (before April 2010 five per day, from then on two per day) were not preserved in daily archives and hence are neither included here\n" ;
# print OUT "# Subproject is language code, followed by project code\n" ;
# print OUT "# Project is b:wikibooks, k:wiktionary, n:wikinews, q:wikiquote, s:wikisource, v:wikiversity, z:wikipedia (z added by compression script: wikipedia happens to be sorted last in dammit.lt files)\n" ;
  print OUT "# Counts format is total per day, followed by count per hour if larger than zero, hour 0..23 shown as A..X (saves up to 22 bytes per line compared to comma separated values)\n" ;
  print OUT "# If data are missing for some hour (file missing or corrupt) a question mark (?) is shown (and for each missing hour the daily total is incremented with hourly average)\n" ;
  print OUT "# Lines starting with ampersand (@) show totals per 'namespace' (including omitted counts for low traffic articles)\n" ;
  print OUT "# Since valid namespace string are not known in the compression script any string followed by colon (:) counts as possible namespace string\n" ;
  print OUT "# Please reconcile with real namespace name strings later\n" ;
  print OUT "# 'namespaces' with count < 5 are combined in 'Other' (on larger wikis these are surely false positives)\n" ;
  print OUT "# Page titles are shown unmodified (preserves sort sequence)\n" ;


  for ($day = 1 ; $day <= 31 ; $day++)
  {
    $yyyymmdd = "$yyyymm-" . sprintf ("%02d", $day) ;

    $file_pagecounts = "$path_in/$yyyymm/pagecounts-$yyyymm2" . sprintf ("%02d", $day) . "_fdt" ;
    if ($hostname eq "bayes")
    { $file_pagecounts .= ".7z" ; }


    if (! -e $file_pagecounts)
    {
      print "\nNot found: $file_pagecounts\n" ;
      print OUT "# $yyyymmdd missing!\n" ;
      next ;
    }

    print "Read $file_pagecounts\n" ;
    print OUT "# $yyyymmdd\n" ;

    if ($hostname eq "bayes")
    { open IN, "-|", "./7za e -so \"$file_pagecounts\"" || die ("Input file '" . $file_pagecounts . "' could not be opened.") ; }
    else
    { open IN,  '<', $file_pagecounts ; }

    while ($line = <IN>)
    {
      $ch = substr ($line,0,1) ;

      next if $ch eq '#' ;  # comments

      if ($ch eq '@') # summary per language project
      {
        if ($line =~ /^\@ $language\.z /o)
        { print OUT $line ; }
        next ;
      }

      next if $line lt "$language.z" ;
      last if $line !~ /$language.z / ;

      ($project, $title, $counts) = split (' ', $line) ;
      print OUT "$title $counts\n" ;
    }
    close IN ;
  }
  close OUT ;

  $cmd = "$path_7za a $file_filtered.7z $file_filtered" ;
  $result = `$cmd` ;

  if ($result =~ /Everything is Ok/s)
  {
    $result =~ s/^.*?(Updating.*?)\n.*$/$1 -> OK/s ;
    unlink $file_filtered ;
  }
  else
  {
    print "Delete $file_filtered.7z\n" ;
    unlink "$file_filtered.7z" ;
  }

  print "$cmd -> $result\n" ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
}

sub Abort
{
  $msg = shift ;
  print "Abort script\nError: $msg\n" ;
  exit ;
}



