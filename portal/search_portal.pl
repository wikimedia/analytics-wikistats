#!/usr/bin/perl -w

# activate these lines (till WARN) temporarily when cgi script retturns no output
#BEGIN { $SIG{'__DIE__'} = sub { print <<__WARN__ and exit 1 } }
#Content-Type: text/html; charset=ISO-8859-1\n
#Fatal Error in @{[(caller(2))[1]||__FILE__]} at ${\ scalar localtime }
#while responding to request from ${\ $ENV{'REMOTE_ADDR'} || 'localhost
#+' }
#${\ join("\n",$!,$@,@_) }
#__WARN__

  use CGI::Carp qw(fatalsToBrowser);
  use CGI qw(:standard);
  use strict ;

  our (@search_keywords,$this_file,$cgi_bin,$output,$sections) ;

  our $true  = 1 ;
  our $false = 0 ;
  our $debug = $false ;
  our $test  = $false ;
  our $error = $true ;

  our $base  = '' ;
  our $folder = '.' ;
  our $search_keywords = 'misc' ; # local tests

  if ($test)
  {
    $cgi_bin = "http://infodisiac.com/cgi-bin" ;	  
    $folder = "../portal" ;
    $base = 'http://infodisiac.com/portal/' ;
    $search_keywords = param('search') || '';
    $this_file = "http://infodisiac.com/cgi-bin/search_portal.pl?search=$search_keywords" ;
  } # local tests
  else
  {
    $cgi_bin = "http://stats.wikimedia.org/cgi-bin" ;	  
    $folder = "../htdocs" ;
    $base = 'http://stats.wikimedia.org/' ;
    $search_keywords = param('search') || '';
    $this_file = "http://stats.wikimedia.org/cgi-bin/search_portal.pl?search=$search_keywords" ;
  }

  $output = "Content-type: text/html\n\n;" ;

# if ($search_keywords eq '')
# {
#   &PrintForm ($search_keywords, "No search criteria specified!", $error) ;
#   print $output ;
#   exit ;
# }

  $search_keywords =~ s/%20/ /g ;
  $search_keywords =~ s/[^a-zA-Z0-9 ,.]//g ;

  # remove redundant blanks
  $search_keywords =~ s/\s+/ /g ;
  $search_keywords =~ s/^\s+// ;
  $search_keywords =~ s/\s+$// ;
  @search_keywords = split ' ', $search_keywords ;

  &Search ;
  &LogResults ;

  exit ;

sub Search
{
  my ($header,$comment,$in_header,$in_footer,$no_search,$section,$lines,$line,$section_body_text,$section_match,$keyword) ;
  my ($color,$toc,$sec,$min) ;

  die "Input 'index.html' not found" if ! -e "$folder/index.html" ;

  open HTML_IN,  '<', "$folder/index.html" ;
  open HTML_OUT, '>', "$folder/index_filtered.html" ;

  $in_header = $true ;
  $in_footer = $false ;
  $no_search = $false ;
  $section   = '' ;

  while ($line = <HTML_IN>)
  {
    if ($debug)
    {
      $lines++ ;
      if ($line =~ /nosearch/)
      { print HTML_OUT "\nline: $lines: $line\n" ; }
      if ($no_search)
      { print "\n" . (0+$lines) . ": nope\n" ; }
      else
      { print "\n" . (0+$lines) . ": yep\n" ; }
    }

    if ($line =~ /nosearch start/)
    { $no_search = $true ; }
    if ($line =~ /nosearch stop/)
    { $no_search = $false ; }

    next if $no_search ;
    next if $line =~ /<div/ ;

    if ($line =~ /<\/body/)
    {
      $in_footer = $true ;
      &Print ("<hr width=500 align=left><p><b>Search ready.<br> " . (0 + $sections) . " relevant sections found for search criteria <font color=red>'$search_keywords'</font>.<\/b>\n\n") ;
    }

    if (($in_header) || ($in_footer))
    { &Print ($line) ; }
    else
    {
      ($section_body_text = $section) =~ s/<[^>]+>//g ;
       $section_body_text =~ s/\&[a-zA-Z0-9]+;//g ;

      if ($line =~ /<hr/)
      {
        if ($search_keywords eq '') 
	{ $section_match = $false ; }
	else
	{
	  $section_match = $true ;
          foreach $keyword (@search_keywords)
          {
            if ($section_body_text !~ /$keyword/i)
            {
              $section_match = $false ;
              last ;
            }
          }
        }  

        if ($section_match)
        {
          $header = $section ;
          $header =~ s/^.*?<h\d[^>]*>//s ; # skip till header
          $header =~ s/<\/h.*$//s ;        # skip after headers
          $header =~ s/<[^>]+>//gs ;       # skip html in header
          $header =~ s/\n//g ;
          $header =~ s/^\s*//g ;
          $header =~ s/\s*$//g ;

          ($header,$comment) = split '\(', $header ;
          $comment = "($comment" if $comment ne '' ;

          next if length ($header) < 5 ; # Q&D fix for empty header on keyword ',' ( = all sections )
          
	  $sections ++ ;

	  if ($comment =~ /(?:defunct|very old|obsolete|outdated)/i)
          { $color = '#C00000' ; }
          else
          { $color = '#008000' ; }

          $toc .= "\n<li><a href='$this_file#section-$sections'><b>$header<\/b> <font color=$color>$comment</font></a>\n" ;

          foreach $keyword (@search_keywords)
          { $section = &HighlightSection ($section, $keyword) ; }

          $section =~ s/(<h\d>)/$1$sections / ;
          &Print ("<a name='section-$sections' id='section-$sections'></a>\n") ;
          &Print ($section) ;
        }

        $section = '' ;
      }
      $section .= $line ;
    }

    if ($line =~ /<body/)
    {
      &PrintForm ($search_keywords)
    }

    if (($base ne '') || ($line =~ /<title/))
    {
      &Print ("<base href='$base' target='_blank'>") ;
      $base = '' ;
    } # tests only

    if ($line =~ /<body/)
    {
      $in_header = $false ;
 
      if ($search_keywords eq '')
      { &Print ("<hr><p><b><font color=red>No search keywords specified</font></b>\n") ; }
      else
      { &Print ("<hr><p><b>Sections found:</b><p><ol>TOC</ol>\n") ; }

      if ($base ne '')
      { &Print ("<p>TOC not linked on this test site (internal anchors don't work with html base statement\n") ; }
    }
  }

  # repeat form at bottom ? (needs refinement: don't repeat header)
  # if ($sections > 5)
  # { &PrintForm ($search_keywords) ; }

  $output =~ s/TOC/$toc/ ;

  print HTML_OUT $output ;
  print $output ;

  close HTML_OUT ;
  close HTML_IN ;
}

sub LogResults
{
  use Digest::MD5 qw(md5_hex);
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
  my $date_time = sprintf ("%04d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec) ;
  my $ip = $ENV{'REMOTE_ADDR'};
  my $md5_hex = md5_hex ($ip) ;
  my $country= '--' ;
  
# if (! -e "$folder/search_portal_log.txt")
# {
#   open  LOG, '>', "$folder/search_portal_log.txt" ;
#   print LOG "time,results,search,country,ip_md5\n" ;
#   close LOG ;
#   chmod 0770, "$folder/search_portal_log.txt" or die "Couldn't chmod $folder/search_portal_log.txt: $!";
# }
# open  LOG, '>>', "/a/srv/stats.wikimedia.org/htdocs/search_portal_log.txt" || die "Cannot open log file /a/srv/stats.wikimedia.org/htdocs/search_portal_log.txt" ;
  open  LOG, '>>', "search_portal_log.txt" || die "Cannot open log file" ;
  print LOG "$date_time," . ($sections+0) . ",\"$search_keywords\",$country,$md5_hex\n" ;
  close LOG ;
}

sub HighlightSection
{
  my ($section, $keyword) = @_ ;
  my @section_lines = split "\n", $section ;
  foreach my $section_line (@section_lines)
  { $section_line = &Highlight ($section_line, $keyword) ; }
  $section = join "\n", @section_lines ;
  return ($section) ;
}

sub Highlight
{
  my ($text, $keyword) = @_ ;

  if ($keyword eq '.') # . placeholder for 'all entries'
  { return $text ; }

  $text =~ s/^([^<>]+)$/&Highlight2 ($1, $keyword)/ge ;
  $text =~ s/^([^<]+)(?=<)/&Highlight2 ($1, $keyword)/ge ;
  $text =~ s/>([^<]+)$/'>' . &Highlight2 ($1, $keyword)/ge ;
  $text =~ s/>([^<>]+)(?=<)/'>' . &Highlight2 ($1, $keyword)/ge ;

  return $text ;
}

sub Highlight2
{
  my ($text, $keyword) = @_ ;

  return $text if $text =~ /^\s*$/ ;

  $text =~ s/^([^\&]+)$/&Highlight3 ($1, $keyword)/ge ;
  $text =~ s/^([^\&]+)(?=\&\w+;)/&Highlight3 ($1, $keyword)/ge ;
  $text =~ s/(\&\w+;)[^\&]+$/$1 . &Highlight3 ($2, $keyword)/ge ;

  return $text ;
}

sub Highlight3
{
  my ($text, $keyword) = @_ ;

  $text =~ s/($keyword)/<font class=highlight>$1<\/font>/gi ;

  return "$text" ;
}

sub PrintForm
{
  my ($search_keywords, $msg, $error) = @_ ;

  my $html = "<table>\n" .
             "  <tr>\n  " .
             "    <td valign=middle>&nbsp;<img src='http://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Wikimedia-logo.svg/25px-Wikimedia-logo.svg.png'></td>\n" .
             "    <td valign=middle align=left><h1>Wikimedia Statistics Search</h1></td>\n" .
             "  </tr>\n" .
             "  <tr>\n  " .
             "    <td valign=middle colspan=99>&nbsp;<font color=#080>Disclaimer: this portal also links to many external sites where the Wikimedia Foundation<br>is not involved in any way</font>        </td>" .
             "  </tr>\n" .
             "  <tr>\n" .
             "    <td valign=middle align=left colspan=99>\n" .
             "      <form name='search' action='$cgi_bin/search_portal.pl' method='get' target='_self'>\n" .
             " Search for: <input type='text' name='search' value='$search_keywords'>\n" .
             "      <input type='submit' value='Submit' size='10' maxlength='40'>\n" .
             " <a href='index.html'>Home</a>\n" .
             "    </form>\n" .
             "    </td>\n" .
             "  </tr>\n" .
             "  <tr>\n" .
             "    <td valign=middle align=left colspan=99>\n" .
             "      Example searches: <a href='$cgi_bin/search_portal.pl?search=views' target='_self'>views</a> /\n" .
             "<a href='$cgi_bin/search_portal.pl?search=edit' target='_self'>edits</a> /\n" .
             "<a href='$cgi_bin/search_portal.pl?search=revert target='_self''>reverts</a> /\n" .
             "<a href='$cgi_bin/search_portal.pl?search=editor' target='_self'>editors</a> /\n" .
             "<a href='$cgi_bin/search_portal.pl?search=bot' target='_self'>bot</a> /\n" .
             "<a href='$cgi_bin/search_portal.pl?search=visit' target='_self'>visit</a> /\n" .
             "<a href='$cgi_bin/search_portal.pl?search=chart' target='_self'>charts</a> /\n" .
             "<a href='$cgi_bin/search_portal.pl?search=diagram' target='_self'>diagrams</a> /\n" .
             "<a href='$cgi_bin/search_portal.pl?search=table' target='_self'>tables</a> /\n" .
             "<a href='$cgi_bin/search_portal.pl?search=defunct' target='_self'>defunct</a> /\n" .
             "<a href='$cgi_bin/search_portal.pl?search=.' target='_self'>all</a>\n" ;
             "<p>Please note this is a very simplistic cost-sensitive search implementation.<br>Bug reports are welcome. Feature requests may be filed for later.\n" ;

  if (! $error)
  {
    $html .= "<br><small>Diclaimer: this portal also links to many external sites where the Wikimedia Foundation is not involved in any way</small>" .
             "<p>Legend:\n" . 
	     "<img src='wmf_logo.png'>&nbsp;hosted by WMF, \n" . 
	     "<img src='toolserver_logo.png'>&nbsp;by Toolserver \n" . 
	     "<img src='wikipedia_logo.png'>&nbsp;on Wikipedia \n" . 
	     "<img src='external_logo.png'>&nbsp;external link" ;
  }

  $html .=   "    </td>\n" .
             "  </tr>\n" .
             "</table>\n\n" ;


  if ($msg ne '')
  { $html .= "<p><b><font color=red>$msg</font></b>" ; }

  &Print ($html) ;
}

sub Print
{
  my $html = shift ;
  $output .= $html ;
}

