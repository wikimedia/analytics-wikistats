#!/usr/bin/perl

# $file_dblist = "/a/wikistats/dblists/wikipedia.dblist" ;
  $file_dblist = "/a/wikistats/dblists/special.dblist" ;
  open DBLIST, '<', $file_dblist ;
  @dblist = <DBLIST> ;
  close DBLIST ;

  @dblist = sort @dblist ;

# $file_newest_dumps = "/a/wikistats/csv/csv_wp/StatisticsNewestDumps.csv" ;
  $file_newest_dumps = "/a/wikistats/csv/csv_wx/StatisticsNewestDumps.csv" ;
  open DUMPS, '>', $file_newest_dumps ;
  print DUMPS "#from WikiCountsListNewestDumps.pl (Q&D, now only for stub dumps and wikipedia: wp)\n" ;
  foreach $wiki (@dblist)
  {
    chomp $wiki ;
    $wiki =~ s/\s//g;
    &FindNewestDumps ('wp', $wiki) ;
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


