#!/usr/bin/perl

$| = 1; # flush screen output

open IN,   '<', 'PageViewsBannerPages.txt' ;
open OUT1, '>', 'PageViewsBannerPagesUse.txt' ;
open OUT2, '>', 'PageViewsBannerPagesDiscard.txt' ;
open LOG,  '>', 'PageViewsBannerPagesLog.txt' ;

while ($line = <IN>)
{
  ($date,$project,$title,$counts) = split (' ', $line) ;

  $date =~ s/^.*?(\d{8}).*$/$1/ ;
  $project =~ s/^.*?:// ;
  $project =~ s/\.z// ;

  $projects {$project} ++ ;

  ($total = $counts) =~ s/\D.*//g ;

# next if $line !~ /20101001/ ;
# next if $line !~ /fy\.z/ ;

  if ($line !~ /(?:BannerCont|BannerList|BannerLoad|Bannerbeheer)/i)
  {
    print OUT2 $line ;
    $total_discard += $total ;
    $titles_discard {"$project $title"} += $total ;
    next ;
  }

  print OUT1 $line ;
  $titles_use {"$project $title"} += $total ;
  $total_use += $total ;

  # print "$counts: " ;
  $counts =~ s/^\d+// ; # remove (redundant) preceding total
  while ($counts ne "")
  {
    $letter = substr ($counts,0,1) ;
    $counts = substr ($counts,1) ;
    ($count = $counts) =~ s/^(\d+).*$/$1/ ;
    $counts =~ s/^\d+(.*)$/$1/ ;
    $hour = ord ($letter) - ord ('A') ;
    # print "[$hour] $count " ;

    $substract  {"$project,$date,$hour"}  += $count ;
  # if (($project eq 'fy') && ($date eq '20101001'))
  # { print "$project,$date,$hour\n" ; }
  }
  # print "\n" ;

}
close IN ;

&Log ("\n\nDiscard:\n") ;
foreach $title (sort {$titles_discard {$b} <=> $titles_discard {$a}} keys %titles_discard)
{
  print     $titles_discard {$title} . " : $title\n" ;
  print LOG $titles_discard {$title} . " : $title\n" ;
  last if $lines_discard++ > 10 ;
}

&Log ("\n\nUse:\n") ;
foreach $title (sort {$titles_use {$b} <=> $titles_use {$a}} keys %titles_use)
{
  print LOG $titles_use {$title} . " : $title\n" ;
  next if $lines_use++ > 10 ;
  print     $titles_use {$title} . " : $title\n" ;
  last if $lines_use++ > 1000 ;
}

&Log ("\n\nProjects:\n") ;
foreach $project (sort keys %projects)
{
  &Log ("$project ") ;
  &Log ("\n") if $projects_printed++ %10 == 0 ;
}
close OUT1 ;
close OUT2 ;
close LOG ;

&Patch ;

&Log ("Use         $total_use\n") ;
&Log ("Discard     $total_discard\n") ;
&Log ("Substracted $counts_substracted\n") ;

print "\n\nReady\n\n" ;
exit ;

sub Patch
{
  &Log ("\n\nPatch\n\n") ;
  if (-d "/a/dammit.lt/projectcounts")
  { $dir = "/a/dammit.lt/projectcounts" ; }
  else
  { $dir = "w:/# In Dammit.lt/projectcounts/t" ; }

  chdir ($dir) || die "Cannot chdir to $dir\n" ;

  local (*DIR);
  opendir (DIR, ".");
  @files = () ;

  while ($file_in = readdir (DIR))
  {
    next if $file_in !~ /^projectcounts-2010(?:09|10)/ ;
  # next if $file_in !~ /^projectcounts-20101001/ ;

    push @files, $file_in ;
  }

  closedir (DIR);

  @files = sort @files ;

  foreach $file (@files)
  { &PatchFile ($file) ; }

  &Log ("\n\nUnpatched\n\n") ;
  foreach $key (sort keys %substract)
  {
    if (! $substract_found  {$key})
    { &Log ("$key\n") ; }
  }
}

sub PatchFile
{
  my $file = shift ;
  my $line ;
  print "\nFile $file\n" ;

  ($dummy,$date,$time) = split '-', $file ;
  $hour = substr ($time,0,2) + 0 ;

  open PROJECTFILE, '<', "$dir/$file" || die "Could not open '$dir/$file'\n" ;

  undef @projectfile ;
  $file_changed = 0 ;
  while ($line = <PROJECTFILE>)
  {
    chomp $line ;
    ($project,$dash,$count,$bytes) = split (' ', $line) ;

   # next if $project ne 'fy' ;
   # print "$line\n" ;
     next if $bytes eq '' ;
     $count_substract = $substract  {"$project,$date,$hour"}  ;
     $substract_found  {"$project,$date,$hour"} ++ ;

     if ($count_substract == 0)
     { push @projectfile, $line ; }
     else
     {
       $file_changed = 1 ;
       $count -= $count_substract ;
       &Log ("\n$line ->\n") ;
       $line = "$project $dash $count 1" ;
       push @projectfile, $line ;
       &Log ("$line\n") ;
     }
   # next if $count_substract eq '' ;
     $counts_substracted += $count_substract ;
   # print "$project $count minus $count_substract\n" ; #  '$project,$date,$hour'\n" ;
  }

  close PROJECTFILE ;

  if ($file_changed)
  {
    open  PROJECTFILE, '>', "$dir/$file" || die "Could not open '$dir/$file'\n" ;
    foreach $line (@projectfile)
    { print PROJECTFILE "$line\n" ; }
    close PROJECTFILE ;
  }
}

sub Log
{
  my $msg = shift ;
  print $msg ;
  print LOG $msg ;
}



