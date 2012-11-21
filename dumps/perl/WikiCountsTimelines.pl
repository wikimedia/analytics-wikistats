#!/usr/bin/perl
# Copyright (C) 2003-2012 Erik Zachte , email erikzachte\@xxx.com (nospam: xxx=infodisiac)
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details, at
# http://www.fsf.org/licenses/gpl.html

# WikiCountTimelines collects all timeline scripts for all regular Wikimedia projects
# Normally this is refreshed via Wikistats job WikiCounts.pl, one project/language at a time

  use WikiCountsTimelines ;

  $true  = 1 ;
  $false = 0 ;

# server paths
  $path_wikistats = -d '/a/wikistats_git' ? '/a/wikistats_git' : '/a/wikistats' ;
  
  $path_dblist = "$path_wikistats/dumps/dblists/" ;
  $path_csv    = "$path_wikistats/dumps/csv/" ;
  $path_dumps  = "/mnt/data/xmldatadumps/public/" ;

  $file_csv_content_namespaces_all = $path_csv . "csv_mw/StatisticsContentNamespaces.csv" ;

  unlink $file_csv_content_namespaces_all ;
  open CSV_OUT, '>>', $file_csv_content_namespaces_all ;
  print CSV_OUT "project code,language code,content namespaces\n" ;

  $wikis = 0 ;

  &GetContentTimelinesPerProject ($path_dumps, 'wb', 'wikibooks.dblist') ;
  &GetContentTimelinesPerProject ($path_dumps, 'wk', 'wiktionary.dblist') ;
  &GetContentTimelinesPerProject ($path_dumps, 'wn', 'wikinews.dblist') ;
  &GetContentTimelinesPerProject ($path_dumps, 'wp', 'wikipedia.dblist') ;
  &GetContentTimelinesPerProject ($path_dumps, 'wq', 'wikiquote.dblist') ;
  &GetContentTimelinesPerProject ($path_dumps, 'ws', 'wikisource.dblist') ;
  &GetContentTimelinesPerProject ($path_dumps, 'wv', 'wikiversity.dblist') ;
  &GetContentTimelinesPerProject ($path_dumps, 'wx', 'special.dblist') ;

  close CSV_OUT ;
  print "\nReady\n\n" ;

sub GetContentTimelinesPerProject
{
  my ($path_dumps,$project,$dbfile) = @_ ;

  $dbfile = $path_dblist . $dbfile ;

  print "\nRead dblist '$dbfile'\n" ;

  die "'path $dbfile not found'" if ! -e $dbfile ;

  print "\nCollect timelines for project $project wiki $dbfile\n\n" ;

  open DBFILE, '<', $dbfile ;
  while ($line = <DBFILE>)
  {
    chomp $line ;
    $language = $line ;
    $wiki     = $line ;
    next if $language !~ /wik/ ;
    print ++$wikis . ": $language\n" ;
    $language =~ s/wik.*$// ;
    $language =~ s/_/-/g ;
    $dump = "$path_dumps/$wiki" ;

    if (! -e $dump)
    {
      $timelines_dumps_found ++ ;
      $timelines_dumps_not_found ++ ;
      next ;
    }

    &CollectTimelinesFromDump ($project, $language, $dump) ;
  }
  close DBFILE ;

  open CSV_IN,  '<', $file_csv_content_namespaces ;
  while ($line = <CSV_IN>)
  {
    chomp $line ;
    print CSV_OUT "$project,$line\n" ;
  }
  close CSV_IN ;
}


# use Encode qw(encode);
# $eckey=encode('utf8',$key);
sub LogT
{
  print shift ;
}



