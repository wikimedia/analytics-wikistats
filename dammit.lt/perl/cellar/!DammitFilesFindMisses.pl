#!/usr/local/bin/perl

# to do
# titles can occur twice (because of ucfirst) , add those counts before pushing to table @data
# remove extra parameters e.g. "Gabriel_Andrade&limit=500"

  use CGI qw(:all);
  use URI::Escape;
  use Getopt::Std ;
  use Cwd ;

  $bayes     = -d "/a/dammit.lt/pagecounts" ;
  $path_7za  = "/usr/lib/p7zip/7za" ;
  $path_grep = "/bin/grep" ;

  $| = 1; # flush screen output
  $true  = 1 ;
  $false = 0 ;

  $jobstart = time ;

  $key = "de.z" ;

# -i "D:/\@Wikimedia/!Perl/#Projects/Dammit Log Files/Scan Log Files/in" -o "D:/\@Wikimedia/!Perl/#Projects/Dammit Log Files/Scan Log Files/out" -f 20090429 -t 20090429 -p ''
  my $options ;
  getopt ("iop", \%options) ;

  $file_articles_in         = "W:/# In Dumps/dewiki-20090917-all-titles-in-ns0" ;
  $file_articles_out        = "W:/# In Dumps/dewiki-20090917-all-titles-in-ns0_b" ;
  $file_pageviews_in        = "W:/pagecounts-20090801_fdt" ;
  $file_pageviews_out       = "W:/pagecounts-20090801_fdt_b" ;
  $file_extract             = "W:/! Perl/Dammit Log Files/Scan Log Files/PageViewsExtractArticlesDeWp.txt" ;
  $file_missing             = "W:/! Perl/Dammit Log Files/Scan Log Files/PageViewsMissingArticlesDeWp.txt" ;

#  if (! defined ($options {"i"})) { &Abort ("Specify input dir as -i dirname") } ;
#  if (! defined ($options {"o"})) { &Abort ("Specify output dir as -o dirname") } ;
#  if (! defined ($options {"p"})) { &Abort ("Specify project as -p \".....\"") } ;

#  $dir_in   = $options {"i"} ;
#  $dir_out  = $options {"o"} ;
#  $project  = $options {"p"} ;

#  $work = cwd() ;
#  print "Work dir $work\n" ;
#  if ($dir_in !~ /[\/\\]/)
#  { $dir_in = "$work/$dir_in" ; }
#  if ($dir_out !~ /[\/\\]/)
#  { $dir_out = "$work/$dir_out" ; }

#  if (! -d $dir_in)  { &Abort ("Input dir not found: $dir_in") } ;
#  if (! -d $dir_out)
#  {
#    print "Create output dir $dir_out\n" ;
#    mkdir $dir_out ;
#    if (! -d $dir_out)
#    { &Abort ("Output dir could not be created.") } ;
#  }

  print "\nExtract missing articles\n" ; # Parm in:  $dir_in\nParm out: $dir_out\n" ;

# &SortEncodedArticleTitles ;
  &ExtractMissingArticles ;

  &Log ("\nReady\n") ;
  exit ;

sub SortEncodedArticleTitles
{
  open IN,  '<', $file_articles_in  || &Abort ("$file_articles_in could not be opened") ;
  open OUT, '>', $file_articles_out || &Abort ("$file_articles_out could not be opened") ;

  while ($line = <IN>)
  {
    chomp ($line) ;
    $line =~ s/\%([0-9A-F]{2})/chr(hex($1))/ge ;
    $line =~ s/([\x00-\x31\x80-\xFF])/"%".sprintf("%X",ord ($1))/ge ;
    $line = ucfirst ($line) ;
    push @data, $line ;
  }
  close IN ;

  @data = sort @data ;

  foreach $line (@data)
  { print OUT "$line\n" ; }

  close OUT ;

  #--------------------------------------------------------------------------------------

  open IN,  '<', $file_pageviews_in  || &Abort ("$file_pageviews_in could not be opened") ;
  open OUT, '>', $file_pageviews_out || &Abort ("$file_pageviews_tmp could not be opened") ;

  @data = () ;
  while ($line = <IN>)
  {
    if ($line !~ /^$key /) { next ; }

    chomp ($line) ;
    ($key2,$title,$counts) = split (' ', $line) ;
    $title =~ s/\%([0-9A-F]{2})/chr(hex($1))/ge ;
    $title =~ s/([\x00-\x31\x80-\xFF])/"%".sprintf("%X",ord ($1))/ge ;
    $title = ucfirst ($title) ;
    push @data, "$title $counts" ;
  }
  close IN ;

  @data = sort @data ;

  foreach $line (@data)
  { print OUT "$line\n" ; }

  close OUT ;
}

sub ExtractMissingArticles
{
  my $dir_in   = shift ;
  my $dir_out  = shift ;

  open ARTICLES,  '<', $file_articles_out  || &Abort ("$file_articles_out could not be opened") ;
  open PAGEVIEWS, '<', $file_pageviews_out || &Abort ("$file_pageviews_out could not be opened") ;
  open EXTRACT,   '>', $file_extract       || &Abort ("$file_extract could not be written") ;
  open MISSING,   '>', $file_missing       || &Abort ("$file_missing could not be written") ;

  $title_at = <ARTICLES> ; # at = article title
  chomp $title_at ;

  @data = () ;
  while ($line_pv = <PAGEVIEWS>) # pv = page view
  {
    chomp ($line_pv) ;
    ($title_pv,$counts) = split (' ', $line_pv) ;

    while (($title_at ne "") && ($title_pv gt $title_at))
    {
      # print EXTRACT "  PV '$title_pv' gt AT $title_at\n" ;
      $title_at = <ARTICLES> ;
      chomp ($title_at) ;
    }

    chomp ($line_articles) ;
    # if ($title_pv eq $title_at)
    # { print EXTRACT "  PV '$title_pv' EQ AT '$title_at'\n" ; }
    # else
    # { print EXTRACT "  PV '$title_pv' NE AT '$title_at'\n" ; }
    if ($title_pv ne $title_at)
    {
      $title_pv2 = $title_pv ;
      $title_pv2 =~ s/\%([0-9A-F]{2})/chr(hex($1))/ge ;
      print EXTRACT "$title_pv2 $counts\n" ;

      if ($title_pv2 !~ /:/) # temp treat all titles with : as namespaces
      {
        $counts =~ s/^(\d+).*$/$1/ ;
        push @data, "$counts $title_pv2" ;
      }
    }
  }
  @data = sort {$b <=> $a} @data ;
  foreach $line (@data)
  { print MISSING "$line\n" ; }
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print LOG $msg ;
}

sub Abort
{
  $msg = shift ;
  print "Abort script\nError: $msg\n" ;
  print LOG "Abort script\nError: $msg\n" ;
  exit ;
}

sub mmss
{
  my $seconds = shift ;
  return (int ($seconds / 60) . " min, " . ($seconds % 60) . " sec") ;
}

