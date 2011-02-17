#!/usr/bin/perl

use Getopt::Std ;

  getopt ("cds", \%options) ;

  die ("Specify dblist file as: -d path") if (! defined (@options {"d"})) ;
  die ("Specify path for StatisticsLog.csv: -c path") if (! defined (@options {"c"})) ;
  die ("Specify suffix: -s suffix") if (! defined (@options {"s"})) ;

  $file_csv    = @options {"c"} ;
  $file_dblist = @options {"d"} ;
  $suffix      = @options {"s"} ;

  if (! -e $file_csv)    { die "csv file '$file_csv' not found" ; }
  if (! -e $file_dblist) { die "dblist file '$file_dblist' not found" ; }

  open CSV,    '<', $file_csv ;
  open DBLIST, '<', $file_dblist ;
  @dblist = <DBLIST> ;
  foreach $db (@dblist)
  {
    chomp $db;
    $db =~ s/\s//g ;
  }
  close DBLIST ;

  while ($line = <CSV>)
  {
    ($lang,$dummy1,$dummy2,$runtime) = split (',', $line) ;
    $runtime =~ s/\&\#44;//g ;
    if ($runtime =~ /hrs.*min.*sec/)
    { $runtime =~ s/^(\d+) hrs (\d+) min (\d+) sec.*$/$1*3600+$2*60+$3/e ; }
    elsif ($runtime =~ /min.*sec/)
    { $runtime =~ s/^(\d+) min (\d+).*$/$1*60+$2/e ; }
    elsif ($runtime =~ /hrs.*min/)
    { $runtime =~ s/^(\d+) hrs (\d+).*$/$1*3600+$2*60/e ; }
    @runtimes {$lang} = $runtime ;
  }
  foreach $lang (sort {$runtimes {$b} <=> $runtimes {$a}} keys %runtimes)
  {
    # print "$lang$suffix\n" ;
    @index {"$lang$suffix"} = ++$index ;
  }

  @dblist = sort {@index {$b} <=> @index {$a}} @dblist ;

  rename $file_dblist, $file_dblist.".bak" ;

  open DBLIST, '>', $file_dblist ;
  foreach $db (@dblist)
  {
    $index = $index {$db} ;
    print "$db: $index\n" ;
    print DBLIST "$db\n" ;
  }
  close DBLIST ;

  print "Ready" ;
  exit ;


