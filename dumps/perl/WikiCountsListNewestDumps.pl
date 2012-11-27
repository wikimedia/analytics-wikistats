#!/usr/bin/perl

# List for every wiki in one project the latest stub dump per language (languages as specified in dblist)
  use Getopt::Std ;
  $| = 1; # Flush output
  
  my %options ;
  getopt ("clpw", \%options) ;
  $path_csv    = $options {'c'} ; 
  $project     = $options {'p'} ;
  $file_dblist = $options {'l'} ;

  die "Specify path to csv files as: -c [path]" if ! -d $path_csv ;
  print "Path to csv files: $path_csv\n" ;

  die "Specify project code as: -p [wb|wk|wn|wp|wq|ws|wv|wx|wo]" if $project !~ /^(?:wb|wk|wn|wp|wq|ws|wv|wx|wo)$/ ;
  print "Project code: $project\n" ;

  die "Dblist file '$file_dblist' not found" if ! -e $file_dblist ; 

  open DBLIST, '<', $file_dblist ;
  @dblist = <DBLIST> ;
  close DBLIST ;
  @dblist = sort @dblist ;

  $file_newest_dumps = "$path_csv/csv_$project/StatisticsNewestDumps.csv" ;
  print "Write output to $file_newest_dumps\n" ;

  open DUMPS, '>', $file_newest_dumps ;
  print DUMPS "#from WikiCountsListNewestDumps.pl\n" ;
  foreach $wiki (@dblist)
  {
    chomp $wiki ;
    $wiki =~ s/\s//g;
    &FindNewestDumps ($project, $wiki) ;
  }
  close DUMPs ;

  print "\nReady\n" ;
  exit ;

sub FindNewestDumps
{
  my ($project,$wiki) = @_ ;
  $file_rss_latest_dump_stub = "/mnt/data/xmldatadumps/public/$wiki/latest/$wiki-latest-stub-meta-history.xml.gz-rss.xml" ;

  if (! -e $file_rss_latest_dump_stub)
  {
    print "$wiki,xml file not found: $file_rss_latest_dump_stub\n" ;
    return ;
  }

  open XML, '<', $file_rss_latest_dump_stub || print "File not found: $file_rss_latest_dump_stub" ;
  while ($line = <XML>)
  {
    chomp $line ;
    if ($line =~ /<link>/)
    {
      ($date = $line) =~ s/^.*?\/(\d{8})<.*$/$1/ ;
      $file_dump = "/mnt/data/xmldatadumps/public/$wiki/$date/$wiki-$date-stub-meta-history.xml.gz" ;
      if ($date =~ /^\d{8}$/)
      {
        if (! -e $file_dump)
        {
          print "$wiki dump not found: $file_dump\n" ;
          print DUMPS "stub,$project,$wiki,dump not found: $file_dump\n" ;
        }
        else
        {
          print "$wiki $date\n" ;
          print DUMPS "stub,$project,$wiki,/mnt/data/xmldatadumps/public/$wiki/$date/$wiki-$date-stub-meta-history.xml.gz\n" ;
        }
      }
      else
      {
        print "$wiki no valid date found\n" ;
        print DUMPS "stub,$project,$wiki,no valid date found\n" ;
      }

      last ;
    }
  }
  close XML ;
}


