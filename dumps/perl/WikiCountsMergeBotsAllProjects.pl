#!/usr/bin/perl

  use Getopt::Std ;

  $| = 1; # Flush output

  my %options ;
  getopt ("c", \%options) ;
  $path_csv  = $options {'c'} ;
  
  die "Specify path to csv files as: -c [path]" if ! -d $path_csv ;
  print "Path to csv files: $path_csv\n" ;

  $file_out = "$path_csv/csv_mw/BotsAllProjects.csv" ;

  open  CSV_OUT, '>', $file_out || die "Could not open $file_out" ;
  binmode CSV_OUT ;
  print CSV_OUT "project,lang,bots\n" ;
  
  &CopyBots ($path_csv,wb) ;
  &CopyBots ($path_csv,wk) unless $test ;
  &CopyBots ($path_csv,wn) unless $test ;
  &CopyBots ($path_csv,wo) unless $test ;
  &CopyBots ($path_csv,wp) unless $test ;
  &CopyBots ($path_csv,wq) unless $test ;
  &CopyBots ($path_csv,ws) unless $test ;
  &CopyBots ($path_csv,wx) unless $test ;
  &CopyBots ($path_csv,wv) ;

  close CSV_OUT ;

  print "Ready\n\n" ;

  exit ;

sub CopyBots
{
  my ($path_csv,$project_code) = @_ ;

  $path_csv .= "/csv_$project_code" ;
  $file_csv = "$path_csv/BotsAll.csv" ;

  print "CopyBots $path_csv\n" ;

  die "File $file_csv not found" if ! -e $file_csv ;

  open CSV_IN, '<', $file_csv ;
  while ($line = <CSV_IN>)
  { print CSV_OUT "$project_code,$line" ; }
  close CSV_IN ;
}
