#!/usr/bin/perl

  use Getopt::Std ;
  use File::Path ;
  getopt ("iod", \%options) ;

  print "\nScan daily file SquidDataBinaries.csv for -d days and report unique images per day\n\n" ;

  $path_csv_in = $options {'i'} ;
  die "Specify input path (squids csv top folder) as -i [path]" if $path_csv_in eq '' ;
  die "Input path '$path_csv_in' not found (squids csv top folder)" if ! -d $path_csv_in ;

  $path_csv_out = $options {'o'} ;
  die "Specify output path as -o [path]" if $path_csv_out eq '' ;
  if (! -d $path_csv_out)
  {
    mkpath $path_csv_out ;
    die "Path '$path_csv_out' could not be created" if ! -d $path_csv_out ;
  }

  $max_days_ago = $options {'d'} ;
  if ($max_days_ago !~ /^\d+$/)
  {
    $max_days_ago = 10 ;
    print "No number of days specified. Use default: $max_days_ago days\n" ;
  }
  if ($max_days_ago > 365)
  { die "No valid number of days specified: $max_days_ago. Specify -d [days] (max 365)\n" ; }

  $time_start   = time ;

  open CSV_OUT, '>', "$path_csv_out/SquidDataTrendUniqueImages.csv" ;
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

    $file = "$path_csv_in/$yyyy_mm/$yyyy_mm_dd/public/SquidDataBinaries.csv" ;

    if (! -e $file)
    {
      $file_bz2 .= "$file.bz2" ;
      if (! -e $file_bz2)
      {
        print "No file ${file}[.bz2]\n" ;
        next ;
      }
      else
      {
        print "Process $file_bz2\n" ;
        open CSV_IN, "-|", "bzip2 -dc \"$file_bz2\"" || abort ("Input file '$file_bz2' could not be opened.") ;
      }
    }
    else
    {
      print "Process $file\n" ;
      open CSV_IN, '<', $file ;
    }

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


