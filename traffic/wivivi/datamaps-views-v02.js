// stabilize x position select box 
// region select box separate ?
// button 'breakdown for lang' consistent text content
// texts in country popup consistent breakdown <> split by country)

  //set initial map coloring to show 

  var mode_show_regions   = false ; 
  var mode_show_languages = true ;

  var sp  = '&nbsp;' ;
  var sp2 = '&nbsp;&nbsp;' ;
  var sp3 = '&nbsp;&nbsp;&nbsp;' ;

  iOS = (iOSVersion () > 0) ;
  iOS = false ;
  var commons        = "<sub><img src='//upload.wikimedia.org/wikipedia/commons/thumb/" ;
  var icon_people    = commons + "9/9d/Community_Noun_project_2280.svg/20px-Community_Noun_project_2280.svg.png'></sub>" ; // for population
  var icon_connected = commons + "5/59/Plug-in_Noun_project_4032.svg/20px-Plug-in_Noun_project_4032.svg.png'></sub>" ; 
  var icon_views     = commons + "e/eb/PICOL_icon_View.svg/23px-PICOL_icon_View.svg.png'></sub>" ; 
  var icon_world     = commons + "8/85/World_icon.svg/20px-World_icon.svg.png'></sup></sub></sup></sub></sub>" ; 
  var icon_sigma     = "<font size=+1><strong><b>&Sigma;</b></strong></font>" ;
  var icon_person    = commons + "7/7f/Community_Noun_project_7345.svg/20px-Community_Noun_project_7345.svg.png'></sub>" ; // for capita
  var icon_speakers  = commons + "9/9d/Noun_project_579150_Conversation.svg/20px-Noun_project_579150_Conversation.svg.png'></sub>" ;

  if (0) // make this optional via checkbox ?
  {
    icon_people    = 'population' ;
    icon_connected = ' connected' ; 
    icon_views     = 'monthly views' ; 
    icon_world     = 'world total' ; 
    icon_sigma     = 'total' ;
    icon_person    = ' person' ;
    icon_speakers  = 'speakers' ;
  }

  var icons_explanation = '<font color=#AAA>' + 
                icon_people + ' = population size, ' + sp2 + 
                icon_speakers + ' = speakers, ' + sp2 +  
                icon_connected + ' = connected to internet, ' + sp2 + 
                icon_views + ' = page views ' + sp2 + 
                icon_world + ' = world total' + 
                icon_person + '= person, ' + sp2 +  
                '<font color=#000>K</font>=thousand, <font color=#000>M</font>=million, <font color=#000>B</font>=billion</font><p>' ;

  var text_about_languages = '<br>Languages ranked by monthly pageviews. Only languages shown with >= 0.1% share in at least one country.' ;

  var text_requests = 'Pageviews' ; // views / pageviews / page views / requests ??

  var text_title_regions   = "Wikipedia, " + data_month + ": "  + ucfirst(text_requests) + " per capita, per month" ; // , per country or region" ; 
//var text_title_languages = "Wikipedia, " + data_month + ": Share per country of " + text_requests + " to language xxx: yyy" ; //, per country" ;
//var text_title_languages = "Wikipedia, " + data_month + ": Share of " + text_requests + " to language xxx: yyy" ; //, per country" ;
  var text_title_languages = "Wikipedia, " + data_month + ": Share of " + text_requests + " to language " ; //, per country" ;
  var text_title_languages = "Wikipedia, " + data_month + ": " + text_requests + " to language " ; //, per country" ;

//var text_show_table_dialog = 'Pageviews from ... ' + text_requests ; // 'Show list of countries' ;
  var text_show_table_dialog_regions = "<table border=0><tr><td><img src='infobox1.png'></td><td>Breakdown<br>by country</td></tr></table>" ; // 'Show list of countries' ;
  var text_show_table_dialog_languages = "<table border=0><tr><td><img src='infobox2.png'></td><td>Breakdown<br>by country</td></tr></table>" ; // 'Show list of countries' ;
//var text_switch_mode_to_languages = "Switch &rArr; <img src='WorldSmall1.jpg'><b>Share of views to language X</b>" ;	
//var text_switch_mode_to_regions   = "Switch &rArr; <b>Pageviews per capita</b>" ; // region" ;
//var text_switch_mode_to_languages = "&rArr; <img src='WorldSmall1.jpg' border=0 style='margin:0;padding:0;border:0'><b>Share of views to language X</b>" ;	
//var text_switch_mode_to_languages = "&rArr; <img src='WorldSmall1.jpg' border=0 style='margin:0;padding:0;border:0'><b>Views to language X</b>" ;	
//  var text_switch_mode_to_languages = "&rArr; <img src='WorldSmall1.jpg' border=0 style='margin:0;padding:0;border:0'>Views to<br>language X" ;	

//var text_switch_mode_to_languages = "<table><tr><td><b>&rArr;</b> <img src='WorldSmall1.jpg' border=0 style='margin:0px;padding:0px;border:0px'></td><td>Views to<br>language X</td></tr></table>" ; 
  var text_switch_mode_to_languages = "<table><tr><td><b>&rArr;</b> <img src='WorldSmall1.jpg' border=0 style='margin:0px;padding:0px;border:0px'></td><td>Pageviews to<br>language X</td></tr></table>" ; 

  var text_switch_mode_to_regions   = "<table><tr><td><b>&rArr;</b> <img src='WorldSmall2.jpg' border=0 style='margin:0px;padding:0px;border:0px'></td><td>Pageviews&nbsp;&nbsp;&nbsp;<br>per capita</td></tr></table>" ; // region" ;
  if (iOS)
  {
    text_switch_mode_to_languages = "<b>&rArr;</b> Pageviews to language X" ; 
    text_switch_mode_to_regions   = "<b>&rArr;</b> Pageviews per capita" ; // region" ;
  }

  var w = window.innerWidth;
  var h = window.innerHeight;
  var max_table_rows = Math.round (h/100) ; // make max rows shown dependant on window height

  var barheight = 10 ; // make all bars in info boxes same height (width depends on percentage shown)
  var overlay_showing = false ;

  var bucket_limits_countries  = [-2,0,0.25,1,2.5,5,10] ;
  var bucket_limits_languages  = [0,0.1,1,5,10,20,50] ; 

  var colorBubbleLabel    = "#888" ; 
  var colorBubbleRegion   = "#F66" ; 
  var colorBubbleLanguage = "#44C" ; 
  var colorNoData         = "#CCC" ; 
  var colorNoData2        = "#333" ; // for legend text (better contrast on white) (now used now, kept fo reference)
  
  var colorDataBoxLanguage = "#080" ; 
  var colorDataBoxRegion   = "#F00" ; 
  var colorDataBoxCountry  = "#44A" ; 

  var opacityBubbleBorder = 0.90 ;
  var opacityBubbleFill   = 0.70 ;

  var hidden = 0 ;
  var grayed = 1 ;
  var normal = 2 ;

  var color_text_grayed  = 'gray' ;
  var color_text_normal  = 'black' ;

  var btn_show_table_dialog_regions   = 'btn_show_table_dialog_regions' ; 
  var btn_show_table_dialog_languages = 'btn_show_table_dialog_languages' ; 
  var btn_switch_mode                 = 'btn_switch_mode' ;
  var btn_show_legend                 = 'btn_show_legend' ;
  var btn_show_about                  = 'btn_show_about' ;
  var select_box_languages            = 'select_box_languages' ;
  var select_box_regions              = 'select_box_regions' ;

  var language_on_display = 'X' ;  

  var language            = 'English' ; 
  var language_name       = 'English Wikipedia' ; 
  var region              = 'World' ; 

  var select_box_languages_left = 0 ;

  function javascript_abort()
  { throw new Error('This is not an error. This is just to abort javascript'); };
  
  var isocodes = {} ;

  var bubbles = [] ;  
  var languages = [] ;  
  var bubbles_regions = [] ; 

  var show_language_list = false ;

  var language_selected = 'EN' ; 
  var region_selected = 'W' ; 
  var region_name = 'World' ; 

  var data_name_EN ;
  var viewfreq_per_country_EN ;
  var index_EN ;

  var text_flags     = '' ;
  var data_flags     = [] ;
  var data_countries = [] ;
  var data_regions   = [] ;
  var data_languages = [] ;

  var file_flags     = 'datamaps-flags.csv' ;
  var file_countries = 'datamaps-views-per-country.csv' ;
  var file_regions   = 'datamaps-views-per-region.csv' ; 
  var file_languages = 'datamaps-views-per-language.csv' ; 
  
  var list_select_box_languages ;
  var list_select_box_regions ;

  header_languages =
    "<tr><th colspan=99 class=l style='background-color:#DDD; vertical-align:middle;color:#080'>" + 
  //"<big>Countries with most " + text_requests + " to xxx</big></th></tr>" +
    "<big>&nbsp;" + text_requests + " to xxx, split by country</big></th></tr>" +
    "<tr class=bubbles>" +
     "<th class=l colspan=5 style='background-color:#DDD; vertical-align:middle;'>Country</th>" +
     "<th class=l colspan=5 style='background-color:#DDD; vertical-align:middle;'>Pageviews</th>" +
     "</tr>";
 
  header_languages +=
    "<tr class=bubbles>" +
     "<th class=l colspan=3 width=1>&nbsp;</th>" +
     "<th class=c colspan=2 style='background-color:#DDD; vertical-align:middle;'>Region</th>" +
     "<th class=r>" + icon_views + "</th>" +      
     "<td class=l colspan=2 style='vertical-align:middle;'><b>contribution per country</b><br><font color='#888'>(percentages add up to ~100%)</font></td>"+ 
     "</tr>";
 
  header_regions =
    "<tr class=bubbles>" +
    "<th class=l colspan=10 style='background-color:#DDD; vertical-align:text-top;'><font color='#F00'>" + 
    "<big>&nbsp; " + text_requests + " to any Wikipedia, from this region</big>" + 
    "</font></th>" +
     "</tr>";
 
  header_regions +=
    "<tr class=bubbles>" +
     "<th colspan=4 class=l style='background-color:#DDD; vertical-align:middle;'>Country</th>" +      
     "<th colspan=3 class=c style='background-color:#DDD; vertical-align:middle;'>Population</th>" +      
     "<th colspan=3 class=c style='background-color:#DDD; vertical-align:middle;'>Pageviews to any Wikipedia</th>" +      
     "</tr>"; 

  header_regions +=
    "<tr class=bubbles>" +
     "<td>&nbsp;</td>" +
     "<td>&nbsp;</td>" +
     "<td>&nbsp;</td>" +
     "<td>N<br>S</td>" +      
     "<th>"  + icon_people +    "</th>" +       
     "<th>%" + icon_world +     "</th>" +  
     "<th>"  + icon_connected + "</th>" +  
     "<th>"  + icon_views +     "</th>" +      
     "<td colspan=2><b>% of global total</b><br><font color='#AAA'>xxx</font></td>" +      
     "<th>&nbsp;</th>" +                   
     "</tr>"; 

  header_countries =
    "<tr><th colspan=99 class=c style='background-color:#DDD; vertical-align:middle;color:#00F'>" + 
    "<big>Wikipedia " + text_requests + ", split by language</big></th></tr>" +
    "<tr class=bubbles>" +
     "<th class=l colspan=2 style='background-color:#DDD; vertical-align:middle;'>Language</th>" +
     "<td class=c colspan=2 style='background-color:#DDD; vertical-align:middle;'>% of country\'s pageviews<br>to language ..." + 
                                                                 "<br><font color='#888'>(percentages add up to ~100%)</font></td>" +
     "</tr>";

//**********************************************************************************************
// functions for init and switch mode (between 'mode_show_languages' and 'mode_show_regions')
// set mode flags, bucket limits, color scheme, title, legend 
//**********************************************************************************************

  var mymap ;

  var bucket_limits ;
  var legend_labels = [] ;
  var colorScheme ;

  var files_read = [] ;
  var toggle = 0 ;

  console.log ('prepMode initial') ; 
  prepMode () ;

  function switchMode () 
  {
//    myelement = document.getElementById(btn_switch_mode) ;
//console.log (myelement.style.bottom + ':::' + myelement.style.left) ;
//    myelement.innerHtml = 'bla bla' ;
//console.log (myelement.height + ':' + myelement.width) ;
//console.log (myelement.style.height + '::' + myelement.style.width) ;
//    document.getElementById ('btn_switch_mode') .innerHTML = '' ;  // status.replace (/\<br\>/g,'') ; }	
//style.height='500px' ;

    console.log ('switchMode') ; 
    mode_show_regions    = ! mode_show_regions ;
    mode_show_languages  = ! mode_show_languages ;

    prepMode () ;
    showMode () ;

    d3.selectAll("circle").remove(); // also to handle memory leak: https://github.com/markmarkoh/datamaps/issues/310
//  d3.selectAll(".regionLabels").remove(); // never to come back (which it should on mode change)  

    show_language_list = false ;

    if (mode_show_languages)
    {
      // show selection box,with previous selection restored
      list_select_box_languages2 = list_select_box_languages.replace ("'"+language_selected+"'","'"+language_selected+"' selected") ;
      SetSelectBoxLanguages (list_select_box_languages2, normal) ;
//      document.getElementById ('select_box_languages').innerHTML = list_select_box_languages2;
      SetTextBreakdownLanguageByCountry (language_name) ;
//      SetSelectedBoxLanguage (lang_code) ;
      SetSelectedBoxLanguage (language_selected) ;

//        showTableDialogLanguages (language_selected);
////      if (! (data_languages === undefined))
////      {
////       worldmap.updateChoropleth (views_per_country, {reset: true}) ;
////       worldmap.updateChoropleth (data_languages); 
////      //  worldmap.bubbles (bubbles, options_bubbles) ;
////      } 
      console.log ('colorMapViewsPerPerson') ;
      data = getLanguageInfo (language_selected) ;
      colorMapViewsPerPerson (data.viewfreq_per_country) ;
    } 

    if (mode_show_regions)
    { 
      // show selection box,with previous selection restored
      list_select_box_regions2 = list_select_box_regions.replace ("'"+region_selected+"'","'"+region_selected+"' selected") ;
      SetSelectBoxRegions (list_select_box_regions2, normal) ;
      SetTextBreakdownRegionByCountry (region_name) ;
   //   SetSelectedBoxRegion (region_code) ;

      if (! (data_countries === undefined))
      {
        worldmap.updateChoropleth (data_countries); 
        worldmap.bubbles (bubbles, options_bubbles) ;
      } 
    }
  }

  function switchIcons () 
  {
  }

  function showTableDialog () //invoked by html: <button id='btn_show_table_dialog_languages[..]' [....] onclick='showTableDialog ()'>
  {
    if (mode_show_languages)
    {
    //d3.select(".infobox").style("display", "block") ; // ???	
      show_language_list = true ;
      showTableDialogLanguages (language_selected) ; // qqqqqa
    }
    else
    {
      show_region_list = true ;
      showTableDialogRegions (region_selected) ;
    }
  }

  function prepMode ()
  {
    var iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream ;

  //  if (iOS)
  //  { alert ('iOS') ; } 
  //  else { alert ('not iOs') ; }

    if (mode_show_regions)
    {
console.log ('mode_show_regions') ; 
      bucket_limits = bucket_limits_countries ;
       
    //colorScheme = [colorBubbleRegion, colorNoData, '#000', '#008', '#080', '#FF0', '#08F', '#8F0', '#F80'] ; // debug
    //colorScheme = [colorBubbleRegion, colorNoData, '#000', '#009', '#03D', '#06F', '#0AF', '#0FF', '#0F8'] ; // blue series
      colorScheme = [colorBubbleRegion, colorNoData, '#000', '#360', '#590', '#7B1', '#9E2', '#CF3'] ; // green series
    }
    else
    {  
console.log ('mode_show_languages') ; 
      bucket_limits = bucket_limits_languages ;
      
    //colorScheme = [colorNoData, '#000', '#008', '#080', '#800', '#00F', '#0F0', '#F00'] ; // debug
      colorScheme = [colorNoData, '#000', '#500', '#800', '#A00', '#C30', '#D80', '#FC0'] ; // red series
 
    //http://colorbrewer2.org/#type=sequential&scheme=Greens&n=6, hard coded as: 
    //colorScheme = [colorNoData, '#006d2c', '#31A354', '#74c476', '#a1d99b', '#c7e9c0', '#edf8e9'] ;
    }
    
    // kept for reference, use external set of colors:
    // var colorScheme = colorbrewer.RdYlBu[9];
    // // if coloring order is running in wrong direction uncomment the following
    // // colorScheme.reverse();

    if (! (worldmap === undefined))
    {
console.log ('set color scheme' + colorScheme [0]) ; 
      worldmap.options.fills =  
      {
        '0': colorScheme[0],
        '1': colorScheme[1],
        '2': colorScheme[2],
        '3': colorScheme[3],
        '4': colorScheme[4],
        '5': colorScheme[5],
        '6': colorScheme[6],
        '7': colorScheme[7],
        defaultFill: colorNoData
      } ;
    }
  }

  function showMode () 
  {
    console.log ('') ;
    console.log ('showMode') ;

    if (mode_show_regions)  
    { 
      setTitle (text_title_regions); 
      SetTextBreakdownRegionByCountry (region_name) ;
      SetButtonTableDialogRegions   (text_show_table_dialog_regions,   normal) ; 
      SetButtonTableDialogLanguages (text_show_table_dialog_languages, hidden) ; 
      SetButtonSwitchMode           (text_switch_mode_to_languages,    normal) ; 
      SetSelectBoxRegions           (list_select_box_regions,           normal) ;
      SetSelectBoxLanguages         ('',                               hidden) ;

      legendCountries () ;
      d3.select(".infobox")      .style("display", "none") ;	
      document.getElementById ('icons_explanation').innerHTML = icons_explanation ;	
      showStatus ('<br>Data read: ' + files_read.join () + '.&nbsp;&nbsp;Canvas: ' + w + 'x' + h) ;

      resetZoom () ;
    }
    else
    { 
      setTitleLanguage (language_on_display) ;
      SetTextBreakdownLanguageByCountry (language_name) ;
      SetButtonTableDialogRegions   (text_show_table_dialog_regions,   hidden) ; 
      SetButtonTableDialogLanguages (text_show_table_dialog_languages, normal) ;
      SetButtonSwitchMode           (text_switch_mode_to_regions,      normal) ; 
      SetSelectBoxLanguages         (list_select_box_languages,        normal) ;
      SetSelectBoxRegions           ('',                               hidden) ;

      legendLanguages () ;
      d3.select(".infobox")      .style("display", "block") ;	
      document.getElementById ('icons_explanation').innerHTML = icons_explanation ;	
      showStatus (text_about_languages + ' <br>Data read: ' + files_read.join () + '.&nbsp;&nbsp;Canvas: ' + w + 'x' + h  + ' ' + max_table_rows) ;
    }
  
    adaptToSmallScreen ()
  }

  function showStatus (status)
  {
    if (w > 900)
    { document.getElementById ('status_bottom_right').innerHTML = status ; }	
    else
    { document.getElementById ('status_bottom_left') .innerHTML = status.replace (/\<br\>/g,'') ; }	
  }

  function adaptToSmallScreen ()
  {
    if (h > 600)
    {
      SetButtonShowLegend (hidden) ;
      SetButtonShowAbout  (hidden) ;
    }
    else
    {
      SetButtonShowLegend (normal) ;                                   // show legend as separate window
      SetButtonShowAbout  (normal) ;                                   // show about info as separate windows
      document.getElementById ('icons_explanation').innerHTML = '' ; // remove legend icons ;	
      document.getElementById ('legend')           .innerHTML = '' ; // remove legend and about info from main window ;	
      document.getElementById ('about')            .innerHTML = '' ; // remove legend and about info from main window ;	
    //d3.selectAll('.datamaps-legend').remove () ;                     // remove legend colors
    //d3.select('.infobox').style('display', 'block') ;	
      document.getElementById ('status_bottom_right').innerHTML = '' ; // non eesential status info (screen metrics, etc)
      document.getElementById ('status_bottom_left') .innerHTML = '' ; 	
    }
  }

  function SetTextBreakdownLanguageByCountry (language)
  {
    console.log ('SetTextBreakdownLanguageByCountry, language ' + language) ;
    if (iOS)
    { text_show_table_dialog_languages = "Breakdown by country for " + language ; }
    else
    { text_show_table_dialog_languages = "<table border=0><tr><td><img src='infobox1.png'></td><td>Breakdown by country<br>for " + 
                                         language +                                   
                                         "</td></tr></table>" ; }
  }

  function SetTextBreakdownRegionByCountry (region)
  {
    console.log ('SetTextBreakdownRegionByCountry, region ' + region) ;

    if (iOS)
    { text_show_table_dialog_regions = "Breakdown by country for region " + region ; }
    else                                   
    { text_show_table_dialog_regions = "<table border=0><tr><td><img src='infobox2.png'></td><td>Breakdown by country<br>for region " +
                                       region +                                   
                                       "</td></tr></table>" ; }
   
  }

//**********************************************************************************************
//**********************************************************************************************
//
//**********************************************************************************************

  window.addEventListener('resize', function () 
  { 
    window.location.reload(); 
  });

//  $( window ).resize(function() {
  //  map.resize();
//  });

//**********************************************************************************************
// read flags (not always reliable, to be researched)
//**********************************************************************************************

//kept for reference: d3.json = asynchronous, d3.text = synchronous 
// although it not always seems to be the case, maybe d3.csv.parse is asynch (?)
//
//d3.json (file_flags,  
//  function(error, data) 
//  {
//    if (error !== null)
//    { console.log ("!!! error reading " + file_flags + ": " + error) ; return ; }

  d3.text (file_flags, function(text) 
  {
    text_flags = text ;
    data_flags = d3.csv.parse(text) ;
    files_read.push (data_flags.length + ' flags') ; // less relevant (but FYI) now that files are read synchronously
  }) ;

//if (data_flags [0] === undefined)  // hmm somehow flags are loaded most of the time anyway
//{ alert ('flag icons could not be loaded, please refresh') ; }

//**********************************************************************************************
// read countries
//**********************************************************************************************

//kept for reference: d3.csv = asynchronous, d3.text = synchronous 
//
//d3.csv (file_countries,
//
//  function(error, data) 
//  {
//      if (error !== null)
//      { console.log ("!!! error reading " + file_countries + ": " + error) ; return ; }

  // processing of data (still) done in callback, in case asynchronous d3.csv is going to be used again
  d3.text (file_countries, function(text) 
  {
    data_countries = d3.csv.parse(text) ;

    var bucket_limits  = bucket_limits_countries ; 

    for (var i = 0 ; i < data_countries.length ; i++)
    { 
      data_countries [i].breakdown_per_language = buildTableRowsDialogCountry (data_countries [i].breakdown_per_language).
                                                  replace (/\^/g, '&nbsp;').  // decompress
                                                  replace (/\.%/g, '\.0%') ;  // enforce at least one decimal

      data_countries [i].population = data_countries [i].population.replace (/\^/g, '&nbsp;');  // decompress

      var views_pp = data_countries [i].views_per_person ;

      var fillKey = '0' // no data (= default)

           if (views_pp == -2)               { fillKey = '0'; } // region
      else if (views_pp >= bucket_limits[7]) { fillKey = '8'; } // views per person
      else if (views_pp >= bucket_limits[6]) { fillKey = '7'; } // views per person
      else if (views_pp >= bucket_limits[5]) { fillKey = '6'; } // views per person
      else if (views_pp >= bucket_limits[4]) { fillKey = '5'; } // views per person
      else if (views_pp >= bucket_limits[3]) { fillKey = '4'; } // views per person
      else if (views_pp >= bucket_limits[2]) { fillKey = '3'; } // views per person
      else                                   { fillKey = '2'; } // views per person

      data_countries [i].fillKey = fillKey ;  
 
      isocodes [data_countries [i].ISO] = {fillKey: '2'} ; 

      // copied from other site, but not understood 
      data_countries [ data_countries [i].ISO ] = data_countries [i] ;
      delete  data_countries [i].ISO;
      delete  data_countries [i] ;
    }
    files_read.push (data_countries.length + ' countries') ;

    worldmap.updateChoropleth (data_countries);
  });

//**********************************************************************************************
// read regions 
//**********************************************************************************************

  // processing of data (still) done in callback, in case asynchronous d3.csv is going to be used again
  d3.text (file_regions, function(text) 
  {
    data_regions = d3.csv.parse(text) ;

    var count_regions = 0 ;

  //list_select_box_regions   = "<b><big>Select region: </big></b>\n" + 
  //list_select_box_regions   = "<b><big>&nbsp;Region: </big></b>\n" + 
  //                     "<select id='select_box_regions' onchange='showTableDialogRegions (this.value)'>\n" ;  
    list_select_box_regions   = "<select id='select_box_regions' onchange='showTableDialogRegions (this.value)'>\n" ;  
    list_select_box_regions +=  " <option value='XX' selected='selected'>none</option>\n" ;  

    for (var i = 0 ; i < data_regions.length ; i++)
    {
      if (data_regions [i].label === undefined) { continue ; } // skip empty lines

      count_regions ++ ;
      data_regions [i].breakdown_by_country = buildTableRowsDialogRegion (data_regions [i].breakdown_by_country).
                                              replace (/\^/g, '&nbsp;').  // decompress
                                              replace (/\.%/g, '\.0%') ;  // enforce at least one decimal

      data_regions [i].population = data_regions [i].population.replace (/\^/g, '&nbsp;');  // decompress

      var region_name = data_regions [i].name ;
      var region_code = data_regions [i].label ;

      data_regions [i].region_code = data_regions [i].label ; // don't show labels ('W','GS','GN', etc) can't hide them on mode switch

      list_select_box_regions += "  <option value='" + region_code + "'>" + region_name + "</option>\n" ; 

      if (':W:GS:'.indexOf (':' + data_regions [i].label + ':') > -1) // test for occurence of these strings, avoid partial match 
      { list_select_box_regions += "<option disabled>----------</option>\n" ; }

      data_regions [i].fillKey = '0' ; 
      data_regions [i].radius  = '7' ; 
     
      if (w > 1200) { data_regions [i].radius  = '10' ; }
      if (w > 1800) { data_regions [i].radius  = '12' ; }

      data_regions [i].highlightFillColor = '#FF0' ;
      data_regions [i].borderWidth        = 1 ;

      if (':EU:AF:NA:CA:SA:AS:OC:'.indexOf (':' + data_regions [i].label + ':') == -1) 
      { data_regions [i].radius  = '0' ; } // do not show bubbles for 'W', 'GN', 'GS'

   // data_regions [ data_regions [i].label ] = data_regions [i].label ; // do now show labels ('W','GS','GN', etc) can't hide them on mode switch

      data_regions [i].label = '' ; // label was used for plug-in, no longer in use

      bubbles.push (data_regions [i]) ;  
    }

    files_read.push (count_regions + ' regions') ;

    list_select_box_regions   += "</select>" ;

    showMode () ;

//  worldmap.svg.selectAll('.bubbles').on('click', function (event, data) {alert (data.radius);}) // test

  }) ;

//**********************************************************************************************
// read languages
//**********************************************************************************************

  // processing of data (still) done in callback, in case asynchronous d3.csv is going to be used again
  d3.text (file_languages, function(text) 
  {
    data_languages = d3.csv.parse(text) ;

    var count_languages = 0 ;

  //list_select_box_languages = "<b><big>&nbsp;Language: </big></b>" + 
  //list_select_box_languages = "<select id='select_box_languages' onchange='showTableDialogLanguages (this.value)'>" ;  
    list_select_box_languages = "<select id='select_box_languages' onchange='switchLanguage (this.value)'>" ;  

    for (var i = 0 ; i < data_languages.length ; i++)
    {
      count_languages ++ ;

      var lang_name = data_languages [i].name ;
      var lang_code = data_languages [i].label ;
      lang_name = lang_name.replace (" Wikipedia","") ;

      if (language_on_display == 'X')
      { language_on_display = data_languages [i].name ; } 

      if (i == 0)
      { list_select_box_languages += "  <option value='" + lang_code + "' selected='selected'>" + lang_name + "</option>\n" ; } 
      else  
      { list_select_box_languages += "  <option value='" + lang_code + "'>" + lang_name + "</option>\n" ; }

      data_languages [i].breakdown_by_language = buildTableRowsDialogLanguage (data_languages [i].breakdown_by_language).
                                                 replace (/\^/g, '&nbsp;').  // decompress
                                                 replace (/\.%/g, '\.0%') ;  // enforce at least one decimal

      // save country data for english, for initial showing 
      if (data_languages [i].name.indexOf ('English') > -1)
      {
        data_name_EN = data_languages [i].name ;
        viewfreq_per_country_EN = data_languages [i].viewfreq_per_country ;
        index_EN = i ;
      }

      data_languages [i].lang_code = data_languages [i].label ; 
      languages.push (data_languages [i]) ;  
    }
   
    files_read.push (count_languages + ' languages') ;

    list_select_box_languages += "</select>" ;

    showMode () ;

    language_on_display = data_name_EN ;  
    colorMapViewsPerPerson (viewfreq_per_country_EN) ;
  });


//**********************************************************************************************
// create map
//**********************************************************************************************

  var worldmap = new Datamap 
  (
    {
      scope:      'world',
      projection: 'equirectangular',
      element:     document.getElementById('map'),

      done: function (map)
      {
         mymap = map ;
      // zoomlevel = 0 ; // test

         map.svg.call(d3.behavior.zoom().on("zoom", redraw));
         function redraw() 
         { 
        // if (++ zoomlevel > 2) { return ; } // test
           map.svg.selectAll("g").attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")"); 
         }
      },

      geographyConfig: 
      {
        highlightOnHover:      true,
        popupOnHover:          true,
        borderColor:           '#aaa',
        borderWidth:           1,
        highlightBorderColor: 'black',
        highlightBorderWidth:  1,
        highlightFillColor:    '#88F', 


        popupTemplate: function (geo,csv_countries)
        {
           return (prepHoverBoxCountries (geo,csv_countries)) ;
        },
      },

      fills: 
      {
        '0': colorScheme[0],
        '1': colorScheme[1],
        '2': colorScheme[2],
        '3': colorScheme[3],
        '4': colorScheme[4],
        '5': colorScheme[5],
        '6': colorScheme[6],
        '7': colorScheme[7],
        '8': colorScheme[8],
        '9': colorScheme[9], 
        defaultFill: colorNoData
      },
  });


//**********************************************************************************************
// set options for bubbles, plus handler for onhover dialog 
//**********************************************************************************************

// no labels, as I can't find how to hide them in other mode
// worldmap.addPlugin('regionLabels', handleRegionLabels);
// worldmap.regionLabels(bubbles, {labelColor: colorBubbleLabel, labelKey: 'label', fontSize: 12}); 

//  d3.selectAll(".datamaps-bubble").remove() ;
//  worldmap.regionLabels(bubbles, {labelColor: '#FF0', labelKey: 'label', fontSize: 99}); 

  options_bubbles = 
  {
    borderOpacity : opacityBubbleBorder,
    fillOpacity   : opacityBubbleFill,

    popupTemplate:
      function (geography, data) 
      { 
          /* 
            if (data.longitude < 0) 
          //{ side = 'right: 20px' ; } to be researched: on very large screen hover box goes way outside map
            { side = 'left: 500px' ; }
            else
            { side = 'left: 5px' ; }
          */   
          side = 'left: 5px' ; 

          info = "<div class='hoverinfo' align=left " + 
                 "style='position: relative ; top: 30px ; " + side + "; white-space: nowrap ; background-color: #FFF; " + 
                 "box-shadow: 2px 2px 5px #CCC; font-size: 12px; border: 3px solid " + colorDataBoxRegion + "; padding: 5px'>" +

                 "&nbsp;<strong>region<font color=" + colorDataBoxRegion + "> " + data.name + "</font></strong>" + sp2 + 
                 icon_people + sp + data.population + sp2 + '(' + data.perc_connected + sp + icon_connected + ')' +
                 "<br>" + icon_views + sp + data.requests + sp2 + '=' + sp2 + 
                 data.perc_share_total + " of " + icon_world + sp2 + '=' + sp2 + data.requests_per_connected_person + " per" + icon_person +
               //"<hr>" + 

               //"<table class=bubbles>" +
               //header_regions +
               //data.breakdown_by_country +
               //"<tr><td class=lnb colspan=99><font color=#888><hr width='100%'><small>Data for " + data_month + "<small></font></td></tr>" + 
               //"</table>" + 
                 "</div>" ;
          //console.log (info) ;

          info = info.replace (/\^/g, '&nbsp;') ; // decompress
          return (info) ;  
    }
  };


// $(worldmap.svg[0][0]).on('click', '.bubbles', function(e) { alert ('1') ; }) ; //test

// http://stackoverflow.com/questions/27215394/d3-datamaps-onclick-events-on-bubbles?rq=1
//worldmap.svg.selectAll ('.bubbles').on('click', function() { alert (1) ; }); // test

//**********************************************************************************************
// get country flag icon
//**********************************************************************************************

  function getFlagIcon (iso3)
  {
    if (data_flags.length == 0)
    {
      console.log ('retry loading flags') ;
    //alert ('retry loading flags') ; // debug only

      data_flags = d3.csv.parse(text_flags) ; // retry
    }

    if ((data_flags === undefined) || (iso3 === undefined))
    { return ('?') ; }

    var flag_icon = '???' ;
    for (var i = 0 ; i < data_flags.length ; i++) 
    {
      if (data_flags [i].country_iso3 == iso3) 
      { flag_icon = data_flags [i].flag_image ; break ; }
    }
    return (flag_icon) ;
  }

//**********************************************************************************************
// create legend (two variations, one for each mode)
//**********************************************************************************************

  function legendCountries ()
  {
  //remove previous legend
    d3.selectAll('.datamaps-legend').remove () ; 
  
    /*
    worldmap.legend (
    {
      legendTitle : '',
      labels: 
      {
        '0': "<font color=" + colorBubbleRegion + ">region</font>",
        '1': "<font color=" + colorNoData + ">no data</font><p>",
        '2': sp2 + "<b>views per person, month:</b></font>" + sp2 + bucket_limits [1] + " - " + bucket_limits [2] + ": ",  
        '3': sp2 + bucket_limits [2] + " - " + bucket_limits [3] + ": ",  
        '4': sp2 + bucket_limits [3] + " - " + bucket_limits [4] + ": ",  
        '5': sp2 + bucket_limits [4] + " - " + bucket_limits [5] + ": ",  
        '6': sp2 + bucket_limits [5] + " - " + bucket_limits [6] + ": ",  
        '7': sp2 + "&gt; " + bucket_limits [6] + ": " 
      },
    });
    */
    prefix = "views pm pp: " ;
    legend_labels = [] ;
    legend_labels.push ("<font color=" + colorBubbleRegion + ">region</font>") ;
    legend_labels.push ("<font color=" + colorNoData2 + ">no data</font>") ;
    legend_labels.push (prefix + bucket_limits [1] + " - " + bucket_limits [2]) ;  
    legend_labels.push (prefix + bucket_limits [2] + " - " + bucket_limits [3]) ;  
    legend_labels.push (prefix + bucket_limits [3] + " - " + bucket_limits [4]) ;    
    legend_labels.push (prefix + bucket_limits [4] + " - " + bucket_limits [5]) ;  
    legend_labels.push (prefix + bucket_limits [5] + " - " + bucket_limits [6]) ;  
    legend_labels.push (prefix + "&gt; " + bucket_limits [6]) ; 
  
    worldmap.mylegend  ({legendTitle:"Views per month per person "}) ;
  }

//**********************************************************************************************

  function legendLanguages ()
  {
  //remove previous legend
    d3.selectAll('.datamaps-legend').remove () ; 

    /*
    worldmap.legend (
    {
      legendTitle: '',  
      labels: 
      {
      //'0': "<font color=" + colorBubbleRegion + ">n.a.</font>",
      //'1': "<font color=" + colorBubbleLanguage + ">lang.</font>",
        '2': "<font color=" + colorNoData + ">no data</font><br>",
        '3': sp2 + "<b>share for this language (%)</b></font>" + 
             sp2 + bucket_limits [2] + "-" + bucket_limits [3] + ": ",  
        '4': sp2 + bucket_limits [3] + "-" + bucket_limits [4] + ": ",  
        '5': sp2 + bucket_limits [4] + "-" + bucket_limits [5] + ": ",  
        '6': sp2 + bucket_limits [5] + "-" + bucket_limits [6] + ": ",  
        '7': sp2 + bucket_limits [6] + "-" + bucket_limits [7] + ": ",  
        '8': sp2 + bucket_limits [7] + "-" + bucket_limits [8] + ": ",  
        '9': sp2 + "> " + bucket_limits [8] + ": "  
      },
    });
    */

    prefix = "share: " ;
    legend_labels = [] ;
    legend_labels.push ("<font color=" + colorNoData2 + ">no data</font>") ;
    legend_labels.push (prefix + bucket_limits [0] + "%-" + bucket_limits [1] + "%") ;
    legend_labels.push (prefix + bucket_limits [1] + "%-" + bucket_limits [2] + "%") ;  
    legend_labels.push (prefix + bucket_limits [2] + "%-" + bucket_limits [3] + "%") ;  
    legend_labels.push (prefix + bucket_limits [3] + "%-" + bucket_limits [4] + "%") ;  
    legend_labels.push (prefix + bucket_limits [4] + "%-" + bucket_limits [5] + "%") ;  
    legend_labels.push (prefix + bucket_limits [5] + "%-" + bucket_limits [6] + "%") ;  
    legend_labels.push (prefix + "> " + bucket_limits [6] + "%") ;  
  
    language_on_display2 = language_on_display ;
    language_on_display2 = language_on_display2.replace (/.*?: /, '') ; // do not show rank again e.g. '#1: English' -> 'English'
  
  //worldmap.mylegend  ({legendTitle:"Share of " + text_requests + "<br>to " + language_on_display2}) ;
    worldmap.mylegend  ({legendTitle:text_requests + "<br>to " + language_on_display2}) ;
  }

//**********************************************************************************************
// create table rows (three variations, one for language, countries, regions)
//**********************************************************************************************

  function buildTableRowsDialogCountry (list)
  {
    if (list === undefined)
    {
      alert ('buildTableRowsDialogCountry: list not (yet) defined)') ;
      return ('') ;
    } 

    var data ;
    var html = '' ;
    var languages = list.split ("|");
    var rows = 0 ;
    var shade_class = '' ;
    var lang_code, langname, perc, barwidth ;
    var total_perc_shown = 0 ; 
  
    for (var j=0; j < languages.length ; j++) 
    {
      if (++rows > max_table_rows)
      { 
         html += htmlLimitMaxRows (2,total_perc_shown) ; 
         break ;
      }
 
      data = languages [j].split (":");
      lang_code = data [0] ;
      langname = data [1] ;
      perc     = data [2] ;
      barwidth = data [2] ;
  
      if (perc) 
      { total_perc_shown += Number (perc.replace (/\%/g,'')); }
  
      if (shade_class === undefined) { shade_class = '?' ; }
      if (lang_code   === undefined) { lang_code    = '?' ; }
      if (langname    === undefined) { langname    = '?' ; }
      if (perc        === undefined) { perc        = '?' ; }
      if (barwidth    === undefined) { barwidth    = '0' ; }
      
      bar = '' ;
      if (barwidth !== '0')
      { 
        barwidth = 1.5 * barwidth.replace ('\%','') ; 
        bar = "<img src='bluebar.gif' width=" + barwidth + " height=" + barheight + ">" ;
      }

      if (rows % 2 == 0)
      { shade_class = "row_shade_even" ; }
      else
      { shade_class = "row_shade_odd" ; }

      html += "<tr class=" + shade_class + ">" +
              "<td>" + lang_code     + "</td>" + 
              "<td>" + langname     + "</td>" + 
              "<td class=r>" + perc + "</td>" + 
              "<td>" + bar          + "</td>" + 
              "</tr>" ;
    }

    return (html) ; 
  }

//**********************************************************************************************

  function buildTableRowsDialogRegion (list)
  {
    var data ;
    var html = '' ;
    var regions = list.split ("|");
    var rows = 0 ;
    var shade_class = '' ;
    var index, iso3, icon, country, north_south, population, perc_population, perc_connected, requests, redbar ;
    var total_perc_shown = 0 ; 
  
    for (var j=0; j < regions.length ; j++) 
    {
      if (++rows > max_table_rows)
      { 
         html += htmlLimitMaxRows (8,total_perc_shown) ; 
         break ;
      }
  
      if (regions [j] == '') { continue ; }
  
      data = regions [j].split (":");
   
      if (data [0] == '') { continue ; }
  
      index            = data [0] ;
      iso3             = data [1] ;
      country          = data [2] ;
      north_south      = data [3] ;
      population       = data [4] ;
      perc_population  = data [5] ;
      perc_connected   = data [6] ;
      requests         = data [7] ;
      perc_share_total = data [8] ;
    
      if (perc_share_total) 
      { total_perc_shown += Number (perc_share_total.replace (/\%/g,'')); }
  
      icon = getFlagIcon (iso3) ;

      if (! (perc_population === undefined))
      { 
        if (perc_population.search ("0.0") > -1) 
        { perc_population = "<font color=#CCC><small><&nbsp;0.1%</small></font>" ; }
      }

      if (perc_share_total === undefined)
      { redbar = "&nbsp" ; }
      else if (perc_share_total.search ("0.0") > -1) 
      { 
        perc_share_total = "<font color=#CCC><small><&nbsp;0.1%</small></font>" ; 
        redbar = "&nbsp" ;
      }
      else
      {
        perc_share_total = perc_share_total.replace ("0%","%") ; // 0.10% -> 0.1% 
        barwidth         = data [8] ;
        if (! (barwidth === undefined))
        { barwidth = 1.5 * barwidth.replace ('\%','') ; }
        redbar = "<img src='redbar.gif' width=" + barwidth + " height=" + barheight + ">" ; 
      }

           if (north_south == "N") { north_south = "<font color=#000BF7><b>N<\/b><\/font>" ; }
      else if (north_south == "S") { north_south = "<font color=#FE0B0D><b>S<\/b><\/font>" ; }

      if (rows % 2 != 0)
      { shade_class = "row_shade_even" ; }
      else
      { shade_class = "row_shade_odd" ; }

      html += "<tr class=" + shade_class + ">" +
              "<td>" + index + "</td>" + 
              "<td><span valign=middle class='vertical-align:middle'>" + icon + "</td>" + 
              "<td>" + addLinkAndShortenCountryName (country) + "</span></td>" + 
              "<td>" +         testnull (north_south)      + "</td>" + 
              "<td class=r>" + testnull (population)       + "</td>" + 
              "<td class=r>" + testnull (perc_population)  + "</td>" + 
              "<td class=r>" + testnull (perc_connected)   + "</td>" + 
              "<td class=r>" + testnull (requests)         + "</td>" + 
              "<td class=r>" + testnull (perc_share_total) + "</td>" + 
              "<td>" + redbar + "</td>" + 
              "</tr>" ;
    }

    return (html) ; 
  }

  function testnull (value)
  { return (value === undefined ? '<font color=#AAA>-</font>' : value) ; }

//**********************************************************************************************

  function buildTableRowsDialogLanguage (list)
  {
  //console.log (list) ;
    var data ;
    var html = '' ;
    var countries = list.split ("|");
    var rows = 0 ;
    var shade_class = '' ;
    var countries, iso3, icon, country, north_south, requests, perc_requests, greenbar ;
    var total_perc_shown = 0 ; 

    for (var j=0; j < countries.length ; j++) 
    {
      if (++rows > max_table_rows)
      { 
        html += htmlLimitMaxRows (6,total_perc_shown) ; 
        break ; 
      }
  
      data = countries [j].split (":");
   
      index            = data [0] ;
      iso3             = data [1] ;
      country          = data [2] ;
      north_south      = data [3] ;
      region_code      = data [4] ;
      requests         = data [5] ;
      perc_requests    = data [6] ;

      total_perc_shown += Number (perc_requests.replace (/\%/g,''));
  
      icon = getFlagIcon (iso3) ;
  
      if (perc_requests === undefined)
      { greenbar = "&nbsp" ; }
      else if (perc_requests.search ("0.0") > -1) 
      { 
        perc_requests = "<font color=#CCC><small><&nbsp;0.1%</small></font>" ; 
        greenbar = "&nbsp" ;
      }
      else
      {
        perc_requests = perc_requests.replace ("0%","%") ; // 0.10% -> 0.1% 
        barwidth         = data [6] ;
        if (! (barwidth === undefined))
        { barwidth = 1.5 * barwidth.replace ('\%','') ; }
        greenbar = "<img src='greenbar.gif' width=" + barwidth + " height=" + barheight + ">" ; 
      }

           if (north_south == "N") { north_south = "<font color=#000BF7><b>N<\/b><\/font>" ; }
      else if (north_south == "S") { north_south = "<font color=#FE0B0D><b>S<\/b><\/font>" ; }

      if (rows % 2 != 0)
      { shade_class = "row_shade_even" ; }
      else
      { shade_class = "row_shade_odd" ; }

      icon = getFlagIcon (iso3) ;

      html += "<tr class=" + shade_class + ">" +
              "<td width=1>" + index + "</td>" + 
              "<td>" + icon + "</td>" +
              "<td>" + addLinkAndShortenCountryName (country) + "</td>" + 
              "<td>" + north_south + "</td>" + 
              "<td class=r>" + region_code + "</td>" + 
              "<td class=r>" + requests + "</td>" + 
              "<td class=r>" + perc_requests + "</td>" + 
              "<td>" + greenbar + "</td>" + 
              "</tr>" ;
    }

    return (html) ; 
  }

  function htmlLimitMaxRows (colspan,total_perc_shown)
  { 
     var html = "<tr><td colspan=" + colspan + " style='vertical-align:text-bottom'><font color=#888>Only first " + max_table_rows + " rows shown!</td>" ;

//     for (i = 5; i < column ; i++)
//     { html += "<td>&nbsp;</td>" ; }
 
     html += "<td class=r><font color=#AAA>&Sigma;: " + total_perc_shown.toFixed(1) + "%<font></td></tr>" ; 
     return (html) ;
  }

  function colorMapViewsPerPerson (view_freqs)
  {
    console.log ('colorMapViewsPerPerson') ;
    var views_per_country = {} ;

    for (var isocode in isocodes)
    { views_per_country [isocode] = {fillKey : '1'} ; }  

    var view_freq = view_freqs.split (";"), part;

    for (var j=0; j < view_freq.length ; j++) 
    {
      part = view_freq [j].split (":");
      isocode  = part [0] ;
      viewfreq = part [1] ;
    //views_per_country [part[0]] = {fillKey : part [1]} ;
      fill_key = '0' ;    

           if (viewfreq < bucket_limits [1]) { fill_key = '1' ; }
      else if (viewfreq < bucket_limits [2]) { fill_key = '2' ; }
      else if (viewfreq < bucket_limits [3]) { fill_key = '3' ; }
      else if (viewfreq < bucket_limits [4]) { fill_key = '4' ; }
      else if (viewfreq < bucket_limits [5]) { fill_key = '5' ; }
      else if (viewfreq < bucket_limits [6]) { fill_key = '6' ; }
      else                                   { fill_key = '7' ; }

      views_per_country [isocode] = {fillKey : fill_key} ;
    }
  
    worldmap.updateChoropleth (views_per_country, {reset: true}) ;
  }

//worldmap.bubbles.labels() ;

//**********************************************************************************************
// format labels (no longer used, as I can't find how to hide them in other mode), kept for ref
//                                                     from jsbin.com/ociMiJu/1/edit?html,output
//**********************************************************************************************

  /*
  function handleRegionLabels (layer, data, options) 
  {
    var self = this;
    options = options || {};

    d3.selectAll(".datamaps-bubble")
    .attr("data-foo", function(datum) 
    {
      var coords = self.latLngToXY(datum.latitude, datum.longitude)
              
      layer.append("text")
           .attr("x", coords[0] + 9)
           .attr("y", coords[1] + 4)
        // .style("text-align", 'center')
        // .style("vertical-align", 'middle')
           .style("font-size", (options.fontSize || 20) + 'px')
           .style("font-family", options.fontFamily || "Verdana")
           .style("fill", options.labelColor || colorBubbleLabel)
           .style('stroke', colorBubbleLabel)
           .text(datum[options.labelKey || 'fillKey']);
      return "bar";
    });
  }
  */

  function setTitle (title)
  {
  
    var title_canvas = d3.select ("#page_title")
  
    title_canvas.select ("rect").remove () ; 
    title_canvas.select ("text").remove () ; 
    title_canvas.select ("svg") .remove () ; 

    title_canvas.append
      ("rect")
       .attr("width", "100%")
       .attr("height", "100%")
       .attr("fill", "white");

    title_canvas.append
      ("text")
       .text(title)
       .attr("x",40)
       .attr("y",20)
       .attr('class','mainTitleText');
	
    title_canvas.append 
      ("svg:image")
       .attr ('x',3)
       .attr ('y',1)
       .attr ('width',  25)
       .attr ('height', 27)
       .attr ("xlink:href","https://upload.wikimedia.org/wikipedia/commons/8/81/Wikimedia-logo.svg");
   
    if (mode_show_languages && (select_box_languages_left == 0)) // qqqqq
    {
      var elem = document.getElementById("select_box_languages");
      select_box_languages_left = title_canvas.select("text").node().getBBox().width+50 ;
      elem.style.left = (select_box_languages_left) + 'px' ;
    }
   
    if (mode_show_regions)
    {
    //var elem = document.getElementById("select_box_regions");
    //select_box_regions_left = title_canvas.select("text").node().getBBox().width+50 ;
    //elem.style.left = (select_box_regions_left) + 'px' ;
    }
  }

var modal = document.getElementById ('modal-infobox');    // Get the modal

  window.onclick = function(event) // When the user clicks anywhere outside of the modal, close it
  {
    if (event.target == modal) 
    { closeDialog () ; }

    /*
    if (overlay_showing)
    {
      el = document.getElementById("overlay");
      el.style.visibility = "hidden" ;
      overlay_showing = false ;
    }
    */

    window.ondblclick = function(event)
    {
    //  console.log ('dblclick') ;
    //  resetZoom () ;
    }

    if (mode_show_languages)  
    { legendLanguages () ; } // update legend (which also shows active language, to be extra clear)
  }

  function strip(html)
  {
     var tmp = document.createElement("DIV");
     tmp.innerHTML = html;
     return tmp.textContent||tmp.innerText;
  }

  function closeDialog ()
  {
    console.log ('') ;
    console.log ('closeDialog') ;

    modal.style.display = "none";
    show_region_list   = false ;
    show_language_list = false ;

    if (mode_show_languages)
    {
      SetTextBreakdownLanguageByCountry (language_name) ;
      SetButtonTableDialogLanguages (text_show_table_dialog_languages, normal) ;
      SetButtonSwitchMode  (text_switch_mode_to_regions,      normal) ; 
    }
    else    
    {
      SetTextBreakdownRegionByCountry (region_name) ;
      SetButtonTableDialogRegions (text_show_table_dialog_regions, normal) ;
      SetButtonSwitchMode  (text_switch_mode_to_languages,    normal) ; 
    }
  }

  function getLanguageInfo (key)
  {
    object_array  = languages.filter (function( obj ) { return (obj.lang_code === key) ; });
    language_info = object_array [0] ;
    return language_info ;
  }

  function getRegionInfo (key) // was getBubbleInfo but bubbles and language should be read seprately soon
  {
    object_array  = bubbles.filter (function( obj ) { return (obj.region_code === key) ; });
    bubble_info = object_array [0] ;
    return bubble_info ;
  }

  function updSelectionLanguages ()
  {
    console.log ('updSelectionLanguages') ;
  }

  function updSelectionRegions ()
  {
    console.log ('updSelectionRegions') ;
  }


// variation on plugin by Max Rosen to have the legend vertically
// see https://ourworldindata.org/wp-content/uploads/datamaps/readFromCSV_autobucket_switchByButtons_infantmortality_longrun/readFromCSV_autobucket_switchByButtons_infantmortality_longrun.html

  function addCustomLegend (layer, data, options) 
  {
    data = data || {};
  
    if ( ! this.options.fills ) 
    { return ; }

    var html  = '' ; // build html for definition list
    var html2 = '' ; // build altarnative html for small screens (all in one row)
    var label = '' ;
    var title = '' ;
    var textcolor = '#000' ;
    var colors = 0 ;
 
    if (( data.legendTitle ) && (h > 820)) // on small window this text interferes with hovering, no hover even on countries in the south 
    {  title = "<b>" + data.legendTitle + "</b><br>" ; } // legend title somewhat redundant, as page title tell similar story
    
    for ( var fillKey in this.options.fills ) 
    {
      if ( fillKey === 'defaultFill') 
      {
        if (! data.defaultFillName) { continue; }
        label = data.defaultFillName;
      } 
      else 
      {
        if (data.labels && data.labels[fillKey]) 
        { label = data.labels[fillKey]; } 
        else 
        {
          // label= '' + fillKey; // changed by Max
          label= '' + legend_labels [fillKey] ;  
          if (label == 'undefined')
          { continue ; }
        }

        if (html !== '')
        { html = '<br>' + html ; }

        html = '&nbsp;<dd style="background-color:' +  this.options.fills[fillKey] + '">&nbsp;</dd><dt>' + label + '</dt>&nbsp;'+ html ;

        // set contrasting text color (hmm Q&D could be generalized better)
        colors++ ; // counts color blocks displayed in legend
        if (mode_show_regions)
        { textcolor = (colors > 5 || colors <= 2) ? '#000' : '#CCC' ; }
        if (mode_show_languages)
        { textcolor = (colors > 6 || colors <= 1) ? '#000' : '#CCC' ; }
  
        html2 = '&nbsp;<span style="background-color:' +  this.options.fills[fillKey] + ';color:' + textcolor + '">' + label + '</span>\n' + html2 ;
      }
    }

    html = "<dl style='background-color:#FFF'>" + title + "<br>" + html + "<br>&nbsp;</dl>" ;
    html2 = html2.replace (/<font.*?>/g,'').replace (/<\/font>/g,'') ;

    if (h < 850) // show legend in one row
    { document.getElementById ('legend').innerHTML = html2 ; }
    else // show legend in block
    {
      var hoverover = d3.select( this.options.element ).append('div')
      .attr('class', 'datamaps-legend')
      .html(html);
    }
  }

  worldmap.addPlugin ("mylegend", addCustomLegend);
  worldmap.mylegend  ({legendTitle:"Default legend"}) ;

  function setTitleLanguage (language_on_display) 
  { 
    if (language_on_display == 'X')
    { 
      console.log ('language_on_display not yet known -> X') ;
      return ; 
    }
    var segments = language_on_display.split (':') ;
    var text_title_languages2 = text_title_languages.replace ('xxx', segments [0]).replace ('yyy',segments [1].replace ('Wikipedia','')) ;
    setTitle (text_title_languages2) ; 
  } 


  function resetZoom() // does not work well 
  {
  //  if (! (mymap === undefined))
  //  { mymap.svg.selectAll("g").attr("transform", "translate(0,0)scale(1.0)"); }
  }

  function ucfirst(string) 
  { return string.charAt(0).toUpperCase() + string.slice(1); }

//**********************************************************************************************
// build hover box for country info (two display modes: synopsis or list of languages)
//**********************************************************************************************

  function prepHoverBoxCountries (geo,csv_countries)
  {
    // makes sure that the tooltip is shown only if there is data 
    if (files_read.length < 4)
    {
      showStatus ('Not all data read yet. Data read ' + files_read.join ()) ;  
      return ('') ;
    }

    flag_icon = getFlagIcon (geo.properties.iso) ;

    // mark language on display in info box (which contains html built once, so zap copy
    breakdown_per_language2 = csv_countries.breakdown_per_language ;

    if (mode_show_languages)
    {
      language = language_on_display.replace (/ Wikipedia/,"").replace (/.*?: /,"") ; // drop Wp and rank number (e.g. '#1:')
      breakdown_per_language2 = breakdown_per_language2.replace (language, "<font color=red><b>" + language + "</b></font>") ;
    }

    // mark views per person, 
    views_per_person2 = csv_countries.views_per_person ; 
    if (mode_show_regions)
    { views_per_person2 = "<font color=red>" + views_per_person2 + "</font>" ; }

    var table_details_languages = '' ;
    var line_header_views = '' ;
    if (mode_show_languages)
    { 
      table_details_languages = 
        "<hr><table align='center'>" +
        header_countries +  
        breakdown_per_language2 +
    //  "<tr><td class=lnb colspan=99><font color=#888><hr width='100%'><small>Data for " + data_month + "<small></font></td></tr>" + 
        "</table>" ; 
    }
    if (mode_show_regions)
    {
      line_header_views = 
        "<br>" + icon_views + " " + csv_countries.total_views + sp2 + '=' + sp2 + 
        csv_countries.total_views_as_perc_of_world_views + "% of " +
        icon_world + 
        sp2 + '=' + sp2 + views_per_person2 + " per" + icon_person + 
        "</font>" ; 
    }

  shift_left = positionLeftPopupCountries (geo.properties.iso) ;
  shift_top  = positionTopPopupCountries  (geo.properties.iso) ;

  info = "<div class='hoverinfo' align=left style='white-space:nowrap; left:" + shift_left + "px; top:" + shift_top + "px ; right: 20px ; " + 
           "white-space: nowrap ; background-color: #FFF; box-shadow: 2px 2px 5px #CCC; " + 
           "font-size: 12px; border: 3px solid " + colorDataBoxCountry + "; padding: 5px'>" +
           flag_icon + "&nbsp;<strong>country <font color=" + colorDataBoxCountry + ">" + shortenCountryName (geo.properties.name) + "</font></strong>" + sp2 + '<br>' + 
       //  (w < 800?'<br>':'') + 
           icon_people + " " + csv_countries.population + sp2 + 
       //  geo.properties.iso + sp2 + // only for begugging show ISO code
           '(' + csv_countries.perc_people_connected + icon_connected + ')' +

           line_header_views +

           table_details_languages +
           "</div>" ;

    info = info.replace (/\^/g,'&nbsp;') ; // decompress = restore non-breaking blanks

    return (info) ;
  } ;

  function SetSelectedBoxLanguage (lang_code) 
  {  
    list_select_box_languages = list_select_box_languages.replace (" selected='selected'>",">") ;  
    list_select_box_languages = list_select_box_languages.replace ("<option value='" + lang_code + "'>", "<option value='" + lang_code + "' selected='selected'>") ;  
    SetSelectBoxLanguages (list_select_box_languages, normal) ;
//    document.getElementById ('select_box_languages').style.visibility = 'visible' ; 
    SetSelectBoxRegions ('', hidden) ;
//    document.getElementById ('select_box_regions')  .style.visibility = 'hidden' ; 
  }

  function SetSelectedBoxRegion (region_code) 
  {  
    list_select_box_regions = list_select_box_regions.replace (" selected='selected'>",">") ;  
    list_select_box_regions = list_select_box_regions.replace ("<option value='" + region_code + "'>", "<option value='" + region_code + "' selected='selected'>") ; 
    SetSelectBoxLanguages ('', hidden) ;
    SetSelectBoxRegions   (list_select_box_regions, normal) ;
    document.getElementById ('select_box_regions')  .style.visibility = 'visible' ; 
    document.getElementById ('select_box_languages').style.visibility = 'hidden' ; 
  }

  function SetButtonSwitchMode (text, visibility)
  {
    elem = document.getElementById (btn_switch_mode) ;
    elem.innerHTML = text ;
//  console.log ('SetButtonSwitchMode ' + visibility ) ;
    elementSetVisibility (elem, visibility) ;
  }

  function SetButtonTableDialogLanguages (text, visibility)
  {
    elem = document.getElementById (btn_show_table_dialog_languages) ; 
    elem.innerHTML = text ;
//  console.log ('SetButtonTableDialogLanguages ' + visibility) ;
    elementSetVisibility (elem, visibility) ;
  }

  function SetButtonTableDialogRegions (text, visibility)
  {
    elem = document.getElementById (btn_show_table_dialog_regions) ; 
    elem.innerHTML = text ;
//  console.log ('SetButtonTableDialogRegions ' + visibility) ;
    elementSetVisibility (elem, visibility) ;
  }

  function SetSelectBoxLanguages (text, visibility)
  {
    elem = document.getElementById (select_box_languages) ; 
    if (text !== '') 
    { elem.innerHTML = text ; }
//  console.log ('SetSelectBoxLanguages ' + visibility) ;
    elementSetVisibility (elem, visibility) ;
  }

  function SetSelectBoxRegions (text, visibility)
  {
    elem = document.getElementById (select_box_regions) ;
    if (text !== '') 
    { elem.innerHTML = text ; }
//  console.log ('SetSelectBoxRegions ' + visibility) ;
    elementSetVisibility (elem, visibility) ;
  }

  function SetButtonShowLegend (visibility)
  {
    elem = document.getElementById (btn_show_legend) ;
    elementSetVisibility (elem, visibility) ;
  }

  function SetButtonShowAbout (visibility)
  {
    elem = document.getElementById (btn_show_about) ;
    elementSetVisibility (elem, visibility) ;
  }

  function elementSetVisibility (elem, visibility)
  {
//  console.log ('elementSetVisibility ' + visibility) ;

    if (visibility == hidden)
    { elem.style.visibility = 'hidden' ; }
    else
    { elem.style.visibility = 'visible' ; } 

    if (visibility == grayed)
    { elem.style.color = color_text_grayed ; }
    else
    { elem.style.color = color_text_normal ; }
  }

  function switchLanguage (language)
  {
console.log ('') ;
console.log ('switchLanguage ' + language) ;

    data = getLanguageInfo (language) ;
    if (data === undefined)
    {
      alert ("No data found for language code '" + language + "' -> list of countries cannot be shown.") ;
      return ;
    } 

    language_selected = language ;
    language_name = data.name.replace (/.*:/,'') ;
  //  language_on_display = data.name ;
    language_on_display = language ;

    SetTextBreakdownLanguageByCountry (language_name) ;
    SetButtonTableDialogLanguages (text_show_table_dialog_languages, normal) ; 
    colorMapViewsPerPerson (data.viewfreq_per_country) ; 
}

//**********************************************************************************************
// create modal dialog for language
//**********************************************************************************************
   
  function showTableDialogLanguages (language)
  {
    if (! mode_show_languages) { return ; }

console.log ('') ;
console.log ('showTableDialogLanguages ' + language) ;

    data = getLanguageInfo (language) ;
    if (data === undefined)
    {
      alert ("No data found for language code '" + language + "' -> list of countries cannot be shown.") ;
      return ;
    } 

    language_selected = language ;
    language_name = data.name.replace (/.*:/,'') ;
  //  language_on_display = data.name ;
    language_on_display = language ;

    colorMapViewsPerPerson (data.viewfreq_per_country) ; 

    SetTextBreakdownLanguageByCountry (language_name) ;
    SetButtonTableDialogLanguages (text_show_table_dialog_languages, grayed) ;
    SetButtonSwitchMode (text_switch_mode_to_regions, grayed) ; 
    SetSelectedBoxLanguage (data.lang_code) ;  

    // show infobox -> hide 'Show list' button 
    // the 'Hide list' version of the button is not even clickable while the modal dialog is there (and hiding the dialog can happen in several ways)
    d3.select(".infobox")  .style("display", "block") ;	

    console.log ('showTableDialogLanguages 1') ;
    if (! mode_show_languages)
    { 
//      language_on_display = data.name ;  
 //     colorMapViewsPerPerson (data.viewfreq_per_country) ;
  //    // showMode () ; // update title 
  //    return ;  
    }

    header_languages2 = header_languages.replace (/xxx/g, language_name) ; 

    setTitleLanguage (language_on_display) ;
    if (! show_language_list) 
    { 
      SetButtonTableDialogLanguages (text_show_table_dialog_languages, normal) ;
      SetButtonSwitchMode (text_switch_mode_to_regions, normal) ; 
      // return ; 
    }

    console.log ('showTableDialogLanguages 2') ;
    modal.style.display = "block"; 
  
    info = 
         "<div class='hoverinfo' align=left " + 
                 
         "style='z-index:1001 ; position:absolute ; width:400px; top: 70px ; left: 150px; white-space: nowrap ; background-color: #FFF; " + // width:400px 
         "box-shadow: 2px 2px 5px #CCC; font-size: 12px; border: 3px solid " + colorDataBoxLanguage + "; padding: 5px'>" +
         "<span style='z-index:0; position:absolute; top:3px; right:3px; background-color:#DDD; border-style:outset' class='close' onclick='closeDialog()'><b>&nbsp;X&nbsp;</b></span>" +


         "&nbsp;<strong>language<font color=" + colorDataBoxLanguage + "> " + data.name + "</font></strong>" + sp2 + 
         icon_speakers + sp + data.population + sp2 + '(' + data.perc_population + ')<br>' + // " of " + icon_world + ')<br>' + 
         icon_views + sp + "<sub></sub> " + data.requests + sp2 + '=' + sp2 + 
         "x%" + // data.perc_share_total + 
         " of " + icon_world + sp2 + '=' + sp2 + 
         "y " + // data.requests_per_connected_person + 
         " per" + icon_person + 
         "<hr>" + 

         "<table align='center'>" +
         header_languages2 +
         data.breakdown_by_language + 
     //  "<tr><td class=lnb colspan=99><font color=#888><hr width='100%'><small>Data for " + data_month + "<small></font></td></tr>" + 
        "</table></div>";

    info = info.replace (/\^/g,'&nbsp;') ; // decompress = restore non-breaking blanks

    myelement = document.getElementById("modal-infobox") ;
    myelement.innerHTML = info ;
 
    /* version to add html as static element, kept for reference, and as fallback 
    var svg = d3.select("p").append("svg")
      .attr("width", 960)
      .attr("height", 500);

    svg.append("foreignObject")
      .attr("width", 480)
      .attr("height", 500)
    .append("xhtml:body")
      .style("font", "14px 'Helvetica Neue'")
      .html(info) ;
    */

    console.log ('showTableDialogLanguages 3') ;
  }

//**********************************************************************************************
// create modal dialog for regions
//**********************************************************************************************
   
  function showTableDialogRegions (region)
  {
    if (! mode_show_regions) { return ; }

console.log ('') ;
console.log ('showTableDialogRegions') ;
    region_selected = region ;
    SetTextBreakdownRegionByCountry (region_name) ;

    SetButtonSwitchMode  (text_switch_mode_to_languages,    grayed) ; 
    SetButtonTableDialogRegions (text_show_table_dialog_regions, grayed) ;

    data = getRegionInfo (region) ;
    if (data === undefined)
    {
      alert ("No data found for region code '" + region + "' -> list of countries cannot be shown.") ;
      SetButtonTableDialogRegions (text_show_table_dialog_regions, normal) ; 
      return ;
    }
     
    SetSelectedBoxRegion (region) ;

    region_on_display = data.name ;
    region_name = region ;

    d3.select(".infobox").style("display", "block") ;	

//  colorMapViewsPerPerson (data.viewfreq_per_country) ;

    modal.style.display = "block"; 
  
    header_regions2 = header_regions.replace (/xxx/,'(entire region:' + data.perc_share_total + ')') ;     
    if (data.name == 'World')
    { header_regions2 = header_regions2.replace (/this region/,'anywhere in the world') ; }
    else
    { header_regions2 = header_regions2.replace (/this region/,data.name) ; }

    info = 
         "<div class='hoverinfo' align=left " + 
                 
         // overflow:clipped?
         "style='z-index:1001 ; position: relative ; width:420px; top: 70px ; left: 150px; white-space: nowrap ; background-color: #FFF; " +  
         "box-shadow: 2px 2px 5px #CCC; font-size: 12px; border: 3px solid " + colorDataBoxRegion + "; padding: 5px'>" +
         "<span style='z-index:0; position:absolute; top:3px; right:3px; background-color:#DDD; border-style:outset' class='close' onclick='closeDialog()'><b>&nbsp;X&nbsp;</b></span>" +

         "&nbsp;<strong>region" + 
         "<font color=" + colorDataBoxRegion + "> " + data.name + "</font></strong>" + sp2 + 
         icon_speakers + sp + data.population + sp2 + '(' + data.perc_population + ')<br>' + // " of " + icon_world + ')<br>' + 
         icon_views + sp + "<sub></sub> " + data.requests + sp2 + '=' + sp2 + 
         data.perc_share_total + 
         " of " + icon_world + sp2 + 
      // '=' + sp2 + 
      // "y " + // data.requests_per_connected_person + 
      // " per" + icon_person + 
         "<hr>" + 

         "<table align='center' width='100%'>" +
         header_regions2+
         data.breakdown_by_country + 
      // "<tr><td class=lnb colspan=99><font color=#888><hr width='100%'><small>Data for " + data_month + "<small></font></td></tr>" + 
        "</table></div>";

    info = info.replace (/\^/g,'&nbsp;') ; // decompress = restore non-breaking blanks

    myelement = document.getElementById("modal-infobox") ;
    myelement.innerHTML = info ;
  }

function shortenCountryName (name)
{
  name = name.replace (/Bosnia and Herzegovina/, 'Bosnia') ;
  name = name.replace (/Venezuela, Bolivarian Republic of/, 'Venezuela') ;
  name = name.replace (/Bolivia, Plurinational State of/, 'Bolivia') ;
  name = name.replace (/Tanzania, United Republic of/, 'Tanzania') ;
  name = name.replace (/Congo, the Democratic Republic of the/, 'Dem. Rep. Congo') ;
  name = name.replace (/Republic/, 'Rep.') ;
  return (name) ;
}

function addLinkAndShortenCountryName (name)
{
  name_org = name ;
  name = shortenCountryName (name) ;
  link = "<a href='http://en.wikipedia.org/wiki/" + name_org + "' target='_blank'>" + name + "</a>" ;
  return (link) ; 
}

function positionLeftPopupCountries (isocode) 
{
  // AFG Aghanistan
  // AUS Australia
  // BGD Bangladesh
  // BTN Bhutan
  // CHN China
  // FJI Fiji
  // GUM Guam
  // IDN Indonesia
  // IND India
  // JPN Japan
  // KHM Cambodja
  // KOR Korea
  // LAO Laos People's Dem Rep
  // LKA Sri Lanka
  // MMR Myanmar
  // MNG Mongolia
  // MYS Malaysia
  // NPL Nepal
  // NZL New Zealand 
  // PAK Pakistan
  // PHL Philipinness
  // PNG Papua New Guinea
  // RUS Russia  
  // SLB Solomon Islands
  // TWN Taiwan
  // VUT Vanuatu
  
  // position hoverbox so that it stays within border of map
  // I couldn't determine mouse position or latitude
  // so hoverbox shifts on basis of country code (is a bit crude on really tiny maps)

  shift_left = -100 ;
  if (isocode.match (/^(AFG|AUS|BGD|BTN|CHN|FJI|GUM|IDN|IND|JPN|KHM|KOR|LAO|LKA|MMR|MNG|MYS|NPL|NZL|PAK|PHL|PNG|RUS|SLB|TWN|VUT)$/))
  { shift_left = -350 ; }
  else 
  {
    if (isocode.match (/^(CAN|USA|WSM)$/))
    { shift_left = 0 ; } // only countries close to west border of map: Canada, USA, Samoa
  }

  return (shift_left) ;
}

function positionTopPopupCountries (isocode) 
{
  shift_top = 20 ;

  if (h < 500)
  { shift_top = -20 ; }

  return (shift_top) ;
}

function showLegend ()
{
  window.open ('legend.html','_blank','location=no,height=400,width=800,scrollbars=yes,status=no') ;
}

function showAbout ()
{
  window.open ('about.html','_blank','location=no,height=400,width=800,scrollbars=yes,status=no') ;
}

function iOSVersion() 
{
  if (window.MSStream)
  {
    // There is some iOS in Windows Phone...
    // https://msdn.microsoft.com/en-us/library/hh869301(v=vs.85).aspx
    return false;
  }

  var match = (navigator.appVersion).match(/OS (\d+)_(\d+)_?(\d+)?/), version;

  if (match !== undefined && match !== null) 
  {
    version = [parseInt(match[1], 10),
               parseInt(match[2], 10),
               parseInt(match[3] || 0, 10)];
    return parseFloat(version.join('.'));
  }

  return false;
}
