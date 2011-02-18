#!/usr/bin/perl

$| = 1; # flush screen output

open IN,  '<', 'DammitPatchProjectcountsForFundraiser/AllSquids.csv' ;
open LOG, '>', 'DammitPatchProjectcountsForFundraiser/Log.txt' ;

chdir ("DammitPatchProjectcountsForFundraiser") || die "Cannot chdir to DammitPatchProjectcountsForFundraiser\n" ;

while ($line = <IN>)
{
  chomp $line ;

  next if $line =~ /[*]/ ;
  next if $line !~ /^2010/ ;

  ($date,$hour,$events,$avg_delta) = split (',', $line) ;

  next if $avg_delta <= 1005 ; # normally projectcounts also miss a few hits, overcorrecting would skew trends
  &Patch ($date, $hour, $avg_delta) ;
}

print "\n\nReady\n\n" ;
exit ;

sub Patch
{
  ($date,$hour,$avg_delta) = @_ ;

  $date =~ s/-//g ;
  $file = "projectcounts-$date-" . sprintf ("%02d",$hour) . "0000" ;

  if (! -e $file)
  {
    $file = "projectcounts-$date-" . sprintf ("%02d",$hour) . "0001" ;
    if (! -e $file)
    {
      print "File '$file' missing!\n" ;
      exit ;
    }
  }
  &PatchFile ($file, $avg_delta) ;
}

sub PatchFile
{
  my ($file,$avg_delta) = @_ ;
  my $line ;
  $correction = $avg_delta / 1000 ;
  print "Patch file $file: avg delta $avg_delta -> correction $correction\n" ;

  open PROJECTFILE, '<', $file || die "Could not open '$file'\n" ;

  undef @projectfile ;
  $file_changed = 0 ;
  while ($line = <PROJECTFILE>)
  {
    chomp $line ;
    ($project,$dash,$count,$bytes) = split (' ', $line) ;

     if ($bytes > 0)
     {
       $count = sprintf ("%.0f", $correction * $count) ;
       # &Log ("\n$line ->\n") ;
       $line = "$project $dash $count 1" ;
       # &Log ("$line\n") ;
     }
     push @projectfile, "$line\n" ;
  }

  close PROJECTFILE ;

  open  PROJECTFILE, '>', $file || die "Could not open '$file'\n" ;
  print PROJECTFILE @projectfile ;
  close PROJECTFILE ;
}

sub Log
{
  my $msg = shift ;
  print $msg ;
  print LOG $msg ;
}



