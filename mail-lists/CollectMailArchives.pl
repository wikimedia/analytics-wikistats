#!/usr/bin/perl

  use lib "/[.. path ..]/lib" ;
  use EzLib ;
  $trace_on_exit = $true ;

  use CGI::Carp qw(fatalsToBrowser);
  use Time::Local ;

  $checkhtml = $true ;
  $checktext = $false ;

  if (-e '/[.. path ..]')
  {
    $root = '/[.. path ..]/@lists' ;
    $file_log = "/[.. path ..]/LogCollectMailArchives.txt" ;
  }
  else
  {
    $root = '\@lists' ;
    $file_log = "LogCollectMailArchives.txt" ;
  }

  ($sec,$min,$hourstarted,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

  &OpenLog ;

  $content =~ s/\x09+\x20+/ /g ;
  $content =~ s/\x09+/ /g ;

  &Log ("\nFetch overview of mailing lists\n") ;
  $url = "http://mail.wikipedia.org/mailman/listinfo" ;
  ($succes, $content) = &GetPage ($url, $checkhtml) ;

  if ($succes)
  { &GetMailingLists ($content) ; }

  &Log ("Ready fetching archives\n\n") ;

  close "FILE_LOG" ;
  exit ;

sub GetPage
{
  use LWP::UserAgent;
  use HTTP::Request;
  use HTTP::Response;
  use URI::Heuristic;

  my $raw_url = shift ;
  my $is_html = shift ;
  my ($success, $content, $attempts) ;
  my $file = $raw_url ;
  $file =~ s/.*\/(.*\/)$/$1/g ;
  $file =~ s/.*\/(.*[^\/])$/$1/g ;

  my $url = URI::Heuristic::uf_urlstr($raw_url);

  my $ua = LWP::UserAgent->new();
  $ua->agent("Wikimedia Perl job / EZ");
  $ua->timeout(60);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://infodisiac.com");

  my $succes = $false ;

  &Log ("Fetch '$file'") ;
  for ($attempts = 1 ; ($attempts <= 2) && (! $succes) ; $attempts++)
  {
    my $response = $ua->request($req);
    if ($response->is_error())
    {
      if (index ($response->status_line, "404") != -1)
      { &Log (" -> 404\n") ; }
      else
      { &Log (" -> error: \nPage could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n") ; }
      return ($false) ;
    }
    # else
    # { &Log ("\n") ; }

    $content = $response->content();

    if ($is_html && ($content !~ m/<\/html>/i))
    {
      &Log ("Page is incomplete:\n  '$raw_url'\n") ;
      next ;
    }

    $succes = $true ;
  }

  if (! $succes)
  { &Log (" -> error: \nPage not retrieved after " . (--$attempts) . " attempts !!\n\n") ; }
  else
  { &Log (" -> OK\n") ; }

  return ($succes,$content) ;
}


sub GetMailingLists
{
  my @content = split ("\n", shift) ;
  my ($url, $content) ;
  &Log ("\nFetch mailing lists\n") ;
  foreach $line (@content)
  {
    if ($line =~ /<a href/)
    {
      ($url, $name) = $line =~ m/<a href=\"([^\"]+)\"><strong>(.*?)<\/strong>/ ;

      next if $name eq "Wikimediafr-l" ; # removed on request, is now private list

      if (($url ne "") && ($name ne ""))
      { &GetMailingList ($name, $url) ; }
    }
  }
}

sub GetMailingList
{
  my $name   = shift ;

  my $url    = shift ;
  my ($content, @content, $path) ;
  my $folder = "\@lists/$name" ;

  &Log ("\n") ;
  $url =~ s/.*\///g ; # http://mail.wikipedia.org/pipermail/announce-l/
  $url = "http://mail.wikipedia.org/pipermail/$url/" ;
  ($succes, $content) = &GetPage ($url, $checkhtml) ;

  if (! $succes)
  {
    return ;
  }

  # to do : beter criterion whether file needs to be downloaded
  # only download file for this month + for previous month
  # previous until that was done at least once succesfully after month ended
  my @content = split ("\n", $content) ;
  $getcnt = 0 ;
  foreach $line (@content)
  {
    if ($line =~ /a href=\"[^\"]+\.txt(?:\.gz)?\"/i)
    {
      ($file) = $line =~ /a href=\"([^\"]+)\"/i ;
      ($year) = $file =~ /^(\d+)[^\d]/ ;

      $path  = "$root/$name/$file" ;
      $path =~ s/\.gz$// ;

      if (($getcnt >= 2) && (-e $path))
      {
        &Log("Skip $path\n") ;
        next ;
      }
      $url2 = $url . $file ;
      ($succes, $content) = &GetPage ($url2, $checktext) ;
      if ($succes)
      {
        # &Log ("$file fetched\n") ;
        &SaveFile ($root, $name, $file, $content) ;
        # if (++$getcnt >= 2)
        # { last ; }
        $getcnt++ ; # only fetch newest two months always
        if ($getcnt > 4)
        { last ; } ; # test only: limit new files per folder to speed up process
      }
    }
  }

  $cmd = "gzip -dfv /[.. path ..]/$folder/*.txt.gz" ;
  $result = `$cmd` ;
  &Log ("\nGzip '$cmd' -> $result\n") ;

}

sub SaveFile
{
  my $root    = shift ;
  my $folder  = $root . "/" . shift ;
  my $file    = shift ;
  my $content = shift ;
  my $path    = "$folder/$file" ;

  if (! -d $root)
  {
    &Log ("Create folder '$root'.") ;
    mkdir $root, 0770 ;
  }
  if (! -d $folder)
  {
    &Log ("Create folder '$folder'.") ;
    mkdir "$folder", 0770 ;
  }
  if (! -d $folder)
  {
    &Log ("Folder '$folder' could not be created.") ;
    return ;
  }

  $l = length ($content) ;
  $s = -s $path ;
  if ($l > $s)
  {
           &Log ("Write '$path' $l $s\n") ;
    unlink $path ;
    open "FILE_OUT", ">", $path  || abort ("File '$path' could not be opened.") ;
    binmode FILE_OUT ;
    print FILE_OUT $content ;
    close "FILE_OUT" ;
  }
  else
  {
    &Log ("Keep '$path'\n") ;
  }
}

sub OpenLog
{
  $fileage  = -M $file_log ;
  if ($fileage > 5)
  {
    open "FILE_LOG", "<", $file_log || abort ("Log file '$file_log' could not be opened.") ;
    @log = <FILE_LOG> ;
    close "FILE_LOG" ;
    $lines = 0 ;
    open "FILE_LOG", ">", $file_log || abort ("Log file '$file_log' could not be opened.") ;
    foreach $line (@log)
    {
      if (++$lines >= $#log - 5000)
      { print FILE_LOG $line ; }
    }
    close "FILE_LOG" ;
  }
  open "FILE_LOG", ">>", $file_log || abort ("Log file '$file_log' could not be opened.") ;
  close "FILE_LOG" ; # first update timestamp only to show job is running (no shell access)
  open "FILE_LOG", ">>", $file_log || abort ("Log file '$file_log' could not be opened.") ;
  &Log ("\n\n===== CollectMailArchivesWikiCounts / " . date_time_english (time) . " =====\n\n") ;
}

sub Log
{
  $msg = shift ;
  print $msg ;
  print FILE_LOG $msg ;
}
