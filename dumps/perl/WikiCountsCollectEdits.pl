#!/usr/bin/perl

  use Time::Local ;
  use Getopt::Std ;

  $| = 1; # flush output
  $verbose = 1 ;

  my %options ;
  getopt ("cipw", \%options) ;
  $path_csv = $options {'c'} ;
  $project  = $options {'p'} ;
  $wiki     = $options {'w'} ;
  $dump     = $options {'i'} ;
  
  die "Specify path to csv files as: -c [path]" if ! -d $path_csv ;
  print "Path to csv files: $path_csv\n" ;

  die "Specify project code as: -p [wb|wk|wn|wo|wp|wq|ws|wv|wx|wo]" if $project !~ /^(?:wb|wk|wn|wo|wp|wq|ws|wv|wx|wo)$/ ;
  print "Project code: $project\n" ;

  die "Specify wiki code as: -w [some wiki, e.g. enwiki]" if $wiki eq '' ;
  print "Wiki code: $wiki\n" ;

  die "Specify dump file as: -i [full path to stub dump]" if $dump eq '' ;
  die "Input stub dump not found: $dump" if ! -e $dump ;

  print "Stub dump: $dump\n" ;

  $file_newest_dumps = "$path_csv/csv_$project/StatisticsNewestDumps.csv" ;
  
  open CSV_IN, '<', $file_newest_dumps || die "Could not open $file_newest_dumps" ;
  binmode CSV_IN ;
  @dumplist = <CSV_IN> ;
  close CSV_IN ;

  open CSV_IN, '<', "$path_csv/csv_$project/BotsAll.csv" || die "Could not open $path_csv/csv_$project/BotsAll.csv" ;
  binmode CSV_IN ;
  @botsall = <CSV_IN> ;
  close CSV_IN ;

#  foreach $line (@dumplist)
#  {
#    chomp $line ;
#    ($type,$project,$wiki,$path) = split (',', $line) ;

#    next if $type ne 'stub' ;

#    if (-e $path)
#    { &ProcessDump ($project, $wiki, $path) ; }
#  }
  &ProcessDump ($project, $wiki, $dump) ;

  print "\nReady\n" ;
  exit ;

sub ProcessDump
{
  my ($project,$wiki,$path) = @_ ;

  ($wp = $wiki) =~ s/wik.*$//g ;

  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
  my $time = sprintf ("%02d:%02d:%02d", $hh, $mm, $ss) ;
  my $titles = 0 ;

  print "$time Process project '$project', wiki '$wiki', dump '$path'\n\n" ;
  $timestart = time ;

  my $bots = '' ;
  my @bots ;
  my %bots ;

  foreach $line (@botsall)
  {
    if ($line =~ /$wp,/)
    { $bots = $line ; last ; }
  }

  if ($bots eq '')
  { print "No line found for $wiki in $path_csv/csv_$project/BotsAll.csv\n" ; }
  else
  {
    chomp $bots ;
    ($lang,$bots) = split (",", $bots,2) ;
    @bots = split ('\|', $bots) ;
    foreach $bot (@bots)
    {
      $bot =~ s/\&comma;/,/g ;
      $bots {$bot} ++ ;
    }
  }

  if ($path =~ /\.gz$/)
  {
    open XML, "-|", "gzip -dc \"$path\"" || die ("Input file could not be opened: $path") ;
    binmode XML ;
  }
  else
  {  print "Unexpected extension: $path\n" ; exit ; }

  $file_out =  "$path_csv/csv_$project/EditsTimestamps" . uc ($wp) . ".csv" ;
  print "Write output to  $file_out\n\n" ;
  open CSV_OUT, '>', $file_out || die "Could not open $file_out" ;
  binmode CSV_OUT ;
  print CSV_OUT "# record types: n=namespace, t=title, e=edit\n" ; 
  print CSV_OUT "# record type e:user type,timestamp from xml, timestamp in seconds since 1900, username or ip address\n" ;
  print CSV_OUT "# user type: R=registered user, B=bot, A=anonymous, -=undefined\n" ;

  while ($line = <XML>)
  {

    if ($line =~ /<timestamp>/) # Q&D: no check on xml level (below <page>)
    {
      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($timestamp = $line) =~ s/<[^>]+>//g ;

      $yyyy = substr ($timestamp,0,4) - 1900 ;
      $mm   = substr ($timestamp,5,2) - 1 ;
      $dd   = substr ($timestamp,8,2) ;
      $hh   = substr ($timestamp,11,2) ;
      $nn   = substr ($timestamp,14,2) ;
      $ss   = substr ($timestamp,17,2) ;

      $time_secs = timegm ($ss,$nn,$hh,$dd,$mm,$yyyy) ;

      # test code 
      # ($sec,$min,$hour,$day,$month,$year) = gmtime ($time_secs) ;
      # $timestamp2 = sprintf ("%04d-%02d-%02dT%02d:%02d:%02dZ", $year+1900, $month+1, $day, $hour, $min, $sec) ;
      # print "e $timestamp $timestamp2, $time, $yyyy $mm $dd, $hh $nn $ss, $time\n" ;
      # die ("timestamps differ") if ($timestamp ne $timestamp2) ;
      # print CSV_OUT "e,$timestamp\n" ;

      next ;
    }

    if ($line =~ /<username/) # Q&D: no check on xml level (below <revision>)
    {
      if ($line =~ /<username>/) 
      {
        chomp $line ;
        $line =~ s/^\s*// ;
        $line =~ s/\s*$// ;
        ($user = $line) =~ s/<[^>]+>//g ;
        $user =~ s/,/&comma;/g ;
        if ($bots {$user} > 0)
        { $usertype = 'B' ; }
        else
        { $usertype = 'R' ; }
      }
    # elsif ($line =~ /<username\s*\/>/) 
    # { $user = 'empty user field' ; }
      else
      { 
        $user = 'empty user field' ; 
        $usertype = '-' ; 
      }
      
      print "e $usertype $timestamp $user\n" if $verbose ;
      print CSV_OUT "e,$usertype,$timestamp,$time_secs,$user\n" ;
      next ;
    }

    # if ($line =~ /\s*\<sha1\>/) # Q&D: no check on xml level (below <revision>)
    # {
    #   chomp $line ;
    #   $line =~ s/^\s*// ;
    #   $line =~ s/\s*$// ;
    #   ($sha1 = $line) =~ s/<[^>]+>//g ;
    # print "e A $timestamp $user\n" if $verbose ;
    # print CSV_OUT "e,A,$timestamp,$time_secs,$user\n" ;
    # }

    if ($line =~ /<ip>/) # Q&D: no check on xml level (below <revision>)
    {
      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($user = $line) =~ s/<[^>]+>//g ;
      $user =~ s/,/&comma;/g ;
      print "e A $timestamp $user\n" if $verbose ;
      print CSV_OUT "e,A,$timestamp,$time_secs,$user\n" ;
      next ;
    }

    if ($line =~ /<title>/) # Q&D: no check on xml level (below <page>)
    {
      $titles++ ;
      if ($titles % 10000 == 0)
      { print "." ; }
      if ($titles % 100000 == 0)
      { print "\n$titles " ; }
      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($title = $line) =~ s/<[^>]+>//g ;
      print "t $title\n" if $verbose ;
      $title =~ s/,/\&comma\;/g ;
      print CSV_OUT "t,$title\n" ;
      next ;
    }

# print $line if $lines++ < 30 ;
    if ($line =~ /<namespace key/) # Q&D: no check on xml level (below <namespaces>)
  #  if ($line =~ /<namespace.*?key/) # Q&D: no check on xml level (below <namespaces>)
    {
# die ("namespace key") ;    
      chomp $line ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($key = $line) =~ s/^.*?key\="(\-?\d+)".*$/$1/g ;
      ($namespace = $line) =~ s/<[^>]+>//g ;

      print "n $key $namespace\n" if $verbose ;
      $namespace =~ s/,/\&comma\;/g ;
      print CSV_OUT "n,$key,$namespace\n" ;
      next ;
    }

  }
  close CSV_OUT ;

  print ("$titles titles, " . &ddhhmmss (time - $timestart). "\n") ;

}

# overcomplete routine copied form other script of mine for date-time formatting
sub ddhhmmss
{
  my $seconds = shift ;
  my $format  = shift ;

  $days = int ($seconds / (24*3600)) ;
  $seconds -= $days * 24*3600 ;
  $hrs = int ($seconds / 3600) ;
  $seconds -= $hrs * 3600 ;
  $min = int ($seconds / 60) ;
  $sec = $seconds % 60 ;

  if ($format eq '')
  {
    $days = ($days > 0) ? (($days > 1) ? "$days days, " : "$days day, ") : "" ;
    $hrs  = (($days + $hrs > 0) ? (($hrs > 1) ? "$hrs hrs" : "$hrs hrs") : "") . ($days + $hrs > 0 ? ", " : ""); # 2 hrs/1 hr ?
    $min  = ($days + $hrs + $min > 0) ? "$min min, " : "" ;
    $sec  = "$sec sec" ;
    return ("$days$hrs$min$sec") ;
  }
  else
  {
    return sprintf ($format,$days,$hrs,$min,$sec) if $format =~ /%.*%.*%.*%/ ;
    return sprintf ($format,      $hrs,$min,$sec) if $format =~ /%.*%.*%/ ;
    return sprintf ($format,           $min,$sec) if $format =~ /%.*%/ ;
    return sprintf ($format,                $sec) ;
  }
}


