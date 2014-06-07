#!/usr/bin/perl

# quick hack: based on stripped down version of WikiCountInput.pl (wikistats) and some code from WikiToTome*.pl
# when use for production purposes code could use some cleaning up

$| = 1; # flush screen output

use CGI::Carp qw(fatalsToBrowser);
use Time::Local ;
use Getopt::Std ;
use Digest::MD5 qw(md5_hex);

$Kb = 1024 ;
$Mb = $Kb * $Kb ;
$true  = 1 ;
$false = 0 ;
$debug = $false ;
$deltaLogC = 10 ;
$dump2csv  = $true ;
$compare_revisions = $false ;
# $only = "Aussagenlogik" ;

$TABLE1 = "<tbl1>" ;
$TABLE2 = "<tbl2>" ;

$timestart_parse = time ;

$language = "DE" ; # test wil AF for speed
$file_csv  = "ScanArchive$language.csv" ;
$file_txt  = "ScanArchiveDebug$language.txt" ;
$file_txt2 = "ScanArchiveDebug${language}2.txt" ;

# $file_in_xml_full = "D:/Wikipedia_XML/pages_full_$language.xml" ;
$file_in_xml_full = "/mnt/benet/public/dewiki/20070727/dewiki-20070727-pages-meta-history.xml.bz2" ;
if (! -e $file_in_xml_full)
{ $file_in_xml_full = "D:/Wikipedia_XML/pages_articles_de.xml" ; }

if ($file_in_xml_full =~ /^\//)
{
  $file_in_sql_usergroups = "/mnt/benet/public/dewiki/20070727/dewiki-20070727-user_groups.sql.gz" ;
  $file_in_sql_users      = "/mnt/benet/private/dewiki/20070727/dewiki-20070727-user.sql.gz" ;
  if (! -e $file_in_sql_usergroups)
  { abort ("File '$file_in_sql_usergroups' could not be opened.") ; }
  if (! -e $file_in_sql_users)
  { abort ("File '$file_in_sql_users' could not be opened.") ; }

  &ReadBots ;
}
&ReadInputXml ;

print "\n\nSuspect users not registered as bots:\n" ;
foreach $bot (sort {@bots_suspected {$b} <=> @bots_suspected {$a}} keys %bots_suspected)
{ print "$bot:" . @bots_suspected {$bot} . " edits\n" ; }

print "Ready" ;
exit ;

sub ReadInputXml
{
  if ($debug)
  {
    open "FILE_TXT",  ">", $file_txt  || abort ("File '$file_txt' could not be opened.") ;
    open "FILE_TXT2", ">", $file_txt2 || abort ("File '$file_txt2' could not be opened.") ;
  }
  else
  { open "FILE_CSV", ">", $file_csv || abort ("File '$file_csv' could not be opened.") ;}

  &ReadFileXml ($file_in_xml_full) ;

  close FILE_DUMP ;

  &Log ("\n\nParsing xml file took " . mmss (time - $timestart_parse). ".\n") ;
}

sub ReadFileXml
{
  $file_in  = shift ;

  if (! -e $file_in)
  { abort ("Input file " . $file_in . " not found.") ; }

  if ($file_in =~ /\.gz$/)
  { open "FILE_IN", "-|", "gzip -dc \"$file_in\"" || abort ("Input file " . $file_in . " could not be opened.") ; }
  elsif ($file_in =~ /\.bz2$/)
  { open "FILE_IN", "-|", "bzip2 -dc \"$file_in\"" || abort ("Input file " . $file_in . " could not be opened.") ; }
  elsif ($file_in =~ /\.7z$/)
  { open "FILE_IN", "-|", "./7za e -so \"$file_in\"" || abort ("Input file " . $file_in . " could not be opened.") ; }
  else
  { open "FILE_IN", "<", $file_in || abort ("Input file " . $file_in . " could not be opened.") ; }

  binmode "FILE_IN" ;

  $filesize = -s $file_in ;
  $fileage  = -M $file_in ;

  if ($filesize == 0)
  { abort ("Input file " . $file_in . " is empty.") ; }

  &Log ("\nRead xml dump file \'" . $file_in . "\'\n") ;

  my $file_completely_parsed = $false ;
  $pages_read     = 0 ;
  $revisions_read = 0 ;
  $bytes_read     = 0 ;
  $mb_read        = 0 ;

  undef %namespaces ;
  &ReadInputXmlNamespaces ;

  &Log  ("File size: " . &i2KbMb ($filesize) . "\n") ;
  &Log  ("Data read (Mb):\n") ;

  &XmlReadUntil ('(?:<page>|<\/mediawiki>)') ;
  while ($line =~ /<page>/)
  {
    $pages_read ++ ;
    &ReadInputXmlPage ;
    &XmlReadUntil ('(?:<page>|<\/mediawiki>)') ;
  }

  if ($line !~ /<\/mediawiki>/)
  { &XmlReadUntil ('<\/mediawiki>') ; }
  if ($line =~ /<\/mediawiki>/)
  { $file_completely_parsed = $true ; }

  if (! $file_completely_parsed)
  {
    $file_in =~ s/.*[\\\/]//g ;
    abort ("String <\/mediawiki> not found at end of file '" . $file_in . "'. Incomplete or corrupt file?") ;
  }

  if (($pages_read == 0) || (($revisions_read == 0)))
  {
    $file_in =~ s/.*[\\\/]//g ;
    abort ("No data found in file '" . $file_in . "': $pages_read pages, $revisions_read revisions. File empty? XML layout changed?") ;
  }
  &Log ("\n\nPages read: $pages_read. Revisions(=records) read: $revisions_read \n") ;
}

sub XmlReadUntil
{
  my $text = shift ;
  while ($line = <FILE_IN>)
  {
    $bytes_read += length ($line) ;
    while ($bytes_read > ($mb_read + 10) * $Mb)
    {
      ($min, $hour) = (localtime (time))[1,2] ;
      if ($prev_min ne $min)
      {
        $prev_min = $min ;
        $mb_counts = 0 ;

        $sec_run = (time - $timestart) ;
        $min_run = int ($sec_run / 60) ;
        if ($min_run % $deltaLogC == 0)
        {
          $mb_delta = $mb_read - $mb_read_prev ;
          $mb_read_prev = $mb_read ;
          $mb_per_hour = sprintf ("%.0f", (60 * $mb_delta) / $deltaLogC) ;

          &Log ("\n" . sprintf ("%02d", $hour) . ":" . sprintf ("%02d", $min) . " - " .
                "run:" . hhmm2($min_run) .
                ",read: " . sprintf ("%6d", $mb_read) .
                "=+" . sprintf ("%5d", $mb_delta) .
                ",p/h: " . sprintf ("%5d", $mb_per_hour)) ;
        }

        &LogTime ;
        &Log (" - ") ;
      }

      $mb_counts ++ ;
      if ($mb_counts > 10)
      {
        $mb_counts = 0 ;
        &Log ("\n        ") ;
      }
      &Log (($mb_read += 10) . " ") ;
    }

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

sub XmlReadBetween
{
  my $tag = shift ;
  &XmlReadUntil ("<$tag>") ;

  my $text = $line ;
  $text =~ s/^.*<$tag>// ;
  while (($line !~ /<\/$tag>/) && ($line = <FILE_IN>))
  {
    $bytes_read += length ($line) ;
    chomp ($line) ;
    $text .= $line ;
  }
  $text =~ s/^\s*// ;
  $text =~ s/<\/$tag>.*$// ;
  $text =~ s/>\s*</></g ;
  $text =~ s/\s*$// ;

  return ($text) ;
}

sub ReadInputXmlNamespaces
{
  &Log ("\n\nParse namespace tags\n\n") ;
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
      &Log (sprintf ("%4s",$key) . " -> '$name'\n") ;
      @namespaces    {$name} = $key ;
      @namespacesinv {$key}  = $name ;
    }
    if ($line =~ /<\/namespaces>/) { last ; }
  }
  &XmlReadUntil ('</siteinfo>') ;
  &Log ("\n\n") ;
}

# now that old sql code has been removed undo the following: (7/2006)
# unescape and escape so that text is in old sql escaped format
sub DecodeXML
{
  my $text = shift;
# unescape xml
  $text =~ s/&lt;/</sg;
  $text =~ s/&gt;/>/sg;
  $text =~ s/&apos;/'/sg;
  $text =~ s/&quot;/"/sg;
  $text =~ s/&amp;/&/sg;
  $text =~ s/\\\'/\#\*\$\@/sg ; # use encoded single quotes needed for old sql format
  return ($text) ;              # to differentiate between quotes in text and added by dump
}

sub ReadInputXmlPage
{
  undef @revisions ;
  my $file_revisions = $path_temp . "RevisionsCached" ;
  my $ndx_revisions = 0 ;

  my $namespace  = 0 ;
  my $edits ;

  &XmlReadUntil ('<title>') ;

  $title = $line ;
  $title =~ s/^.*<title>(.*)<\/title>.*$/$1/ ;
  $title_full = $title ;

  if ($title =~ /\:./)
  {
    $name = $title ;
    $name =~ s/\:.*$// ;
    $namespace = @namespaces {$name} + 0 ; # enforce numeric

    if (! defined @namespaces {$name})
    { @undef_namespaces {$name} ++ ; }

    # if ($namespace != 0)
    # { $title =~ s/^[^\:]*\:// ; }
  }

  if (($namespace % 2 > 0) || (($namespace > 0) && ($namespace < 100)))
  {
    # print "\nSkip $title\n" ;
    &XmlReadUntil ('<\/page>') ;
    return ;
  }

  $title = &DecodeXML ($title) ;
  # &Log ("Title $title\n") ;

  &XmlReadUntil ('<revision>') ;

  if (($only ne "") && ($title !~ /^$only$/i))
  {
    &XmlReadUntil ('(?:<revision>|<\/page>)') ;
    return ;
  }
  undef (%users) ;
  $anonymous_edits  = 0 ;
  $bot_edits        = 0 ;
  $irrelevant_edits = 0 ;
  $relevant_edits   = 0 ;
  $reverted_edits   = 0 ;

  $article_prev = "" ;
  $user_prev = "" ;
  $md5_list = "" ;
  while ($line =~ /<revision>/)
  {
    ($article, $time, $user) = &ReadInputXmlRevision ;
    $user = DecodeXML ($user) ;
    $md5 = md5_hex($article);

    if ($compare_revisions)
    { ($article, $stripped) = &Strip ($article) ; }

    if ($md5_list =~ /$md5/)
    { $reverted_edits++ ; }
  # { $reverted_edits++ ; print "\nRevert: $title $time\n" ; }
    elsif (&IpAddress ($user))
    { $anonymous_edits++ ; }
    # to do: try to get list of registered bots from csv_wp/bots.csv (currently not available)
    elsif ((@bots {$user} > 0) || ($user =~ /conversion script$/i))
    { $bot_edits++ ; }
    else
    {
      if ($user =~ /bot$/i)
      { @bots_suspected {$user}++ ; }

      if ($article eq $article_prev)
      { $irrelevant_edits++ ; }
      else
      {
        $relevant_edits++ ;
        @users {$user}++ ;
      }
    }
    $md5_list .= "|$md5" ;
    $article_prev = $article ;
    $user_prev    = $user ;

    &XmlReadUntil ('(?:<revision>|<\/page>)') ;
  }

  $anonymous_edits  += 0 ; # '' -> '0'
  $relevant_edits   += 0 ; # '' -> '0'
  $irrelevant_edits += 0 ; # '' -> '0'
  $bot_edits        += 0 ; # '' -> '0'
  $reverted_edits   += 0 ; # '' -> '0'

  if (! $compare_revisions)
  { ($article, $stripped) = &Strip ($article) ; }
  $size = length ($article) ;

  if ($size >= 1800) # article should be at least 1800 bytes
  {
#    if ($debug || ($articles_selected++ == 50))
#    {
#      print "\n\nSuspect users not registered as bots:\n" ;
#      foreach $bot (sort keys %bots_suspected)
#      { print "$bot:" . @bots_suspected {$bot} . " edits\n" ; }
#      exit ;
#    }

    $registered_edits = "" ;
    foreach $user (sort {@users{$b} <=> @users{$a}} keys %users)
    {
      $user =~ s/\|/&pipe;/g ;
      $user =~ s/\:/&colon;/g ;
      $user =~ s/\,/&comma;/g ;
      if ($registered_edits ne "")
      { $registered_edits .= ',' ; }
      $registered_edits .= "$user:" . (@users {$user}+0) ;
    }
    $anonymous_edits = ($anonymous_edits+0) ; # "" -> "0"
    if ($registered_edits eq "")
    { $registered_edits = "-" ; }

    if ($debug)
    {
      print FILE_TXT  "$size|$time|$title|$anonymous_edits|$bot_edits|$reverted_edits|$irrelevant_edits|$relevant_edits|$registered_edits\n\n>\n$article\n<\n\n" ;
      print FILE_TXT  "$stripped====================================================================\n\n" ;
      print FILE_TXT2 "\n\n$title\n>\n$article\n<\n\n" ;
    }
    else
    { print FILE_CSV "$size|$time|$title|$anonymous_edits|$bot_edits|$reverted_edits|$irrelevant_edits|$relevant_edits|$registered_edits\n" ; }
  }
  # debug:
  if (($only ne "") && ($title =~ /^$only$/))
  { exit ; }
}

sub ReadInputXmlRevision
{
  $revisions_read ++ ;

  my ($time, $article, $contributor, $user, $user_id) ;

  &XmlReadUntil ('<timestamp>') ;
  $timestamp = $line ;
  $time = $timestamp ;
  $time =~ s/^.*<timestamp>(.*)<\/timestamp>.*$/$1/ ;
  $time =~ s/^(\d\d\d\d).(\d\d).(\d\d).(\d\d).(\d\d).(\d\d).*$/$1$2$3$4$5$6/ ;

  $contributor = &XmlReadBetween ('contributor') ;

  $user = '?' ;
  $user_id   = '?' ;

  if ($contributor =~ /<username>(.*)<\/username>/)
  { $user = $1 ; }
  if ($contributor =~ /<id>(.*)<\/id>/)
  { $user_id = $1 ; }
  if ($contributor =~ /<ip>(.*)<\/ip>/)
  { $user = $1 ; }

  if (($user eq '?') && ($user_id eq '?'))
  { $user = "???" ; &Log ("\nTimestamp $timestamp:\nTitle '$title':\nNo user info retrieved from contributor element:\n'$contributor'\n") ; }

  &XmlReadUntil ('<text ') ;
  chomp ($line) ;

  if ($line =~ /<text[^\>]*\/>/)
  { $article = "" ; }
  else
  {
    $article = $line ;
    $article =~ s/^.*<text[^\>]*>// ;
    while (($line !~ /<\/text>/) && ($line = <FILE_IN>))
    {
      $bytes_read += length ($line) ;
      $article .= $line ;
    }

    $article =~ s/<\/text.*$// ;
    $totsize_revisions += length ($article) ;
  }

  my $month = substr ($time,0,6) ;
  my $date  = substr ($time,0,8) ;

  if ($namespace != 0)
  { $article = "" ; } # not interested in content

  $article =~ s/`/*{|}*/g ;
  $user    =~ s/`/*{|}*/g ;

  return ($article, $time, $user) ;
}

sub Strip
{

  my $article = shift ;
  my ($stripped, $stripped2, $stripped3) ;
  $article =~ s/\n/\\n/gs ;
  $article = &DecodeXML ($article) ;

  # remove math formula's which can be very unwieldy
  if ($article =~ /<math/)
  {
    $stripped .= "\nRemove math:\n\n" ;
    $article =~ s/(<math>.*?<\/math>)/($stripped .= "'$1' -> ''\n","")/ge ;
  }

  # remove (nearly all) interlanguage links
  $stripped .= "\nRemove interwiki links:\n\n" ;
  $article =~ s/(\[\[\w{2,3}\:[^\]]+\]\])/($stripped .= "'$1' -> ''\n","")/ge ;
  $article =~ s/(\[\[\w{2,3}-\w{2,3}\:[^\]]+\]\])/($stripped .= "'$1' -> ''\n","")/ge ;
  $article =~ s/(\[\[(?:meta|minnan|simple|sep11|tokipona|be-x-old|zh[-\w]+)\:[^\]]+\]\])/($stripped .= "'$1' -> ''\n","")/ge ;

  # remove image, first those with embedded link in description then those without such link, and galleries
  $stripped .= "\nRemove images:\n\n" ;
  $article =~ s/(\[\[(?:image|bild|beeld):[^\[\]]*\[+[^\[\]]*\]+[^\[\]]*\]\])/($stripped .= "'$1' -> ''\n","")/gie ;
  $article =~ s/(\[\[(?:image|bild|beeld):[^\]]+\]\])/($stripped .= "'$1' -> ''\n","")/gie ;
  $article =~ s/(<gallery>.*?<\/gallery>)/($stripped .= "'$1' -> ''\n","")/gie ;

  # remove html
  $stripped .= "\nRemove html:\n\n" ;
  $article =~ s/(<.*?>)/($stripped .= "'$1' -> ''\n","")/ge ;

  # remove category tags
  $stripped .= "\nRemove categories:\n\n" ;
  $article =~ s/(\[\[:?(?:category|kategorie):.*?\]\])/($stripped .= "'$1' -> ''\n","")/gie ;

  # remove headers entirely
  $stripped .= "\nRemove headers:\n\n" ;
  $article =~ s/\\n\s*(==+)([^=\\]+)(==+)/($stripped .= "'$1$2$3' -> ''\n","")/ge ;

  $stripped .= "\nReplace unicode and html chars:\n\n" ;
  # unicode char -> x (count as one char)
  $article =~ s/[\xc0-\xdf][\x80-\xbf]|[\xe0-\xef][\x80-\xbf]{2}|[\xf0-\xf7][\x80-\xbf]{3}/*/g ;
  # &#123; -> x (count as one char)
  $article =~ s/&nbsp;/ /g ;
  $article =~ s/(\&\#?[\d\w]{1,7};)/($stripped .= "'$1' -> '*'\n","*")/ge ;

  # this rather complicated code section to remove templates is partly based on WikiToTome
  # it is not
  if ($article =~ /\{\{/)
  {
    $stripped .= "\nRemove templates:\n\n" ;
    $article =~ s/(\{\{\!\}\})/($stripped .= "'$1' -> ''\n","")/ge ;
    $article =~ s/(\{\{\!\-\}\})/($stripped .= "'$1' -> ''\n","")/ge ;
    $article =~ s/(^|(?:\\n))\s*\{\|/$1$TABLE1/go ;   # replace {| by encrypted table start
    $article =~ s/(^|(?:\\n))\s*\|\}(?:$|[^\}])/$1$TABLE2$2/go ;   # replace |} by encrypted table stop

    my $nested    = 0 ;
    while (($nested++ < 99) && (! $abort_template_processing))
    {
      my $articleprev = $article ;
      my $nested2 = 0 ;
      while ($nested2++ < 99)
      {
        my $articleprev2 = $article ;
        $article =~ s/(\{\{\{\{\{\s*\}\}\}\}\})/($stripped .= "'$1' -> ''\n","")/ge ;
        $article =~ s/(\{\{\{\{\s*\}\}\}\})/($stripped .= "'$1' -> ''\n","")/ge ;
        $article =~ s/(\{\{\{\s*\}\}\})/($stripped .= "'$1' -> ''\n","")/ge ;
        $article =~ s/(\{\{\s*\}\})/($stripped .= "'$1' -> ''\n","")/ge ;
        if ($article eq $articleprev2)
        { last ; }
      }

      my $nested2 = 0 ;
      while ($nested2++ < 99)
      {
        my $articleprev2 = $article ;
        $article =~ s/(\{\{\{  [^\{\}]+  \}\}\})/($stripped .= "'$1' -> ''\n","")/geox ;
        if ($article eq $articleprev2) { last ; }
      }

      $article =~ s/`/\&backtick;/g ;
      $article =~ s/\{\{/`\{\{/g ;
      $article =~ s/\}\}/`\}\}/g ;
      $article =~ s/(`\{\{ [^`]+ `\}\})/($a=$1, $a=~ s#`##g, $stripped .= "\n'$a' -> ''\n","")/geox ;
      $article =~ s/`\{\{/\{\{/g ;
      $article =~ s/`\}\}/\}\}/g ;
      $article =~ s/\&backtick;/`/g ;

      if ($article eq $articleprev) { last ; }
    }

    $article =~ s/$TABLE1/\{\|/g ;  # restore 'hidden' table start symbols
    $article =~ s/$TABLE2/\|\}/g ;  # restore 'hidden' table stop symbols
  }

#  print "Article: \n'$article'\n" ;

#  for ($i = 0; $i < 5; $i++) # this is only rough approximation may miss
# { $article =~ s/(\{\{.*?\}\})/($stripped .= "'$1' -> ''\n","")/ge ; }

  # remove (most of) wiki tables
  if ($article =~ /\{\|/)
  {
    $stripped .= "\nRemove wiki tables:\n\n" ;
    # $article =~ s/((?:[^\\\|][^\|] | \\[^nr]))\{\|/$1."&#123;&#124;"/goe ;
    # $article =~ s/((?:[^\\].|\\[^nr]))\|\}/$1."&#124;&#125;"/goe ;

  # prefix table delimiters with nesting level
    my $nested = 0 ;
    $article =~ s/((?:\{\|)|(?:\|\}))/($1 eq "\{\|") ?
                                       "\!".($nested++).$1:
                                       ($nested > 0)?"\!".(--$nested).$1 :$1/gxe ;
    while ($nested > 0)
    { $article .= "\!" . (--$nested) . "\|\}" ; } # assume end of table at end of article

    for ($nested = 9 ; $nested >= 0 ; $nested--)
    {  $article =~ s/(\!$nested\{\| .*? \!$nested\|\})/($a=$1, $a=~s#\!$nested##g, $stripped .= "\n'$a' -> ''\n","")/gxe ;
    }

    $article =~ s/\!\-?\d[\{\|]//go ; # leftovers, should not happen
  }

  # remove external links
  $stripped .= "\nRemove external links:\n\n" ;
  $article =~ s/(\[(?:http|https|ftp)\:[^\]]+\])/($stripped .= "'$1' -> ''\n","")/ge ;
  $article =~ s/((?:http|https|ftp)\:[^\s]+)/($stripped .= "'$1' -> ''\n","")/ge ;

  # remove (most of) wiki tables (quick and dirty, may leave part of nested tables)
  # better code is available at WikiToTome job, to be worked on
#  for ($i = 0; $i < 5; $i++) # this is only rough approximation may miss
  # { $article =~ s/(\{\|[^\{]*?\|\})/($stripped .= "table removed: " . length($1) . " bytes\n","")/ge ; }
#  { $article =~ s/(\{\|.*?\|\})/($stripped .= "'$1' -> ''\n","")/ge ; }

  # remove misc wiki markup
  $stripped .= "\nRemove misc wiki markup:\n\n" ;
  # [[A|B]] -> B
  $article =~ s/(\[\[[^\]\|]+\|)([^\]]+)(\]\])/($stripped .= "'$1$2$3' -> '$2'\n","$2")/ge ;
  # [[A]] -> A
  $article =~ s/\[\[([^\]]+)\]\]/($stripped .= "'[[$1]]' -> '$1'\n","$1")/ge ; # remove <...> ~ html tags

  # remove list chars (# * ; :)
  $article =~ s/\\n([\#\*\;\:]+)/($stripped2 .= "$1 ","\\n")/ge ;
  if ($stripped2 ne "")
  { $stripped .= "List markup removed: $stripped2\n" ; }

  # remove bold/italic markup
  $article =~ s/(''+)/($stripped3 .= "$1 ","\\n")/ge ;
  if ($stripped3 ne "")
  { $stripped .= "Italic/Bold markup removed: $stripped3\n" ; }

  # remove line breaks
  $article =~ s/\\n//g ;

  # count multiple spaces as one space
  $article =~ s/ +/ /g ;
  return ($article, $stripped) ;
}

# some subroutine only make real sense in the original WikiCountInput.pl code where they contain more code
sub abort
{
  $msg = shift ;
  print "$msg\n" ;
  exit ;
}

sub LogTime
{
  my ($min, $hour) = (localtime (time))[1,2] ;
  &Log ("\n" . sprintf ("%02d", $hour) . ":" . sprintf ("%02d", $min)) ;
}

sub Log
{
  $msg = shift ;
  print "$msg" ;
}

sub i2KbMb
{
  my $v = shift ;
  if ($v > $Mb)
  { $v = sprintf ("%.1f",($v / $Mb)) . " Mb" ; }
  else
  { $v = sprintf ("%.0f",($v / $Kb)) . " Kb" ; }
  return ($v) ;
}

sub mmss
{
  my $seconds = shift ;
  return (int ($seconds / 60) . " min, " . ($seconds % 60) . " sec") ;
}

sub hhmm
{
  my $minutes = shift ;
  return (sprintf ("%02d", int ($minutes / 60)) . " hrs, " . sprintf ("%02d", ($minutes % 60)) . " min") ;
}

sub hhmm2
{
  my $minutes = shift ;
  return (sprintf ("%02d", int ($minutes / 60)) . ":" . sprintf ("%02d", ($minutes % 60))) ;
}

sub csv
{
  my $s = shift ;
  return (&csv2($s) . ",") ;
}

sub csv2
{
  my $s = shift ;
  if (defined ($s))
  {
    $s =~ s/^\s+// ;
    $s =~ s/\s+$// ;
    $s =~ s/\,/&#44;/g ;
  }
  if ((! defined ($s)) || ($s eq ""))
  { $s = 0 ; } # not all fields are numeric, but those that aren't are never empty
  return ($s) ;
}

sub csv3
{
  my $s = shift ;
  $s =~ s/\n/\\n/gos ;
  return (&csv ($s)) ;
}

sub IpAddress
{
  my $user = shift ;
  if (($user eq "Emme.pi.effe") || ($user eq ".mau.") || # exceptions on it:
      ($user eq "A.R. Mamduhi"))                         # exception  on eo:
  { return ($false) ; }

  if (($user =~ m/[^\.]{2,}\.[^\.]{2,}\.[^\.]{2,4}$/) ||
      ($user =~ m/^\d+\.\d+\.\d+\./) ||
      ($user =~ m/\.com$/i))
  { return ($true) ; }
  else
  { return ($false) ; }
}

sub ReadBots
{
#  $read_stored_bots = $false ;
#  if (($file_in_sql_users      eq "") ||
#      ($file_in_sql_usergroups eq ""))
#  {
#    $read_stored_bots = $true ;
#    &ReadStoredBots ;
#    return ;
#  }

  print "\nReadbots \ngroups: '$file_in_sql_usergroups'\nusers:  '$file_in_sql_users'\n" ;

  if ($file_in_sql_usergroups =~ /\.gz$/)
  { open "GROUPS", "-|", "gzip -dc \"$file_in_sql_usergroups\"" || abort ("Input file " . $file_in_sql_usergroups . " could not be opened.") ; }
  elsif ($file_in_sql_usergroups =~ /\.bz2$/)
  { open "GROUPS", "-|", "bzip2 -dc \"$file_in_sql_usergroups\"" || abort ("Input file " . $file_in_sql_usergroups . " could not be opened.") ; }
  elsif ($file_in_sql_usergroups =~ /\.7z$/)
  { open "GROUPS", "-|", "./7za e -so \"$file_in_sql_usergroups\"" || abort ("Input file " . $file_in_sql_usergroups . " could not be opened.") ; }
  else
  { open "GROUPS", "<", $file_in_sql_usergroups || abort ("Input file " . $file_in_sql_usergroups . " could not be opened.") ; }

  binmode "GROUPS" ;

  while ($line = <GROUPS>)
  { $line =~ s/\((\d+),'bot'\)/(@botsndx{$1}=1)/ge ; }
  close "GROUPS" ;

  # foreach $bot (sort {$a <=> $b} keys %botsndx)
  # { print "$bot\n" ; }

  if ($file_in_sql_users =~ /\.gz$/)
  { open "USERS", "-|", "gzip -dc \"$file_in_sql_users\"" || abort ("Input file " . $file_in_sql_users . " could not be opened.") ; }
  elsif ($file_in_sql_users =~ /\.bz2$/)
  { open "USERS", "-|", "bzip2 -dc \"$file_in_sql_users\"" || abort ("Input file " . $file_in_sql_users . " could not be opened.") ; }
  elsif ($file_in_sql_users =~ /\.7z$/)
  { open "USERS", "-|", "./7za e -so \"$file_in_sql_users\"" || abort ("Input file " . $file_in_sql_users . " could not be opened.") ; }
  else
  { open "USERS", "<", $file_in_sql_users || abort ("Input file " . $file_in_sql_users . " could not be opened.") ; }

  binmode "USERS" ;

  while ($line = <USERS>)
  { if ($line =~ /^LOCK TABLE/) { last ; }}
  while ($line = <USERS>)
  {
    if ($line =~ /ALTER TABLE/) { last ; }
    $line =~ s/\((\d+),'([^']*)'/&TestBot($1,$2)/ge ;
  }
  close "USERS" ;

  @bots2 = (sort {$a cmp $b} keys %bots) ;
  if ($#bots2 > -1)
  { &Log ("\nRegistered bots: " . join (', ', @bots2) . "\n") ; }
}

sub TestBot
{
  my $index = shift ;
  my $name  = shift ;
  $name =~ s/\|/&pipe;/g ;
  if (@botsndx {$index} > 0)
  { @bots {$name} = 1 ; }
}

1;
