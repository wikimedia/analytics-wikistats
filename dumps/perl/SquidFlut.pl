#!/usr/bin/perl
  use Time::Local ;
  use Getopt::Std ;
  use Cwd;
  use Net::Domain qw (hostname);

  $false = 0 ;
  $true  = 1 ;
  $timestart = time ;
  $| = 1; # flush screen output

  &ReadInput ;
  print "\nReady in " . &mmss ((time - $timestart)). "\n\n" ;
  exit ;

sub ReadInput
{
  $file_in = "sampled-1000-oneday.txt" ;

  print "Process $file_in\n\n" ;
  if (! -e $file_in)
  { print "ReadInput: File not found: $file_in. Aborting...\n\n" ; exit ; }

  open IN,  '<', $file_in ;

  while ($line = <IN>)
  {
    $lines ++ ;
    if ($lines > 2000000) { last  ; }

    @fields = split (' ', $line) ;

    $time       = $fields [2] ;
    $client_ip  = $fields [4] ;
    $status     = $fields [5] ;
    $size       = $fields [6] ;
    $method     = $fields [7] ;
    $url        = lc ($fields [8]) ;
    $mime       = $fields [10] ;
    $referer    = lc ($fields [11]) ;
    $agent      = $fields [13] ;

    @result = `geoiplookup $client_ip` ;
    $line  = $result [0] ;
    $line =~ s/^.*?:\s*// ;
    @countries {$line} ++ ;

    if ($#fields < 13) { $fields_too_few  ++ ; next ; }
    if ($#fields > 13) { $fields_too_many ++ ; next ; }

    if (++ $lines % 100000 == 0)
    { print &mmss(time-$timestart) . " - " . substr($time,0,19) . ": $lines\n" ; }
  }
  close IN ;

  if (time - $timestart > 0)
  { print "\nLines: $lines -> " . sprintf ("%.0f", $lines / (time - $timestart)) . " per sec\n" ; }

  foreach $key (sort {$countries {$b} <=> $countries {$a}} keys %countries)
  { print sprintf ("%8d", $countries {$key}) . ": $key" ; }
}

sub mmss
{
  my $seconds = shift ;
  return (int ($seconds / 60) . " min, " . ($seconds % 60) . " sec") ;
}

# Lines: 13381788 -> 176076 per sec
# Ready in 1 min, 16 sec
