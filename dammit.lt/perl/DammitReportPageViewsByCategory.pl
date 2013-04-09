#!/usr/bin/perl

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;
  use Getopt::Std ;

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
  our ($file_csv, $file_html) = &ParseArguments ;
  &WriteReport ($file_csv, $file_html) ;

  print "\n\nReady\n\n" ;
  exit ;

# arguments checking can be improved, is not fool proof
sub ParseArguments
{
  my %options ;
  getopt ("io", \%options) ;

  $file_csv  = $options {"i"} ;
  $file_html = $options {"o"} ;

  die "Specify -i [input file]"  if $options {"i"} eq '' ;
  die "Specify -o [output file]" if $options {"o"} eq '' ;

  die "Input file '$file_csv' not found!" if ! -e $file_csv ;

  return ($file_csv, $file_html) ;
}

sub WriteReport
{
  my ($file_csv, $file_html) = @_ ;
  my ($line, $msg_month, $msg_wiki, $msg_category, $msg_depth, $line_html, $html, $url, $rows) ;

  open FILE_CSV,  '<', $file_csv  || die "Could not open input file '$file_csv'\n" ;


  $html = "<html>\n" ;
  $html .= &ScriptHead ;
  $html .= "<body>\n" ;
  $html .= "<h3>HEADER</h3>\n" ;
  $html .= "<b>DESCRIPTION</b>&nbsp;<p>\n" ;
  $html .= "Click arrow in header to sort on that column. Shift+click to add column as secondary sort order. " ;
  $html .= "E.g. first on category, secondary on views.<br>" ;
  $html .= "On huge tables sort will take a while, please be patient." ;
  $html .= "<table border='1' id='table1' class='tablesorter'>\n" ;
  $html .= "<thead>\n" ;
  $html .= "<tr><th>Views&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th><th>Page title</th><th>Category</th></tr>\n" ;
  $html .= "</thead>\n" ;
  $html .= "<tbody>\n" ;
  while ($line = <FILE_CSV>)
  {
    if ($line =~ /^views:/) # these lines come from consolidated monthly page views file
    {
      $line =~ s/[^\#]*#\s*// ;
      $line =~ s/:/: / ;
      if ($line =~ /page request counts for /)
      {
        $line =~ s/.*?page request counts for // ;
        $msg_month = $line ;
      }
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
      { $msg_category = $line ; }
      if ($line =~ /depth/)
      { $msg_depth = $line ; }
      next ;
    }

    chomp $line ;
    my ($project_code, $title, $count, $category) = split (' ', $line) ;

    (my $title2 = $title) =~ s/_/ /g ;
    (my $category2 = $category) =~ s/_/ /g ;
    $title2    = &EncodeHtml ($title2) ;
    $category2 = &EncodeHtml ($category2) ;

    $line_html = "<tr><td class=r>$count</td>" . 
                     "<td class=l><a href='http://$url/wiki/$title'>$title2</td>" . 
		     "<td class=l><a href='http://$url/wiki/category:$category'>$category2</td></tr>\n" ;

		     $html .= $line_html ;
    $rows++ ;
  }
  $html .= "</tbody>\n" ;
  $html .= "</table>" ;
  $html .= "$rows pages found" ;
  $html .= "</body>\n" ;
  $html .= &ScriptSorterInvoke ;
  $html .= "</html>\n" ;
  close FILE_CSV ;

  $html =~ s/TITLE/Page views in $msg_category on $msg_wiki/ ;
  $html =~ s/HEADER/Page views in $msg_category on $msg_wiki/ ;
  $html =~ s/DESCRIPTION/$msg_month/ ;

  $html .= &Colophon ;

  open  FILE_HTML, '>', $file_html || die "Could not open output file '$file_html'\n" ;
  print FILE_HTML $html ;
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
my $html = <<__COLOPHON__ ;
Author Erik Zachte
  <font color=#606060>
  <small>Author:Erik Zachte (<a href='http://infodisiac.com/'><font color=#6060FF>web site</font></a>, <a href='http://infodisiac.com/blog'>blog</a>, <a href='http://twitter.com/infodisiac'>twitter</a>)<br>
  Mail:ezachte@### (no spam: ### = wikimedia.org)<br>
  For documentation, scripts and data see <a href='http://stats.wikimedia.org/index.html#fragment-14'>About page</a>.<br>
  See also  <a href='http://infodisiac.com/blog'><font color=#6060FF>Blog on Wikimedia Statistics</font></a></small>
  </font>
__COLOPHON__

return $html ;
}






