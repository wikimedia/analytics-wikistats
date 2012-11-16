#!/usr/bin/perl

sub ProcessBookTitle
{
  my $title   = shift ;
  my $article = shift ;
  my $current_revision = shift ;

  my $title_found = $true ;
  my $title2 = $title ;

  $title2 =~ s^\#\*\$\@^'^g ; # restore single quotes
  $title2 =~ s/\,/&comma;/g ;
  $title2 =~ s/\|/&pipe;/ ;
  $title2 =~ s/\*/&star;/ ;

  my $chapter    = $title2 ;
  my $booktitle  = $title2 ;

  my $poscolon   = index ($chapter, ':') ;
  my $posslash   = index ($chapter, '/') ;
  my $poshyphen  = index ($chapter, ' - ') ;
  if ($poshyphen == -1)
  { $poshyphen  = index ($chapter, "_\xE2\x80\x93_") ; }
  if ($poshyphen == -1)
  { $poshyphen  = index ($chapter, "\xE2\x80\x93") ; }
  if ($poshyphen == -1)
  { $poshyphen  = index ($chapter, '_-_') ; }
  if ($poshyphen == -1)
  { $poshyphen  = index ($chapter, '-') ; }
  my $posbracket = index ($chapter, '(') ;
  my $posspace   = index (substr ($chapter,4), ' ') + 4 ;
  if ($posspace == -1)
  { $posspace   = index (substr ($chapter,4), '_') + 4 ; }

  my $posnum = -1 ;
  if ($chapter =~ /\_?\d+$/)
  {
    my $chapter2 = $chapter ;
    $chapter2 =~ s/\_?\d+$// ;
    $posnum = length ($chapter2) ;
  }

  $poscolon   = ($poscolon   < 1 ? 9999 : $poscolon) ;
  $posslash   = ($posslash   < 2 ? 9999 : $posslash) ;
  $poshyphen  = ($poshyphen  < 2 ? 9999 : $poshyphen) ;
  $posbracket = ($posbracket < 2 ? 9999 : $posbracket) ;
  $posnum     = ($posnum     < 2 ? 9999 : $posnum) ;
  $posspace   = ($posspace   < 4 ? 9999 : $posspace) ;

  if ($mode eq "wv") # accept only slash as chapter delimiter
  {
    $poscolon   = 9999 ;
    $poshyphen  = 9999 ;
    $posbracket = 9999 ;
    $posnum     = 9999 ;
    $posspace   = 9999 ;
  }


  if (($poscolon < 9999) && ($poscolon < $posslash) && ($poscolon < $poshyphen))
  {
    $booktitle =~ s/\:.*$// ;
    $chapter   = substr ($chapter, length ($booktitle)) ;
  }
  elsif (($posslash < 9999) && ($posslash < $poscolon) && ($posslash < $poshyphen))
  {
    $booktitle =~ s/\/.*$// ;
    $chapter = substr ($chapter, length ($booktitle)) ;
  }
  elsif (($poshyphen < 9999) && ($poshyphen < $poscolon) && ($poshyphen < $posslash))
  {
    if ($booktitle =~ /[ \_]?\xE2\x80\x93/)
    {
      $booktitle =~ s/[ \_]?\xE2\x80\x93.*$// ;
      $chapter = substr ($chapter, length ($booktitle)) ;
    }
    elsif ($booktitle =~ /[ \_]?\-/)
    {
      $booktitle =~ s/[ \_]?\-.*$// ;
      $chapter = substr ($chapter, length ($booktitle)) ;
    }
    else
    { &Log ("hyphenation failed for book $booktitle chapter $chapter\n") ; }
  }
  elsif ($posbracket < 9999)
  {
    $booktitle    =~ s/^.*\(([^\)]+)\).*$/$1/ ;
    $chapter      =~ s/^(.*)\([^\)]+\)(.*)$/$1 $2/ ;
  }
  elsif ($posnum < 9999)
  {
    $booktitle = substr ($chapter, 0, $posnum) ;
    $chapter   = substr ($chapter, $posnum)  ;
  }
  elsif ($posspace < 9999)
  {
    $booktitle = substr ($booktitle, 0, $posspace) ;
    $chapter   = substr ($chapter, $posspace) ;
  }
  else
  {
    $booktitle = $title2 ;
    $title_found = $false ;
  }

  if (! $title_found)
  { $chapter = $title2 ; }

  if ($prescan)
  {
    @chaptercnt {$booktitle} ++ ;
    return ($booktitle) ;
  }

  my $mainchapter = "    " ;
  # reassign booktitle when complete title is main page of some book
  if (@chaptercnt {$title2} > 2)
  {
    $mainchapter = " !! " ;
    $booktitle = $title2 ;
    $chapter = $title2 ;
  }

  if ($current_revision)
  {
    # following code copied from CollectArticleCounts  -> make sub
    $article =~ s/\'\'+//go ; # strip bold/italic formatting
    $article =~ s/\<[^\>]+\>//go ; # strip <...> html
    $article =~  s/[\xc0-\xf7][\x80-\xbf]+/x/gxo ;
    $article =~ s/\&\w+\;/x/go ;   # count htlm chars as one char
    $article =~ s/\&\#\d+\;/x/go ; # count htlm chars as one char
    $article =~ s/\[\[ [^\:\]]+ \: [^\]]* \]\]//gxoi ; # strip image/category/interwiki links
                                                       # a few internal links with colon in title will get lost too
    $article =~ s/http \: [\w\.\/]+//gxoi ; # strip external links
    $article =~ s/\=\=+ [^\=]* \=\=+//gxo ; # strip headers
    $article =~ s/\n\**//go ; # strip linebreaks + unordered list tags (other lists are relatively scarce)
    $article =~ s/\s+/ /go ; # remove extra spaces
    my $size = length ($article) ;

    # count again: some booktitles have been reassigned
    @book_chaptercnt {$booktitle}++ ;
    $chapter =~ s/^[\_\:\/\-]+// ;
    @book_chapterlist {$booktitle} .= "$chapter\*$title2\*$size\|" ;
  }

  @book_edits {$booktitle} ++ ;

  return ($booktitle) ;
}

1;