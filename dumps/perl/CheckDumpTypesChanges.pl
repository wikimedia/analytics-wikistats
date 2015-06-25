#!/usr/bin/perl

  foreach $project (qw ("wb wk wn wo wp wq ws wv wx"))
  { &Collect ($project) ; }

  print sort @lines ;
  exit ;

sub Collect
{
  my $project = shift ;
  my (%dump,%change) ;

  open IN, '<', "/a/wikistats_git/dumps/csv/csv_$project/StatisticsLogRunTime.csv" ;

  while ($line = <IN>)
  {
    $dump = '' ;

    ($lang,$date) = split (',', $line) ;
    $lang =~ s/ //g ;

    if ($line =~ /edits_only/) 
    {$dump = 'stub' ; }

    if ($line =~ /full_dump/) 
    {$dump = 'full' ; }

    next if $dump eq '' ;

    if (($dump {$lang} ne '') and ($dump {$lang} ne $dump))
    { 
      $change {$lang} = $date ; 
    }
    $dump {$lang} = $dump ;
  }
  foreach $lang (sort keys %dump)
  {
    push @lines, $change {$lang} . '-> ' . $dump {$lang} . " for $project|$lang\n" ;
  } 

  close IN ;
}
