#!/usr/bin/perl

# November 2011 this file is much simplified version of DammitSyncFiles.pl
# DammitSyncFiles.pl used to wget each day new pagecounts and projectcounts files from dammit.lt/wikistats
# These files are now on WMF server. Only copy small projectcounts files and store in tar file. Pagecounts files no longer needs to beed copied.
# This provides a compact archive of all files, and allows versioning (after patching certain ranges of files for server underreporting)

  use Time::Local ;
  use Archive::Tar;

  $tar = Archive::Tar->new;

  $| = 1; # flush screen output

  $timestart = time ;

  $dir_tars    = "/a/dammit.lt/projectcounts" ;
  $dir_dumps   = "/mnt/data/xmldatadumps/public/other/pagecounts-raw" ;
  $dir_archive = "/mnt/data/xmldatadumps/public/other/pagecounts-ez/projectcounts" ;

  if (! -d $dir_tars)
  { &Abort ("Folder not found: '$dir_tars'\n") ; }
  if (! -d $dir_dumps)
  { &Abort ("Folder not found: '$dir_dumps'\n") ; }

  ($month,$year) = (gmtime(time))[4,5];
  $year += 1900;
  $month ++ ;
  $this_month = sprintf ("%04d/%04d-%02d", $year, $year, $month) ;
  $month -- ;
  if ($month == 0)
  { $month = 12 ; $year -- ; }
  $prev_month = sprintf ("%04d/%04d-%02d", $year, $year, $month) ;

  &GetProjectCounts ($prev_month) ;
  &GetProjectCounts ($this_month) ;
  &ArchiveTars ;

  &Log ("Ready in " . (time - $timestart) . " sec.\n") ;
  exit ;

sub GetProjectCounts
{
  my ($yyyy_yyyy_mm) = @_ ;
  my $year  = substr ($yyyy_yyyy_mm,0,4) ;
  my $month = substr ($yyyy_yyyy_mm,10,2) ;

  print "GetProjectCounts for $year - $month\n" ;

  $tar_file = "$dir_tars/projectcounts-$year.tar" ;

  if (-e $tar_file)
  {
    if ($tar_file ne $tar_file_prev)
    {
      &Log ("\nRead tar file $tar_file\n") ;
      $tar->read($tar_file);
      $tar_file_prev = $tar_file ;
    }
  }
  else
  { &Log ("Tar file $tar_file not found\n") ; }

  my $dir_files = "$dir_dumps/$year/$year-$month" ;
  if (! -d $dir_files)
  { &Abort ("Folder not found: '$dir_files'") ; }

  chdir $dir_files || &Abort ("Could not change to dir '$dir_files'") ;

  @files = <*>;
  foreach $file (sort @files)
  {
    next if ! -e $file ;
    next if $file !~ /^projectcounts/ ;
    &GetFile ($tar_file,$dir_files, $file) ;
    $last_file_added = $file ;
  }
}

sub GetFile
{
  my ($tar_file, $dir_files, $file) = @_ ;

  if ($tar->contains_file ($file))
  {
     # &Log ("File $file exists in tar file $tar_file\n") ;
     return ;
  }

  &Log ("Add new file $file to $tar_file\n") ;

  $cmd = "tar --append --file=$tar_file $file" ;
  &Log ("Cmd '$cmd'\n") ;
  $result = `$cmd` ;
  print "$result\n" ;
}

sub ArchiveTars
{
  $cmd = "rsync -av $dir_tars/projectcounts-20??.tar $dir_archive" ;
  &Log ("Cmd '$cmd'\n") ;
  $result = `$cmd` ;
  print "$result\n" ;

  open LAST, '>', "$dir_archive/most_recent_file.txt" ;
  print LAST $last_file_added ;
  close LAST ;
}

sub Log
{
  $msg = shift ;
  my ($ss, $nn, $hh) = (localtime(time))[0,1,2] ;
  my $time  = sprintf ("%02d:%02d:%02d", $hh, $nn, $ss) ;
  $msg = "$time $msg" ;
  print $msg ;
  print LOG $msg ;
}

sub Abort
{
  $msg = shift ;
  &Log ("\nError: $msg\n\n") ;
  exit ;
}
