#!/usr/local/bin/perl
use CGI qw(:all);

  open IN, '<', "pagecounts-20090301_fdt" ;
  open OUT, '>', "!DammitRankSpecialPages.txt" ;
  $projprev = "" ;
  while ($line = <IN>)
  {
    if ($line =~ /^#/) { next ; }
    if ($line =~ /^@/) { next ; }
  #  if (($line !~ / Wikipedia\:/) && ($line !~ / Help\:/)  && ($line !~ / Hilfe\:/) && ($line !~ / Wikipédia\:/) && ($line !~ / Aide\:/)  )
    if (($line !~ / Help\:/)  && ($line !~ / Hilfe\:/) && ($line !~ / Aide\:/))
    { next ; }

    chomp ($line) ;
    ($project, $title, $counts) = split (' ', $line) ;
    $project =~ s/^([^\.]+)\.z/wikipedia:$1/ ;
    $project =~ s/^([^\.]+)\.b/wikibooks:$1/ ;
    $project =~ s/^([^\.]+)\.d/wiktionary:$1/ ; # dictionaire
    $project =~ s/^([^\.]+)\.m/wikimedia:$1/ ;
    $project =~ s/^([^\.]+)\.n/wikinews:$1/ ;
    $project =~ s/^([^\.]+)\.q/wikiquote:$1/ ;
    $project =~ s/^([^\.]+)\.s/wikisource:$1/ ;
    $project =~ s/^([^\.]+)\.v/wikiversity:$1/ ;
    $project =~ s/^([^\.]+)\.x/wikispecial:$1/ ;
    if ($project ne $projprev)
    {
      $rows = 0 ;
      foreach $key (sort {$counts {$b} <=> $counts {$a}} keys %counts)
      {
        print OUT sprintf ("%8d", $counts {$key} ) . ": $key\n" ;
        if ($rows++ > 50)
        { last ;}
      }
      undef %counts ;
    }
    $projprev = $project ;

    $counts =~ s/^(\d+).*$/$1/ ;
    @counts {"$project $title"} += $counts ;
  }



