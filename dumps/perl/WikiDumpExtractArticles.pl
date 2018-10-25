#!/usr/bin/perl

  $| = 1; # Flush output
 
  use warnings ;
  use strict ;

  our $true  = 1 ;
  our $false = 0 ;

  our $timestart = time ;
  our %select_titles ;
  our %titles_found ;
  our $bytes_processed = 0 ;

  my $time_format = '%2d hrs %2d min %2d sec' ;

  use Getopt::Std ;
  my %options ;
  getopt ("ios", \%options) ;
  our $dir_dumps_in  = $options {"i"} ;
  our $dir_dumps_out = $options {"o"} ;
  our $file_select_titles = $options {"s"} ; # select these titles from total dump

  die "input folder not specified (use -i)"  if $dir_dumps_in  eq '' ; 
  die "output folder not specified (use -o)" if $dir_dumps_out eq '' ; 
  die "input file not specified for titles to select (use -s)" if $file_select_titles eq '' ; 

  die "input folder '$dir_dumps_in' not found"     if ! -d $dir_dumps_in ; 
  die "output folder '$dir_dumps_out' not found"   if ! -d $dir_dumps_out ; 
  die "input file '$file_select_titles' not found" if ! -e $file_select_titles ; 

  print "dir_dumps_in:  '$dir_dumps_in'\n" ;
  print "dir_dumps_out: '$dir_dumps_out'\n" ;
  print "file_titles:   '$file_select_titles'\n" ;

  our @dumps = &CollectDumps ($dir_dumps_in) ;
  my $file_extract = $dumps [0] ;
  $file_extract =~ s/.*\/// ;
  $file_extract =~ s/history.*$/history_extract3.xml/ ;
  $file_extract = "$dir_dumps_out/$file_extract" ;

  print "File titles:  '$file_select_titles'\n" ;
  print "File extract: '$file_extract'\n" ;
  my $total_titles_to_select = &ReadTitles  ($file_select_titles) ;
  my $titles_selected = &ExtractDump ($file_extract) ;

  my $perc_titles_selected = 0 ;
  if ($total_titles_to_select > 0)
  { $perc_titles_selected = sprintf ("%.1f", (100 * $titles_selected) / $total_titles_to_select) ; }

  print "$titles_selected out of $total_titles_to_select titles found ($perc_titles_selected\%)\n" ;

  my $missing = 0 ;
  print "\n\nTitles not found:\n\n" ;
  foreach my $title (sort keys %select_titles)
  {
    if (! $titles_found {$title})
    { print ++$missing . ": $title\n" ; }
  }

  print "\nTotal file size: " . &MB ($bytes_processed) . "MB \n\n" ;
  print "\n\nReady\n\n" ;
  exit ;

sub CollectDumps
{
  print "Collect dumps, files found:\n" ;
  my ($dir_dumps) = @_ ;

  chdir $dir_dumps ;
  my @files = <*>;

  foreach my $file (@files)
  {
    # next if $file !~ /pages-meta-history.*?bz2/ ;
    next if $file !~ /stub-meta-history.xml.gz/ ;
    push @dumps, "$dir_dumps/$file" ;
  }
  @dumps = sort @dumps ;
  print "\n\n" . join ("\n", @dumps) . "\n\n";

  die "No *[pages/stub]-meta-history* files found in $dir_dumps" if $#dumps == -1 ;

  return @dumps ;
}

sub ReadTitles
{
  my ($file_select_titles) = @_ ;
  my ($line) ;

  open TITLES, '<', $file_select_titles || die "File could not be read: '$file_select_titles'\n" ;
  while ($line = <TITLES>)
  {
# next if $line !~ /^American/i ;
    chomp $line ;
    $line =~ s/\s*$//g ;
    next if $line =~ /^\s*$/ ;
    $select_titles {lc ($line)} = $true ;
    print "list: select '$line'\n" ;
  }

  my @keys = sort keys %select_titles ;
  die "No titles to select!" if $#keys == -1 ;
  print "\n\nTitles to select:\n\n" . join ("\n", @keys) . "\n\n"  ;
  my $total_titles_to_select = $#keys + 1 ;
  return ($total_titles_to_select) ;
}

sub ExtractDump
{
  my ($file_extract) = @_ ;
  my ($file_dump, $titles, $titles_selected, $filecnt) ;

  open EXTRACT, '>', $file_extract || die "Could not open output file '$file_extract'\n" ;
  binmode EXTRACT ;

  $titles = 0 ;
  $titles_selected = 0 ;
  $filecnt = 0 ;
  while ($#dumps > -1)
  {
    $file_dump = shift @dumps ;
    ($titles,$titles_selected) = &ExtractDumpFile (++$filecnt, $file_dump, $titles, $titles_selected) ;
  }

  print EXTRACT "  </mediawiki>\n" ;
  close EXTRACT ;

  return ($titles_selected) ;
}

sub ExtractDumpFile
{
  my ($filecnt, $file_dump, $titles, $titles_selected) = @_ ;
  my ($line, $lines, $title, $select_title) ;

  print "\nProcess '$file_dump'\n" ;
  die "File '$file_dump' not found" if ! -e $file_dump ;

  if ($file_dump =~ /\.xml$/)
  { open XML, "<", "$file_dump" || die ("Input file could not be opened: '$file_dump'") ; }
  elsif ($file_dump =~ /\.bz2$/)
  { open XML, "-|", "bzip2 -dc \"$file_dump\"" || die ("Input file could not be opened: '$file_dump'") ; }
  elsif ($file_dump =~ /\.gz$/)
  { open XML, "-|", "gzip -dc \"$file_dump\"" || die ("Input file could not be opened: '$file_dump'") ; }
  else
  {  print "Unexpected extension: $file_dump\n" ; exit ; }

  binmode XML ;

  $lines = 0 ;
  while ($line = <XML>)
  {
    $lines++ ;
    last if $line =~ /<page>/ ;
    if ($filecnt == 1)
    { print EXTRACT $line ; }
  }

  my $title_prev = '' ;
  my $bytes_processed_prev = 0 ;
  while ($line = <XML>)
  {
    $lines++ ;
    $bytes_processed += length ($line) ;
    # if ($line =~ /^\s*<timestamp/) # Q&D: no check on right xml level (below <page>)
    # { print $line ; }

    if ($line =~ /^\s*<title>.*?<\/title>/) # Q&D: no check on right xml level (below <page>)
    {
      chomp $line ;


      $titles++ ;
      # print "." ; 
      if ($titles % 10000 == 0)
    # { print "\ndone " . &commify ($titles) . " titles in " . &ddhhmmss (time-$timestart, $time_format) . ", in " . &MB ($bytes_processed) . " MB \n" ; }
      { print   "done " . &commify ($titles) . " titles in " . &ddhhmmss (time-$timestart, $time_format) . ", in " . &MB ($bytes_processed) . " MB \n" ; }

      $title = $line ;
      $title =~ s/^.*?<title[^>]*>\s*// ;
      $title =~ s/\s*<\/title>.*$// ;
      $title =~ s/ /_/g ;
# next if $title !~ /^American/i ;
# print "dump: title '$title'\n" ;
      my $size_article_history = &MB ($bytes_processed - $bytes_processed_prev) ;
      if ($size_article_history > 100) # otry ($titles > 1) && ($titles < 10000))      
      {	print "\n$size_article_history MB: '$title_prev'\n" ; }     
      $title_prev = $title ;
      $bytes_processed_prev = $bytes_processed ;
      
      if ($select_titles {lc ($title)})
      {
        $titles_selected++ ;
        $select_title = $true ;
        $titles_found {lc ($title)} = $true ;
        print "\n==> $titles_selected: select title $title\n" ;
        print EXTRACT "  <page>\n" ;
      # print         "  <page>\n" ;
      }
      else
      { print "not selected\n" ; }
    }
    if ($select_title)
    { 
      print EXTRACT "$line\n" ; 
    # print         "$line\n" ; 
    }

    if ($line =~ /<\/page>/)
    { $select_title = $false ; }
  }

  close XML ;

  return ($titles, $titles_selected) ;
}

# routine (overcomplete for this script) Q&D copied from other script
sub ddhhmmss
{
  my $seconds = shift ;
  my $format  = shift ;

  my ($days,$hrs,$min,$sec,$text_days,$text_hrs,$text_min,$text_sec) ;

  $days = int ($seconds / (24*3600)) ;
  $seconds -= $days * 24*3600 ;
  $hrs = int ($seconds / 3600) ;
  $seconds -= $hrs * 3600 ;
  $min = int ($seconds / 60) ;
  $sec = $seconds % 60 ;

  if ($format eq '')
  {
    $text_days = ($days > 0) ? (($days > 1) ? "$days days, " : "$days day, ") : "" ;
    $text_hrs  = (($days + $hrs > 0) ? (($hrs > 1) ? "$hrs hrs" : "$hrs hrs") : "") . ($days + $hrs > 0 ? ", " : ""); # 2 hrs/1 hr ?
    $text_min  = ($days + $hrs + $min > 0) ? "$min min, " : "" ;
    $text_sec  = "$sec sec" ;
    return ("$text_days$text_hrs$text_min$text_sec") ;
  }
  else
  {
    return sprintf ($format,$days,$hrs,$min,$sec) if $format =~ /%.*%.*%.*%/ ;
    return sprintf ($format,      $hrs,$min,$sec) if $format =~ /%.*%.*%/ ;
    return sprintf ($format,           $min,$sec) if $format =~ /%.*%/ ;
    return sprintf ($format,                $sec) ;
  }
}

sub commify
{
  my $num = shift ;
  $num =~ s/(\d)(\d\d\d)$/$1,$2/ ;
  $num =~ s/(\d)(\d\d\d,)/$1,$2/ ;
  $num =~ s/(\d)(\d\d\d,)/$1,$2/ ;
  return $num ;
}

sub MB
{
  my $bytes = shift ;
  return (&commify (sprintf ("%.0f", $bytes / (1024 * 1024)))) ;
}

