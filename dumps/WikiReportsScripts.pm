#!/usr/bin/perl

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

#------------------------------------------------------------------------

sub SetScripts
{

$out_script_multititle = <<__SCRIPT_MULTI_TITLE__ ;
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
__SCRIPT_MULTI_TITLE__

#----------------------------------------------------------

# PE = Plot Edits
$out_script_plot_edits = <<__SCRIPT_EDIT_PLOT_EDITS__ ;
$out_script_multititle

plotdata <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:22]
counts   <- plotdata[2:6]
dates    <-strptime(as.character(plotdata\$month), "%m/%d/%Y")

plotdata = data.frame(date=dates,counts)
plotdata
attach (plotdata)

#install.packages(c("Cairo"), repos="http://cran.r-project.org" )
 library(Cairo)
 Cairo(width=640, height=480, file="FILE_PNG_RAW", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test")
#Cairo(width=600, height=450, file="FILE_PNG", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test") # for blog
#CairoSVG(width=600, height=450, file="FILE_SVG", pointsize=10, bg="#F0F0F0", canvas = "white", dpi = 1000, title="Test")

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))

plot (dates,plotdata\$PE_edits_total,type="l", col="black", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i")

axis(2, at=10*c(0:10),labels=10*c(0:10), col.axis="black", las=2, tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="month"), format="\b", tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="year"), format="%b %y ", tck=1, col="#909090", mar=c(4,3,2.5,1))

title(" TITLE ",  cex.main=2,   font.main=3, col.main= "black")

lines(dates,plotdata\$PE_edits_total,col="black", lty="solid", lwd=2)
lines(dates,plotdata\$PE_edits_bots,col="green4", lty="solid", lwd=2)
lines(dates,plotdata\$PE_edits_reg_users,col="blue", lty="solid", lwd=2)
lines(dates,plotdata\$PE_edits_anon_users,type="l", col="red", lty="solid", lwd=2)
lines(dates,plotdata\$PE_reverts_total,col="magenta3", lty="solid", lwd=2)

legend("topleft",c("All edits ", "TOT_G PERC_G " , " ", "Registered edits ", "TOT_R PERC_R ", " ", "Anonymous edits ", "TOT_A PERC_A ", " ", "Bot edits ", "TOT_B PERC_B ",  " ", "Reverts ", "TOT_X PERC_X ","", "(article edits only)"), lty=1, lwd=2, col=c("black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "red","#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "magenta3", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("100 = max edits in ", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("MAX_MONTH: EDITS ", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext(paste(format(Sys.time(), " stats.wikimedia.org ")), cex=0.85, line=1.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext(paste(format(Sys.time(), " %Y-%m-%d %H:%M ")), cex=0.85, line=0.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext("Script: Erik Zachte. Renderer: R", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")

box()
dev.off()

plotdata <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:22]
counts   <- plotdata[2:6]
dates    <-strptime(as.character(plotdata\$month), "%m/%d/%Y")

times_tot = ts(plotdata\$PE_edits_total, start=2001, freq=12)
times_tot_decomposed = decompose(times_tot, type="mult")

times_reg = ts(plotdata\$PE_edits_reg_users, start=2001, freq=12)
times_reg_decomposed = decompose(times_reg, type="mult")

times_anon = ts(plotdata\$PE_edits_anon_users, start=2001, freq=12)
times_anon_decomposed = decompose(times_anon, type="mult")

times_bots = ts(plotdata\$PE_edits_bots, start=2001, freq=12)
times_bots_decomposed = decompose(times_bots, type="mult")

times_reverts = ts(plotdata\$PE_reverts_total, start=2001, freq=12)
times_reverts_decomposed = decompose(times_reverts, type="mult")

plotdata = data.frame(date=dates,counts,times_tot_decomposed\$trend,times_anon_decomposed\$trend,times_reg_decomposed\$trend,times_bots_decomposed\$trend,times_reverts_decomposed\$trend)
plotdata
attach (plotdata)

#install.packages(c("Cairo"), repos="http://cran.r-project.org" )
 library(Cairo)
 Cairo(width=640, height=480, file="FILE_PNG_TRENDS", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test")
#Cairo(width=600, height=450, file="FILE_PNG", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test") # for blog
#CairoSVG(width=600, height=450, file="FILE_SVG", pointsize=10, bg="#F0F0F0", canvas = "white", dpi = 1000, title="Test")

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))

plot (dates,plotdata\$PE_edits_total,type="l", col="black", lty="solid", lwd=0.5, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i")

axis(2, at=10*c(0:10),labels=10*c(0:10), col.axis="black", las=2, tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="month"), format="\b", tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="year"), format="%b %y ", tck=1, col="#909090", mar=c(4,3,2.5,1))

title(" TITLE ",  cex.main=2,   font.main=3, col.main= "black")

lines(dates,plotdata\$times_tot_decomposed\.trend,type="l", col="black", lty="solid", lwd=3)
lines(dates,plotdata\$times_anon_decomposed\.trend,type="l", col="red", lty="solid", lwd=3)
lines(dates,plotdata\$times_reg_decomposed\.trend,type="l", col="blue", lty="solid", lwd=3)
lines(dates,plotdata\$times_bots_decomposed\.trend,type="l", col="green4", lty="solid", lwd=3)
lines(dates,plotdata\$times_reverts_decomposed\.trend,type="l", col="magenta3", lty="solid", lwd=3)

lines(dates,plotdata\$PE_edits_total,col="black", lty="solid", lwd=0.8)
lines(dates,plotdata\$PE_edits_bots,col="green4", lty="solid", lwd=0.8)
lines(dates,plotdata\$PE_edits_reg_users,col="blue", lty="solid", lwd=0.8)
lines(dates,plotdata\$PE_edits_anon_users,type="l", col="red", lty="solid", lwd=0.8)
lines(dates,plotdata\$PE_reverts_total,col="magenta3", lty="solid", lwd=0.8)

legend("topleft",c("All edits ", "TOT_G PERC_G " , " ", "Registered edits ", "TOT_R PERC_R ", " ", "Anonymous edits ", "TOT_A PERC_A ", " ", "Bot edits ", "TOT_B PERC_B ",  " ", "Reverts ", "TOT_X PERC_X ","", "(article edits only)"), lty=1, lwd=2, col=c("black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "red","#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "magenta3", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("100 = max edits in ", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("MAX_MONTH: EDITS ", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext(paste(format(Sys.time(), " stats.wikimedia.org ")), cex=0.85, line=1.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext(paste(format(Sys.time(), " %Y-%m-%d %H:%M ")), cex=0.85, line=0.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext("Script: Erik Zachte. Renderer: R", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")

box()
dev.off()

__SCRIPT_EDIT_PLOT_EDITS__

#----------------------------------------------------------

# PR = Plot Reverts
$out_script_plot_reverts = <<__SCRIPT_EDIT_PLOT_REVERTS__ ;
$out_script_multititle

plotdata <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:22]
counts   <- plotdata[2:21]
dates    <-strptime(as.character(plotdata\$month), "%m/%d/%Y")
dates
#times_anon = ts(plotdata\$PR_reverts_anon_users, start=2001, freq=12)
#times_anon_decomposed = decompose(times_anon, type="mult")
#plotdata = data.frame(date=dates,counts,times_anon_decomposed\$trend)

times_tot = ts(plotdata\$PE_edits_total, start=2001, freq=12)
times_tot_decomposed = decompose(times_tot, type="mult")

plotdata = data.frame(date=dates,counts)
attach (plotdata)

#install.packages(c("Cairo"), repos="http://cran.r-project.org" )
 library(Cairo)
 Cairo(width=640, height=480, file="FILE_PNG_RAW", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test")
#Cairo(width=600, height=450, file="FILE_PNG", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test") # for blog
#CairoSVG(width=600, height=450, file="FILE_SVG", pointsize=10, bg="#F0F0F0", canvas = "white", dpi = 1000, title="Test")

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))
plot (dates,plotdata\$PR_reverts_total,type="l", col="black", lty="solid", lwd=1, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=YLIM)

axis(2, at=10*c(0:10),labels=10*c(0:10), col.axis="black", las=2, tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="month"), format="\b", tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="year"), format="%b %y ", tck=1, col="#909090", mar=c(4,3,2.5,1))

title(" TITLE ",  cex.main=2,   font.main=3, col.main= "black")

#lines(dates,plotdata\$times_anon_decomposed\.trend,type="l", col="red", lty="solid", lwd=3)
lines(dates,plotdata\$PR_reverts_total,col="black", lty="solid", lwd=2.5)
lines(dates,plotdata\$PR_reverts_bots,col="green4", lty="solid", lwd=1.8)
lines(dates,plotdata\$PR_reverts_reg_users,col="blue", lty="solid", lwd=1.8)
lines(dates,plotdata\$PR_reverts_anon_users,type="l", col="red", lty="solid", lwd=1.8)

legend("topleft",c("Ratio for all edits ", "TOT_G PERC_G " , " ", "for registered edits ", "TOT_R PERC_R ", " ", "for anonymous edits ", "TOT_A PERC_A ", " ", "for bot edits ", "TOT_B PERC_B ", "", "(article edits only)"), lty=1, lwd=2, col=c("black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "red","#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("percentage", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("reverted", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext(paste(format(Sys.time(), " stats.wikimedia.org ")), cex=0.85, line=1.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext(paste(format(Sys.time(), " %Y-%m-%d %H:%M ")), cex=0.85, line=0.5, side=3, adj=1, outer=FALSE, col="#808080")
#text("Script: Erik Zachte. Renderer: R.    Ratio is 'reverting edits/other edits', not 'reverted edits/other edits", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")
mtext("Script: Erik Zachte. Renderer: R.    Ratio is 'reverts per editor class/all edits by editor class'", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")

box()
dev.off()

plotdata <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:22]
counts   <- plotdata[2:21]
dates    <-strptime(as.character(plotdata\$month), "%m/%d/%Y")
dates

times_tot = ts(plotdata\$PR_reverts_total, start=2001, freq=12)
times_tot_decomposed = decompose(times_tot, type="mult")

times_reg = ts(plotdata\$PR_reverts_reg_users, start=2001, freq=12)
times_reg_decomposed = decompose(times_reg, type="mult")

times_anon = ts(plotdata\$PR_reverts_anon_users, start=2001, freq=12)
times_anon_decomposed = decompose(times_anon, type="mult")

times_bots = ts(plotdata\$PR_reverts_bots, start=2001, freq=12)
times_bots_decomposed = decompose(times_bots, type="mult")

plotdata = data.frame(date=dates,counts,times_tot_decomposed\$trend,times_anon_decomposed\$trend,times_reg_decomposed\$trend,times_bots_decomposed\$trend,times_reverts_decomposed\$trend)
attach (plotdata)

#install.packages(c("Cairo"), repos="http://cran.r-project.org" )
 library(Cairo)
 Cairo(width=640, height=480, file="FILE_PNG_TRENDS", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test")
#Cairo(width=600, height=450, file="FILE_PNG", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test") # for blog
#CairoSVG(width=600, height=450, file="FILE_SVG", pointsize=10, bg="#F0F0F0", canvas = "white", dpi = 1000, title="Test")

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))
plot (dates,plotdata\$PR_reverts_total,type="l", col="black", lty="solid", lwd=1, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i", ylim=YLIM)

axis(2, at=10*c(0:10),labels=10*c(0:10), col.axis="black", las=2, tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="month"), format="\b", tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="year"), format="%b %y ", tck=1, col="#909090", mar=c(4,3,2.5,1))

title(" TITLE ",  cex.main=2,   font.main=3, col.main= "black")

lines(dates,plotdata\$times_tot_decomposed\.trend,type="l", col="black", lty="solid", lwd=3)
lines(dates,plotdata\$times_anon_decomposed\.trend,type="l", col="red", lty="solid", lwd=3)
lines(dates,plotdata\$times_reg_decomposed\.trend,type="l", col="blue", lty="solid", lwd=3)
lines(dates,plotdata\$times_bots_decomposed\.trend,type="l", col="green4", lty="solid", lwd=3)

lines(dates,plotdata\$PR_reverts_total,col="black", lty="solid", lwd=0.8)
lines(dates,plotdata\$PR_reverts_bots,col="green4", lty="solid", lwd=0.8)
lines(dates,plotdata\$PR_reverts_reg_users,col="blue", lty="solid", lwd=0.8)
lines(dates,plotdata\$PR_reverts_anon_users,type="l", col="red", lty="solid", lwd=0.8)

legend("topleft",c("Ratio for all edits ", "TOT_G PERC_G " , " ", "for registered edits ", "TOT_R PERC_R ", " ", "for anonymous edits ", "TOT_A PERC_A ", " ", "for bot edits ", "TOT_B PERC_B ", "", "(article edits only)"), lty=1, lwd=2, col=c("black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "red","#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("percentage", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("reverted", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext(paste(format(Sys.time(), " stats.wikimedia.org ")), cex=0.85, line=1.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext(paste(format(Sys.time(), " %Y-%m-%d %H:%M ")), cex=0.85, line=0.5, side=3, adj=1, outer=FALSE, col="#808080")
#mtext("Script: Erik Zachte. Renderer: R.    Ratio is 'reverting edits/other edits', not 'reverted edits/other edits", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")
mtext("Script: Erik Zachte. Renderer: R.    Ratio is 'reverts per editor class/all edits by editor class'", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")

box()
dev.off()

__SCRIPT_EDIT_PLOT_REVERTS__

#----------------------------------------------------------

# PA = Plot Anons
$out_script_plot_anons = <<__SCRIPT_EDIT_PLOT_ANONS__ ;
$out_script_multititle

plotdata  <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:26]
counts    <- plotdata[2:25]
dates     <-strptime(as.character(plotdata\$month), "%m/%d/%Y")
plotdata = data.frame(date=dates,counts)
attach (plotdata)

#install.packages(c("Cairo"), repos="http://cran.r-project.org" )
 library(Cairo)
 Cairo(width=640, height=480, file="FILE_PNG_RAW", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test")
#Cairo(width=600, height=450, file="FILE_PNG", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test") # for blog
#CairoSVG(width=600, height=450, file="FILE_SVG", pointsize=10, bg="#F0F0F0", canvas = "white", dpi = 1000, title="Test")

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))
plot (dates,plotdata\$PA_edits_anon_users,type="l", col="white", lty="solid", lwd=2, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i")

axis(2, at=10*c(0:10),labels=10*c(0:10), col.axis="black", las=2, tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="month"), format="\b", tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="year"), format="%b %y ", tck=1, col="#909090", mar=c(4,3,2.5,1))

title(" TITLE ",  cex.main=2,   font.main=3, col.main= "black")

lines(dates,plotdata\$PA_edits_anon_users_kept,type="l", col="black", lty="solid", lwd=1.8)
lines(dates,plotdata\$PA_edits_anon_users,type="l", col="red", lty="solid", lwd=1.8)
lines(dates,plotdata\$PA_reverts_by_reg_users,type="l", col="blue", lty="solid", lwd=1.8)
lines(dates,plotdata\$PA_reverts_by_anon_users,type="l", col="darkred", lty="solid", lwd=1.8)
lines(dates,plotdata\$PA_reverts_by_bots,type="l", col="green", lty="solid", lwd=1.8)

legend("topleft",c("All anonymous edits ", "TOT_AT PERC_AT " , " ", "Not reverted ", "TOT_AM PERC_AM", " ","Reverted by reg user ","TOT_RR PERC_RR ", " ", "Reverted by anon user ", "TOT_RA PERC_RA ",  " ", "Reverted by bot ", "TOT_RB PERC_RB ","", "(article edits only)"), lty=1, lwd=2,col=c("red","#E0E0E0", "#E0E0E0", "black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "darkred", "#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("100 = max anon edits in ", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("MAX_MONTH: EDITS ", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext(paste(format(Sys.time(), " stats.wikimedia.org ")), cex=0.85, line=1.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext(paste(format(Sys.time(), " %Y-%m-%d %H:%M ")), cex=0.85, line=0.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext("Script: Erik Zachte. Renderer: R", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")

box()
dev.off()


plotdata  <- read.csv(file="FILE_CSV",head=TRUE,sep=",")[2:26]
counts    <- plotdata[2:25]
dates     <-strptime(as.character(plotdata\$month), "%m/%d/%Y")

times_anon = ts(plotdata\$PA_edits_anon_users, start=2001, freq=12)
times_anon_decomposed = decompose(times_anon, type="mult")

times_anon_kept = ts(plotdata\$PA_edits_anon_users_kept, start=2001, freq=12)
times_anon_kept_decomposed = decompose(times_anon_kept, type="mult")

times_reg = ts(plotdata\$PA_reverts_by_reg_users, start=2001, freq=12)
times_reg_decomposed = decompose(times_reg, type="mult")

times_anon_revert = ts(plotdata\$PA_reverts_by_anon_users, start=2001, freq=12)
times_anon_revert_decomposed = decompose(times_anon_revert, type="mult")

#times_bot_revert = ts(plotdata\$PA_reverts_by_bots, start=2001, freq=12)
#times_bot_revert_decomposed = decompose(times_bot_revert, type="mult")

#plotdata = data.frame(date=dates,counts,times_anon_decomposed\$trend,times_anon_kept_decomposed\$trend,times_reg_decomposed\$trend,times_anon_revert_decomposed\$trend,times_bot_revert_decomposed\$trend)
plotdata = data.frame(date=dates,counts,times_anon_decomposed\$trend,times_anon_kept_decomposed\$trend,times_reg_decomposed\$trend,times_anon_revert_decomposed\$trend)

attach (plotdata)

#install.packages(c("Cairo"), repos="http://cran.r-project.org" )
 library(Cairo)
 Cairo(width=640, height=480, file="FILE_PNG_TRENDS", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test")
#Cairo(width=600, height=450, file="FILE_PNG", type="png", pointsize=10, bg="#F0F0F0", canvas = "white", units = "px", dpi = "auto", title="Test") # for blog
#CairoSVG(width=600, height=450, file="FILE_SVG", pointsize=10, bg="#F0F0F0", canvas = "white", dpi = 1000, title="Test")

r <- as.POSIXct(round(range(dates), "days"))

par(mar=c(2.5,3,2.5,1.5))
par(oma=c(0,0,0,0))
plot (dates,plotdata\$PA_edits_anon_users,type="l", col="white", lty="solid", lwd=2, tck=1, xlab="", ylab="", xaxt="n", yaxt="n", las=2, bty="o", xaxs = "i", yaxs = "i")

axis(2, at=10*c(0:10),labels=10*c(0:10), col.axis="black", las=2, tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="month"), format="\b", tck=1, col="#D0D0D0")
axis.POSIXct(1, at=seq(r[1], r[2], by="year"), format="%b %y ", tck=1, col="#909090", mar=c(4,3,2.5,1))

title(" TITLE ",  cex.main=2,   font.main=3, col.main= "black")

lines(dates,plotdata\$times_anon_kept_decomposed\.trend,type="l", col="black", lty="solid", lwd=3)
lines(dates,plotdata\$times_anon_decomposed\.trend,type="l", col="red", lty="solid", lwd=3)
lines(dates,plotdata\$times_reg_decomposed\.trend,type="l", col="blue", lty="solid", lwd=3)
lines(dates,plotdata\$times_bot_revert_decomposed\.trend,type="l", col="green", lty="solid", lwd=3)
#lines(dates,plotdata\$times_anon_revert_decomposed\.trend,type="l", col="darkred", lty="solid", lwd=3)

lines(dates,plotdata\$PA_edits_anon_users_kept,type="l", col="black", lty="solid", lwd=0.8)
lines(dates,plotdata\$PA_edits_anon_users,type="l", col="red", lty="solid", lwd=0.8)
lines(dates,plotdata\$PA_reverts_by_reg_users,type="l", col="blue", lty="solid", lwd=0.8)
lines(dates,plotdata\$PA_reverts_by_bots,type="l", col="green", lty="solid", lwd=0.8)
#lines(dates,plotdata\$PA_reverts_by_anon_users,type="l", col="darkred", lty="solid", lwd=0.8)

legend("topleft",c("All anonymous edits ", "TOT_AT PERC_AT " , " ", "Not reverted ", "TOT_AM PERC_AM", " ","Reverted by reg user ","TOT_RR PERC_RR ", " ", "Reverted by anon user ", "TOT_RA PERC_RA ",  " ", "Reverted by bot ", "TOT_RB PERC_RB ","", "(article edits only)"), lty=1, lwd=2,col=c("red","#E0E0E0", "#E0E0E0", "black","#E0E0E0", "#E0E0E0", "blue","#E0E0E0", "#E0E0E0", "darkred", "#E0E0E0", "#E0E0E0", "green4", "#E0E0E0", "#E0E0E0", "#E0E0E0"), inset=0.05, bg="#E0E0E0")

mtext("100 = max anon edits in ", cex=0.85, line=1.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext("MAX_MONTH: EDITS ", cex=0.85, line=0.5, side=3, adj=0, outer=FALSE, col="#000000")
mtext(paste(format(Sys.time(), " stats.wikimedia.org ")), cex=0.85, line=1.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext(paste(format(Sys.time(), " %Y-%m-%d %H:%M ")), cex=0.85, line=0.5, side=3, adj=1, outer=FALSE, col="#808080")
mtext("Script: Erik Zachte. Renderer: R", cex=0.85, line=0.2, side=4, adj=0, outer=FALSE, col="#999999")

box()
dev.off()

__SCRIPT_EDIT_PLOT_ANONS__


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
\$('#table2').tablesorter({
  // debug:true,
  headers:{0:{sorter:false},1:{sorter:false},2:{sorter:'nohtml'},3:{sorter:'nohtml'},4:{sorter:'nohtml'},5:{sorter:false},6:{sorter:'millions'},7:{sorter:'digitsonly'},8:{sorter:'digitsonly'},9:{sorter:'digitsonly'},10:{sorter:false}}
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
td.l {text-align:left;}
td.lwrap {white-space:normal; text-align:left; padding-left:2px; padding-right:2px; padding-top:1px;padding-bottom:0px}

td.cb    {text-align:center; border: inset 1px #FFFFFF}
td.lb    {text-align:left;   border: inset 1px #FFFFFF}
td.rb    {text-align:right;  border: inset 1px #FFFFFF}
td.sigma {color:#400040;     border: inset 1px #FFFFFF}
td.img   {padding:0px ; margin:0px ; border: inset 1px #FFFFFF}


table.b td    {text-align:right;  border: inset 1px #FFFFFF}
table.b th    {text-align:center; border: none}
table.b th.l  {text-align:left;   border: none ; vertical-align:top;}
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

#------------------------------------------------------------------------

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

}

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
