#!/usr/bin/perl

sub SetScriptTrackerCode
{
#disabled on request, retaining the variable (and code, as example) for other sites or more acceptable page tracker in the future
#$out_tracker_code = <<__TRACKER_CODE__ ;
#<script type="text/javascript">

#  var _gaq = _gaq || [];
#  _gaq.push(['_setAccount', 'UA-25704186-1']);
#  _gaq.push(['_trackPageview']);

#  (function() {
#    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
#    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
#    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
#  })();

#</script>
#__TRACKER_CODE__
}

sub SetScriptImageFormat
{
  my $format = shift ;

  $out_script_embedded_imageformat = <<__SCRIPT_EMBEDDED2__ ;

<script>
<!--
  setCookie (\"ImageFormat\", \"$format\");
//-->
<\/script>

__SCRIPT_EMBEDDED2__

}

$out_script_expand = <<__SCRIPT_EXPAND__ ;
<script>
var base  = 'http://WP.wikibooks.org/wiki/' ;
var base2 = '' ;
var book2 = '' ;
function h  (header) { base2 = header ; document.write ("<br><b>" + header + "</b> ") ; }
function hl (header) { base2 = header ; document.write ("<br><a href='" + base + encodeURI(header) + "'><b>" + header + "</b></a> ") ; }
function hr ()       { base2 = '' ; document.write ("<p>"); }
function b2 (book)
{ book2 = book + '/' ; }
function b (href, book, parts, edits, size, words)
{
  html = "<hr>" + href + "\\n<p><h4>" + book + "</h4>\\n" +
         parts + " chapters, " + edits + " edits, " + size + " bytes, " + words + " words\\n<p>" ;
  document.write (html) ;
}
function bl (href, book, parts, edits, size, words)
{
  html = "<hr>" + href + "\\n<p><h4><a href='" + base + encodeURI(book) + "'>" + book + "</a></h4>\\n" +
         parts + " chapters, " + edits + " edits, " + size + " bytes, " + words + " words\\n<p>" ;
  document.write (html) ;
}
function c (chapters)
{
  var html = '' ;

  var list = chapters.split('\|');
  for (var i = 0 ; i < list.length ; i++)
  {
    var chapter = list [i] ;
    var list2 = chapter.split('`');
    var url = base + list2 [0] ;
    url.replace ('^0^', book2) ;
    url.replace ('^1^', base2) ;
    url.replace ('^2^', list2 [1]) ;
    html += "<a href='" + encodeURI(url) + "'>" + list2 [1] + "</a>" ;
    if (i < list.length - 1)
    { html += ' / ' ; }
  }
  document.write (html) ;
}
</script>
__SCRIPT_EXPAND__



$out_script_sorter = <<__SCRIPT_SORTER__ ;
<script src=\"../jquery-1.3.2.min.js\" type=\"text/javascript\"></script>
<script src=\"../jquery.tablesorter.js\" type=\"text/javascript\"></script>

<script type="text/javascript">
\$.tablesorter.addParser({
  id: "nohtml",
  is: function(s) { return false; },
  format: function(s) { return s.replace(/<.*?>/g,"").replace(/\&nbsp\;/g,""); },
  type: "text"
});

\$.tablesorter.addParser({
  id: "millions",
  is: function(s) { return false; },
  format: function(s) { return \$.tablesorter.formatFloat(s.replace(/<[^>]*>/g,"").replace(/\&nbsp\;/g,"").replace(/M/,"000000").replace(/\&\#1052;/,"000000").replace(/k/i,"000").replace(/\&\#1050;/i,"000").replace(/(\\d)\\.(\\d)0/,"\$1\$2")); },
  type: "numeric"
});


\$.tablesorter.addParser({
  id: "digitsonly",
  is: function(s) { return false; },
  format: function(s) { return \$.tablesorter.formatFloat(s.replace(/<.*?>/g,"").replace(/\&nbsp\;/g,"").replace(/,/g,"").replace(/-/,"-1")); },
  type: "numeric"
});

function getParameterByName( name ){
  name = name.replace(/[\\[]/,"\\\\\\[").replace(/[\\]]/,"\\\\\\]");
  var regexS = "[\\\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    return "";
  else
    return decodeURIComponent(results[1].replace(/\\+/g, " "));
}
</script>

<style type="text/css">
<!--
table.tablesorter
{
/*
  font-family:arial;
  background-color: #CDCDCD;
  margin:10px 0pt 15px;
  font-size: 7pt;
  width: 80%;
  text-align: left;
*/
}
table.tablesorter thead tr th, table.tablesorter tfoot tr th
{
/*
  background-color: #99D;
  border: 1px solid #FFF;
  font-size: 8pt;
  padding: 4px;
*/
}
table.tablesorter thead tr .header
{
  background-color: #ffffdd;
  background-image: url(../bg.gif);
  background-repeat: no-repeat;
  background-position: center right;
  cursor: pointer;
}
table.tablesorter tbody th
{
/*
  color: #3D3D3D;
  padding: 4px;
  background-color: #CCF;
  vertical-align: top;
*/
}
table.tablesorter tbody tr.odd th
{
  background-color:#eeeeaa;
  background-image:url(../asc.gif);
}
table.tablesorter thead tr .headerSortUp
{
  background-color:#eeeeaa;
  background-image:url(../asc.gif);
}
table.tablesorter thead tr .headerSortDown
{
  background-color:#eeeeaa;
  background-image:url(../desc.gif);
}
table.tablesorter thead tr .headerSorthown, table.tablesorter thead tr .headerSortUp
{
  background-color: #eeeeaa;
}
-->
</style>
__SCRIPT_SORTER__


$out_script_sorter_invoke = <<__SCRIPT_SORTER_INVOKE__ ;
<script type='text/javascript'>
var sortcol = getParameterByName('sortcol');
var regexp = /d/i ;
var ascdesc='0';
if (regexp.exec (sortcol))
{ ascdesc='1'; } 
sortcol=sortcol.replace(/\\D/g,'') ;

\$('#table2').tablesorter({
  // debug:true,
  headers:{0:{sorter:false},1:{sorter:false},2:{sorter:false},3:{sorter:false},4:{sorter:'nohtml'},5:{sorter:'nohtml'},6:{sorter:'nohtml'},7:{sorter:false},8:{sorter:'millions'},9:{sorter:'digitsonly'},10:{sorter:'digitsonly'},11:{sorter:'digitsonly'},12:{sorter:'digitsonly'},13:{sorter:'digitsonly'},14:{sorter:'digitsonly'},15:{sorter:'digitsonly'},16:{sorter:'digitsonly'},17:{sorter:'digitsonly'},18:{sorter:'digitsonly'}},
  sortList: [[sortcol,ascdesc]]
});
</script>
__SCRIPT_SORTER_INVOKE__

$out_script_sorter_invoke_edits = <<__SCRIPT_SORTER_INVOKE_EDITS__ ;
<script type='text/javascript'>
\$('#table2').tablesorter({
  // debug:true,
  headers:{0:{sorter:'nohtml'},1:{sorter:'nohtml'},2:{sorter:'millions'},3:{sorter:'millions'},4:{sorter:'digitsonly'},5:{sorter:'millions'},6:{sorter:'digitsonly'},7:{sorter:'millions'},8:{sorter:'digitsonly'},9:{sorter:false},10:{sorter:'millions'},11:{sorter:'millions'},12:{sorter:'digitsonly'},13:{sorter:'millions'},14:{sorter:'digitsonly'},15:{sorter:'millions'},16:{sorter:'digitsonly'},17:{sorter:false}}
});
</script>
__SCRIPT_SORTER_INVOKE_EDITS__


#------------------------------------------------------------------------

$out_script_expand2 = <<__SCRIPT_EXPAND2__ ;
<script>
function e(p1,p2,p3,p4,p5,p6)
{
  if (! p5) { p5 = p6 ; }
  html = "<br>"+p1+" - "+p2+"%, "+p3+" - "+p4+", <a href='"+p5+"'>"+p6+"</a>" ;
  document.write (html) ;
}
</script>
__SCRIPT_EXPAND2__

#------------------------------------------------------------------------

$out_script_embedded = <<__SCRIPT_EMBEDDED__ ;

<script>
<!--
initTableSize() ;
//-->
<\/script>

__SCRIPT_EMBEDDED__

#------------------------------------------------------------------------

$out_script_hide = <<__SCRIPT_HIDE__ ;
<script>
function hide(id)
{
  if (document.layers)  // Netscape 4 stuff
  { var v = document.layers [id]; }
  else
  if (document.getElementById) // IE 5, Netscape 6, Chrome
  { var v = document.getElementById (id); }
  else
  if (document.all) // IE 4 ??
  { var v = document.all (id); }
  else
  { return ; }

  if (v.style) // IE4 ??, IE5, Netscape 6, Chrome
  {
    v.style.visibility = "hidden";
    v.style.display = "none" ;
  }
  else // Netscape 4
  { v.visibility = "hide"; }
}
</script>

__SCRIPT_HIDE__

#------------------------------------------------------------------------

$out_color_buttons = <<__COLOR__ ;
<b>Show</b>
<input type="button" value=" % " onclick = "switchShowPercentages('')">
<input type="button" value=" C " onclick = "switchShowCellColors('')">
__COLOR__

#------------------------------------------------------------------------

$out_color_button = <<__COLOR__ ;
<b>Show</b>
<input type="button" value=" C " onclick = "switchShowCellColors('')">
__COLOR__

#------------------------------------------------------------------------

$out_zoom_buttons = <<__ZOOM__ ;

<b>Zoom</b>
<input type="button" value=" - " onclick = "switchFontSize('-')">
<input type="button" value=" + " onclick = "switchFontSize('+')">

__ZOOM__

#------------------------------------------------------------------------

$out_form = <<__FORM__ ;

<form name = "form" action='url'>
ZOOM
HOME
BUTTON_SWITCH&nbsp;&nbsp;
<select name = "page" onchange="switchPage()">
OPTIONS
</select>
BUTTON_PREVIOUS
BUTTON_NEXT
</form>

__FORM__

#------------------------------------------------------------------------

$out_page_header = <<__PAGE_HEADER__ ;

<table width='100%' border='0' cellpadding='0' cellspacing='0' summary='Page header' >
<tr bgcolor='#FFFFDD'>
<td class=l><a id='top' name='top'></a><h2>PAGE_TITLE</h2></td>
<td class=r>
FORM
CROSSREF
</td></tr>
<tr><td class=l><b>PAGE_SUBTITLE</b></td>
<td valign='top' class=r>EXPLANATION</td></tr>
</table>

__PAGE_HEADER__

$out_style = <<__STYLE__ ;

<style type="text/css">
<!--
body    {font-family:arial,sans-serif; font-size:12px }
input   {font-family:arial,sans-serif; font-size:12px }
h2      {margin:0px 0px 3px 0px; font-size:18px}
h3      {margin:0px 0px 1px 0px; font-size:15px}
h4      {margin:0px 0px 9px 0px; font-size:14px}
hr,form {margin-top:1px;margin-bottom:2px}
hr.b    {margin-top:1px;margin-bottom:4px}

td   {white-space:nowrap; text-align:right; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px}
td.c {text-align:center }
td.o {vertical-align:text-bottom}
td.l {text-align:left;}
td.lwrap {white-space:normal; text-align:left; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px}

td.cb    {text-align:center; border: inset 1px #FFFFFF}
td.cbo   {text-align:center; border: inset 1px #FFFFFF ; vertical-align:text-bottom}
td.cbg   {text-align:center; border: inset 1px #FFFFFF ; color:#808080; }
td.lb    {text-align:left;   border: inset 1px #FFFFFF}
td.rb    {text-align:right;  border: inset 1px #FFFFFF}
td.rbg   {text-align:right;  border: inset 1px #FFFFFF ; color:#808080; }
td.sigma {color:#400040;     border: inset 1px #FFFFFF}
td.img   {padding:0px ; margin:0px ; border: inset 1px #FFFFFF}


table.b td    {text-align:right;  border: inset 1px #FFFFFF}
table.b th    {text-align:center; border: none}
table.b th.l  {text-align:left;   border: none ; vertical-align:top;}
table.b td.l  {text-align:left;   border: none ; vertical-align:top;}
table.b th.c  {text-align:center; border: none ; vertical-align:top;}
table.b th.r  {text-align:right;  border: none ; vertical-align:top;}
table.b td.cb {text-align:center; border: inset 1px #FFFFFF}

tr.c td    {text-align:center}

th.cnb {text-align:center; border:none ; padding:2px 0px 2px 0px ; vertical-align:top;}
th.lnb {text-align:left;   border:none ; padding:2px 0px 2px 0px ; vertical-align:top;}
th.rnb {text-align:right;  border:none ; padding:2px 0px 2px 0px ; vertical-align:top;}

th.cb  {text-align:center; padding:2px 0px 2px 0px ; vertical-align:top; border: inset 1px #FFFFFF}
th.lb  {text-align:left;   padding:2px 0px 2px 0px ; vertical-align:top; border: inset 1px #FFFFFF}
th.rb  {text-align:right;  padding:2px 0px 2px 0px ; vertical-align:top; border: inset 1px #FFFFFF}

.chart {font-size: 8px; text-align:center; color: #000000; font-family: arial,sans-serif; padding:0px; border: 1px }
.chart_scale {font-size: 8px; text-align:right; color: #000000; font-family: arial,sans-serif; padding: 0px;}
.xsmall {font-size: 8px; color: #FF00FF; font-family: arial,sans-serif;}
xsmall {font-size: 10px; color: #000000; font-family: arial,sans-serif;}

a:link { color:blue;text-decoration:none;  }
a:visited {color:#0000FF;text-decoration:none; }
a:active  {color:#0000FF;text-decoration:none;  }
a:hover   {color:#FF00FF;text-decoration:underline}

ul {border-left:0em ; margin-left:2em ; padding-left:0em}
li {list-style-type:none}

img {border:0 ; margin:0px; padding:0px}
img.border { border:1px solid black }

thin {border:none;margin:0px}

img {border:0}

.d1 { font-size:9px;float:left;width:1%}
.d2 { font-size:12px;font-weight:bold;float:right;width:100%}

.ch1  { color:#BBBB66; font-size:12px; font-weight:normal }
.ch2  { color:#5555AA; font-size:12px; font-weight:normal }
.ch3  { color:#0000FF; font-size:12px; font-weight:bold }
.ch1a { color:#BBBB66; font-size:12px; font-weight:normal ; padding-left:3px ; padding-right:3px }
.ch2a { color:#5555AA; font-size:12px; font-weight:normal ; padding-left:3px ; padding-right:3px }
.ch3a { color:#0000FF; font-size:12px; font-weight:bold ;   padding-left:3px ; padding-right:3px }
.ch1b { color:#BBBB66; font-size:9px;  font-weight:normal ; padding-left:3px ; padding-right:3px }
.ch2b { color:#5555AA; font-size:11px; font-weight:normal ; padding-left:3px ; padding-right:3px }
.ch3b { color:#0000FF; font-size:13px; font-weight:normal ; padding-left:3px ; padding-right:3px }
.ch1c { color:#000044; font-size:9px;  font-weight:normal ; padding-left:2px ; padding-right:2px }
.ch2c { color:#0000AA; font-size:11px; font-weight:bolder ; padding-left:4px ; padding-right:4px }
.ch3c { color:#0000FF; font-size:13px; font-weight:bold   ; padding-left:6px ; padding-right:6px }
-->
</style>

__STYLE__
# .d1 { font-size:9px;visibility:hidde;float:left;width:1%}
# .d2 { font-size:12px;float:right;width:100%}
# .d3 { font-size:12px;background-color:#00FF00}

#------------------------------------------------------------------------

$out_counter = <<__COUNTER__ ;


<!-- PAGE COUNTER -->
<a target='_top' href='http://w.extreme-dm.com/?login=siroops3'>
<img src='http://w1.extreme-dm.com/i.gif' height=1
border=0 width=1 alt=''></a>
<script language='javascript1.2'>
<!--
EXs=screen;EXw=EXs.width;navigator.appName!='Netscape'?
EXb=EXs.colorDepth:EXb=EXs.pixelDepth;
//-->
</script>
<script language='javascript'>
<!--
EXd=document;
EXw?'':EXw='na';
EXb?'':EXb='na';
EXd.write("<img src='http://w0.extreme-dm.com','/0.gif?tag=siroops3&j=y&srw='+EXw+'&srb='+EXb+'&l='+escape(EXd.referrer)+'\\' height=1 width=1 alt=''>");
//-->
</script>
<noscript>
<img height=1 width=1 alt='' src='http://w0.extreme-dm.com/0.gif?tag=siroops3&j=n' alt=''>
</noscript>

__COUNTER__

sub ReadHtmlTrendsAllProjects
{
  my $html = <<__SCRIPT_TRENDS_ALL_PROJECTS__ ;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<head>
<meta name="language" content="en,English">
<meta name="robots" content="index,follow">

<meta http-equiv="Content-type" content="text/html; charset=iso-8859-1">

<title>Wikimedia Active Wikis</title>

<style>
body   {font-family:arial,sans-serif; font-size:12px; background-color:#333; color:#FFF;}
canvas {border:2px solid #333;}
a:link    { color:#AAAAFF;text-decoration:none; }
a:visited {color:#AAAAFF;text-decoration:none; }
a:active  {color:#AAAAFF;text-decoration:none; }
a:hover   {color:#AAAAFF;text-decoration:underline; }
</style>

</head>
<body>

<table border=0 align=center>
<tr>
<td><h1>HEADER</h1></td>
<td align=right><img src='http://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Wikimedia-logo.svg/25px-Wikimedia-logo.svg.png'></td>
</tr>
<tr>
<td colspan=99><font color=#AAA>View similar overview for metric</font> 
<a href='ProjectTrendsActiveWikis.html'>Active wikis</a>, 
<a href='ProjectTrendsEditors.html'>Total editors</a>, 
<a href='ProjectTrendsTotalEdits.html'>Total edits</a>,
<a href='ProjectTrendsPageviews.html'>Pageviews</a>, 
<a href='ProjectTrendsTotalArticles.html'>Total articles</a>, 
<a href='ProjectTrendsNewArticles.html'>New articles</a> 
</tr>
<tr>
<td align=left colspan=99>
COMMENTS_TOP
</td>
</tr>
<tr>
<td><img src='http://stats.wikimedia.org/EN/PNG'><br><a href='http://stats.wikimedia.org/EN/SummaryZZ.htm'>View all trend charts for Wikipedia project</a></td>
<td><img src='http://stats.wikimedia.org/wikibooks/EN/PNG'><br><a href='http://stats.wikimedia.org/wikibooks/EN/SummaryZZ.htm'>View all trend charts for Wikibooks project</a></td>
</tr>
<tr>
<td><img src='http://stats.wikimedia.org/wikinews/EN/PNG'><br><a href='http://stats.wikimedia.org/wikinews/EN/SummaryZZ.htm'>View all trend charts for Wikinews project</a></td>
<td><img src='http://stats.wikimedia.org/wiktionary/EN/PNG'><br><a href='http://stats.wikimedia.org/wiktionary/EN/SummaryZZ.htm'>View all trend charts for Wiktionary project</a></td>
</tr>
<tr>
<td><img src='http://stats.wikimedia.org/wikiquote/EN/PNG'><br><a href='http://stats.wikimedia.org/wikiquote/EN/SummaryZZ.htm'>View all trend charts for Wikiquotes project</a></td>
<td><img src='http://stats.wikimedia.org/wikisource/EN/PNG'><br><a href='http://stats.wikimedia.org/wikisource/EN/SummaryZZ.htm'>View all trend charts for Wikisource project</a></td>
</tr>
<tr>
<td><img src='http://stats.wikimedia.org/wikivoyage/EN/PNG'><br><a href='http://stats.wikimedia.org/wikivoyage/EN/SummaryZZ.htm'>View all trend charts for Wikivoyage project</a></td>
<td><img src='http://stats.wikimedia.org/wikiversity/EN/PNG'><br><a href='http://stats.wikimedia.org/wikiversity/EN/SummaryZZ.htm'>View all trend charts for Wikiversity project</a></td>
</tr>
<tr>
<td><img src='http://stats.wikimedia.org/wikispecial/EN/PNGCOMMONS'><br><a href='http://stats.wikimedia.org/wikispecial/EN/SummaryCOMMONS.htm'>View all trend charts for Commons</a></td>
<td><img src='http://stats.wikimedia.org/wikispecial/EN/PNGWIKIDATA'><br><a href='http://stats.wikimedia.org/wikispecial/EN/SummaryWIKIDATA.htm'>View all trend charts for Wikidata</a></td>
</tr>
COMMENTS_BOTTOM
</table>
</body>
</html>
__SCRIPT_TRENDS_ALL_PROJECTS__
 return ($html) ;
}

1 ;
