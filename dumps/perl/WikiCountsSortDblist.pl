#!/usr/bin/perl

use Getopt::Std ;

  getopt ("cds", \%options) ;

  die ("Specify dblist file as: -d path") if (! defined (@options {"d"})) ;
  die ("Specify path for StatisticsLog.csv: -c path") if (! defined (@options {"c"})) ;
  die ("Specify suffix: -s suffix") if (! defined (@options {"s"})) ;

  $file_csv    = @options {"c"} ;
  $file_dblist = @options {"d"} ;
  $suffix      = @options {"s"} ;

# local test only:
# $file_csv    = "dblists/StatisticsLog.csv" ;
# $file_dblist = "dblists/wikinews.dblist" ;
# $suffix      = "wikinews" ;

  if (! -e $file_csv)    { die "csv file '$file_csv' not found" ; }
  if (! -e $file_dblist) { die "dblist file '$file_dblist' not found" ; }

  print "\n\nSort dblist $file_dblist\nProcessing last dump took x seconds:\n\n" ;
  open DBLIST, '<', $file_dblist ;
  @dblist = <DBLIST> ;
  foreach $db (@dblist)
  {
    chomp $db;
    $db =~ s/\s//g ;
  }
  close DBLIST ;

  open CSV, '<', $file_csv ;
  while ($line = <CSV>)
  {
    ($lang,$dummy1,$dummy2,$runtime) = split (',', $line) ;
    $runtime =~ s/\&\#44;//g ;

    $runtime_dhms = $runtime ;
    $runtime_dhms =~ s/^\s*0 days 0 hrs 0 min// ;
    $runtime_dhms =~ s/^\s*0 days 0 hrs// ;
    $runtime_dhms =~ s/^\s*0 days// ;
    $runtime_dhms =~ s/^\s*// ;
    $runtimes_dhms {"$lang$suffix"} = $runtime_dhms ;

    if ($runtime =~ /days.*hrs.*min.*sec/)
    { $runtime =~ s/^(\d+) days (\d+) hrs (\d+) min (\d+) sec.*$/$1*3600*234+$2*3600+$3*60+$4/e ; }
    elsif ($runtime =~ /hrs.*min.*sec/)
    { $runtime =~ s/^(\d+) hrs (\d+) min (\d+) sec.*$/$1*3600+$2*60+$3/e ; }
    elsif ($runtime =~ /min.*sec/)
    { $runtime =~ s/^(\d+) min (\d+).*$/$1*60+$2/e ; }
    elsif ($runtime =~ /hrs.*min/)
    { $runtime =~ s/^(\d+) hrs (\d+).*$/$1*3600+$2*60/e ; }
    $runtimes {"$lang$suffix"} = $runtime ;
  }
  close CSV ;

  foreach $lang (sort {$runtimes {$b} <=> $runtimes {$a}} keys %runtimes)
  {
    # print "$lang$suffix\n" ;
    @wiki_rank {$lang} = ++$index ;
  }

  @dblist = sort {@wiki_rank {$b} <=> @wiki_rank {$a}} @dblist ;

  rename $file_dblist, $file_dblist.".bak" ;

  $lines = 0 ;
  open DBLIST, '>', $file_dblist ;
  foreach $db (@dblist)
  {
    $rank = $wiki_rank {$db} ;
    print (sprintf ("%3d", ++$lines) . ": $db - " . $runtimes {$db} . " - (" . $runtimes_dhms {$db} . ")\n") ;
    print DBLIST "$db\n" ;
  }
  close DBLIST ;

  print "\n==\n" ;
  exit ;


