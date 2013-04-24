#!/usr/bin/perl

  use strict ;
  use warnings ;

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Getopt::Std ;
  use URI::Escape ;

  our $timestart = time ;

  # -v "w:\! perl\dammit\dammit page requests per category\pagecounts-2013-01-views-ge-5-totals.bz2" -t nederlands_kunstschilder\scancategoriesfoundarticles.csv -o "PageViewsFiltered.csv"
  our ($file_out, $file_titles, $file_views) = &ParseArguments ;
  &FilterArticles ($file_out, $file_titles, $file_views) ;

  print "\n\nReady\n\n" ;
  exit ;

# arguments checking can be improved, is not fool proof
sub ParseArguments
{
  my %options ;
  getopt ("otv", \%options) ;

  my ($file_out, $file_titles, $file_views) ;

  $file_out    = $options {"o"} ;
  $file_titles = $options {"t"} ;
  $file_views  = $options {"v"} ;

  die "Specify -o [output file]" if $options {"o"} eq '' ;
  die "Specify -t [titles file]" if $options {"t"} eq '' ;
  die "Specify -v [views file]"  if $options {"v"} eq '' ;

  die "Input file '$file_titles' not found!" if ! -e $file_titles ;
  die "Input file '$file_titles' empty!"     if ! -s $file_titles ;
  die "Views file '$file_views' not found!"  if ! -e $file_views ;

  $file_titles = uri_unescape ($file_titles) ;
  $file_views  = uri_unescape ($file_views) ;

  return ($file_out, $file_titles, $file_views) ;
}

sub FilterArticles
{
  my ($file_out, $file_titles, $file_views) = @_ ;
  my ($line_titles, $line_views, $line_cnt_views) ;
  my ($line_titles_key, $line_views_key) ;
  my ($lang_proj,$title,$categories,$count) ;

  open FILE_TITLES, '<', $file_titles || die "Could not open titles file '$file_titles'\n" ;

  if ($file_views =~ /\.bz2$/)
  { open FILE_VIEWS, "-|", "bzip2 -dc \"$file_views\"" || abort ("Input file '" . $file_views . "' could not be opened.") ; }
  else
  { open FILE_VIEWS,  '<', $file_views  || die "Could not open views file '$file_views'\n" ; }

  open FILE_OUT,    '>', $file_out    || die "Could not open output file '$file_out'\n" ;

  $line_views_key  = '' ;
  $line_titles_key = '' ;

  $line_cnt_views = -1 ;
  while ($line_views = <FILE_VIEWS>)
  {
    if (++$line_cnt_views % 1000000 == 0)
    { print "$line_cnt_views:\n$line_views$line_titles_key\n\n" ; }

    if ($line_views =~ /^#/)
    {
      print FILE_OUT "views: " . $line_views ;
      print          "views: " . $line_views ;
      next ;
    }
    
    next if $line_views lt $line_titles_key ;  

    chomp $line_views ;
    ($lang_proj,$title,$count) = split (' ', $line_views) ;
    $line_views_key = "$lang_proj $title" ; 

    while (($line_titles_key lt $line_views_key) and ($line_titles = <FILE_TITLES>))
    {
      if ($line_titles =~ /^#/)
      {
        print FILE_OUT "titles: " . $line_titles ;
        print          "titles: " . $line_views ;
        next ;
      }
      chomp $line_titles ;
      ($lang_proj,$title,$categories) = split (',', $line_titles) ;
      $line_titles_key = "$lang_proj $title" ;
    }

    if (! $line_titles) # EOF ?
    { print "EOF line_titles\n" ; last ;}
    # key titles is either equal or larger than key views

    # print "views: $line_views_key\ntitles: $line_titles_key\n\n" ;
    if ($line_views_key eq $line_titles_key)
    {  print FILE_OUT "$line_views_key $count $categories\n" ; }
  }

  print "Close files" ;
  close FILE_TITLES ;
  close FILE_VIEWS ;
  close FILE_OUT ;

}



