#!/usr/bin/perl

$out_ploticus = <<__PLOTICUS_1__ ;
#proc settings
  months: MONTHS

#proc page
  dobackground: yes
//pagesize: 9.8 5.8
  pagesize: 8.55 5.3
  backgroundcolor: gray(0.9)
  tightcrop: yes
  dopagebox: no

#proc areadef
  rectangle: 0.13 0.35 8.00 5.1
  frame: no
  areacolor: gray(0.2) // black // white
  xscaletype: date mm/dd/yyyy
  xrange: XRANGELO XRANGEHI
  yrange: 0 YRANGE

#proc drawcommands
  commands:
  color gray(0.25)
  textsize 9
  movp 0.13 5.15
  text TITLE2

#proc drawcommands
  commands:
  color black
  textsize 9
  movp 4.27 5.15
  centext TITLE1

#proc drawcommands
  commands:
  color black
  textsize 6
  movp 8.28 5.20
  rightjust SCALE

#proc xaxis:
  stubs: incremental MONTHINC month
  stubformat: Mmm
  stubcull: 0.05
  stubdetails: size=6
  autoyears: yyyy

#proc xaxis:
  ticincrement: 1 month
//  ticslide: 2 month
  grid color=gray(0) style=1
  stubs: none
  tics: none

#proc xaxis:
  ticincrement: 3 month
//ticslide: 2 month
  grid color=gray(0) style=2
  stubs: none
  tics: none

#proc yaxis
  stubs: inc INCSTUB
//minortics: yes
//minorticinc: MINORTIC
//  stubformat: STUBFORMAT !!!!!!!!!!!! %2.0f
  stubdetails: size=6 adjust=0.28,0 align=L
  grid color=black
  //gray(0.8)
  //gray(0.8)
  // black // gray(0.3)
//location: 9.38
  location: 8.00
  ticlen: 0 0.08
//minorticlen: 0 0.03

#proc getdata
  file: FILE
  fieldnameheader: yes
  delim: comma
#endproc

PROCSPLOT
PROCRECT
PROCLEGEND

#endproc

__PLOTICUS_1__

#------------------------------------------------------------------------

$out_ploticus_dummy = <<__PLOTICUS_2__ ;

#proc areadef
  rectangle: 1 1 3 2
  frame: no
  xrange: 1 10
  yrange: 1 10

#proc drawcommands
  commands:
  color red
  mov 1 1
  text TEST
#endproc

__PLOTICUS_2__

1 ;
