#!/usr/bin/perl

  open IN, '<', "WLM_images_by_country_by_year_uploads.txt" ;

  while ($line = <IN>)
  {
  next if $line =~ /^#/ ;
# print $line ;
  ($year,$lang) = split (',', $line) ;
  next if $year != 2014 ;

  $line =~ s/^.*?",20/20/ ;
  $line =~ s/Z,.*// ;
  $date = substr ($line,0,10) ;

  $uploads_date {$date} ++ ;
  $uploads_lang_date {"$lang,$date"} ++ ;
  $langs {$lang}++ ;
# print "$line\n" ;
# exit if $lines++ > 10 ;
  }


  open OUT, '>', "WLM_images_by_country_by_year_uploads_per_day.csv" ;
  print OUT "date,total," ;
  foreach $lang (sort keys %langs)
  { print OUT "$lang," ; }
  print OUT "\n" ;

  foreach $date (sort keys %uploads_date)
  {
    print OUT "$date," . $uploads_date {$date} . ',' ;
    foreach $lang (sort keys %langs)
    { print OUT (0+$uploads_lang_date {"$lang,$date"}) . ',' ; }
    print OUT "\n" ;
  }
