#! /usr/bin/perl

# Q&D script: absolute paths
# $file_csv_content_namespaces = "w:/# out stat1/csv_mw/StatisticsContentNamespaces.csv" ;
  $file_csv_content_namespaces = "/a/wikistats_git/dumps/csv/csv_mw/StatisticsContentNamespaces.csv" ;
# $dir_csv_in = "w:/# out stat1/csv_wp" ;
  $dir_csv_in = "/a/wikistats_git/dumps/csv/csv_wp" ;
  $mode = 'wp' ; # Wikipedia ;

  &GetContentNamespaces ($file_csv_content_namespaces) ;

  @files = &CollectFilenames ($dir_csv_in) ;

  foreach $file (@files)
  { &ParseFile ($file) ; }

  &SortLanguages ;
  &WriteReport  ('CreatesByMonth.csv') ; ;
  &WriteReport2 ('CreatesByMonthAlt.csv') ; ;

  print "\n\nReady\n\n" ;
  exit ;

  $| = 1; # flush screen output

sub CollectFilenames
{
  my ($path) = @_ ;

  my $files = 0 ;
  chdir $path ;
  my @folder_entries = <*> ;
  foreach $file (@folder_entries)
  {
    next if -d $file ;
    next if $file !~ /^Creates/ ;
    ($file2 = $file) =~ s/[A-Z-_]//g ;
    next if $file2 ne 'reates.csv' ;  # e.g. CreatesBinaries
    $files++ ;
    push @files, $file ;
  }
  print "$files files found\n" ;

  return @files ;
}

sub ParseFile
{
  my ($file) = @_ ;

  my $language = $file ;
  $language =~ s/^Creates// ;
  $language =~ s/\..*// ;
  $language = lc ($language) ;

# return if $language ne 'fy' and $language ne 'af' ;

  push @languages, $language ;

  print "\nParseFile $file, language $language\n\n" ;

  open CSV_IN, '<', $file ;
  while ($line = <CSV_IN>)
  {
    next if $line =~ /^#/ ; # comment
    next if $line =~ /^-/ ; # no internal link in page
    next if $line =~ /^R/ ; # redirect

    chomp $line ;
    my ($count_flag,$yyyymmddhhnn,$namespace,$usertype,$user,$title,$uploadwizard) = split (',', $line) ;
    my $yyyymm = substr ($yyyymmddhhnn,0,7) ;

    if (! defined ($content_namespace {$mode} {$language} {$namespace}))
    { $content_namespace {$mode} {$language} {$namespace} = 0 ; }

    if ($content_namespace {$mode} {$language} {$namespace} <= 0)
    {
      if ($content_namespace {$mode} {$language} {$namespace} == 0)
      { print "skip $mode $language $namespace\n" ; }
      $content_namespace {$mode} {$language} {$namespace} -- ;
    }
    else
    {
      if ($content_namespace {$mode} {$language} {$namespace} == 1)
      { print "count $mode $language $namespace\n" ; }
      $content_namespace {$mode} {$language} {$namespace} ++ ;
    }

#    next if $namespace != 0 ; # Q&D approximation, some wikis have 'content' in other namespaces

    @yyyymm {$yyyymm} ++ ;
    $creates_per_lang_per_month_per_usertype {$language} {$yyyymm} {$usertype}  ++ ;
    $tot_creates_per_lang {$language} ++ ;
    $tot_creates_per_lang_per_usertype {$language} {$usertype} ++ ;

  #  print "$yyyymm $usertype\n" ;

  }
  close CSV_IN ;
}

sub SortLanguages
{
  foreach $language (@languages)
  {
    $creates_reg   = (0+$tot_creates_per_lang_per_usertype {$language} {'R'}) ;
    $creates_anon  = (0+$tot_creates_per_lang_per_usertype {$language} {'A'}) ;
    $creates_bot   = (0+$tot_creates_per_lang_per_usertype {$language} {'B'}) ;
    $creates_total {$language} = $creates_reg + $creates_anon + $creates_bot ;
    $creates_perc_bot = 0 ;
    if ($creates_total {$language}> 0)
    { $creates_perc_bot = 100 * $creates_bot / $creates_total {$language} ; }

    $perc_bot_creates_per_language {$language} = $creates_perc_bot ;
  }

  # sort by percentage bot creates for all time
  # @sorted_languages = sort {$perc_bot_creates_per_language {$b} <=> $perc_bot_creates_per_language {$a}} keys %perc_bot_creates_per_language ;

  # sort by total bot creates for all time (~ size of wiki in articles)
  @sorted_languages = sort {$creates_total {$b} <=> $creates_total {$a}} keys %creates_total ;
}

sub WriteReport
{
  my ($file_out) = @_ ;
  my $line ;
  my %creates_bot_cumulative ;
  my %creates_total_cumulative ;

  open CSV_OUT, '>', $file_out || die "Could not open '$file_out'" ;

  print CSV_OUT "Wikipedia article creates per month per user type\n" ;
  print CSV_OUT "Source: wikimedia dumps via ..csv_wp/Creates[language code].csv\n\n" ;
  print CSV_OUT "Only namespaces with encyclopedic concern have been counted. Not talk pages or image upload pages or housekeeping pages etc!\n" ;
  print CSV_OUT "Languages are sorted by total article creates for all time ('page count').\n" ;
  print CSV_OUT "For language names corresponding to language codes, please see http://stats.wikimedia.org/EN/Sitemap.htm\n\n" ;

  $line = '' ;
  foreach $language (@sorted_languages)
  { $line .= "$language,$language,$language,$language,$language," ; }
  $line =~ s/,$// ;
  print CSV_OUT "Language code,$line\n" ;
# print         "Language code,$line\n" ;

  $line = '' ;
  foreach $language (@sorted_languages)
  { $line .= "Reg user,Anon user,Bot,Total Cum.,Perc Bot," ; }
  $line =~ s/,$// ;
  print CSV_OUT "User type,$line\n" ;
# print         "User type,$line\n" ;

  $line = '' ;
  foreach $language (@sorted_languages)
  {
    $creates_reg   = (0+$tot_creates_per_lang_per_usertype {$language} {'R'}) ;
    $creates_anon  = (0+$tot_creates_per_lang_per_usertype {$language} {'A'}) ;
    $creates_bot   = (0+$tot_creates_per_lang_per_usertype {$language} {'B'}) ;
    $creates_total = $creates_reg + $creates_anon + $creates_bot ;
    $creates_perc_bot = '' ;
    if ($creates_total > 0)
    { $creates_perc_bot = sprintf ("%.1f", 100 * $creates_bot / $creates_total) . '%' ; }
    $line .= "$creates_reg,$creates_anon,$creates_bot,$creates_perc_bot," ;
  }
  $line =~ s/,$// ;
  print CSV_OUT "Total/Perc,$line\n" ;
# print         "Total/Perc,$line\n" ;

  foreach $yyyymm (sort keys %yyyymm)
  {
    $line = '' ;

    foreach $language (@sorted_languages)
    {
      $creates_reg   = (0+$creates_per_lang_per_month_per_usertype {$language} {$yyyymm} {'R'}) ;
      $creates_anon  = (0+$creates_per_lang_per_month_per_usertype {$language} {$yyyymm} {'A'}) ;
      $creates_bot   = (0+$creates_per_lang_per_month_per_usertype {$language} {$yyyymm} {'B'}) ;
      $creates_total = $creates_reg + $creates_anon + $creates_bot ;

      $creates_bot_cumulative   {$language} += $creates_bot ;
      $creates_total_cumulative {$language} += $creates_total ;

      $creates_perc_bot = 'n.a.' ;
      if ($creates_total_cumulative {$language} > 0)
      { $creates_perc_bot = sprintf ("%.1f", 100 * $creates_bot_cumulative   {$language} / $creates_total_cumulative {$language}) . '%' ; }

      $line .= "$creates_reg,$creates_anon,$creates_bot," . $creates_total_cumulative {$language}. ",$creates_perc_bot," ;
    }

    $line =~ s/,$// ;
    print CSV_OUT "$yyyymm,$line\n" ;
  # print         "$yyyymm,$line\n" ;
  }

  close CSV_OUT ;
}

sub WriteReport2
{
  my ($file_out) = @_ ;
  my $line ;
  my %creates_bot_cumulative ;
  my %creates_total_cumulative ;

  open CSV_OUT, '>', $file_out || die "Could not open '$file_out'" ;

  print CSV_OUT "Wikipedia article creates per month per user type\n" ;
  print CSV_OUT "Source: wikimedia dumps via ..csv_wp/Creates[language code].csv\n\n" ;
  print CSV_OUT "Only namespaces with encyclopedic concern have been counted. Not talk pages or image upload pages or housekeeping pages etc!\n" ;
  print CSV_OUT "Languages are sorted by total article creates for all time ('page count').\n" ;
  print CSV_OUT "For language names corresponding to language codes, please see http://stats.wikimedia.org/EN/Sitemap.htm\n\n" ;

  $line = '' ;
  foreach $language (@sorted_languages)
  { $line .= "$language," ; }
  $line =~ s/,$// ;

  push @lines_reg,   "Articles created by registered users\nLanguage code,$line\n" ;
  push @lines_anon,  "Articles created by anonymous users\nLanguage code,$line\n" ;
  push @lines_bot,   "Articles created by bots\nLanguage code,$line\n" ;
  push @lines_total, "Total articles created (cumulative for all history)\nLanguage code,$line\n" ;
  push @lines_perc,  "Percentage articles created by bots\nLanguage code,$line\n" ;

  $line_reg = '' ;
  $line_anon = '' ;
  $line_bot = '' ;
  $line_total = '' ;
  $line_perc_bot = '' ;
  foreach $language (@sorted_languages)
  {
    $creates_reg   = (0+$tot_creates_per_lang_per_usertype {$language} {'R'}) ;
    $creates_anon  = (0+$tot_creates_per_lang_per_usertype {$language} {'A'}) ;
    $creates_bot   = (0+$tot_creates_per_lang_per_usertype {$language} {'B'}) ;
    $creates_total = $creates_reg + $creates_anon + $creates_bot ;
    $creates_perc_bot = '' ;
    if ($creates_total > 0)
    { $creates_perc_bot = sprintf ("%.1f", 100 * $creates_bot / $creates_total) . '%' ; }
    $line_reg      .= "$creates_reg," ;
    $line_anon     .= "$creates_anon," ;
    $line_bot      .= "$creates_bot," ;
    $line_total    .= "$creates_total," ;
    $line_perc_bot .= "$creates_perc_bot," ;
  }
  $line_reg      =~ s/,$// ;
  $line_anon     =~ s/,$// ;
  $line_bot      =~ s/,$// ;
  $line_total    =~ s/,$// ;
  $line_perc_bot =~ s/,$// ;
  push @lines_reg,   "Total,$line_reg\n" ;
  push @lines_anon,  "Total,$line_anon\n" ;
  push @lines_bot,   "Total,$line_bot\n" ;
  push @lines_total, "Total,$line_total\n" ;

  foreach $yyyymm (sort keys %yyyymm)
  {
    $line_reg = '' ;
    $line_anon = '' ;
    $line_bot = '' ;
    $line_total = '' ;
    $line_perc_bot = '' ;

    foreach $language (@sorted_languages)
    {
      $creates_reg   = (0+$creates_per_lang_per_month_per_usertype {$language} {$yyyymm} {'R'}) ;
      $creates_anon  = (0+$creates_per_lang_per_month_per_usertype {$language} {$yyyymm} {'A'}) ;
      $creates_bot   = (0+$creates_per_lang_per_month_per_usertype {$language} {$yyyymm} {'B'}) ;
      $creates_total = $creates_reg + $creates_anon + $creates_bot ;

      $creates_bot_cumulative   {$language} += $creates_bot ;
      $creates_total_cumulative {$language} += $creates_total ;

      $creates_perc_bot = 'n.a.' ;
      if ($creates_total_cumulative {$language} > 0)
      { $creates_perc_bot = sprintf ("%.1f", 100 * $creates_bot_cumulative   {$language} / $creates_total_cumulative {$language}) . '%' ; }

      $line_reg      .= "$creates_reg," ;
      $line_anon     .= "$creates_anon," ;
      $line_bot      .= "$creates_bot," ;
      $line_total    .= $creates_total_cumulative {$language} . "," ;
      $line_perc_bot .= "$creates_perc_bot," ;
    }

    $line_reg      =~ s/,$// ;
    $line_anon     =~ s/,$// ;
    $line_bot      =~ s/,$// ;
    $line_total    =~ s/,$// ;
    $line_perc_bot =~ s/,$// ;
    push @lines_reg,   "$yyyymm,$line_reg\n" ;
    push @lines_anon,  "$yyyymm,$line_anon\n" ;
    push @lines_bot,   "$yyyymm,$line_bot\n" ;
    push @lines_total, "$yyyymm,$line_total\n" ;
    push @lines_perc,  "$yyyymm,$line_perc_bot\n" ;
  # print         "$yyyymm,$line\n" ;
  }

  push @lines_reg,   "\n\n" ;
  push @lines_anon,  "\n\n" ;
  push @lines_bot,   "\n\n" ;
  push @lines_total, "\n\n" ;
  push @lines_perc,  "\n\n" ;

  foreach $line (@lines_reg)   { print CSV_OUT $line ; }
  foreach $line (@lines_anon)  { print CSV_OUT $line ; }
  foreach $line (@lines_bot)   { print CSV_OUT $line ; }
  foreach $line (@lines_total) { print CSV_OUT $line ; }
  foreach $line (@lines_perc)  { print CSV_OUT $line ; }


  close CSV_OUT ;
}


sub GetContentNamespaces
{
  my ($file_csv_content_namespaces) = @_ ;

  if (! -e $file_csv_content_namespaces)
  { die ("Namespaces file not found: '$file_csv_content_namespaces'. Run 'collect_countable_namespaces.sh'\n") ; }

  $line_content_namespaces = '' ;
  open FILE_NS, "<", $file_csv_content_namespaces ;
  while ($line = <FILE_NS>)
  {
    chomp $line ;
    my ($mode,$language,$content_namespaces) = split (',', $line) ;
    $language =~ s/-/_/g ; # wikistats (unfortunately) uses codes like 'roa_rup', not 'roa-rup' , to be changed some day
    print "$mode, $language, " ;

    foreach my $id (split '\|', $content_namespaces)
    {
      print "$id, " ;
      $content_namespace {$mode} {$language} {$id} = 1 ;
    }

    print "\n" ;
  }
  close FILE_NS ;
}
