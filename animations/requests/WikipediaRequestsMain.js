/*

menu e.d. fixed size, not blow up on zoom
edits[e] is undefined line 1474

Author Erik Zachte - February to May 2011
License covered by Creative Commons Attribution 3.0
See for full coverage of the license: http://creativecommons.org/licenses/by-sa/3.0/
Essentially you are allowed to copy, distribute, transmit and adapt this work, under the following condition:
You must attribute the work to me, by mentioning my name and website (http://infodisiac.com)

Maps used
- 3000px-Whole_world_land_and_oceans.jpg  file http://commons.wikimedia.org/wiki/File:Whole_world_-_land_and_oceans.jpg (NASA)
- 3000px-Whole_world_borders_map.png      data http://thematicmapping.org/downloads/world_borders.php
  1500px-Whole_world_borders_map.png      rendered with https://github.com/RandomEtc/shapefile-js via index.html  

To be used: http://en.wikipedia.org/wiki/Population_density

Ideas for improvement:

- extend mouse interface
- more feedback on available/active options 
- heatmap : use log scale for luminance / use max lum. for 95th percentile (now one unfiltered bot can wreck scale)
- barchart for edits per language per hour below image 
- make overview per language also available for languages beyond top 20

- realtime data feed 
- dynamically load js (for 2+Mb data file) see http://www.javascriptkit.com/javatutors/loadjavascriptcss.shtml
- paint svg on canvas (is that possible ?) see http://code.google.com/p/canvg/

- sample colors SEDAC map colors -> raw pop counts, make map with views per million people

- icons for zoom box (currently disabled)
  http://commons.wikimedia.org/wiki/File:Nuvola_action_edit_add.svg
  http://commons.wikimedia.org/wiki/File:Nuvola_action_edit_remove.svg

Script notes:
  
- The animation and maps were implemented in html5, using the canvas object. 
  Most challenging were zoom and pan options, where legend and title should stay locked in place. 
  I did not find a ready-made html5 solution for stacked layers with variable scaling, 
  so instead I built routines which on zoom and pan translate and scale in a such way that when 
  the 2D context changes in size and position these elements stay in place. 
- html5 canvas measureText only provides width, not height (although pixel size of font is aproximation) 
  instead of putting a blank box behind a text to make it stand out from background 
  here the same text can be printed first in any color with slight x/y shifts in all four directions 
- For high res country borders I also chose prendered bitmaps.
  Maybe OpenLayers can do this on the fly, but presumably with considerable speed premium,
  and their documentation style is not my cup of tea. 
- If someone knows how to paint an svg on html5 canvas, that might open new possibilities.   
- Too many hard coded small tweaks to get all UI elements fit on variable size screen


  
Performance
- Tested on Windows 7 
  Running animation simultaneously on 3 browsers:
  MSIE 9.08 543kB, Firefox 4.01 633kB, Chrome 11.0 232kB     
  MSIE 9.08 25% cpu, Firefox 4.01 10% cpu, Chrome 11.0 12% cpu
  Chrome used half the memory other browsers used
  MSIE used more than twice cpu power than other browsers
*/

  var show_date = '29 July 2011' ; // to do , get from data file 
  
  var VERSION       = '0.8' ;
  var iPad   = navigator.userAgent.match(/iPad/i) != null;
  var iPod   = navigator.userAgent.match(/iPod/i) != null;
  var iPhone = navigator.userAgent.match(/iPhone/i) != null;
  
  var img_plus  = new Image(); img_plus.src  = '40px-Nuvola_action_edit_add.svg.png';
  var img_minus = new Image(); img_minus.src = '40px-Nuvola_action_edit_remove.svg.png';

  var setup_phase   = 0 ;

  var resolution    = 8 ; // round latitude and longitude for heat maps to 1/resolution degree, (animation always use 1/2 degree to protect against de-anonimization)
  
  if (resolution == 8) { var views_per_cell_high = 150 ; var views_per_cell_inc = 15 } 
  if (resolution == 4) { var views_per_cell_high = 600 ; var views_per_cell_inc = 50 } 
  if (resolution == 2) { var views_per_cell_high = 2400 ; var views_per_cell_inc =  200 } 
  
  var square_kilometers_per_cell_equator = Math.pow (40000 / (360 * resolution), 2) ; // cell area near equator , e.g. 0.5 degree squared -> (40000 / 360 * 2) km squared = 55 km * 55 km = 3086 sq km
  
  var INTERVAL      = 50 ;
  var INTERVAL_LONG = 50 ;
  var PI2           = Math.PI * 2 ;
  var SEC_IN_DAY    = 24 * 3600 ;
  var MIN_IN_DAY    = 24 * 60 ;
  var COLOR         = 1 ;
  var B_W           = 0 ;

  var MIN_CANVAS_WIDTH_MENU_TOP_LEFT = 600 ;
       
  var cycles        = 0 ;  
  var clock         = 0 ; 
  var clock_prev    = 0 ; 
  var clock_delta   = 1 ; 
  var interval      = INTERVAL ; 
  var now ;

  var frames_shown         = -1 ;
  var time_first_frame     = -1 ;
  var time_prev_cs         = 0 ;
  var time_align_map       = 0 ;
  var time_check_align_map = 0 ;
  var alignment_map_busy   = 0 ;
  var msecs_per_frame      = 0 ;
  var frames_per_sec       = 0 ;
  var speed_up_measured    = 0 ;
  var speed_up_desired     = 5 ;
  var maps_drawn           = 0 ;
  var lengthy_operations   = 0 ;
    
  var ctx ;   // canvas context
  var imgmap    = new Image();
  var imgmapBW  = new Image();
  var imgmapBWs = new Image(); // small
  var imgmapPD  = new Image(); // population density 
//var imgmapCC  = new Image(); // country colors


  var canvas_resized      = 0 ;
  var canvas_width        = 0 ; 
  var canvas_height       = 0 ; 
  var canvas_width_half   = 0 ; // canvas width  / 2
  var canvas_width_third  = 0 ; // canvas width  / 2
  var canvas_height_half  = 0 ; // canvas height / 3
  var canvas_height_third = 0 ; // canvas height / 3

  var cx0 =    0 ;
  var cy0 =    0 ;
  var viewport_width       = 0 ;
  var viewport_height      = 0 ;
  var viewport_width_prev  = 0 ;
  var viewport_height_prev = 0 ;
  var viewport_margin      = 18 ; // somehow there is a top and left margin outside canvas than I can't get go away, so make even spaced margin around image
  var image_size_auto      = 1 ;
  var fixed_image_widths = new Array(600,700,800,900,1000,1150,1300,1450,1600,1800,2000,2200,2400,2600,2800,3000) ;
  var delta_x_tot        = 0 ;
  var delta_y_tot        = 0 ;
  var delta_x_tot_prev   = 0 ;
  var delta_y_tot_prev   = 0 ;
  var delta_x_tot_phase1 = 0 ;
  var delta_y_tot_phase1 = 0 ;
  var pixel_color ;
  var perc_center_x      = 0 ;
  var perc_center_y      = 0 ;
      
  var show_mode         = 1 ;
  var show_animation    = 1 ;
  var show_distrib      = 2 ;
  var show_heatmap      = 3 ;
  var show_views        = 4 ;
  var show_perc_mobile  = 5 ;

  var show_edits        = 3 ;  
  if (iPad || iPod || iPhone)
  { show_edits = 1 ; }

  var show_debug        = 0 ;
  var show_one_language = 0 ;
  var show_cities       = 0 ;
  var show_sun          = 1 ;
  var show_help         = 0 ;
  var show_clocks       = 1 ;
  var jump_forward      = 0 ;
  var do_pause          = 0 ;

  var show_pop_not      = 0 ;
  var show_pop_right    = 1 ;
  var show_pop_left     = 2 ;
  var show_pop_full     = 3 ;
  var show_pop_density  = show_pop_not ;
  
  var parms = [] ;

  var mouse_text_prev = '' ;
  
  var dragging         = false ;
  var mouse_down       = false ;
  var mouse_in         = false ;
  var mouse_pos_x      = 0 ;
  var mouse_pos_y      = 0 ;
  var mouse_imgmap_x   = 0 ;
  var mouse_imgmap_y   = 0 ;
  var mouse_box_in_map = 0 ;
  var mouse_box_bx     = 0 ;
  var mouse_box_by     = 0 ;
  var mouse_box_bw     = 0 ;
  var mouse_box_bh     = 0 ;
  var mouse_box_tx     = 0 ;
  var mouse_box_ty     = 0 ;
  var mouse_box_lat    = '' ;
  var mouse_box_long   = '' ;
  var mouse_box_left   = false ;

  var button_plus = {x:0,y:0,w:0,h:0} ;
  var button_min  = {x:0,y:0,w:0,h:0} ;
  
  var TRANSPARENCY_FILL = 0.6 ;  
  var TRANSPARENCY_LINE = 1.0 ;  

  var TRANSPARENCY_FILL_DISTRIB = 0.5 ;  
  var TRANSPARENCY_LINE_DISTRIB = 1.0 ;  
  
  var SATURATION_11_20 = 50 ;
  var imgmap_transparency = 0.15 ;  
  var font_type = "Arial" ;
  var text_border_color = '' ;
  var show_text_border = false ;
  var ctx_font_unscaled = 1 ;
  var pixels_per_degree = 1 ;
  var images_loaded = 0 ;
  var help_color = 0 ;
  var longitude = 0 ;
  var latitude = 0 ;

  var edits_in    = [] ;
  var edits_temp  = [] ;
  var freq_in     = [] ; 
  var viewstats_in = [] ; 
  var edits       = [] ; 
  var frequencies = [] ; 
  var viewstats   = [] ; 
  var cities      = [] ; 
  var coord       = [] ; 
  var max_count   = [] ; 
  var max_count_trace   = [] ; 
  var tot_count   = [] ; 
  var heatmap     = [] ;
  var colors      = [] ;
  var hues        = [] ;
  var languages   = [] ;
  var langcodes   = [] ;
  var langindex   = [] ;
  var color_map   = [] ;
  var coords      = [] ;
  
  color_map [show_animation]   = B_W ;
  color_map [show_distrib]     = B_W ;
  color_map [show_heatmap]     = B_W ;
  color_map [show_views]       = B_W ;
  color_map [show_perc_mobile] = B_W ;
  
  var tot_languages = 0 ;
  var tot_edits = 0 ;
  var tot_views = 0 ;
  var tot_views_mobile = 0 ;
  var tot_frequencies = 0 ;
  var tot_viewstats = 0 ;
  var tot_cities = 0 ;
  var color_max = 20 ;
  
  var zoom_factors   = new Array ;
  var zoom_factor    = 1 ;
  var zoom_level     = 0 ;
  var zoom_level_max = 0 ;
  var factor_grid    = 4 ;
  var show_chrome_msg = 0 ;
  
  while (true)
  { 
    if (zoom_factor > 5) 
    { zoom_factor = 5 ; }
    
    zoom_factors [zoom_level] = zoom_factor ;
    zoom_level_max = zoom_level ;
    
    if (zoom_factor >= 5) break ;
    
    if (zoom_factor == 1)
    { zoom_factor = 1.1 ; }
    else
    { zoom_factor *= 1.2 ; }
    zoom_level ++ ;
  }  
  zoom_factor  = 1 ;
  zoom_level   = 0 ;
  

  var notice_text     = '' ; // message text
  var notice_added    = 0 ; // timestamp
  var notice_duration = 0 ; // msecs

  var alerts  = 0 ; // test
  var resized = 0 ;
  var events_drawn = 0 ;
  var events_drawn_trend = 0 ;
  var edits_shown = 0 ;

  var first_event_to_show = 0 ;
  var last_event_to_show  = 1 ;
  var radius_max = 7 ;
  var radius_min = radius_max / 4 ;
  var radius_city = 4 ;
  var fade_factor = 0.8 ;
  
  var sun_width = 20 ;
  var sun_height = 3 ;
  
  var show_cities_white = 1 ;
  var language_selected = 'rest' ; 

  var mouse_drawn = 0 ;
  var mouse_text_prev = '' ;
  
  var totals = [] ;
  totals ['en'] = new Array (1440) ; 
  
  var mousewheelevt=(/Firefox/i.test(navigator.userAgent))? "DOMMouseScroll" : "mousewheel" //FF doesn't recognize mousewheel as of FF3.x
  var key = '' ;
 
function chk (x)
{
   if (alerts ++ < 10) // prevent endless loops
   { alert (x) ; }
}

function eventPageLoaded (imagefile1,imagefile2,imagefile3,imagefile4) 
{
  data_init () ;
  
  document.body.style.overflow = 'hidden';

  imgmap  .onload = eventImagesLoaded ;
  imgmap  .src    = imagefile1 ; // "3000px-Whole_world_-_land_and_oceans.jpg" ;       NASA
  imgmapBW.src    = imagefile2 ; // "3000px-Whole_world_borders_map.jpg" ;             data http://thematicmapping.org/downloads/world_borders.php, rendered with https://github.com/RandomEtc/shapefile-js via index.html
  imgmapBWs.src   = imagefile3 ; // "1500px-Whole_world_borders_map.jpg" ;             data same 
  imgmapPD.src    = imagefile4 ; // "3000px-Whole_world_population_density-2010.jpg" ; http://beta.sedac.ciesin.columbia.edu/maps/client 
  
  canvas = document.getElementById("cv");
  canvas.style.border = "black 1px solid" ;    

  if (canvas.attachEvent) //if IE (and Opera depending on user setting)
  { canvas.attachEvent("on"+mousewheelevt, eventMouseWheel) }
  else 
  if (canvas.addEventListener) //WC3 browsers
  {  canvas.addEventListener(mousewheelevt, eventMouseWheel, false) }

  ctx    = canvas.getContext("2d");
  
  if (! ctx.measureText)
  { 
    document.write 
    ("<center><h2>Wikipedia page edits</h2>" +
     "<p><b><font color=#800000>Animation can not be shown.</font></b><p>" + 
     "The animation shows a distribution in time and space of<br> over 400,000 manual edits from a random day in February 2011<p>" + 
     "Apparently your browser version does not support html5 yet,<br>or maybe you chose to disable execution of javascript.<p>" +
     "Apologies for the inconvenience.<p>Erik Zachte" +  
     "</center>") ; 
  }  
  
  if (document.addEventListener) 
  { document.getElementById("cv").addEventListener("mousemove",eventMouseMoveInImage, false); } 
  
}

function eventImagesLoaded()
{
//settingsRead () ;
  calcPageSize () ; // do this only on OnLoad OnResize ? 
  imagePrep    () ;
  setTimeout (prepData, interval); 
}

function eventKeyPressed (e)
{
  var input = document.getElementById("input");
  // document.getElementById("input").value = 'x' ;
  
  var evtobj    = window.event ? event : e ; //distinguish between IE's explicit event object (window.event) and Firefox's implicit. (not tested yet, copied this line from web)
  var unicode   = evtobj.charCode? evtobj.charCode : evtobj.keyCode ;
  key = String.fromCharCode (unicode) ;

  if (setup_phase == 3) // waiting for choice on initial screen
  { 
    if (key in { 'l':1, 'L':1 })      
    {
      color_map [show_mode] = B_W ; 
      show_edits  = 3 ;
      setup_phase = 4 ; 
      notice_added = 0 ; 
      notice_text = '' ;
      key = '' ;
      return ; 
    }  
    else if (key in { 'r':1, 'R':1 })      
    {
      color_map [show_mode] = COLOR ; 
      show_edits  = 1 ;
      setup_phase = 4 ; 
      notice_added = 0 ; 
      notice_text = '' ;
      key = '' ;
      return ; 
    }  
    else if (key in { '@':1 })  
    { show_debug      = ! show_debug ; }
    else 
    {
      key = '' ;
      return ;
    }  
  }

        if (key in { '1':1 })         { if (show_mode != show_animation) 
                                       { 
                                          show_mode = show_animation ; 
                                          imgmap_transparency = 0.30 ; 
                                          show_one_language = 0 ; 
                                          resetAnimation () ;
                                       }
                                     }  
  else if (key in { '2':1 })         { if (show_mode != show_distrib)   
                                       { 
                                         show_mode = show_distrib ;   
                                         imgmap_transparency = 0.15 ; 
                                         if (show_one_language == 0)
                                         {
                                           show_one_language = 1 ; 
                                           language_selected = 'en' ; 
                                         }  
                                       }
                                     }
  else if (key in { '3':1 })         { 
                                       if (show_mode != show_heatmap)   
                                       { 
                                         show_mode = show_heatmap ;   
                                         imgmap_transparency = 0.80 ; 
                                         if (show_one_language == 0)
                                         {
                                           show_one_language = 1 ; 
                                           language_selected = 'en' ; 
                                         }  
                                       }
                                     }
  else if (key in { '4':1 })         { 
                                       if (show_mode != show_views)   
                                       { 
                                         show_mode = show_views ;   
                                         imgmap_transparency = 0.80 ; 
                                       }
                                     }
  else if (key in { '5':1 })         { 
                                       if (show_mode != show_perc_mobile)   
                                       { 
                                         show_mode = show_perc_mobile ;   
                                         imgmap_transparency = 0.80 ; 
                                       }
                                     }

  else if (key in { 'a':1, 'A':1 })  { alerts = -1 ; }
  else if (key in { 'b':1, 'B':1 })  { imgmap_transparency = imgmap_transparency <= 0.80 ? imgmap_transparency + 0.15 : 0 ; }
//else if (key in { 'c':1, 'C':1 })  { show_cities     = canvas_width < 2200 ? (show_cities + 1) % 2 : (show_cities + 1) % 3 ; }
  else if (key in { 'c':1, 'C':1 })  { show_cities     = (show_cities + 1) % 2 ; }
  else if (key in { 'd':1, 'D':1 })  { show_pop_density = (show_pop_density + 1) % 4 ; 
                                       if ((zoom_factor > 2) && (show_pop_density > show_pop_not)) 
                                       { show_pop_density = show_pop_full ; }
                                     }
  else if (key in { 'e':1, 'E':1 })  { show_edits < 3 ? show_edits +=1 : show_edits = 1 ; } 
  else if (key in { 'f':1, 'F':1 })  { jump_forward    = 1 ; }
  else if (key in { 'g':1, 'G':1 })  { factor_grid *= 1.5 ; if (factor_grid > 10) { factor_grid = 2 ; } }  
  else if (key in { 'h':1, 'H':1 })  { show_help  = ! show_help ; }
  else if (key in { 'l':1, 'L':1 })  { show_help  = false ; }
  else if (key in { 'm':1, 'M':1 })  { 
                                       if (show_mode < show_heatmap)   
                                       { color_map [show_mode] == B_W ? color_map [show_mode] = COLOR : color_map [show_mode] = B_W }
                                     }  
  else if (key in { 'n':1, 'N':1, ' ':1 })
                                       { if (show_one_language == 0)
                                       { show_one_language = 1 ; language_selected = 'en' ; }
                                       else 
                                       {
                                         li = langindex [language_selected] ;
                                         li < color_max - 1 ? language_selected = langcodes [1 + li] : 
                                         li < color_max ? language_selected = 'rest' : 
                                         language_selected == 'rest' ? language_selected = 'all' : 
                                         ((language_selected == 'all') && (show_mode == show_heatmap)) ? language_selected = 'composite' : 
                                         language_selected = 'en' ; 
                                       }  
                                     }
  else if (key in { 's':1, 'S':1 })  { radius_max           = radius_max < calcMin (15, canvas_width / 50) ? radius_max * 1.2 : calcMax (4, canvas_width / 200) ; radius_min = radius_max / 4 ; }
  else if (key in { 'p':1, 'P':1 })  { do_pause        = ! do_pause ; }
//else if (key in { 'r':1, 'R':1 })  { clock = Math.floor (SEC_IN_DAY / 2) ; clock_prev = clock ; } // start at noon GMT  
  else if (key in { 't':1, 'T':1 })  { show_clocks     = ! show_clocks ; }
  else if (key in { 'u':1, 'U':1 })  { show_sun        = ! show_sun ; }
//else if (key in { 'x':1, 'X':1 })  { settingsSave () ; }
  else if (key in { '@':1        })  { show_debug      = ! show_debug ; }
//else if (key in { '*':1, '[':1, ']':1 }) { imageSetWidth (key) ; }  // ony auto sized image for now 
  else if (key in { '<':1, ',':1 })  { if (show_mode == show_animation)
                                       { speed_up_desired > 5 ? speed_up_desired -= 5 : speed_up_desired > 1 ? speed_up_desired -= 1 : x = x ; }
                                     }  
  else if (key in { '>':1, '.':1 })  { if (show_mode == show_animation)
                                       { speed_up_desired < 5 ? speed_up_desired ++ : speed_up_desired < 30 ? speed_up_desired += 5 : x = x ; }
                                     }  
  else if (key in { '_':1, '-':1, '+':1,  '=':1 })  { eventKeyZoom (key) ; }

  key = '' ;
}

function eventKeyZoom (key)
{
  zoom_factor_prev = zoom_factor ;

  if (((key == '_') || (key == '-')) && (zoom_level > 0)) { zoom_level -- ; }
  if (((key == '+') || (key == '=')) && (zoom_level < zoom_level_max)) { zoom_level ++ ; }

  zoom_factor = zoom_factors [zoom_level] ;
  //zoom_factor = 4 ;

  if ((navigator.appVersion.indexOf ('Chrome') > -1) && (zoom_factor_prev == 1) && (zoom_factor > 1) && (show_chrome_msg++ < 3))
  { setNotice (4, "Chrome browser:| Title/Menu/Legend only shown when zoomed out") ; } 
  
  if (zoom_factor == zoom_factor_prev) { return ; }
  
  ctxFillStyle   (64,64,64,1) ;
  ctxStrokeStyle (64,64,64,1) ;
//  ctx.fillRect   (-1,-1,canvas_width+1,canvas_height+1) ;
  ctx.fillRect   (0,0,canvas_width,canvas_height) ;

//perc_center_x = - delta_x_tot_prev/canvas_width  + (mouse_pos_x / (canvas_width  * zoom_factor)) ;
//perc_center_y = - delta_y_tot_prev/canvas_height + (mouse_pos_y / (canvas_height * zoom_factor)) ;

  perc_center_x = - delta_x_tot_prev/canvas_width  + ((canvas_width /2) / (canvas_width  * zoom_factor_prev)) ;
  perc_center_y = - delta_y_tot_prev/canvas_height + ((canvas_height/2) / (canvas_height * zoom_factor_prev)) ;

  ctx.translate (- delta_x_tot_prev, - delta_y_tot_prev) ;

  ctx .scale  (1/ zoom_factor_prev,      1 / zoom_factor_prev) ;
  
  ctx.scale  (zoom_factor, zoom_factor) ;

  delta_x_tot = - (perc_center_x * canvas_width  * zoom_factor - canvas_width  / 2) / zoom_factor ;
  delta_y_tot = - (perc_center_y * canvas_height * zoom_factor - canvas_height / 2) / zoom_factor ;

  delta_x_min = - (canvas_width  * (zoom_factor - 1)) /zoom_factor ;
  delta_y_min = - (canvas_height * (zoom_factor - 1)) /zoom_factor ;

  // qqq
  //if (delta_x_tot > 0) delta_x_tot = 0 ; 
  //if (delta_y_tot > 0) delta_y_tot = 0 ; 
  //if (delta_x_tot < delta_x_min) { delta_x_tot = delta_x_min ; }
  //if (delta_y_tot < delta_y_min) { delta_y_tot = delta_y_min ; }
  
  ctx.translate (delta_x_tot, delta_y_tot) ;
  
  delta_x_tot_prev = delta_x_tot ;
  delta_y_tot_prev = delta_y_tot ;
}

// http://beej.us/blog/2010/02/html5s-canvas-part-ii-pixel-manipulation/

function eventMouseDown (e)
{
  time_align_map = new Date().getTime () ;

  mouse_down = true ;
  mouse_in   = true ;

  mouse_pos_x = e.pageX - e.target.offsetLeft - 8 ;
  mouse_pos_y = e.pageY - e.target.offsetTop  - 8 ;
  
  if ((mouse_pos_x >= button_plus.x) &&
      (mouse_pos_x <= button_plus.x+button_plus.w-1) &&
      (mouse_pos_y >= button_plus.y) &&
      (mouse_pos_y <= button_plus.y+button_plus.h-1))
  { 
    eventKeyZoom ('+') ; 
    return ; 
  }    

  if ((mouse_pos_x > button_min.x) &&
      (mouse_pos_x < button_min.x+button_min.w-1) &&
      (mouse_pos_y > button_min.y) &&
      (mouse_pos_y < button_min.y+button_min.h-1))
  { 
    eventKeyZoom ('-') ; 
    return ; 
  }    
  
  if (zoom_factor > 1)
  {
    dragging = true ;
    document.body.style.cursor = 'move' ;
  }  
}

function eventMouseUp (e)
{
  time_align_map = new Date().getTime () ;

  dragging   = false ;
  mouse_down = false ;
  mouse_in   = true ;

  mouse_pos_x = -1 ;
  mouse_pos_y = -1 ;

 document.body.style.cursor = 'auto' ;
}

function eventMouseOut (e)
{
  time_align_map = new Date().getTime () ;

  dragging   = false ;
  mouse_down = false ;
  mouse_in   = false ;

  mouse_pos_x = -1 ;
  mouse_pos_y = -1 ;
 document.body.style.cursor = 'auto' ;
}


function eventMouseWheel (event)
{
  time_align_map = new Date().getTime () ;

  if (setup_phase > 0) { return ; }
  
  if (event.wheelDelta)
  { delta = event.wheelDelta ; }
  else
  { delta = event.detail ; }
  
  if (delta < 0)
  { eventKeyZoom ('+') ; }
  else
  { eventKeyZoom ('-') ; }
}

function eventMouseMove (e) 
{
  // return ;
  time_align_map = new Date().getTime () ;

  if (setup_phase > 0) { return ; }

  mouse_in   = true ;

  x = e.pageX - e.target.offsetLeft;
  y = e.pageY - e.target.offsetTop;
  
  if (dragging) 
  {
    
    if (! mouse_down) return ; // can that happen, out of sync msg ?
    
    // pixel_color = data [x,y] ;
    // chk (pixel_color) ;
    
    delta_x = x - mouse_pos_x;
    delta_y = y - mouse_pos_y;
       
    delta_x_tot += delta_x / zoom_factor ;
    delta_y_tot += delta_y / zoom_factor  ;

    delta_x_min = - (canvas_width  * (zoom_factor - 1)) /zoom_factor ;
    delta_y_min = - (canvas_height * (zoom_factor - 1)) /zoom_factor ;
    if (delta_x_tot > 0) delta_x_tot = 0 ;
    if (delta_y_tot > 0) delta_y_tot = 0 ; 
    if (delta_x_tot < delta_x_min) { delta_x_tot = delta_x_min ; }
    if (delta_y_tot < delta_y_min) { delta_y_tot = delta_y_min ; }
    
    ctx.translate (- delta_x_tot_prev + delta_x_tot, - delta_y_tot_prev + delta_y_tot) ;
    delta_x_tot_prev = delta_x_tot ;
    delta_y_tot_prev = delta_y_tot ;
  }

  mouse_pos_x = x ;
  mouse_pos_y = y ;
}

// info from document.addEventListener
// to be merged with evenMouseMove
function eventMouseMoveInImage(evt)
{
  time_align_map = new Date().getTime () ;

//return ;
  now  = new Date() ;
  time = now.getTime () ;
  
  if (time - mouse_drawn < 100)
  { return ; }
  mouse_drawn = time ;

  mouse_imgmap_x = mouse_imgmap_y = 0;
    
  if (document.addEventListener && evt && typeof evt.pageX == "number")
  { 
    mouse_box_in_map = 0 ;
    
    var element = evt.target;
    var mouse_total_offset_left, mouse_total_offset_top;
    mouse_total_offset_left = mouse_total_offset_top = 0;
    while (element.offsetParent) 
    {
      mouse_total_offset_left += element.offsetLeft ;
      mouse_total_offset_top += element.offsetTop ;
      element = element.offsetParent ;
    }
    if ((evt.pageX < canvas.left) || (evt.pageX > canvas.left + canvas_width  - 1) ||
        (evt.pageYX < canvas.top) || (evt.pageY > canvas.top  + canvas_height - 1))
    { return ; }
    
    mouse_imgmap_x = evt.pageX - mouse_total_offset_left ;
    mouse_imgmap_y = evt.pageY - mouse_total_offset_top ;

    if (show_mode > -1)
    {
      // canvas_width > 1000 ? ctxFontSize (9) : canvas_width > 700 ? ctxFontSize (8) :  ctxFontSize (7);   

      ctxFontSize (8);   
      ctxFillStyle   (255,255,255,1) ; 
      ctxStrokeStyle (255,255,255,1) ; 

      long = mouse_imgmap_x / canvas_width  * 360 - 180 ;
      long2 = (long % 1) * 60 ; // + "\′" + long < 0 ? 'E' : 'W' ; //S 174°44′E;
      dir = long < 0 ? 'W' : 'E' ;
      long = Math.floor (Math.abs(long)) +"\°" + Math.floor (Math.abs(long2))+"\′"+dir ;

      lat  = mouse_imgmap_y / canvas_height * 180 -  90 ;
      lat2 = (lat % 1) * 60 ; // + "\′" + long < 0 ? 'E' : 'W' ; //S 174°44′E;
      dir = lat > 0 ? 'S' : 'N' ;
      lat = Math.floor (Math.abs(lat)) + "\°" + '\'' + Math.floor (Math.abs(lat2))+ '\'' +"\′"+dir ;
      text = lat + ' ' + long ;

      if (mouse_text_prev == text)
      { return ; }
      
      ctx_font_unscaled_saved = ctx_font_unscaled ;
      ctxFontSize (ctx_font_unscaled * zoom_factor) ; // measure width in unscaled font,scaling happens in ctxWriteZ

      wlat  = ctxTextWidth (lat) ; 
      wlong = ctxTextWidth (long) ; 
      wlat > wlong ? w_latlong = wlat : w_latlong = wlong ;

      ctxFontSize (ctx_font_unscaled_saved) ;  // back to scaled font 

      mouse_text_prev = text ;
      
      if (mouse_box_left)  
      {
        mouse_box_bx   = mouse_imgmap_x - 16 - w ;
        mouse_box_by   = mouse_imgmap_y - 21 ;
      }
      else
      {  
        mouse_box_bx   = mouse_imgmap_x + 20 ;
        mouse_box_by   = mouse_imgmap_y ;
      }

      mouse_box_tx   = mouse_box_bx + 4  ;
      mouse_box_ty   = mouse_box_by + 11 ; 
      mouse_box_bw   = w_latlong + 12 ;
      mouse_box_bh   = 35 ;  
      mouse_box_lat  = lat ;
      mouse_box_long = long ;
      
      if (mouse_box_by + mouse_box_bh > canvas_height - 1)
      { 
        mouse_box_by = canvas_height - 1 - mouse_box_bh ; 
        mouse_box_ty = canvas_height - 1 - mouse_box_bh + 14 ;
      } ;
      
      if ((mouse_box_bx >= 0) && (mouse_box_by >= 0)) 
      { mouse_box_in_map = 1 ; }
    }  
  }
  document.getElementById('cv').innerHTML = "X:"+mouse_imgmap_x+" Y: "+mouse_imgmap_y;
  return false ;
}  
  
function sortEdits (a,b)
{
  return a.substr (0,5) - b.substr (0,5) ;
}

function prepData ()
{    
  setNotice ( 3, 'Data loaded. Building tables.') ; 
  drawNotice () ;

  data_languages_sort_by_edits.replace (/&quot;/g,'\'') ;
  languages_in = data_languages_sort_by_edits.split(';') ; 
  data_languages_sort_by_edits = '' ;
  for (var l = 0, len = languages_in.length ; l < len; l++)
  {
    langcodename = languages_in [l].split (':') ;
    langcode = langcodename [0] ;
    langcode = langcode.replace (/_/g,'-') ; // fix in input later
    langname = langcodename [1] ;
    langcodes [tot_languages] = langcode ;
    languages [langcode] = langname ;
    langindex [langcode] = tot_languages ;
    
    switch (tot_languages % 10)
    {
      case 0 : hue =  0 ; break ; // English, Turskish 
      case 1 : hue =  8 ; break ; // Japanese, Swedish
      case 2 : hue = 15 ; break ; // German, Finnish
      case 3 : hue = 22 ; break ;
      case 4 : hue = 38 ; break ;
      case 5 : hue = 55 ; break ;
      case 6 : hue = 62 ; break ;
      case 7 : hue = 75 ; break ;
      case 8 : hue = 82 ; break ;
      case 9 : hue = 90 ; break ;
    }
    
    // tot_languages <  10 ? sat = 100 : tot_languages < 20 ? sat = 70 : sat = 100 ;
    // tot_languages <  10 ? val = 100 : tot_languages < 20 ? val = 70 : val = 100 ;

    tot_languages >= 20 ? hue = 0 : hue = hue ;
    tot_languages < 10 ? sat = 100 : sat = 40 ;
    val = 100 ; 
    
    colors    [langcode] = conv_hsv2rgb (360*hue/100,sat,val) ; 
    hues      [langcode] = 360*hue/100 ;
    max_count [langcode] = 0 ; 
    tot_count [langcode] = 0 ; 
    
    tot_languages ++ ;
  }
  colors    ['rest']  = conv_hsv2rgb (0,100,100) ;
  languages ['rest']  = 'Other' ;  
  langindex ['rest']  = tot_languages ;  
  max_count ['rest']  = 0 ; 

  colors    ['all']   = conv_hsv2rgb (0,100,100) ;
  languages ['all']   = 'All' ;  
  langindex ['all']   = tot_languages + 1 ;
  max_count ['all']   = 0 ; 

// at least as long as server side compression does't work
// this shrinks file significantly further

  data_edits = data_edits.replace (/N/g,',nl;') ;
  data_edits = data_edits.replace (/L/g,',pl;') ;
  data_edits = data_edits.replace (/P/g,',pt;') ;
  data_edits = data_edits.replace (/I/g,',it;') ;
  data_edits = data_edits.replace (/R/g,',ru;') ;
  data_edits = data_edits.replace (/S/g,',es;') ;
  data_edits = data_edits.replace (/F/g,',fr;') ;
  data_edits = data_edits.replace (/D/g,',de;') ;
  data_edits = data_edits.replace (/J/g,',ja;') ;
  data_edits = data_edits.replace (/E/g,',en;') ;
  
  tot_edits = 0 ;
  tot_frequencies = 0 ;
  tot_viewstats = 0 ;
  tot_viewsmobile = 0 ;
  tot_cities = 0 ;
  
  edits = [] ;
  edits_in = data_edits.split('^') ; // single edits
  for (var e = 0, len = edits_in.length, latlong_data; e < len; e++)
  {
    latlongcountry_data = edits_in [e].split ('|') ;
    events = latlongcountry_data [1].split (';') ;
    time_prev = 0 ;
    for (var e2 = 0, len2 = events.length, timewiki; e2 < len2; e2++)
    {
      fields = events[e2].split (',') ;
      time = time_prev + 1 * fields [0] ;      
      time_prev = time ;
      edits_temp [tot_edits++] = sprintf ("%05d", time) + ',' + fields [1] + ',' +  latlongcountry_data [0] ;
    }  
  }

  data_languages_sort_by_edits = '' ;
  data_languages_sort_by_code  = '' ;
  data_edits = '' ;

  setTimeout (prepData2, interval); 
}  
  
// use here always resolution 1/2 degree (not 1/4 or 1/8) to prevent de-anonimization
function prepData2 ()
{    
  edits_temp.sort (sortEdits) ;

  for (var e = 0 ; e < tot_edits; e++)
  { 
    fields = edits_temp [e].split (',') ;
    edits [e] =              
    new initEditEvent (e,
                       fields [0],         // time, resolution in 10 seconds
                       fields [1],         // lang
                       fields [4],         // country code
                       fields [2]/2-180,   // longitude, data accuracy is half degree, doubled then stored as int, saves previous file size: no dec point needed)
                       fields [3]/2- 90) ; // latitude,  data accuracy is half degree, doubled then stored as int, saves previous file size: no dec point needed)
  }  

  edits_in   = [] ;
  edits_temp = [] ;
  
  setTimeout (prepData3, interval); 
}

function prepData3 ()
{    
  tot_edits < 100000 ? mult_test = 10 : mult_test = 1 ;
  frequencies = [] ; 
  freq_in = data_freq.split(';') ; 
  
  for (p = 0 ; p < 360*resolution ; p++)
  { 
    for (q = 0 ; q < 180 * resolution ; q++)
    { coords [p*180*resolution+q] = 0 ; } 
  }  

  tot_count_rest  = 0 ;
  tot_count_all = 0 ;
  for (var n = 0, len = freq_in.length, frequencySplit; n < len; n++)
  {
    frequencySplit = freq_in [n].split (',') ;
    if (freq_in [n] != '')
    {
      frequencies [tot_frequencies++] = 
      new initFrequencyItem (n,
                             frequencySplit [0],      // language code
                            (frequencySplit [1]/resolution-180), // longitude as rounded whole number
                            (frequencySplit [2]/resolution-90),  // latitude  as rounded whole number
                             frequencySplit [3] * mult_test) ;    // edit count
    }            
  }
  tot_count ['rest']  = tot_count_rest ;
  tot_count ['all']   = tot_count_all ;

  viewstats_in = data_viewstats.split(';') ; 
  for (var n = 0, len = viewstats_in.length, viewstatsSplit; n < len; n++)
  {
    viewstatsSplit = viewstats_in [n].split (',') ;
//  chk (n + ':' + viewstats_in [n]) ;
    if (viewstats_in [n] != '')
    {
      views_desktop = parseInt (viewstatsSplit [2]) ;
      views_mobile  = parseInt (viewstatsSplit [3]) ;
      views_all     = views_mobile + views_desktop ;
      tot_views        += views_all ; // all day, all locations
      tot_views_mobile += views_mobile ; // all day, all locations
      
      if (views_all > 0)
      { perc_mobile = sprintf ("%.0f", (100 * views_mobile) / views_all) ; }
      else
      { perc_mobile = 0 ; }
      
      viewstats [tot_viewstats++] = 
      new initViewStatsItem (n,
                            (viewstatsSplit [0]/resolution-180), // longitude as rounded whole number
                            (viewstatsSplit [1]/resolution-90),  // latitude  as rounded whole number
                             views_all,          
                             perc_mobile) ; 
    }            
  }

  addCities () ;
  resetAnimation () ;

  clock = Math.floor (SEC_IN_DAY / 2) ; // start at noon GMT  
  clock_prev = clock ;

  data_freq = '' ;
  freq_in   = [] ;
  data_viewstats = '' ;
  
  setTimeout (draw, INTERVAL);
}

function imageResize()
{
  imagePrep () ;

  resetAnimation () ;

  for (e = 0 ; e < tot_edits ; e++)
  {
    edits [e].x = Math.round (edits [e].long * pixels_per_degree + canvas_width / 2) ;
    edits [e].y = Math.round (canvas_height * (1 - (edits [e].lat + 90) / 180)) ;
  }

  for (f = 0 ; f < tot_frequencies ; f++)
  {
    frequencies [f].x = Math.round (frequencies [f].long * pixels_per_degree + canvas_width / 2) ;
    frequencies [f].y = Math.round (canvas_height * (1 - (frequencies [f].lat + 90) / 180)) ;

    frequencies [f].r = Math.sqrt (frequencies [f].count) * (canvas_width / 5000) ; 
    if (frequencies [f].r > canvas_width / 2)
    { frequencies [f].r = canvas_width / 2 ; }
    frequencies [f].lw = frequencies [f].r / 15 ; // line width
  }
  
  for (v = 0 ; v < tot_viewstats ; v++)
  {
  //viewstats [v].x = Math.round (viewstats [v].long * pixels_per_degree + canvas_width / 2) ;
  //viewstats [v].y = Math.round (canvas_height * (1 - (viewstats [v].lat + 90) / 180)) ;
    viewstats [v].x = viewstats [v].long * pixels_per_degree + canvas_width / 2 ;
    viewstats [v].y = canvas_height * (1 - (viewstats [v].lat + 90) / 180) ;
  }

  for (c = 0 ; c < tot_cities ; c++)
  {
    cities [c].x = Math.round (cities [c].long * pixels_per_degree + canvas_width / 2) ;
    cities [c].y = Math.round (canvas_height * (1 - (cities [c].lat + 90) / 180)) ;
  }
  
  resized = 1 ;
  
  if (image_size_auto == 0)
  { setNotice (2, "Image size: " +canvas.width + ' x ' + canvas_height + " px") ; }
}

function prepCanvas ()
{
  setNotice (5, "Loading data (2 Mb!), please wait.") ; 
// test 
//canvas = document.getElementById("cv");
//canvas.style.border = "black 1px solid" ;    
//canvas.width  = 100 ;  
//canvas.height = 100 ;
//canvas.focus () ;
  setTimeout (prepCanvas2, interval); 
}

function prepCanvas2 ()
{
}
function imagePrep ()
{    
  //if (canvas.height < 100)
  //{
  //  canvas.width = 1000 ;  
  //  canvas.height = 500 ;
  //}  
  
  drawMap () ;

  canvas_width  = canvas.width ;
  canvas_height = canvas.height ;

  canvas_width_prev = canvas.width ;

  // issue: overrules saved setting !!!!
  radius_max    = calcMax (4, canvas_width / 150) ; 
  radius_min    = radius_max / 4 ;
  radius_legend = radius_max * 0.75 ;
  
  pixels_per_degree = canvas_width / 360 ;

  canvas_height > 500 ? ctxFontSize (12) : ctxFontSize (10) ;   
  
  clock = Math.floor (SEC_IN_DAY / 2) ; // start at noon GMT  
  clock_prev = clock ;
}

// **** MAIN LOOP **** //
function draw ()
{

//  ctx.clearRect (0,0,canvas_width,canvas_height) ;
  if (show_mode < show_heatmap)
  { show_pop_density = show_pop_not ; }
  
  if (key != '')
  {
    if (handleKeyPressed)
    { handleKeyPressed (key) ; }
    key = '' ;
    // chk(1) ;
  }
  
  if ((canvas_width < 600) && (show_pop_density != show_pop_not))  // no split screen on very small display 
  { show_pop_density = show_pop_full ; }                            // only swap population density map with other map

  if ((zoom_factor > 2) && ((show_pop_density > show_pop_not) && (show_pop_density < show_pop_full)))    // no split screen when zoomed in (zoom/pan for split screen not yet implemented)
  {                          // only swap population density map with other map
    show_pop_density = show_pop_not ; 
    setNotice (7, "Split screen not active at large zoom levels (> 2x).|You can still toggle population density map by pressing 'd'.") ; 
  } 

  ctx.textBaseline = 'middle' ;  
//  canvas.focus () ;
  calcPageSize () ; // do this only on OnLoad OnResize ? 

  time_check_align_map = new Date().getTime () - time_align_map ;
  
  // realign map in small steps, looks more natural, like someone adjusts it manually
  // also wait a small while to do this, is less nervous 
  if ((setup_phase == 0) && (! mouse_down && (time_check_align_map > 500)))
  {
    alignment_map_busy = 0 ;
    
    perc_center_x = - delta_x_tot_prev/canvas_width  + ((canvas_width /2) / (canvas_width  * zoom_factor)) ;
    perc_center_y = - delta_y_tot_prev/canvas_height + ((canvas_height/2) / (canvas_height * zoom_factor)) ;

    ctx.translate (- delta_x_tot_prev, - delta_y_tot_prev) ;

    delta_x_tot = - (perc_center_x * canvas_width  * zoom_factor - canvas_width  / 2) / zoom_factor ;
    delta_y_tot = - (perc_center_y * canvas_height * zoom_factor - canvas_height / 2) / zoom_factor ;

    delta_x_min = - (canvas_width  * (zoom_factor - 1)) /zoom_factor ;
    delta_y_min = - (canvas_height * (zoom_factor - 1)) /zoom_factor ;

    if (delta_x_tot > 0)           { delta_x_tot -= calcMax (1, delta_x_tot / 7)  ; }
    if (delta_y_tot > 0)           { delta_y_tot -= calcMax (1, delta_y_tot / 7) ;  }
    if (delta_x_tot < delta_x_min) { delta_x_tot += calcMax (1, (delta_x_min - delta_x_tot) / 7) ; }
    if (delta_y_tot < delta_y_min) { delta_y_tot += calcMax (1, (delta_y_min - delta_y_tot) / 7) ; }
  
    ctx.translate (delta_x_tot, delta_y_tot) ;
  
    if ((delta_x_tot != delta_x_tot_prev) || (delta_y_tot != delta_y_tot_prev))
    { alignment_map_busy = 1 ; }  
    
    delta_x_tot_prev = delta_x_tot ;
    delta_y_tot_prev = delta_y_tot ;
  }  

  if (canvas_width != canvas_width_prev)
  {
    // htmlShow ('msg_wait2') ;
    imageResize () ;
    // prepData () ; 
    // htmlHide ('msg_wait2') ;
    setTimeout (draw, INTERVAL);
    return ;
  }
  
  if (do_pause)
  { setTimeout (draw, INTERVAL_LONG) ; return ; }

  drawMap () ;

  // clearTitleArea () ; // no need, is already solid blue
  drawMapShade () ;

  // drawTotals () ; // to be done
  
  if (alignment_map_busy == 0)
  { 
    switch (show_mode)
    {
      case show_animation   : drawAnimation  () ; break ;
      case show_distrib     : drawBubbleMap  () ; interval = INTERVAL_LONG ; break ;
      case show_heatmap     : drawHeatmap    () ; interval = INTERVAL_LONG ; break ;
      case show_views       : drawViews      () ; interval = INTERVAL_LONG ; break ;
      case show_perc_mobile : drawPercMobile () ; interval = INTERVAL_LONG ; break ;
      default: chk ('unknown show_mode: ' + show_mode) ;
    }
  }

  if (setup_phase == 0)
  {
    drawTitle () ;
    drawDebugInfo ()
    drawCredits () ;
    drawLegend () ; 
    drawZoomBox () ;
    drawMouseInfo () ;
  }
  else 
  { 
    setupPhase () ; 
    drawDebugInfo ()
  }
    
  drawNotice () ;

  setTimeout (draw, interval); 
}

function drawAnimation ()
{
//if (dragging) return ;
  
  clock_prev = clock ;
  clock = (clock + clock_delta) % SEC_IN_DAY ;
  
  if (clock < clock_prev) 
  { edits_shown = 0 ; }
  
  if ((speed_up_measured > speed_up_desired) &&
      (clock_delta > 0.3)) // guard against run-away increment (saw once, not able to replay
  { clock_delta *= 0.98 ; }
  else
  if ((speed_up_measured < speed_up_desired) &&
      (clock_delta < 10)) // guard against run-away increment (saw once, not able to replay
  { clock_delta *= 1.02 ; }

  drawCities () ; // cities below other content
  
  // *** UPDATE CLOCK ***
  events_drawn = 0 ;
  
  if (jump_forward > 0)
  {
    e = first_event_to_show ;
 
    while (e != last_event_to_show)
    {
      edits [e].r = -1 ;
      edits [e].showing = false ;
      e = (e + 1) % tot_edits ;
    }
    clock = (clock + 3600) % SEC_IN_DAY ;
    clock_prev = clock ;
    jump_forward = 0 ;

    cycles_escape = 0 ;
    while ((edits [e].time < clock) || (edits [e].time - clock > 3600))
    {
      e = (e + 1) % tot_edits ;
      if (cycles_escape ++ > 1000000) // safety
      { break ; }
    }  
    first_event_to_show = e ;
  }
  
  // *** UPDATE RANG of ACTIVE EVENTS ***
  ctxLineWidth (2) ;
  cycles_escape = 0 ;

  calcSpeed () ;
  setCircleShrinkRate () ;

  e = first_event_to_show ;
  while (true)
  {
// chk ('first event to show ' + first_event_to_show + ', e: ' + e + ' edits[e].r ' + edits [e].r) ;    
    if ((edits [e].r <= radius_min) && (edits [e].showing))
    { 
      first_event_to_show = (first_event_to_show + 1) % tot_edits ; 
      edits [e].showing = false ;
      edits [e].r = -1 ;
    }
    e = (e + 1) % tot_edits ;
    last_event_to_show = e ;

    diff = (SEC_IN_DAY + edits [e].time - clock) % SEC_IN_DAY ;

if ((diff > 0) && (diff < 3600)) 
{ break ; }
    
    if ((tot_edits + last_event_to_show - first_event_to_show) % tot_edits > 5000) // show up to 2000 points (most recent, kill older points)
    { 
      edits [first_event_to_show].showing = false ;
      edits [first_event_to_show].r = -1 ; 
      first_event_to_show = (first_event_to_show + 1) % tot_edits ; 
    }

    if (cycles_escape ++ > 1000000) // safety
    { break ; }
  }
  
  // *** UPDATE ACTIVE EVENTS ***
  ctxTextAlignLeft () ;
  
  e = last_event_to_show ;
  while (e >= first_event_to_show)
  {
    edits[e].update(e) ;

  //  if ((tot_edits + (last_event_to_show - e)) % tot_edits > 100)
  //  { break ; } 

    e = (tot_edits + e - 1) % tot_edits ; 
  }

  events_drawn_trend = 0.9 * events_drawn_trend +  0.1 * events_drawn ;

  if (setup_phase == 0)
  {
    drawSun () ; 
    drawClocks () ;
  }  
}

function drawBubbleMap ()
{
  if (language_selected == 'composite')
  {
    drawBubbleMapComposite () ;
    return ;
  }
  
  // always use brilliant saturated colors here
  if ((language_selected != 'rest') && (language_selected != 'all'))
  { c = setColors (langcodes [langindex [language_selected] % 10], TRANSPARENCY_FILL_DISTRIB, TRANSPARENCY_LINE_DISTRIB) ; }
  else
  { c = setColors (language_selected, TRANSPARENCY_FILL_DISTRIB, TRANSPARENCY_LINE_DISTRIB) ; }
  
  ctxStrokeStyle (0,0,0,1) 
  
  for (f = 0 ; f < tot_frequencies ; f++)
  {
    if ( (show_pop_density == show_pop_not)                                              || // don't show population density
        ((show_pop_density == show_pop_left)  && (frequencies [f].x >= canvas_width / 2))  || // show population density in left half of screen
        ((show_pop_density == show_pop_right) && (frequencies [f].x <  canvas_width / 2)))    // show population density in right half of screen 
    {
      if (frequencies [f].lang == language_selected)
      {   
        ctxLineWidthZ (frequencies [f].lw) ;
        ctxCircle (frequencies [f].x, frequencies [f].y, frequencies [f].r/zoom_factor, c) ; 
      }  
    }
  }

  drawCities () ; // cities above other content
}  

function drawHeatmap ()
{  
  if (language_selected == 'composite')
  {
    drawHeatmapComposite () ;
    return ;
  }
  
  ctxLineWidth (0) ;

  w2 = h2 = ((canvas_width / (360 * resolution)) / 2) * 1 ; 

  for (f = 0 ; f < tot_frequencies ; f++)
  {
    if ( (show_pop_density == show_pop_not)                                            || // don't show population density
        ((show_pop_density == show_pop_left) && (frequencies [f].x >= canvas_width / 2))  || // show population density in left half of screen
        ((show_pop_density == show_pop_right) && (frequencies [f].x <  canvas_width / 2)))    // show population density in right half of screen 
    {
      if (frequencies [f].lang == language_selected)
      { 
        edits = frequencies [f].count ;
        if (edits > 1) 
        {
          rgb = setColorEdits (edits, language_selected) ; 
          ctx.fillStyle   ="rgb(" + rgb + ')' ;
          ctx.strokeStyle ="rgb(" + rgb + ')' ;
          ctxDrawBox (frequencies [f].x - w2, frequencies [f].y - h2, w2*2, h2*2) ;
        }  
      }  
    }
  }
  drawCities () ; // cities above other content
}

function drawViews ()
{  
  ctxLineWidth (0) ;
  
// w2 = h2 = ((canvas_width / (360 * resolution)) / 2) - 0.5 / 4 ; //zoom_factor ;
//  w2 = h2 = 0.2 ; // ((canvas_width / (360 * resolution)) / 2) - 0.5 / 4 ; //zoom_factor ;
  w2 = h2 = ((canvas_width / (360 * resolution)) / 2) * 0.5 ; // - 0.5 / zoom_factor ;
  
  for (v = 0 ; v < tot_viewstats ; v++)
  {
    if ( (show_pop_density == show_pop_not)                                            || // don't show population density
        ((show_pop_density == show_pop_left) && (viewstats [v].x >= canvas_width / 2))  || // show population density in left half of screen
        ((show_pop_density == show_pop_right) && (viewstats [v].x <  canvas_width / 2)))    // show population density in right half of screen 
    {
      rgb = setColorViews (viewstats [v].views) ;

      ctx.fillStyle   ="rgb(" + rgb + ')' ;
      ctx.strokeStyle ="rgb(" + rgb + ')' ;
      ctxDrawBox (viewstats [v].x - w2, viewstats [v].y - h2, w2*2, h2*2) ;
    }  
  }
  drawCities () ; // cities above other content
}

function drawPercMobile ()
{  
  ctxLineWidth (0) ;
  
  w2 = h2 = ((canvas_width / (360 * resolution)) / 2) * 0.5 ; // - 0.5 / zoom_factor ;
  
  for (v = 0 ; v < tot_viewstats ; v++)
  {
    if ( (show_pop_density == show_pop_not)                                            || // don't show population density
        ((show_pop_density == show_pop_left) && (viewstats [v].x >= canvas_width / 2))  || // show population density in left half of screen
        ((show_pop_density == show_pop_right) && (viewstats [v].x <  canvas_width / 2)))    // show population density in right half of screen 
    {
      rgb = setColorPercMobile (viewstats [v].perc_mobile) ;

      ctx.fillStyle   ="rgb(" + rgb + ')' ;
      ctx.strokeStyle ="rgb(" + rgb + ')' ;
      ctxDrawBox (viewstats [v].x - w2, viewstats [v].y - h2, w2*2, h2*2) ;
    }  
  }
  drawCities () ; // cities above other content
}

function drawBubbleMapComposite ()
{
  ctxLineWidth (0) ;
  
  w2 = h2 = (canvas_width / 720) / factor_grid ; // half box width/height

  for (p = 0 ; p < (360 * resolution) ; p++)
  { 
    for (q = 0 ; q < 360 ; q++)
    { 
      pq = p*360+q ;
      if (coords [pq] > 0)
      {
        f = coords [pq] ;
        lang = frequencies [f].lang ;
        index = langindex [lang] ;
        max_count_color_lang = max_count [lang] ;
        hue = hues [lang] ;    
  
        if (max_count_color_lang > Math.sqrt (tot_count [lang])) 
        { max_count_color_lang = Math.sqrt (tot_count [lang]) ; }


        val = 70 * Math.pow (frequencies [f].count / max_count_color_lang,1) + 30 ;
        sat = 100 ;

        if ((lang == 'rest') || (lang == 'all') || (index >= 20))
        { 
          sat = 0 ; 
          val = 20 * Math.pow (frequencies [f].count / max_count_color_lang,1) + 15 ;
        }
        else if (langindex [lang] >= 10)
        { sat = SATURATION_11_20 ; }

        rgb = conv_hsv2rgb (hue,sat,val) ;
        fill_color = 'rgba(' + rgb + ',0.7)' ;
        line_color = 'rgba(' + rgb + ',0.7)' ;
      
        ctxLineWidth2 (frequencies [f].lw) ;
        c = {f:fill_color, l:line_color} ;
        ctxCircle (frequencies [f].x, frequencies [f].y, frequencies [f].r/zoom_factor, c) ; 
      }       
    }  
  }  

  drawCities () ; // cities above other content
}  

function drawHeatmapComposite ()
{  
  ctxLineWidth (0) ;
  
  w2 = h2 = ((canvas_width / (360 * resolution)) / 2) * 0.5 ; 

  for (p = 0 ; p < (360 * resolution) ; p++)
  { 
    for (q = 0 ; q < 180 * resolution ; q++)
    { 
      pq = p*360+q ;
      if (coords [pq] > 0)
      {
        f = coords [pq] ;
        lang = frequencies [f].lang ;

        edits = frequencies [f].count ;
        if (edits > 0) 
        {
          rgb = setColorEdits (50, lang) ; 
          ctx.fillStyle   ="rgb(" + rgb + ')' ;
          ctx.strokeStyle ="rgb(" + rgb + ')' ;
      
          ctxDrawBox (frequencies [f].x - w2, frequencies [f].y - h2, w2*2, h2*2) ;
        }  
      }       
    }  
  }  

  drawCities () ; // cities above other content
}

function resetAnimation ()
{
  clock = Math.floor (SEC_IN_DAY / 2) ; // start at noon GMT  
  clock_prev = clock ;

  // if lowest time in array edits is after time 'clock'
  // then at the end of this routine counters point to first edit after time 'clock' rather than last edit before before time 'clock' 
  first_event_to_show = 0 ;
  last_event_to_show  = 0 ;
 
  clock_found = false ;
  
  for (e = 0 ; e < tot_edits ; e++)
  {
    edits [e].r = -1 ; 
    edits [e].showing = false ;
    
    if (edits [e].time > clock) 
    { clock_found = true ; }
    
    if (! clock_found) 
    {
      first_event_to_show = e ;
      last_event_to_show  = e ;
      first_event_to_show_0 = e ;
      last_event_to_show_0  = e ;
    }
  }

  frames_shown = -1 ;
}    

initEditEvent.prototype.update = 
function(e)
{
// state machine, after clock passed edit timestamp, wait x frames to show circle (x = frames per sec / speed factor)
// delay at least one frame, to keep start event at one place in code
// example: speed factor 5 (clock of simulation runs 5x real clock), frames per sec 20 -> delay 1-4 frames
// this spreads appeareance of circles, otherwise all circles for some second would appear in same frame, which at low speed produces pulse/wave effect  
  
  // I kept this condition similar to other draw routines, even when all action happens in else section
  if ( (show_pop_density == show_pop_not)                                            || // don't show population density
      ((show_pop_density == show_pop_left) && (this.x >= canvas_width / 2))  || // show population density in left half of screen
      ((show_pop_density == show_pop_right) && (this.x <  canvas_width / 2)))    // show population density in right half of screen 
  { ; }
  else
  { return ; }

  if (this.delay > 0)
  { 
    this.delay -- ;
    if (this.delay == 0)
    {
      //start showing new circle
      this.showing = true ; 
      this.r = radius_max ; 
      this.noshrink = 2 ; // keep circle at full size for several frames
      this.t = 0.7 ; // TRANSPARENCY_FILL ;
      this.f = 2 + radius_max * 1.2 ;
      edits_shown ++ ;
    }  
  }
  else
  if (this.r > radius_min)
  { 
    if (this.noshrink > 0) // keep marker full size for several frames
    { this.noshrink-- ; } 
    else
    {
      this.r = this.r * fade_factor ; // radius
      this.t *= fade_factor ; // transparency 
      this.f *= fade_factor ; // font size
    }  
  }
  else if (this.r > 0)
  { 
    this.r = -1 ; 
    this.showing = false ;
  } // don't show again for 1000 frames
  else 
  {
    if ((clock_prev < this.time) && (clock >= this.time)) // start new circle ?
    { 
      if ((show_one_language == 0) || (this.lang == language_selected) || 
          ((language_selected == 'rest') && (langindex [this.lang] >= color_max)))
      {
        if (speed_up_measured > 0)
        { this.delay = rand (frames_per_sec / speed_up_measured) + 1 ; }
        else
        { this.delay = 1 ; }
      }  
    }
  }  

  ctxLineWidth (this.r / 5) ;
  ctxStrokeStyle (0,0,0,1) ;
  
  if (this.r > 0)
  { 
    if (setup_phase == 0) 
    { drawMarker (this.x,this.y,this.r,this.t,this.c,this.f,this.lang) ; }
    else   
    {
      // choose map and marker type from 4 partial screens      
      
      x0 = this.x ;
      y0 = this.y ;

      // opening sequence: show different marker styles in color and black and white map sections  
      show_edits_save = show_edits ;
      x0 < canvas_width * 1600/3000 ? show_edits = 3 : show_edits = 1 ;
      drawMarker (this.x,this.y,this.r,this.t,this.c,this.f,this.lang) ; 
      show_edits = show_edits_save ;
    }  
  }
}  

function drawMarker (x,y,r,t,c,f,lang)
{
  events_drawn ++ ;

  if (r < 2) { r = 2 ; }
  
  switch (show_edits)
  {
    case 1: 
      r /= zoom_factor ;
      c = setColors (lang, t, t) ;
      ctxLineWidth (r / 4) ;
      ctxCircle (x, y, r, c) ; 
    break ;
     
    case 2: 
      ctxFontSize (2+radius_max) ;
        
      ctx.fillStyle= 'rgb(' + colors [lang] + ')' ;
      w2 = ctxTextWidth (lang) / 2 ;
      ctxWrite (x-w2,y+2, lang) ;
    break ;
      
    case 3: 
      ctxFontSize (f) ;
        
      ctx.fillStyle= 'rgb(' + colors [lang] + ')' ;
      w2 = ctxTextWidth (lang) / 2 ;
      ctxWrite (x-w2,y+2, lang) ;
     break ;
  }  
}

function initEditEvent (n,time,lang,country,long,lat) // lang = language, long = longitude
{
  this.time    = time ; // seconds
  this.lang    = lang ;
  this.country = country ;
  this.long    = long ;
  this.lat     = lat ;
  this.x       = Math.round (long * pixels_per_degree + canvas_width / 2) ;
  this.y       = Math.round (canvas_height * (1 - (lat + 90) / 180)) ;
  this.r       = -1 ; // rand (10) + rand(10)/10 ;
  this.c       = setColors (lang, TRANSPARENCY_FILL, TRANSPARENCY_LINE) ;
  this.showing = false ;
  
  if ((clock == 0) && (this.time > SEC_IN_DAY / 2)) // start at noon 
  { clock = this.time ; first_event_to_show = n ; }
}

function initFrequencyItem (n,lang,long,lat,count) // lang = language, long = longitude
{
  this.lang    = lang ;
  this.long    = long ;
  this.lat     = lat ;
  this.x       = Math.round (long * pixels_per_degree + canvas_width / 2) ;
  this.y       = Math.round (canvas_height * (1 - (lat + 90) / 180)) ;

  if (count == 0) 
  { count = 1 ; } // safety, lest sqrt fails
  this.count   = count ;

  this.r = Math.sqrt (count) * (canvas_width / 5000); 
  if (this.r > canvas_width / 2)
  { this.r = canvas_width / 2 ; }
  this.lw = this.r / 15 ; // line width
  
  if (count > max_count [lang])
  { 
  	max_count [lang] = count ;
  	max_count_trace [lang] += ',' + count ;
  }
  
  
  tot_count [lang] += count ;
  
  if ((lang != 'all') && (lang != 'rest'))
  { 
    tot_count_all += this.count ;  

    if (langindex [lang] > color_max - 1)
    { tot_count_rest += this.count ; }

    pq = ((this.long + 180) * resolution) * 360 + (this.lat + 90) * resolution ;
    if (coords [pq] == 0)
    { coords [pq] = n ; } 
    else
    {
      if (this.count > frequencies [coords [pq]].count)
      { coords [pq] = n ; } 
    }  
  }   
}

function initViewStatsItem (n,long,lat,views,perc_mobile) // lang = language, long = longitude
{
  this.long    = long ;
  this.lat     = lat ;
  this.x       = long * pixels_per_degree + canvas_width / 2 ;
  this.y       = canvas_height * (1 - (lat + 90) / 180) ;
  
  // convert 1/1000 views per cell to views per square kilometer 
  // width in km's per cell changes with latitude 
  square_kilometers_per_cell = square_kilometers_per_cell_equator * Math.cos ((Math.abs (lat) / 90) * (Math.PI / 2)) ;
  views = sprintf ("%.0f", (views * 1000) / square_kilometers_per_cell) ; // * 1000 because of 1:1000 sampling
  this.views    = views ;
  this.perc_mobile  = perc_mobile ;
}


function drawCities ()
{
  if (! show_cities > 0) { return ; } // condition here to keep main tidy 

  city_show_from_size = canvas_width / 200 ;
  save_fillStyle   = ctx.fillStyle ;
  for (var n = 0, len = cities.length; n < len; n++)
  { 
    x  = cities [n].x ;
    y  = cities [n].y ;
    dx = cities [n].dx ;
    dy = cities [n].dy ;
    r = radius_city ;
    if (canvas_width <= 1000)
    { r -- ; }
    
    if (cities [n].show > city_show_from_size) 
    { continue ; }
    
    align = cities [n].align ;
    name  = cities [n].name ;
    pos   = cities [n].pos ;
    ctxStrokeStyle (0,0,0,1) ;
    ctxLineWidth (1/zoom_factor) ;

    switch (show_mode)
    {
      case show_animation: 
        if (color_map [show_mode] == COLOR)
        { ctxCircle (x,y,r/zoom_factor,setColor ('255,255,255')) ; }
        else
        { ctxCircle (x,y,r/zoom_factor,setColor ('96,96,163')) ; }
        
        switch (cities [n].color)
        {
          case 'w': ctxFillStyle (255,255,255,0.8) ; break ;
          case 'g': ctxFillStyle (192,192,192,0.8) ; break ;
          default : ctxFillStyle (  0,  0,  0,0.8) ; break ;
        }
      break ;
      
      case show_distrib:
        ctxCircle (x,y,r/zoom_factor,setColors ('rest', 0.8,0.8)) ; 
        if (show_cities_white)
        { ctxFillStyle (255,255,255,0.8) ; }
        else
        { ctxFillStyle (128,128,128,0.5) ; }
      break ;

      case show_heatmap:
        // ctxCircle (x,y,r,setColors ('rest', 0.2,0.2)) ; 
        if ((language_selected == 'rest') || (language_selected == 'all'))   
        { ctxCircle (x,y,2/zoom_factor,setColors ('it', 1, 1)) ;  }
        else  
        { ctxCircle (x,y,2/zoom_factor,setColors ('rest', 1, 1)) ;  }
        if (show_cities_white)
        { ctxFillStyle (255,255,255,0.2) ; }
        else
        { ctxFillStyle (128,128,128,0.5) ; }
      break ;  

      case show_views:
      case show_perc_mobile:
        // ctxCircle (x,y,r,setColors ('rest', 0.2,0.2)) ; 
        ctxCircle (x,y,2/zoom_factor,setColors ('it', 1, 1)) ;  

        if (show_cities_white)
        { ctxFillStyle (255,255,255,0.2) ; }
        else
        { ctxFillStyle (128,128,128,0.5) ; }
      break ;  
    }

    if (color_map [show_mode] == B_W)
    { 
      if ((language_selected == 'rest') || (language_selected == 'all'))
      { ctxFillStyle (128,128,128,0.7) ; }
      else
      { ctxFillStyle (128,128,128,0.7) ; }
    }  
     
    canvas_width > 1000 ? ctxFontSize (9) : canvas_width > 700 ? ctxFontSize (8) :  ctxFontSize (7);   

    if (align == 'l')
    { ctxWrite (x-ctxTextWidth(name)+(dx-radius_city-3)/zoom_factor,y+(dy+5)/zoom_factor,name) ; }  
    else
    {
      ctxWrite (x+(radius_city+3+dx)/zoom_factor,y+(dy+5)/zoom_factor,name) ;
      // skip showing lat/long on every city, now shown at mouse focus
      // if (show_cities > 1)
      // { ctxWrite (x+radius_city+3+dx,y+18+dy,pos) ; }
    }  
  }  
  ctx.fillStyle   = save_fillStyle ;
}

function drawLegend ()
{
	if ((navigator.appVersion.indexOf ('Chrome') > -1) && (zoom_factor > 1))
	{ return ; }
		
	
  color_map [show_mode] == COLOR ? ctxTextBorder (0,0,0) : ctxTextBorder (-1) ;
  
  ctxTextAlignLeft () ;

  if (canvas_width < 450) { return ; }

  ctxFillStyle (192,192,192,1) ;
  
  x = canvas_width / 100 ;
  if (canvas_width > 600)
  {
    dy = Math.floor ((radius_legend + 2) * 2.2) ;
    canvas_width < 800 ? dy -= 2 : canvas_width < 900 ? dy -= 1 : dy = dy ;
    y = show_help ? canvas_height / 2 - 7 * dy : canvas_height / 4 - 15 ;
  }
  else
  {
    dy = Math.floor ((radius_legend + 2) * 2.2) ;
    if (dy < 8) { dy = 8 ; }
    y = 0 ;
  }
  
  
  
  if ((! show_help) && (show_pop_density == show_pop_not))
  {
    if (show_mode == show_views)
    {
      ctxWriteZ (10, y+=dy, "x 1000 views/sq km") ;
      for (v = 0 ; v <= views_per_cell_high ; v += views_per_cell_inc)
      { addLegendViews (x,y+=dy,v) ; }
 
      y += dy ;
      ctxWriteZ (x, y+=dy, "Continuous scale.") ;
      ctxWriteZ (x, y+=dy, "> 150 topped out.") ;
      ctxWriteZ (x, y+=dy, "Black = no data") ;
    }
    else
    if (show_mode == show_perc_mobile)
    {
      ctxWriteZ (x, y+=dy, "Mobile share") ;
      for (perc = 0 ; perc <= 15 ; perc += 3)
      { addLegendPercMobile (x,y+=dy,perc) ; }

      y += dy ;
      ctxWriteZ (x, y+=dy, "Continuous scale.") ;
      ctxWriteZ (x, y+=dy, "> 15% topped out.") ;
      ctxWriteZ (x, y+=dy, "Black = no data") ;
 
      y += dy ;
    }
    else
    if (show_mode == show_heatmap)
    { // qq1
      ctxWriteZ (x, y+=dy, "Edits per day/sq 1/8 deg") ;
      addLegendEdits (x,y+=dy,2,'1-5') ; 
      addLegendEdits (x,y+=dy,7,'5-10') ; 
      addLegendEdits (x,y+=dy,15,'10-20') ; 
      addLegendEdits (x,y+=dy,30,'20-40') ; 
      addLegendEdits (x,y+=dy,50,'40+') ; 
      y += dy ;
    }
    else
    {
      for (l = 0 ; l < color_max ; l++)
      { addLegendLanguage (x,y+=dy, langcodes [l]) ; }
      addLegendLanguage (x,y+=dy, 'rest') ; 
  
      y += dy ;
    }  
  }  
  
  if (show_pop_density == show_pop_full)
  {
    ctxWriteZ           (x-3,   y+=dy, "People/sq km") ;
    addLegendPopulation (x,y+=dy, '255,253,133', '1-5') ; 
    addLegendPopulation (x,y+=dy, '255,219,90', '5.1-25') ; 
    addLegendPopulation (x,y+=dy, '245,187,61', '25.1-50') ; 
    addLegendPopulation (x,y+=dy, '215,135,24', '50.1-100') ; 
    addLegendPopulation (x,y+=dy, '160,68,19', '100.1-250') ; 
    addLegendPopulation (x,y+=dy, '109,6,0', '250+') ; 
    y += dy ;
  }
  
  
  x -= 3 ;
  
  if (show_help)
  { 
    if (canvas_width < MIN_CANVAS_WIDTH_MENU_TOP_LEFT)
    {
      ctxWriteZ (x,   y+=dy, "CONTENT") ;
      ctxWriteZ (x+1, y    , "CONTENT") ;
      ctxWriteZ (x,   y+=dy, "1 = Edits: Animation") ;
      ctxWriteZ (x,   y+=dy, "2 = Edits: Bubble map") ;
      ctxWriteZ (x,   y+=dy, "3 = Edits: Heat map") ;
      ctxWriteZ (x,   y+=dy, "4 = Views: Heat map") ;
      ctxWriteZ (x,   y+=dy, "5 = Mobile Ratio: Heat map") ;
      y += dy ;
    }  
    
    ctxWriteZ (x,   y+=dy, "INTERFACE") ;
    ctxWriteZ (x+1, y,     "INTERFACE") ;
    ctxWriteZ (x,   y+=dy, "+-= zoom in/out") ;
    show_mode == show_animation ? ctxFillStyle (192,192,192,1) : ctxFillStyle (96,96,96,1) ;
    ctxWriteZ (x,   y+=dy, "<>= animation slower/faster") ;
    color_map [show_mode] == COLOR ?  ctxFillStyle (192,192,192,1) : ctxFillStyle (96,96,96,1) ;
    ctxWriteZ (x,   y+=dy, "B = dim Background") ;
    ctxFillStyle (192,192,192,1) ;
    ctxWriteZ (x,   y+=dy, "C = s/h Cities") ;
    show_mode == show_animation ? ctxFillStyle (192,192,192,1) : ctxFillStyle (96,96,96,1) ;
    ctxWriteZ (x,   y+=dy, "D = s/h population density") ;
    ctxWriteZ (x,   y+=dy, "E = change Event marker") ;
    ctxWriteZ (x,   y+=dy, "F = Forward clock one hour") ;
    show_mode >= show_heatmap ? ctxFillStyle (96,96,96,1) : ctxFillStyle (192,192,192,1) ;
    ctxWriteZ (x,   y+=dy, "G = grid cell size") ;   
    ctxWriteZ (x,   y+=dy, "M = toggle color/b&w Map") ;   
    ctxFillStyle (192,192,192,1) ;
    ctxWriteZ (x,   y+=dy, "N = Next language *") ;
    show_mode == show_animation ? ctxFillStyle (192,192,192,1) : ctxFillStyle (96,96,96,1) ;
    ctxWriteZ (x,   y+=dy, "P = Pause") ;   
//  ctxWriteZ (x,   y+=dy, "R = Reset clock") ;
    ctxWriteZ (x,   y+=dy, "S = marker Size") ;
    ctxWriteZ (x,   y+=dy, "U = s/h sUn") ;
    ctxWriteZ (x,   y+=dy, "T = s/h local Time") ;
//  ctxFillStyle (192,192,192,1) ;
//  ctxWriteZ  (x,   y+=dy, "X = save settings") ;

    if (show_debug)
    { ctxWriteZ (x, y+=dy, "Z = s/h Debug info") ; }

    ctxFillStyle (128,128,128,1) ; 
    
    ctxWriteZ (x, y+=dy, "s/h = show/hide") ;
    ctxWriteZ (x, y+=dy, "* = also space bar") ;
  }  

  help_color += 0.05 ;
  r= g= b= 63 + Math.abs (Math.round (192 * Math.sin (help_color))) ;
  ctxFillStyle (r,g,b,1) ;
  if (show_help)
  { ctxWriteZ  (x, y+=2*dy, "L = legend") ; }
  else  
  { ctxWriteZ  (x, y+=dy, "H = help") ; }
  
  ctxTextBorder (-1) ;
}

function drawZoomBox ()
{
  if (canvas_width < 600) { return ; }
  
  w = canvas_width / 50 ;
  if (w > 30) { w = 30 ; }
  h = w ;
  x = w / 5 ;
  y = canvas_height - h * 2 ;
  ctxLineWidthZ  (1) ;  
  ctxFontSize    (14);   

  ctxFillStyle   (48,48,48,1) ; 
  ctxStrokeStyle (128,128,128,1) ; 
  ctxDrawBoxZ    (x,  y,w,h) ;
  button_plus = {x:x+1,   y:y+1, w:w-2, h:h-2} ;

// + button (don't use write, as rounding errors make text wobble on zoom)   
  zoom_factor == 4 ? ctxFillStyle   (48,96,48,1)  : ctxFillStyle     (0,200,0,1) ; 
  zoom_factor == 4 ? ctxStrokeStyle (48,96,48,1)  : ctxStrokeStyle   (0,200,0,1) ; 
  ctxFillStyle   (48,48,48,1) ; 
  ctxDrawBoxZ    (x+w/2-5,y+h/2,9,1.5) ;
  ctxDrawBoxZ    (x+w/2-1.5,y+h/2-4,1.5,9) ;

//- button
  ctxFillStyle   (48,48,48,1) ; 
  ctxStrokeStyle (128,128,128,1) ; 
  ctxDrawBoxZ    (x+w,y,w,h) ;

  button_min  = {x:x+1+w, y:y+1, w:w-2, h:h-2} ;
  zoom_factor == 1 ? ctxFillStyle   (80,80,80,1) : ctxFillStyle     (0,200,0,1) ; 
  zoom_factor == 1 ? ctxStrokeStyle (80,80,80,1) : ctxStrokeStyle   (0,200,0,1) ; 
  ctxDrawBoxZ    (x+w+w/2-4,y+h/2,9,1.5) ;

  ctx.textBaseline = 'middle' ;  
 
  font_size = canvas_width / 150 ;
  if (font_size > 10) { font_size = 10 ; }
  if (font_size <  7) { font_size =  7 ; }
  ctxFontSize (font_size) ;
  ctxFontSizeBodyText ;
  ctxFillStyle   (128,200,128,1) ;

  x = x+w*2+4 ;
  y = y+h/2+2 ;
  text = sprintf ("%.1f",zoom_factor) + 'x' ; 
  
  ctxTextBorder  (0,0,0) ;
  ctxFillStyle   (128,200,128,1) ;
  ctxWriteZ      (x,y,text) ;
  ctxTextBorder  (-1) ;
}

function addLegendLanguage (x,y,lang) 
{
  if (show_mode > 1)
  { c = setColors (lang, 1, 1) ; } // TRANSPARENCY_FILL, TRANSPARENCY_LINE) ; }
  else
  { c = setColors (lang, 1, 1) ; } //TRANSPARENCY_FILL, TRANSPARENCY_LINE) ; }
  
  ctxLineWidthZ  (radius_legend / 5) ;
  ctxStrokeStyle (0,0,0,1) ;
  ctxCircleZ     (x,y,radius_legend,c) ;
  
  ctxFillStyle (192,192,192,1) ;
  dx = 5+canvas_width  / 200 ;
  ctxWriteZ (x+dx, y+5, languages [lang]) ;
}

function addLegendPopulation (x,y,rgb,text) 
{
  ctxLineWidthZ  (radius_legend / 5) ;
  ctxStrokeStyle (0,0,0,1) ;
  ctxCircleZ     (x,y,radius_legend,setColor(rgb)) ;
  
  ctxFillStyle (192,192,192,1) ;
  dx = 5+canvas_width  / 200 ;
  ctxWriteZ (x+dx, y+5, text) ;
}

function addLegendEdits (x,y,edits,text) 
{
  ctxLineWidthZ  (radius_legend / 5) ;
  ctxStrokeStyle (0,0,0,1) ;
  ctxCircleZ     (x,y,radius_legend, setColor (setColorEdits (edits, language_selected))) ;
  
  ctxFillStyle (192,192,192,1) ;
  dx = 5+canvas_width  / 200 ;
  ctxWriteZ (x+dx, y+5, text) ;
}

function addLegendViews (x,y,views) 
{
  ctxLineWidthZ  (radius_legend / 5) ;
  ctxStrokeStyle (0,0,0,1) ;
  ctxCircleZ     (x,y,radius_legend,setColor (setColorViews (views))) ;

  ctxFillStyle (192,192,192,1) ;
  dx = 5+canvas_width  / 200 ;
  ctxWriteZ (x+dx, y+5, sprintf ("%.0f", views)) ;
}

function addLegendPercMobile (x,y,perc_mobile) 
{
  ctxLineWidthZ  (radius_legend / 5) ;
  ctxStrokeStyle (0,0,0,1) ;
  ctxCircleZ     (x,y,radius_legend,setColor (setColorPercMobile (perc_mobile))) ;

  ctxFillStyle (192,192,192,1) ;
  dx = 5+canvas_width  / 200 ;
  ctxWriteZ (x+dx, y+5, perc_mobile + ' %') ;
}

function drawTitle () 
{
  color_map [show_mode] == COLOR ? ctxTextBorder (0,0,0) : ctxTextBorder (-1) ;

  ctxTextAlignLeft () ;

  canvas_width > 1000 ? ctxFontSize (12) : canvas_width > 700 ? ctxFontSize (10) :  ctxFontSize (8);   
  
  color_map [show_mode] == COLOR ? ctxFillStyle (192,192,192,1) : ctxFillStyle (128,128,128,1) ;

  hint  = 'H = Help ' ; 
  
  if (language_selected == 'rest')
  { language_name = 'other languages' ; }
  else
  if (language_selected == 'all')
  { language_name = 'all languages' ; }
  else
  { language_name = languages [language_selected] + ' Wikipedia' ; }
  
  switch (show_mode)
  {
    case show_animation :
      if (show_one_language == 1)
      { 
        title = 'Wikipedia edits for ' ; 
        drawTitleColored (title,language_name,'','rgb(180,180,180)',setColorLang (language_selected),'') ;
      }
      else
      { 
        title = 'Wikipedia edits on ' + show_date + ' - ' ; 
        drawTitleColored (title,conv_time2hhmm (clock),sprintf ("%02d GMT - speed %.0fx",clock % 60, speed_up_desired), 
        'rgb(180,180,180)','rgb(210,210,210)','rgb(210,210,210)') ;
      }
  
      ctxFontSizeBodyText () ;
      ctxFillStyle   (200,200,200,1) ;
      ctxStrokeStyle (200,200,200,1) ;
      ctxTextAlignRight () ;
      text_width = ctxTextWidth ('60 seconds edit activity') ;
      
      // stabilize on screen speed display
      if ((speed_up_measured > speed_up_desired * 0.9) &&
          (speed_up_measured < speed_up_desired * 1.1))
      { speed_up_measured2 = speed_up_desired ; } 
      else    
      { speed_up_measured2 = speed_up_measured ; }
      
      if (canvas_width > 600)
      {
        ctxWriteZ (canvas_width - 5, 10, '1 second animation shows') ; 
        ctxWriteZ (canvas_width - 5, 22, sprintf ("%.0f", speed_up_measured2) + ' seconds edit activity') ; 
      }  
      
      if ((show_one_language == 0) && (canvas_width > 800))
      { ctxWriteZ (canvas_width - 5, 34, '(avg ' + sprintf ("%.0f", (tot_edits / 1440)) + ' edits/min)' ) ; }

      ctxTextAlignLeft () ;
    break ;
    
    case show_distrib: 
      if (language_selected == 'composite')
      {
        title = 'Bubble map - spatial distribution for ' ;
        total = '(' + tot_count ['all'] + ' total in one day)' ;
        drawTitleColored (title,'most edited language version ',total,'rgb(180,180,180)','rgb(210,210,210)','rgb(180,180,180)') ;
      }
      else
      {
        title = 'Bubble map - spatial distribution of edits for ' ;
        total = '(' + tot_count [language_selected] + ' total in one day)' ;
        drawTitleColored (title,language_name,total,'rgb(180,180,180)',setColorLang (language_selected),'rgb(180,180,180)') ;
      }  
        title = 'Bubble map - spatial distribution of edits for ' ;
    break ;
    
    case show_heatmap: 
      if (language_selected == 'composite')
      {
        title = 'Heat map - spatial distribution for ' ;
        total = '(' + tot_count ['all'] + ' total in one day)' ;

        drawTitleColored (title,'most edited language version ',total,'rgb(180,180,180)','rgb(210,210,210)','rgb(180,180,180)') ;
      }
      else
      {
        title  = 'Heat map - spatial distribution of edits for ' ;
        total = '(' + tot_count [language_selected] + ' total in one day)' ;
        drawTitleColored (title,language_name,total,'rgb(180,180,180)',setColorLang (language_selected),'rgb(180,180,180)') ;
      }  
    break ;

    case show_views: 
      tot_views_M = sprintf ("%.0f", tot_views / 1000) ; // not / 1000000!, input is 1:1000 sampled
      drawTitleColored ('Wikipedia page views in ' + name_month + ' - ' , 'on average ' + tot_views_M + ' million per day','','rgb(180,180,180)','rgb(210,210,210)','rgb(180,180,180)') ;
    break ;

    case show_perc_mobile: 
      perc_mobile = sprintf ("%.1f", 100 * tot_views_mobile / tot_views) ;
      drawTitleColored ('Wikipedia page views in ' + name_month + ' - ' ,'mobile share (' + perc_mobile + '% overall) ','','rgb(180,180,180)','rgb(210,210,210)','rgb(180,180,180)') ;
    break ;

  }   

  if (canvas_width >= MIN_CANVAS_WIDTH_MENU_TOP_LEFT)
  {
    ctxFillStyle (180,180,180,1) ;
    ctxFontSizeBodyText () ;
    ctxWriteZ (5, 12, "1 = Edits, Animation") ;
    ctxWriteZ (5, 25, "2 = Edits, Bubble map") ;
    ctxWriteZ (5, 38, "3 = Edits, Heat map") ;
    ctxWriteZ (5, 51, "4 = Views") ;
    ctxWriteZ (5, 64, "5 = Mobile Share") ;
  }  

  ctxTextBorder  (-1) ;
}

function drawTitleColored (title1,title2,title3,color1,color2,color3) 
{
  text_baseline_prev = ctx.textBaseline ;
  ctx.textBaseline = 'ideographic' ;

  y = Math.round (canvas_width / 70) ;
  if (canvas_width < 600) y+=2 ;
  if (canvas_width < 500) y+=2 ;

  font_size_title = canvas_width / 100 ;
  if (font_size_title < 8)
  { font_size_title = 8 ; }
  

  ctxFontSize (font_size_title * zoom_factor) ; // measure width in unscaled font,scaling happens in ctxWriteZ
  text_width_x1 = ctxTextWidth (title1) ;
  text_width_x2 = ctxTextWidth (title2) ;
  ctxFontSize (font_size_title * 0.8 * zoom_factor) ; 
  text_width_x3 = ctxTextWidth (title3) ;
  ctxFontSize (font_size_title) ; 

  if ((show_pop_density == show_pop_not) || (show_pop_density == show_pop_full))
  { 
    x1 = canvas_width / 2 - (text_width_x1 + text_width_x2 + text_width_x3)/ 2 ; 
    ctxTextAlignCenter () ;
  }
  else 
  if (show_pop_density == show_pop_left)
  { 
    x1 = canvas_width / 2 + 20 ;
    ctxTextAlignLeft () ;
  }
  else
  if (show_pop_density == show_pop_right)
  { 
    x1 = canvas_width / 2 - 20  - text_width_x1 - text_width_x2 - text_width_x3 ;
    ctxTextAlignLeft () ;
  }


  if (show_pop_density != show_pop_full)
  {
    ctxTextAlignLeft () ;
    x2 = x1 + text_width_x1 ;
    x3 = x2 + text_width_x2 + 4 ;

    ctx.fillStyle   = color1 ;
    ctx.strokeStyle = color1 ;
    ctxWriteZ (x1,   y, title1) ;
    if (canvas_width > 800)
    { ctxWriteZ (x1+1/zoom_factor, y, title1) ; } // -> bold
  
    ctx.fillStyle   = color2 ;
    ctx.strokeStyle = color2 ;
    ctxWriteZ (x2,   y, title2) ;
    if (canvas_width > 800)
    { ctxWriteZ (x2+1/zoom_factor, y, title2) ; } // -> bold
  
    if (title3 != '')
    {
      ctxFontSize (font_size_title * 0.8) ;   
      ctx.fillStyle   = color3 ;
      ctx.strokeStyle = color3 ;
      ctxWriteZ (x3,   y, title3) ;
    }
  }  
  
  ctxFontSize (font_size_title) ; 
  ctx.fillStyle   = color1 ;
  ctx.strokeStyle = color1 ;
  if (show_pop_density == show_pop_left)
  { 
    x1 = canvas_width / 2 - 20 ; 
    ctxTextAlignRight () ;
    ctxWriteZ (x1, y, 'Population density 2010') ;
    if (canvas_width > 800)
    { ctxWriteZ (x1+1/zoom_factor, y,  'Population density 2010') ; } // -> bold
  }
  else 
  if (show_pop_density == show_pop_right)
  { 
    x1 = canvas_width / 2 + 20 ; 
    ctxTextAlignLeft () ;
    ctxWriteZ (x1, y, 'Population density 2010') ;
    if (canvas_width > 800)
    { ctxWriteZ (x1+1/zoom_factor, y,  'Population density 2010') ; } // -> bold
  }
  else 
  if (show_pop_density == show_pop_full)
  { 
    x1 = canvas_width / 2  ; 
    ctxTextAlignCenter () ;
    ctxWriteZ (x1, y, 'Population density 2010') ;
    if (canvas_width > 800)
    { ctxWriteZ (x1+1/zoom_factor, y,  'Population density 2010') ; } // -> bold
  }

  x2 = x1 + text_width_x1 ;
  x3 = x2 + text_width_x2 + 4 ;
  
}  

function drawCredits () 
{
  if (canvas_width < 450) { return ; }
  
  if (color_map [show_mode] == COLOR)
  {
    ctxTextBorder (200,200,200) ;
    ctxFillStyle  (0,0,0,1) ;
    
    if ((show_pop_density == show_pop_not) || (show_pop_density == show_pop_full)) 
    { credits = 'Erik Zachte 2011 - Map NASA' ; }
    else 
    { credits = 'Map NASA - Erik Zachte 2011 - Map NASA' ; }
  }
  else
  { 
    ctxFillStyle (127,127,127,1) ;
    if (show_pop_density == show_pop_not)
    { credits = 'Erik Zachte 2011 - Map thematicmapping.org' ; }
    else 
    if (show_pop_density == show_pop_left)
    { credits = 'Map SEDAC - Erik Zachte 2011 - Map thematicmapping.org' ; }
    else 
    if (show_pop_density == show_pop_right)
    { credits = 'Map thematicmapping.org - Erik Zachte 2011 - Map SEDAC' ; }
    else
    { credits = 'Erik Zachte 2011 - Map SEDAC' ; }
  }  

  canvas_width > 1000 ? ctxFontSize (10) : canvas_width > 700 ? ctxFontSize (8) :  ctxFontSize (7);   

  ctx.textBaseline = 'ideographic' ; 
  ctxTextAlignCenter () ;

  x = canvas_width / 2 ;
  if ((! show_clocks) || (canvas_width < 600) || (show_mode != show_animation) || (show_pop_density != show_pop_not))
  { y = canvas_height - 5 ; }  
  else
  { y = canvas_height - canvas_height / 40 - 6 ; }

  ctxWrite (x,y,   credits) ;
  ctxTextBorder (-1) ;
}  

function drawNotice ()
{
  now = new Date() ;

  if (now.getTime () - notice_added > notice_duration * 1000)
  { 
    if (setup_phase == 3)
    {
      if (notice_text == 'No input received')
      {
        color_map [show_mode] = COLOR ; 
        show_edits  = 1 ;
        setup_phase = 4 ; 
      }
      else
      { 
        setNotice (3, 'No input received') ; 
        return ;
      }
    }  

    notice_added = 0 ; 
    notice_text = '' ;
  }

  if (notice_text == '')
  { return ; }
  
  notice_text_segments = notice_text.split('|') ; 
  ctxFontSizeNotice () ;

  h = imgmap.width / 1000 ; // font size , temp Q&D

  x = canvas_width / 2 ; 
  
  
  if (setup_phase > 1)
  { y = (canvas_height - h) * 0.17 ; } // in ocean
  else
  { y = (canvas_height - h) * 0.8 ; } // in ocean

  ctx.textBaseline = 'bottom' ; 
  ctxFillStyle   (255,255,0,1) ;
  ctxStrokeStyle (255,255,0,1) ;
  ctxTextAlignCenter () ;
  
  for (var l = 0, len = notice_text_segments.length ; l < len; l++)
  {
    if (notice_text_segments [l] != '')
    {
      ctxWriteZ (x, y, notice_text_segments [l]) ;
      if (canvas_width > 800)
      { ctxWriteZ (x+1 / zoom_factor, y, notice_text_segments [l]) ; } // bold
    }  
    y += canvas_height / 30 + 2 ;
  }  
}

function drawSun (time)
{  
  if (! show_sun) { return ; }  // condition here to keep main tidy 
  if (show_pop_density != show_pop_not)  { return ; } 
  
  save_strokeStyle = ctx.strokeStyle ;
  save_fillStyle   = ctx.fillStyle ;

  ctxFillStyle (200,180,00,1) ;

  x = canvas_width - ((clock / SEC_IN_DAY) * canvas_width) ;
  ctxDrawBox (x-5,0,10,3) ;
  ctxDrawBox (x-5,canvas_height-3,10,3) ;

  if (color_map [show_mode] == COLOR)
  { 
    if (canvas_width > 1000)
    { ctxLineWidth (3 / zoom_factor) ; ctx.strokeStyle = "rgba(255,255,0,0.2)" ; }
    else
    { ctxLineWidth (2 / zoom_factor) ; ctx.strokeStyle = "rgba(255,255,0,0.4)" ; }
  }  
  else
  { 
    if (canvas_width > 1000)
    { ctxLineWidth (3 / zoom_factor) ; ctx.strokeStyle = "rgba(128,128,0,0.2)" ; }
    else
    { ctxLineWidth (2 / zoom_factor) ; ctx.strokeStyle = "rgba(1285,128,0,0.4)" ; }
  }  
  
  ctxLine (x,0,x,canvas_height-1)
  ctxLineWidth (2 / zoom_factor) ; 

  ctx.strokeStyle = save_strokeStyle ;
  ctx.fillStyle   = save_fillStyle ;
}

function drawClocks ()
{
  if (! show_clocks) { return ; }  // condition here to keep main tidy 
  if (show_pop_density != show_pop_not)  { return ; } 
  if (canvas_width < 600) { return ; }
  
  ctx.textBaseline = 'ideographic' ;
  
  ctx.strokeStyle = "rgba(0,0,0,0)" ;
  ctxFontSize (7) ;   

  if (color_map [show_mode] == COLOR)
  { 
    ctxTextBorder (200,200,200) ;
    ctxFillStyle (63,63,63,1) ;
  }
  else
  {
    ctxFillStyle  (127,127,127,1) ;
  }  

  time = clock ;
  x = canvas_width / 2 - canvas_width / 24 - canvas_width / 48;
  for (zone = 0 ; zone <= 23 ; zone ++)
  {
    x = (x + canvas_width / 24) % canvas_width ;
    timehhmm = conv_time2hhmm (time) ;
    ctxWrite (x - 15, canvas_height - 3, timehhmm) ; 
    // ctxWrite (x - 14, canvas_height - 3, timehhmm) ;  // bold
    (time = (time + 3600 % SEC_IN_DAY) % SEC_IN_DAY) ;
  }  
   ctxTextBorder (-1) ;
}  

function drawMouseInfo ()
{
  // show coordiantes only when mouse down, inside map area, and map completely zoomed out
  // bug: coordinates are wrong on zoomed in map, that's fine for now, mouse is used for dragging then
  
  if (! mouse_down || ! mouse_in || zoom_factor > 1) { return ; } 
  
//  if (mouse_box_in_map == 0) { return ; }
  ctx.textBaseline = 'middle' ;  
  
  show_debug ? bw_plus = 300 : bw_plus = 0 ;


  ctxFillStyle   (192,192,192,1) ; 
  ctxStrokeStyle (63,63,63,1) ; 
  ctxDrawBoxZ (mouse_box_bx, mouse_box_by, mouse_box_bw+bw_plus, mouse_box_bh) ;
   
  ctxFontSize (8);   
  if (mouse_box_left)
  { ctxTextAlignRight () ; }
   
  ctxFillStyle   (0,0,0,1) ; 
  ctxStrokeStyle (255,255,255,1) ; 

  ctxWriteZ (mouse_box_tx, mouse_box_ty,      mouse_box_lat) ;
  ctxWriteZ (mouse_box_tx, mouse_box_ty + 14, mouse_box_long) ;

  if (mouse_box_left)
  { ctxTextAlignLeft () ; }
}

function drawDebugInfo ()
{
  if (! show_debug) { return ; }  // condition here to keep main tidy 

  ctxFillStyle (255,255,255,1) ;
  ctxStrokeStyle (0,0,0,1) ; 
  ctxFontSize (10) ;

  x = canvas_width / 2 - 100 ;
  y = canvas_height * 0.4 ;
  
  if (show_mode == show_animation)
  {
    ctxWriteZ (x,y+=20, "Image size: " +canvas.width + ' x ' + canvas_height + " px") ;     
    ctxWriteZ (x,y+=20, frames_shown + ' frames in ' + sprintf ("%.0f", msecs_per_frame) + ' msecs/frame') ; 
    ctxWriteZ (x,y+=20, sprintf ("%.1f", frames_per_sec) + ' frames/sec, speed_up_desired: ' + speed_up_desired) ;
    ctxWriteZ (x,y+=20, 'clock_delta: ' + sprintf ("%.2f", clock_delta) + ', edits shown: ' + edits_shown) ;
    ctxWriteZ (x,y+=20, 'max: ' + radius_max + ', min: ' + radius_min + ', shrink: ' + sprintf ("%.2f", fade_factor) + ' events drawn: ' + sprintf ("%.0f", events_drawn_trend)) ;
    ctxWriteZ (x,y+=20, 'max_count [en]: ' + max_count_trace ['en'] + ', max_count [de]: ' + max_count_trace ['de']) ;
    ctxWriteZ (x,y+=20, 'ctx.font: ' + ctx.font) ; 
    ctxWriteZ (x,y+=20, 'navigator.appVersion: ' + navigator.appVersion) ; 
  }  
//ctxWriteZ (x,y+=20, mouse_box_bx + ',' + mouse_box_by + ' - ' + mouse_box_bw + ' x ' + mouse_box_bh) ;
}

function addCities ()
{
  l = 'l' ;
  r = 'r' ;
  w = 'w' ;
  g = 'g' ;
  b = 'b' ;
  // http://en.wikipedia.org/wiki/World%27s_largest_cities
  addCity (1,l,g,"Vancouver", "49°25′N 123°6′W",0,0) ;  
  addCity (1,l,w,"Montreal", "45°30′N 73°33′W",7,-13) ;  
  addCity (7,r,w,"Calgary", "51°02′N 114°03′W",0,0) ;  
  addCity (1,l,w,"Edmonton", "53°34′N 113°31′W",0,-3) ;  
  addCity (1,l,w,"Ottawa", "45°25′N 75°41′W",0,-5) ;  
  addCity (1,r,g,"Toronto", "43°42′N 79°20′W",0,0) ;  
  addCity (1,r,g,"Quebec", "46°49′N 71°13′W",0,-10) ;  

  addCity (1,r,g,"New York", "40°43′N 74°0′W",0,0) ;
  addCity (1,l,g,"San Francisco", "37°46′N 122°25′W",0,0) ;
  addCity (6,l,g,"Los Angeles", "34°03′N 118°15′W",0,0) ;  
  addCity (1,l,w,"Chicago", "41°52′N 87°37′W",0,0) ;  
  addCity (7,r,w,"Houston", "29°45′N 95°22′W",0,-5) ;  
  addCity (1,l,w,"Philadelphia", "39°57′N 75°10′W",0,5) ;  
  addCity (1,l,g,"San Diego", "32°42′N 117°9′W",0,7) ;  
  addCity (1,r,w,"San Antonio", "29°25′N 98°30′W",-10,8) ;  
  addCity (1,r,w,"Phoenix", "33°27′N 112°4′W",0,0) ;  
  addCity (7,r,w,"Dallas", "32°47′N 96°48′W",0,-7) ;  
  addCity (1,r,w,"San Jose", "37°20′N 121°53′W",0,-30) ;  
  addCity (7,r,w,"Detroit", "42°20′N 83°03′W",0,0) ;  

  addCity (1,l,g,"Mexico City", "19°26′N 99°8′W",0,0) ;  
  addCity (1,l,g,"Guatemala City", "14°37′N 90°32′W",0,0) ;  

  addCity (1,l,g,"Santo Domingo", "18°30′N 69°59′W",0,0) ;  
  addCity (1,l,g,"Havana", "23°08′N 82°23′W",0,0) ;  

  addCity (1,r,g,"Buenos Aires", "34°36′S 58°22′W",-9,12) ;    
  addCity (1,r,g,"Rio de Janeiro", "22°54′S 43°11′W",0,0) ;  
  addCity (1,l,g,"Santiago", "33°27′S 70°40′W",0,0) ;  
  addCity (1,l,w,"Brasilia", "15°48′S 47°54′W",0,0) ;  
  addCity (1,r,g,"São Paulo", "23°33′S 46°38′W",-10,10) ;
  addCity (1,l,g,"Lima", "12°2′S 77°1′W",0,0) ;  
  addCity (1,r,w,"Bogota", "4°35′N 74°4′W",0,0) ;  
  addCity (1,r,g,"Salvador", "12°58′S 38°28′W",0,0) ;  
  addCity (1,r,g,"Belo Horizonte", "19°55′S 43°56′W",0,-5) ;  
  addCity (1,r,g,"Fortaleza", "3°77′S 38°57′W",-8,-8) ;  
  addCity (1,l,g,"Cali", "3°25′N 76°31′W",-6,0) ;  
  addCity (1,l,g,"Curitiba", "25°25′S 49°15′W",0,0) ;  
  addCity (1,l,g,"Manaus", "03°06′S 60°01′W",0,0) ;  
  addCity (1,r,g,"Recife", "8°3′S 34°54′W",0,0) ;  
  addCity (1,r,g,"Porto Alegre", "30°2′S 51°14′W",0,0) ;  
  addCity (1,r,g,"Montevideo", "34°53′S 56°10′W",0,-3) ;  

  addCity (1,l,g,"London", "51°30′N 0°7′W",0,0) ;
  addCity (1,l,g,"Paris", "48°51′N 2°21′E",0,5) ;
  addCity (1,r,g,"Berlin", "52°30′N 13°23′E",0,0) ;
  addCity (1,r,g,"A'dam", "52°22′N 4°53′E",-10,-10) ;
  addCity (1,l,g,"Madrid", "40°24′N 3°41′W",5,-5) ;
  addCity (1,r,g,"Milan", "45°27′N 9°11′E",0,0) ;
  addCity (1,l,g,"Lisbon", "38°42′N 9°8′W",0,0) ;
//  addCity (1,l,g,"Barcelona", "40°24′N 3°41′W",0,0) ;
//  addCity (1,l,g,"Athens", "40°24′N 3°41′W",0,0) ;
//  addCity (1,l,g,"Rome", "40°24′N 3°41′W",0,0) ;
//  addCity (1,l,g,"Warsaw", "40°24′N 3°41′W",0,0) ;
//  addCity (1,l,g,"Ruhr area", "40°24′N 3°41′W",0,0) ;

  addCity (1,r,g,"Moscow", "55°45′N 37°37′E",-17,7) ;
  addCity (1,r,g,"Saint Petersburg", "59°57′N 30°19′E",-8,-10) ;
  addCity (1,r,g,"Novosibirsk", "55°01′N 82°56′E",0,0) ;
  addCity (1,r,g,"Nizhny Novgorod", "56°20′N 44°00′E",-22,-10) ;
  addCity (1,r,g,"Yekaterinberg", "56°50′N 60°35′E",-4,-5) ;
  addCity (1,r,g,"Samara", "53°14′N 50°10′E",-2,2) ;
  addCity (1,r,g,"Omsk", "54°59′N 73°22′E",0,0) ;
  addCity (1,r,g,"Kazan", "55°47′N 49°10′E",0,0) ;
  addCity (1,r,g,"Krasnoyarsk", "56°01′N 93°04′E",0,0) ;
//addCity (1,r,g,"Perm", "58°0′N 56°19′E",0,0) ;

  addCity (1,r,w,"Bejing", "39°54′N 116°23′E",-10,-10) ;
  addCity (1,l,w,"Shanghai", "31°12′N 121°30′E",4,5) ;
  addCity (1,l,w,"Zhumadian", "32°59′N 114°02′E",0,-5) ;
  addCity (1,l,w,"Nanchong", "31°15′N 106°14′E",9,7) ;
  addCity (1,l,w,"Tai'an", "36°10′N 117°07′E",2,-5) ;
  addCity (1,l,w,"Guanghzou", "23°7′N 113°15′E",0,-6) ;
  addCity (1,l,w,"Hong Kong", "22°17′N 114°09′E",0,6) ;
  
  addCity (1,r,g,"Taipei", "25°2′N 121°38′E",0,0) ;
  addCity (1,r,g,"Seoul", "37°34′N 126°58′E",-18,-9) ;

  addCity (1,l,g,"Jakarta", "6°12′S 106°48′E",0,0) ;
  addCity (1,r,g,"Manila", "14°35′N 120°58′E",5,0) ;  

  addCity (1,r,b,"Karachi", "24°51′N 67°0′E",-25,-10) ;  
  addCity (1,r,b,"Delhi", "28°36′N 77°12′E",-17,10) ;
  addCity (1,l,g,"Mumbai", "18°58′N 72°49′E",0,0) ;

  addCity (1,r,g,"Tokyo", "35°42′N 139°42′E",5,-15) ;
  addCity (1,r,g,"Osaka", "34°42′N 135°30′E",2,9) ;
  addCity (1,r,g,"Yokohama", "35°27′N 139°38′E",3,-6) ;
  addCity (1,r,g,"Nagoya", "35°10′N 136°54′E",5,0) ;
  addCity (1,r,g,"Sapporo", "43°4′N 141°21′E",5,0) ;
  addCity (1,l,g,"Kobe", "34°41′N 135°12′E",9,7) ;
  addCity (1,l,g,"Kyoto", "35°0′N 135°46′E",15,-10) ;

  addCity (1,r,b,"Jerusalem", "31°47′N 35°13′E",-10,10) ;
  addCity (1,r,w,"Istanbul", "41°01′N 28°58′E",0,-7) ;
  addCity (1,r,w,"Ankara", "39°52′N 32°52′E",0,7) ;
  addCity (1,r,b,"Riyadh", "24°38′N 46°43′E",-10,10) ;
  addCity (1,l,g,"Dhaka", "23°24′N 90°22′E",8,-10) ;
  addCity (1,r,b,"Tehran", "35°41′N 51°25′E",0,5) ;
  addCity (1,r,g,"Bangkok", "13°45′N 100°29′E",0,-5) ;
  addCity (1,l,g,"Lahore", "31°33′N 74°20′E",0,0) ;
  addCity (1,l,b,"Kolkatta", "22°34′N 88°22′E",0,0) ;
  addCity (1,r,b,"Bhagdad", "33°20′N 44°26′E",-5,10) ;
  addCity (1,l,g,"Bangalore", "12°58′N 77°34′E",-8,0) ;
  addCity (1,r,g,"Chennai", "13°5′N 80°16′E",0,0) ;
  addCity (1,l,g,"Signapore", "1°17′N 103°50′E",0,0) ;

  addCity (1,l,b,"Cairo", "30°3′N 31°13′E",10,12) ;
  addCity (1,r,w,"Lagos", "6°27′N 3°23′E",-10,-10) ;  
  addCity (1,r,w,"Kinshasa", "4°19′N 15°19′E",-3,-3) ;  
  addCity (1,r,g,"Johannesburg", "26°12′S 28°2′E",0,0) ;
  addCity (1,r,w,"Karthoum", "15°38′N 32°32′E",-9,8) ;  
  addCity (1,l,b,"Alexandria", "31°12′N 29°55′E",5,7) ;  
  addCity (1,l,g,"Abidjan", "5°19′N 4°02′E",0,5) ;  
  addCity (1,l,b,"Casablanca", "33°32′N 7°35′E",8,7) ;  
  addCity (1,r,g,"Cape Town", "33°55′S 18°25′E",-20,9) ;  
  addCity (1,r,g,"Durban", "29°53′S 31°03′E",0,0) ;  
  addCity (1,l,g,"Accra", "5°33′N 0°12′E",0,-10) ;  
  addCity (1,l,w,"Nairobi", "1°17′N 36°49′E",7,7) ;  
  addCity (1,r,w,"Antananarivo", "18°56′S 47°31′E",5,0) ;  

  addCity (1,r,g,"Sydney", "33°51′S 151°12′E",0,0) ;
  addCity (1,r,g,"Melbourne", "37°49′S 144°57′E",-10,10) ;
  addCity (1,r,g,"Brisbane", "27°48′S 153°02′E",0,0) ;
  addCity (1,l,g,"Perth", "31°57′S 115°51′E",0,0) ;
  addCity (1,l,g,"Adelaide", "34°56′S 138°36′E",7,7) ;
  addCity (7,l,g,"Dunedin", "45°52′S 170°30′E",7,7) ;
  
  addCity (7,l,g,"Wellington", "41°17′S 174°46′E",0,0) ;
  addCity (1,l,g,"Auckland", "36°50′S 174°44′E",0,0) ;

//addCity (1,r,w,"Zero", "0°0′S 0°0′E",0,0) ;  // test only
}  

function addCity (show,align,color,name,pos,dx,dy)
{
  if (name == '') { return ; }
  // e.g. "40°43′N 74°0′W"  
  coord = pos.split (' ') ; 
  
  parts = coord [0].split ('°') ; deg = parts [0] ; parts = parts [1].split ('′') ; min = parts [0] ; dir = parts [1] ;
  lat = 1 * deg + min / 60 ; // 1 * = make numeric
  lat2 = lat ;
  if (dir == 'S')
  { lat2 = -lat ; }
//  chk (name  + ': ' + coord[0] + '-' + deg +'-'+ min +'-'+dir+' - ' + lat + ' - ' + lat2) ;
  
  parts = coord [1].split ('°') ; deg = parts [0] ; parts = parts [1].split ('′') ; min = parts [0] ; dir = parts [1] ;
  long = 1 * deg + min / 60 ;
  long2 = long ;
  if (dir == 'W')
  { long2 = -long ; }
//  chk (name  + ': ' + coord[1] + '-' + deg +'-'+ min +'-'+dir+' - ' + long + ' - ' + long2) ;

  x = Math.round (long2 * pixels_per_degree + canvas_width / 2) ;
  y = Math.round (canvas_height * (1 - (lat2 + 90) / 180)) ;
  
  cities [tot_cities++] = {show:show, align:align, color:color, name:name, pos:pos, long:long2, lat:lat2, x:x, y:y, dx:dx, dy:dy} 
}

function conv_time2hhmmss (time)
{
  hh = Math.floor (time / 3600) ;
  mm = Math.floor ((time - (hh * 3600)) / 60) ;
  ss = time - (hh * 3600) - (mm * 60) ;
  return (sprintf ("%02d:%02d:%02d",hh,mm,ss)) ;
}  

function clearTitleArea () 
{
  save_strokeStyle = ctx.strokeStyle ;
  save_fillStyle   = ctx.fillStyle ;

  ctx.strokeStyle = "rgba(255,255,0,0)" ;
  ctx.fillStyle = "rgba(11,10,50,1)" ;
  ctxDrawBox (0,0,canvas_width,22) ;

  ctx.strokeStyle = save_strokeStyle ;
  ctx.fillStyle   = save_fillStyle ;
}  

function drawMap ()
{
  // Nine arguments: the element, source (x,y) coordinates, source width and height (for cropping), 
  //                 destination (x,y) coordinates, and destination width and height (resize).
  // context.drawImage (img_elem, sx, sy, sw, sh, dx, dy, dw, dh);
  
  // opening sequence : present choice of presentation styles:
  if ((setup_phase >= 1) && (setup_phase <= 3))
  {
    ctx.drawImage(imgmap,   0, 0, 3000, 1500, 0, 0, canvas_width, canvas_height);               // draw black and white map
    ctx.drawImage(imgmapBW, 0, 0, 1600, 1500, 0, 0, canvas_width * (1600/3000), canvas_height); // overwrite slighly more than half with black and white map 
    return ;
  }  

  ctx.globalAlpha = 1 ;
  ctxStrokeStyle (0,0,0,1) ; 
  
  if (show_pop_density == show_pop_full) // show only density map
  { ctx.drawImage(imgmapPD,   0, 0, 3000, 1500, 0, 0, canvas_width, canvas_height); }
  else
//if ((show_pop_density != show_pop_not) && (zoom_factor == 1))
  if (show_pop_density != show_pop_not)
  { 
    if (color_map [show_mode] == COLOR)
    { ctx.drawImage(imgmap,   0, 0, 3000, 1500, 0, 0, canvas_width, canvas_height);  }
    else
    { 
      if (canvas_width * zoom_factor > 2000)
      { ctx.drawImage(imgmapBW,  0, 0, 3000, 1500, 0, 0, canvas_width, canvas_height); }
      else
      { ctx.drawImage(imgmapBWs, 0, 0, 1500,  750, 0, 0, canvas_width, canvas_height); }
    }

    if (show_pop_density == show_pop_left) // show population density in left half of screen
  //{ ctx.drawImage(imgmapPD, 1500, 0, 1500, 1500, 0,    0, canvas_width * (1500/3000), canvas_height); } // overwrite left half with population density map 
    { ctx.drawImage(imgmapPD, 1500 / zoom_factor, 0, 1500, 1500, 0,    0, canvas_width * (1500/3000), canvas_height); } // overwrite left half with population density map 
    else
    { ctx.drawImage(imgmapPD,    1500-1500/zoom_factor, 0, 1500, 1500, canvas_width * (1500/3000), 0, canvas_width * (1500/3000), canvas_height); } // overwrite right with population density map 
  }
  else
  {
    if (color_map [show_mode] == COLOR)
    { ctx.drawImage(imgmap,   0, 0, 3000, 1500, 0, 0, canvas_width, canvas_height);  }
    else
    { 
      if (canvas_width * zoom_factor > 2000)
      { ctx.drawImage(imgmapBW,  0, 0, 3000, 1500, 0, 0, canvas_width, canvas_height); }
      else
      { ctx.drawImage(imgmapBWs, 0, 0, 1500,  750, 0, 0, canvas_width, canvas_height); }
    }
  }  
  
  maps_drawn++ ;

  // test: mark center unzoomed image (lat 0, long 0)
  if (show_debug)
  {
    ctxFillStyle (255,255,0,1) ;
    ctxStrokeStyle (255,255,0,1) ;
    ctxDrawBoxZ (canvas_width_half - 1, canvas_height_half - 1, 3, 3) ; // test to show center of map
  }  
}

function drawMapShade () 
{
  if (color_map [show_mode] == B_W)
  { return ; }
  
  if (imgmap_transparency > 0)
  {
    save_lineWidth = ctx.ctxLineWidth ;
    ctxLineWidth (0) ; 
    if (show_mode >= show_heatmap)
    { ctxFillStyle (63,63,63,imgmap_transparency) ; }
    else
    { ctxFillStyle (192,192,192,imgmap_transparency) ; }
    ctxDrawBox (0,0,canvas_width-1,canvas_height-1) ;
    ctxLineWidth (save_lineWidth) ;
  }  
}

function conv_time2hhmm (time)
{
  hh = Math.floor (time / 3600) ;
  mm = Math.floor ((time - (hh * 3600)) / 60) ;
  return (sprintf ("%02d:%02d",hh,mm)) ;
}  

function calcMin (a,b)
{ if (a < b) { return (a) } else { return (b) } ; }

function calcMax (a,b)
{ if (a > b) { return (a) } else { return (b) } ; }


function calcSpeed ()
{
  time = new Date().getTime () ;

  if (frames_shown < 0) // start count
  {
    frames_shown = 0 ;
    time_frame_first = time ;
    time_prev_cs = time ;
    return ;
  }  

  frames_shown ++ ;
  time_diff = time - time_prev_cs ; 

  if (msecs_per_frame == 0) 
  { msecs_per_frame = time_diff ; }
  else
  if (time_diff < 30 * msecs_per_frame) // skip time keeping on lengthy operation , e.g. resize
  {
    msecs_per_frame = 0.95 * msecs_per_frame + 0.05 * time_diff ; 
    frames_per_sec = 1000 / msecs_per_frame ;  
    frames_per_clock_second = 1000 / INTERVAL ;
    speed_up_measured = clock_delta * frames_per_sec ;  
  }  
  else
  { lengthy_operations++ ; }
  time_prev_cs = time ;
}

function setCircleShrinkRate () 
{
  // make circle shrink from radius_max to radius_min in x frames ->
  // fade_factor = 
  //    ^ y  
  //  x     = z => x = y th root of z
  
  if (frames_per_sec > 0)
  { fade_factor = Math.pow (radius_min/radius_max, 1/frames_per_sec)  ; }
  

}

function rand (max)
{
  return (Math.floor (Math.random()* max)) ;
}

function setColor (rgb)
{
  if (! rgb)
  { rgb = '192,192,192' ; }
  line_color = "rgba(96,96,96," + TRANSPARENCY_LINE + ")" ; 
  fill_color = "rgb(" + rgb + ")" ; 
  return {f:fill_color, l:line_color} ;
}

function setColors (lang, transparency_fill, transparency_line)
{
  line_color = "rgba(96,96,96," + transparency_line + ")" ; 

  if (langindex [lang] >= color_max) 
  { lang = 'rest' ; } 
  
  rgb = colors [lang] ;
  if ((lang == 'rest') || (! rgb))
  { rgb = '192,192,192' ; }

  fill_color = "rgba(" + rgb + "," + transparency_fill + ")" ; 

  return {f:fill_color, l:line_color} ;
}      

function setColorLang (lang)
{
  if (langindex [lang] >= color_max) 
  { lang = 'rest' ; } 

  rgb = colors [lang] ;
  if (lang == 'rest')
  { rgb = '192,192,192' ; }

  return ("rgb(" + rgb + ")") ; 
}

function setColorEdits (edits, language_selected)
{ // qq2
       if  (edits <  2.01) { val = 25 ; }
  else if  (edits <  5.01) { val = 35 ; }
  else if  (edits < 10.01) { val = 48 ; }
  else if  (edits < 20.01) { val = 63 ; }
  else if  (edits < 40.01) { val = 80 ; }
  else { val = 100 ; }
        	
  sat = 100 ;
  if ((language_selected == 'rest') || (language_selected == 'all'))
  { sat = 0 ; }
  else if (langindex [language_selected] >= 20)
  { sat = 0 ; }
//else if (langindex [language_selected] >= 10)
//{ sat = 40 ; }
  
  hue = hues [language_selected] ;    
  
  return (conv_hsv2rgb (hue,sat,val)) ;
}  

function setColorViews (views)
{

//if (views > views_per_cell_high) { views = views_per_cell_high ; } // for now assume upper limit -> max 0.2% of overall views in one location
//hue = (360 + 240 - 240 * (views / views_per_cell_high)) % 360 ;
  if (views > views_per_cell_high) { views = views_per_cell_high ; } // for now assume upper limit -> max 0.2% of overall views in one location
  hue = (360 + 240 - 240 * (views / views_per_cell_high)) % 360 ;
  
// val = 100 ; 
  val = 70 + 30 * (views / views_per_cell_high) ;   
  sat = 100 ;
  return (conv_hsv2rgb (hue,sat,val)) ;
}  

function setColorPercMobile (perc_mobile)
{
  if (perc_mobile > 15) { perc_mobile = 15 ; } // for now assume upper limit -> map percentages 0 - 50 over full color circle
//hue = (360 + 120 - 120 * (perc_mobile / 15)) % 360 ;
//hue = (120 - 120 * (perc_mobile / 15)) % 360 ;
  hue = (90 * (perc_mobile / 15)) % 360 ;
  
  val = 70 + 30 * (perc_mobile / 15) ; 
//  val = 100 ;
  sat = 100 ;
  return (conv_hsv2rgb (hue,sat,val)) ;
}  

function imageSetWidth (action)
{
  if (action == '*')
  {
    image_size_auto = 1 ;
    viewport_width_prev = -1 ;
    calcPageSize () ;
  }
  else
  {
    var size_changed = false ;
    
    image_size_auto = 0 ;
    width = canvas_width ;
    sizes = fixed_image_widths.length ;
    for (size = 0  ; size < sizes ; size++)
    { 
      if (width == fixed_image_widths [size])  
      { break  ; }
      
      if (fixed_image_widths [size] > width)  
      { 
        if (size > 0) 
        { size -- ; }
        break ;  
      }
    }  

    if ((action == ']') && (size < sizes - 1))
    { size ++ ; size_changed = true ; }

    if ((action == '[') && (size > 0))
    { size -- ; size_changed = true ; }
    
    if (size_changed)
    {
      canvas.width  = fixed_image_widths [size] ;
      canvas.height = canvas.width / 2 ; 
      
      calcCanvas () ;
    }  
  }   
}

function calcCanvas ()
{      
  canvas_width  = canvas.width ;
  canvas_height = canvas.height ;
    
  canvas_width_half   = canvas_width  / 2 ;
  canvas_width_third  = canvas_width  / 3 ;
  canvas_height_half  = canvas_height / 2 ; ;
  canvas_height_third = canvas_height / 3 ; ;
  cx0 = canvas_width_half ;
  cy0 =    0 ;
      
  delta_x_tot_prev = delta_x_tot = 0 ;
  delta_y_tot_prev = delta_y_tot = 0 ;
  zoom_factor = 1 ;
  zoom_level  = 0 ;
}  
  
function ctxLine(x1,y1,x2,y2)
{
  ctx.beginPath();
  ctx.moveTo(x1,y1);
  ctx.lineTo(x2,y2);
  ctx.closePath();
  ctx.stroke();
}

function ctxCircle (x,y,r,c)
{              
  ctx.fillStyle = c.f ;
  
  ctx.beginPath();
  ctx.arc(x, y, r, 0, PI2, true) ;
  ctx.closePath();
  ctx.fill() ;
  ctx.stroke() ; 
}

function ctxCircleZ (x,y,r,c)
{              
  x /= zoom_factor ;
  y /= zoom_factor ;
  r /= zoom_factor ;
  
  ctxCircle (-delta_x_tot+x,-delta_y_tot+y,r,c) ;
}

function ctxDrawBox(x,y,w,h) 
{
  ctx.fillRect   (x,y,w,h) ;
  ctx.strokeRect (x,y,w,h) ;
}

function ctxDrawBoxZ (x,y,w,h) 
{
  ctxDrawBox (-delta_x_tot + x/zoom_factor,-delta_y_tot + y/zoom_factor,w/zoom_factor,h/zoom_factor) ;
}

function ctxWrite(x,y,text)
{
  if (show_text_border)
  { ctxWriteBorder (x,y,1,text) ; }
  
  ctx.fillText(text+' ',x,y);
}

// for texts that should always be at same position, 
// regardless zoom level
function ctxWriteZ(x,y,text)
{
	if ((navigator.appVersion.indexOf ('Chrome') > -1) && (zoom_factor > 1))
	{ 
		if ((text.indexOf ('Chrome') == -1) && (text.indexOf ('Title/Menu/Legend') == -1))
		{ return;} ; 
  }
	
  x = -delta_x_tot + x/zoom_factor ;
  y = -delta_y_tot + y/zoom_factor ;

  if (show_text_border)
  { ctxWriteBorder (x,y,1/zoom_factor,text) ; }

  ctx.fillText(text+' ',x,y);
}

function ctxWriteBorder(x,y,dxy,text)
{
  fillStyleSave = ctx.fillStyle ;
  ctx.fillStyle = text_border_color ;

  ctx.fillText(text+' ',x-dxy,y-dxy);
  ctx.fillText(text+' ',x-dxy,y+dxy);
  ctx.fillText(text+' ',x+dxy,y-dxy);
  ctx.fillText(text+' ',x+dxy,y+dxy);

  ctx.fillStyle = fillStyleSave ;
}

function ctxTextAlignLeft ()
{ ctx.textAlign = "left" ; }

function ctxTextAlignCenter ()
{ ctx.textAlign = "center" ; }

function ctxTextAlignRight ()
{ ctx.textAlign = "right" ; }

// ***************** 
// VERY TRIVIAL FUNCTIONS 
// to somewhat improve readability main code, 
// by keeping draw primitives similar

function ctxLineWidth (w) 
{ ctx.lineWidth = w ; }

function ctxLineWidthZ (w) 
{ ctx.lineWidth = w / zoom_factor ; }

function ctxFontSize (size)
{ ctx.font = sprintf ("%.2f", size / zoom_factor)  + "pt " + font_type ; ctx_font_unscaled = size ; } 

function ctxTextBorder (r,g,b)
{ 
  if (r < 0)
  { show_text_border = false ; }
  else
  { 
    show_text_border = true ; 
    text_border_color = 'rgb('+r+','+g+','+b+')' ; 
  }
}
 
function ctxFontSizeBodyText ()
{
  font_size = canvas_width / 90 ;
  if (font_size > 10) { font_size = 10 ; }
  if (font_size <  5) { font_size =  5 ; }
  ctxFontSize (font_size) ;
}

function ctxFontSizeNotice ()
{
  font_size = canvas_width / 100 + 2 ;
  if (font_size <  7) { font_size =  7 ; }
  ctxFontSize (font_size) ;
}


function ctxTextWidth (text) 
{ 
  dim = ctx.measureText (text) ; 
  return Math.round(dim.width) ; 
}

function ctxTextWidthZ (text) 
{ 
  dim = ctx.measureText (text) ; 
  return Math.round(dim.width / zoom_factor) ; 
}

function ctxStrokeStyle (r,g,b,t) 
{
  if (t != 1)
  { ctx.strokeStyle = 'rgba('+r+','+g+','+b+','+t+')' ; }
  else
  { ctx.strokeStyle =  'rgb('+r+','+g+','+b+')' ; }
}

function ctxFillStyle (r,g,b,t) 
{
  if (t != 1)
  { ctx.fillStyle = 'rgba('+r+','+g+','+b+','+t+')' ; }
  else
  { ctx.fillStyle =  'rgb('+r+','+g+','+b+')' ; }
}

// From site: http://snipplr.com/view/14590/hsv-to-rgb/
// HSV to RGB color conversion
// H runs from 0 to 360 degrees
// S and V run from 0 to 100
// Ported from the excellent java algorithm by Eugene Vishnevsky at:
// http://www.cs.rit.edu/~ncs/color/t_convert.html

function conv_hsv2rgb(h, s, v) 
{
  var r, g, b;
  var i;
  var f, p, q, t;

  // Make sure our arguments stay in-range
  h = Math.max(0, Math.min(360, h));
  s = Math.max(0, Math.min(100, s));
  v = Math.max(0, Math.min(100, v));

  s /= 100;
  v /= 100;
       
  if (s == 0)
  {
    // Achromatic (grey)
    r = g = b = v;
    return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
  }
       
  h /= 60; // sector 0 to 5
  i = Math.floor(h);
  f = h - i; // factorial part of h
  p = v * (1 - s);
  q = v * (1 - s * f);
  t = v * (1 - s * (1 - f));
       
  switch(i) 
  { 
    case 0: r = v ; g = t ; b = p ; break ;
    case 1: r = q ; g = v ; b = p ; break ;
    case 2: r = p ; g = v ; b = t ; break;
    case 3: r = p ; g = q ; b = v ; break;
    case 4: r = t ; g = p ; b = v ; break;
    default:r = v ; g = p ; b = q ; // case 5:
  }
       
//return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
  r = Math.round (r * 255) ;
  g = Math.round (g * 255) ;
  b = Math.round (b * 255) ;
  return (r+','+g+','+b) ; 
}

//http://www.quirksmode.org/js/cookies.html
function cookieCreate (name,value,days) 
{
	if (days) 
	{
		var date = new Date();
		date.setTime (date.getTime() + (days*24*60*60*1000));
		var expires = "; expires=" + date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

function cookieRead (name) 
{
	var nameEQ = name + "=";
	var ca = document.cookie.split (';');
	for (var i = 0 ; i < ca.length ; i++) 
	{
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring (1, c.length);
		if (c.indexOf(nameEQ) == 0) 
		{ return c.substring (nameEQ.length,c.length) ; }
	}
	return null;
}

function cookieErase (name) 
{
	cookieCreate (name,"",-1);
}

function htmlHide(id)
{
  var v = document.getElementById (id); 
  if (v.style) 
  {
    v.style.visibility = "hidden";
    v.style.display = "none" ;
    v.visibility = "hidden";
    v.display = "none" ;
  }
  else 
  { v.visibility = "hide"; }
}

function htmlShow(id)
{
  var v = document.getElementById (id); 
  if (v.style) // IE4 ??, IE5, Netscape 6, Chrome
  {
    
    v.style.visibility = "visible";
    // v.style.display = "block" ;
  }
  // else 
  // { v.visibility = "block"; }
}

function setNotice (duration,text)
{
  notice_text = text ;
  if (text == '') return ;
  
  now = new Date() ;
  notice_added    = now.getTime () ;
  notice_duration = duration ; // seconds
}

function calcPageSize () // or see http://stackoverflow.com/questions/1664785/html5-canvas-resize-to-fit-window  
{
  // the more standards compliant browsers (mozilla/netscape/opera/IE7) use window.innerWidth and window.innerHeight
 
  if (typeof window.innerWidth != 'undefined')
  {
    viewport_width  = window.innerWidth,
    viewport_height = window.innerHeight
  }
  // IE6 in standards compliant mode (i.e. with a valid doctype as the first line in the document)
  // also useful for newwer browsers ?
  else if (typeof document.documentElement != 'undefined' 
        && typeof document.documentElement.clientWidth != 'undefined' 
        && document.documentElement.clientWidth != 0)
  {
    viewport_width = document.documentElement.clientWidth,
    viewport_height = document.documentElement.clientHeight
  }
  // older versions of IE
  else  
  {
    viewport_width  = document.getElementsByTagName('body')[0].clientWidth,
    viewport_height = document.getElementsByTagName('body')[0].clientHeight
  }
  
  // ugly code !!!  // somehow there is a top and left margin outside canvas than I can't get go away, so make even spaced margin around image
  if ((viewport_width_prev  != viewport_width) ||
      (viewport_height_prev != viewport_height)) 
  {
    // abort set phase if applicable
    // reset zoom level
    if (canvas_resized++ > 0)
    { 
      zoom_factor = 1 ;
      zoom_level  = 0 ;

      if (setup_phase > 0)
      {
        color_map [show_mode] = B_W ; 
        show_edits  = 3 ;
        notice_added = 0 ; 
        notice_text = '' ;
      }  
      
      newPhase (0) ; 
    }
        
    if (image_size_auto > 0) 
    {
      viewport_width_prev  = viewport_width ;
      viewport_height_prev = viewport_height ;
      
      canvas.width  = viewport_width - viewport_margin ;
      canvas.height = Math.floor (canvas.width / 2) ;
      if (canvas.height > viewport_height - viewport_margin)
      {
        canvas.height = viewport_height - viewport_margin ;
        canvas.width  = canvas.height * 2 ;
      }  
    
      calcCanvas () ;
    }  
  }
}

function setupPhase ()
{
  switch (setup_phase) 
  {
    
    case 1 : 
    setNotice (0,'') ;      
    if (zoom_factor < 3)
    { 
      eventKeyZoom ('+') ; 
      delta_x_tot_phase1 = delta_x_tot ;
      delta_y_tot_phase1 = delta_y_tot ;
      newPhase (1) ; 
    }
    else 
    { newPhase (2) ; }
    break ; 

    case 2 : 
    if (delta_y_tot < -30)
    { 
      delta_x_tot -=  2 ;    
      delta_y_tot += 10 ;    
      ctx.translate (-2,10) ;
      newPhase (2) ; 
    }  
    else 
    { 
      setNotice (15, "Which style do you prefer?|Type L (eft) or R (ight)|(You can switch later)") ;
      newPhase (3) ; 
    }
    break ; 
    
    // phase 3 -> 4 in eventKeyPressed
    
    case 4 : 
    if (delta_y_tot > delta_y_tot_phase1)
    {
      delta_x_tot += 2 ; 
      delta_y_tot -= 10 ; 
      ctx.translate (2,-10) ;
      newPhase (4) ; 
    } 
    else 
    { newPhase (5) ; }
    break ; 

    case 5 : 
    if (zoom_factor > 1)
    { 
      eventKeyZoom ('-') ; 
      newPhase (5) ; 
    }
    else
    { 
      setNotice (10, "1 / 2 / 3 = Animation / Bubble Map / Heat map|M / E = switch Map / Event marker|H = Help, for more options") ;
      newPhase (0) ; 
    }
    break ; 
  }  
}

function newPhase (phase)

{
  setup_phase = phase ; 

  now = new Date() ;
  time = now.getTime () ;
  frames_shown = 0 ;
  time_frame_first = time ;
  time_prev = time ;
}


function settingsSave () 
{
  settings  = 'setup_phase:'          + '0' ;
  settings += '|show_debug:'          + show_debug ;
  settings += '|show_edits:'          + show_edits ;
  settings += '|show_mode:'           + show_mode ;
  settings += '|show_cities:'         + show_cities ;
  settings += '|show_clocks:'         + show_clocks ;
  settings += '|show_sun:'            + show_sun ;
  settings += '|show_help:'           + show_help ;
  settings += '|show_one_language:'   + show_one_language ;
//settings += '|canvas_width:'        + canvas_width ;
//settings += '|radius_max:'          + radius_max ;
  settings += '|language_selected:'   + language_selected ;
  settings += '|imgmap_transparency:' + imgmap_transparency ;
  settings += '|color_map_animation:' + color_map[show_animation] ;
  settings += '|color_map_bubblemap:' + color_map[show_distrib] ;
//settings += '|color_map_heatmap:'   + color_map[show_heatmap] ;
//settings += '|speed_up_desired:'    + speed_up_desired ;
//settings += '|clock_delta:'         + clock_delta ;
//settings += '|image_size_auto:'     + image_size_auto ;
   
  cookieCreate ('settings',settings,365) ;
    
  if (show_debug)
  { setNotice (4, 'Settings saved: ' + settings) ; }
  else
  { setNotice (2, 'Settings saved') ; }
}
  
function settingsRead () 
{
  settings = cookieRead ('settings') ;
     
  if (settings == null)
  { return ; }
  if (show_debug)
  { setNotice (4, 'Settings read: ' + settings) ; }
    
  parms = settings.split ('|') ;   

  for (var p = 0, len = parms.length, parmSplit; p < len; p++)
  {
    parmSplit = parms [p].split (':') ;
    parm  = parmSplit [0] ;
    value = parmSplit [1] ;

    if (parm == 'setup_phase')          { setup_phase = value * 1 ; } // * 1 = make numeric
    if (parm == 'show_debug')           { show_debug = value * 1 ; }
    if (parm == 'show_edits')           { show_edits = value * 1 ; } 
    if (parm == 'show_mode')            { show_mode = value * 1 ; } 
    if (parm == 'show_cities')          { show_cities = value * 1 ; } 
    if (parm == 'show_clocks')          { show_clocks = value * 1 ; } 
    if (parm == 'show_sun')             { show_sun = value * 1 ; } 
    if (parm == 'show_help')            { show_help = value * 1 ; } 
    if (parm == 'show_one_language')    { show_one_language = value * 1 ; } 
  //if (parm == 'radius_max')           { radius_max = value * 1  ; }
    if (parm == 'language_selected')    { language_selected = value ; }
  //if (parm == 'canvas_width')         { canvas.width = value * 1  ; canvas.height = canvas_width / 2 ; }
    if (parm == 'imgmap_transparency')  { imgmap_transparency = value * 1  ; }
    if (parm == 'color_map_animation')  { color_map [show_animation] = value * 1 } ; 
    if (parm == 'color_map_bubblemap')  { color_map [show_distrib] = value * 1 } ; 
  //if (parm == 'color_map_heatmap')    { color_map [show_heatmap] = value * 1 } ; 
  //if (parm == 'speed_up_desired')     { speed_up_desired = value * 1 } ; 
  //if (parm == 'clock_delta')          { clock_delta = value * 1 } ; 
  //if (parm == 'image_size_auto')      { image_size_auto = 1 * 1 } ; 
  }
}
  

// ----------------------------------------------------

// Three arguments: the element, destination (x,y) coordinates.
// context.drawImage(img_elem, dx, dy);

// Five arguments: the element, destination (x,y) coordinates, and destination 
// width and height (if you want to resize the source image).
// context.drawImage(img_elem, dx, dy, dw, dh);

// Nine arguments: the element, source (x,y) coordinates, source width and 
// height (for cropping), destination (x,y) coordinates, and destination width 
// and height (resize).
// context.drawImage(img_elem, sx, sy, sw, sh, dx, dy, dw, dh);