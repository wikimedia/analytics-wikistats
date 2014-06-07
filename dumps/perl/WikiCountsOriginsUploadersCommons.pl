#!/usr/bin/perl

  use warnings ;
  use strict ;

  our $true  = 1 ;
  our $false = 0 ;

  my $time_format = '%2d hrs %2d min %2d sec' ;

# in this script 'uploads' (and, derived from that, 'uploaders') refers to new articles on commons, created in namespace 6
# re-uploads are ignored (sometimes an image is uploaded again after cropping or other small adjustment)

  my $dir_in = "w:/# Out Stat1/csv_wx/" ; # Q&D script, hard coded path

  my $file_creates_commons      = "$dir_in/CommonsUploadersStats/CreatesCommons.csv" ;
  my $file_uploaders_per_month  = "$dir_in/CommonsUploadersStats/CommonsUploadersPerMonth.csv" ;
  my $file_meta                 = "$dir_in/CommonsUploadersStats/CommonsUploadersPerMonthMeta.txt" ;
  my $file_edits_except_commons = "$dir_in/CommonsUploadersStats/EditsPerUserPerMonthPerNamespaceAllProjectsExceptCommons.csv" ;
  my $file_first_month_non_commons_per_user = "$dir_in/CommonsUploadersStats/FirstEditPerUser" ;
  my $file_bots                 = "$dir_in/CommonsUploadersStats/BotsAll.csv" ;

  my @bots = &ReadBots ($file_bots) ;

# &CollectFirstEditsPerUser ($file_edits_except_commons, $file_first_month_non_commons_per_user) ;
  &CollectUploadersPerMonth ($file_creates_commons, $file_uploaders_per_month, $file_edits_except_commons, $file_first_month_non_commons_per_user, $file_meta, @bots) ;

  print "\n\nReady\n\n" ;
  exit ;


sub ReadBots
{
  print "ReadBots ->" ;

  my ($file_bots) = @_ ; # function arguments

  my $wiki = 'commons' ;
  my ($line,$bots,$lang,@bots,%bots) ;

  open FILE_BOTS, '<', $file_bots ;
  binmode FILE_BOTS ;
  while ($line = <FILE_BOTS>)
  {
    if ($line =~ /^$wiki/)
    { $bots = $line ; last ; }
  }
  close FILE_BOTS ;

  if ($bots eq '')
  { print "No line found for '$wiki' in '$file_bots'\n" ; }
  else
  {
    chomp $bots ; # remove eol char
    ($lang,$bots) = split (",", $bots,2) ;
    @bots = split ('\|', $bots) ; # split into array
    foreach my $bot (@bots)
    { $bot =~ s/\&comma;/,/g ; } # comma's in user name were encoded
  }

  print $#bots . " bots found on commons\n\n" ;

  return (@bots) ;
}

sub CollectFirstEditsPerUser
{
  my ($file_edits_except_commons, $file_first_month_non_commons_per_user) = @_ ;
  my ($line, $user, $month, $user_prev) ;

  die "File not found: '$file_edits_except_commons'" if ! -e $file_edits_except_commons ;

  open CSV_IN,  '<', $file_edits_except_commons ;
  open CSV_OUT, '>', $file_first_month_non_commons_per_user || die "Could not open '$file_first_month_non_commons_per_user'" ;

  $file_edits_except_commons =~ s/^.*\//..\// ; # greedy: replace all till last slash with '../'
  print CSV_OUT "#data based on $file_edits_except_commons\n" ;
  print CSV_OUT "#user,month\n" ;

  $user_prev = '' ;
  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;
    next if $line =~ /^\s*$/ ;

    ($user,$month) = split (',', $line) ;

    if (($user ne $user_prev) && ($user_prev ne ''))
    { print CSV_OUT "$user,$month\n" ; }
    $user_prev = $user ;
  }

  close CSV_IN ;
  close CSV_OUT ;
}

sub CollectUploadersPerMonth
{
  my ($file_creates_commons, $file_uploaders_per_month, $file_edits_except_commons, $file_first_month_non_commons_per_user, $file_meta, @bots) = @_ ;

  my ($article_type,$yyyymmddhhnn,$namespace,$usertype,$user,$title,$uploadwizard,
     $line,$lines,$month, $timestart,
     %months, %uploads_per_user_per_month, %uploads_per_month_per_user, %uploads_this_month_per_user,
     %uploads_per_anonymous_user, %uploads_per_bot,
     %first_month_on_commons_per_user, %first_month_non_commons_per_user, %bots) ;

  # array -> hash
  foreach my $bot (@bots)
  { $bots {$bot} = $true ; }

# fields: article type,yyyymmddhhnn,namespace,usertype,user,title,uploadwizard
# usertype  = [A:anonymous|B:bot|R:registered user]
# article type = [-:page contains no internal link|R:page is redirect|S:(link list, deprecated)|S:stub|+:normal article]
# when processing full archive dump: count article only when it contains an internal link (official article definition), and is not a redirect
# when processing full archive dump: only difference for stubs is : those are not counted for alternate article count
# when processing stub dump: article content is unavailable (no test for redirect or stub threshold) -> article count will be higher

  die "File not found: '$file_creates_commons'" if ! -e $file_creates_commons ;

  $lines = 0 ;
  $month = '' ;
  $timestart = time ;

  open TXT_META, '>', $file_meta || die "Could not open '$file_meta'" ;

  open CSV_IN, '<', $file_first_month_non_commons_per_user || die "Could not open '$file_first_month_non_commons_per_user'" ;
  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;

    chomp $line ;
    ($user,$month) = split (',', $line) ;
    $user =~ s/\&comma;/,/g ;
    $first_month_non_commons_per_user {$user} = $month ;
  }
  close CSV_IN ;

  open CSV_IN, '<', $file_creates_commons || die "Could not open '$file_creates_commons'" ; ;
  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ;
    $lines++ ;

  # last if $month gt '2005' ;

    if ($lines % 1000000 == 0)
    { print  &ddhhmmss (time - $timestart, $time_format) . " lines: " . commify ($lines) . "\n" ; }

    chomp $line ;
    ($article_type,$yyyymmddhhnn,$namespace,$usertype,$user,$title,$uploadwizard) = split (',', $line) ;

    next if $namespace != 6 ;

    if (&IpAddress ($user))
    {
      $uploads_per_anonymous_user {$user} ++ ;
      next ;
    }
    if (defined ($bots {$user}))
    {
      $uploads_per_bot {$user} ++ ;
      next ;
    }

    $month = substr ($yyyymmddhhnn,0,7) ;


    $months {$month} ++ ;
    if (not defined $first_month_on_commons_per_user {$user})
    { $first_month_on_commons_per_user {$user} = $month ; }
    elsif ($month lt $first_month_on_commons_per_user {$user})
    { $first_month_on_commons_per_user {$user} = $month ; }

    # $uploads_per_user_per_month {$user} {$month} ++ ;
    $uploads_per_month_per_user {$month} {$user} ++ ;
  }
  close CSV_IN ;

  print "Write $file_uploaders_per_month\n" ;
  open CSV_OUT, '>', $file_uploaders_per_month ;

  # greedy: replace all till last slash with '../'
  $file_creates_commons                   =~ s/^.*\//..\// ;
  $file_first_month_non_commons_per_user  =~ s/^.*\//..\// ;
  $file_edits_except_commons              =~ s/^.*\//..\// ;

  print CSV_OUT "#data based on $file_first_month_non_commons_per_user which is based on $file_edits_except_commons\n" ;
  print CSV_OUT "#data also based on $file_creates_commons\n" ;
  print CSV_OUT "#month,uploaders,new uploaders,new uploaders - veteran editors,repeat uploaders,repeat uploaders - veteran editors\n" ;

  my ($uploaders,
      $new_uploaders,    $new_uploaders_started_elsewhere,
      $repeat_uploaders, $repeat_uploaders_started_elsewhere,
      $new_uploader,     $started_elsewhere) ;

  foreach $month (sort keys %months)
  {
    $uploaders = 0 ;
    $new_uploaders = 0 ;
    $new_uploaders_started_elsewhere = 0 ;
    $repeat_uploaders = 0 ;
    $repeat_uploaders_started_elsewhere = 0 ;
    $new_uploader = 0 ;
    $started_elsewhere = 0 ;

    %uploads_this_month_per_user = %{$uploads_per_month_per_user {$month}} ;

    foreach $user (sort keys %uploads_this_month_per_user)
    {
      # print "$user $month: " . $uploads_this_month_per_user {$user} . "\n" ;
      $uploaders ++ ;
      # so the user uploaded this month, now 2 questions:

      # is it a new kid on the block this month, on commons?
      $new_uploader = ($month eq $first_month_on_commons_per_user {$user}) ;

      # did the user start on commons? (monthly precision only)

      $started_elsewhere = (defined ($first_month_non_commons_per_user {$user}) &&
                           ($first_month_non_commons_per_user {$user} lt $first_month_on_commons_per_user {$user})) ;

      if ($new_uploader)
      {
        $new_uploaders ++ ;
        if ($started_elsewhere)
        { $new_uploaders_started_elsewhere ++ ; }
      }
      else
      {
        $repeat_uploaders ++ ;
        if ($started_elsewhere)
        { $repeat_uploaders_started_elsewhere ++ ; }
      }
    }

    print CSV_OUT "$month,$uploaders,$new_uploaders,$new_uploaders_started_elsewhere,$repeat_uploaders,$repeat_uploaders_started_elsewhere\n" ;
  }
  close CSV_OUT ;

  print TXT_META "Anonymous users:\n\n" ;
  foreach $user (sort {$uploads_per_anonymous_user {$b} <=> $uploads_per_anonymous_user {$a}} keys %uploads_per_anonymous_user)
  { print TXT_META "$user: " . $uploads_per_anonymous_user {$user} . "\n" ; }

  print TXT_META "\n\nBots:\n\n" ;
  foreach $user (sort {$uploads_per_bot {$b} <=> $uploads_per_bot {$a}} keys %uploads_per_bot)
  { print TXT_META "$user: " . $uploads_per_bot {$user} . "\n" ; }

  close TXT_META ;
}

# overcomplete routine (for this script) Q&D copied from other script
sub ddhhmmss
{
  my $seconds = shift ;
  my $format  = shift ;

  my ($days,$hrs,$min,$sec,$text_days,$text_hrs,$text_min,$text_sec) ;

  $days = int ($seconds / (24*3600)) ;
  $seconds -= $days * 24*3600 ;
  $hrs = int ($seconds / 3600) ;
  $seconds -= $hrs * 3600 ;
  $min = int ($seconds / 60) ;
  $sec = $seconds % 60 ;

  if ($format eq '')
  {
    $text_days = ($days > 0) ? (($days > 1) ? "$days days, " : "$days day, ") : "" ;
    $text_hrs  = (($days + $hrs > 0) ? (($hrs > 1) ? "$hrs hrs" : "$hrs hrs") : "") . ($days + $hrs > 0 ? ", " : ""); # 2 hrs/1 hr ?
    $text_min  = ($days + $hrs + $min > 0) ? "$min min, " : "" ;
    $text_sec  = "$sec sec" ;
    return ("$text_days$text_hrs$text_min$text_sec") ;
  }
  else
  {
    return sprintf ($format,$days,$hrs,$min,$sec) if $format =~ /%.*%.*%.*%/ ;
    return sprintf ($format,      $hrs,$min,$sec) if $format =~ /%.*%.*%/ ;
    return sprintf ($format,           $min,$sec) if $format =~ /%.*%/ ;
    return sprintf ($format,                $sec) ;
  }
}

sub commify
{
  my $num = shift ;
  $num =~ s/(\d)(\d\d\d)$/$1,$2/ ;
  $num =~ s/(\d)(\d\d\d,)/$1,$2/ ;
  $num =~ s/(\d)(\d\d\d,)/$1,$2/ ;
  return $num ;
}


# in xml dumps anonymous users are often not specified by address (4 triplets) but by provider
# at least in older edits
# # hence this complicated test, also a few exceptions for self-reported false positives
sub IpAddress
{
  my $user = shift ;
  if (($user eq "Emme.pi.effe") ||
      ($user eq ".mau.") || # exceptions on it:
      ($user eq "Crochet.david.bot") || # exception on en: (Wikiversity)
      ($user eq "A.R. Mamduhi"))        # exception  on eo:
  { return ($false) ; }

  if (($user =~ m/[^\.]{2,}\.[^\.]{2,}\.[^\.]{2,4}$/) ||
      ($user =~ m/^\d+\.\d+\.\d+\./) ||
      ($user =~ m/\.com$/i))
  { return ($true) ; }
  else
  { return ($false) ; }
}



