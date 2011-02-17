#!/usr/bin/perl
# Copyright (C) 2003-2010 Erik Zachte , email erikzachte\@xxx.com (nospam: xxx=infodisiac)
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, at
# http://www.fsf.org/licenses/gpl.html

# Disclaimer: most of these sources have been developed in limited free time.  
# Over the years complexity of the sources grew, sometimes at the expense of maintainability.
# Some design decisions have not scaled well.
# Some parts of the code are hard to read due to overly concise or obscure variable names
# (WikiCounts.. files suffer less from this than WikiReports.. files).
# although in general I try to choose descriptive variable and function names.
# There is little documentation, too few comments in the code. 
# Sometimes obsolete code has been commented out rather than deleted to ease re-activation.
# Some code contains hard coded file paths mainly to Erik's test environment (Windows)

# On the bright side: 
# Most code produces a decent audit trail, which can help understand process flow. 
# Great care has been taken to produce output that is tuned to each specific project. 

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (11) ;

# set defaults mainly for tests on local machine
# default_argv "-a|-m wk|-l en|-i 'D:\@Wikimedia\\# Out Bayes\\csv_wk'|-o 'D:\@Wikimedia\\# Out Test\\htdocs2'" ;
# default_argv "-g|-t|-m wp|-l en|-i 'D:\@Wikimedia\\# Out Bayes\\csv_wp'|-o 'D:\@Wikimedia\\# Out Test\\htdocs\\'" ;
# default_argv "-t|-m wx|-l en|-i 'D:\@Wikimedia\\# Out Bayes\\csv_wx'|-o 'D:\@Wikimedia\\# Out Test\\htdocs\\wikispecial'" ;
# default_argv "-v m|-n|-g|-t|-m wp|-l en|-i 'D:\@Wikimedia\\# Out Bayes\\csv_wp'|-o 'D:\@Wikimedia\\# Out Test\\htdocs'" ; # for page views
#  default_argv "-r africa|-g|-t|-m wp|-l en|-i 'D:\@Wikimedia\\# Out Bayes\\csv_wp'|-o 'D:\@Wikimedia\\# Out Test\\htdocs'" ;
# default_argv "-g|-t|-m wp|-l en|-i 'D:\@Wikimedia\\# Out Bayes\\csv_wp'|-o 'D:\@Wikimedia\\# Out Test\\htdocs'" ;
 default_argv "-v m|-r africa|-n|-g|-t|-m wp|-l en|-i 'D:\@Wikimedia\\# Out Bayes\\csv_wp'|-o 'D:\@Wikimedia\\# Out Test\\htdocs'" ;

# to do
# change: figures for first months are too low -> figures for early 2001

# and remove this notice at all on project pages that start to report from 2002 or later


  # use Statistics:LineFit ;
  # use warnings ;
  # use strict 'vars' ;

  use WikiReportsInput ;
  use WikiReportsOutputTables ;
  use WikiReportsOutputCharts ;
  use WikiReportsOutputPlots ;
  use WikiReportsOutputMisc ;

  use WikiReportsOutputAnimations ;
  use WikiReportsOutputCategories ;
  use WikiReportsOutputTimelines ;
  use WikiReportsOutputWikibooks ;
  use WikiReportsOutputPageViews ;
  use WikiReportsProcessReverts ;
  use WikiReportsOutputEditHistory ;

  use WikiReportsScripts ;
  use WikiReportsDate ;
  use WikiReportsHtml ;
  use WikiReportsConversions ;
  use WikiReportsLocalizations ;
  use WikiReportsLiterals ;
  use WikiReportsNoWikimedia ;

  no warnings 'uninitialized';

  $version   = "2.5" ;
  $timestart = time ;
  $Kb        = 1024 ;
  $Mb        = $Kb * $Kb ;
  $Gb        = $Kb * $Kb * $Kb ;
  $showplots = $true ;
  $javascript = $false ;

  $out_myname = "Erik Zachte" ;
  $out_mymail = "ezachte@### (no spam: ### = wikimedia.org)" ;
  $out_mysite = "http://infodisiac.com/" ;
  $out_pageviewlogs = "http://dammit.lt/wikistats/" ;

  $crossref = "ast,bg,br,ca,cs,da,de,en,eo,es,fr,he,hu,id,it,ja,nl,nn,pl,pt,ro,ru,sk,sl,sr,sv,wa,zh" ;
  $languages_force_case_uc = "ast|br|de|en|id|nl|wa" ;


  &SetLanguageInfo ;

  &ParseArguments ;

  open "FILE_LOG", ">>", $file_log || abort ("Log file '$file_log' could not be opened.") ;
  &Log ("\n===== WikiReports / " . &GetDateTime(time) . " / Project R:" . uc ($mode). ":" . uc ($language) . " =====\n\n") ;
  &SpoolPreviousErrors ;
  open (STDERR, ">>", $file_errors) ;

  &LogArguments ;

  &InitGlobals ;

  &DetectWikiMedia ;
# $wikimedia = $false ; # for test only

  &SetLiterals ;

  &UpdateLanguageTranslations ;

  if ($animation)
  {
    &ReadDumpDateAndForecastFactors ;
    &LogT ("\nRead Monthly Statistics") ;
    &ReadMonthlyStats ;
    &LogT ("\nGenerate Animation Input") ;
    &GenerateAnimationsInputProjectsGrowth ;
    &GenerateAnimationsInputSizeAndCommunity ;
    &LogT ("Ready\n") ;
    close "FILE_LOG" ;
  }

  &SetScripts ;

  if ($pageviews)
  {
    &LogT ("\nRead Monthly Statistics") ;
    &ReadMonthlyStats ;
    &LogT ("\nWrite Page Views Totals Report") ;
    &WritePageViewsMonthly ;
    &WriteMonthlyStatsHtmlAllProjects ;
    &GenerateComparisonTablePageviewsAllProjects ('non-mobile,normalized') ;
    &GenerateComparisonTablePageviewsAllProjects ('non-mobile,not-normalized') ;
    &LogT ("\n\nExecution took " . ddhhmmss (time - $timestart). ".\n") ;
    &LogT ("Ready\n") ;
    close "FILE_LOG" ;
    exit ;
  }

  if (! $wikimedia)
  { &SettingsNoWikimedia ; }

  &SetConversionTables ;

  &ReadLanguageNames ;
  &GetTranslateWikiData ;

  &ReadDumpDateAndForecastFactors ;

  &LogT ("\nRead Bot Statistics") ;
  &ReadBotStats ;

  &LogT ("\nRead Monthly Statistics") ;
  &ReadMonthlyStats ;

#&GenerateTableZeitGeist ('commons') ;
# generate .html and .bat (DOS batch) files to get screen shots of all Wikipedia main pages
# reduced to 40% using url2bmp.exe
#  &GenerateSiteMap ;
# &GenerateGallery ;
# exit ;

  &LogT ("\nGenerate Current Status") ;
  if (! $singlewiki)
  { &GenerateCurrentStatus ; }

  &LogT ("\nGenerate Site Map") ;
  if ($showplots)
  { &GenerateSiteMapNew ; }
  else
  { &GenerateSiteMap ; }

# &GenerateTablesPerWiki ("zz") ;
# &GenerateComparisonTables ;

#  if ($language eq "en")
#  {
#    &GenerateYearlyGrowthStats ;
#  # &TestCompleted ;
#    &ReadEditHistory ;
#    &ReadRevertHistoryGenerateReports ;
#    &GenerateEditHistoryReports ; # wait till R runs on bayes
#  }

# &GenerateTablesPerWikipedia ("zzz") ;
# &TestCompleted ;

  &LogT ("\nGenerate Growth Summary") ;
  &GenerateGrowthSummary ;

  &LogT ("\nGenerate Bots Summary") ;
  &GenerateBotSummary ;

  if ($categorytrees)
  {
    &LogT ("\nGenerate Category Reports") ;
    &GenerateCategoryReports ;
    if ($wikimedia)
    { exit ; }
  }

  if ($mode_wp && ($language eq "en"))
  {
    &LogT ("\nGenerate Timeline Pages") ;
    &GenerateTimelinePages ;
    &MoveTimelinePages ;
  }

  if (($mode_wb || $mode_wv) && ($language eq "en"))
  {
    &LogT ("\nGenerate Wikibooks Pages") ;
    &GenerateWikibookReports ;
  }

  &LogT ("\nGenerate Comparison Tables") ;
  &GenerateComparisonTables ;

# $showplots = $false ; # for test only

  if ($showplots)
  {
    &LogT ("\nGenerate Plot Data Files") ;
    &GeneratePlotDataFiles ;

    # &Log ("\nTest Ploticus output capabilities") ;
    # &PloticusDummyRun ;
    &LogT ("\nGenerate Plots") ;
    &GeneratePlotFiles ;
  }

  &LogT ("\nGenerate Wiki Specific Tables") ;
  &GenerateWikiSpecificTables ;
  if ($mode_wp)
  { &GenerateTablesPerWiki ("zzz") ; }

  &LogT ("\nGenerate Wikipedia Specific Charts") ;
  foreach $wp (@languages)
  { &GenerateChartsPerWikipedia ($wp) ; }
  if ($mode_wp)
  { &GenerateChartsPerWikipedia ("zzz") ; }

# &GenerateChartsPerWikipedia ("zz") ;
# &GenerateChartsPerWikipedia ("en") ;

  &LogT ("\nGenerate Trends Report") ;
  &GenerateConsolidatedTablePlusCharts ;

  &LogT ("\nCollect File Timestamps\n") ;
  &CollectFileTimeStamps ;

  &LogT ("\n\nExecution took " . ddhhmmss (time - $timestart). ".\n") ;
  &LogT ("Ready\n") ;
  close "FILE_LOG" ;

  &SignalPublishingToDo ;
  exit ;

sub TestCompleted
{
  return if ! $testmode ;

  &LogT ("\n\nTest completed.") ;
  &LogT ("\n\nExecution took " . ddhhmmss (time - $timestart). ".\n") ;
  &LogT ("Ready\n") ;
  exit ;
}

1;
