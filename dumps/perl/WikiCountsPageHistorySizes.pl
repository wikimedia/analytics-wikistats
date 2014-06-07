#!/usr/bin/perl

  $| = 1; # Flush output
 
  use warnings ;
  use strict ;

  our $true  = 1 ;
  our $false = 0 ;

  our $bytes_read = 0 ;
  our $titles     = 0 ;
  
  my $dir_dumps_in  = "/mnt/data/xmldatadumps/public/dewiki/20131008" ;
  my $dir_csv       = "/a/wikistats_git/dumps/csv/csv_wp" ;
  my $file_counts   = "$dir_csv/PageHistorySizesDE.csv" ;

  our @dumps = &CollectDumps ($dir_dumps_in) ;
  open OUT, '>', $file_counts ;
  &ScanDump ;
  close OUT ;

  print "\nTotal file size: $bytes_read bytes\n" ;
  print "\n\nReady\n\n" ;
  exit ;

sub CollectDumps
{
  print "Scan dumps, files found:\n" ;
  my ($dir_dumps) = @_ ;

  chdir $dir_dumps ;
  my @files = <*>;

  foreach my $file (@files)
  {
    next if $file !~ /pages-meta-history.*?bz2/ ;
    push @dumps, "$dir_dumps/$file" ;
  }
  @dumps = sort @dumps ;
  print "\n\n" . join ("\n", @dumps) . "\n\n";

  die "No *pages-meta-history* files found in $dir_dumps" if $#dumps == -1 ;

  return @dumps ;
}

sub ScanDump
{
  while ($#dumps > -1)
  {
    my $file_dump = shift @dumps ;
    &ScanDumpFile ($file_dump) ;
  }
}

sub ScanDumpFile
{
  my ($file_dump) = @_ ;
  my ($line, $lines, $title) ;

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

  my $title_prev      = '' ;
  my $bytes_read      = 0 ;
  my $bytes_read_prev = 0 ;

  while ($line = <XML>)
  {
    $bytes_read += length ($line) ;

    if ($line =~ /^\s*<title>.*?<\/title>/) 
    {
      chomp $line ;

      $titles++ ;
      if ($titles % 10 == 0)
      { print "." ; }
      if ($titles % 1000 == 0)
      { print "\ndone $titles titles\n" ; }

      if ($title_prev ne '')
      { print OUT ($bytes_read - $bytes_read_prev) . " $title_prev\n" ; }

      $title = $line ;
      $title =~ s/^.*?<title[^>]*>\s*// ;
      $title =~ s/\s*<\/title>.*$// ;
      
      $title_prev      = $title ;
      $bytes_read_prev = $bytes_read ;
    }
  }
  
  close XML ;
  print OUT $bytes_read - $bytes_read_prev . " $title_prev\n" ;
}


