#!/usr/local/bin/perl

# 4/27/2010 renamed from WikiStatsCompactDammitFiles.pl

# http://article.gmane.org/gmane.science.linguistics.wikipedia.technical/38154/match=new+statistics+stuff
# http://svn.wikimedia.org/viewvc/mediawiki/trunk/webstatscollector/
# https://bugzilla.wikimedia.org/show_bug.cgi?id=13541
# http://de.wikipedia.org/w/api.php?action=query&meta=siteinfo&siprop=general|namespaces|namespacealiases

# Ideas:
# 1 namespace string -> namespace number ? (may not save much space: compress will deal with recurring patterns like these)
# 2 frequency distribution hits per file per first letter _-> manifest crawler
#   assuming crawler collects articles in alphabetical order
# 3 first letter uppercase -> sort (in sections per first two chars ?)

  use lib "/home/ezachte/lib" ;
  use EzLib ;

  $trace_on_exit = $true ;
  ez_lib_version (13) ;

  # set defaults mainly for tests on local machine
# default_argv "-i C:/bayes_backup/a/dammit.lt/pagecounts|-t C:/bayes_backup/a/dammit.lt|-f C:/bayes_backup/a/dammit.lt|-o C:/bayes_backup/a/dammit.lt|-d 20101215" ;
  default_argv "-m|-i C:/bayes_backup/a/dammit.lt/pagecounts|-o C:/bayes_backup/a/dammit.lt|-d 200812" ;

  use CGI qw(:all);
  use URI::Escape;
  use Cwd ;
  $bayes = -d "/a/dammit.lt" ;
# $path_7za = "/usr/lib/p7zip/7za" ;

  use IO::Compress::Bzip2 qw(bzip2 $Bzip2Error) ;

  if (! $bayes)
  {
    print "Test on Windows\n" ;
    use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ; # install IO-Compress-Zlib
    use IO::Compress::Gzip     qw(gzip   $GzipError) ;   # install IO-Compress-Zlib
  }

  $| = 1; # flush screen output

  $true  = 1 ;
  $false = 0 ;
  $threshold = 0 ;
  undef %totals_per_namespace ;

  ($sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst) = gmtime(time);
  $year = $year + 1900;
  $month++ ;
  $month_run = sprintf ("%4d-%2d", $year, $month) ;
  print "Current month: $month_run\n" ;

  $filter = "^(?:outreach|quality|strategy|usability)\.m\$" ;
  print "Filter: $filter\n" ;
  $reg_exp_filter = qr"$filter" ;

  $track = "NonExistingPageForSquidLogMonitoring" ;
  print "Track: $track\n" ;
  $reg_exp_track = qr"$track" ;

# -i "D:/\@Wikimedia/!Perl/#Projects/Visitors Compact Log Files/in" -o "D:/\@Wikimedia/!Perl/#Projects/Visitors Compact Log Files/out"

  my $options ;
  getopt ("iodft", \%options) ;

  $compactmonth = $options {"m"} ;
  $compactday = ! $compactmonth ;

  if (! defined ($options {"i"})) { &Abort ("Specify input dir: -i dirname") } ;
  if ($compactday)
  {
    if (! defined ($options {"o"})) { &Abort ("Specify output dir: -o dirname") } ;
    if (! defined ($options {"f"})) { &Abort ("Specify filter dir: -f dirname") } ;
    if (! defined ($options {"t"})) { &Abort ("Specify tracking dir: -t dirname") } ;
    if (! defined ($options {"d"})) { &Abort ("Specify date range: as yyyymmdd, yyyymm*, yyyy* or *") } ;
  }
  if ($compactmonth)
  {
    if (! defined ($options {"d"})) { &Abort ("Specify date range: as yyyymm, yyyy* or *") } ;
  }


  $dir_in       = $options {"i"} ;
  $dir_out      = $options {"o"} ;
  $dir_filtered = $options {"f"} ;
  $dir_track    = $options {"t"} ;
  $daterange    = $options {"d"} ;

  $work = cwd() ;
  print "Work dir $work\n" ;

  if ($dir_in !~ /[\/\\]/)
  { $dir_in = "$work/$dir_in" ; }

  if ($dir_out eq '')
  { $dir_out = "$work" ; }
  elsif ($dir_out !~ /[\/\\]/)
  { $dir_out = "$work/$dir_out" ; }

  if ($compactmonth && ($dir_out eq ''))
  { $dir_out = $dir_in ; }

  if ($dir_filtered !~ /[\/\\]/)
  { $dir_filtered = "$work/$dir_filtered" ; }

  if ($dir_track !~ /[\/\\]/)
  { $dir_track = "$work/$dir_track" ; }

  if (! -d $dir_in)
  { &Abort ("Input dir not found: $dir_in") } ;

  if (! -d $dir_out)
  {
    print "Create output dir $dir_out\n" ;
    mkdir $dir_out ;
    if (! -d $dir_out)
    { &Abort ("Output dir could not be created.") } ;
  }

  open LOG, ">>", "$work/WikiStatsCompactDammitFiles.log" ;

  if ($compactday)
  {
    if (($daterange !~ /^\d{8}$/) && ($daterange !~ /^\d{6}\*$/) && ($daterange !~ /^\d{4}\*$/) && ($daterange !~ /^\*$/))
    { &Abort ("Specify date range: as yyyymmdd, yyyymm*, yyyy* or *") ; }

    &Log ("\nCompress pagecount files\nin:  $dir_in\nout: $dir_out\nflt: $dir_filtered\ntrack: $dir_track\ndate range: $daterange\n") ;
    $daterange =~ s/\*/\\d+/ ;

    &CompactVisitorStatsOneDay ($dir_in, $dir_out, $dir_filtered, $dir_track, $daterange) ;
  # &UncompactVisitorStats ; # test only, to see if process is revertible
  }

  if ($compactmonth)
  {
    if (($daterange !~ /^\d{6}$/) && ($daterange !~ /^\d{4}\*$/) && ($daterange !~ /^\*$/))
    { &Abort ("Specify date range: as yyyymm, yyyy* or *") ; }

    ($daterange2 = $daterange) =~ s/\*/\\d+/ ;
    &Log ("\nCompress pagecount files\nin:  $dir_in\nout: $dir_out\ndate range: $daterange->$daterange2\n") ;

    &CompactVisitorStatsOneMonth ($dir_in, $dir_out, $daterange2) ;
  }

  &Log ("\nReady\n") ;
  close LOG ;
  exit ;

sub CompactVisitorStatsOneDay
{
  my $dir_in       = shift ;
  my $dir_out      = shift ;
  my $dir_filtered = shift ;
  my $dir_track    = shift ;
  my $daterange    = shift ;

  chdir ($dir_in) || &Abort ("Cannot chdir to $dir_in\n") ;

  local (*DIR);
  opendir (DIR, ".");
  @files = () ;

  while ($file_in = readdir (DIR))
  {
    next if $file_in !~ /^pagecounts-$daterange-\d{6,6}.gz$/ ;

    push @files, $file_in ;
  }

  closedir (DIR);

  @files = sort @files ;

# if (($daterange =~ /^\d{8}$/) and ($#files < 23))
# { &Abort ("Less than 24 files found for date $daterange\n" . @files) ; }

  foreach $file (@files)
  {
    $date = substr ($file,11,8) ;
    $process_dates {$date}++ ;
  }

  &Log ("\n\n") ;

  foreach $date (sort keys %process_dates)
  { &MergeFilesFullDay ($dir_in, $dir_out, $dir_filtered, $dir_track, $date) ; }
}

sub MergeFilesFullDay
{
  my $dir_in       = shift ;
  my $dir_out      = shift ;
  my $dir_filtered = shift ;
  my $dir_track    = shift ;
  my $date         = shift ;

  my $year  = substr ($date,0,4) ;
  my $month = substr ($date,4,2) ;
  my $day   = substr ($date,6,2) ;

  my ($file_out1, $file_out2, $file_out3, $out_day, $hours_missing) ;

  $dir_out = "$dir_out/${year}-${month}" ;
  if (! -d $dir_out)
  {
    mkdir $dir_out ;
    if (! -d $dir_out)
    { &Abort ("Output dir could not be created: $dir_out") } ;
  }

  my @files_today = () ;
  foreach $file (@files)
  {
    next if $file !~ /^pagecounts-$date-\d{6,6}.gz$/ ;

    push @files_today, $file ;
  }

  # very few times (nearly) dupiclate files are found for same hour
  # keep the largest and presumably most complete one
  for ($i = 0 ; $i < $#files_today ; $i++)
  {
    for ($j = $i+1 ; $j <= $#files_today ; $j++)
    {
      if (substr ($files_today [$i],0,25) eq substr ($files_today [$j],0,25))
      {
        $size_i = -s $files_today [$i] ;
        $size_j = -s $files_today [$j] ;
        print "${files_today [$i]}: $size_i\n" ;
        print "${files_today [$j]}: $size_j\n" ;
        if ($size_i > $size_j)
        {
          print "Keep ${files_today [$i]}\n\n" ;
          $files_today [$j]= "" ;
        }
        else
        {
          print "Keep ${files_today [$j]}\n\n" ;
          $files_today [$i]= "" ;
        }
      }
    }
  }

  $time_start = time ;
  $lines = 0 ;

  undef @in_hour ;

  # $file_out = "pagecounts-$year$month$day_full_day" ;
  # open OUT, ">", $file_out ;
  # binmode $file_out ;

# my $out_day1 = IO::Compress::Gzip->new ($file_out1) || &Abort ("IO::Compress::Gzip failed: $GzipError\n") ;
  if ($bayes)
  {
  # $file_out1 = "$dir_out/pagecounts-$year$month$day" . "_fd"  ; # full day
    $file_out2 = "$dir_out/pagecounts-$year$month$day" . "_h" ; # full day, hourly data
  # $file_out3 = "$dir_out/pagecounts-$year$month$day" . "_d" ; # full day, compact, just daily totals
    if ((-e "$file_out2.7z") || (-e "$file_out2.bz2") || (-e "$file_out2.zip") || (-e "$file_out2.gz"))
    {
      &Log ("\nTarget file '$file_out2.[7z|bz2|zip|gz]' exists already. Skip this date.\n") ;
      return ;
    }
    if ($#files_today < 23)
    {
      &Log ("\nLess than 24 files found for target file '$file_out2.7z'. Skip this date.\n") ;
      return ;
    }

    open $out_day2, ">", "$file_out2" || &Abort ("Output file '$file_out2' could not be opened.") ;
  # open $out_day3, ">", "$file_out3" || &Abort ("Output file '$file_out3' could not be opened.") ;
  }
  else
  {
  # $file_out1 = "$dir_out/pagecounts-$year$month$day" . "_fd.gz"  ; # full day
    $file_out2 = "$dir_out/pagecounts-$year$month$day" . "_h.gz" ; # full day, hourly data, count above threshold
    $out_day2 = IO::Compress::Gzip->new ($file_out2) || &Abort ("IO::Compress::Gzip failed: $GzipError\n") ;
  # $file_out3 = "$dir_out/pagecounts-$year$month$day" . "_d.gz" ; # full day, count above threshold
  # $out_day3 = IO::Compress::Gzip->new ($file_out3) || &Abort ("IO::Compress::Gzip failed: $GzipError\n") ;
  }

# binmode $out_day1 ;
  binmode $out_day2 ;
# binmode $out_day3 ;

  # print "File_out1 $file_out1\n" ;
  print "File_out2 $file_out2\n" ;
  # print "File_out3 $file_out3\n" ;

  $file_filtered = "$dir_filtered/pagecounts-$year$month$day.txt" ;
  &Log ("\nFilter file: $file_filtered\n") ;
  open $out_filtered, '>', $file_filtered ;
  binmode $out_filtered ;

  $file_track = "$dir_track/_PageCountsForSquidLogTracking.txt" ;
  &Log ("Tracking file: $file_track\n\n") ;

  for ($hour = 0 ; $hour < 24 ; $hour++)
  { $file_in_found [$hour] = $false ; }

  $files_in_open  = 0 ;
  $files_in_found = 0 ;
  $langprev = "" ;
  foreach $file_in (@files_today)
  {
    next if $file_in eq "" ;

    ($hour = $file_in) =~ s/^pagecounts-\d+-(\d\d)\d+\.gz$/$1/ ;
    $hour = (0+$hour) ;
    # print "            file found '$file_in'\n" ;

    if ($bayes)
    { open $in_hour [$hour], "-|", "gzip -dc \"$file_in\"" || &Abort ("Input file '" . $file_in . "' could not be opened.") ; }
    else
    { $in_hour [$hour] = IO::Uncompress::Gunzip->new ($file_in) || &Abort ("IO::Uncompress::Gunzip failed for '$file_in': $GunzipError\n") ; }
    binmode $in_hour [$hour] ;

    $files_in_open++ ;
    $file_in_found [$hour] = $true ;
    $file_in_open  [$hour] = $true ;
    $files_in_found ++ ;
    $file = $in_hour [$hour] ;
    $line = <$file> ;
    $line =~ s/^(\w+)2 /$1.y /o  ;# project wikipedia comes without suffix -> out of sort order, make it fit by appending suffix
    $line =~ s/^(\w+) /$1.z /o  ;

    ($lang,$title,$count [$hour],$dummy) = split (' ', $line) ;
    $key [$hour] = "$lang $title" ;
  }

  $comment = "# Wikimedia page request counts for $date, each line shows 'subproject title counts'\n" ;
  if ($threshold > 0 )
  { $comment .= "# Count for articles with less than $threshold requests per full day are omitted\n" ; }
  $comment .= "# Subproject is language code, followed by project code\n" ;
  $comment .= "# Project is b:wikibooks, k:wiktionary, n:wikinews, q:wikiquote, s:wikisource, v:wikiversity, z:wikipedia (z added by compression script: wikipedia happens to be sorted last in dammit.lt files)\n" ;
  $comment .= "# Counts format is total per day, followed by count per hour if larger than zero, hour 0..23 shown as A..X (saves up to 22 bytes per line compared to comma separated values)\n" ;
  $comment .= "# If data are missing for some hour (file missing or corrupt) a question mark (?) is shown (and for each missing hour the daily total is incremented with hourly average)\n\n" ;
  print $out_day2 $comment ;
# print $out_day3 $comment ;

  if ($files_in_found < 24)
  {
    for ($hour = 0 ; $hour < 24 ; $hour++)
    {
      if (! $file_in_found [$hour])
      { $hours_missing .= "$hour," ; }
    }
    $hours_missing =~ s/,$// ;
    &Log ("Merge files: date = $date, only $files_in_found files found!\n\n") ;
  }
  else
  { &Log ("Merge files: date = $date\n") ; }

  if ($hours_missing ne '')
  {
    print $out_day2 "#\n" ;
    print $out_day2 "# In this file data are missing for hour(s) $hours_missing!\n" ;
  # print $out_day3 "#\n" ;
  # print $out_day3 "# In this file data are missing for hour(s) $hours_missing!\n" ;
  }
  $comment  = "#\n" ;
  $comment .= "# Lines starting with ampersand (@) show totals per 'namespace' (including omitted counts for low traffic articles)\n" ;
  $comment .= "# Since valid namespace string are not known in the compression script any string followed by colon (:) counts as possible namespace string\n" ;
  $comment .= "# Please reconcile with real namespace name strings later\n" ;
  $comment .= "# 'namespaces' with count < 5 are combined in 'Other' (on larger wikis these are surely false positives)\n" ;
  $comment .= "#\n" ;
  $comment .= "# Page titles are shown unmodified (preserves sort sequence)\n" ;
  $comment .= "#\n" ;
  print $out_day2 $comment ;
# print $out_day3 $comment ;

  $key_low_prev = "" ;
  while ($files_in_open > 0)
  {
    $key_low = "\xFF\xFF";
    for ($hour = 0 ; $hour < 24 ; $hour++)
    {
      if (($files_in_open == 24) || ($file_in_found [$hour] && $file_in_open [$hour]))
      {
        if ($key [$hour] lt $key_low)
        { $key_low = $key [$hour] ; }
      }
    }

    if (($key_low =~ /^nov/) || ($key_low_prev =~ /^nov/))
    { &Log ("key_low '$key_low' (key_low_prev '$key_low_prev')\n") ; }

    $counts = "" ;
    $total  = 0 ;
    for ($hour = 0 ; $hour < 24 ; $hour++)
    {
      if (! $file_in_found [$hour])
      { $counts .= chr ($hour+ord('A')) . '?' ; }
      elsif (($files_in_open == 24) || $file_in_open [$hour])
      {
        if ($key [$hour] eq $key_low)
        {
          $counts .= chr ($hour+ord('A')) . $count [$hour] ;
          $total += $count [$hour] ;
          $file = $in_hour [$hour] ;
          # $line = <$file> ;

          while ($true)
          {
            if ($line = <$file>) #  =~ /^a/)
            {
              $line =~ s/^([\w\-]+)2 /$1.y /o  ; # project wikipedia comes without suffix -> out of sort order, make it fit by appending suffix
              $line =~ s/^([\w\-]+) /$1.z /o  ;
             ($lang,$title,$count [$hour],$dummy) = split (' ', $line) ;
              $key [$hour] = "$lang $title" ;

              last if $lang !~ /\d/ ;
            }
            else
            {
              if ($bayes)
              { close $in_hour [$hour] ; }
              else
              { $in_hour [$hour] -> close () ; }
              $files_in_open-- ;
              $file_in_open [$hour] = $false ;
              $key [$hour] = "\xFF\xFF";

              last ;
            }
          }
        }
      }
    }
    if ($lines == 0)
    { &Log ("\nlines:  project key\n") ; }

    if (++$lines % 100000 == 0)
    { &Log ("$lines: $key_low\n") ; }

  # last if $lines > 10000 ; # test

    last if $key_low eq "\xFF\xFF" ;

    # Q&D fix for unexplained out of order error for what seems to be invalid language
    # remember : no suffix on language code gets replaced by .y or .z to fixed sort order
    # ^nov.mw nov1 1 8765
    # ^nov1.mw nov1 1 931 <--------------
    # ^nov 10_dw_oktobre 1 11421
    ($lang,$title) = split (' ', $key_low) ;
    if ($lang =~ /\d/)
    {
      $invalid_languages {$lang}++ ;
      &Log ("\nSkip invalid language '$lang'\n") ;
      next ;
    }


    if ($key_low_prev gt $key_low)
    {
      for ($hour = 0 ; $hour < 24 ; $hour++)
      { &Log ("hour $hour: key ${key[$hour]}\n") ; }

      &Abort ("Sequence error: '$key_low_prev' gt '$key_low'\n") ;
    }

    if (($key_low_prev eq $key_low)  && ($files_in_open > 0))
    {
      for ($hour = 0 ; $hour < 24 ; $hour++)
      {
         if ($file_in_open [$hour])
         { print "hour $hour: file open,   key ${key [$hour]}\n" ; }
         else
         { print "hour $hour: file closed, key ${key [$hour]}\n" ; }
      }
      &Abort ("Sequence error: '$key_low_prev' eq '$key_low'\n") ;
    }

    # print OUT "$key_low $total$counts\n" ;
#    print $out_day1 "$key_low $total$counts\n" ;

    ($lang,$title) = split (' ', $key_low) ;

    $title =~ s/\%20/_/g ;
    $title =~ s/\%3A/:/gi ;
#   $title =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/seg;
    if (($title !~ /\:/) || ($title =~ /^:[^:]*$/)) # no colon or only on first position
    { $namespace = 'NamespaceArticles' ; }
    else
    { ($namespace = $title) =~ s/([^:])\:.*$/$1/ ; }
    # print "KEY $key_low -> $namespace\n" ;

    if (($lang ne $langprev) && ($langprev ne ""))
    {
      $filter_matches = $lang =~ $reg_exp_filter ;
      if ($filter_matches)
      { print "F $lang\n" ; }
      # else
      # { print "- $lang\n" ; }

      &WriteTotalsPerNamespace ($out_day2, $langprev) ;
    # &WriteTotalsPerNamespace ($out_day3, $langprev) ;
      undef %totals_per_namespace ;
    }
    $langprev = $lang ;

    if (($files_in_found < 24) && ($files_in_found > 0)) # always > 0 actually
    { $total = sprintf ("%.0f",($total / $files_in_found) * 24) ; }

    $totals_per_namespace {"$lang $namespace"} += $total ;

    if ($filter_matches)
    { print $out_filtered "$key_low $total$counts\n" ; }

    if ($key_low =~ $reg_exp_track) # track count for NonExistingPageForSquidLogMonitoring on en.z
    {
      open $out_track, '>>', $file_track ;
      binmode $out_track ;
      print $out_track "$key_low $total$counts\n" ;
      close $out_track ;
    }

    if ($total >= $threshold)
    { print $out_day2 "$key_low $total$counts\n" ;
    # print $out_day3 "$key_low $total\n" ;
    }

    $key_low_prev = $key_low ;
  # print "OUT $key_low $counts\n" ;
  }

  &WriteTotalsPerNamespace ($out_day2, $langprev) ;
# &WriteTotalsPerNamespace ($out_day3, $langprev) ;

  &Log ("File production took " . (time-$time_start) . " seconds\n\n") ;

  &Log ("[$lines, $files_in_open] $key_low\n") ;
# close OUT ;

  if ($bayes)
  {
  # close $out_day1 ;
    close $out_day2 ;
  # close $out_day3 ;
    close $out_filtered ;

#    $cmd = "$path_7za a $file_out2.7z $file_out2" ;
#    $result = `$cmd` ;
#    if ($result =~ /Everything is Ok/s)
#    {
#      $result =~ s/^.*?(Updating.*?)\n.*$/$1 -> OK/s ;
#      unlink $file_out2 ;
#      foreach $file_in (@files_today)
#      {
#        print "unlink $dir_in/$file_in\n" ;
#        unlink "$dir_in/$file_in" ;
#      }
#    }
#    else
#    {
#      print "Delete $file_out2.7z\n" ;
#      unlink "$file_out2.7z" ;
#    }


    $time_start_compression = time ;
    $cmd = "bzip2 -9 -v $file_out2" ;
    &Log ("\n\n$cmd ->\n") ;
    $result = `$cmd` ;
    &Log ("\n\nCompression took " . (time-$time_start_compression) . " seconds\n$result\n") ;

    if ($true)
    {
      foreach $file_in (@files_today)
      {
        print "unlink $dir_in/$file_in\n" ;
        unlink "$dir_in/$file_in" ;
      }
    }
    else
    {
      # print "Delete $file_out2.7z\n" ;
      # unlink "$file_out2.7z" ;
    }
  }
  else
  {
  # $out_day1->close() ;
    $out_day2->close() ;
  # $out_day3->close() ;
    close $out_filtered ;
  }

  &Log ("\nRecords skipped for invalid languages:\n") ;
  foreach $key (sort keys %invalid_languages)
  { &Log ("$key: ${invalid_languages {$key}}\n") ; }

  &Log ("\nTotals per namespace written: $lines_namespace_counts\n") ;
  &Log ("Processed in " . (time-$time_start) . " seconds\n\n") ;
}

sub WriteTotalsPerNamespace
{
  my $out_day = shift ;
  my $lang = shift ;
  my $total ;
  my $totals_per_namespace_other ;

  foreach my $key (sort keys %totals_per_namespace)
  {
    $total = $totals_per_namespace {$key} ;
    if ($total < 5)
    { $totals_per_namespace_other += $total ; }
    else
    {
      # print "@ $key $total\n"  ;
      print $out_day "@ $key $total\n"  ;
      $lines_namespace_counts ++ ;
    }
  }
  if ($totals_per_namespace_other > 0 )
  {
    # print "@ $lang -other- $totals_per_namespace_other\n"  ;
    print $out_day "@ $lang -other- $totals_per_namespace_other\n"  ;
    $lines_namespace_counts ++ ;
  }
}

sub CompactVisitorStatsOneMonth
{
  my $dir_in       = shift ;
  my $dir_out      = shift ;
  my $daterange    = shift ;

  &Log ("\nCompactVisitorStatsOneMonth\n\n") ;

  chdir ($dir_in) || &Abort ("Cannot chdir to $dir_in\n") ;

  local (*DIR);
  opendir (DIR, ".");
  @files = () ;

  while ($dir = readdir (DIR))
  {
    next if ! -d $dir ;
    next if $dir !~ /^\d\d\d\d-\d\d$/ ;

    push @dirs, $dir ;
  }

  closedir (DIR);

  @dirs = sort @dirs ;

  foreach $dir (@dirs)
  {
    &Log ("\n\n" . '-' x 80 . "\n\nCompactVisitorStatsOneMonth:\nCheck dir $dir_in/$dir\n") ;

    if (-e "$dir_in/$dir/a")
    {
      &Log ("Already done -> skip\n\n") ;
      next ;
    }

    ($dir2 = $dir) =~ s/-//g ;
    if ($dir2 !~ /^$daterange/)
    {
      &Log ("Directory out of date range ($daterange) -> skip\n\n") ;
      next ;
    }

    local (*DIR2);
    opendir (DIR2, "$dir_in/$dir");

    undef @files ;
    undef %process_dates ;

    while ($file_in = readdir (DIR2))
    {
      if ($bayes)
      { next if $file_in !~ /^pagecounts-\d{8}_(?:fdt\.7z|h\.bz2)$/ ; }
      else
      { next if $file_in !~ /^pagecounts-\d{8}_fdt$/ ; }

      &Log ("File found: $file_in\n") ;

      push @files, $file_in ;
    }

    closedir (DIR2);

    @files = sort @files ;

    foreach $file (@files)
    {
      $date = substr ($file,11,8) ;
      $process_dates {$date}++ ;
    }

    &Log ("\n\n") ;

    &MergeFilesFullMonth ($dir_in, $dir_out, $dir, @files) ;
  }

  exit ;
}

sub MergeFilesFullMonth
{
  my $dir_in  = shift ;
  my $dir_out = shift ;
  my $dir     = shift ;
  my @files_this_month  = @_ ;

  my $year  = substr ($dir,0,4) ;
  my $month = substr ($dir,5,2) ;

  my (@file_in_open, @file_in_found, @counts, $days_missing) ;
  my $days_in_month = days_in_month ($year, $month) ;

  my ($file_out2) ;

  $lines = 0 ;

  undef @in_day ;
  my $time_start = time ;

  if ($dir eq $month_run)
  { $scope = "part" ; }
  else
  { $scope = "all" ; }

  $file_out = "$dir_out/pagecounts-$year-$month-$scope" ;

  &Log ("\nMergeFilesFullMonth\nIn:  $dir_in/$dir\nOut: $dir_out/$file_out\nDays expected: $days_in_month\n\nProcess...\n") ;

  if ($bayes)
  {
    if ((-e "$file_out.7z") || (-e "$file_out.bz2") || (-e "$file_out.zip") || (-e "$file_out.gz"))
    {
      &Log ("\nTarget file '$file_out.[7z|bz2|zip|gz]' exists already. Skip this month.\n") ;
      return ;
    }
  }


  my $out_month_all = new IO::Compress::Bzip2 "$file_out.bz2" or die "bzip2 failed for $file_out.bz2: $Bzip2Error\n";
  my $out_month_ge5 = new IO::Compress::Bzip2 "${file_out}_ge5.bz2" or die "bzip2 failed for ${file_out}_ge5.bz2: $Bzip2Error\n";

  $out_month_all->binmode() ;
  $out_month_ge5->binmode() ;

  for ($day = 0 ; $day < $days_in_month ; $day++)
  { $file_in_found [$day] = $false ; }

  $files_in_open  = 0 ;
  $files_in_found = 0 ;
  $total_hours_missing = 0 ;
  $langprev = "" ;
  $lines_read_this_month = 0 ;
  @hours_missing_per_day = () ;
  $hours_missing_coded = '' ;
  $lines_omitted_daily = 0 ;

  foreach $file_in (@files_this_month)
  {
    next if $file_in eq "" ;

    ($day = $file_in) =~ s/^pagecounts-\d{6}(\d+)_(?:fdt|fdt\.7z|h\.bz2)$/$1/ ;
    $day = sprintf ("%2d", $day-1) ;

    $file_in = "$dir_in/$year-$month/$file_in" ;
    # print "File $file_in -> day $day\n" ;

    &CheckHoursMissing ($year,$month,$day,$file_in) ;

    if ($bayes)
    {
      if ($file_in =~ /\.bz2$/)
      { open $in_day [$day], "-|", "bzip2 -dc \"$file_in\"" || abort ("Input file '" . $file_in . "' could not be opened.") ; }
      elsif ($file_in =~ /\.7z$/)
      { open $in_day [$day], "-|", "7z e -so \"$file_in\"" || abort ("Input file '" . $file_in . "' could not be opened.") ; }
      else
      { abort ("MergeFilesFullMonth: unexpected file name $file_in.") ; }
    }
    else
    { open $in_day [$day], '<', $file_in || &Abort ("Open failed for '$file_in'\n") ; }

    binmode $in_day [$day] ;

    $files_in_open++ ;
    $file_in_found [$day] = $true ;
    $file_in_open  [$day] = $true ;
    $files_in_found ++ ;

    $file = $in_day [$day] ;
    $line = <$file> ;
    while (($line =~ /^#/) || ($line =~ /^@/))
    { $line = <$file> ; }

    chomp $line ;
    if ($line =~ /^[^ ]+ [^ ]+ [^ ]+$/) # prepare for format change: space will be added between daily total and hourly counts
    {
      ($lang,$title,$counts) = split (' ', $line) ;
    }
    else
    {
      ($lang,$title,$total,$counts) = split (' ', $line) ;
      $counts = "$total$counts" ;
    }

    $key [$day] = "$lang $title" ;
    $counts [$day] = $counts ;
    # print "DAY " . ($day+1) . " KEY ${key [$day]} COUNTS $counts\n" ;
  }
  print "\n" ;

  $comment = "# Wikimedia article requests (aka page views) for year $year, month $month\n" ;
  if ($threshold > 0 )
  { $comment .= "# Count for articles with less than $threshold requests per full month are omitted\n" ; }
  $comment .= "#\n" ;
  $comment .= "# Each line contains four fields separated by spaces\n" ;
  $comment .= "# - wiki code (subproject.project, see below)\n" ;
  $comment .= "# - article title (encoding from original hourly files is preserved to maintain proper sort sequence)\n" ;
  $comment .= "# - monthly total (possibly extrapolated from available data when hours/days in input were missing)\n" ;
  $comment .= "# - hourly counts (only for hours where indeed article requests occurred)\n" ;
  $comment .= "#\n" ;
  $comment .= "# Subproject is language code, followed by project code\n" ;
  $comment .= "# Project is b:wikibooks, k:wiktionary, n:wikinews, q:wikiquote, s:wikisource, v:wikiversity, z:wikipedia\n" ;
  $comment .= "# Note: suffix z added by compression script: project wikipedia happens to be sorted last in dammit.lt files, so add this suffix to fix sort order\n" ;
  $comment .= "#\n" ;
  $comment .= "# To keep hourly counts compact and tidy both day and hour are coded as one character each, as follows:\n" ;
  $comment .= "# Hour 0..23 shown as A..X                            convert to number: ordinal (char) - ordinal ('A')\n" ;
  $comment .= "# Day  1..31 shown as A.._  27=[ 28=\\ 29=] 30=^ 31=_  convert to number: ordinal (char) - ordinal ('A') + 1\n" ;
  $comment .= "#\n" ;
  $comment .= "# Original data source: Wikimedia full (=unsampled) squid logs\n" ;
  $comment .= "# These data have been aggregated from hourly pagecount files at http://dammit.lt/wikistats, originally produced by Domas Mituzas\n" ;
  $comment .= "# Daily and monthly aggregator script built by Erik Zachte\n" ;
  $comment .= "# Each day hourly files for previous day are downloaded and merged into one file per day\n" ;
  $comment .= "# Each month daily files are merged into one file per month\n" ;
# $comment .= "# If data are missing for some hour (file missing or corrupt) a question mark (?) is shown (and for each missing hour the daily total is incremented with hourly average)\n" ;
# $comment .= "# If data are missing for some day  (file missing or corrupt) a question mark (?) is shown (and for each missing day the monthly total is incremented with daily average)\n" ;
  $comment .= "#\n" ;

  $out_month_all->print ($comment) ;
  $comment .= "# This file contains only lines with monthly page request total greater/equal 5\n" ;
  $comment .= "#\n" ;
  $out_month_ge5->print ($comment) ;

  if ($files_in_found < $days_in_month)
  {
    for ($day = 0 ; $day < $days_in_month ; $day++)
    {
      if (! $file_in_found [$day])
      {
        $days_missing .= ($day+1) . "," ;
        $total_hours_missing += 24 ;
        for (my $h = 0 ; $h <= 23 ; $h++)
        { $hours_missing_coded .= chr ($day + ord ('A')) . chr ($h + ord ('A')) .',' ; }
      }
    }

    $days_missing =~ s/,$// ;
    &Log ("Merge files: year $year, month $month, only $files_in_found files found!\n\n") ;

    if ($days_missing =~ /,/)
    {
      $out_month_all->print ("# No input files found for days $days_missing!\n#\n") ;
      $out_month_ge5->print ("# No input files found for days $days_missing!\n#\n") ;
      print           "No input files found for days $days_missing!\n\n" ;
    }
    else
    {
      $out_month_all->print ("# No input file found for day $days_missing!\n#\n") ;
      $out_month_ge5->print ("# No input file found for day $days_missing!\n#\n") ;
      print           "No input file found for day $days_missing!\n\n" ;
    }
  }
  else
  { &Log ("Merge files: year $year, month $month\n\n") ; }

  if ($#hours_missing_per_day > -1)
  {
    $out_month_all->print (@hours_missing_per_day) ;
    $out_month_ge5->print (@hours_missing_per_day) ;
  }

  if ($hours_missing_coded ne '')
  {
    $hours_missing_coded =~ s/,$// ;
    $hours_missing_coded = join (',', sort {$a cmp $b} split (',', $hours_missing_coded)) ; # single hours and full days missing added out of sort order
    $out_month_all->print ("#\n# Hours missing: $hours_missing_coded\n") ;
    $out_month_ge5->print ("#\n# Hours missing: $hours_missing_coded\n") ;
    print           "Hours missing: $hours_missing_coded\n\n" ;
  }

  $monthly_correction = 1 ;
  if ($total_hours_missing == 0)
  {
    $out_month_all->print ("# Data for all hours of each day were available in input\n#\n") ;
    $out_month_ge5->print ("# Data for all hours of each day were available in input\n#\n") ;
    print           "Data for all hours of each day were available in input\n\n" ;
  }
  else
  {
    $monthly_correction = sprintf ("%.4f", ($days_in_month * 24) / ($days_in_month * 24 - $total_hours_missing)) ;
    $out_month_all->print ("#\n# In this file data for $total_hours_missing hours were not encountered in input\n") ;
    $out_month_ge5->print ("#\n# In this file data for $total_hours_missing hours were not encountered in input\n") ;
    $out_month_all->print ("# Monthly totals per page have been extrapolated from available counts: multiplication factor = $monthly_correction\n#\n") ;
    $out_month_ge5->print ("# Monthly totals per page have been extrapolated from available counts: multiplication factor = $monthly_correction\n#\n") ;
    print           "In this file data for $total_hours_missing hours were not encountered in input\n" ;
    print           "Monthly totals per page have been extrapolated from available counts: multiplication factor = $monthly_correction\n\n" ;
  }

  if ($threshold_requests_omitted > 0)
  {
    $out_month_all->print ("# For this month intermediate files (from daily aggregation of hourly files) did no longer contain lines with daily total below $threshold_requests_omitted page requests\n#\n") ;
    $out_month_ge5->print ("# For this month intermediate files (from daily aggregation of hourly files) did no longer contain lines with daily total below $threshold_requests_omitted page requests\n#\n") ;
    print           "# For this month intermediate files (from daily aggregation of hourly files) did no longer contain lines with daily total below $threshold_requests_omitted page requests\n#\n" ;
  }

  $key_low_prev = "" ;
  while ($files_in_open > 0)
  {
  # last if $cycles ++ > 10000 ; # test code

    $key_low = "\xFF\xFF";
    for ($day = 0 ; $day < $days_in_month ; $day++)
    {
      if (($files_in_open == $days_in_month) || ($file_in_found [$day] && $file_in_open [$day]))
      {
        if ($key [$day] lt $key_low)
        { $key_low = $key [$day] ; }
      }
    }

    $counts_per_month = "" ;
    $total_per_month  = 0 ;

    for ($day = 0 ; $day < $days_in_month ; $day++)
    {
      if (! $file_in_found [$day])
      {
      # $counts_per_month .= chr ($day+ord('A')) . '?' ;
      }
      elsif (($files_in_open == $days_in_month) || $file_in_open [$day]) # slight optimization
      {
        if ($key [$day] eq $key_low)
        {
          $ch_day = chr ($day+ord('A')) ;
          $counts_per_day = $counts [$day] ;

          ($total_per_day = $counts_per_day) =~ s/^(\d+).*$/$1/ ;
          $counts_per_day =~ s/^\d+// ; # remove total

          $counts_per_day =~ s/([A-Z]\d+)/$ch_day$1,/g ; # prefix each hourly count with char that represent day
          $counts_per_month .= $counts_per_day ;

          $total_per_month += $total_per_day ;
          $file = $in_day [$day] ;
          # $line = <$file> ;

          while ($true)
          {
            # if (($line = <$file>) && ($lines_read_this_month++ < 10000)) # test code
              if ($line = <$file>)
            {
              next if $line =~ /^#/ ;
              next if $line =~ /^@/ ;

              $line =~ s/^([\w\-]+)2 /$1.y /o  ;
              $line =~ s/^([\w\-]+) /$1.z /o  ;

              chomp $line ;

              if ($line =~ /^[^ ]+ [^ ]+ [^ ]+$/) # prepare for format change: space will be added between daily total and hourly counts
              {
                ($lang,$title,$counts) = split (' ', $line) ;
              }
              else
              {
                ($lang,$title,$total,$counts) = split (' ', $line) ;
                $counts = "$total$counts" ;
              }

              $key [$day] = "$lang $title" ;
              $counts [$day] = $counts ;

              last ;
            }
            else
            {
              close $in_day [$day] ;

              $files_in_open-- ;
              $file_in_open [$day] = $false ;
              $key [$day] = "\xFF\xFF";

              last ;
            }
          }
        }
      }
    }
    if ($lines == 0)
    { &Log ("\nlines:  project key\n") ; }

    if (++$lines % 100000 == 0)
    { &Log ("$lines: $key_low\n") ; }

  # last if $lines > 10000 ; # test

    last if $key_low eq "\xFF\xFF" ;

    # Q&D fix for unexplained out of order error for what seems to be invalid language
    # remember : language code without suffix gets appended by .y or .z to fix sort order
    # ^nov.mw nov1 1 8765
    # ^nov1.mw nov1 1 931 <--------------
    # ^nov 10_dw_oktobre 1 11421
    ($lang,$title) = split (' ', $key_low) ;
    if ($lang =~ /\d/)
    {
      $invalid_languages {$lang}++ ;
      &Log ("\nSkip invalid language '$lang'\n") ;
      next ;
    }

    if ($key_low_prev gt $key_low)
    {
      for ($day = 0 ; $day < $days_in_month ; $day++)
      { &Log ("day " . ($day+1) . ": key ${key[$day]}\n") ; }

      &Abort ("Sequence error: '$key_low_prev' gt '$key_low'\n") ;
    }

    if (($key_low_prev eq $key_low)  && ($files_in_open > 0))
    {
      for ($day = 0 ; $day < $days_in_month ; $day++)
      {
         if ($file_in_open [$day])
         { print "day " . ($day+1) . ": file open,   key ${key [$day]}\n" ; }
         else
         { print "day " . ($day+1) . ": file closed, key ${key [$day]}\n" ; }
      }
      &Abort ("Sequence error: '$key_low_prev' eq '$key_low'\n") ;
    }

    ($lang,$title) = split (' ', $key_low) ;

    if (($title !~ /\:/) || ($title =~ /^:[^:]*$/)) # no colon or only on first position
    { $namespace = 'NamespaceArticles' ; }
    else
    { ($namespace = $title) =~ s/([^:])\:.*$/$1/ ; }

    if (($lang ne $langprev) && ($langprev ne ""))
    {
      $filter_matches = $lang =~ $reg_exp_filter ;
      if ($filter_matches)
      { print "F $lang\n" ; }
    }
    $langprev = $lang ;

    if (($files_in_found < $days_in_month) && ($files_in_found > 0)) # always > 0 actually
    { $total = sprintf ("%.0f",($total / $files_in_found) * $days_in_month) ; }

    $counts_per_month =~ s/,$// ;
    $total_per_month = sprintf ("%.0f", $monthly_correction * $total_per_month) ;

    $out_month_all->print ("$key_low $total_per_month $counts_per_month\n") ;
    if ($total_per_month ge 5)
    { $out_month_ge5->print ("$key_low $total_per_month $counts_per_month\n") ; }

    $key_low_prev = $key_low ;
  }

  &Log ("File production took " . (time-$time_start) . " seconds\n\n") ;

  &Log ("[$lines, $files_in_open] $key_low\n") ;

  $out_month_all->close () ;
  $out_month_ge5->close () ;

  if ($bayes)
  {
    foreach $file_in (@files_this_month)
    {
      print "unlink $dir_in/$file_in (dummy run, test only)\n" ;
      # unlink "$dir_in/$file_in" ;
    }
  }

  &Log ("Processed in " . (time-$time_start) . " seconds\n\n") ;
}

sub CheckHoursMissing
{
  my ($year,$month,$day,$file_in) = @_ ;
  my ($hour,%hours_seen,%hours_valid,$hours_seen,$hours_missing,%hours_missing) ;

# &Log ("\nCheckHoursMissing for day " . ($day+1) . "\n") ;

  if ($bayes)
  {
    if ($file_in =~ /\.bz2$/)
    { open FILE_CHECK, "-|", "bzip2 -dc \"$file_in\"" || abort ("Input file '" . $file_in . "' could not be opened.") ; }
    elsif ($file_in =~ /\.7z$/)
    { open FILE_CHECK, "-|", "7z e -so \"$file_in\"" || abort ("Input file '" . $file_in . "' could not be opened.") ; }
    else
    { abort ("CheckHoursMissing: unexpected file name $file_in.") ; }
  }
  else
  { open FILE_CHECK, '<', $file_in || &Abort ("Open failed for '$file_in'\n") ; }

  binmode FILE_CHECK ;

  $lines_checked = 0 ;
  while ($line = <FILE_CHECK>)
  {
    if ($line =~ /^#.*?requests per full day are omitted/)
    { ($threshold_requests_omitted = $line) =~ s/[^\d]//g ; }

    next if $line =~ /^#/ or $line =~ /^@/ ;

    last if $lines_checked ++ > 10000 ;

    chomp $line ;
    if ($line =~ /^[^ ]+ [^ ]+ [^ ]+$/) # prepare for format change: space will be added between daily total and hourly counts
    {
      ($lang,$title,$counts) = split (' ', $line) ;
    }
    else
    {
      ($lang,$title,$total,$counts) = split (' ', $line) ;
      $counts = "$total$counts" ;
    }
    # &Log ("Counts 1 $counts\n") ; # test

    undef @counts ;
    # $counts = "123A1B2C?D4" ; # test
    $counts =~ s/([A-X])(\d+|\?)/(push @counts,"$1$2"),""/ge ;
    foreach $key (@counts)
    {
      my $hour = ord (substr ($key,0,1)) - ord ('A') ;

      # test code
      # if ($month % 2 == 1)
      # {
      #   if ($day % 3 == 0)
      #   {
      #     next if $hour == 2 ;
      #     if ($hour % 3 == 0)
      #     { $key = substr ($key,0,1,) . '?' ; }
      #   }
      # }
      # else
      # { next if $hour == 2 ; }

      next if $hours_seen {$hour} > 0 ;
      $hours_seen {$hour} = $true ;
      $hours_seen ++ ;
      if ($key =~ /\d/)
      { $hours_valid {$hour} ++ ; }
      else
      {
        $hours_missing {$hour} ++ ;
        $hours_missing ++ ;
        $hours_missing_coded .= chr ($day + ord ('A')) . chr ($hour + ord ('A')) .',' ;
      }
    }
    # &Log ("Counts 2 $counts, seen: $hours_seen, valid:". (join ',', sort {$a <=> $b}  keys %hours_valid) . ", missing: " . (join ',', sort {$a <=> $b} keys %hours_missing) . "\n") ; # test

    last if $hours_seen == 24 ;
  }

  close FILE_CHECK ;

  for ($hour = 0 ; $hour <= 23 ; $hour++)
  {
    if (! $hours_seen {$hour})
    {
      $hours_missing {$hour} ++ ;
      $hours_missing ++ ;
      $hours_missing_coded .= chr ($day + ord ('A')) . chr ($hour + ord ('A')) .',' ;
    }
  }

  if ($lines_checked > 10000)
  { &Log ("\nDay " . ($day+1) . ": not all hours encountered after 10,000 lines !!! Seen (can be ?=missing) " . (join ',', sort {$a <=> $b}  keys %hours_seen) . "\n") ; }

  if ($hours_missing > 0)
  {
    $text_hour = $hours_missing > 1 ? 'hours' : 'hour' ;
    push @hours_missing_per_day, "# Day " . ($day+1) . ": $text_hour missing " .  (join ',', sort {$a <=> $b} keys %hours_missing) . "\n" ;
    print "Day " . ($day+1) . ": $text_hour missing " .  (join ',', sort {$a <=> $b} keys %hours_missing) . "\n" ;
  }

  $total_hours_missing += $hours_missing ;
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

#=============================================================================================================

# snippets obsolete but revivable code / test code

#sub Compact
#{
#  my $day = shift ;
#  &Log ("Compact files for $day\n") ;

#  $file_in  = "pagecounts-$day.out" ;
#  $file_out1 = "pagecounts-${day}_all.gz" ;
#  $file_out2 = "pagecounts-${day}_10plus.gz" ;
#  open IN, "<", $file_in ;
#  binmode $file_in ;

#  my $out_day1 = IO::Compress::Gzip->new ($file_out1) || &Abort ("IO::Compress::Gzip failed: $GzipError\n") ;
#  my $out_day2 = IO::Compress::Gzip->new ($file_out2) || &Abort ("IO::Compress::Gzip failed: $GzipError\n") ;

#  open OUT, ">", $file_out ;
#  binmode $file_out ;

#  $lang_prev = "" ;
#  while ($line = <IN>)
#  {
#    chomp ($line) ;
#    ($lang, $title, $counts) = split (' ', $line) ;
#    $title2 = $title ;
#    $title =~ s/\%20/_/g ;
#    $title =~ s/\%3A/:/g ;
#  # $title =~ s/\%([0-9A-F]{2})/chr(hex($1))/ge ;
#  # if ($title =~ /[\x00-\x1F]/)
#  # { &Log ("> '$title2'\n") ; }
#    $title =~ s/\x00-\x1F/"%" . sprintf ("%X", ord($1)) ;/ge ;
#    print $out_day1 "$lang $title $counts\n" ;
#    ($counts2 = $counts) =~ s/^(\d+).*/$1/ ;
#    if ($counts2 >= $threshold)
#    { print $out_day2 "$lang $title $counts\n" ; }
#    $lang_prev = $lang ;
#  }
#
#  close IN ;
#  $out_day1->close() ;
#  $out_day2->close() ;
#}


#sub GetViewDistribution
#{
#  open OUT, ">", "Views.csv" ;
#  foreach $file_in (@files)
#  {
#    ($hour = $file_in) =~ s/^pagecounts-\d+-(\d\d)\d+\.gz$/$1/ ;
#    $hour = chr(ord('A')+$hour) ;
#    &Log ("Process $hour $file_in\n") ;

#    $in_hour1 = IO::Uncompress::Gunzip->new ($file_in) || &Abort ("IO::Uncompress::Gunzip failed: $GunzipError\n") ;
#    while ($line = <$in_hour1>)
#    {
#      ($lang,$title,$count,$dummy) = split (' ', $line) ;
#      if (($lang eq "en") && ($title !~ /:/)) # only en: and namespace 0
#      {
#        $tot {$hour} += $count ;
#        if ($count < 3)
#        { @counts {$hour . substr ($title,0,1)}++ ; }
#      }
#    }
#    $in_hour1->close () ;
#  }
#
#  print OUT "," ;
#  foreach $hour ('A'..'X')
#  {  print OUT $hour . ", " ; }
#  print OUT "\n" ;
#
#  print OUT "," ;
#  foreach $hour ('A'..'X')
#  {  print OUT $tot {$hour} . ", " ; }
#  print OUT "\n" ;
#
#  for ($c=0; $c < 256; $c++)
#  {
#    # do not print chars " and , as such: confuses csv format
#    if ($c < 33)
#    { print OUT "chr($c), " ; }
#    elsif (chr($c) eq '"')
#    { print OUT "dquote, " ; }
#    elsif (chr($c) eq ',')
#    { print OUT "comma, " ; }
#    else
#    { print OUT chr($c) . ", " ; }
#
#    foreach $hour ('A'..'X')
#    {  print OUT (0+@counts {$hour.chr($c)}) , ", " ; }
#
#    if ($c < 255)
#    { print OUT "\n" ; }
#  }
#  close OUT ;
#}


#sub RecompactVisitorStats
#{
#  my $dir_in = "D:/Wikipedia_Visitors/full_day/" ;
#  chdir ($dir_in) || &Abort ("Cannot chdir to $dir_in\n") ;
#  local (*DIR);
#  opendir (DIR, ".");
#  @files = () ;
#  while ($file_in = readdir (DIR))
#  {
#    next if $file_in !~ /^pagecounts-\d{8,8}_fd.gz$/ ;
#
#    push @files, $file_in ;
#  }

#  $filecnt = $#files+1 ;
#  @files = sort { substr ($a, 20,2) <=> substr ($b, 20,2)} @files ;

#  foreach $file (@files)
#  { &RecompactVisitorStats2 ($file) ; }
#  closedir (DIR, ".");
#}

#sub RecompactVisitorStats2
#{
## http://www.7-zip.org/7z.html
#  my $file = shift ;
#  my $time_start = time ;
#  my $path_7z  = "D:/Wikipedia_Visitors/7z.exe" ;
## my $file_in  = "D:/Wikipedia_Visitors/full_day/2008-07-pagecounts/pagecounts-20080702_fd.gz" ;
#  my $file_in  = "D:/Wikipedia_Visitors/full_day/$file" ;
#  my $file_out ; ($file_out  = $file_in) =~ s/gz$/txt/ ;
#  my $file_7z ;  ($file_7z  = $file_in) =~ s/gz$/7z/ ;

#  &Log ("Process $file_in\n") ;

#  $in_hour  = IO::Uncompress::Gunzip->new ($file_in) || &Abort ("IO::Uncompress::Gunzip failed for '$file_in': $GunzipError\n") ;
#  binmode $in_hour ;
#  open OUT, ">", $file_out ;
#  binmode OUT ;

#  my ($title, $title2) ;
#  while ($line = <$in_hour>)
#  {
#    chomp ($line) ;
#    ($lang,$title,$counts) = split (" ", $line) ;

#    if ($lang ne $lang_prev) { print "$lang " ; }
#    $lang_prev = $lang ;

#    # test pagecounts-20080701_fd.gz
#    # all records  424 Mib compressed (1984 uncompressed)
#    # count > 1    212 Mib compressed ( 733 uncompressed)
#    # count > 2    169 Mib compressed ( 551 uncompressed)
#    next if $counts <= 1 ;

#    $title =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/seg;
#    $title =~ s/\s/_/g;
#    $lang  =~ s/\.z// ; # remove codes that were added to fix sort sequence
#    $lang  =~ s/\.y/2/ ;

#    print OUT "$lang $title $counts\n" ;
#  }

#  print "Close files\n" ;
#  $in_hour  -> close () ;
#  close (OUT) ;

#  &Log ("Compress $file_out\n") ;

#  unlink $file_7z ;
#  $result = `$path_7z a $file_7z $file_out` ;
#  &Log ("Compressed\n") ;
#  &Log ("Result " . ($result+0) . " \n") ;
#  if ((-e $file_7z) && (-s $file_7z > 0) && (($result == 0) || ($result == 7)))
#  { unlink $file_out ; }

#  &Log ("Processed in " . (time-$time_start) . " seconds\n\n") ;
## 0 No error
## 1 Warning (Non fatal error(s)). For example, one or more files were locked by some other application, so they were not compressed.
## 2 Fatal error
## 7 Command line error
## 8 Not enough memory for operation
## 255 User stopped the process
#}


#sub RecompactVisitorStats3
#{
## http://www.7-zip.org/7z.html
#  my $path_7z  = "D:/Wikipedia_Visitors/7z.exe" ;
#  my $file_in  = "D:/Wikipedia_Visitors/full_day/2008-07-pagecounts/pagecounts-20080702_fd.gz" ;
#  my $file_out ; ($file_out  = $file_in) =~ s/gz$/txt/ ;
#  my $file_7z ;  ($file_7z  = $file_in) =~ s/gz$/7z/ ;
## my $file_log = "D:/Wikipedia_Visitors/full_day/2008-07-pagecounts/pagecounts.log" ;

#  $in_hour  = IO::Uncompress::Gunzip->new ($file_in) || &Abort ("IO::Uncompress::Gunzip failed for '$file_in': $GunzipError\n") ;
#  binmode $in_hour ;
## $out_day = IO::Compress::Gzip->new ($file_out) || &Abort ("IO::Compress::Gzip failed: $GzipError\n") ;
## binmode $out_day ;
#  open OUT, ">", $file_out ;
#  binmode OUT ;
## open LOG, ">", $file_log ;
## binmode LOG ;

#  my ($title, $title2) ;
#  while ($line = <$in_hour>)
#  {
#    chomp ($line) ;
#    ($lang,$title,$counts) = split (" ", $line) ;

#    if ($lang ne $lang_prev) { print "$lang\n" ; }
##   last if $lang gt "fs" ;
#    $lang_prev = $lang ;

#    # test pagecounts-20080701_fd.gz
#    # all records  424 Mib compressed (1984 uncompressed)
#    # count > 1    212 Mib compressed ( 733 uncompressed)
#    # count > 2    169 Mib compressed ( 551 uncompressed)
#    next if $counts <= 1 ;

##   next if $lang !~ /^(?:ar|fr)/ ;

#if ($false)
#{
#    $title1b = $title ;
#    $title1b =~ s/(\%[A-Fa-f0-9]{2})/uc($1)/seg;
#    $title1b =~ s/\%28/(/g ;
#    $title1b =~ s/\%29/)/g ;
#    $title1b =~ s/\%3A/:/g ;
#    $title1b =~ s/\%2F/\//g ;
#    $title1b =~ s/\%5C/\\/g ;
#    $title1b =~ s/\%2A/*/g ;
#    $title1b =~ s/\%21/!/g ;
#    $title1b =~ s/\%5F/_/g ;
#    $title1b =~ s/\%2C/,/g ;
#    $title1b =~ s/\%2E/./g ;
#    $title1b =~ s/\%2D/-/g ;
#    $title1b =~ s/\%25/%/g ;
#    $title1b =~ s/\%7E/~/g ;
#    $title1b =~ s/\%27/'/g ;
#    $title1b =~ s/\%3D/=/g ;
#    $title1b =~ s/\%26/&/g ;
#    $title1b =~ s/\%3B/;/g ;
#    $title1b =~ s/\%3F/?/g ;
#    $title1b =~ s/\%2B/+/g ;
#    $title2 = $title1b ;
#    $title2 =~ s/%([A-F0-9]{2})/chr(hex($1))/seg;

#    if ($title1b ne $title2) # if changed anything at all
#    {
#      $title3 = uri_escape ($title2) ;
#      $title3 =~ s/\%28/(/g ;
#      $title3 =~ s/\%29/)/g ;
#      $title3 =~ s/\%3A/:/g ;
#      $title3 =~ s/\%2F/\//g ;
#      $title3 =~ s/\%5C/\\/g ;
#      $title3 =~ s/\%2A/\*/g ;
#      $title3 =~ s/\%21/\!/g ;
#      $title3 =~ s/\%5F/\_/g ;
#      $title3 =~ s/\%2C/,/g ;
#      $title3 =~ s/\%2E/./g ;
#      $title3 =~ s/\%2D/-/g ;
#      $title3 =~ s/\%25/%/g ;
#      $title3 =~ s/\%7E/~/g ;
#      $title3 =~ s/\%27/'/g ;
#      $title3 =~ s/\%3D/=/g ;
#      $title3 =~ s/\%26/&/g ;
#      $title3 =~ s/\%3B/;/g ;
#      $title3 =~ s/\%3F/?/g ;
#      $title3 =~ s/\%2B/+/g ;

#      if ($title1b eq $title3) # process reversible ?
#      {
#        $y++ ;
#        $title2 =~ s/\s/_/g;
#        $title = $title2 ;
#      }
#      else
#      {
#        $n++ ;
#        print "Y $y N $n\n$title\n$title3\n\n" ;
#        print LOG "Y $y N $n\n$title\n$title3\n\n" ;
#      }
#    }
#}
#    $title =~ s/%([a-fA-F0-9]{2})/chr(hex($1))/seg;
#    $title =~ s/\s/_/g;
#    $lang  =~ s/\.z// ; # remove codes that were added to fix sort sequence
#    $lang  =~ s/\.y/2/ ;

#  # print $out_day "$lang $title $counts\n" ;
#    print OUT "$lang $title $counts\n" ;
#  }

#  print "Close files\n" ;
#  $in_hour  -> close () ;
## $out_day -> close () ;
#  close (OUT) ;
#  $result = `$path_7z a $file_out $file_txt` ;
#  print $result ;
#}



# test (partial) reversibility of process
#sub UncompactVisitorStats
#{
#  my $file_in = "out/2009-03/pagecounts-20090301_fdt" ;
#  my $dir_out = "out" ;
#  # $in_hour = IO::Uncompress::Gunzip->new ($file_in) || &Abort ("IO::Uncompress::Gunzip failed for '$file_in': $GunzipError\n") ;
#  open $in_hour, '<', $file_in ;
#  binmode $in_hour ;

#  for ($h=0 ; $h<=23 ; $h++)
#  {
#    $time = sprintf ("%02d",$h) . "0000" ;
##   $file_out = "$dir_out/pagecounts-20090301-$time.gz" ;
#    $file_out = "$dir_out/pagecounts-20090301-$time" ;
#    open $out_day [$h], '>', $file_out ;
##    $out_day [$h] = IO::Compress::Gzip->new ($file_out) ||  &Abort ("IO::Compress::Gzip failed: $GzipError\n");
#    binmode $out_day [$h] ;
#  }

#  while ($line = <$in_hour>)
#  {
#    next if $line =~ /^#/ ;
#    next if $line =~ /^@/ ;
#    chomp ($line) ;
##   print "$line\n" ;
#   if ($lines++ > 10000) { exit ; }
#    ($lang,$title,$counts) = split (" ", $line) ;
#    $lang =~ s/\.z// ;
#    $lang =~ s/\.y/2/ ;
#    $counts =~ s/^\d+// ; # remove (redundant) preceding total
#    while ($counts ne "")
#    {
#      $letter = substr ($counts,0,1) ;
#      $counts = substr ($counts,1) ;
#      ($count = $counts) =~ s/^(\d+).*$/$1/ ;
#      $counts =~ s/^\d+(.*)$/$1/ ;
#      $h = ord ($letter) - ord ('A') ;
#      $file = $out_day [$h] ;
#      $writes {$h} ++ ;
#      print $file "$lang $title $count\n" ;
#    }

#  }

#  for ($h=0 ; $h<=23 ; $h++)
#  {
##   $out_day [$h] -> close () ;
#    close $out_day [$h] ;
#  }
#}


