#!/usr/bin/perl

  $| = 1; # Flush output

  use IO::Compress::Gzip ;   # install IO-Compress-Zlib

  $false = 0 ;
  $true  = 1 ;

  $lang = 'en' ;
  $date = '20120902' ;

  $file_in  = "/mnt/data/xmldatadumps/public/${lang}wiki/$date/${lang}wiki-${date}-stub-meta-history.xml.gz" ;
  
  # Q&D fix for Q&D script
  if (-d '/a/wikistats_git')
  { $file_out = "/a/wikistats_git/tmp/${lang}wiki-${date}-stub-meta-history.xml" ; }
  else
  { $file_out = "/a/wikistats/tmp/${lang}wiki-${date}-stub-meta-history.xml" ; }

# local test
# $file_in  = 'w:/# in dumps/aawiki-20120913-stub-meta-history.xml' ;
# $file_out = 'w:/# in dumps/aawiki-20120913-stub-meta-history2.xml' ;

  &ProcessFileXml ($file_in, $file_out) ;

  print "\nReady\n\n" ;
  exit ;

sub ProcessFileXml
{
  my ($file_in, $file_out) = @_ ;

  if (! -e $file_in)
  { die ("ReadFileXml \$file_in '$file_in' not found.\n") ; }

  if ($file_in =~ /\.gz$/)
  { open FILE_IN, "-|", "gzip -dc \"$file_in\"" || die ("Input file '" . $file_in . "' could not be opened.") ; }
  elsif ($file_in =~ /\.bz2$/)
  { open FILE_IN, "-|", "bzip2 -dc \"$file_in\"" || die ("Input file '" . $file_in . "' could not be opened.") ; }
  elsif ($file_in =~ /\.7z$/)
  { open FILE_IN, "-|", "7z e -so \"$file_in\"" || die ("Input file '" . $file_in . "' could not be opened.") ; }
  else
  { open FILE_IN, "<", $file_in || die ("Input file '" . $file_in . "' could not be opened.") ; }

  binmode FILE_IN ;

  open FILE_OUT, '>', $file_out || die  ("Output file '" . $file_out . "' could not be opened.") ;
  binmode $file_out ;

  $first_page_found = $false ;
  $page_complete = $true ;
  $page_content = '' ;
  $revision_content = '' ;
  $revision_complete = $true ;
  $copy_page = $false ;
  $copy_revision = $false ;

  while ($line = <FILE_IN>)
  {
    $bytes_read += length ($line) ;
    $mb_read = int ($bytes_read / (1024 * 1024)) ;
    $mb_read_100 = int ($mb_read / 100) ;
    if ($mb_read_100 > $mb_read_100_prev)
    { print "$mb_read Mb\n" ; }
    $mb_read_100_prev = $mb_read_100 ;

    if (! $first_page_found)
    {
      print FILE_OUT $line ;
      if ($line =~ /^\s*<\/siteinfo>\s*$/o)
      {
        $first_page_found = $true ;
        next ;
      }
      next ;
    }

    if ($revision_complete)
    {
      if ($line =~ /^\s*<page>\s*$/)
      {
        $page_complete = $false ;
        $page_content = $line ;
        next ;
      }
      elsif ($line =~ /^\s*<\/page>\s*$/)
      {
        $page_complete = $true ;
        if ($copy_page)
        {
          $page_content .= $line ;
          print FILE_OUT $page_content ;
        }
        $page_content  = '' ;
        $copy_page = $false ;
        next ;
      }
    }

    if ($line =~ /^\s*<revision>\s*$/o)
    {
      $revision_complete = $false ;
      $revision_content  = $line ;
      next ;
    }

    if ($line =~ /^\s*<\/revision>\s*$/o)
    {
      $revision_complete = $true ;
      if ($copy_revision)
      {
        $revision_content .= $line ;
        $page_content .= $revision_content ;
      }
      $revision_content = '' ;
      $copy_revision = $false ;
      next ;
    }

    if ((! $revision_complete) && ($line =~ /^\s*<timestamp>.*?<\/timestamp>\s*$/o))
    {
      ($timestamp = $line) =~ s/^\s*<timestamp>(.*?)<\/timestamp>\s*$/$1/o ;
      if ($timestamp =~ /^2001/)
      {
        $copy_page = $true ;
        $copy_revision = $true ;
      }
    # print "$timestamp\n" ;
    }

    if ((! $page_complete) && ($line =~ /^\s*<title>.*?<\/title>\s*$/o))
    {
      ($title = $line) =~ s/^\s*<title>(.*?)<\/title>\s*$/$1/o ;
      $titles++ ;
    # print "\n$titles: $title\n" ;
    }

    if (! $page_complete)
    {
      if ($revision_complete)
      { $page_content .= $line ; }
      else
      { $revision_content .= $line ; }
      next ;
    }

    if ($page_complete && ($line =~ /^\s*<\/mediawiki>\s*$/o))
    {
      print FILE_OUT $line ;
      print "\nEnd of file reached\nInput file complete\n" ;
      last ;
    }
  }
  close FILE_OUT ;
}
