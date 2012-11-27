#!/usr/bin/perl

  use lib "/home/ezachte/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;

require "WikiCountsDate.pl" ;
  require "WikiCountsConversions.pl" ;

  $bhi       = 127 ;
  $b2hi      = 128*128-1 ;
  $b3hi      = 128*128*128-1 ;
  $b4hi      = 128*128*128*128-1 ;

  &ParseArguments ;
  &OpenLog ;
  &LogArguments ;
  &ReadInputSql ;

  open "FILE_OUT", ">", "$language.txt" ;

  foreach $key (sort keys %edits)
  {
    print $key . ": " . @edits {$key} . "\n" ;
    print FILE_OUT $key . ": " . @edits {$key} . "\n" ;
  }
  exit ;

sub ParseArguments
{
  my $options ;
  my ($year, $month) , ;
  getopt ("pldioms", \%options) ;

  abort ("Specify input folder for SQL dump files as: -i path") if (! defined (@options {"i"})) ;

  $path_in   = @options {"i"} ;
  $language  = @options {"l"} ;
  $testmode  = defined (@options {"t"}) ; # use input files with language code

  $language_ = $language ;
  $language_ =~ s/-/_/g ;

  if ($path_in =~ /\\/)
  { $path_in  =~ s/[\\]*$/\\/ ; } # make sure there is one trailing (back)slash
  else
  { $path_in  =~ s/[\/]*$/\// ; }

  $file_log                   = $path_out . "WikiCountsLog.txt" ;

  &Log ("Parsing dump file for wiki: " . $language . "\n") ;

  if (! -d $path_in)
  { abort ("Input directory '" . $path_in . "' not found.") ; }

    if ($testmode)
    {
      $file_in_old  = $path_in . "old_table_" .$language_ . ".sql" ;
      $file_in_cur  = $path_in . "cur_table_" .$language_ . ".sql" ;
    }
    else
    {
      $file_in_old  = $path_in . $language_ . "/old_table.sql.gz" ;
      $file_in_cur  = $path_in . $language_ . "/cur_table.sql.gz" ;
      if (! -e $file_in_cur)
      {
        &Log ("\nSql dump file '" . $file_in_cur . "' not found, try old extension: .bz2\n") ;
        $file_in_old  = $path_in . $language_ . "/old_table.sql.bz2" ;
        $file_in_cur  = $path_in . $language_ . "/cur_table.sql.bz2" ;
      }
    }

    if (! -e $file_in_cur)
    { abort ("Sql dump file '" . $file_in_cur . "' not found.") ; }

    if ((! -e $file_in_old) && (! $cur_only))
    {
      $cur_only = $true ;
      &Log ("\nSql dump file '" . $file_in_old . "' not found!\n") ;
    }
}

sub LogArguments
{
  my $arguments ;
  foreach $arg (sort keys %options)
  { $arguments .= " -$arg " . @options {$arg} . "\n" ; }
  &Log ("\nArguments\n$arguments\n") ;
}

sub ReadInputSql {
  $timestart_parse = time ;

  $Kb = 1024 ;
  $Mb = $Kb * $Kb ;

  $first = "\\(" ;        # find start of record = opening brace
  $TEXT  = "'([^']*)'," ; # alphanumeric field (save contents between quotes)
  $text2 = "'[^']*'," ;   # alphanumeric field
  $INT   = "(\\d+)," ;    # integer field (save contents)
  $int2  = "\\d+," ;      # integer field
  $float = "[^,]*," ;     # used for floating point field
  $last  = "[^)]*\\)" ;   # last field and closing brace

  $reg_expr_old = qr"$first$INT$INT$TEXT$TEXT$text2$int2$TEXT$TEXT$int2$TEXT$last" ;
  $reg_expr_cur = qr"$first$INT$INT$TEXT$TEXT$text2$int2$TEXT$TEXT$text2$int2$int2$int2$int2$float$last" ;

  &ReadFileSql ($file_in_cur, $reg_expr_cur, "cur") ;
  &ReadFileSql ($file_in_old, $reg_expr_old, "old") ;

  &Log ("\n\nParsing SQL files took " . ddhhmmss (time - $timestart_parse). ".\n") ;

}

sub ReadFileSql
{
  $file_in  = shift ;
  $reg_expr = shift ;
  $table    = shift ;

  if ($file_in =~ /\.gz$/)
  { open "FILE_IN", "-|", "gzip -dc \"$file_in\"" || abort ("Input file " . $file_in . " could not be opened.") ; }
  elsif ($file_in =~ /\.bz2$/)
  { open "FILE_IN", "-|", "bzip2 -dc \"$file_in\"" || abort ("Input file " . $file_in . " could not be opened.") ; }
  else
  { open "FILE_IN", "<", $file_in || abort ("Input file " . $file_in . " could not be opened.") ; }

  binmode "FILE_IN" ;

  $filesize = -s $file_in ;
  $fileage  = -M $file_in ;

  if ($filesize == 0)
  { abort ("Input file " . $file_in . " is empty.") ; }

  &Log ("\nRead sql dump file \'" . $file_in . "\' (". &i2KbMb ($filesize) . ")\n") ;

  &Log ("Extract timestamps.\n") ;
  &Log ("Data read (Mb):\n") ;
  &LogTime ;

  my $file_completely_parsed = $false ;
  my $records_read = 0 ;

  while (($line = <FILE_IN>) && ($line !~ /INSERT INTO/)) # \`?$table\`? VALUES"/))
  { ; }

  $bytes_read = 0 ;
  $mb_read = 0 ;
  $records_read += &ProcessSqlBlock ($reg_expr, $table) ;
  while (($line = <FILE_IN>)  && (length ($line) > 1))
  {
    if ($line =~ /^UNLOCK TABLES;/i)
    { $file_completely_parsed = $true ; last }
    $records_read += &ProcessSqlBlock ($reg_expr, $table) ;
  }
  close "FILE_IN" ;

  if ($records_read == 0)
  {
    $file_in =~ s/.*[\\\/]//g ;
    abort ("No records matched regexp in file '" . $file_in . "'. File empty? Database layout changed?") ;
  }
  &Log ("\n\nRecords read: $records_read\n") ;
}

sub ProcessSqlBlock
{
  if (! $testmode)
  { use Compress::Zlib; }

  $reg_expr = shift ;
  $table    = shift ;

  #temporary replace all \' text quotes, leaving only CSV quotes
  $line =~ s/\\\'/\#\*\$\@/g ;
  $records_found = 0 ;
  while ($line =~ m/$reg_expr/g)
  {

    $records_found++ ;
    $pageid    = $1 ;
    $namespace = $2 ;
    $title     = $3 ;
    $article   = $4 ;
    $user      = $5 ;
    $time      = $6 ;

    $year  = substr ($time,0,4) ;
    $month = substr ($time,4,2) ;
    $day   = substr ($time,6,2) ;
    $hour  = substr ($time,8,2) ;

    $timegm = timegm ( 0, 0, 0,$day, $month-1, $year-1900) ;
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime ($timegm);

    if (($wday == 0) || ($wday == 6)) # skip weekends
    { next ; }

    @edits {"$year-$month-$hour"} ++ ;
  }


  $bytes_read += length ($line) ;
  while ($bytes_read > ($mb_read + 10) * $Mb)
  {
    &Log (($mb_read += 10) . " ") ;
  }
  return ($records_found) ;
}

sub OpenLog
{
  my $target = "" ;
  if    ($webalizer)    { $target = "Webalizer" ; }
  elsif ($mode eq "wb") { $target = "Wikibooks" ; }
  elsif ($mode eq "wk") { $target = "Wiktionary" ; }
  elsif ($mode eq "wn") { $target = "Wikinews" ; }
  elsif ($mode eq "wo") { $target = "Wikivoyage" ; }
  elsif ($mode eq "wp") { $target = "Wikipedia" ; }
  elsif ($mode eq "wq") { $target = "Wikiquote" ; }
  elsif ($mode eq "ws") { $target = "Wikisource" ; }
  elsif ($mode eq "wx") { $target = "Wikispecial" ; }
  elsif ($mode eq "wv") { $target = "Wikiversity" ; }
  else                  { $target = "???" ; }

  $fileage  = -M $file_log ;
  if ($fileage > 5)
  {
    open "FILE_LOG", "<", $file_log || abort ("Log file 'WikiCountsLog.txt' could not be opened.") ;
    @log = <FILE_LOG> ;
    close "FILE_LOG" ;
    $lines = 0 ;
    open "FILE_LOG", ">", $file_log || abort ("Log file 'WikiCountsLog.txt' could not be opened.") ;
    foreach $line (@log)
    {
      if (++$lines >= $#log - 5000)
      { print FILE_LOG $line ; }
    }
    close "FILE_LOG" ;
  }
  open "FILE_LOG", ">>", $file_log || abort ("Log file 'WikiCountsLog.txt' could not be opened.") ;
  &Log ("\n\n===== WikiCounts / " . &GetDateTime(time) . " / $target: " . uc ($language) . " =====\n\n") ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print FILE_LOG $msg ;
}

sub Log2
{
  $msg = shift ;
  print FILE_LOG $msg ;
}

sub LogTime
{
  if ($filesizelarge)
  {
    my ($min, $hour) = (localtime (time))[1,2] ;
    &Log ("\n" . sprintf ("%02d", $hour) . ":" . sprintf ("%02d", $min)) ;
  }
}
