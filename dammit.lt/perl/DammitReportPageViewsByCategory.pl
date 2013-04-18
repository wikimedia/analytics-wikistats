#!/usr/bin/perl

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Getopt::Std ;
  use URI::Escape ;

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  ez_lib_version (8) ;
  $trace_on_exit = $false ;
  
  use strict ;
  use warnings ;

  our $true  = 1 ;
  our $false = 0 ;

  our $timestart = time ;
  our $mirror = $false ; # no RTL languages support yet

  # -i "w:\! perl\dammit\dammit page requests per category\scan_categories_views_per_article.csv" -o "scan_categories_views_per_article.html"
# our ($file_csv, $file_html_in, $file_html_out, , $view_threshold, $msg_month) = &ParseArguments ;
  my ($file_csv, $file_html_out, , $view_threshold, $msg_month, $abbr, $yyyy_mm) = &ParseArguments ;
# &WriteReport ($file_csv, $file_html_in, $file_html_out, $view_threshold, $msg_month) ;
  &WriteReport ($file_csv, $file_html_out, $view_threshold, $msg_month, $abbr, $yyyy_mm) ;

  print "\n\nReady\n\n" ;
  exit ;

# arguments checking can be improved, is not fool proof
sub ParseArguments
{
  my %options ;
  getopt ("iovmha", \%options) ;

  my $file_csv       = $options {"i"} ;
# my $file_html_in   = $options {"h"} ;
  my $file_html_out  = $options {"o"} ;
  my $view_threshold = $options {"v"} ;
  my $abbr           = $options {"a"} ;
  my $yyyy_mm        = $options {"m"} ;

  die "Specify -i [input file]"            if $options {"i"} eq '' ;
  die "Specify -o [output file]"           if $options {"o"} eq '' ;
# die "Specify -h [categeories html file]" if $options {"h"} eq '' ;
  if (! defined $view_threshold) 
  {
    $view_threshold = 20 ;
    print "View threshold not specified, use default 20\n" ;    
  }
  die "Specify -v [numeric]" if $view_threshold !~ /^\d+$/ ;
  die "Specify -m [yyyy-mm]" if $yyyy_mm        !~ /^\d\d\d\d-\d\d$/ ;

  die "Input file '$file_csv' not found!" if ! -e $file_csv ;
# die "Categories html file '$file_html_in' not found!" if ! -e $file_html_in ;

  $msg_month = "year " . substr ($yyyy_mm,0,4) . " month " . substr ($yyyy_mm,5,2) ;
# return ($file_csv, $file_html_in, $file_html_out, $view_threshold, $msg_month) ;
  return ($file_csv, $file_html_out, $view_threshold, $msg_month, $abbr, $yyyy_mm) ;
}

sub WriteReport
{
# my ($file_csv, $file_html_in, $file_html_out, $view_threshold, $msg_month) = @_ ;
  my ($file_csv, $file_html_out, $view_threshold, $msg_month, $abbr, $yyyy_mm) = @_ ;
  my ($line, $msg_wiki, $msg_category, $msg_depth, $line_html, $html, $html2, $url, $rows, $rows2, %row, $category, $category2, $chars) ;
  my ($yyyy, $mm, $yyyy_mm_prev, $yyyy_mm_next, $file_html_out_no_path, $file_html_out_older, $file_html_out_newer, $file_html_out_longer) ; 
  my $file_html_categories = $file_html_out ;
  
  open FILE_CSV,  '<', $file_csv  || die "Could not open input file '$file_csv'\n" ;


  $html = "<html>\n" ;
  $html .= &ScriptHead ;
  $html .= "<body>\n" ;
  $html .= "<h3>HEADER</h3>\n" ;
  $html .= "<b>DESCRIPTION</b>&nbsp;<p>\n" ;
  $html .= "<b>Some top ranking titles in this list may seem out of place.</b><br>" ;
# $html .= "The assigned ategory which makes an article appear in this list may not explain why that article is viewed so often.</b><br>" ;
# $html .= "<b>In some occasions a listed entry may be totally irrelevant to the topcategory on which this list is based</b><br>" .
#          " (a list of pages about politicians may feature a page about a music album, just because a famous musician happened to be also a minor politician).<p>" ;
  $html .= "Please note that any Wikipedia article can have tens of categories assigned to it.<br>" .
           "A popular article will rank high in any list where it's featured, regardless of the category under review.<br>" . 
	   "Thus a well-known singer may be top ranking in a list about politicians, because he/she also played a minor or brief role in politics.<p>" ;
  $html .= "Click arrow in header to sort on that column. Shift+click to add column as secondary sort order. " ;
  $html .= "E.g. first on category, secondary on views.<br>" ;
  $html .= "On huge tables sort will take a while, please be patient.<p>" ;

  $file_html_categories =~ s/pageviews/categories/ ;
  $file_html_categories =~ s/^.*\/// ; # remove path
  $html .= "<a href='$file_html_categories'>Categories included</a> / Other reports: " ;
  
  $html .= "<a href='../..'>start</a> / " ;
  $html .= "<a href='..'>$abbr</a> / " ;
  $html .= "<a href='.'>$yyyy_mm</a> / " ;

  $yyyy = substr ($yyyy_mm,0,4) ;
  $mm   = substr ($yyyy_mm,5,2) ;
  if ($mm > 0)  { $mm -- ; } else { $mm = 12 ; $yyyy-- ; }
  $yyyy_mm_prev = sprintf ("%4d-%02d",$yyyy,$mm) ;
  if ($mm < 12) { $mm ++ ; } else { $mm =  1 ; $yyyy++ ; }
  if ($mm < 12) { $mm ++ ; } else { $mm =  1 ; $yyyy++ ; }
  $yyyy_mm_next = sprintf ("%4d-%02d",$yyyy,$mm) ;

  $html .= "Other version: " ;

  $file_html_out_no_path = $file_html_out ;
  $file_html_out_no_path =~ s/^.*\//.\// ;
  ($file_html_out_older  = $file_html_out_no_path) =~ s/$yyyy_mm/$yyyy_mm_prev/g ;
  ($file_html_out_longer = $file_html_out_no_path) =~ s/\.html/_huge\.html/ ;

  if ($yyyy_mm gt '2013-01')
  { $html .= "<a href='../$yyyy_mm_prev/$file_html_out_older'>older</a> / " ; }
  ($file_html_out_newer = $file_html_out_no_path) =~ s/$yyyy_mm/$yyyy_mm_next/g ;
  $html .= "<a href='../$yyyy_mm_next/$file_html_out_newer'>newer</a> <font color=#A0A0A0>(published after month is complete)</font> " ; 
  $html .= "##LONG##" ; 
  
  $html .= "<table border='1' id='table1' class='tablesorter'>\n" ;
  $html .= "<thead>\n" ;
  $html .= "<tr><th>Views&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th><th>Page title</th><th>Category&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th></tr>\n" ;
  $html .= "</thead>\n" ;
  $html .= "<tbody>\n" ;
  while ($line = <FILE_CSV>)
  {
    if ($line =~ /^views:/) # these lines come from consolidated monthly page views file
    {
      $line =~ s/[^\#]*#\s*// ;
      $line =~ s/:/: / ;
      #if ($line =~ /page request counts for /)
      #{
      #  $line =~ s/.*?page request counts for // ;
      #  $msg_month = $line ;
      #}
      next ;
    }
    if ($line =~ /^titles:/) # these lines come from file with page titles produced by DammitScanCategories.pl
    {
      $line =~ s/[^\#]*#\s*// ;
      $line =~ s/:/: / ;
      if ($line =~ /wiki/)
      {
        $line =~ s/wiki:\s*// ;
        $msg_wiki = $line ;
        ($url = $msg_wiki) =~ s/.*?(\w+\.\w+\.\w+).*$/$1/ ;
      }
      if ($line =~ /category/)
      { 
        $msg_category = $line ; 
	$msg_category =~ s/category:\s*// ;
      }
      if ($line =~ /depth/)
      { $msg_depth = $line ; }
      next ;
    }

    chomp $line ;
    my ($project_code, $title, $count, $categories) = split (' ', $line, 4) ;

    next if $count < $view_threshold ;

    $title = uri_unescape ($title) ;
    (my $title2 = $title) =~ s/_/ /g ;
    $title = uri_escape ($title) ;
    if (length ($title2) > 60)
    { $title2 = substr ($title2,0,60) . '..' ; }
    $title2    = &EncodeHtml ($title2) ;

    my @categories = split ('\|', $categories) ;
    $categories = '' ;
    $chars = 0 ;
    foreach $category (@categories)
    {
      $category =~ s/^\s*// ;
      $category =~ s/\s*$// ;
      $category2 = $category ;
      $category2 =~ s/_/ /g ;
      $category2 = &EncodeHtml ($category2) ;
      $category2 =~ s/\%2C/,/g ;

      $chars += length ($category) ;
      if ($chars > 100)
      { 
	$categories .= "<br>" ; 
        $chars = length ($category) ;
      }
      $categories .= "<a href='http://$url/wiki/category:$category'>$category2</a>, " ;      
    } 
    $categories =~ s/, $// ;

    $line_html = "<tr><td class=r valign=top>$count</td>\n" . 
                     "<td class=l valign=top><a href='http://$url/wiki/$title'>$title2</a></td>\n" . 
		     "<td class=l>$categories</td></tr>\n" ;
    $row {$line_html} = $count ;
  }

  my $key ;
  $rows = 0 ;
  for $key (sort {$row {$b} <=> $row {$a}} keys %row)
  { 
    $rows++ ;	  
    if ($rows <= 10000)
    { $html .= $key ; }
    if ($rows == 2500)
    { $html .= "##2500##" ; }
  }
  $html .= "##999999##" ;
  
  $html .= "</tbody>\n" ;
  $html .= "</table>" ;
  $html .= "##PAGES##<p>" ;
  $html .= "Views are number of times the article has been requested in the given month.<br>" ;
  $html .= "This includes a small amount (+/-10?) requests by search engines (crawlers).<br>" ;
  $html .= "Articles with less than $view_threshold requests have been omitted.<p>" ;
 
# $html .= "<a name=categories id=categories></a><small>" ;
#  open HTML_IN, '<', $file_html_in ;
#  while ($line = <HTML_IN>)
#  { $html .= $line ; }   
#  $html .= "</small><p>" ;

  $html .= &Colophon ;

  $html .= "</body>\n" ;
  $html .= &ScriptSorterInvoke ;
  $html .= "</html>\n" ;
  close FILE_CSV ;

  $html =~ s/TITLE/Page views in category $msg_category on $msg_wiki/ ;
  $html =~ s/HEADER/Page views in category <font color=#080>$msg_category<\/font> on <font color=#080>$msg_wiki<\/font>/ ;
  $html =~ s/DESCRIPTION/$msg_month/ ;

  $file_html_out = uri_escape ($file_html_out) ;
  $file_html_out =~ s/\%2D/-/g ;
  $file_html_out =~ s/\%5F/_/g ;
  $file_html_out =~ s/\%2F/\//g ;
  
  $html2 = $html ;

  if ($rows > 3500) # except slighly 'concise' file if ful list is less than 1000 lines more than concise list
  {
    $html2 =~ s/\#\#2500\#\#.*\#\#999999\#\#//s ;
    $html2 =~ s/##999999##// ; # if ##2500## not found
    $html2 =~ s/##PAGES##/$rows pages found, showing top 2500/ ;
    if ($rows <= 10000)
    { $html2 =~ s/##LONG##/\/ <a href='$file_html_out_longer'>all $rows pages<\/a><p>/ ; }
    else
    { $html2 =~ s/##LONG##/\/ <a href='$file_html_out_longer'>top 10,000 pages<\/a><p>/ ; }
  }
  else
  {
    $html2 =~ s/##2500##// ;
    $html2 =~ s/##999999##// ;
    $html2 =~ s/##PAGES##/$rows pages found/ ;
    $html2 =~ s/##LONG##// ; 
  }
  
  # write concise list (or full list if less than 3500)
  print "Write html file $file_html_out\n" ;
  open  FILE_HTML, '>', $file_html_out || die "Could not open output file '$file_html_out'\n" ;
  print FILE_HTML $html2 ;
  close FILE_HTML ;

  # write full list
  if ($rows > 3500)
  {
    $html =~ s/##2500##// ;
    $html =~ s/##999999##// ;
    ($rows2 = $rows) =~ s/(\d\d\d)$/,$1/ ;
    if ($rows <= 10000)
    { $html =~ s/##PAGES##/$rows2 pages found/ ; }
    else
    { $html =~ s/##PAGES##/$rows2 pages found, showing top 10,000/ ; }
    $html =~ s/##LONG##/\/ <a href='$file_html_out'>top 2500 pages<\/a><p>/ ; 

    $file_html_out =~ s/\.html/_huge.html/ ;
    print "Write html file $file_html_out\n" ;
    open  FILE_HTML, '>', $file_html_out || die "Could not open output file '$file_html_out'\n" ;
    print FILE_HTML $html ;
    close FILE_HTML ;
  }  

# print FILE_HTML &AlignPerLanguage ($html) ; # to do: support RTL languages, 

  close FILE_HTML ;
}

sub AlignPerLanguage
{
  my $html = shift ;
  if ($mirror)
  {
  # $html =~ s/(<body[^\>]*>)/$1<div dir=rtl align=right>/ ;
  # $html =~ s/(<\/body>)/<\/div>$1/ ;
    $html =~ s/(<html[^>]*)>/$1 dir=rtl>/gi ;
    $html =~ s/class=l/class=x/g ;
    $html =~ s/class=r/class=l/g ;
    $html =~ s/class=x/class=r/g ;
    $html =~ s/class='l'/class='x'/g ;
    $html =~ s/class='r'/class='l'/g ;
    $html =~ s/class='x'/class='r'/g ;
    $html =~ s/align='left'/align=x/g ;
    $html =~ s/align='right'/align='left'/g ;
    $html =~ s/align=x/align='right'/g ;
  }
  return ($html) ;
}


sub EncodeHtml
{
  my $text = shift ;
  $text = convert_unicode ($text) ;
  $text =~ s/([\<\>\'\"])/"\&\#" . ord($1) . "\;"/ge ;
  $text =~ s/\n/<br>/g ;
  return ($text) ;
}

sub ScriptHead
{
my $script = <<__SCRIPT_HEAD__ ;

<head>
<meta http-equiv="Content-type" content="text/html; charset=iso-8859-1">
<meta name="robots" content="noindex,nofollow">
<title>TITLE</title>
SORTER

<style type="text/css">
<!--
body    {font-family:arial,sans-serif; font-size:12px }
input   {font-family:arial,sans-serif; font-size:12px }
h3      {margin:0px 0px 1px 0px; font-size:15px}
hr,form {margin-top:1px;margin-bottom:2px}
hr.b    {margin-top:1px;margin-bottom:4px}

table td    {border: inset 1px #FFFFFF}
td   {white-space:nowrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px}
td.c {text-align:center }
td.l {text-align:left;}

a:link { color:blue;text-decoration:none;  }
a:visited {color:#0000FF;text-decoration:none; }
a:active  {color:#0000FF;text-decoration:none;  }
a:hover   {color:#FF00FF;text-decoration:underline}
-->
</style>

</head>

__SCRIPT_HEAD__

$script =~ s/SORTER/&ScriptSorter/e ;

return $script ;
}

sub ScriptSorter
{
my $script = <<__SCRIPT_SORTER__ ;

<script src='http://stats.wikimedia.org/jquery-1.3.2.min.js'   type='text/javascript'></script>
<script src='http://stats.wikimedia.org/jquery.tablesorter.js' type='text/javascript'></script>

<script type="text/javascript">
\$.tablesorter.addParser({
  id: "nohtml",
  is: function(s) { return false; },
  format: function(s) { return s.replace(/<.*?>/g,"").replace(/\&nbsp\;/g,""); },
  type: "text"
});
</script>

<style type="text/css">
<!--
table.tablesorter
{
  font-family:arial;
  background-color: #eee ;
  margin:10px 0pt 15px;
  font-size: 9pt;
//width: 20%;
  text-align: left;
}
table.tablesorter thead tr th, table.tablesorter tfoot tr th
{

  background-color: #99d;
  border: 1px solid #fff;
  font-size: 9pt;
  padding: 4px;

}
table.tablesorter thead tr .header
{
  background-color: #ccc;
  background-image: url(http://stats.wikimedia.org/bg.gif);
  background-repeat: no-repeat;
  background-position: center right;
  cursor: pointer;
}
table.tablesorter tbody th
{
  color: #AAA;
  padding: 4px;
  background-color: #EEE;
  vertical-align: top;
}
table.tablesorter tbody tr.odd th
{
  background-color:#eee;
  background-image:url(http://stats.wikimedia.org/asc.gif);
}
table.tablesorter thead tr .headerSortUp
{
  background-color:#ffd;
  background-image:url(http://stats.wikimedia.org/asc.gif);
}
table.tablesorter thead tr .headerSortDown
{
  background-color:#ffd;
  background-image:url(http://stats.wikimedia.org/desc.gif);
}
table.tablesorter thead tr .headerSortdown, table.tablesorter thead tr .headerSortUp
{
  background-color: #ffd;
}
-->
</style>
__SCRIPT_SORTER__

return $script ;
}

sub ScriptSorterInvoke
{
my $script = <<__SCRIPT_SORTER_INVOKE__ ;
<script type='text/javascript'>
\$('#table1').tablesorter({
  // debug:true,
  headers:{0:{sorter:'true'},1:{sorter:'nohtml'},2:{sorter:'nohtml'}}
});
</script>
__SCRIPT_SORTER_INVOKE__

return $script ;
}

sub Colophon
{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
  my $now = sprintf ("%02d-%02d-%04d %02d:%02d\n",$mday,$mon+1,$year+1900,$hour,$min) ;

my $html = <<__COLOPHON__ ;
<font color=#606060>
<small>Author:Erik Zachte (<a href='http://infodisiac.com/'><font color=#6060FF>web site</font></a>, <a href='http://twitter.com/infodisiac'>twitter</a>)<br>
Mail:ezachte@### (no spam: ### = wikimedia.org)<br>
Script used: <a href='https://github.com/wikimedia/analytics-wikistats/tree/master/dammit.lt'>dammit_list_views_by_category.sh</a><br>
Data used: <a href='http://dumps.wikimedia.org/other/pagecounts-ez/merged/'>monthly page view archive</a><br>
See also  <a href='http://infodisiac.com/blog'><font color=#6060FF>Blog on Wikimedia Statistics</font></a> and <a href='http://stats.wikimedia.org'>Wikistats portal</a><p>
Page generated: $now GMT (server time) (dd-mm-yyyy)
</font>
</small>
__COLOPHON__

return $html ;
}






