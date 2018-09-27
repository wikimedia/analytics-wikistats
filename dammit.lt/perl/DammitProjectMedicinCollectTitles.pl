#!/usr/bin/perl

# collect urls from https://en.wikipedia.org/wiki/Wikipedia:WikiProject_Medicine/Translation_task_force/RTT
# write list of page titles, to be looked up in montly consolidated page views file

  use CGI::Util ; 
  use Time::Local ;
  use Getopt::Std ;
  use File::Path ;

  our $table_depth = 0 ;
  our $true = 1 ;
  our $false = 0 ;

  our $check_redirects  = $true ;
  our $check_categories = $false ; # old approach, to be removed ?

# our $url_page = "https://en.wikipedia.org/wiki/Wikipedia:WikiProject_Medicine/Translation_task_force/RTT" ;
  our $url_page = "https://docs.google.com/a/wikimedia.org/spreadsheets/d/1cb80jUe-tObwbTo-o4hh2IpcQHSv1TAJh-8vuniNsCs/edit#gid=0" ;

  our $img_cat   = "<img src='https://upload.wikimedia.org/wikipedia/commons/c/cc/Icons-mini-icon_accept.gif'>" ;
  our $img_nocat = "<img src='https://upload.wikimedia.org/wikipedia/commons/5/5a/Icons-mini-action_stop.gif'>" ;

  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
  $now = sprintf ("%02d-%02d-%04d %02d:%02d\n",$mday,$mon+1,$year+1900,$hour,$min) ;
  our $out_generated = "<br><small>Page generated: $now GMT (server time)<br>Script 'DammitProjectMedicinProgressReport.pl' by Erik Zachte runs hourly on stats server</small>" ;
  our $out_legend = "<p>Legend:<br>$img_cat: Page is 'Live', contains category, links to <i>view page</i><br>$img_nocat: Page is 'Live', does not contain category, links to <i>edit page</i>" ;
  our $out_comments = "<p><font color=#A00>If the edit link leads to a redirect page (edit box almost empty), click <i>Cancel</i> to reach the proper article, then click <i>Edit</i></font>" ;

  &ParseArguments ;

# Dec 2014: data are now wget on stat1003
# ($result, $content) = &GetPage ($url_page, $true) ;
# die "Page could not be found ($result)" if ! $result ;

  open HTML, '<', "/a/wikistats_git/dammit.lt/temp/google_doc_medicin_project.html" ;
  @content = <HTML> ;
  $content = join ("\n", @content) ;
  &ProcessArticle ($content) ;

# open CSV_OUT, '>', "w:/temp/WikiProject_Medicine_Translation_task_force_RTT.csv" ; # tests

  print "write $dir_out/$file\n" ;

  open CSV_OUT, '>', "$dir_out/$file_out" ;

  print CSV_OUT "# category:Medical_articles_translated_from_English\n" ;
  print CSV_OUT "# depth:10\n" ;
  print CSV_OUT "# job:\n" ;
  $lang_prev = '' ;
  foreach $line (sort @csv)
  {
    chomp $line ;
    ($lang = $line) =~ s/\..*$// ;
    if ($lang ne $lang_prev)
    {
      print CSV_OUT "# wiki:$lang.wikipedia.org\n" ;
      $lang_prev = $lang ;
    }
    print CSV_OUT "$line\n" ;
  }
  close CSV_OUT ;

  print "Ready\n\n" ;
  exit ;

sub ParseArguments
{
  my $options ;
  getopt ("o", \%options) ;
  my $output = $options {"o"} ;

  print "Output: '$output'\n" ;
  abort ("Specify output file as : '-o [path][file]'") if ($output !~ /.+\/.+/) ;

  our ($file_out, $dir_out) ;
  ($file_out = $options {o}) =~ s/^.+\/([^\/]+)$/$1/ ;
  abort ("No file specified in output string as : '-o [path][file]'") if $file_out eq '' or $file_out eq $output ;
  ($dir_out = $options {o}) =~ s/$file_out// ;

  mkpath ($dir_out, 1, 0750) ;
  abort ("Output dir '$dir_out' does not exist and could not be created") if (! -d $dir_out) ;
}

sub ProcessArticle
{
  my ($content) = @_ ;
  my @article = split ('\n', $content) ;

# open HTML_OUT, '>', 'w:/temp/WikiProject_Medicine_Translation_task_force_RTT.htm' ; # tests
# open HTML_OUT, '>', '$dir_out/WikiProject_Medicine_Translation_task_force_RTT.html' ; # Q&D hard coded location

  foreach $line (@article)
  {
    $table_depth ++ if $line =~ /<table/ ;
    $table_depth -- if $line =~ /<\/table/ ;
    $line =~ s/(<h1[^>]*>)/<table border='3' style='padding:10px'><tr><td>$out_generated<h3><font color=#080>Wikistats copy of <a href='$url_page'>RTT page<\/a><br>For manually adding category 'Medical articles translated from English' to live articles<\/font><\/h3>$out_legend$out_comments<\/td><\/tr><\/table><p>$1/ ;

    if ($table_depth > 0)
    {
      # print "\n$line\n" ;
      if ($links++ < 10000) # set to 100 for tests
      { $line =~ s/(<a .*?<\/a>)/&ProcessLink ($1)/ge ; }
    }

    $line =~ s|"//bits|"https://bits|g ;
    $line =~ s|"//|"https://en.wikipedia.org/|g ;
#   print HTML_OUT $line ;
  }
# close HTML_OUT ;
}

sub ProcessLink
{
  my ($link) = @_ ;

  $link =~ s/,/%2C/g ;
  return ($link) if $link =~ "/jobs/" ;

  if (($link =~ /"\/wiki/) && ($link !~ /\d\d-\d\d-\d\d\d\d/))
  {
    $title_en = $link ;
  # $title_en =~ s/^.*?title=\"// ;
  # $title_en =~ s/".*$// ;
  # if (($title eq '') || ($title =~ /title=/))
  # { $title_en = 'invalid title' ; }
    $title_en =~ s/,/%2C/g ;
    return ($link) ;
  }

  if (($link =~ /.wikipedia.org/) && (($link =~ />Live</) || ($link =~ />Done</) || ($link =~ />GA</) || ($link =~ />FA</)))
  {
  #  print "\nlink: $link\n" ;
    $tag = $link ;
    $tag =~ s/<a.*?>// ;
    $tag =~ s/<\/a>// ;

    $href = $link ;
    $href =~ s/^.*?href="//g ;
    $href =~ s/".*$// ;

    $wiki = $href ;
    $wiki =~ s/https?:// ;
    $wiki =~ s/\.wikipedia.*$// ;
    $wiki =~ s/^\/+// ;

    $name = $link ;
    $name =~ s/^.*?wiki\///g ;
    $name =~ s/".*$//g ;
  # print "name= '$name'\n" ;

    $href =~ s|/wiki/|/w/index.php?title=| ;
    if ($href !~ /http/)
    { $href = "http:$href" ; }

    if ($check_redirects)
    {
      $url = "$wiki.wikipedia.org/w/api.php?action=query&format=xml&titles=$name&prop=categories&redirects" ;
      ($result, $content) = &GetPage ($url, $true) ;
      $found = $false ;
      if ($content =~ /<api>/)
      {
        # $content =~ s/<\/categories>.*$// ;
        # $content =~ s/^.*?<categories>// ;
        # $content =~ s/ title="([^"]+)"/push @titles,$1/ge ;
        if ($content =~ /from.*to/)
        {
          $found = $true ;
        # print "\n$content\n\n" ;

          ($from = $content) =~ s/^.*?from="([^"]+).*$/$1/ ;
          ($to   = $content) =~ s/^.*?to="([^"]+).*$/$1/ ;

          $same = '' ;
          ($from2 = $from) =~ s/_/ /g ;
          ($to2   = $to)   =~ s/_/ /g ;
          if ($from2 eq $to2)
          { $same = " !!! same !!!\n" ; }
          
          print "[$wiki:$title_en] from '$from' to '$to' $same\n" ;

          if ($same eq '')
          { 
            $to2 = $to ;
            $to =~ s/\%20/ /g ;
            $to =~ s/ /_/g ;

            print "1 from $name - $from\n" ;
            print "1 to   $name - $to\n" ;
            $from =~ s/([^-_\(\)])/"\%".sprintf ("%02X",ord($1))/ge ;
            $to   =~ s/([^-_\(\)])/"\%".sprintf ("%02X",ord($1))/ge ;
            print "2 from $name - $from\n" ;
            print "2 to   $name - $to\n" ;

            $line_csv = "$wiki\.z,$name,$title_en is redirect &#8680; <a href='http://$wiki.wikipedia.org/wiki/$to'>target</a>\n" ;
            push @csv, $line_csv ;
            $line_csv = "$wiki\.z,$to,$title_en is redirected &#8678; <a href='http://$wiki.wikipedia.org/wiki/$from'>source</a>\n" ;
            push @csv, $line_csv ;
            $line_csv = "$wiki\.z,$to2,$title_en is redirected &#8678; <a href='http://$wiki.wikipedia.org/wiki/$from'>source</a>\n" ;
            push @csv, $line_csv ;
          }
          else
          {
            $line_csv = "$wiki\.z,$name,$title_en\n" ;
            push @csv, $line_csv ;
          }
          return ($link) ;
        }
      }
    #  else
    #  {
    #  }
    }

    if ($check_categories)
    {
      $url = "$wiki.wikipedia.org/w/api.php?action=query&format=xml&titles=$name&prop=categories&redirects" ;
      print "url $url\n" ;
      ($result, $content) = &GetPage ($url, $true) ;
      $found = $false ;
      if ($content =~ /<api>/)
      {
        # $content =~ s/<\/categories>.*$// ;
        # $content =~ s/^.*?<categories>// ;
        # $content =~ s/ title="([^"]+)"/push @titles,$1/ge ;
        if ($content =~ /Medical articles translated from English/)
        { $found = $true ; }
        print "\ncategories: $content\n\n" ;
      }

      # https://en.wikipedia.org/w/api.php?action=query&titles=Albert%20Einstein&prop=categories
      if ($found)
      { $link = "<a href='$href'>$img_cat&nbsp;$tag</a>" ; }
      else
      { $link = "<a href='$href&action=edit'>$img_nocat&nbsp;$tag</a>" ; }
    }

    $line_csv = "$wiki\.z,$name,$title_en\n" ;
    push @csv, $line_csv ;
    # print "1 >>> $link <<<\n\n" ;
  }
  else
  {
  # print "2 }}} $link {{{\n\n" ;
  }

  return ($link) ;
}



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

  my $url = URI::Heuristic::uf_urlstr($raw_url);

  my $ua = LWP::UserAgent->new();
  $ua->proxy(["http", "https"], $ENV{"http_proxy"}) ;
  $ua->agent("Wikimedia Perl job / EZ");
  $ua->timeout(60);

  my $req = HTTP::Request->new(GET => $url);
  $req->referer ("http://infodisiac.com");

  my $succes = $false ;

  # pacer not needed?
  # if ($requests++ % 2 == 2)
  # { sleep (1) ; }

  my $response = $ua->request($req);
  if ($response->is_error())
  {
    if (index ($response->status_line, "404") != -1)
    { &Log ("\n$url -> 404\n\n") ; }
    else
    { &Log ("\n$url -> error: \nPage could not be fetched:\n  '$raw_url'\nReason: "  . $response->status_line . "\n\n") ; }
    return ($false) ;
  }
    # else
    # { &Log ("\n") ; }

  $content = $response->content();

  $succes = $true ;

  if (! $succes)
  { &Log (" -> error: \nPage not retrieved !!\n\n") ; }
# else
# { &Log (" -> OK\n") ; }

  return ($succes,$content) ;
}

sub Log
{
  print shift ;
}

