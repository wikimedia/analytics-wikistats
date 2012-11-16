#!/usr/bin/perl

  no warnings 'uninitialized';
  no warnings 'once';

  use lib "/home/ezachte/lib" ;
  use EzLib ;
# $trace_on_exit = $true ;
  ez_lib_version (10) ;

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Getopt::Std ;

  use WikiCountsConversions ;
  use WikiCountsLanguage ;
  use WikiCountsOutput ;
  use WikiCountsLog ;

  $file_log_concise = "WikiCountsLogConcise.txt" ;

  $timestart = time ;

  $deltaLogC = 1 ;
  $time_till = "20100701" ;
  $log_enabled = $true ;

  $file_in_xml = &ChoseXmlDump ;

  $full_archive = ($file_in_xml =~ /history/) ;

  &ReadInputXml ($file_in_xml) ;
  print "\n\nReady\n\n" ;
  exit ;

sub ChoseXmlDump
{
  open LIST, '<', "WikiCountsInputWordCount.csv" ;
  while ($line = <LIST>)
  {
     next if $line !~ /meta-history/ ;
     chomp $line ;
     $line =~ s/^\d+,// ;
     $line =~ s/,.*$// ;
     $line =~ s/^.*?([^\/]+)$/$1/ ;
     # print "1 '$line'\n" ;
     $list_xmldumps_done {$line}++ ;
  }
  close LIST ;

  open LIST, '<', "ListXmlDumpsFullArchive.txt" ;
  while ($path = <LIST>)
  {
    chomp $path ;
    $file = $path ;
    $file =~ s/^.*?([^\/]+)$/$1/ ;
    # print "2 '$file'\n" ;
    if ($list_xmldumps_done {$file} == 0)
    { return ($path) ; }
  }
  close LIST ;
  exit ;
}

sub ReadInputXml
{
  $path_in_xml = shift ;

  $Kb = 1024 ;
  $Mb = $Kb * $Kb ;

  $ImageExtensions = "(gif|jpg|png|bmp|jpeg)";

  $language = "en" ;

  $file_csv = "WikiCountsInputWordCount.csv" ;


  $fileseq = '7' ;

  if ($job_runs_on_production_server)
  {
    $path = $path_in_xml ;
    ($file = $path_in_xml) =~ s/^.*?([^\/]+)$/$1/ ;
    ($wiki = $file) =~ s/-.*$// ;
    ($language = $wiki) =~ s/wik.*$// ;
    LogT "Process path: $path\n" ;
    LogT "Process file: $file\n" ;
    LogT "Process wiki: $wiki\n" ;
    LogT "Process lang: $language\n" ;

    $path_php = "/mnt/php/languages" ;

  # $file_in_xml = "$wiki-$date-pages-meta-history$fileseq.xml.bz2" ;
  # $path_in_xml = "/mnt/data/xmldatadumps/public/$wiki/$date/$file_in_xml" ;
  }
  else
  {
    $path = $path_in_xml ;
    ($file = $path_in_xml) =~ s/^.*?([^\/]+)$/$1/ ;
    ($wiki = $file) =~ s/-.*$// ;
    ($language = $wiki) =~ s/wik.*$// ;
    LogT "Process path: $path\n" ;
    LogT "Process file: $file\n" ;
    LogT "Process wiki: $wiki\n" ;
    LogT "Process lang: $language\n" ;

    $path_in_xml = "w:/\# In Dumps/$file_in_xml" ;
  }


  if ($wiki =~ /^(?:ja|zh|ko)/)
  {
    $ja_zh_ko = $true ;
    $length_stub = 50 ;
  }
  else
  {
    $ja_zh_ko = $false ;
    $length_stub = 200 ;
  }

  &ReadLanguageSettings ;
  &ReadFileXml ($path_in_xml) ;

  &LogT ("\n\nParsing xml file took " . ddhhmmss (time - $timestart). ".\n") ;
  $time_parse_input = time - $timestart ;
}

sub ReadFileXml
{
  $file_in  = shift ;

  if (! -e $file_in)
  { abort ("ReadFileXml \$file_in '$file_in' not found.\n") ; }

  if ($file_in =~ /\.gz$/)
  {
    open FILE_IN, "-|", "gzip -dc \"$file_in\"" || abort ("Input file '" . $file_in . "' could not be opened.") ;
    $fileformat = "gz" ;
  }
  elsif ($file_in =~ /\.bz2$/)
  {
    open FILE_IN, "-|", "bzip2 -dc \"$file_in\"" || abort ("Input file '" . $file_in . "' could not be opened.") ;
    $fileformat = "bz2" ;
  }
  elsif ($file_in =~ /\.7z$/)
  {
       open FILE_IN, "-|", "./7za e -so \"$file_in\"" || abort ("Input file '" . $file_in . "' could not be opened.") ;
    $fileformat = "7z" ;
  }
  else
  {
    open FILE_IN, "<", $file_in || abort ("Input file '" . $file_in . "' could not be opened.") ;
    $fileformat = $file_in ;
    $fileformat =~ s/^.*?\.([^\.]*)$/$1/ ;
  }

  binmode FILE_IN ;

  $filesize = -s $file_in ;
  $fileage  = -M $file_in ;
  $filesize_ondisk = $filesize ;

  if ($filesize == 0)
  { abort ("Input file " . $file_in . " is empty.") ; }

  &LogT ("\nUse temp dir '" . $path_temp . "\'\n") ;
  &LogT ("\n\nRead xml dump file \'" . $file_in . "\'\n\n") ;

  my $file_completely_parsed = $false ;
  $pages_read     = 0 ;
  undef %namespaces_read ;
  $bytes_read = 0 ;
  $mb_read = 0 ;
  $word_count = 0 ;

  undef %namespaces ;
  &ReadInputXmlNamespaces ;

  &LogT  ("File size: " . &i2KbMb ($filesize) . "\n") ;
  &LogT  ("Data read (Mb):\n") ;

  &XmlReadUntil ('(?:<page>|<\/mediawiki>)') ;

  $find_next_title = $false ;
  $article = "" ;
  while ($line = <FILE_IN>)
  {
    if ($line =~ /<title>/i)
    { $pages_read2 ++ ; }

    $bytes_read += length ($line) ;
    if ($lines_read ++ %10000 == 0)
    {
      $pages_read = $namespaces_read {0} ;

      while ($bytes_read > ($mb_read + 50) * $Mb)
      {
        ($min, $hour) = (localtime (time))[1,2] ;
        if ($prev_min ne $min)
        {
          $prev_min = $min ;
          $mb_counts = 0 ;

          $sec_run = (time - $timestart) ;
          $min_run = int ($sec_run / 60) ;
          if (($min % $deltaLogC == 0) || ($min_run - $min_run_LogC > 10))
          {
            $min_run_LogC = $min_run ;

            $mb_delta = $mb_read - $mb_read_prev ;
            $mb_read_prev = $mb_read ;
            $mb_per_hour = sprintf ("%.0f", (60 * $mb_delta) / $deltaLogC) ;
            if (time > $timestart)
            { $pages_per_min = sprintf ("%.0f", $pages_read / ((time - $timestart)/60)) ; }

            &LogC ("\n$wiki   " . sprintf ("%02d", $hour) . ":" . sprintf ("%02d", $min) . ":00 " . int($min_run/60) . "h" . sprintf ("%02d",$min_run%60) . " " .
                  " " . sprintf ("%6d Mb", $mb_read) .
                  "=+" . sprintf ("%5d Mb", $mb_delta) .
                  sprintf ("~%5d Mb/hr", $mb_per_hour) .
                  " free:$disk_free used:$disk_used" .
                  " pages:$pages_read ($pages_per_min/min)\n") ;
          }
       }

       $mb_counts ++ ;
       if ($mb_counts > 10)
       {
         $mb_counts = 0 ;
         &Log (" \n           ") ;
       }
       &Log (($mb_read += 50) . " ") ;
      }
    }

    if ($line =~ /<title>/)
    {
      if ((! $full_archive) || ($article_existed_in_time))
      { $namespaces_read {$namespace}++ ; }

      if ($namespace == 0)
      { &ScanArticle ($tracetime_in, $tracetime_out, , $title, $article) ; }

      $tracetime_in  = '' ;
      $tracetime_out = '' ;
      $find_next_title = $false ;
      $timestamp_in_range = $false ;
      $article_existed_in_time = $false ;

      $article = "" ;
      $intext = $false ;
      $namespace = 0 ;
      chomp $line ;
      ($title = $line) =~ s/^\s*<title>(.*?)<\/title>.*$/$1/ ;

      if ($title =~ /\:./)
      {
        $name = $title ;
        $name =~ s/\:.*$// ;
        $namespace = $namespaces {$name} + 0 ; # enforce numeric
        if (! defined $namespaces {$name})
        {
          $undef_namespaces {$name} ++ ;
          $namespace = 0 ;
        }

        if ($namespace != 0)
        {
          $find_next_title = $true ;
          $title =~ s/^[^\:]*\:// ;
        }
      }
      $namespace += 0 ;
      # if ($find_next_title)
      # {;} # { print "$namespace: $title SKIP!\n" ; }
      # else
      # { print "$title\n" ; }
    }

    # on full archive only process last revision before cutoff time (if any)
    # otherwise process any article content always
    if ($full_archive)
    {
      next if $find_next_title ;

      if ($line =~ /<timestamp>/)
      {
        chomp $line ;
        $timestamp = $line ;
        $timestamp =~ s/^.*<timestamp>(\d\d\d\d).(\d\d).(\d\d).(\d\d).(\d\d).(\d\d)Z<\/timestamp>.*$/$1$2$3$4$5$6/ ;

        if ($timestamp lt $time_till)
        {
          $timestamp_in_range = $true ;
          $article_existed_in_time = $true ;
          $in_range = 'I' ;
          $tracetime_in = "$in_range $timestamp" ;
        }
        else
        {
          $timestamp_in_range = $false ;
          $in_range = 'O' ;
          $tracetime_out = "$in_range $timestamp" ;
          $find_next_title = $true ;
        }
        next ;
      }
    }

    $intext_prev = $intext ;
    if ($line =~ /<text>.*?<\/text>/)
    { $article = $line ; }
    elsif ($line =~ /<text/)
    {
      $intext = 1 ;
      $article  = $line ;
    }
    elsif ($line =~ /<\/text>/)
    {
      $intext = 0 ;
      $article .= $line ;
    }
    elsif ($intext)
    {
      $article .= $line ;
    }
  }

  if ($article_existed_in_time)
  { $namespaces_read {$namespace}++ ; }

  &ScanArticle ($article) ;

  print "$line\n" ;
  $pages_read = $namespaces_read {0} ;
  &LogT ("\n\nPages read: $pages_read, $pages_read2. Word count : $word_count \n") ;

  if ($full_archive)
  { &Log ("\n\nPages per namespace that existed before $time_till:\n") ; }

  foreach $namespace (sort {$a <=> $b} keys %namespaces_read)
  {
    &Log ("$namespace: " . $namespaces_read {$namespace} . "\n") ;
    $all_namespaces += $namespaces_read {$namespace} ;
  }
  &Log ("Total: $all_namespaces\n") ;

  open FILE_CSV, '>>', $file_csv ;
  print FILE_CSV "$time_till,$file_in_xml,$wiki,$date,$min_run,$mb_read,$mb_per_hour,$pages_read,$articles,$word_count\n" ;
  close FILE_CSV ;
}

sub ScanArticle
{
  my ($tracetime_in, $tracetime_out, $title, $article) = @_ ;

  return if $article eq '' ;

  $article =~ s/^.*?<text [^>]*>// ;
  $article =~ s/<\/text\s*>.*$// ;

  $article =~ s/&lt;/</sgo;
  $article =~ s/&gt;/>/sgo;
  $article =~ s/&quot;/\"/sgo;
  $article =~ s/&amp;/&/sgo;

  $size = length ($article) ;

  $do_count      = "-" ;
  $links         = 0 ;
  $wikilinks     = 0 ;
  $imagelinks    = 0 ;
  $categorylinks = 0 ;
  $externallinks = 0 ;

  &ProcessArticle ($article) ;

  if ($full_archive)
  {
    if ($tracetime_in eq '')
    { $tracetime_in = "- .............." ; }
    if ($tracetime_out eq '')
    { $tracetime_out = "- .............." ; }
  }
# print "$tracetime_in $tracetime_out $title\n" ;
# print "\n>>>>\n$article\n<<<<\n" ;
}

sub ProcessArticle    # from WikiCountsInput.pm
{
  my $article = shift ;

#   if (($article =~ m/\#redirect.*?\[\[.*?(?:\||\]\])/ios) || ($article =~ m/$redirtag.*?\[\[.*?(?:\||\]\])/ios))

  $redirect = ($article =~ m/(?:$redirtag).*?\[\[.*?(?:\||\]\])/ios) ;

  return if $redirect ;
  return if $article !~ m/\[\[/ ;

  $articles ++ ;

  #  strip headers, wiki formatting, html
  $article2 = $article;

  $article2 =~ s/\'\'+//go ; # strip bold/italic formatting
  $article2 =~ s/\<[^\>]+\>//go ; # strip <...> html

# $article2 =~  s/[\xc0-\xdf][\x80-\xbf]|
#                 [\xe0-\xef][\x80-\xbf]{2}|
#                 [\xf0-\xf7][\x80-\xbf]{3}/{x}/gxo ;
  $article2 =~  s/[\xc0-\xf7][\x80-\xbf]+/{x}/gxo ;

  $article2 =~ s/\&\w+\;/x/go ;   # count html chars as one char
  $article2 =~ s/\&\#\d+\;/x/go ; # count html chars as one char

# $article2 =~ s/\[\[ $imagetag \: [^\]]* \]\]//gxoi ; # strip image links
# $article2 =~ s/\[\[ .. \: [^\]]* \]\]//gxo ; # strip interwiki links

  $article2 =~ s/\[\[ [^\:\]]+ \: [^\]]* \]\]//gxoi ; # strip image/category/interwiki links
                                                      # a few internal links with colon in title will get lost too
  $article2 =~ s/http \: [\w\.\/]+//gxoi ; # strip external links

  $article4 = $article2 ;

#  $article2 =~ s/\{x\}/x/g ;
#  $article2 =~ s/\=\=+ [^\=]* \=\=+//gxo ; # strip headers
#  $article2 =~ s/\n\**//go ; # strip linebreaks + unordered list tags (other lists are relatively scarce)
#  $article2 =~ s/\s+/ /go ; # remove extra spaces

#  # calc length of stripped articles - internal links
#  $length2 = length ($article2) ;
#  $length3 = $length2 ;
#  while ($article2 =~ /(\[\[ [^\]]* \]\])/gxo)
#  { $length3 -= length ($1) ; }
#  while ($article2 =~ /\[\[ ([^\]\|]* \|)? [^\]]* \]\]/gxo)
#  { $length2 -= length ($1) ; }
#  $size2 = $length2 ;

#  if ($article eq "")
#  { $do_count = "S" ; }
#  elsif ($length2 < $length_stub) { $do_count = "S" ; } # stub

  $words = 0 ;
  $unicodes = 0 ;

  if ($ja_zh_ko)
  {
    while ($article4 =~ m/\{x\}/g)
    { $unicodes++ ; }
    if ($language eq "ja")
    { $words = int ($unicodes * 0.37) ; }
    else
    { $words = int ($unicodes * 0.55) ; }
    $article4 =~ s/(?:\{x\})+/ /g ;
  } # most unicodes are separate characters, each a word
  else
  { $article4 =~ s/\{x\}/x/g ; } # most unicodes are diacritical characters, part of one larger word

  $article4 =~ s/\d+[,.]\d+/number/g ; # count number as one word
  $article4 =~ s/\[\[ (?:[^|\]]* \|)? ([^\]]*) \]\]/$1/gxo ; # links -> text + strip hidden part of links


  while ($article4 =~ m/\b\w+\b/g)
  { $word_count++ ; }

#      undef (@links) ;
#      $links = 0 ;
#      while ($article =~ /\[\[([^\:\]]*)\]\]/go)
#      { push @links, uc ($1) ; }
#      while ($article =~ /\[\[[^\]]{2,3}:/go)
#      { $wikilinks ++ ; }

#      while ($article =~ /\[\[([^\]]{4,}:[^\]]*)\]\]/go)
#      {
#        if (index (substr ($1,0,4),':') > 1)
#        { $wikilinks ++ ; }
#        else
#        {
#          my $a = $1 ;

#          if ($a =~ /^(?:$imagetag)\:/io)
#          {
#            $imagelinks ++ ;
#            if (! $prescan)
#            {
#              my $tag = lc ($a) ;
#              $tag =~ s/^([^:]*):.*$/$1/s ;
#              if ($imagetags {$tag} == 0)
#              { &LogT ("\nNew image tag '" . encode_non_ascii ($tag) . "' encountered\n- ") ; }
#              $imagetags {$tag}++ ;
#            }
#          }
#          else
#          {
#            if ($a =~ /^(?:$categorytag)\:/gio)
#            { $categorylinks ++ ; }
#            else
#            {
#              if ($categorytag ne "category")
#              {
#                if ($a =~ /^category\:/gio)
#                { $categorylinks ++ ; }
#              }
#            }
#          }
#        }
#      }

#      @links = sort { $a cmp $b} @links ;
#      $lprev = "@#$%" ;
#      foreach $lcurr (@links)
#      {
#        if ($lcurr ne $lprev)
#        { $links++ ; }
#        $lprev = $lcurr ;
#      }

#      while ($article =~ m/(https?:)[^\s]+\./go) { $externallinks ++ ; }
#      while ($article =~ m/(ftp:)[^\s]+\./go)    { $externallinks ++ ; }

      # article without html/wiki formatting etc contains over 50% links ?
#      if ($length3 * 2 < $length2) # link list
#      { $links = 0 ; }
}

sub XmlReadUntil
{
  my $text = shift ;
  my $lines_read = 0 ;

  while ($line = <FILE_IN>)
  {
    $bytes_read += length ($line) ;
    if ($lines_read_xml_read_until++ % 1000 == 0)
    { &XmlReadProgress ; }

    if (($line =~ /<\/mediawiki>/) && ($text !~ /<\\\/mediawiki>/))
    {
      $file_in =~ s/.*[\\\/]//g ;
      abort ("String <\/mediawiki> found too soon, while searching for '$text'.") ;
    }

    if ($line =~ /$text/)
    { last ; }
  }
  chomp ($line) ;
}

sub XmlReadProgress
{
  while ($bytes_read > ($mb_read + 10) * $Mb)
  {
    ($min, $hour) = (localtime (time))[1,2] ;
    if ($prev_min ne $min)
    {
      &WriteTraceBuffer ;

      $prev_min = $min ;
      $mb_counts = 0 ;

      if (! $prescan)
      {
        $sec_run = (time - $timestart) ;
        $min_run = int ($sec_run / 60) ;
      # if (($min_run > 0) && ($min_run % $deltaLogC == 0))
      # if (($min_run % $deltaLogC == 0) || ($min_run - $min_run_LogC > 10))
        if (($min % $deltaLogC == 0) || ($min_run - $min_run_LogC > 10))
        {
          $min_run_LogC = $min_run ;

          $mb_delta = $mb_read - $mb_read_prev ;
          $mb_read_prev = $mb_read ;
          $mb_per_hour = sprintf ("%.0f", (60 * $mb_delta) / $deltaLogC) ;
          if ($time > $timestart_parse)
          { $pages_per_min = sprintf ("%.0f", $pages_read / ((time - $timestart_parse)/60)) ; }

          my $edits_prev = 0 ;
          my $edits_now  = 0 ;
          if ($edits_total_previous_run > 0)
          {
            $edits_now     = $edits_total_namespace_a + $edits_total_namespace_x ;
            $edits_compare = $edits_now / $edits_total_previous_run ;
          }

          &LogC ("\n" . sprintf ("%02d", $hour) . ":" . sprintf ("%02d", $min) . ":00 " . int($min_run/60) . "h" . sprintf ("%02d",$min_run%60) . " " .
                sprintf (" %4.1f\%", 100 * $edits_compare) .
                " " . sprintf ("%6d Mb", $mb_read) .
                "=+" . sprintf ("%5d Mb", $mb_delta) .
                sprintf ("~%5d Mb/hr", $mb_per_hour) .
                " free:$disk_free used:$disk_used" .
                " pages:$pages_read ($pages_per_min/min)\n") ;
        }
      }
    }

    $mb_counts ++ ;
    if ($mb_counts > 10)
    {
      $mb_counts = 0 ;
      &Log (" \n           ") ;
    }
    &Log (($mb_read += 10) . " ") ;
  }
}

sub ReadInputXmlNamespaces
{
  my $log = "\n\nParse namespace tags\n" ;
  &XmlReadUntil ('<siteinfo>') ;
  &XmlReadUntil ('<namespaces>') ;
  while ($line = <FILE_IN>)
  {
    $bytes_read += length ($line) ;
    if ($line =~ /<namespace /)
    {
      chomp $line ;
      $key  = $line ;
      $name = $line ;
      $key  =~ s/^.*key="([^\)]*)".*$/$1/ ;

      if ($line =~ /<namespace[^>]*\/>\s*$/)
      { $name = "" ; }
      else
      { $name =~ s/^.*<namespace[^\]]*>([^\]]*)<.*$/$1/ ; }
      $log .= sprintf ("%4s",$key) . " -> '$name'\n" ;
      $namespaces    {$name} = $key ;
      $namespacesinv {$key}  = $name ;
    }
    if ($line =~ /<\/namespaces>/) { last ; }
  }
  &XmlReadUntil ('</siteinfo>') ;

  &LogT ("\n\n$log\n\n") ;
}

sub ReadFileCsv
{
  my ($wp, $date, $day, $month, $year) ;
  my $file_csv = shift ;
  undef @csv  ;

  if (! -e $file_csv)
  { &LogT ("File $file_csv not found.\n") ; return ; }

  open FILE_IN, "<", $file_csv ;
  while ($line = <FILE_IN>)
  {
    if (! ($line =~ /^$language\,/))
    {
      chomp ($line) ;
#     ($wp, $date) = split (",", $line) ;
#     if ((substr ($date,2,1) eq '/') &&
#         (substr ($date,5,1) eq '/'))
#     {
#       $day   = substr ($date,3,2) ;
#       $month = substr ($date,0,2) ;
#       $year  = substr ($date,6,4) ;
#       $date  = timegm (0,0,0,$day, $month-1, $year-1900) ;
#       if ($date > $dumpdate_gm_hi)
#       { next ; }
#     }
      push @csv, $line ;
    }
  }
  close FILE_IN ;
}



