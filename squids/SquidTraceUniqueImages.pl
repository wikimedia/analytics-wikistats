#!/usr/bin/perl

  $max_days_ago = 100 ;
  $time_start   = time ;

  open CSV_OUT, '>', '/a/ezachte/SquidDataTrendUniqueImages.csv' ;
  print CSV_OUT ",unique files,,,,unique images\n" ;
  print CSV_OUT "date,count,delta,,date,count,delta\n" ;

  for ($days_ago = $max_days_ago ; $days_ago > 0 ; $days_ago --)
  {
    ($day,$month,$year) = (localtime ($time_start - 3600 * 24 * $days_ago))[3,4,5];
    $month++ ;
    $year+=1900 ;
    $yyyy_mm    = sprintf ("%04d-%02d",      $year, $month) ;
    $yyyy_mm_dd = sprintf ("%04d-%02d-%02d", $year, $month, $day) ;
    $date_excel = "\"=DATE($year,$month,$day)\"" ;

    # print "$days_ago days ago -> $yyyy_mm_dd\n" ;

    $file = "/a/ezachte/$yyyy_mm/$yyyy_mm_dd/public/SquidDataBinaries.csv" ;

    if (! -e $file)
    { print "No file $file\n" ; next }

    print "Process $file\n" ;

    open CSV_IN, '<', $file ;
    while ($line = <CSV_IN>)
    {
      chomp $line ;

      next if $line =~ /^#/ ;
      next if $line =~ /^:/ ;

      if ($line =~ /,.*,/)  # forgot to encode comma's in image name
      {
        $line =~ s/,([^,]*)$/#?#?#$1/;
        $line =~ s/,/%47/g;
        $line =~ s/\#\?\#\?\#/,/;
      }

      if ($line =~ /,.*,/)  # not fixed ?
      {
        $line =~ s/,([^,]*)$/^#^$1/;
        $line =~ s/,/%47/g;
        print "\nSkip $line\n" ;
        next ;
      }

      ($file,$count) = split (',', $line) ;

      if ($files {$file} == 0)
      {
        $unique_files++ ;
        $files {$file} += $count ;
      }

      # print "1 $file\n" ;
      $file =~ s/^.*\/\d\/\d\w\/// ;
      # print "2 $file\n" ;
      $file =~ s/\/.*$// ;
      # print "3 $file\n" ;

      if ($images {$file} == 0)
      {
        $unique_images++ ;
        $images {$file} += $count ;
      }

    }

    $delta_files  = $unique_files  - $unique_files_prev ;
    $delta_images = $unique_images - $unique_images_prev ;

    print         "$days_ago,$date_excel,$unique_files,$unique_images\n" ;
    print CSV_OUT "$date_excel,$unique_files,$delta_files,,$date_excel,$unique_images,$delta_images\n" ;

    $unique_files_prev  = $unique_files ;
    $unique_images_prev = $unique_images ;
  }


