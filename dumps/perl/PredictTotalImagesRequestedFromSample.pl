#!/usr/bin/perl

$total_images = 1000000;
$sampling_rate = 1/1000 ;
$run_length = 300 ; # seconds

$time_start = time ;

# vary popularity of image between 0 and 1 with most image 'unpopular'
for ($ndx = 0 ; $ndx < $total_images ; $ndx++)
{
  if (rand () < 0.1)
  { $image_popularity [$ndx] = 0.99 ; }
  else
  { $image_popularity [$ndx] = 0.00001 ; }
}

$secs_to_go = $run_length ;
while ($secs_to_go > 0)
{
  # choose random image
  $ndx = int (rand ($total_images)) ; # very unrandom on Windows, fine in Linux

  # decide to request image or not
  $rand = rand () ;
  # print "$rand " . $image_popularity [$ndx] . "\n" ;
  next if $rand > $image_popularity [$ndx] ;
  $total_images_requested++ ;
  $image_requested [$ndx] ++ ;
  if (rand () < $sampling_rate)
  { $image_occurs_in_sample [$ndx] ++ ; }

  if ($total_images_requested % 500000 == 0)
  { &ShowResults ; } # give intermediate results

  $secs_to_go = $run_length - (time - $time_start) ;
}

&ShowResults ;

print "\nReady\n" ;

sub ShowResults
{
  $unique_images_requested_total = 0 ;
  $unique_images_occurring_in_sample = 0 ;
  for ($i = 0 ; $i < $total_images ; $i++)
  {
    if ($image_requested [$i] >= 1)
    { $unique_images_requested_total ++ ; }
    if ($image_occurs_in_sample [$i] >= 1)
    { $unique_images_occurring_in_sample ++ ; }
  }

  $chance_image_not_in_sample = 1 - $unique_images_occurring_in_sample / $total_images ;
  $chance_image_not_requested_at_all = $chance_image_not_in_sample ** (1/$sampling_rate) ;
  $estimate_unique_images_requested_total = int ($total_images * (1 - $chance_image_not_requested_at_all)) ;

  print "Total image requests               $total_images_requested\n" ;
  print "Unique images available            $total_images\n" ;
  print "Unique images counted overall:     $unique_images_requested_total\n" ;
  print "Unique images counted in sample:   $unique_images_occurring_in_sample\n" ;
  print "Chance image not in sample:        $chance_image_not_in_sample\n" ;
  print "Chance image not requested at all: $chance_image_not_requested_at_all\n" ;
  print "Estimated unique images requested: $estimate_unique_images_requested_total\n" ;
  print "Ratio counted vs estimated unique images requested: " . sprintf ("%.10f",$unique_images_requested_total/$estimate_unique_images_requested_total) . "\n" ;
  print "Runtime in seconds remaing:        $secs_to_go\n\n\n" ;
}

