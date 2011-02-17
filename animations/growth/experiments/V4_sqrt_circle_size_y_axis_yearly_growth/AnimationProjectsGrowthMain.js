// Author Erik Zachte - March 2008
// License covered by Creative Commons Attribution 3.0
// See for full coverage of the license: http://creativecommons.org/licenses/by-sa/3.0/
// Essentially you are allowed to copy, distribute, transmit and adapt this work, under the following condition:
// You must attribute the work to me, by mentioning my name and website (http://infodisiac.com)

// for IE excanvas.js see http://explorercanvas.blogspot.com/

  function ctx_measureText (text) 
  { dim = ctx.measureText (text) ; return Math.round(dim.width) ; }

  var a = []; // array with all data per Wikipedia  
  var b = []; // array with buttons

  var button = 0 ;          
  var button_prev = -1 ;

  var x_axis_time    = 1 ;
  var x_axis_editors = 2 ;
  var x_axis_mode    = x_axis_editors ;

  var y_axis_log = 1 ;
  var y_axis_lin = 2 ;
  var y_axis_growth_contrib = 3 ;
  var y_axis_mode = y_axis_growth_contrib ;
  
  var r_size_mode_lin = 1 ;
  var r_size_mode_log = 2 ;
  var r_size_mode_sqrt = 3 ;
  var r_size_mode = r_size_mode_sqrt ;

  var c_dim_mode_equal = 1 ;
  var c_dim_mode_small = 2 ;
  var c_dim_mode = c_dim_mode_equal ;

  var r_follows_editors = true ;
  
  var r_mult   = 1 ;
  var r_fixed  = 12 ;

  var g_mode_monthly = 1 ;
  var g_mode_yearly  = 2 ;
  var g_mode = g_mode_yearly ;

  var show_codes = true ;
  var show_trail = false ;

  var incomplete = false ;
  var date = new Date() ;
  var time = date.getTime();
  var elapsed = "" ;
  
  var Coordinate_X_InImage = 0 ;
  var Coordinate_Y_InImage = 0 ;

  var canvas, ctx;
  var canvas_width  = 0 ;
  var canvas_height = 0 ;
  var canvas_wh_min = 0 ;
  var mouse_x = 0 ;
  var mouse_y = 0 ;
  var ready = false ;
  var transparency_fill = 0.6 ;  
  var transparency_line = 1.0 ;  

  var COLOR_50 = setcolors (50,99,0.3,0.3) ;
  var CIRCLES    = true ;
  var RADIUSMULT = 2.5 ;
  var PI2        = Math.PI * 2 ;
  var INTERVAL   = 1 ;

  var LOG10   = Math.log(10) ;
  var LOG1010 = Math.log(10)/LOG10 ;
  var x_min = 1 ;     // 10      // 100
  var x_min_log = 0 ; // LOG1010 // 2 * LOG1010 ;
  var y_min = 1 ;     // 10      // 100
  var y_min_log = 0 ; // LOG1010 // 2 * LOG1010 ;
  
  var CYCLES = 100 ;

  var MARGIN_L = 30 ;
  var MARGIN_B = 15 ;
  var MARGIN_R = 10 ;
  var MARGIN_T = 20 ;

  var VARY_YSCALE = (ARTICLES_MAX >= 20000) ;
  var steps_switch_scale_max = 15 ;
  var steps_switch_scale = 0 ;

  var articles_max_hi = ARTICLES_MAX ;
  var editors_max = EDITORS_MAX ;
  
  if (r_size_mode != r_size_mode_log) // keep large circles far right within diagram
  { editors_max = 2 * editors_max ; }
  
  var cycle   = 0 ;
  var month   = FROM_MONTH ;
  var year    = FROM_YEAR ;
  var step    = 0 ;
  var index   = 0 ;
  var size    = 0 ;
  var steps_max ; 
  var alerts = 0 ;
  var steps_per_month = 15 ;
  var time_ready ;

  if (x_axis_mode == x_axis_editors) // slow down compared with original animation 
  { steps_per_month *= 2 ; }

  var MONTHS = ['','JAN','FEB','MRT','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'] ;
  var PROJECTS = ['Wikipedia', 'Wikibooks', 'Wikinews', 'Wikiquote', 'Wikisource' , 'Wikiversity', 'Wiktionary'] ;  
  var PROJECTSCODES = ['Wp', 'Wb', 'Wn', 'Wq', 'Ws' , 'Wv', 'Wk'] ;  
  
  var diagram_height   ;
  var diagram_width ;
  
  function SetValuesLogLin()
  {  
    if (y_axis_mode == y_axis_log)                                                                            
    { 
      articles_max = ARTICLES_MAX * 2 ;
      diagram_height = (canvas.height - MARGIN_B - MARGIN_T) / ((Math.log(articles_max)/LOG10)-y_min_log) ; 

      // MARGIN_L = 30 ;

      // buttons_x = canvas.width  - MARGIN_R - 63 ;
      // buttons_y = canvas.height - MARGIN_B- 141 ;
    }
    else
    { 
      // articles_max = Math.floor (ARTICLES_MAX * 1.02) ;
      articles_max = ARTICLES_MAX ;
      setStubIncr (articles_max) ;
      diagram_height = canvas.height - MARGIN_B - MARGIN_T ; 

      // ctx.font = "8pt Arial";
      // MARGIN_L = ctx_measureText("9999k") + 3 ;

      // buttons_x = MARGIN_L ;
      // buttons_y = MARGIN_T ;
    }

    diagram_width  = canvas.width - MARGIN_L - MARGIN_R ;
    steps_max = months * steps_per_month ;
    dxstep = diagram_width / steps_max ;

    diagram_width_log_editors5 = diagram_width / ((Math.log(editors_max)/LOG10)-y_min_log) ; 
  }   

  // make sure yrange and stub intervals are nice round figures
  function setStubIncr()
  {
    var incstub     = 1 ;
    var incstubmult = 1 ;
    var incstubmax  = 12 ;

    while (incstubmax * incstub * incstubmult < articles_max)
    {
     if (incstub == 1)
      {
        if (incstubmult == 1)
        { incstub = 5 ; }
        else
        { incstub  = 2.5 ; }
        incstubmax  = 10 ;
      }
      else 
      {
        if (incstub == 2.5)
        {
          incstub  = 5 ;
          incstubmax  = 10 ;
        }
        else
        {
          incstub     = 1 ;
          incstubmult *= 10 ;
          incstubmax  = 12 ;
        }
      }
    }  

    incstub  *= incstubmult ;

    var articles_max2 = 0 ;
    while (articles_max2 <= articles_max)
    { articles_max2 += incstub ; }
    articles_max = articles_max2 ;
    articles_max_hi = articles_max ;
  }

// courtesy ->
// http://www.netlobo.com/url_query_string_javascript.html
  function getParameter(name)
  {
    name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
    var regexS = "[\\?&]"+name+"=([^&#]*)";
    var regex = new RegExp( regexS );
    var results = regex.exec( window.location.href );
    if( results == null )
      return "";
    else
      return results[1];
  }
// <- courtesy 

  function setcolors (value, radius, transparency_fill, transparency_line)
  {
    line_color = "rgba(0,0,0," + transparency_line + ")" ; 

    if (value < -999) // disabled
    { fill_color = "rgba(0,0,0,0)" ;  }
    else
    {
      var value1=Math.floor((value/100)*255) ;
      var value2=Math.floor((value/100)*230) ;
      fill_color = "rgba(" + value1 + "," + (230-value2) + ",255," + transparency_fill + ")" ; 
      value= (value+128) % 256 ;                              
    }  

    transparency_text = transparency_fill ;
    
    var rgb = "256,256,64" ;
    if (radius > 7)
    { text_color = "rgba(" + rgb + "," + transparency_text + ")" ;  }
    else
    { text_color = "rgba(" + rgb + "," + transparency_text/2 + ")" ;  }

    return {f:fill_color, l:line_color, t:text_color} ;
  }      

  function radiusCircle (editors)
  {
    if (x_axis_mode == x_axis_time)
    {
      if (editors > 0) 
        if (r_size_mode == r_size_mode_log)
          return 2 + Math.log(editors)/LOG10 * r_mult * 2 ;  
        if (r_size_mode == r_size_mode_lin)
          return 0.5 + editors/editors_max * r_mult * 2 ;  
      else    
        return 2 ;
    }
    // else    
    if (x_axis_mode == x_axis_editors)
    {
      if (editors > 0) 
        if (r_size_mode == r_size_mode_log)
          return 0.5 + Math.log(editors)/LOG10 * r_mult * 1.5 ;  
        if (r_size_mode == r_size_mode_lin)
          return 2 + editors/editors_max * r_mult * 25 ;  
        if (r_size_mode == r_size_mode_sqrt)
          return 2 + Math.sqrt (editors/editors_max) * r_mult * 50 ;  
      else    
        return 0.5 ;
    }
  }

  //**** drawGrid ****//
  function drawGrid()
  {
    var dz ;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    ctx.lineWidth = "1";
    ctx.strokeStyle = "rgb(0,0,0)" ;

    // draw vertical lines
    ctx.font = "8pt Arial";

    if (x_axis_mode == x_axis_time) 
    {
      for (var x = 0; x <= years ; x++)
      {
        x1 = MARGIN_L + x * 12 * steps_per_month * dxstep ;
        line (x1,canvas.height-MARGIN_B,x1,MARGIN_T) ;
      }
      line (canvas.width-MARGIN_R,canvas.height-MARGIN_B,canvas.width-MARGIN_R,MARGIN_T) ;
    }
    // else 
    if (x_axis_mode == x_axis_editors) 
    {  
      x = x_min ;
      z = -1 ;
      dz = 3 ;

      line (MARGIN_L,MARGIN_T,MARGIN_L,canvas.height-MARGIN_B);
      while (x <= editors_max)
      {
        z++ ;

        x1 = MARGIN_B + (Math.log(x)/LOG10) * diagram_width_log_editors5 ; 

        ((z % dz == 0) || (x == editors_max)) ? ctx.strokeStyle = "rgb(0,0,0)" : ctx.strokeStyle = "rgb(55,55,55)" ;     // lines
        (z % dz == 0) ? ctx.fillStyle   = "rgb(255,255,255)" : ctx.fillStyle   = "rgb(110,110,110)" ;  // text

        line (MARGIN_L+x1,MARGIN_T,MARGIN_L+x1,canvas.height-MARGIN_B);
      
        text = Math.floor (x) ;
        if (x > 999999)
        { text = Math.round (text / 1000000) + 'M' ;  }
        else
        {
          if (x > 999)
          { text = Math.round (text / 1000) + 'k' ;  }
        }  

        dxtext = ctx_measureText(text) ;
        dytext = 4 ;
      //if (x * 2 > editors_max) // rightmost text ?
      //{ write (MARGIN_L+x1-dxtext  , canvas.height-dytext,text) ; }
      //else
      //{ write (MARGIN_L+x1-dxtext/2, canvas.height-dytext,text) ; }

        if (z % dz != 1) { x *= 2 ; } else { x *= 2.5 ; } 
      }
    }  
    x1 = MARGIN_B + (Math.log(editors_max)/LOG10) * diagram_width ; 
    ctx.strokeStyle = "rgb(0,0,0)" ;
    line (canvas.width-MARGIN_R,canvas.height-MARGIN_B,canvas.width-MARGIN_R,MARGIN_T) ;

    // draw horizontal lines

    ctx.font = "8pt Arial";
    if (y_axis_mode == y_axis_growth_contrib)
    {
      for (i = -1 ; i <= 1 ; i+= 0.2)
      {
        if ((i == -1) || ((i > -0.001) && (i < 0.001)) || (i == 1))    
        { 
          ctx.fillStyle   = "rgb(255,255,255)" ;
          ctx.strokeStyle = "rgb(0,0,0)" ; 
        }
        else
        { 
          ctx.fillStyle   = "rgb(110,110,110)" ;
          ctx.strokeStyle = "rgb(55,55,55)" ; 
        }
        
        y1 = diagram_height * (0.5 - i/2) ;
        line (MARGIN_L,MARGIN_T+y1,canvas.width-MARGIN_R,MARGIN_T+y1);
        
        text = Math.round(100*i) + "%" ;
        dxtext = ctx_measureText(text) ;
        write (MARGIN_L-dxtext-4, MARGIN_T+y1+3,text) ;
      }
    }
    else
    {
      if (y_axis_mode == y_axis_log)
      { y = y_min ; }
      else
      { y = 0 ; }
    
      z = -1 ;
      (y_axis_mode == y_axis_log) ? dz = 3 : dz = 2 ;

      log = "" ;
      ctx.fillStyle = "White";
      ctx.font = "8pt Arial";
      while (y <= articles_max)
      {
        z++ ;
  
        if (y_axis_mode == y_axis_log)
        {  y1 = MARGIN_B + ((Math.log(y)/LOG10)-y_min_log) * diagram_height ; }
        else
        {  y1 = MARGIN_B + y / articles_max * diagram_height ; }
        
  
        ((z % dz == 0) || (y == articles_max)) ? ctx.strokeStyle = "rgb(0,0,0)"       : ctx.strokeStyle = "rgb(55,55,55)" ;     // lines
        (z % dz == 0) ? ctx.fillStyle   = "rgb(255,255,255)" : ctx.fillStyle   = "rgb(110,110,110)" ;  // text
  
        line (MARGIN_L,canvas.height-y1,canvas.width-MARGIN_R,canvas.height-y1);
        
        text = Math.floor (y) ;
        if (y_axis_mode == y_axis_log)
        {
          if (y > 999999)
          { text = Math.round (text / 1000000) + 'M' ;  }
          else
          {
            if (y > 999)
            { text = Math.round (text / 1000) + 'k' ;  }
          }  
        }
        else
        {
          text = Math.round (text / 1000) ;  
        }  
  
        dxtext = ctx_measureText(text) ;
        dytext = -4 ;
        write (MARGIN_L-dxtext-6, canvas.height-y1-dytext,text) ;

        if (y_axis_mode == y_axis_log)
        { if (z % dz != 1) { y *= 2 ; } else { y *= 2.5 ; } }
        else
        { y += articles_max / 10 ; }
      }
      if (y_axis_mode == y_axis_log)
      { y1 = MARGIN_B + ((Math.log(articles_max)/LOG10)-y_min_log) * diagram_height ; }
      ctx.strokeStyle = "rgb(0,0,0)" ;
      line (MARGIN_L,canvas.height-y1,canvas.width-MARGIN_R,canvas.height-y1);
    }  
  }

  function drawGrid2()
  {
    ctx.fillStyle = "White";
    ctx.font = "8pt Arial";
    if (x_axis_mode == x_axis_time)
    {
      // number vertical lines
      for (var x = 0; x <= years ; x++)
      {
        x1 = MARGIN_L + x * 12 * steps_per_month * dxstep ;
        dxtext = ctx_measureText(x)/2 ;
        write (x1-dxtext, canvas.height-MARGIN_B+11, x);
      }
    }  
    // else
    if (x_axis_mode == x_axis_editors)
    {
      text = "0" ;
      dxtext = ctx_measureText(text) ;
      dytext = 4 ;
      write (MARGIN_L-dxtext/2, canvas.height-dytext,text) ; 
      
      x = x_min ;
      z = -1 ;
      dz = 3 ;

      while (x <= editors_max)
      {
        z++ ;

        x1 = MARGIN_B + (Math.log(x)/LOG10) * diagram_width_log_editors5 ; 

        ((z % dz == 0) || (x == editors_max)) ? ctx.strokeStyle = "rgb(0,0,0)" : ctx.strokeStyle = "rgb(55,55,55)" ;     // lines
        (z % dz == 0) ? ctx.fillStyle   = "rgb(255,255,255)" : ctx.fillStyle   = "rgb(110,110,110)" ;  // text

      //line (MARGIN_L+x1,MARGIN_T,MARGIN_L+x1,canvas.height-MARGIN_B);
      
        text = Math.floor (x) ;
        if (x > 999999)
        { text = Math.round (text / 1000000) + 'M' ;  }
        else
        {
          if (x > 999)
          { text = Math.round (text / 1000) + 'k' ;  }
        }  

        dxtext = ctx_measureText(text) ;
        dytext = 4 ;
        if (x * 2 > editors_max) // rightmost text ?
        { write (MARGIN_L+x1-dxtext  , canvas.height-dytext,text) ; }
        else
        { write (MARGIN_L+x1-dxtext/2, canvas.height-dytext,text) ; }

        if (z % dz != 1) { x *= 2 ; } else { x *= 2.5 ; } 
      }
      x1 = MARGIN_B + (Math.log(editors_max)/LOG10) * diagram_width ; 
    }  
  }  

  function drawButton(b) 
  {                                   
    ctx.font = b.pt + "pt Arial";
    ctx.lineWidth = "2";
    ctx.fillStyle = b.c ;
    ctx.fillRect   (buttons_x + b.x, buttons_y + b.y,b.w,b.h) ;
    ctx.strokeStyle = "black";
    ctx.strokeRect (buttons_x + b.x, buttons_y + b.y,b.w,b.h) ;

    if ((VARY_YSCALE) && (b.t === "lin")) 
    {                                         
      ctx.fillStyle = "rgb(0,64,0)" ; 

      if (articles_max > 20000)
      { ctx.fillRect (buttons_x + b.x+1, buttons_y + b.y+1,14,b.h-2) ; }
      if (articles_max < articles_max_hi)
      { ctx.fillRect (buttons_x + b.x + b.w-16, buttons_y + b.y+1,14,b.h-2) ; }
    }
    
    dxtext = ctx_measureText(b.t) / 2;
    if (b.active)
    { 
      if (show_trail) 
      { ctx.fillStyle = "rgb(64,128,64)" ; }
      else
      { ctx.fillStyle = "rgb(128,255,128)" ; }
    }  
    else
    { ctx.fillStyle = "rgb(0,96,0)" ; }
    
    write (buttons_x + b.x+b.w/2-dxtext  , buttons_y + b.y+b.h/2+b.dy, b.t);
    if (b.f > 1)
    { write (buttons_x + b.x+b.w/2-dxtext-1, buttons_y + b.y+b.h/2+b.dy, b.t); }
    if (b.f > 2)
    {  write (buttons_x + b.x+b.w/2-dxtext+1, buttons_y + b.y+b.h/2+b.dy, b.t); }

    if ((VARY_YSCALE) && (b.t === "lin")) 
    {                                         
      ctx.fillStyle = "rgb(0,128,0)" ; 
      if (articles_max > 20000)
      { write (buttons_x + b.x+3, buttons_y + b.y+b.h/2+b.dy, '<'); }
      if (articles_max < articles_max_hi)
      { write (buttons_x + b.x+b.w-ctx_measureText('>')-3, buttons_y + b.y+b.h/2+b.dy, '>'); }
    }
  }
                     
  function drawCircles()
  {
    var  i ;       
    var date = new Date() ;
    incomplete = false ;
    mouse_index = -1 ;         

    ctx.lineWidth = "1";
    ctx.strokeStyle = "rgb(255, 255, 255)";
    ctx.font = "10pt Arial";

    for (i = WIKIPEDIAS - 1 ; i >= 0 ; i--)
    {
      a[i].update(i);      
      
      if (a[i].show && (steps_switch_scale == 0))
      {
        ctx.lineWidth = "1";
        if ((mouse_x > 0) && (mouse_y > 0))
        {     
          x = a[i].x - mouse_x ;                     
          y = a[i].y - mouse_y ;
          r = a[i].r ;
          if (x*x + y*y < r*r)
          { mouse_index = i ; }
        }
      }  
    }               

    show_trail = (mouse_index > -1) ;

    for (i = WIKIPEDIAS - 1 ; i >= 0 ; i--)
 // for (i = 1 ; i >= 0 ; i--)
    {
      if (a[i].show)
      {
        if (show_trail)
        { 
          c = setcolors (a[i].value, 99, 0.1, 1) ; 
          c.t = "rgba(255,255,0,0.1)" ; 
        }
        else
        { 
          if (x_axis_mode == x_axis_time)
          { c = setcolors (a[i].value, a[i].r, a[i].transparency_fill, a[i].transparency_line) ;  }
          // else  
          if (x_axis_mode == x_axis_editors)
          { 
            if (c_dim_mode == c_dim_mode_equal) 
            { r_min = 0 ; }
            else
            { r_min = (y_axis_mode == y_axis_growth_contrib) ? 12 : 7 ; }
            if (a[i].r > r_min)
            { c = setcolors (a[i].value, a[i].r, a[i].transparency_fill, a[i].transparency_line) ; }
            else
            { c = setcolors (a[i].value, a[i].r, 0.3 + (a[i].transparency_fill-0.3) / (r_min-a[i].r), 0.3 + (a[i].transparency_line-0.3) / (r_min-a[i].r)) ; }
          }
          
          //c.t = "rgba(255,255,0,1)" ; 
        }
    
        a[i].fill_color = c.f ;
        a[i].line_color = c.l ;
        a[i].text_color = c.t ;                             

        if ((a[i].size2 == 0) && (! show_trail)) // show incomplete project in red
        { 
          var date = new Date() ;
          var msec = date.getMilliseconds() ;
          var red = Math.floor ((1000 - msec) / 1000 * 255) ;
          if (red < 200) { red = 200 ; }
          a[i].text_color = c.t = "rgb("+red+",0,0)" ; 
        }                             
                            
        if (CIRCLES)
        {
          ctx.strokeStyle = c.l ; 
          if (a[i].r > 1)
          { ctx.fillStyle = c.f ;  }
          else
          { ctx.fillStyle = COLOR_50.f ; } //"rgb(196,196,0)" ;  }
          circle (a[i].x, a[i].y, a[i].r) ;
        }                                          
                      
        if (a[i].last !== "")
        {
          ctx.font = "6pt Arial";
          if (a[i].stop < a[i].articles.length - 2)
          {
            ctx.fillStyle = "red" ; // rgb(128,0,0)";
            ctx.strokeStyle = "red" ; // rgb(128,0,0)";
          }  
          else
          {
            ctx.fillStyle = "rgb(128,0,0)";
            ctx.strokeStyle = "rgb(128,0,0)";
          }  
          write (a[i].x+a[i].r, a[i].y+a[i].r, a[i].last) ;
          line  (a[i].x+a[i].r/Math.sqrt(2),a[i].y+a[i].r/Math.sqrt(2),a[i].x+a[i].r, a[i].y+a[i].r) ;
        }

        if (show_codes && (a[i].r > 5))
        {
          ctx.font = a[i].ts ;
          ctx.fillStyle = c.t ; 
          label = a[i].label ;                     
          dxtext = ctx_measureText(label) / 2;
          dytext = -a[i].r / 3 ; 
          write (a[i].x-dxtext, a[i].y-dytext, label);
        }             
      }  
    }               
  }

  function drawBox(x,y,w,h) 
  {
    ctx.fillRect   (x,y,w,h) ;
    ctx.strokeRect (x,y,w,h) ;
  }
    
  function drawTextbox(mouse_index) 
  {
    ctx.lineWidth = "3";
    ctx.strokeStyle = a[mouse_index].line_color ;
      
    color = a[mouse_index].fill_color ;
    color = color.replace(/rgba/,"rgb");
    color = color.replace(/,[^,\)]+\)$/,"\)");
      
    ctx.fillStyle = color ;
    // circle (a[mouse_index].x, a[mouse_index].y, a[mouse_index].r*1.5) ;
    circle (a[mouse_index].x, a[mouse_index].y, a[mouse_index].r) ;

    // ctx.fillStyle = a[mouse_index].text_color ; // "black";            
    ctx.fillStyle = "black" ;            
    ctx.font = a[mouse_index].ts ;
    label = a[mouse_index].label ;                     
    dxtext = ctx_measureText(label) / 2;
    dytext = -a[mouse_index].r / 3 ; 
    write (a[mouse_index].x-dxtext, a[mouse_index].y-dytext, label);

    ctx.font = "11pt Arial";
    dxtext  = ctx_measureText(a[mouse_index].language);
    ctx.font = "9pt Arial";
    dxtext2 = ctx_measureText("Size: " + a[mouse_index].articles [index]);
    dxtext3 = ctx_measureText("Editors: " + a[mouse_index].editors5[index]);
    dxtext4 = ctx_measureText(a[mouse_index].value+"% > 0.5Kb");

    if (dxtext2 > dxtext) { dxtext = dxtext2 ; }
    if (dxtext3 > dxtext) { dxtext = dxtext3 ; }
    if (dxtext4 > dxtext) { dxtext = dxtext4 ; }
    
    dxtext5 = dxtext + 28 ;
    if (mouse_x < canvas.width - MARGIN_R - dxtext - 20)
    { dxtext = a[mouse_index].r + 5 ; }
    else
    { dxtext = -a[mouse_index].r - dxtext5 - 5 ; }

    var BOXHEIGHT = 70 ;
    dytext = - BOXHEIGHT / 2 ; 
    ctx.fillStyle = "rgb(255,255,255)";
    ctx.strokeStyle = "rgb(0,0,0)";
                                    
  //var x = a[mouse_index].x+dxtext ;                       
  //var y = a[mouse_index].y+dytext ;         
  //if (y < MARGIN_T) { y = MARGIN_T ; }
  //if (y + BOXHEIGHT > canvas_height - MARGIN_B) { y = canvas_height - MARGIN_B - BOXHEIGHT ; }
    var x = buttons_x + buttons_w + 5 ; // MARGIN_L ;
    var y = MARGIN_T + 5 ;
    
    drawBox (x,y, dxtext5, BOXHEIGHT) ;
    
    ctx.font = "11pt Arial";
    ctx.fillStyle = "rgb(0,64,0)" ; // a[mouse_index].text_color ;
    write (x+7, y+20, a[mouse_index].language); // draw twice -> bold
    write (x+8, y+20, a[mouse_index].language);
    
    ctx.font = "9pt Arial";
    ctx.fillStyle = "black" ; 
    write (x+7, y+34, "Articles: " + a[mouse_index].articles [index]);
    write (x+7, y+48, "Editors: " + a[mouse_index].editors5[index]);
    write (x+7, y+62, a[mouse_index].value+"% > 0.5Kb");
//  write (x+7, y+62, "Age:" + a[mouse_index].size);

    ctx.lineWidth = "1";
  }

  function drawTexts()
  {
    // title
    ctx.font = "12pt Arial";
    // text = "Number of articles, and article size, per " + PROJECT ;
    // text = "Articles, total and size, per " + PROJECT ;
    text = "Growth per " + PROJECT + " wiki";
    ctx.fillStyle = "white";
    dxtext = ctx_measureText(text) / 2;                            
    x1 = MARGIN_L + (canvas.width - MARGIN_L - MARGIN_R) / 2 - dxtext ;
    if (canvas_width < 800) // for smaller canvas sizes avoid overlaps with other header texts
    { x1 -= 70 ; }
    write (x1, MARGIN_T-6, text);

    // yyyy
    ctx.font = "18pt Arial";
    ctx.fillStyle = "Grey";
    text = year ; 
    dxtext = ctx_measureText(text) ;
    x1 = MARGIN_L + (canvas.width - MARGIN_L - MARGIN_R) / 2 - dxtext - 5 ;
    write (x1, MARGIN_T + 22, text) ;

    // month           
    text = MONTHS[month] ; // //steps_switch_scale ; // + " : " + size1 + " - " + a[0].size2 ;
    dxtext = ctx_measureText(text) ;
    x1 = MARGIN_L + (canvas.width - MARGIN_L - MARGIN_R) / 2 + 5 ;
    write (x1, MARGIN_T + 22, text);

    // footer
    ctx.font = "8pt Arial";
    ctx.fillStyle = "White";

    if (y_axis_mode == y_axis_growth_contrib)
    { text = "Monthly growth in active editors (> 5 edits)" ; }
    // else
    if (y_axis_mode == y_axis_log)
    { text = "Articles" ; }
    // else
    if (y_axis_mode == y_axis_lin)
    { text = "Articles x1000" ; }
    
    dxtext = ctx_measureText(text);
    write (MARGIN_L, MARGIN_T-7, text);

    if (x_axis_mode == x_axis_time)
    {
      text = "Age" ;
      dxtext = ctx_measureText(text);
      x1 = canvas.width - MARGIN_R - dxtext - 3 ;
      write_vert (canvas.width-4, canvas.height-MARGIN_B-(text.length-1)*10+10, text);
    }
    // else  
    if (x_axis_mode == x_axis_editors)
    {
      text = "Editors" ;
      dxtext = ctx_measureText(text);
      x1 = canvas.width - MARGIN_R - dxtext - 3 ;
      write_vert (canvas.width-4, canvas.height-MARGIN_B-(text.length-1)*10-5, text);
    }

    text = "Author: Erik Zachte" ;
    text = "ERIK ZACHTE" ;
    ctx.fillStyle = "rgb(100,100,100)";
    dxtext = ctx_measureText(text);

    // position at far right, 50% above 1K line, 50% below 
    if (y_axis_mode == y_axis_log)
    { write_vert (canvas.width-4, canvas.height - (MARGIN_T + ((Math.log(1000)/LOG10)-y_min_log)  * diagram_height) - (text.length-1)*10/2, text); }
    else
    { write_vert (canvas.width-4, MARGIN_B + diagram_height / 2 - text.length*10/2, text); }

    // legend
    if ((show_codes) && (! show_trail))
    {
      ctx.font = "8pt Arial";
      ctx.fillStyle = "rgba(200,200,0,0.7)";
      // yalias = MARGIN_T + 12 ;
      var x = aliasses_x ;
      var y = aliasses_y ;
      aliasses = aliasses.replace (/_/g,'-') ;
      var aliasses2 = aliasses.split(',') ;
      for (var a = 0; a < aliasses2.length ; a++)
      {
        dxtext = ctx_measureText(aliasses2[a]) / 2;
        // x1 = MARGIN_L + (canvas.width - MARGIN_L - MARGIN_R) / 2 - dxtext ;
        write (x,y,aliasses2[a]);
        y += 12 ;
      }
    }  
                         
    // write legend: meaning of colored circles
    ctx.strokeStyle = "black" ;
    x1 = canvas.width - 220 ;
    label = "Articles > 0.5Kb:" ;                     
    // label = "Avg. size:" ;                     
    ctx.fillStyle = "white";
    write (x1+5, MARGIN_T-7, label);

    c = setcolors (0, 99, transparency_fill, transparency_line) ;
    ctx.fillStyle   = c.f ;
    // circle (x1+58, MARGIN_T-11, 6) ;
    circle (x1+98, MARGIN_T-11, 6) ;
    // label = "0\% > 0.5 Kb" ;                     
    label = "0\%" ;                     
    ctx.fillStyle = "white";
    write (x1+108, MARGIN_T-7, label);

    c = setcolors (50, 99, transparency_fill, transparency_line) ;
    ctx.fillStyle   = c.f ;
    circle (x1+133, MARGIN_T-11, 6) ;
    // label = "50\% > 0.5 Kb" ;                     
    label = "50\%" ;                     
    ctx.fillStyle = "white";
    write (x1+143, MARGIN_T-7, label);

    c = setcolors (100, 99, transparency_fill, transparency_line) ;
    ctx.fillStyle   = c.f ;
    // circle (x1+147, MARGIN_T-11, 6) ;
    circle (x1+174, MARGIN_T-11, 6) ;
    // label = "100\% > 0.5 Kb" ;                     
    label = "100\%" ;                     
    ctx.fillStyle = "white";
    write (x1+184, MARGIN_T-7, label);
    
    // write XX = Last month(s) missing
    if (false)  // if ((incomplete) && (! show_trail) && show_codes)
    {
      // var date = new Date() ;
      // var msec = date.getMilliseconds() ;
      // var red = Math.floor ((1000 - msec) / 1000 * 255) ;
      // if (red < 128) { red = 128 ; }
      // ctx.fillStyle = "rgb("+red+",0,0)" ; 
      ctx.fillStyle = "red" ; 
      label = "XX" ;                     
      write (55, MARGIN_T-7, label);
      ctx.fillStyle = "white";
      label = "= Last month(s) missing" ;                     
      write (73, MARGIN_T-7, label);
    }  
  }

  function drawButtons()
  {
    // draw background for buttons
    ctx.fillStyle = "rgb(56,56,56)";
    ctx.fillRect (buttons_x, buttons_y, buttons_w, buttons_h) ;
    ctx.strokeStyle = "black";

    // draw buttons
    for (x = 0 ; x < b.length ; x++)
    { drawButton (b[x]) ; }
  }
    
  function testButtons()
  {    
    button_prev = button ;
    button = -1 ;
    for (x = 0 ; x < b.length ; x++)
    { 
      if ((mouse_x >= buttons_x + b[x].x) && (mouse_x <= buttons_x + b[x].x+b[x].w) &&
          (mouse_y >= buttons_y + b[x].y) && (mouse_y <= buttons_y + b[x].y+b[x].h))
      { button = x ; }
    }
    if (button > -1)
    {                
      if (button < 4) // speed buttons
      {
        for (x = 0 ; x < 4 ; x++)
        { b[x].active = (x == button) ; }
      
        if (button == 3)  
        { ready = true ; }
        else
        {
          if (button == 0) // restart slow
          { steps_per_month = 30 ; }
          if (button == 1) // restart normal
          { steps_per_month = 8 ; }
          if (button == 2) // restart fast
          { steps_per_month = 4 ; }
      
          if (x_axis_mode == x_axis_editors) // slow down compared with original animation 
          { steps_per_month *= 2 ; }
          
          restart() ;
        }  
      }                     
      else
      {
        if ((button == 4) && (button != button_prev)) // edits > 5
        { 
          b[4].active = ! b[4].active ; 
          r_follows_editors = ! r_follows_editors ;
        }
        if ((button == 5) && (button != button_prev))
        { 
          b[5].active = ! b[5].active ; 
          show_codes = ! show_codes ;
        }
        if (button == 6) // logarithmic / lineair
        { 
          if (y_axis_mode == y_axis_lin)
          {
            if (VARY_YSCALE)
            {
              if (mouse_x <= buttons_x + b[6].x+15) 
              {
                articles_max = Math.floor (articles_max * 0.95) ;
                if (articles_max < 10000)
                { articles_max = 10000 ; }
                button = button_prev ;  
              }
              if (mouse_x >= buttons_x + b[6].x+b[6].w-15) 
              {
                articles_max = Math.floor (articles_max * 1/0.95) ;
                if (articles_max > articles_max_hi)
                { articles_max = articles_max_hi ;  }
                button = button_prev ;  
              }
            }
          }
          if (button != button_prev) 
          {
            // b[6].active = true ;  b[7].active = false ; 
            if (y_axis_mode == y_axis_lin)
            {
              y_axis_mode = y_axis_log ;
              b[6].t = "log" ; 
            }  
            else
            {
              y_axis_mode = y_axis_lin ;
              b[6].t = "lin" ; 
            }  
            steps_switch_scale = steps_switch_scale_max ;
            SetValuesLogLin() ;
          }  
        }
      }  
    } 
  }

  function TrackCoordinatesInImage(evt)
  {
    Coordinate_X_InImage = Coordinate_Y_InImage = 0;
    
    //if (window.event && !window.opera && typeof event.offsetX == "number") 
    //{ // IE 5+
    //  Coordinate_X_InImage = event.offsetX;
    //  Coordinate_Y_InImage = event.offsetY;
    //} 
    //else 
    
    // Mozilla-based browsers
    if (document.addEventListener && evt && typeof evt.pageX == "number")
    { 
      var Element = evt.target;
      var CalculatedTotalOffsetLeft, CalculatedTotalOffsetTop;
      CalculatedTotalOffsetLeft = CalculatedTotalOffsetTop = 0;
      while (Element.offsetParent) 
      {
        CalculatedTotalOffsetLeft += Element.offsetLeft ;
        CalculatedTotalOffsetTop += Element.offsetTop ;
        Element = Element.offsetParent ;
      }
      Coordinate_X_InImage = evt.pageX - CalculatedTotalOffsetLeft ;
      Coordinate_Y_InImage = evt.pageY - CalculatedTotalOffsetTop ;
      
    }
    document.getElementById('cv').innerHTML = "X:"+Coordinate_X_InImage+" Y: "+Coordinate_Y_InImage;
    return false ;
  }  
  
  function Wikipedia()
  {
    this.x = 0 ;
    this.y = 0 ;
    this.r = 12 ; 
    this.xprev = 0 ;                     
    this.yprev = 0 ;
    this.value = 0 ;
    this.valuelast = 0 ;
    this.maxsize = 0 ;
    this.show = false ;
    this.rand = 0 ; //(Math.random() - 0.5) * steps_per_month * dxstep ;
    this.transparency_fill = transparency_fill ;
    this.transparency_line = transparency_line ;
    this.last = "" ;
    this.sizeprev= 0 ;
  }

  Wikipedia.prototype.update = function(i)
  {
     step0 = step % steps_per_month ;
     share_new_value = step0 / steps_per_month ;
     share_old_value = 1 - share_new_value ;
//if (i == 0)
//{
    if (this.x > 0)
    {
      if (steps_switch_scale == steps_switch_scale_max) 
      {
        this.yprev = this.y ;
        if (this.yprev < MARGIN_T) { this.yprev = MARGIN_T ; }
      }                     
     
      if (steps_switch_scale > 0) 
      {                     
        if (this.size == 0)
        { this.size = this.sizeprev ; }
      
        if (y_axis_mode == y_axis_log)
        { this.y = (this.size == 0) ? this.yprev : canvas.height - (MARGIN_T + ((Math.log(this.size)/LOG10)-y_min_log)  * diagram_height) ; }
        else
        { this.y = (this.size == 0) ? this.yprev : canvas.height - (MARGIN_B + this.size / articles_max * diagram_height) ; }

        this.y = this.yprev * steps_switch_scale/steps_switch_scale_max + this.y * (1 - steps_switch_scale/steps_switch_scale_max) ; 
                                  
        return ;
      }
    }  

    this.label = this.langcode ;

    this.size1 = 0 ;
    this.size2 = this.articles [index] ;
    if (index > 0)
    { this.size1 = this.articles [index-1] ; }
    if (this.size1 == undefined) { this.size1 = 0 ; }
    if (this.size2 == undefined) { this.size2 = 0 ; }
    
    if (this.size2 > 0)
    {                  
      this.size = (step0 / steps_per_month) * this.size2 + (1 - (step0 / steps_per_month)) * this.size1 ;
    }                   
    else
    { 
      if (this.size1 > 0)
      { 
        if (i < 25) // signal only when data missing for 25 largest wikis
        { 
          incomplete = true ; 
                  
          if (PROJECT === 'Wikipedia')
          {
            if (year != TILL_YEAR)
            { this.last = year_prev + " " + MONTHS[month_prev] ; }
            else
            { this.last = MONTHS[month_prev] ; }
          }  
        }
        this.size = this.size1 ; 
      }                   
      else
      {
        if ((this.maxsize > 0) && (i < 25)) // signal only when data missing for 25 largest wikis
        { incomplete = true ; }
      }
    }
    
    if (this.size > 0)
    { this.sizeprev = this.size ; }

    if (this.size > this.maxsize)
    { this.maxsize = this.size ; }

    if (this.maxsize >= y_min)
    { this.show = true ; }
    
    if (this.maxsize == 0) { return ; }

    if (x_axis_time)
    { 
      this.x = (this.size2 == 0) ? this.xprev : MARGIN_L + cycle * dxstep - (this.start*steps_per_month*dxstep) + this.rand ;
      if (y_axis_mode == y_axis_log)
      { this.y = (this.size == 0) ? this.yprev : canvas.height - (MARGIN_T + ((Math.log(this.size)/LOG10)-y_min_log)  * diagram_height) ; }
      else
      { this.y = (this.size == 0) ? this.yprev : canvas.height - (MARGIN_B + this.size / articles_max * diagram_height) ; }
    }
    // else 
    if (x_axis_mode == x_axis_editors)
    {  
      editors5_step = (step0 / steps_per_month) * this.editors5 [index];
      if (index > 0)
      { editors5_step += (1 - (step0 / steps_per_month)) * this.editors5 [index-1] ; }
      if (editors5_step < 1)
      { editors5_step = 1 ; }
      this.x = (editors5_step < 1) ? this.xprev : MARGIN_L + (Math.log(editors5_step)/LOG10) * diagram_width_log_editors5 ; //+ this.rand ;

      //if (this.x <= MARGIN_L + (Math.log(5)/LOG10) * diagram_width_log_editors5)
      //{ trace ("i:" + i + ",this.x:" + this.x + ", editors:" + editors5_step + ", width: " + diagram_width_log_editors5) ; }
      //else
      //{ this.x = 800 ; }
      
      if (y_axis_mode == y_axis_log)
      { this.y = (this.size == 0) ? this.yprev : canvas.height - (MARGIN_T + ((Math.log(this.size)/LOG10)-y_min_log)  * diagram_height) ; }
      // else
      if (y_axis_mode == y_axis_lin)
      { this.y = (this.size == 0) ? this.yprev : canvas.height - (MARGIN_B + this.size / articles_max * diagram_height) ; }
      // else
      if (y_axis_mode == y_axis_growth_contrib)
      { 
        if (g_mode == g_mode_monthly)
        {
          if ((index > 0) && (this.editors5 [index-1] > 0))
          { 
            editors5_growth = ((this.editors5 [index] / this.editors5 [index-1])-1) ; 
            if (editors5_growth < -1) { editors5_growth = -1 ; }
            if (editors5_growth >  1) { editors5_growth = 1 ; }
          }
          else 
          { editors5_growth = 0 ; }
        
          if ((index > 1) && (this.editors5 [index-2] > 0))
          { 
            editors5_growth_prev = ((this.editors5 [index-1] / this.editors5 [index-2])-1) ; 
            if (editors5_growth_prev < -1) { editors5_growth_prev = -1 ; }
            if (editors5_growth_prev >  1) { editors5_growth_prev = 1 ; }
          }  
          else
          { editors5_growth_prev = 0 ; }

          editors5_growth_step = share_new_value * editors5_growth + share_old_value * editors5_growth_prev ; 

          this.y = (editors5_growth_step == 0) ? this.yprev : canvas.height - (MARGIN_B + (editors5_growth_step/2+0.5) * diagram_height) ; 
        }
        if (g_mode == g_mode_yearly)
        {
          if ((index > 12) && (this.editors5 [index-12] > 0))
          { 
            editors5_growth = ((this.editors5 [index] / this.editors5 [index-12])-1) ; 
            if (editors5_growth < -15) { editors5_growth = -15 ; }
            if (editors5_growth >  15) { editors5_growth = 15 ; }
          }
          else 
          { editors5_growth = 0 ; }
        
          if ((index > 13) && (this.editors5 [index-13] > 0))
          { 
            editors5_growth_prev = ((this.editors5 [index-1] / this.editors5 [index-13])-1) ; 
            if (editors5_growth_prev < -15) { editors5_growth_prev = -15 ; }
            if (editors5_growth_prev >  15) { editors5_growth_prev = 15 ; }
          }  
          else
          { editors5_growth_prev = 0 ; }

          editors5_growth_step = share_new_value * editors5_growth + share_old_value * editors5_growth_prev ; 

          this.y = (editors5_growth_step == 0) ? this.yprev : canvas.height - (MARGIN_B + (editors5_growth_step/20+0.2) * diagram_height) ; 
        }  
        //if (i==0)
        //{ trace (step0) ; }
        // { trace (this.editors5 [index-1] + " -> " + this.editors5 [index] + " = " + editors5_growth_step) ; }
      }
    }  

    this.xprev = this.x ;
    this.yprev = this.y ;
    
    if (this.values [index] > 0)
    { this.value = this.values [index] ; }
    if (this.values [index] > 0)
    { this.valuelast = this.values [index] ; }

    if (r_follows_editors)
    {
      this.editors1 = 0 ;
      this.editors2 = this.editors5 [index] ;
      if (index > 0)
      { this.editors1 = this.editors5 [index-1] ; }
      if (this.editors1 == undefined) { this.editors1 = 0 ; }
      if (this.editors2 == undefined) { this.editors2 = 0 ; }

      if (this.editors2 > 0)
      {                  
        step0 = step % steps_per_month ;
        this.editors = (step0 / steps_per_month) * this.editors2 + (1 - (step0 / steps_per_month)) * this.editors1 ;
      }                   
      else
      { 
        if (this.editors1 > 0)
        { this.editors = this.editors1 ; }                   
      }
                                                           
      this.r = radiusCircle (this.editors) ;
    }
    else
    { this.r = r_fixed ; }  
    
    this.ts = Math.floor(this.r) + "pt Arial";
  }         
//}  
  function drawTrail(i)
  {                                     
    var r,x,y,size,editors,value,color ; 

    for (var n = 0 ; n < index ; n++)
    {
      size = a[i].articles[n] ;
      if (size > 0)
      {
        if (y_axis_mode == y_axis_log)
        { y = canvas.height - (MARGIN_T + ((Math.log(size)/LOG10)-y_min_log)  * diagram_height) ; }
        else
        { y = canvas.height - (MARGIN_B + size / articles_max * diagram_height) ; }
      }  
      
      if (x_axis_time)
      { x = MARGIN_L + (n - a[i].start) * steps_per_month * dxstep ; }
      // else 
      if (x_axis_mode == x_axis_editors)
      { x = (a[i].editors5 [n] < 1) ? 1 : MARGIN_L + (Math.log(a[i].editors5[n])/LOG10) * diagram_width_log_editors5 ; } //+ this.rand ; 

      if (r_follows_editors)
      {
        editors = a[i].editors5[n] ;
        r = radiusCircle (editors) ; 
      }
      else
      { r = r_fixed ; }  
      
      if (a[i].values [n] > 0)
      { value = a[i].values [n] ; }
      else
      { value = a[i].valuelast ; }

      color = setcolors (value, 99, transparency_fill, transparency_line) ;

      ctx.strokeStyle = "rgba(192,192,192,1)" ;
      ctx.fillStyle   = color.f ;
      if (size > 0)
      { circle (x, y, r) ; }
    }  
  }

//**** MAIN LOOP ****//

  function loop()
  {
    testButtons() ;

    if ((ready) && (button == button_prev) && ((mouse_x == 0) && (mouse_y == 0) && (! show_trail)) && (steps_switch_scale == 0))
    { 
      var date = new Date() ;
      if (date.getTime() - time_ready > 10) // blink red texts for 10 secs after completion
      { setTimeout (loop, INTERVAL); return ; }
     
    }

    drawGrid() ;

    drawCircles() ;

    if (show_trail) 
    { 
      drawTrail(mouse_index) ; 
      drawTextbox(mouse_index) ; 
    }
                
    drawGrid2() ;    

    if ((! ready) && ((mouse_x == 0) && (mouse_y == 0)) && (steps_switch_scale == 0))
    {
      cycle += 1 ;
      step += 1 ;
      if (step >= steps_per_month)
      {
        month_prev= month ;
        year_prev = year ;

        step = 0 ;
        month += 1 ;
        index ++ ;
        if (month > 12)
        {
          month = 1 ;
          year += 1 ;
        }  
      }
    }

    drawTexts() ;
    drawButtons() ;
    
    if ((year == TILL_YEAR) && (month == TILL_MONTH) && (step >= steps_per_month-1) && (! ready))
    { 
      ready = true ; 
      var date = new Date() ;
      time_ready = date.getTime() ;
      elapsed = " - " + (time_ready - time) ;                                              
      
      button = 3 ;
      for (x = 0 ; x < 4 ; x++)
      { b[x].active = (x == button) ; }
    }

    if (steps_switch_scale > 0) { steps_switch_scale-- ; }

    setTimeout(loop, INTERVAL);
  }

//**** END MAIN LOOP ****//


//**** OUTPUT PRIMITIVES ****//
  function line(x1,y1,x2,y2)
  {
    ctx.beginPath();
    ctx.moveTo(x1,y1);
    ctx.lineTo(x2,y2);
    ctx.closePath();
    ctx.stroke();
  }
  
  function write(x,y,text)
  {
    //ctx.translate(x,y);
    ctx.fillText(text+' ',x,y);
    //ctx.translate(-x,-y);
  }

  function write_vert(x,y,text)
  {
    //ctx.save() ;
    for (t=0 ; t < text.length; t++)
    {
      t2 = text.charAt(t) ;
      dxtext = ctx_measureText(t2) / 2;
      //ctx.translate(x-dxtext,y);
      ctx.fillText(t2+' ',x-dxtext,y);
      y += 10 ;
      //ctx.translate(-x+dxtext,-y+10);
    }  
    //ctx.restore() ;
  }

  function circle(x,y,r)
  {              
    if ((x > 0) && (y > 0))      
    {
      if (r <= 1)
      { r = 1.5 ; }
      ctx.beginPath();
      ctx.arc(x, y, r, 0, PI2, true) ;
      ctx.closePath();
      ctx.fill() ;
      ctx.stroke() ; 
    }  
  }
    
//**** RESTART ****//
  function restart()
  {
    ready = false ;
    cycle = 0 ;
    step  = 0 ;
    index = 0 ;
    month   = FROM_MONTH ;
    year    = FROM_YEAR ;
    for (i = WIKIPEDIAS - 1 ; i >= 0 ; i--)
    {
      a[i].x = 0 ;
      a[i].y = 0 ;
      a[i].r = 12 ; 
      a[i].xprev = 0 ;                     
      a[i].yprev = 0 ;
      a[i].value = 0 ;
      a[i].valuelast = 0 ;
      a[i].maxsize = 0 ;
      a[i].show = false ;
      a[i].rand = (Math.random() - 0.5) * steps_per_month * dxstep ;
      a[i].transparency_fill = transparency_fill ;
      a[i].transparency_line = transparency_line ;
      a[i].size = 0 ;
      a[i].editors1 = 0 ;
      a[i].editors2 = 0 ;
      a[i].editors  = 0 ;
      a[i].last = "" ;
    }

    steps_max = months * steps_per_month ;
    dxstep = diagram_width / steps_max ;
    // setTimeout(loop, 0);
  }

function trace (text)
{     
// drawGrid() ;
  ctx.fillStyle   = "red" ;
  write (MARGIN_L+diagram_width-300, canvas_height - MARGIN_B-10, text) ;
}  


//**** LOAD ****//
  function load(steps)
  {                                      
    if (document.addEventListener) 
    { document.getElementById("cv").addEventListener("mousemove",TrackCoordinatesInImage, false); } 
    // else if(window.event && document.getElementById) 
    // { document.getElementById("idImageToMonitor").onmousemove = TrackCoordinatesInImage; }

    steps_per_month = steps ;
    if (x_axis_mode == x_axis_editors) // slow down compared with original animation 
    { steps_per_month *= 2 ; }
    
    var i, m ;
    canvas = document.getElementById("cv");

    canvas.width  = canvas_width ;
    canvas.height = canvas_height ;
    
    ctx    = canvas.getContext("2d");

    if (! ctx.measureText)
    { 
      var msg = "<center><h2>Animated growth figures per Wikimedia project</h2>" +
                "<b>This javascript-only animation uses state of the art html5 syntax!</b><br>" +  
                "Browsers that can run this animation (Sep 2009) are <font color=green><b>Firefox 3.5+, Safari 4, Chrome</b></font><p>"  + 
                "<b>You can watch a <a href='Animation.html'><font color=#008000>prerecorded Flash registration</font></a> of this animation (8 Mb).</b></center>" ; 

      document.write (msg) ; // alert (msg) ;
    
      return ; 
    }

    ctx.font = "8pt Arial";
    MARGIN_L = ctx_measureText("9999k") + 3 ;

    cycle  = 0 ;
    month  = FROM_MONTH ;
    year   = FROM_YEAR ;
    step   = 0 ;
    index  = 0 ;
    ready  = false ;

    months = (TILL_YEAR*12+TILL_MONTH) - (FROM_YEAR*12+FROM_MONTH) + 1 ;
    years = Math.floor (months/12) ;
                                                                               
    SetValuesLogLin() ;

    init() ;

    for (i = 0; i < WIKIPEDIAS; i++)
    {
      a[i].start = -1 ;
      for (m = 0 ; m < a[i].articles.length ; m++)
      {
        if (a [i].articles[m] > 0)
        { a[i].start = m ; break ; }
      }
      a[i].stop = a[i].articles.length - 1 ;
      for (m = a[i].articles.length - 1 ; m > 0 ; m--)
      {
        if (a [i].articles[m] != 0)
        { break ;  }
        a[i].stop -- ;
      }
    }

    // buttons_x = canvas.width  - MARGIN_R - 63 ;
    // buttons_y = canvas.height - MARGIN_B- 141 ;
    buttons_x = MARGIN_L + 1 ;
    buttons_y = MARGIN_T + 1 ;
    buttons_w = 64 ;  
    buttons_h = 142 ;  

    b[0] = {x: 5, y: 89, w:24, h:20, c:"rgb(48,48,48)", t:">",       pt:"12", dy:7, active:false, f:3}  
    b[1] = {x: 5, y:117, w:24, h:20, c:"rgb(48,48,48)", t:">>",      pt:"10", dy:6, active:true,  f:3}  
    b[2] = {x:35, y: 89, w:24, h:20, c:"rgb(48,48,48)", t:">>>",     pt:"9",  dy:5, active:false, f:3}  
    b[3] = {x:35, y:117, w:24, h:20, c:"rgb(48,48,48)", t:"||||",    pt:"10", dy:4, active:false, f:3}  
    b[4] = {x: 5, y: 61, w:54, h:20, c:"rgb(48,48,48)", t:"editors", pt:"10", dy:4, active:true,  f:2}  
    b[5] = {x: 5, y: 33, w:54, h:20, c:"rgb(48,48,48)", t:"codes",   pt:"10", dy:4, active:true,  f:2}  
    b[6] = {x: 5, y:  5, w:54, h:20, c:"rgb(48,48,48)", t:"log",     pt:"10", dy:4, active:true,  f:2}  
    if (r_mult < 3)
    {
      b[5].active = false ;
      show_codes  = false ;
    }

    aliasses_x = buttons_x + buttons_w + 5 ;
    aliasses_y = MARGIN_T + 12 ;
  }
         
       
  function storepoint(x,y)
  {
    mouse_x = x ;
    mouse_y = y ;
  }         

  function freepoint()
  {
    mouse_x = 0 ;
    mouse_y = 0 ;
  }         
  
  function footer()
  {
    canvas_width = getParameter ('canvas_width') ;
    if (! canvas_width) { canvas_width = '800' ; } 
    canvas_height = getParameter ('canvas_height') ;
    if (! canvas_height) { canvas_height = '600' ; } 
    if (canvas_width  > 4000) { canvas_width  = '4000' ; } 
    if (canvas_height > 3000) { canvas_height = '3000' ; } 
    // alert ("w:"+canvas_width + " h:"+canvas_height) ;
    canvas_wh_min = (canvas_width < canvas_height) ? canvas_width : canvas_height ;
    r_mult  = canvas_wh_min / 200 ;
    r_fixed = canvas_wh_min / 100 + 2 ;
    if (r_fixed < 7) { r_fixed = 7 ; }
    

    var href  = "" ;
    var links = "Project:&nbsp;&nbsp;" ;
    for (var i=0 ; i < PROJECTS.length ; i++)
    {
      if (PROJECT !== PROJECTS [i])
      { links += "<a href='AnimationProjectsGrowth" + PROJECTSCODES [i] + ".html?canvas_width=" + canvas_width + "\&canvas_height=" + canvas_height + "'>" + PROJECTS [i] + "</a>&nbsp;&nbsp;" ;     }
      else
      { 
        href   = "<a href='AnimationProjectsGrowth" + PROJECTSCODES [i] + ".html?"
        links += "<b><font color=#B0B0B0>" + PROJECTS [i] + "</font></b> ";     
      }
    }
                             
    var sizes = " | Canvas: " ;
    if (canvas_width < 8000)                             
    { sizes = "<br>Canvas: " ; }
    sizes += href + "canvas_width=600&canvas_height=450'>600x450</a>&nbsp;&nbsp;" + 
             href + "canvas_width=800&canvas_height=600'>800x600</a>&nbsp;&nbsp;" + 
             href + "canvas_width=900&canvas_height=675'>900x675</a>&nbsp;&nbsp;" + 
             href + "canvas_width=1000&canvas_height=750'>1000x750</a>&nbsp;&nbsp;" + 
             href + "canvas_width=1200&canvas_height=900'>1200x900</a>&nbsp;&nbsp;" + 
             href + "canvas_width=1600&canvas_height=1200'>1600x1200</a> " ; 

    var nolink  = href + "canvas_width="+canvas_width+"&canvas_height="+canvas_height+"'>"+canvas_width+"x"+canvas_height+"</a>" ;
    var nolink2 = "<b><font color=#B0B0B0>"+canvas_width+"x"+canvas_height+"</font></b> " ;
    // alert (nolink+"\n"+sizes) ; 
    sizes = sizes.replace (nolink, nolink2) ;
    
    var author ;
    if (canvas_width < 8000)                             
    { author = "<br>Author:&nbsp;&nbsp;&nbsp;<font color=#B0B0B0>Erik Zachte</font> - <a href='http://infodisiac.com/'>http://infodisiac.com/</a>" ; }
    else 
    { author = "<br>Author:&nbsp;&nbsp;&nbsp;<font color=#B0B0B0>Erik Zachte</font> - <a href='http://infodisiac.com/'>http://infodisiac.com/</a>" ; }
    
    var explanation = 
    "<hr color=#606060>" + 
    "<font color=#A0A0A0><b>See how the " + PROJECT + " project evolves over time, both in article count and size, and in active editors.</font></b><p>" +
    "&bull; Click &gt;, &gt;&gt; or &gt;&gt;&gt; to rerun the animation at different speeds.<br>" +
    "&bull; Click a circle to see the full language name. The displayed codes are the official Wikimedia language codes.<br>" + 
    "&bull; Click 'codes' to hide or display language codes<br>" +
    "&bull; Click 'editors' to switch between alternating views: either all projects are shown as equally sized circles,<br>" + 
    "&nbsp;&nbsp;or the size of each circle represents the number of active editors (&gt; 5 edits in that month).<br>" +
    "&bull; Switch between lineair (LIN) and logarithmic (LOG) vertical scales.<br>" + 
    "&nbsp;&nbsp;On a lineair vertical scale you can vary the maximum value visible. (click arrow left/right of button LIN)" +
    "<hr color=#606060>" +                                            
    "This javascript-only animation reuires a browser with support for inline animations (html5 canvas object).<br>" +  
    "The animation runs as expected on <b>Firefox 3.5+, Safari 4, Chrome</b> (Sep 2009)<br>" +
    "Inspiration was drawn from <a href='http://en.wikipedia.org/wiki/Hans_Rosling'>Hans Rosling</a>'s wonderful <a href='http://www.gapminder.org/video/gap-cast/'>Gapcasts</a>." ;
    
    document.write (links+sizes+author+explanation) ;
  }
