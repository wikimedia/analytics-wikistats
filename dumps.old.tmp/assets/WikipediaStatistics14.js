var fontSize ;
var abort  = false ;
var regExp = new RegExp (',', 'g') ;
var a = 1 ;

var showTotals = getCookie("ShowTotals");
if (! ((showTotals == "n") || (showTotals == "y")))
{ showTotals = "n" ; }

var showPercentages = getCookie("ShowPercentages");
if (! ((showPercentages == "n") || (showPercentages == "y")))
{ showPercentages = "y" ; }

var showCellColors = getCookie("ShowCellColors");
if (! ((showCellColors == "n") || (showCellColors == "y")))
{ showCellColors = "y" ; }

var twoScales = getCookie("TwoScales");
if (! ((twoScales == "n") || (twoScales == "y")))
{ twoScales = "y" ; }

var plotSize = getCookie("PlotSize");
if (! ((plotSize == 1) || (plotSize == 2) || (plotSize == 3) || (plotSize == 4) || (plotSize == 5) || (plotSize == 6) || (plotSize == 7) || (plotSize == 8)))
{
  plotSize = 2 ;
  setCookie ("PlotSize", plotSize);
}

// bars: white bar (spacer) / black bar / grey bar 
function b1(w)
{ document.write ("<img src='../blanco.gif' width="+w+" height=1>") ; }
function b2a(w,h)
{ document.write ("<img src='../black.gif' width="+w+" height="+h+">") ; }
function b2b(w,h)
{ document.write ("<img src='../grey.gif' width="+w+" height="+h+">") ; }

function tr(data)
{ document.write ("<tr>"+data+"</tr>") ; }

function trc(bgc)
{
  if (showCellColors == "y")
  { bgc = " bgcolor=#C0C0C0" ; }
  else	
  { bgc = " bgcolor="+bgc ; }

	 document.write ("<tr"+bgc+">") ; 
}	

function tdg (data)
{
  if (showCellColors == "y")
  { bgc = " bgcolor=#C0C0C0" ; }
  else	
  { bgc = "" ; }

	 if (data == "")
	 { data = "&nbsp;" ; }
	 document.write ("<td"+bgc+">"+data+"</td>") ; 
}	

function tdc(bgc,perc,val)
{ 
  if (showCellColors == "y")
  { bgc = " bgcolor="+bgc ; }
  else	
  { bgc = "" ; }
  if ((showPercentages == "y") && (perc != ""))
  { document.write ("<td"+bgc+"><span class=d1>"+perc+"</span><small><br></small><span class=d2>"+val+"</span></td>") ; }
  else
  { document.write ("<td"+bgc+">"+val+"</td>") ; }
}	 

function tdnc(val)
{ 
	 document.write ("<td>"+val+"</td>") ; 
}	 

function ll1 (postfix,name,code)
{ document.write ("<td class=cb><b><a href='TablesWikipedia"+postfix+".htm' title='"+name+"'>"+code+"</a></b></td>") ; }

function ll2 (code)
{ document.write ("<td class=cb><b>"+code+"</b></td>") ; }

function thl2nb(code,name)
{ 
	 header = "<a href='TablesWikipedia"+code+".htm'><small>"+name+"</small></a>" ; 
	 document.write ("<th class=lb colspan=2 style='text-align:left'>"+header+"</th>") ;	
}

function thcnb(code,name)
{ 
	 header = "<a href='TablesWikipedia"+code+".htm'><small>"+name+"</small></a>" ; 
	 document.write ("<th class=cnb>"+header+"</th>") ;	
}

function thcxnb(rows,code,name)
{ 
	 header = "<a href='TablesWikipedia"+code+".htm'><small>"+name+"</small></a>" ; 
	 document.write ("<th class=cnb colspan="+rows+">"+header+"</th>") ;	
}

function showOnNoPercentages (code)
{
	 if (showPercentages == "n")
	 { document.write (code) ; }
}

function thcnb0(code,name)
{ 
//	 header = "<a href='TablesWikipedia"+code+".htm'><small>"+name+"</small></a>" ; 
//	 document.write ("<th class=lb colspan=2 style='text-align:left'>"+header+"</th>") ;	
}

var imageFormat = getCookie("ImageFormat");
if (! ((imageFormat == "Gif") || (imageFormat == "Png") || (imageFormat == "Svg")))
{
  imageFormat = "Png" ;
  setCookie ("ImageFormat", imageFormat);
}

function ShowCellTopLeft (text, color, size)
{
  text = '<font color=' + color + '>' + text + '</font>';
  if (size == 'small')
  { text = '<small>' + text + '</small>' ; }
  var x=document.getElementById('table1').rows;
  var y=x[0].cells;
  y[0].innerHTML= text ;
}

function getLegend ()
{
  if (twoScales == "n")
  { return ("&nbsp;") ; }
  else
  if (showTotals == "y")
  { return ("|&nbsp;&nbsp <image src='../violetbar.gif' width=15 height =10> <b>:</b> " +
            "<image src='../yellowbar.gif' width=15 height =10> <b>:</b> " +
            "<image src='../greenbar.gif'  width=15 height =10> = 1 <b>:</b> 1 <b>:</b> 10") ; }
  else
  { return ("|&nbsp;&nbsp <image src='../yellowbar.gif' width=15 height =10> <b>:</b> " +
            "<image src='../greenbar.gif'  width=15 height =10> = 1 <b>:</b> 10") ; }
}

function switchShowTotals()
{
  if (showTotals=="n")
  { showTotals = "y" ; }
  else
  { showTotals = "n" ; }
  setCookie ("ShowTotals", showTotals);
  window.location.reload();
}

function switchTwoScales()
{
  if (twoScales=="n")
  { twoScales = "y" ; }
  else
  { twoScales = "n" ; }
  setCookie ("TwoScales", twoScales);
  window.location.reload();
}

function switchShowPercentages()
{
  if (showPercentages=="n")
  { 
  	 showPercentages = "y" ; 
  	 // alert ("Show percentages") ;
	 }
  else
  { 
  	 showPercentages = "n" ; 
  	 // alert ("Hide percentages") ;
	 }
  setCookie ("ShowPercentages", showPercentages);
  window.location.reload();
}

function switchShowCellColors()
{
  if (showCellColors=="n")
  { 
  	 showCellColors = "y" ; 
  	 // alert ("Show cell colors") ;
	 }
  else
  { 
  	 showCellColors = "n" ; 
  	 // alert ("Hide cell colors") ;
	 }
  setCookie ("ShowCellColors", showCellColors);
  window.location.reload();
}

function switchLanguage()
{
  var language = document.form.language.value;
  window.location = "Statistics__Language_" + language + ".htm" ;
}

function switchPage()
{
  var url = document.form.page.value;
  gotoPage (url) ;
}

function gotoPage(url)
{
  if (url != "")
  { window.location = url ; }
}

function changeCSS(myclass,element,value)
{
  var CSSRules ;
  if (document.all)
  { CSSRules = 'rules';}
  else
    if (document.getElementById)
    { CSSRules = 'cssRules';}
    else
    {return;}
  for (var i = 0; i < document.styleSheets[0][CSSRules].length; i++)
  {
    if (document.styleSheets[0][CSSRules][i].selectorText == myclass)
    { document.styleSheets[0][CSSRules][i].style[element] = value; }
  }
}

function embedSvg(src)
{
  w = 900 ; // zoom factor = 1.1
  if (plotSize == 1) { w = 700 ; }
  if (plotSize == 2) { w = 770 ; }
  if (plotSize == 3) { w = 847 ; }
  if (plotSize == 4) { w = 932 ; }
  if (plotSize == 5) { w = 1025 ; }
  if (plotSize == 6) { w = 1127 ; }
  if (plotSize == 7) { w = 1240 ; }
  if (plotSize == 8) { w = 1500 ; }
  h = Math.round (w * 384/621) ;

  wh = "width='" + w + "' height='" + h + "'" ;
  document.write ("<object data='" + src + "' name='SVGEmbed' " + wh +
                  " type='image/svg+xml'>" +
                  "<embed src='" + src + "' name='SVGEmbed' " + wh +
                  " type='image/svg+xml' pluginspage='http://www.adobe.com/svg/viewer/install/'>" +
                  "</object>") ;
}

function switchPlotSize(zoom)
{
  if ((zoom == "-") && (plotSize > 1))
  {
    plotSize-- ;
    setCookie("PlotSize",plotSize);
    window.location.reload();
  }
  if ((zoom == "+") && (plotSize < 8))
  {
    plotSize++ ;
    setCookie("PlotSize",plotSize);
    window.location.reload();
  }
}

function switchFontSize(zoom)
{
  if ((zoom == "-") && (fontSize > 9))
  {
    fontSize-- ;
    setCookie("FontSize",fontSize);
  }
  if ((zoom == "+") && (fontSize < 18))
  {
    fontSize++ ;
    setCookie("FontSize",fontSize);
  }

  document.getElementById('table1').style.fontSize = fontSize;
  document.getElementById('table2').style.fontSize = fontSize;
  document.getElementById('table3').style.fontSize = fontSize;
  document.getElementById('table4').style.fontSize = fontSize;
  document.getElementById('table5').style.fontSize = fontSize;
  document.getElementById('table6').style.fontSize = fontSize;
}

function initTableSize()
{
  fontSize = getCookie("FontSize");
  if (fontSize == "")
  { fontSize = 11 ; }
  document.getElementById('table1').style.fontSize = fontSize;
  document.getElementById('table2').style.fontSize = fontSize;
  document.getElementById('table3').style.fontSize = fontSize;
  document.getElementById('table4').style.fontSize = fontSize;
  document.getElementById('table5').style.fontSize = fontSize;
  document.getElementById('table6').style.fontSize = fontSize;
}

function setCookie(name, value, expires, path, domain, secure)
{
var curCookie = name + "=" + escape(value) + ((expires) ? "; expires=" + expires.toGMTString() : "") +
((path) ? "; path=" + path : "") + ((domain) ? "; domain=" + domain : "") + ((secure) ? "; secure" : "");
document.cookie = curCookie;
}

function getCookie(name)
{
var prefix = name + "="; var nullstring = ""; var cookieStartIndex = document.cookie.indexOf(prefix);
if (cookieStartIndex == -1) {return nullstring;}
var cookieEndIndex = document.cookie.indexOf(";", cookieStartIndex + prefix.length);
if (cookieEndIndex == -1) {cookieEndIndex = document.cookie.length;}
return unescape(document.cookie.substring(cookieStartIndex + prefix.length, cookieEndIndex));
}

function y_axis(max1,max2,txtmonth,mode,sep1,sep2)
{
  sep_1000 = sep1 ;
  sep_dec  = sep2 ;

  if ((max2 != -1) && (showTotals == "n"))
  { max = max2 ; }
  else
  { max = max1 ; }

  maxheight = 100 ;
  maxvalue  = max ;
  maxvalue3 = max ;
  if (max == 0)
  { maxvalue = 1 ; }

  if (mode == 1)
  { limit = 1000 ; }
  else
  { limit = 100000 ; }

  yscale    = 1 ;
  exponent  = 0 ;
  while (max / yscale > limit)
  {
    yscale = yscale * 10 ;
    exponent ++ ;
  }
  if (yscale == 1)
  { prefix = '&nbsp;' ; }
  else
  {
    if (exponent > 4)
    { prefix = "x 10<sup>" +  exponent +"</sup>" ; }
    else
    { prefix = "x " +  yscale ; }
  }

  maxvalue2 = " " ;
  if (maxvalue > 1000000)
  {
     maxvalue  = Math.round (maxvalue / 100000) / 10 ;
     maxvalue2 = " M" ;
  }

  maxvalue1 = maxvalue ;
  if (maxvalue > 999)
  {
    maxvalue  = '?' + maxvalue ;
    maxvalue1 = maxvalue.substr (1,maxvalue.length-4).toString() + sep_1000 + maxvalue.substr (maxvalue.length-3) ;
  }

  width  = 40 ;
  if (mode == 1)
  {
    h = "<tr><td class=chart_scale bgcolor=#ffffff valign=bottom width=" + width + ">" +
        "<img height=2 src='../blanco.gif' width=" + width + "><br>" +
        maxvalue1.toString() + maxvalue2 + "&nbsp;<br>" +
        "<img height=1 src='../black.gif'  width=" + width + "><br>" +
        "<img height=" + maxheight + " src='../blanco.gif' width=" + width + "><br>" +
        "<img height=1 src='../black.gif'  width=" + width + "><br>" +
        prefix + "&nbsp;<br>" +
        "<img height=1 src='../blanco.gif'  width=" + width + "><br>" +
        txtmonth + "&nbsp;<br></td>" ;
  }
  else
  {
    h = "<tr><td class=chart_scale>" +
          "<table width='100%' cellSpacing=0 cellPadding=0 border=0><tbody><tr>" +
          "<td class=chart_scale bgcolor=#ffffff valign=bottom>" +
        "<img height=1 src='../black.gif'  width=" + 10 + "><br>" +
        "<img height=" + 10 + " src='../blanco.gif' width=1>" +
        maxvalue1.toString() + maxvalue2 + "&nbsp;<br>" +
        "<img height=" + ((maxheight / 2)-11) + " src='../blanco.gif' width=1>" +
        txtmonth + "&nbsp;<br>" +
        "<img height=" + ((maxheight / 2)-2) + " src='../blanco.gif' width=1><br>" +
        "<img height=1 src='../black.gif'  width=" + 10 + "><br>" +
        "</td></tr><tr><td class=chart_scale bgcolor=#ffffff>" + prefix + "&nbsp;</td></tr>" +
        "</tbody></table></td>" ;
  }
  document.write (h);
  maxvalue  = max / yscale ;
  values    = "<td class=chart>" + prefix + "&nbsp;</td>" ;
  odd       = true;
  columns   = 1 ;
}

function bar(color, value, value2, month)
{
  img  = 'blanco' ;
  if (value == "-")
  { value = 0 ; }
  if (value2 == "-")
  { value2 = 0 ; }
  value  *= 1 ;
  value2 *= 1 ;

  if (color == 'Y') { img = 'yellowbar' ; }
  if (color == 'B') { img = 'bluebar' ; }
  if (color == 'R') { img = 'redbar' ; }
  if (color == 'G') { img = 'greenbar' ; }
  if (color == 'V') { img = 'violetbar' ; }
  img2 = 'greybar' ;

  h  = "<td class=chart valign=bottom width=18>" ;

  height = 0 ;
  if ((value != 0) && (maxvalue != 0))
  { height = Math.round (maxheight * ((value/yscale) / maxvalue)) ; }
  height2 = 0 ;
  if ((value2 != 0) && (maxvalue != 0))
  { height2 = Math.round (maxheight * ((value2/yscale) / maxvalue)) - 1 ; }


  if (height2 > 1)
  {
    h += "<img height=1 src='../black.gif' width=15><br>" +
         "<img height=" + (height2 - 1) + " src='../" + img2 + ".gif' width=15><br>" ;
  }

  if (height > 0)
  {
    h += "<img height=1 src='../black.gif' width=15><br>" +
         "<img height=" + height + " src='../" + img + ".gif' width=15><br>" +
         "<img height=1 src='../black.gif' width=18><br>" ;
  }
  else
  { h += "<img height=1 src='../black.gif' width=18><br>" ; }


  value3 = (((value+value2)/yscale)+".").split('.');
  value4 = value3 [0] ;
  if (value4 == 0)
  { value4 = "" ; }

  if (value4 >= 0)
  {
    if (odd)
    { h += "<font color='#000088'>" + value4 + "</font>" ; }
    else
    { h += "<font color='#000000'>" + value4 + "</font>" ; }
    odd = ! odd ;

  }
  h += "<br><img height=1 src='../grey.gif' width=18>" ;
  h += "<br>" + month + "</td>" ;
  document.write (h);
}

function bar2(color, value)
{
  img  = 'blanco' ;
  if (value == "-") { value = 0 ; }

  if (color == 'Y') { img = 'yellowbar' ; }
  if (color == 'B') { img = 'bluebar' ; }
  if (color == 'R') { img = 'redbar' ; }
  if (color == 'G') { img = 'greenbar' ; }

  columns++ ;
  if (columns == 2)
  {
    if (showTotals == "y")
    { img = 'violetbar' ; }
    else
    { img = 'blanco' ; }
  }

  h = "<td class=chart valign=bottom>" +
      "<table width='100%' cellSpacing=0 background='../background2.gif' cellPadding=0 border=0><tbody><tr>" ;

  height = 0 ;
  if ((value != 0) && (maxvalue != 0))
  { height = maxheight * ((value/yscale) / maxvalue) ; }

  if ((twoScales == "y")&& (value < (maxvalue3 / 10)))
  {
    height *= 10 ;
    img = 'greenbar2' ;
  }

  height = Math.round (height) ;

  h += "<td class=chart valign=bottom height='102'><center>" ;
  if ((columns == 2) && (showTotals == "n"))
  {
    h += "&nbsp;" ;
  }
  else
  {
    if (height > 0)
    {
      h += "<img height=1 src='../black.gif' width=15><br>" ;
      h += "<img height=" + height + " src='../" + img + ".gif' width=15><br>" ;
    }
    h += "<img height=1 src='../black.gif' width=15></center>" ;
  }

  value2 = ((value/yscale)+".").split('.');
  value = value2 [0]+'.'+(value2[1]+'0000').substr(0,1);
  if ((value2 [0] > 10) || ((color == 'Y') && (yscale == 1)))
  { value = value2 [0] ; }

  if (value > 0)
  {
     if (value > 999)
     { value = value.substr (0,value.length-3) + "," + value.substr (value.length-3) ; }
     value = value.replace(regExp, sep_1000) ;

     h += "</td></tr><tr><td class=chart><font color='#000000'>" + value + "</font></td></tr>" ;
  }
  else
  { h += "</td></tr><tr><td class=chart>&nbsp;</td></tr>" ; }

  h += "</tbody></table></td>" ;
  document.write (h);
}

// Return a stylesheet rule with the mentioned name

function get_rule (name) 
{
  // W3C
  if (document.getElementById && document.styleSheets && document.styleSheets[0].cssRules) 
  {
    for (sheet = 0; sheet < document.styleSheets.length ; sheet++)
    {
      for (rule = 0; rule < document.styleSheets[sheet].cssRules.length ; rule++)
      {
        if (document.styleSheets[sheet].cssRules[rule].selectorText == name)
        { return (document.styleSheets[sheet].cssRules[rule]) ; }
      }
    }  
  }
  // IE 
  else
 	if(document.all && document.styleSheets) 
  {
    for ( sheet = 0; sheet < document.styleSheets.length; sheet++ )
    {
    	 for(rule=0; rule<document.styleSheets(sheet).rules.length; rule++)
      {
        if(document.styleSheets(sheet).rules(rule).selectorText == name)
        { return (document.styleSheets(sheet).rules(rule)); }
      }
    }    
  }

  return(0);
}

 

function get_style_class (s) 
{
  var theclass = null;

  if (document.layers)
  { theclass = eval ('document.classes.' + s + '.all') ; }
  else
  {
    myclass = get_rule ('.' + s);
    if (!myclass)
    { myclass = get_rule (s); }

    if (!myclass)
    { myclass = get_rule ('*.' + s); }

    if (myclass)
    { return (myclass.style); }
  }
  return (theclass);
}

function set_style_booklinks (showBookSizes)
{
  if (showBookSizes == 0)
  { showBookSizes = getCookie("ShowBookSizes") ; } 

  if (showBookSizes == -1)
  { showBookSizes = getCookie("ShowBookSizes") ; showBookSizes++ ; alert ('x') ;} 
  
  if ((showBookSizes < 1) || (showBookSizes > 3))
  { showBookSizes = 1 ; }
  
  setCookie ("ShowBookSizes", showBookSizes);
  
  if (showBookSizes == 1)
	 {
	 	 get_style_class ('ch1').color = '#BBBB66' ;
	 	 get_style_class ('ch1').fontSize   = '12px' ;
	 	 get_style_class ('ch1').fontWeight = 'normal' ;
	   get_style_class ('ch1').paddingLeft  = '3px' ;
	   get_style_class ('ch1').paddingRight = '3px' ;

	 	 get_style_class ('ch2').color = '#4466AA' ;
	 	 get_style_class ('ch2').fontSize   = '12px' ;
	 	 get_style_class ('ch2').fontWeight = 'normal' ;
	   get_style_class ('ch2').paddingLeft  = '3px' ;
	   get_style_class ('ch2').paddingRight = '3px' ;

	 	 get_style_class ('ch3').color = '#0000FF' ;
	 	 get_style_class ('ch3').fontSize   = '12px' ;
	   get_style_class ('ch3').fontWeight = 'bold' ;
	   get_style_class ('ch3').paddingLeft  = '3px' ;
	   get_style_class ('ch3').paddingRight = '3px' ;
  }		 

  if (showBookSizes == 2)
	 {
	 	 get_style_class ('ch1').color = '#BBBB66' ;
	 	 get_style_class ('ch1').fontSize   = '9px' ;
	 	 get_style_class ('ch1').fontWeight = 'normal' ;
	   get_style_class ('ch1').paddingLeft  = '3px' ;
	   get_style_class ('ch1').paddingRight = '3px' ;

	 	 get_style_class ('ch2').color = '#4466AA' ;
	 	 get_style_class ('ch2').fontSize   = '11px' ;
	 	 get_style_class ('ch2').fontWeight = 'normal' ;
	   get_style_class ('ch2').paddingLeft  = '3px' ;
	   get_style_class ('ch2').paddingRight = '3px' ;

	 	 get_style_class ('ch3').color = '#0000FF' ;
	 	 get_style_class ('ch3').fontSize   = '13px' ;
	   get_style_class ('ch3').fontWeight = 'normal' ;
	   get_style_class ('ch3').paddingLeft  = '3px' ;
	   get_style_class ('ch3').paddingRight = '3px' ;
  }		 

  if (showBookSizes == 3)
	 {
	 	 get_style_class ('ch1').color       = '#000044' ;
	 	 get_style_class ('ch1').fontSize    = '9px' ;
	 	 get_style_class ('ch1').fontWeight  = 'normal' ;
	   get_style_class ('ch1').paddingLeft  = '0px' ;
	   get_style_class ('ch1').paddingRight = '0px' ;

  	 get_style_class ('ch2').color       = '#0000AA' ;
	 	 get_style_class ('ch2').fontSize    = '11px' ;
	 	 get_style_class ('ch2').fontWeight  = 'bolder' ;
	   get_style_class ('ch2').paddingLeft  = '3px' ;
	   get_style_class ('ch2').paddingRight = '3px' ;

	 	 get_style_class ('ch3').color       = '#0000FF' ;
	 	 get_style_class ('ch3').fontSize    = '13px' ;
	   get_style_class ('ch3').fontWeight  = 'bold' ;
	   get_style_class ('ch3').paddingLeft  = '6px' ;
	   get_style_class ('ch3').paddingRight = '6px' ;
  }		 
}