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
# Version numbering has been inconsistent.
# Some code contains hard coded file paths mainly to Erik's test environment (Windows)

# On the bright side:
# Most code produces a decent audit trail, which can help understand process flow.
# The scripts have been modified again and again to cope with ever more colossal input files,
# without overtaxing system resources. (e.g. by externalizing huge memory structures)
# Great care has been taken to produce output that is tuned to each specific project.

# Rudimentary documentations at:
# http://meta.wikimedia.org/wiki/Wikistats
# http://www.mediawiki.org/wiki/Manual:Wikistats/TrafficReports


# to do revert
#   eliminate self reverts
#   separate revert rv from vandal rvv
#   count reverts per user

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;
  ez_lib_version (10) ;

  # set defaults mainly for tests on local machine
# default_argv "-e|-f|-x|-m wk|-t|-l su|-d 20111130|-i 'D:/\@Wikimedia/# In Dumps'|-o 'D:/\@Wikimedia/# Out Test/csv_wk'|-s 'D:/\@Wikimedia/# Out Zwinger/mnt/languages'" ;
#default_argv    "-e|-f|-x|-m wx|-t|-l commons|-d 20120331|-i 'D:/\@Wikimedia/# In Dumps'|-o 'D:/\@Wikimedia/# Out Test/csv_wx'|-s 'D:/\@Wikimedia/# Out Zwinger/mnt/languages'" ;
 default_argv    "-f|-x|-m wp|-t|-l ru|-d 20120831|-i 'D:/\@Wikimedia/# In Dumps'|-o 'D:/\@Wikimedia/# Out Test/csv_wp'|-s 'D:/\@Wikimedia/# Out Zwinger/mnt/languages'" ;
 #default_argv    "-f|-x|-m wp|-t|-l hi|-d 20120430|-i 'D:/\@Wikimedia/# In Dumps'|-o 'D:/\@Wikimedia/# Out Test/csv_wp'|-s 'D:/\@Wikimedia/# Out Zwinger/mnt/languages'" ;

  # used for test only, (arg -t), blank to derive test file from other parms
  $file_in_xml_test = "eowiki-20120904-pages-meta-history.xml" ;
  ($date = $file_in_xml_test) =~ s/[^\d]//g ;
  # used for test only, blank to use normal file name
  $file_csv_monthly_stats_test = "StatisticsMonthly_$date.csv" ;

  $wpx = 'wp';
# default_argv "-i 'D:/\@Wikimedia/# Out Bayes/csv_$wpx'|-o 'D:/\@Wikimedia/# Out Bayes/csv_$wpx'|-y" ;

# todo WikiCountsOutput update UpdateEditsPerArticle, one file per language
#      WikiCountsInput  make 25 language dependent: if ($tot_revisions >= 25)

#END # detect performance breakers in regexps: $1` $' $&
#{
#  use Devel::SawAmpersand ;
## use Devel::FindAmpersand ; # does not work on threaded perl
#  print 'Naughty variable was ' . ((Devel::SawAmpersand::sawampersand)?'':'not ') . 'used;\n' ;
#}

  # use warnings ;
  # use strict ;

  use WikiCountsArguments ;
  use WikiCountsBooks ;
  use WikiCountsBots ;
  use WikiCountsCategories ;
  use WikiCountsConversions ;
  use WikiCountsDate ;
  use WikiCountsInput ;
  use WikiCountsLanguage ;
  use WikiCountsLog ;
  use WikiCountsOutput ;
  use WikiCountsProcess ;
  use WikiCountsTimelines ;
# use WikiCountsWebalizer ;

  $version   = "2.3" ;
  $timestart = time ;
  $bhi       = 127 ;
  $b2hi      = 128*128-1 ;
  $b3hi      = 128*128*128-1 ;
  $b4hi      = 128*128*128*128-1 ;
  $deltaLogC = 20 ;
  $nohashes = "skip" ;
  $log_enabled = $false ;
  $skip_on_dumpdate = $false ;
  
  $base_content_namespaces_on_api = $true ; # use predefined 'content' (=countable) namespaces, or base this on api result ? 

  $weekly_plotdata = $false ;
  if ($weekly_plotdata)
  { $period_significant_digits = 8 ; } # compare dates on day level, only process last edit per article per day
  else
  { $period_significant_digits = 6 ; } # compare dates on month level, only process last edit per article per month

# $forecast_partial_month = $false ; # obsolete ? when counts for current month were shown
                                     # a forecast was added for end of current mont full month  partial momtn in th epast for last siz month for this wiki the rati
                                     # to this end an average ratio for last six motnhs was determined between
                                     # (very) active editors on day x  / (very) active editors for full month

  if ($job_runs_on_production_server)
  {
    $threshold_filesize_large = 1000_000_000 ; # compressed dump size (to do: make this dependant on compression type)
    $threshold_tie_file       = 1000_000_000 ; # compressed dump size (to do: make this dependant on compression type)
    $threshold_edits_only     = 10_000 ;  # edits in namepace 0 on previous run
  #  $threshold_edits_only     = 10_000_000 ;  # edits in namepace 0 on previous run
  #  $threshold_edits_only     = 100_000_000_000 ; # edits in namepace 0 on previous run
  }
  else
  {
    $threshold_filesize_large = 100_000_000 ; # uncompressed dump size
    $threshold_tie_file       = 1000_000_000 ; # uncompressed dump size
    $threshold_edits_only     = 100_000_000_000 ; # edits in namepace 0 on previous run
  }

  $useritem_id = 0 ;
  $useritem_edit_first = 1 ;
  $useritem_edit_last = 2 ;
  $useritem_edit_ip_namespace_a = 3 ;            # anon, article namespace (for most wikis ns 0)
  $useritem_edit_ip_namespace_x = 4 ;            # anon, all other namespaces
  $useritem_edit_reg_namespace_a = 5 ;           # reg user, article namespace
  $useritem_edit_reg_namespace_x = 6 ;           # reg user, all other namespaces
  $useritem_edit_reg_recent_namespace_a = 7 ;    # reg user, article namespace, if in last 30 days
  $useritem_edit_reg_recent_namespace_x = 8 ;    # reg user, other namespace namespace, if in last 30 days
  $useritem_create_reg_namespace_a = 9 ;         # reg user, article namespace
  $useritem_create_reg_namespace_x = 10 ;        # reg user, all other namespaces
  $useritem_create_reg_recent_namespace_a = 11 ; # reg user, article namespace, if in last 30 days
  $useritem_create_reg_recent_namespace_x = 12 ; # reg user, other namespace namespace, if in last 30 days
  $useritem_edits_10 = 13 ;                      # count if user made 10 or more edits

  &ParseArguments ;

  &SetEnvironment ;

  if ($merge_user_edits_one_project) # option -y
  {
    print "\nunlink $path_out/EditsBreakdownPerUserPerMonthAllWikis.csv\n" ;
    unlink "$path_out/EditsBreakdownPerUserPerMonthAllWikis.csv" ;
    &ReadBotNames ;
    &ReadUserNamesWikiLovesMonuments ;  # list of user names who uploaded WLM content in 2010,2011,2012,etc
    &CollectActiveUsersPerMonthsAllWikis ;
    exit ;
  }

  if ($merge_user_edits_all_projects) # option -z
  {
    print "\nunlink $path_out/EditsBreakdownPerUserPerMonthAllProjects.csv\n" ;
    unlink "$path_out/EditsBreakdownPerUserPerMonthAllProjects.csv" ;
    &ReadBotNames ;
    &CollectActiveUsersWikiLovesMonuments ;
    &CollectActiveUsersPerMonthAllProjects ;
    &CountActiveWikisPerMonthAllProjects ;
    exit ;
  }

  &OpenLog ;
  &SpoolPreviousErrors ;
  open (STDERR, ">>", $file_errors) ;

  if (defined ($path_perl))
  { &CheckForNonAscii ; }

  # partial execution for tests only
#  if (! $job_runs_on_production_server)
#  {
#    $language = 'commons' ;
#    &CollectUploaders ;
#    exit ;
#  }

  &TraceMem ;
  if ((! defined ($webalizer_only)) && (! $skip_on_dumpdate))
  {
    &GetContentNamespaces ($mode, $language) ;

    &ReadBots ;
    &UpdateBots ;
    &AssumeBots ;
    &UpdateBotsAll ;

    if (! $testmode)
    {
      if (-e $file_in_sql_usergroups)
      {
        &ReadAccessLevels ;
        &UpdateAccessLevels ;
      }
    }

    &ReadLanguageSettings ;

    &ReadInputXml ;

    if ($reverts_only)
    { 
      &RenameTempCsvFiles ;
      &LogT ("\n\nRevert data collected. Stop further processing.\n\n") ; exit ; 
    }


    if (&TraceJob)
    {
      &LogT ("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n") ;
      my $text = `ls -l $path_temp` ;
      &LogT ("\nll =>\n" . $text) ;
      &LogT ("\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n") ;
    }

    &UpdateNamespaces ;

    if ($length_line_event eq "")
    {
      &UpdateLog ;
      &abort ("No relevant events found") ;
    }

    &SortArticleHistoryOnArticleDateTime ; # for CountArticlesPerFewDays and CountArticlesUpTo
    &CountArticlesPerNamespacePerMonth ; # -> UpdateMonthlyStats
    &CountEditsPerNamespacePerMonth ;    # -> UpdateMonthlyStats
    &CountArticlesPerMonth ;             # -> UpdateMonthlyStats
    &CollectUserStats ;                  # -> UpdateMonthlyStats
    &CollectActiveUsersPerMonth ;        # -> UpdateMonthlyStats
    &UpdateMonthlyStats ;

  # to be replaced: do no longer update weekly stats for Ploticus plots ->
  # to be replaced with (R?) plots based on monthly data
    if ($weekly_plotdata)
    {
      &SortArticleHistoryOnDateTime ;
      &CountUsersPerWeek ;
      &UpdateWeeklyStats ;
    }

    &RankUserStats ;
    &UpdateActiveUsers ;
    &UpdateSleepingUsers ;
    &UpdateBotEdits ;

    &CountBinariesPerExtensionPerMonth ;
    &UpdBinariesStats ;

    &UpdateUsers ; # for $file_csv_user and $file_csv_edit_distribution

    &UpdateSizeDistribution ;
    &UpdateEditsPerArticle ;
    &UpdateReverts ;

  # to be replaced: do no longer update weekly stats for Ploticus plots ->
  # to be replaced with (R?) plots based on monthly data
    if ($weekly_plotdata)
    { &CountArticlesPerFewDays ; }

    &UpdateTimelines ;

    &WriteCategoryInfo ;

    &UpdateZeitGeist ;

    &UpdateLog ;

    &SortAndCompactEditsUserMonth ;

    if ($mode eq "wp")
    { &WriteTimelineOverview ; }

    if (($mode eq "wb") || ($mode eq "wv"))
    { &WriteWikibooksInfo ; }

    if ($mode eq 'wx' and $language eq 'commons')
    { &CollectUploaders ; }

    &RenameTempCsvFiles ;

    &WriteJobRunStats ;
    &UpdateUsersAnonymous ; # last: huge sort

    &SignalReportingToDo ;  # run WikiReports.pl

  # &GetWebalizerPages ; webalizer inactive, no use to fetch new pages
  }

# &CountWebalizerStats ;

# &LogT ("\n\nExecution took " . ddhhmmss (time - $timestart). ".\n") ;
# &LogT ("Ready\n\n") ;
  close "FILE_LOG" ;

  if ($min_run > 1)
  {
    ($min, $hour) = (localtime (time))[1,2] ;
    &LogC ("\n" . sprintf ("%02d", $hour) . ":" . sprintf ("%02d", $min) .
           " Ready in " . ddhhmmss (time - $timestart). "\n") ;
  }
  else
  { &LogC (" -> " . ddhhmmss (time - $timestart). "\n") ; }

  if ($min_run > 1)
  { &WriteDiskStatus ; }

  rmdir $path_temp ; # remove if empty
  if (-d $path_temp)
  {
  # &LogT ("Temp ${path_temp}\@Ready written\n") ;
    open READY, '>', "$path_temp/\@Ready" ;
    print READY "Ready" ;
    close READY ;
  }
  else
  { &LogT ("Temp $path_temp removed\n") ; }

  if ($min_run > 1)
  {
    &Log ("\n************************************\n") ;
    &Log (  "*** Job $job_code_uc completed succesfully ***\n") ; # uc helps search log
    &Log (  "************************************\n") ;
    &Log ('') ; # Q&D do not repeat last log line in exit report
  }
  else
  { &Log ("\n*** Job $job_code completed succesfully ***\n") ; }

  &Log ('') ; # do not repeat last log line in exit routine

  &Beep ;
  exit ;


