#!/usr/local/bin/perl

# 27 April 2010 renamed from WikiStatsCollectArticleNames.pl

use CGI qw(:all);
use Time::Local ;
use Getopt::Std ;

  &ParseArguments ;
  $dumpfile = &FindDumpFile ;
  &ProcessFile ($dumpfile, "$path_out/$mode\_$project.txt") ;
  print "\n\nReady\n\n" ;
  exit ;

sub ParseArguments
{
  my $options ;
  getopt ("iomp", \%options) ;

  &Abort ("Specify input folder for xml dump files as: -i path") if (! defined (@options {"i"})) ;
  &Abort ("Specify output folder as: -o path") if (! defined (@options {"o"})) ;

  $path_in        = @options {"i"} ;
  $path_out       = @options {"o"} ;
  $project        = @options {"p"} ;
  $mode           = @options {"m"} ;

  $language  = $project ;
  $language_ = $language ;
  $language_ =~ s/-/_/g ;

  if ($mode eq "")
  { $mode = "wp" ; }
  if ($mode !~ /^(?:wb|wk|wn|wp|wq|ws|wx|wv)$/)
  { abort ("Specify mode as: -m [wb|wk|wn|wp|wq|ws|wx|wv]\n(wp=wikipedia (default), wb=wikibooks, wk=wiktionary, wn=wikinews, wq=wikiquote, ws=wikisource, wx=wikispecial, wv=wikiversity)") ; }

  &Abort ("Project $project is skipped: 'mania' and/or 'team' in the name") if ($project =~ /(?:mania|team)/i) ;

  if ($project =~ /wik(?:|ibooks|inews|iquote|isource|tionary|iversity)$/i)
  {
    $project_suffix = $project ;
    $project_suffix =~ s/wik(?:|ibooks|inews|iquote|isource|tionary|iversity)$// ;
  }
  $language =~ s/wik(?:|ibooks|inews|iquote|isource|tionary|iversity)$// ;

  if ($project =~ /wiki$/i)
  {
    $project_suffix = $project ;
    $project_suffix =~ s/wiki$// ;
  }
  $language =~ s/wiki$// ;

  &Log ("Project '$project' -> language '$language'\n\n") ;
}

sub FindDumpFile
{
  my ($dumpdir,$dir,$file,$scandir,$status) ;

  @files = glob "$path_in/*" ;

  &Log ("Find latest valid dump dir in $path_in ->\n\n") ;
  foreach $file (@files)
  {
    if ($file !~ /\/\d{8,8}$/)
    { next ; }
    if (! -d $file)
    { next ; }

    ($dir = $file) =~ s/.*?\/(\d{8,8})/$1/ ;
    $scandir = "$path_in/$dir" ;
    if (! -e "$scandir/status.html")
    { &Log ("$scandir/status.html not found\n") ; }
    elsif (! -e "$scandir/index.html")
    { &Log ("$scandir/index.html not found\n") ; }
    else
    {
      open STATUS, '<', "$scandir/status.html" ;
      $line = <STATUS> ;
      chomp $line ;
      close STATUS ;
      $status = "undetermined: $line" ;
      if ($line =~ /dump complete/i)
      { $status = "dump complete" ; }
      elsif ($line =~ /dump aborted/i)
      { $status = "dump aborted" ; }
      elsif ($line =~ /dump in progress/i)
      { $status = "dump in progress" ; }
      if ($dumpdir lt $dir)
      {
        if ($status eq "dump complete")
        {
          open INDEX, '<', "$scandir/index.html" ;
          while ($line = <INDEX>)
          {
            if ($line =~ /failed.*?All pages with complete.*?edit history/i)
            {
              $status = "dump aborted (dump failed)" ;
              last ;
            }
          }
          close INDEX ;
        }
        if ($status eq "dump complete")
        { $dumpdir = $dir ; }
      }
      &Log ("$dir: $status\n") ;
    }
  }
  if ($dumpdir eq "")
  { &Abort ("No valid dump dir found\n") ; }

  $path_in .= "/$dumpdir/" ;
  &Log ("\nDump dir -> $path_in\n") ;
  $dumpdate = $dumpdir ;

  $dumpfile = "$path_in/$project-$dumpdate-pages-meta-current.xml.bz2" ;
  &Log ("\nFile in  $dumpfile\n") ;
  return ($dumpfile) ;
}

sub ProcessFile
{
  my $file_in  = shift ;
  my $file_out = shift ;
  print "File out $file_out\n" ;
  open FILE_OUT, '>', $file_out  || abort ("Output file '" . $file_out . "' could not be opened.") ;
  open FILE_IN, "-|", "bzip2 -dc \"$file_in\"" || abort ("Input file '" . $file_in . "' could not be opened.") ;
  while ($line = <FILE_IN>)
  {
  # $line =~ s/<title>([^<]*)<\/title>/print FILE_OUT "$1\n", print "$1\n"/ge ;
    $line =~ s/<title>([^<]*)<\/title>/print FILE_OUT "$1\n"/ge ;
  }
  close FILE_IN ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
# print LOG $msg ;
}

sub Abort
{
  $msg = shift ;
  print "Abort script\nError: $msg\n" ;
# print LOG "Abort script\nError: $msg\n" ;
  exit ;
}


