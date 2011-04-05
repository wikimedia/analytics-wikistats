#!/usr/bin/perl
# Copyright (C) 2003-2008 Erik Zachte , email ezachte a-t wikimedia d-o-t org
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, at
# http://www.fsf.org/licenses/gpl.html                                                                                         =

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (14) ;

# build argument list for test run in OptiPerl IDE (Erik's home test env)
# arguments are parsed in WikiReportsInput:ParseArguments
  if (! $job_runs_on_production_server)
  {
    # push @arguments, '-a' ;       # generate input files (.js) for animations, see e.g.
                                    # http://stats.wikimedia.org/wikimedia/animations/growth/AnimationProjectsGrowthWp.html
                                    # mutually exclusive with other reporting

    # push @arguments, '-v m' ;     # generate tables with pageviews per wiki: mobile sites
                                    # e.g. http://stats.wikimedia.org/EN/TablesPageViewsMonthly.htm
                                    # mutually exclusive with other reporting
    # push @arguments, '-v n' ;     # generate tables with pageviews per wiki: non-mobile traffic
                                    # e.g. http://stats.wikimedia.org/EN/TablesPageViewsMonthlyMobile.htm
                                    # mutually exclusive with other reporting
    # push @arguments, '-v c' ;     # generate tables with pageviews per wiki: mobile + non-mobile traffic
                                    # e.g. http://stats.wikimedia.org/EN/TablesPageViewsMonthlyCombined.htm
                                    # mutually exclusive with other reporting
    # push @arguments, '-n' ;       # normalize monthly page view data (see -v) to 30 days for each month

    # push @arguments, '-G' ;       # generate .html and .bat (DOS batch) files to get screen shots of all Wikimedia main pages, using url2bmp.exe (Windows only)
                                    # mutually exclusive with other reporting

    # push @arguments, '-c' ;       # generate category trees
                                    # mutually exclusive with other reporting

      push @arguments, '-r india' ; # only one region per run, no region specified -> all languages
    # push @arguments, '-r africa' ;
    # push @arguments, '-r america' ;
    # push @arguments, '-r asia' ;
    # push @arguments, '-r europe' ;
    # push @arguments, '-r oceania' ;
    # push @arguments, '-r articifial' ;

    $mode = 'wp' ;                  # specify wp=wikipedia (default), wb=wikibooks, wk=wiktionary, wn=wikinews, wq=wikiquote, ws=wikisource, wv=wikiversity, wx=wikispecial
    $mode =~ s/\s//g ;
    push @arguments, "-m $mode" ;

       if ($mode eq 'wb') { $folder = 'wikibooks' ; }
    elsif ($mode eq 'wk') { $folder = 'wiktionary' ; }
    elsif ($mode eq 'wn') { $folder = 'wikinews' ; }
    elsif ($mode eq 'wp') { ; }
    elsif ($mode eq 'wq') { $folder = 'wikiquote' ; }
    elsif ($mode eq 'ws') { $folder = 'wikisource' ; }
    elsif ($mode eq 'wv') { $folder = 'wikiversity' ; }
    elsif ($mode eq 'wx') { $folder = 'wikispecial' ; }

    push @arguments, '-l en' ;    # output language (ISO codes), see WikiReportsLiterals for acceptable codes

    push @arguments, "-i 'W:\\# Out Bayes\\csv_$mode'" ;           # input directory: csv files
    if (join ('|', @arguments) =~ /-a/)
    { push @arguments, "-o 'W:\\\@ Main Page Gallery'" ; }         # output directory: batch files for capturing all Wikimedia main pages
    else
    { push @arguments, "-o 'W:\\# Out Test\\htdocs\\$folder'" ; }  # output directory: html files, image files (plots)

    push @arguments, '-g' ; # convert generated gif (Ploticus) nconvert.exe, on Windows platform only

    push @arguments, '-t' ; # test mode

    # push @arguments, '-p [some path]' ; # path to Ploticus exe
    # push @arguments, '-s wikimedia' ; # site for which stats are run
  }

  default_argv (join ("\|", @arguments)) ;

# to do
# change: figures for first months are too low -> figures for early 2001
# and remove this notice at all on project pages that start to report from 2002 or later

  use WikiReportsConversions ;
  use WikiReportsDate ;
  use WikiReportsHtml ;
  use WikiReportsInput ;
  use WikiReportsLiterals ;
  use WikiReportsLocalizations ;
  use WikiReportsNoWikimedia ;
  use WikiReportsOutputAnimations ;
  use WikiReportsOutputCategories ;
  use WikiReportsOutputCharts ;
  use WikiReportsOutputEditHistory ;
  use WikiReportsOutputMisc ;
  use WikiReportsOutputPageViews ;
  use WikiReportsOutputPlots ;
  use WikiReportsOutputSummaries ;
  use WikiReportsOutputTables ;
  use WikiReportsOutputTimelines ;
  use WikiReportsOutputWikibooks ;
  use WikiReportsProcessReverts ;
  use WikiReportsScripts ;

  no warnings 'uninitialized';

  $version   = "2.6" ; # versioning has not been maintained consistently
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
    exit ;
  }

  &SetScripts ;

  if ($pageviews)
  {
    &LogT ("\nRead Monthly Statistics") ;
    &ReadMonthlyStats ;
    &LogT ("\nWrite Page Views Totals Report\n") ;
    &WritePageViewsMonthly ;
    &WriteMonthlyStatsHtmlAllProjects ;
    &GenerateComparisonTablePageviewsAllProjects ($true) ;  # normalized
    &GenerateComparisonTablePageviewsAllProjects ($false) ; # not normalized
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

  if ($dump_gallery)
  {
    # generate .html and .bat (DOS batch) files to get screen shots of all Wikipedia main pages
    # reduced to 40% using url2bmp.exe
    &GenerateGallery ;
    exit ;
  }

  &LogT ("\nGenerate Current Status") ;
  if (! $singlewiki)
  { &GenerateCurrentStatus ; }

  &LogT ("\nGenerate Site Map") ;
  if ($showplots)
  { &GenerateSiteMapNew ; }
  else
  { &GenerateSiteMap ; }

  if ($mode_wp && ($language eq "en"))
  {
    &LogT ("\nGenerate Summaries Per Wiki") ;
    &GenerateSummariesPerWiki ;
  }

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

  if ((! $mode_wp) || ($region eq ''))
  {
    &LogT ("\nGenerate Wiki Specific Tables") ;
    &GenerateWikiSpecificTables ;
    if ($mode_wp)
    { &GenerateTablesPerWiki ("zzz") ; }

    &LogT ("\nGenerate Wikipedia Specific Charts" ) ;
    foreach $wp (@languages)
    { &GenerateChartsPerWikipedia ($wp) ; }
    if ($mode_wp)
    { &GenerateChartsPerWikipedia ("zzz") ; }
  }

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
