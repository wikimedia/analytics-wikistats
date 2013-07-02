#!/usr/bin/perl

sub SetScripts
{
$include_script_plot_go = <<__SCRIPT_PLOT_GO__ ;
box()
dev.off()
__SCRIPT_PLOT_GO__

$include_script_plot_credits = <<__SCRIPT_PLOT_CREDITS__ ;
mtext(paste(" stats.wikimedia.org "), cex=0.85, line=1.5, side=3, adj=1, outer=FALSE, col="#000000")
mtext(paste ("Erik Zachte  -  perl+R  -  ", format(Sys.time(), "%b %d, %H:%M ")), cex=0.80, line=0.2, side=4, adj=0, outer=FALSE, col="#AAAAAA")
__SCRIPT_PLOT_CREDITS__

$include_script_credits_ez = <<__SCRIPT_EDIT_CREDITS_EZ__ ;
mtext(paste(format(Sys.time(), " stats.wikimedia.org ")), cex=0.85, line=1.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext(paste(format(Sys.time(), " %Y-%m-%d %H:%M ")), cex=0.85, line=0.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext("Script: Erik Zachte. Renderer: R", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")
__SCRIPT_EDIT_CREDITS_EZ__

$include_script_plot_cairo_640_240 = <<__SCRIPT_PLOT_CAIRO__ ;
#install.packages(c("Cairo"), repos="http://cran.r-project.org" )
 library(Cairo)
 Cairo(width=640, height=240, file="FILE_PNG_RAW", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test")
__SCRIPT_PLOT_CAIRO__

$include_script_plot_data = <<__SCRIPT_PLOT_DATA__ ;
plotdata <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[COL_DATA]
counts   <- plotdata[COL_COUNTS]
dates    <-strptime(as.character(plotdata\$month), "%m/%d/%Y")
plotdata = data.frame(date=dates,counts)
plotdata
attach (plotdata)
r <- as.POSIXct(round(range(dates), "days"))
__SCRIPT_PLOT_DATA__

$include_script_plot_top_month = <<__SCRIPT_PLOT_TOP_MONTH__ ;
mtext("max MAX_METRIC ", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("MAX_MONTH: MAX_VALUE ", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")
__SCRIPT_PLOT_TOP_MONTH__

$include_script_plot_grid = <<__SCRIPT_PLOT_GRID__ ;
axis.POSIXct(1, at=seq(r[1], r[2], by="month"), format=" ",   tck=1,     col="gray80") # vertical monthly bars light grey
axis.POSIXct(1, at=seq(r[1], r[2], by="year"),  format="%Y ", tck=1,     col="gray80") # year numbers below x axis
axis.POSIXct(1, at=seq(r[1], r[2], by="year") , format=" ",   tck=1,     col="gray20") # vertical yearly bar dark grey
axis.POSIXct(1, at=seq(r[1], r[2], by="year") , format=" ",   tck=-0.02, col="gray20") # extending slightly below x asix (as tick marks)
__SCRIPT_PLOT_GRID__

$include_script_reverts_axis = <<__SCRIPT_PLOT_REVERTS_AXIS__ ;
axis(2, at=10*c(0:10),labels=10*c(0:10), col.axis="black", las=2, tck=1, col="#D0D0D0")
#axis.POSIXct(1, at=seq(r[1], r[2], by="month"), format="\b", tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="year"), format="%b %y ", tck=1, col="#909090", mar=c(4,3,2.5,1))
__SCRIPT_PLOT_REVERTS_AXIS__

$include_script_reverts_title = <<__SCRIPT_PLOT_REVERTS_TITLE__ ;
title(" TITLE ",  cex.main=2,   font.main=3, col.main= "black")
__SCRIPT_PLOT_REVERTS_TITLE__

$include_script_plot_axis_summary = <<__SCRIPT_PLOT_AXIS_SUMMARY__ ;
#axis(2, at=100000000*c(0:10),labels=100000000*c(0:10), col.axis="black", las=2, tck=1, col="#D0D0D0")
axis(2, col.axis="black", las=2, tck=1, col="#D0D0D0")
__SCRIPT_PLOT_AXIS_SUMMARY__

$include_script_title = <<__SCRIPT_PLOT_TITLE__ ;
title(\" TITLE \", cex.main=1.2, font.main=3, col.main= \"black\")
__SCRIPT_PLOT_TITLE__

$include_script_plot_period  = <<__SCRIPT_PLOT_PERIOD__ ;
mtext(paste (\"PERIOD \"), cex=0.85, line=0.5, side=3, adj=1, outer=FALSE, col=\"#000000\")
__SCRIPT_PLOT_PERIOD__

$include_script_options_summary = <<__SCRIPT_PLOT_OPTIONS_SUMMARY__ ;
options("scipen"=20)
par(mar=c(3.5,4,2.5,1.5))
par(oma=c(0,0,0,0))
__SCRIPT_PLOT_OPTIONS_SUMMARY__

$include_plot_months_normalized  = <<__SCRIPT_PLOT_MONTHS_NORMALIZED__ ;
mtext(\"metrics have been normalized to months of 30 days (Jan*30/31, Feb*(29|30)/28, Mar*30/31, etc)\", cex=0.85, line=2.2, side=1, outer=FALSE, col=\"#808080\")
__SCRIPT_PLOT_MONTHS_NORMALIZED__

$include_script_reverts_cairo_trends = <<__SCRIPT_REVERTS_CAIRO_TRENDS__ ;
#install.packages(c("Cairo"), repos="http://cran.r-project.org" )
 library(Cairo)
 Cairo(width=640, height=480, file="FILE_PNG_TRENDS", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test")
#Cairo(width=600, height=450, file="FILE_PNG", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test") # for blog
#CairoSVG(width=600, height=450, file="FILE_SVG", pointsize=10, bg="#F0F0F0", canvas = "white", dpi = 1000, title="Test")
__SCRIPT_REVERTS_CAIRO_TRENDS__

$include_script_reverts_cairo_raw = <<__SCRIPT_REVERTS_CAIRO_RAW__ ;
#install.packages(c("Cairo"), repos="http://cran.r-project.org" )
 library(Cairo)
 Cairo(width=640, height=480, file="FILE_PNG_RAW", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test")
#Cairo(width=600, height=450, file="FILE_PNG", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test") # for blog
#CairoSVG(width=600, height=450, file="FILE_SVG", pointsize=10, bg="#F0F0F0", canvas = "white", dpi = 1000, title="Test")
__SCRIPT_REVERTS_CAIRO_RAW__

$include_script_dates = <<__SCRIPT_REVERTS_DATES__ ;
dates    <-strptime(as.character(plotdata\$month), "%m/%d/%Y")
dates
__SCRIPT_REVERTS_DATES__

$include_script_plot_multititle = <<__SCRIPT_PLOT_MULTI_TITLE__ ;
#multiTitle <- function(...){
###
### multi-coloured title
###
### examples:
###  multiTitle(color="red","Traffic",
###             color="orange"," light ",
###             color="green","signal")
###
### - note triple backslashes needed for embedding quotes:
###
###  multiTitle(color="orange","Hello ",
###             color="red"," \\\"world\\\"!")
###
### Barry Rowlingson <b dot rowlingson at lancaster dot ac dot uk>
###
#  l = list(...)
#  ic = names(l)=='color'
#  colors = unique(unlist(l[ic]))

#  for(i in colors){
#    color=par()$col.main
#    strings=c()
#    for(il in 1:length(l)){
#      p = l[[il]]
#      if(ic[il]){ # if this is a color:
#        if(p==i){  # if it's the current color
#          current=TRUE
#        }else{
#          current=FALSE
#        }
#      }else{ # it's some text
#        if(current){
#          # set as text
#          strings = c(strings,paste('"',p,'"',sep=""))
#        }else{
#          # set as phantom
#          strings = c(strings,paste("phantom(\"",p,"\")",sep=""))
#        }
#      }
#    } # next item
#    ## now plot this color
#    prod=paste(strings,collapse="*")
#    express = paste("expression(",prod,")",sep="")
#    e=eval(parse(text=express))
#    title(e,col.main=i,cex.main=2)
#  } # next color
#  return()
#}
__SCRIPT_PLOT_MULTI_TITLE__

#----------------------------------------------------------

# PE = Plot Edits
$out_script_plot_edits = <<__SCRIPT_EDIT_PLOT_EDITS__ ;

$include_script_plot_multititle

plotdata <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:22]
counts   <- plotdata[2:6]

$include_script_dates

plotdata = data.frame(date=dates,counts)
plotdata
attach (plotdata)

$include_script_reverts_cairo_raw

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))

plot (dates,plotdata\$PE_edits_total,type="l", col="black", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i")

$include_script_reverts_axis
$include_script_reverts_title

lines(dates,plotdata\$PE_edits_total,col="black", lty="solid", lwd=2)
lines(dates,plotdata\$PE_edits_bots,col="green4", lty="solid", lwd=2)
lines(dates,plotdata\$PE_edits_reg_users,col="blue", lty="solid", lwd=2)
lines(dates,plotdata\$PE_edits_anon_users,type="l", col="red", lty="solid", lwd=2)
lines(dates,plotdata\$PE_reverts_total,col="magenta3", lty="solid", lwd=2)

legend("topleft",c("All edits ", "TOT_G PERC_G " , " ", "Registered edits ", "TOT_R PERC_R ", " ", "Anonymous edits ", "TOT_A PERC_A ", " ", "Bot edits ", "TOT_B PERC_B ",  " ", "Reverts ", "TOT_X PERC_X ","", "(article edits only)"), lty=1, lwd=2, col=c("black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "red","#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "magenta3", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("100 = max edits in ", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("MAX_MONTH: EDITS ", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")

$include_script_credits_ez
$include_script_plot_go

plotdata <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:22]
counts   <- plotdata[2:6]

$include_script_dates

times_tot     = ts(plotdata\$PE_edits_total,      start=2001, freq=12)
times_reg     = ts(plotdata\$PE_edits_reg_users,  start=2001, freq=12)
times_anon    = ts(plotdata\$PE_edits_anon_users, start=2001, freq=12)
times_bots    = ts(plotdata\$PE_edits_bots,       start=2001, freq=12)
times_reverts = ts(plotdata\$PE_reverts_total,    start=2001, freq=12)

times_tot_decomposed     = decompose(times_tot,     type="mult")
times_reg_decomposed     = decompose(times_reg,     type="mult")
times_anon_decomposed    = decompose(times_anon,    type="mult")
times_bots_decomposed    = decompose(times_bots,    type="mult")
times_reverts_decomposed = decompose(times_reverts, type="mult")

plotdata = data.frame(date=dates,counts,times_tot_decomposed\$trend,times_anon_decomposed\$trend,times_reg_decomposed\$trend,times_bots_decomposed\$trend,times_reverts_decomposed\$trend)
plotdata
attach (plotdata)

$include_script_reverts_cairo

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))

plot (dates,plotdata\$PE_edits_total,type="l", col="black", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i")

$include_script_reverts_axis
$include_script_reverts_title


lines(dates, plotdata\$times_tot_decomposed\.trend,     type="l", col="black",    lty="solid", lwd=3)
lines(dates, plotdata\$times_anon_decomposed\.trend,    type="l", col="red",      lty="solid", lwd=3)
lines(dates, plotdata\$times_reg_decomposed\.trend,     type="l", col="blue",     lty="solid", lwd=3)
lines(dates, plotdata\$times_bots_decomposed\.trend,    type="l", col="green4",   lty="solid", lwd=3)
lines(dates, plotdata\$times_reverts_decomposed\.trend, type="l", col="magenta3", lty="solid", lwd=3)

lines(dates, plotdata\$PE_edits_total,               col="black",    lty="solid", lwd=0.8)
lines(dates, plotdata\$PE_edits_bots,                col="green4",   lty="solid", lwd=0.8)
lines(dates, plotdata\$PE_edits_reg_users,           col="blue",     lty="solid", lwd=0.8)
lines(dates, plotdata\$PE_edits_anon_users,type="l", col="red",      lty="solid", lwd=0.8)
lines(dates, plotdata\$PE_reverts_total,             col="magenta3", lty="solid", lwd=0.8)

legend("topleft",c("All edits ", "TOT_G PERC_G " , " ", "Registered edits ", "TOT_R PERC_R ", " ", "Anonymous edits ", "TOT_A PERC_A ", " ", "Bot edits ", "TOT_B PERC_B ",  " ", "Reverts ", "TOT_X PERC_X ","", "(article edits only)"), lty=1, lwd=2, col=c("black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "red","#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "magenta3", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("100 = max edits in ", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("MAX_MONTH: EDITS ", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")
$include_script_credits_ez
$include_script_plot_go
__SCRIPT_EDIT_PLOT_EDITS__

#----------------------------------------------------------

# PR = Plot Reverts
$out_script_plot_reverts = <<__SCRIPT_EDIT_PLOT_REVERTS__ ;

$include_script_plot_multititle

plotdata <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:22]
counts   <- plotdata[2:21]

$include_script_dates

#times_anon = ts(plotdata\$PR_reverts_anon_users, start=2001, freq=12)
#times_anon_decomposed = decompose(times_anon, type="mult")
#plotdata = data.frame(date=dates,counts,times_anon_decomposed\$trend)

times_tot = ts(plotdata\$PE_edits_total, start=2001, freq=12)
times_tot_decomposed = decompose(times_tot, type="mult")

plotdata = data.frame(date=dates,counts)
attach (plotdata)

$include_script_reverts_cairo_raw

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))
plot (dates,plotdata\$PR_reverts_total,type="l", col="black", lty="solid", lwd=1, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=YLIM_MAX)

$include_script_reverts_axis
$include_script_reverts_title


#lines(dates,plotdata\$times_anon_decomposed\.trend, type="l", col="red",    lty="solid", lwd=3)
lines(dates,plotdata\$PR_reverts_total,                        col="black",  lty="solid", lwd=2.5)
lines(dates,plotdata\$PR_reverts_bots,                         col="green4", lty="solid", lwd=1.8)
lines(dates,plotdata\$PR_reverts_reg_users,                    col="blue",   lty="solid", lwd=1.8)
lines(dates,plotdata\$PR_reverts_anon_users,         type="l", col="red",    lty="solid", lwd=1.8)

legend("topleft",c("Ratio for all edits ", "TOT_G PERC_G " , " ", "for registered edits ", "TOT_R PERC_R ", " ", "for anonymous edits ", "TOT_A PERC_A ", " ", "for bot edits ", "TOT_B PERC_B ", "", "(article edits only)"), lty=1, lwd=2, col=c("black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "red","#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("percentage", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("reverted", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")

#mtext("Script: Erik Zachte. Renderer: R.    Ratio is 'reverts per editor class/all edits by editor class'", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")

$include_script_credits_ez
$include_script_plot_go

plotdata <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:22]
counts   <- plotdata[2:21]

$include_script_dates

times_tot = ts(plotdata\$PR_reverts_total,       start=2001, freq=12)
times_reg = ts(plotdata\$PR_reverts_reg_users,   start=2001, freq=12)
times_anon = ts(plotdata\$PR_reverts_anon_users, start=2001, freq=12)
times_bots = ts(plotdata\$PR_reverts_bots,       start=2001, freq=12)

times_tot_decomposed  = decompose(times_tot,  type="mult")
times_reg_decomposed  = decompose(times_reg,  type="mult")
times_anon_decomposed = decompose(times_anon, type="mult")
times_bots_decomposed = decompose(times_bots, type="mult")

plotdata = data.frame(date=dates,counts,times_tot_decomposed\$trend,times_anon_decomposed\$trend,times_reg_decomposed\$trend,times_bots_decomposed\$trend,times_reverts_decomposed\$trend)
attach (plotdata)

$include_script_reverts_cairo_trends

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))
plot (dates,plotdata\$PR_reverts_total,type="l", col="black", lty="solid", lwd=1, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=YLIM_MAX)

$include_script_reverts_axis
$include_script_reverts_title


lines(dates,plotdata\$times_tot_decomposed\.trend,  type="l", col="black",  lty="solid", lwd=3)
lines(dates,plotdata\$times_anon_decomposed\.trend, type="l", col="red",    lty="solid", lwd=3)
lines(dates,plotdata\$times_reg_decomposed\.trend,  type="l", col="blue",   lty="solid", lwd=3)
lines(dates,plotdata\$times_bots_decomposed\.trend, type="l", col="green4", lty="solid", lwd=3)

lines(dates,plotdata\$PR_reverts_total,               col="black",  lty="solid", lwd=0.8)
lines(dates,plotdata\$PR_reverts_bots,                col="green4", lty="solid", lwd=0.8)
lines(dates,plotdata\$PR_reverts_reg_users,           col="blue",   lty="solid", lwd=0.8)
lines(dates,plotdata\$PR_reverts_anon_users,type="l", col="red",    lty="solid", lwd=0.8)

legend("topleft",c("Ratio for all edits ", "TOT_G PERC_G " , " ", "for registered edits ", "TOT_R PERC_R ", " ", "for anonymous edits ", "TOT_A PERC_A ", " ", "for bot edits ", "TOT_B PERC_B ", "", "(article edits only)"), lty=1, lwd=2, col=c("black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "red","#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("percentage", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("reverted", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")

#mtext("Script: Erik Zachte. Renderer: R.    Ratio is 'reverts per editor class/all edits by editor class'", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")

$include_script_credits_ez
$include_script_plot_go
__SCRIPT_EDIT_PLOT_REVERTS__


#----------------------------------------------------------

# PA = Plot Anons
$out_script_plot_anons = <<__SCRIPT_EDIT_PLOT_ANONS__ ;

$include_script_plot_multititle

plotdata  <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:26]
counts    <- plotdata[2:25]
dates     <-strptime(as.character(plotdata\$month), "%m/%d/%Y")
plotdata = data.frame(date=dates,counts)
attach (plotdata)

$include_script_reverts_cairo_raw

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))
plot (dates,plotdata\$PA_edits_anon_users,type="l", col="white", lty="solid", lwd=2, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i")

$include_script_reverts_axis
$include_script_reverts_title


lines(dates,plotdata\$PA_edits_anon_users_kept, type="l", col="black",   lty="solid", lwd=1.8)
lines(dates,plotdata\$PA_edits_anon_users,      type="l", col="red",     lty="solid", lwd=1.8)
lines(dates,plotdata\$PA_reverts_by_reg_users,  type="l", col="blue",    lty="solid", lwd=1.8)
lines(dates,plotdata\$PA_reverts_by_anon_users, type="l", col="darkred", lty="solid", lwd=1.8)
lines(dates,plotdata\$PA_reverts_by_bots,       type="l", col="green",   lty="solid", lwd=1.8)

legend("topleft",c("All anonymous edits ", "TOT_AT PERC_AT " , " ", "Not reverted ", "TOT_AM PERC_AM", " ","Reverted by reg user ","TOT_RR PERC_RR ", " ", "Reverted by anon user ", "TOT_RA PERC_RA ",  " ", "Reverted by bot ", "TOT_RB PERC_RB ","", "(article edits only)"), lty=1, lwd=2,col=c("red","#E0E0E0", "#E0E0E0", "black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "darkred", "#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("100 = max anon edits in ", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("MAX_MONTH: EDITS ", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")

$include_script_credits_ez
$include_script_plot_go

plotdata  <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:26]
counts    <- plotdata[2:25]
dates     <-strptime(as.character(plotdata\$month), "%m/%d/%Y")

times_anon        = ts(plotdata\$PA_edits_anon_users,      start=2001, freq=12)
times_anon_kept   = ts(plotdata\$PA_edits_anon_users_kept, start=2001, freq=12)
times_reg         = ts(plotdata\$PA_reverts_by_reg_users,  start=2001, freq=12)
times_anon_revert = ts(plotdata\$PA_reverts_by_anon_users, start=2001, freq=12)
#times_bot_revert = ts(plotdata\$PA_reverts_by_bots,       start=2001, freq=12)

times_anon_decomposed        = decompose(times_anon,        type="mult")
times_anon_kept_decomposed   = decompose(times_anon_kept,   type="mult")
times_reg_decomposed         = decompose(times_reg,         type="mult")
times_anon_revert_decomposed = decompose(times_anon_revert, type="mult")
#times_bot_revert_decomposed = decompose(times_bot_revert,  type="mult")

#plotdata = data.frame(date=dates,counts,times_anon_decomposed\$trend,times_anon_kept_decomposed\$trend,times_reg_decomposed\$trend,times_anon_revert_decomposed\$trend,times_bot_revert_decomposed\$trend)
plotdata = data.frame(date=dates,counts,times_anon_decomposed\$trend,times_anon_kept_decomposed\$trend,times_reg_decomposed\$trend,times_anon_revert_decomposed\$trend)
attach (plotdata)

$include_script_reverts_cairo_trends

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))
plot (dates,plotdata\$PA_edits_anon_users,type="l", col="white", lty="solid", lwd=2, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i")

$include_script_reverts_axis
$include_script_reverts_title

lines(dates, plotdata\$times_anon_kept_decomposed\.trend,   type="l", col="black",   lty="solid", lwd=3)
lines(dates, plotdata\$times_anon_decomposed\.trend,        type="l", col="red",     lty="solid", lwd=3)
lines(dates, plotdata\$times_reg_decomposed\.trend,         type="l", col="blue",    lty="solid", lwd=3)
lines(dates, plotdata\$times_bot_revert_decomposed\.trend,  type="l", col="green",   lty="solid", lwd=3)
#lines(dates,plotdata\$times_anon_revert_decomposed\.trend, type="l", col="darkred", lty="solid", lwd=3)

lines(dates, plotdata\$PA_edits_anon_users_kept, type="l", col="black",   lty="solid", lwd=0.8)
lines(dates, plotdata\$PA_edits_anon_users,      type="l", col="red",     lty="solid", lwd=0.8)
lines(dates, plotdata\$PA_reverts_by_reg_users,  type="l", col="blue",    lty="solid", lwd=0.8)
lines(dates, plotdata\$PA_reverts_by_bots,       type="l", col="green",   lty="solid", lwd=0.8)
#lines(dates,plotdata\$PA_reverts_by_anon_users, type="l", col="darkred", lty="solid", lwd=0.8)

legend("topleft",c("All anonymous edits ", "TOT_AT PERC_AT " , " ", "Not reverted ", "TOT_AM PERC_AM", " ","Reverted by reg user ","TOT_RR PERC_RR ", " ", "Reverted by anon user ", "TOT_RA PERC_RA ",  " ", "Reverted by bot ", "TOT_RB PERC_RB ","", "(article edits only)"), lty=1, lwd=2,col=c("red","#E0E0E0", "#E0E0E0", "black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "darkred", "#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("100 = max anon edits in ", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("MAX_MONTH: EDITS ", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")

$include_script_credits_ez

$include_script_plot_go
__SCRIPT_EDIT_PLOT_ANONS__

# PB = Plot Binaries
$out_script_plot_binaries = <<__SCRIPT_EDIT_PLOT_BINARIES__ ;

$include_script_plot_multititle
$include_script_plot_data
$include_script_plot_cairo_640_240
$include_script_options_summary

#plot (dates,plotdata\$count_1,type="l", log="y", col="blue", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=c(0.001,YLIM_MAX))
 plot (dates,plotdata\$count_1,type="l",          col="blue", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=c(0,YLIM_MAX))

axis(2, col.axis="black", las=2, tck=1, col="#D0D0D0")

$include_script_plot_grid
$include_script_title

lines(dates,plotdata\$count_1,col="COLOR_1", lty="solid", lwd=1.8)
lines(dates,plotdata\$count_2,col="COLOR_2", lty="solid", lwd=1.8)
lines(dates,plotdata\$count_3,col="COLOR_3", lty="solid", lwd=1.8)
lines(dates,plotdata\$count_4,col="COLOR_4", lty="solid", lwd=1.8)
lines(dates,plotdata\$count_5,col="COLOR_5", lty="solid", lwd=1.8)

legend("topleft",c("LABEL_1 ", "LABEL_2 ", "LABEL_3 ", "LABEL_4 ", "LABEL_5 "), lty=1, lwd=1.8, col=c("COLOR_1","COLOR_2", "COLOR_3", "COLOR_4", "COLOR_5"), inset=0.02, bg="#E0E0E0")

$include_script_plot_top_month
$include_script_plot_period
$include_script_plot_credits
$include_script_plot_go
__SCRIPT_EDIT_PLOT_BINARIES__

# PE = Plot Editors
$out_script_plot_editors = <<__SCRIPT_EDIT_PLOT_EDITORS__ ;

$include_script_plot_multititle
$include_script_plot_data
$include_script_plot_cairo_640_240
$include_script_options_summary

plot (dates,plotdata\$count_5,type="l", col="blue", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=c(0,YLIM_MAX))

$include_script_plot_axis_summary
$include_script_plot_grid
$include_script_title

lines(dates,plotdata\$count_5,col="COLOR_5", lty="solid", lwd=1.8)
lines(dates,plotdata\$count_25,col="COLOR_25", lty="solid", lwd=1.8)
lines(dates,plotdata\$count_100,col="COLOR_100", lty="solid", lwd=1.8)

#legend("topleft",c("5+ edits ", "25+ edits ", "100+ edits ", "(reg edits only)"), lty=1, lwd=2, col=c("COLOR_5","COLOR_25", "COLOR_100", "#F0F0F0"), inset=0.05, bg="#E0E0E0")
legend("topleft",c("5+ edits ", "25+ edits ", "100+ edits "), lty=1, lwd=1.8, col=c("COLOR_5","COLOR_25", "COLOR_100"), inset=0.02, bg="#E0E0E0")

$include_script_plot_top_month
$include_script_plot_period
$include_script_plot_credits
$include_script_plot_go
__SCRIPT_EDIT_PLOT_EDITORS__

# PE = Plot Page Views
$out_script_plot_pageviews = <<__SCRIPT_EDIT_PLOT_PAGEVIEWS__ ;

$include_script_plot_multititle
$include_script_plot_data
$include_script_plot_cairo_640_240
$include_script_options_summary

plot (dates,plotdata\$count_normalized,type="l", col="blue", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=c(0,YLIM_MAX))

$include_script_plot_axis_summary
$include_script_plot_grid
$include_script_title

lines(dates,plotdata\$count_normalized,col="green4", lty="solid", lwd=1.8)

$include_script_plot_top_month
$include_script_plot_period
$include_script_plot_credits
$include_plot_months_normalized
$include_script_plot_go
__SCRIPT_EDIT_PLOT_PAGEVIEWS__

# Plot Uploads
$out_script_plot_uploads = <<__SCRIPT_EDIT_PLOT_UPLOADS__ ;

#$include_script_plot_multititle

$include_script_plot_data
$include_script_plot_cairo_640_240
$include_script_options_summary

# total:
# plot (dates,plotdata\$uploads_tot,type="l", col="gray50", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=c(0,YLIM_MAX))
plot (dates,plotdata\$uploads_bot,type="l", col="green4", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=c(0,YLIM_MAX))

$include_script_plot_axis_summary
$include_script_plot_grid
$include_script_title

#lines(dates,plotdata\$uploads_tot,    col="grey50", lty="solid", lwd=1.8)
lines(dates, plotdata\$uploads_bot,    col="green4", lty="solid", lwd=1.8)
lines(dates, plotdata\$uploads_manual, col="blue",   lty="solid", lwd=1.8)
lines(dates, plotdata\$uploads_wizard, col="red",    lty="solid", lwd=1.8)

legend("topleft",c("Bot uploads ", "All manual uploads ", "Manual uploads via wizard "), lty=1, lwd=2, col=c("green4","blue", "red"), inset=0.05, bg="#E0E0E0")

$include_script_plot_top_month
$include_script_plot_period
$include_script_plot_credits
#$out_plot_months_normalized
$include_script_plot_go
__SCRIPT_EDIT_PLOT_UPLOADS__

# Plot Uploaders
$out_script_plot_uploaders = <<__SCRIPT_EDIT_PLOT_UPLOADERS__ ;

#$include_script_plot_multititle
$include_script_plot_data
$include_script_plot_cairo_640_240
$include_script_options_summary

plot (dates,plotdata\$uploaders_ge_1,type="l", col="gray10", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=c(0,YLIM_MAX))

$include_script_plot_axis_summary
$include_script_plot_grid
$include_script_title

lines(dates, plotdata\$uploaders_ge_1,        col="COLOR_1",  lty="solid", lwd=1.8)
lines(dates, plotdata\$uploaders_ge_5,        col="COLOR_5",  lty="solid", lwd=1.8)
lines(dates, plotdata\$uploaders_ge_25,       col="COLOR_25", lty="solid", lwd=1.8)
lines(dates, plotdata\$uploaders_wizard_ge_1, col="COLOR_W1", lty="solid", lwd=1.8)

legend("topleft",c("1+ uploads ", "5+ uploads ", "25+ uploads ","1+ uploads via wizard "), lty=1, lwd=1.8, col=c("COLOR_1","COLOR_5","COLOR_25","COLOR_W1"), inset=0.02, bg="#E0E0E0")

$include_script_plot_top_month
$include_script_plot_period
$include_script_plot_credits
#(not yet) $include_plot_months_normalized
$include_script_plot_go
__SCRIPT_EDIT_PLOT_UPLOADERS__

# Plot [Total|New] Articles
$out_script_plot_articles = <<__SCRIPT_EDIT_PLOT_ARTICLES__ ;

#$include_script_plot_multititle

$include_script_plot_data
$include_script_plot_cairo_640_240
$include_script_options_summary

plot (dates,plotdata\$articles,type="l", col="gray10", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=c(0,YLIM_MAX))

$include_script_plot_axis_summary
$include_script_plot_grid
$include_script_title

lines(dates,plotdata\$articles,col="orange3", lty="solid", lwd=1.8)

#legend("topleft",c("1+ uploads ", "5+ uploads ", "25+ uploads ","1+ uploads via wizard "), lty=1, lwd=1.8, col=c("COLOR_1","COLOR_5","COLOR_25","COLOR_W1"), inset=0.02, bg="#E0E0E0")

$include_script_plot_top_month
$include_script_plot_period
$include_script_plot_credits
#$out_plot_months_normalized
$include_script_plot_go
__SCRIPT_EDIT_PLOT_ARTICLES__

# Plot [Total|New] Articles
$out_script_plot_articles2 = <<__SCRIPT_EDIT_PLOT_ARTICLES2__ ;

#$include_script_plot_multititle

$include_script_plot_data
$include_script_plot_cairo_640_240
$include_script_options_summary

plot (dates,plotdata\$articles_reg,type="l", col="gray10", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=c(0,YLIM_MAX))

$include_script_plot_axis_summary
$include_script_plot_grid
$include_script_title

lines(dates, plotdata\$articles_reg,  col="green4", lty="solid", lwd=1.8)
lines(dates, plotdata\$articles_anon, col="red",    lty="solid", lwd=1.8)
lines(dates, plotdata\$articles_bot,  col="blue",   lty="solid", lwd=1.8)

# http://stat.ethz.ch/R-manual/R-patched/library/graphics/html/legend.html
legend("topleft",c("reg", "anon", "bots"), lty=1, lwd=1.8, col=c("green4","red","blue"), inset=0.02, bg="#E0E0E0")

$include_script_plot_top_month
$include_script_plot_period
$include_script_plot_credits
#$out_plot_months_normalized
$include_script_plot_go
__SCRIPT_EDIT_PLOT_ARTICLES2__

}

1 ;
