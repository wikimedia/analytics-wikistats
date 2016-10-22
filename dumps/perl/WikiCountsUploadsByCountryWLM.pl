#!/usr/bin/perl

  use Time::Local ;
  use Getopt::Std ;

  use warnings ;
# use strict ;

  # since this is run only once a year, temporary use hardcoded files
  # Q&D past here new file, someday parse html status file, like https://dumps.wikimedia.org/commonswiki/20161001/
  # section "All pages with complete edit history (.7z)"

  $folder_xml = "/mnt/data/xmldatadumps/public/commonswiki/20161001" ;
  @xml_files = qw (commonswiki-20161001-pages-meta-history1.xml-p000000001p001855684.7z
                   commonswiki-20161001-pages-meta-history1.xml-p001855685p004288603.7z
                   commonswiki-20161001-pages-meta-history1.xml-p004288605p006457504.7z
                   commonswiki-20161001-pages-meta-history2.xml-p006457505p011852935.7z
                   commonswiki-20161001-pages-meta-history2.xml-p011852936p016129764.7z
                   commonswiki-20161001-pages-meta-history3.xml-p016129765p023222913.7z
                   commonswiki-20161001-pages-meta-history3.xml-p023222914p029059062.7z
                   commonswiki-20161001-pages-meta-history4.xml-p029059063p035492989.7z
                   commonswiki-20161001-pages-meta-history4.xml-p035492990p043650172.7z
                   commonswiki-20161001-pages-meta-history4.xml-p043650173p051981353.7z) ;
 
  $| = 1; # flush output immediately

  $true  = 1 ;
  $false = 0 ;
  $verbose = $false ; # for debugging 
  $time_format = '%2d hrs %2d min %2d sec' ;

  our %bots ;

  my ($file_bots, $file_xml, $file_counts, $file_names, $file_uploads, $file_edits, $file_html, $file_trace, $file_errors, $path_csv) = &ParseArguments ;

  my @bots = &ReadBots ($file_bots) ; 
  &ReadCountryNames ($file_names) ; # fills global %countries  

  &ParseXml ($file_xml, $file_counts, $file_uploads, $file_edits, $file_html, $file_trace, $file_errors, @bots) ;
 
  &WriteUploaders ($path_csv) ;

  print "\nReady\n" ;
  exit ;

sub WriteUploaders
{
  my ($path_csv) = @_ ;

  $wlm_year_prev = '' ;	
  @uploaders = sort keys %uploaders ;
  foreach $line (@uploaders)
  {
    ($wlm_year,$wlm_user) = split (',',$line,2) ;
    if ($wlm_year !~ /^\d\d\d\d$/)
    {
      print "Invalid wlm_year: '$wlm_year'\nLine '$line'\n" ; 
      next ; 
    }
    if ($wlm_year ne $wlm_year_prev)
    {
      if ($wlm_year_prev ne '')
      { 
        print "close TXT 1\n" ; 
        close TXT ; 
      }
      print "open TXT: $path_csv/WLM_uploaders_$wlm_year.txt\n" ; 
      open TXT, '>', "$path_csv/WLM_uploaders_$wlm_year.txt" ;

      $wlm_year_prev = $wlm_year ;	    
    }	    
    print "print TXT: $wlm_user\n" ; 
    print TXT "$wlm_user\n" ;
  } 

  if ($wlm_year_prev ne '')
  { 
    print "close TXT 2\n" ; 
    close TXT ; 
  }
}

sub ParseArguments
{
  print "- ParseArguments\n" ;	

  my %options ; # script arguments
  getopt ("bonx", \%options) ;   # expect these arguments to come with value 

  $file_bots  = $options {'b'} ; # input file
  $path_csv   = $options {'o'} ; # output folder
  $file_names = $options {'n'} ; # country names 
  $file_xml   = $options {'x'} ; # input file

  die "specify file with bot names as -b [path]"                 if $options {'b'} eq '' ;
  die "specify output folder (for csv file) as -o [path]"        if $options {'o'} eq '' ;
  die "specify country codes->names lookup file as -n [path]"    if $options {'n'} eq '' ;
  die "specify (full archive) xml file as -x [path]"             if $options {'x'} eq '' ;

  die "xml file '$file_xml' not found"                           if ! -e $file_xml ;  # -e is test if file exists
  die "file with bot names '$file_bots' not found"               if ! -e $file_bots ; # -e is test if file exists
  die "country codes->names lookup file '$file_names' not found" if ! -e $file_names ;  # -e is test if file exists
  die "output folder '$path_csv' not found"                      if ! -d $path_csv ;  # -d is test if folder exists
  
  $file_counts  = "$path_csv/WLM_images_by_country_by_year.csv" ;
  $file_uploads = $file_counts ;
  $file_uploads =~ s/\.csv/_uploads.txt/ ;
  $file_edits   = $file_counts ;
  $file_edits   =~ s/\.csv/_edits.txt/ ;
  $file_html    = $file_counts ;
  $file_html    =~ s/\.csv/_inspect.html/ ;
  $file_errors  = $file_counts ;
  $file_errors  =~ s/\.csv/_errors.txt/ ;
  $file_trace   = $file_counts ;
  $file_trace   =~ s/\.csv/_trace.txt/ ;
  
  
  print "Input xml file: $file_xml\n" ; 
  print "Input bot names file: $file_bots\n" ; 
  print "Input country names file: $file_names\n" ; 
  print "Output file counts: $file_counts\n" ; 
  print "Output file uploads: $file_uploads\n" ; 
  print "Output file edits: $file_edits\n" ; 
  print "Output file inspect: $file_html\n" ; 
  print "Trace file: $file_trace\n" ; 
  print "Errors file: $file_errors\n" ; 

  return ($file_bots, $file_xml, $file_counts, $file_names, $file_uploads, $file_edits, $file_html, $file_trace, $file_errors, $path_csv) ;
}

sub ReadBots
{
  print "- ReadBots\n" ;	

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
    foreach $bot (@bots)
    { $bot =~ s/\&comma;/,/g ; } # comma's in user name were encoded
  }

  return (@bots) ;
}

sub ReadCountryNames
{
  my ($file_names) = @_ ;

  print "- ReadCountryNames\n" ;
  print "$file_names\n" ;

  open FILE_NAMES, '<', $file_names ;
  binmode FILE_NAMES ;
  while ($line = <FILE_NAMES>)
  {
    next if $line =~ /^#/ ;
    chomp $line ;
    ($code,$name) = split (',', $line) ;

    # note: double quotes will be added again in csv file
    $name =~ s/^\s*\"\s*// ; # remove leading double quote/spaces
    $name =~ s/\s*\"\s*$// ; # remove trailing double quote/spaces
    print "$code $name\n" ;
        
    if ($code =~ /^[A-Z]+$/)
    { $country_names {lc ($code)} = $name ; }
  }
  close FILE_NAMES ;
}

sub ParseXml
{
  print "- ParseXml\n" ;	

  my ($file_xml, $file_counts, $file_uploads, $file_edits, $file_html, $file_trace, $file_errors, @bots) = @_ ; # function arguments
  my ($bot, $user, $line, $trace, $usertype, $timestamp, $titles, $page_id, $wlm_year, $wlm_country) ;
  my (%bots) ;  # hash file %bots: access one element as $bots{some value}  

  # array -> hash
  foreach $bot (@bots)
  { $bots {$bot} = $true ; }

  my $in_text = $false ; 

  my ($ss,$mm,$hh) = (localtime (time))[0,1,2] ;
  my $time = sprintf ("%02d:%02d:%02d", $hh, $mm, $ss) ;
  $timestart = time ; # save system time

  my $wlm_images        = 0 ;
  my $wlm_any_revision_has_template  = $false ;
  my $wlm_last_revision_has_template = $false ;

  print "Start $time\n\n" ;

  open CSV_UPLOADS, '>', $file_uploads ;
  binmode CSV_UPLOADS ;
  print CSV_UPLOADS "# year,country,file,usertype,user,timestamp,unflagged\n" ;
  print CSV_UPLOADS "# usertype: R=registered user B=bot A=anonymous\n" ;


  open CSV_EDITS, '>', $file_edits ;
  binmode CSV_EDITS ;
  print CSV_EDITS "# page id,file,timestamp,usertype,year,country\n" ;
  print CSV_EDITS "# usertype: R=registered user B=bot A=anonymous\n" ;
# print CSV_EDITS "# commas in page title and user name have been replaced by &comma (easier for post processing than surrounding field by double quotes)\n" ;

  open HTML, '>', $file_html ;
  binmode HTML ;
  print HTML "<head>\n<body>\n" ; # Q&D html file to find and patch anomalies manually

  open TRACE, '>', $file_trace ;
  binmode TRACE ;

  open ERRORS, '>', $file_errors ;
  binmode ERRORS ;

  # process xml (Q&D: no check on proper xml level, (all should be level below <page>)
  $titles = 0 ; 
  $title = '' ;
  $namespace = -1 ;
  $lines = 0 ;

  $page_id       = '' ;
  $wlm_timestamp = '' ;
  $wlm_user      = '' ;
  $wlm_usertype  = '' ;
  $user_trace    = '' ;

  print "\n" ;
#while ($line = <XML>)
#{ 
#  last if $lines++ > 2500000000 ;
#   if ($lines % 10000000 == 0)
#  { print " lines: " . &commify($lines) . "\n" ; }
#} 

  $files_xml = 0 ;
  while ($file_xml = shift (xml_files))
  {
    $file_xml = "$folder_xml/$file_xml" ;
    $files_xml ++ ;
    print "Process xml file $files_xml: $file_xml\n" ;
 
       if ($file_xml =~ /\.gz$/) # extension gz ?
    { open XML, "-|", "gzip -dc \"$file_xml\""   || die ("Input file could not be opened: $file_xml") ; }
    elsif ($file_xml =~ /\.bz2$/) # extension bz2 ?
    { open XML, "-|", "bzip2 -dc \"$file_xml\""  || die ("Input file could not be opened: $file_xml") ; }
    elsif ($file_xml =~ /\.7z$/) # extension 7z ?
    { open XML, "-|", "7z e \"$file_xml\" -so"   || die ("Input file could not be opened: $file_xml") ; }
    else
    {                                               die ("Unexpected extension: $file_xml") ; }

    binmode XML ;
# todo: indent two spaces till 'next file_xml'
  while ($line = <XML>)
  {
    $lines ++ ;	  
    if ($line =~ /^\s*<title>/) 
    {
#last if $lines++ > 3000000000 ;
      $titles++ ;

      if ($wlm_any_revision_has_template)
      {
        $wlm_images++ ;
	
        # $title =~ s/,/\&comma;/g ; # comma's in title disrupt csv format
	# $user  =~ s/,/\&comma;/g ; # same with user id
        if (($wlm_year eq '2010') && ($wlm_country eq '--')) # don't flag this as error
	{ $wlm_country = 'nl' ; }

        $error_reason = '' ;
        $error = $false ;
	if (($wlm_year !~ /^\d\d\d\d$/) || ($wlm_country !~ /^[\w\-]{2,}$/))
	{ $error = $true ; }
	
	if (($wlm_year eq '') || ($wlm_year eq '--'))
	{ $wlm_year = substr ($wlm_timestamp,0,4) ; $error_reason .= "year from creation date, " ; }

	$wlm_country2 = $wlm_country ;
	$wlm_country =~ s/\s*1\s*=\s*// ; # 1=nl -> nl
	if ($wlm_country ne $wlm_country2) 
	{ $error_reason .= "1=xx->xx, " ; }
	
	$wlm_country2 = $wlm_country ;
	$wlm_country =~ s/\s*\{\{lc\:(\w+)/lc($1)/e ; # {{lc:DE -> de
	if ($wlm_country ne $wlm_country2) 
	{ $error_reason .= "{{lc:XX}}->xx, " ; }

	$wlm_country2 = $wlm_country ;
	$wlm_country =~ s/MITTELHESSEN/de/ ;
	if ($wlm_country ne $wlm_country2) 
	{ $error_reason .= "MITTELHESSEN->de, " ; }

	$wlm_country2 = $wlm_country ;
	$wlm_country =~ s/([a-z])\-.*$/$1/ ;
	if ($wlm_country ne $wlm_country2) 
	{ $error_reason .= "xx-yy->xx, " ; }

	$wlm_country2 = $wlm_country ;
	$wlm_country = lc ($wlm_country) ;
	if ($wlm_country ne $wlm_country2) 
	{ $error_reason .= "XX->xx, " ; }

	$error_reason =~ s/, $// ; # remove trailing comman/space

	if ($wlm_last_revision_has_template)
	{
	  $images_per_year_per_country_last_rev          {"$wlm_year,$wlm_country"} ++ ;
	  $images_per_year_per_country_per_user_last_rev {"$wlm_year,$wlm_country"} {$wlm_user} ++ ;
  	  $images_per_year_last_rev                      {$wlm_year} ++ ;
        }  
        
	$images_per_year_per_country_any_rev {"$wlm_year,$wlm_country"} ++ ;
  	$images_per_year_any_rev             {$wlm_year} ++ ;

        $wlm_error_fixed = '' ; $f = "_ ";
	if (($wlm_year =~ /^\d\d\d\d$/) && ($wlm_country =~ /^[\w\-]{2,}$/))
	{ $wlm_error_fixed = "(fixed: $error_reason)" ; $f = "F " ; }
	
        if ($error)
	{
          print ERRORS "$f $page_id,\"$title\",$wlm_timestamp,$wlm_usertype,\"$wlm_user\",$wlm_year,$wlm_country $wlm_error_fixed\n" ;
	  print HTML   "[$wlm_year,$wlm_country] <a href='http://commons.wikimedia.org/w/index.php?title=File:$title\&action=edit'>$f $title $wlm_error_fixed</a><br>\n" ;
	}

        $wlm_unflagged = '-' ; 
	if (! $wlm_last_revision_has_template)
	{ $wlm_unflagged = 'unflagged' ; }

        if ($wlm_usertype eq 'R') # registered user, not a bot
	{ $uploaders {"$wlm_year,$wlm_user"} ++ ; }

	print CSV_UPLOADS "$wlm_year,$wlm_country,\"$title\",$wlm_usertype,\"$wlm_user\",$wlm_timestamp,$wlm_unflagged\n" ;
        
	$wlm_any_revision_has_template = $false ;
        $wlm_last_revision_has_template = $false ;
      }

      $wlm_year    = '--' ;
      $wlm_country = '--' ;
      
      if (! $verbose)
      {
        if ($titles % 1000== 0) 
        { print "." ; }
        if ($titles % 10000 == 0)
        { print " " . &ddhhmmss (time - $timestart, $time_format). " lines: " . &commify($lines) . " pages: " . &commify ($titles) . " WLM images: " . &commify ($wlm_images) . "\n" ; }
      }

      chomp $line ;
      $line =~ s/^\s*//g ;     # remove leading spaces 
      $line =~ s/\s*$//g ;     # remove trailing spaces 
      $line =~ s/<[^>]+>//g ;  # remove tags
      $line =~ s/_/ /g ;       # replace underscores by spaces
      $line =~ s/\&amp;/\&/g ; # replace tag by character
      $title = $line ;

      $title =~ s/^File:// ; # remove namespace prefix for ns 6 (note: is localized on other wikis) 
    # print "\narticle $title\n" if $verbose ;

      $page_id       = '' ;
      $wlm_timestamp = '' ;
      $wlm_user      = '' ;
      $wlm_usertype  = '' ;
    }

    if ($line =~ /^\s*<ns>\d+<\/ns>/) 
    {
      chomp $line ;
      $line =~ s/\s//g ;      # remove spaces 
      $line =~ s/<[^>]+>//g ; # remove tags
      $namespace = $line ;

      next if $namespace != 6 ; # only look further when article is in namepscae 6 (binary upload)
      print "ns $namespace / $title\n" if $verbose ;
    }

    next if $namespace != 6 ; # only look further when article is in namepscae 6 (binary upload)

    if (($line =~ /^\s*<id>/) && ($page_id eq ''))
    {
      chomp $line ;
      $line =~ s/\s//g ;      # remove spaces 
      $line =~ s/<[^>]+>//g ; # remove tags
      $page_id = $line ; 
      print "page id $page_id\n" if $verbose ;
    }

    if ($line =~ /^\s*<timestamp>/) 
    {
      chomp $line ;
      $line =~ s/\s//g ;      # remove spaces 
      $line =~ s/<[^>]+>//g ; # remove tags
      $timestamp = $line ; 

      if ($wlm_timestamp eq '')
      { $wlm_timestamp = $timestamp ; }
    # print "time $timestamp\n" if $verbose ;

      $wlm_last_revision_has_template = $false ; # we will found out about this revision being the last
    }

    if ($line =~ /^\s*<username>/) 
    {
      chomp $line ;
      $line =~ s/^\s*//g ;     # remove leading spaces 
      $line =~ s/\s*$//g ;     # remove trailing spaces 
      $line =~ s/<[^>]+>//g ;  # remove tags
      $line =~ s/_/ /g ;       # replace underscores by spaces
      $line =~ s/\&amp;/\&/g ; # replace tag by character
      $user = $line ;

      if (defined ($bots {$user}))
      { $usertype = 'B' ; } # bot
      elsif (&IpAddress ($user)) # some anons are not specified by <ip>..</ip> tag
      { $usertype = 'A' ; } # anon
      else
      { $usertype = 'R' ; } # registered user

      print "$timestamp $usertype $user\n" if $verbose ;
      if ($wlm_user eq '')
      { $wlm_user = "$user" ; }
      if ($wlm_usertype eq '')
      { $wlm_usertype = $usertype ; }
    }

    if ($line =~ /^\s*<ip>/) 
    {
      chomp $line ;
      $line =~ s/\s//g ;      # remove spaces 
      $line =~ s/<[^>]+>//g ; # remove tags
      $user = $line ;
      print "$timestamp A $user\n" if $verbose ;
      if ($wlm_user eq '')
      { $wlm_user = "$user" ; }
      if ($wlm_usertype eq '')
      { $wlm_usertype = 'A' ; }
    }

    if ($line =~ /^\s*<text/) 
    {
      $in_text = $true ;
      $line =~ s/^\s*<text [^>]+>/\n>>\n/ ;
    }

    if ($in_text)
    {
      my $line2 = $line ;
      $line =~ s/<\/text[^>]*>.*$// ;
      
      if ($line =~ /Loves.*Monuments/i) # first test loosely, not on exact template syntax (somewhat faster on 12M images), and '.' cheaper than '[\s_]'
      {
        chomp $line ;
        if ($line =~ /\{\{Wiki[\s_]Loves[\s_]Monuments/i) # now test more strict (slightly more costly, therefor only as step 2)
	{
  	  $trace = "match! $line\n" ;	      
          $wlm_any_revision_has_template  = $true ; # remember there was at least one wlm revision until all revisions for this page have been processed   
          $wlm_last_revision_has_template = $true ; # assume this is last revison until proven wrong
      
	  if ($line =~ /\{\{Wiki[\s_]Loves[\s_]Monuments\s*\d+/i)
	  {
            $trace .= "wlm_year $line -> " ;		  
            $wlm_year    = $line ;
            $wlm_year    =~ s/^.*?\{\{Wiki.Loves.Monuments\s*//si ;
            $trace .= "$wlm_year -> " ;		  
            $wlm_year    =~ s/^(\d+).*$/$1/ ;
            $trace .= "$wlm_year\n" ;		  
          }

	  if ($line =~ /\{\{Wiki[\s_]Loves[\s_]Monuments\s*\d*\s*\|/i)
          {
            $trace .= "wlm_country $line -> " ;  
	    $wlm_country = $line ;
	    $wlm_country =~ s/^.*?\{\{Wiki.Loves.Monuments\s*\d*\s*\|\s*//si ;
            $wlm_country =~ s/^([^\}]*).*$/$1/ ;
            $trace .= "$wlm_country\n" ;	    
          }
	  
	  $line = "$page_id,\"$title\",$timestamp,$usertype,\"$user\",$wlm_year,$wlm_country\n" ;
	  print CSV_EDITS $line ;
	  $trace .= $line ;
	}	
	else
	{ $trace = "nomatch! $line\n" ; }	      
        
	print TRACE $trace ;
      }

      if ($verbose)
      {
        $line2 =~ s/<\/text[^>]*>.*$/\n<<\n/ ;
        print $line2 ; 	
      }
    }
    
    if ($in_text && ($line =~ /<\/text/)) 
    {
      $in_text = $false ;
    }
  }
  close XML ;
} # next file_xml

  print HTML "</body>\n</html\n" ;

  close CSV_UPLOADS ;
  close CSV_EDITS ;
  close HTML ;
  
  open CSV_COUNTS, '>', $file_counts ;
  binmode CSV_COUNTS ;

  # IMAGES PER YEAR
    
  print            "Images per year:\n" ;
  print CSV_COUNTS "Images per year:\n" ;
  
  # first well formed years
  print CSV_COUNTS "\nWell formed:\n" ;
  foreach $year (sort keys %images_per_year_last_rev)
  { 
    next if $year !~ /^\d\d\d\d$/ and $year ne '--' ;
    $line = $year . ',' . $images_per_year_last_rev {$year} . "\n" ; 
    print CSV_COUNTS $line ; 
  }
  
  # then anomalies
  print CSV_COUNTS "\nAnomalies:\n" ;
  foreach $year (sort keys %images_per_year_last_rev)
  { 
    next if $year =~ /^\d\d\d\d$/ ;
    $line = "[$year]," . $images_per_year_last_rev {$year} . "\n" ; 
    print CSV_COUNTS $line ; 
  }

  # then unflagged
  print CSV_COUNTS "\nIncluding unflagged (but without anomalies)\n\n" ;
  foreach $year (sort keys %images_per_year_any_rev)
  { 
    next if $year !~ /^\d\d\d\d$/ and $year ne '--' ;
    $line = "[$year]," . $images_per_year_any_rev {$year} . "\n" ; 
    print CSV_COUNTS $line ; 
  }

  # IMAGES PER YEAR PER COUNTRY
    
  print CSV_COUNTS "\n\nImages per year per country:\n" ;
  print CSV_COUNTS "\nWell formed: (images and uploaders)\n" ;

  # first well formed year/country pairs
  foreach $year_country_code (sort keys %images_per_year_per_country_last_rev)
  {
    my ($year,$country_code) = split (',', $year_country_code) ; 

    next if $year !~ /^\d\d\d\d$/ ;
    next if $country_code !~ /^[\w\-]{2,}$/ and $country_code ne '--' ;
    
    if (defined ($country_names {$country_code}))
    { $country_name = $country_names {$country_code} ; }
    else
    { $country_name = '--' ; }

    @users = keys %{$images_per_year_per_country_per_user_last_rev {$year_country_code}} ;
    $users = $#users + 1 ;

    foreach $user (sort {$images_per_year_per_country_per_user_last_rev {$year_country_code}{$b} <=> 
	                 $images_per_year_per_country_per_user_last_rev {$year_country_code}{$a}} @users)
    { $user_trace .= "$year,$country_code,$country_name,$user," . $images_per_year_per_country_per_user_last_rev {$year_country_code}{$user} . "\n" ; } 

    $line = "$year,$country_code,$country_name," . $images_per_year_per_country_last_rev {$year_country_code} . ",$users\n" ; 
    print CSV_COUNTS $line ;
  }

  close TRACE ;

  print CSV_COUNTS "\nAnomalies:\n" ;

  # then anomalies
  foreach $key (sort keys %images_per_year_per_country_last_rev)
  {
    my ($year,$country_code) = split (',', $key) ; 

    next if $year =~ /^\d\d\d\d$/ and ($country_code =~ /^[\w\-]{2,}$/ or $country_code eq '--') ;
    
    if (defined ($country_names {$country_code}))
    { $country_name = $country_names {$country_code} ; }
    else
    { $country_name = '--' ; }

    $line = "[$year,$country_code,$country_name]," . $images_per_year_per_country_last_rev {$key} . "\n" ; 
    print CSV_COUNTS $line ;
  }

  print CSV_COUNTS "\nIncluding unflagged (but without anomalies)\n\n" ;

  # then well formed year/country pairs including unflagged as wlm in last revision
  foreach $key (sort keys %images_per_year_per_country_any_rev)
  {
    my ($year,$country_code) = split (',', $key) ; 

    next if $year !~ /^\d\d\d\d$/ ;
    next if $country_code !~ /^[\w\-]{2,}$/ and $country_code ne '--' ;
    
    if (defined ($country_names {$country_code}))
    { $country_name = $country_names {$country_code} ; }
    else
    { $country_name = '--' ; }

    $line = "$year,$country_code,$country_name," . $images_per_year_per_country_any_rev {$key} . "\n" ; 
    print $line ;
    print CSV_COUNTS $line ;
  }

  print CSV_COUNTS "\nUsers (well formed templates, not unflagged)\n\n" ;

  print CSV_COUNTS $user_trace ;

  close ERRORS ;
  
  if ($wlm_last_revision_has_template)
  { $wlm_images++ ; }

  $line = "$wlm_images WLM images found in " . &ddhhmmss (time - $timestart, $time_format). "\n" ;
  print $line ;
  print CSV_COUNTS "\n$line" ;
  close CSV_COUNTS ;
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



