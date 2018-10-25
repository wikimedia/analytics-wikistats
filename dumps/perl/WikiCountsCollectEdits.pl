#!/usr/bin/perl

  use Time::Local ;
  use Getopt::Std ;

  $verbose = 0 ;
  $title_on_each_record = 1 ;

  my %options ;
  getopt ("bdioprw", \%options) ;

  if (defined ($options {'c'}))
  { $write_to_stdout = 1 ; }
  else
  { $| = 1; } # flush output

  $path_in  = $options {'i'} ;
  $path_out = $options {'o'} ;
  $project  = $options {'p'} ;
  $wiki     = $options {'w'} ;
  $dump     = $options {'d'} ;
  $runtimes = $options {'r'} ;
  $silent   = defined ($options {'s'}) ;

  $data = 0 ; # suppress meta messages when output is sent to STD_OUT
  $meta = 1 ;

  die "Specify path for csv input as: -i [some path]" if $path_in eq '' ;
  die "Specify path for csv output as: -o [some path]" if $path_out eq '' ;
  die "Specify project code as: -p [wb|wk|wn|wo|wp|wq|ws|wv|wx|wo]" if $project !~ /^(?:wb|wk|wn|wo|wp|wq|ws|wv|wx|wo)$/ ;
  die "Specify wiki code as: -w [some wiki, e.g. enwiki]" if $wiki eq '' ;
  die "Specify dump file as: -d [full path to stub dump] or -r [log file with wikistats runs]" if $dump eq '' and $runtimes eq '' ;
  die "Specify either dump file as: -d [full path to stub dump] or -r [log file with wikistats runs], not both" if $dump ne '' and $runtimes ne '' ;

  die "Input path not found: $path_in"   if ! -d $path_in ;
  die "Output path not found: $path_out" if ! -d $path_out ;

  if ($wiki eq 'wikidatawiki')
  { $wiki = 'wikidata' ; }

  &Write ($meta, "Read stats and bot names from input dir: $path_in\n") ; 
  &Write ($meta, "Write to output dir: $path_out\n") ; 
  &Write ($meta, "Project code: $project\n") ;
  &Write ($meta, "Wiki code: $wiki\n") ;

  if ($dump ne '')   
  {
    die "Input stub dump not found: $dump" if ! -e $dump ;
    &Write ($meta, "Stub dump: $dump\n") ;
  }
  
  if ($runtimes ne '')
  {
    die "Input log file with wikistats runs not found: $runtimes" if ! -e $runtimes ;
    &Write ($meta, "Log file with run times: $runtimes\n") ;

    if ($wiki =~ /^wikidata(wiki)?$/)
    { $wiki2 = 'wikidata' ; }
    else
    { ($wiki2 = $wiki) =~ s/wiki.*$// ; }  

    &Write ($meta, "Compare language codes in log file '$runtimes' with '$wiki2' (wiki: '$wiki' -> lang code '$wiki2')\n") ; 
    &Write ($meta, "Only check stub dumps with extension '\.gz' (easy to extend, see WikiCountsArguments.pm)\n") ;
    open RUNTIMES, '<', $runtimes || die "Could not open $runtimes" ;
    while ($line = <RUNTIMES>)
    {
      next if $line !~ /xmldatadumps\/public.*?stub-meta-history\.xml\.gz/ ;
      chomp $line ;
      ($lang,$date,$age_in_seconds,$timestamp,$extension,$cnt1,$cnt2,$somevar,$cnt3,$cnt4,$cnt5,$cnt6,$mode,$path) = split (',', $line) ;
      $lang =~ s/ //g ; 
      next if $wiki2 ne $lang ; 
    # print "$date $path\n" ;
      $dump = $path ;
    }
    close RUNTIMES ;
    die "No valid stub dump found for project '$project', wiki '$wiki' in log file '$runtimes'" if $dump eq '' ;
    &Write ($meta, "Use input dump '$dump'\n\n") ;
  }

  $file_newest_dumps = "$path_in/csv_$project/StatisticsNewestDumps.csv" ;
  
  open CSV_IN, '<', $file_newest_dumps || die "Could not open $file_newest_dumps" ;
  binmode CSV_IN ;
  @dumplist = <CSV_IN> ;
  close CSV_IN ;

  open CSV_IN, '<', "$path_out/csv_$project/BotsAll.csv" || die "Could not open $path_out/csv_$project/BotsAll.csv" ;
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

  &Write ($meta, "\nReady\n") ;
  exit ;

sub ProcessDump
{
  my ($project,$wiki,$path) = @_ ;

  $wp = $wiki ; 
  if ($wiki ne 'wikidata')
  { $wp =~ s/wik.*$//g ; }

  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
  my $time = sprintf ("%02d:%02d:%02d", $hh, $mm, $ss) ;
  my $titles = 0 ;
  my $namespace_found ;

  &Write ($meta, "Process project '$project', wiki '$wiki', dump '$path'\n\n") ;
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
  { die ("No line found for $wiki in $path_out/csv_$project/BotsAll.csv\n") ; }
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
  {  die "Unexpected extension: $path\n" ; }

  if ($title_on_each_record)
  { $file_out =  "$path_out/csv_$project/EditsTimestampsTitles" . uc ($wp) . ".csv" ; }
  else
  { $file_out =  "$path_out/csv_$project/EditsTimestamps" . uc ($wp) . ".csv" ; }

  if (! $write_to_stdout)
  {
    &Write ($meta, "Write output to  $file_out\n\n") ;
    open CSV_OUT, '>', $file_out || die "Could not open $file_out" ;
    binmode CSV_OUT ;
  }

  if ($title_on_each_record)
  {
    &Write ($meta, "# record type e:user type,timestamp from xml, timestamp in seconds since 1900, key, namespace, title, username or ip address\n") ;
    &Write ($meta, "# user type: R=registered user, B=bot, A=anonymous, -=undefined\n") ;
  }
  else
  {
    &Write ($meta, "# record types: n=namespace, t=title, e=edit\n") ; 
    &Write ($meta, "# record type e:user type,timestamp from xml, timestamp in seconds since 1900, username or ip address\n") ;
    &Write ($meta, "# user type: R=registered user, B=bot, A=anonymous, -=undefined\n") ;
  }

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
      chomp $line ;
      $line =~ s/[\x00-\x1F]+//g ;
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
      
      $title =~ s/,/%2C/g ;
      $user  =~ s/,/%2C/g ;
      $namespace_found =~ s/,/%2C/g ;

    # print "e $usertype $timestamp $user\n" if $verbose ;
      if ($title_on_each_record) 
      { &Write ($data, "$wiki,e,$usertype,$timestamp,$time_secs," . ($key+0) . ",$namespace_found,$title,$user\n") ; }
      else
      { &Write ($data, "$wiki,e,$usertype,$timestamp,$time_secs,$user\n") ; }

      undef ($timestamp) ;
      undef ($time_secs) ;
      undef ($user) ;

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
      $line =~ s/[\x00-\x1F]+//g ;
      $line =~ s/^\s*// ;
      $line =~ s/\s*$// ;
      ($user = $line) =~ s/<[^>]+>//g ;
      $user =~ s/,/&comma;/g ;
    # print "e A $timestamp $user\n" if $verbose ;

      $title =~ s/,/%2C/g ;
      $user  =~ s/,/%2C/g ;
      $namespace_found =~ s/,/%2C/g ;

      if ($title_on_each_record) 
      { &Write ($data, "$wiki,e,A,$timestamp,$time_secs," . ($key+0) . ",$namespace_found,$title,$user\n") ; }
      else
      { &Write ($data, "$wiki,e,A,$timestamp,$time_secs,$user\n") ; }

      undef ($timestamp) ;
      undef ($time_secs) ;
      undef ($user) ;

      next ;
    }

    if ($line =~ /<title>/) # Q&D: no check on xml level (below <page>)
    {
      undef ($title) ;
      undef ($namespace_found) ;
 
      chomp $line ;
      $line =~ s/[\x00-\x1F]+//g ;
      $titles++ ;
      if ($titles % 10000 == 0)
      { &Write ($meta, ".") ; }
      if ($titles % 100000 == 0)
      { &Write ($meta, "\n$titles ") ; }

      ($title = $line) =~ s/<[^>]+>//g ;
      $title =~ s/^\s*// ;
      $title =~ s/\s*$// ;
      $title =~ s/ /_/g ;

      $key = '0' ;

      if ($title =~ /\:/)
      {
        foreach $ns_name (@namespaces)
        {
         # print "title '$title' matches '$ns_name' ?\n " ;
          if ($title =~ /^$ns_name\:/)
          { 
            $key = $namespaces {$ns_name} ; 
            $namespace_found = $ns_name ;
            $title =~ s/^$ns_name\:// ;
          # print "Found namespace $namespace_found -> key = $key\n" ;
            last ;
          }
        }
      }
     
      $title =~ s/,/\%2C/g ;
      
      if (! $title_on_each_record) 
      { &Write ($data, "$wiki,t,$title\n") ; }
    # print "t $title\n" if $verbose ;

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
      ($ns_key  = $line) =~ s/^.*?key\="(\-?\d+)".*$/$1/g ;
      ($ns_name = $line) =~ s/<[^>]+>//g ;

    # $ns_name =~ s/,/\&comma\;/g ;
      if (! $title_on_each_record) 
      { &Write ($data, "$wiki,n,$ns_key,$ns_name\n") ; }
      else
      { &Write ($meta, "# namespace $ns_key: $ns_name\n") ; }

      if ($ns_key != 0)
      {
        $namespaces {$ns_name} = $ns_key ;
        push @namespaces, $ns_name ; 
        @namespaces = sort {length ($b) <=> length ($a)} @namespaces ;
      }
      next ;
    }

  }

  if ($write_to_stdout)
  { close CSV_OUT ; }

  &Write ($meta, "# $titles titles, " . &ddhhmmss (time - $timestart). "\n") ;
}

sub Write 
{
  my ($meta,$line) = @_ ;
  return if $meta && $write_to_stdout ;
  return if $meta && $silent ;

  if ($write_to_stdout)
  { 
    if ($lines_to_stdout++ > 0) 
    { print "\n" ; }
    $line =~ s/\n$// ;
    print $line ; 
  }
  else
  {
    print         $line if $verbose ;
    print CSV_OUT $line ;
  }
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


