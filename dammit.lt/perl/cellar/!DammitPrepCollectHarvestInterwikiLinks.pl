#!/usr/bin/perl

open IN, '<', 'index.php' ;

while ($line = <IN>)
{
  if ($line =~ /class=\"interwiki/)
  {
    chomp ($line) ;
    $lang = $line ;
    $lang =~ s/^.*?interwiki-(\w+).*$/$1/ ;
    $title = $line ;
    $title =~ s/^.*?href=\"([^\"]+)\".*$/$1/ ;
    $title =~ s/^.*\/([^\/]+)$/$1/ ;
#    print "[$lang] $title\n" ;
    @languages {$title} .= "$lang," ;
    @langcnt   {$title}++ ;
  }
}
print "\n\n\n" ;

foreach $title (sort {$langcnt {$b} <=> $langcnt {$a}} keys %langcnt)
{
  $count = $langcnt {$title} ;
  if ($count > 10)
  { $pattern .= "^$title\n" ; }
  else
  {
    $langlist = $languages {$title} ;
    @langs = split (',', $langlist) ;
    foreach $lang (@langs)
    {
      print "$lang $title\n" ;
      $pattern .= "^$lang\.z $title\n"
    }
  }
}

print "\n\nPATTERN:\n$pattern\n" ;

