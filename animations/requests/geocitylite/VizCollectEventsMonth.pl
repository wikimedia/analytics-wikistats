#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (14) ;

  use Time::Local ;
  use Compress::Zlib;
  use Getopt::Std ;

  my $options ;
  getopt ("m", \%options) ;
  $month = $options {"m"} ;

  die "Specify month as -m yyyy/mm" if $month !~ /^\d\d\d\d\/\d\d$/ ;
  ($year,$month) = split ('\/', $month) ;

  $days = &days_in_month ($year,$month) ;
  for ($day = 1 ; $day <= $days ; $day++)
  {
    $date = sprintf ("%04d/%02d/%02d",$year,$month,$day) ; ;
    $cmd = "\nperl VizCollectEvents.pl -d $date" ;
    print "\n$cmd ->\n" ;

    $result = `$cmd` ;
    @results = split ("\n", $result) ;
    foreach $line (@results)
    { print "# $line\n" ; }
  }

  print "\n\nReady\n\n" ;
  exit ;


