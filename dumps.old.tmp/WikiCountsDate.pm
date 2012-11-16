#!/usr/bin/perl

sub GetDateTime
{
  my $time = shift ;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
  my $timestamp = sprintf ("%2d:%02d ", $hour, $min) . &GetDateEnglish ($time) ;
  $timestamp =~ s/\&nbsp\;/ /g ;
  return ($timestamp) ;
}

sub GetDate
{
  my $time = shift ;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);

  my @weekdays_en = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);

  my @months_en   = qw (January February March April May June July
                        August September October November December);

  my @weekdays_nl = qw(zondag maandag dinsdag woensdag donderdag vrijdag zaterdag) ;

  my @months_nl   = qw (januari februari maart april mei juni juli
                        augustus september oktober november december) ;

  my @weekdays_de = qw (Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag);

  my @months_de   = qw (Januar Februar M&auml;rz April Mai Juni Juli
                        August September Oktober November Dezember);

  my @weekdays_fr = qw (dimanche lundi mardi mercredi jeudi vendredi samedi);

  my @months_fr   = qw (janvier f&eacute;vrier mars avril mai juin juillet
                        ao&ucirc;t septembre octobre novembre d&eacute;cembre );

  my @weekdays_eo = qw (dimancxo lundo mardo merkredo jxaudo vendredo sabato);

  my @months_eo   = qw (januaro februaro marto aprilo majo junio julio
                        auxgusto septembro oktobro novembro decembro);

  if ($language eq "nl")
  { return ($weekdays_nl[$wday] . " " . $mday . " " . $months_nl[$mon] . " " . (1900 + $year)) ; }

  elsif ($language eq "de")
  { return ($weekdays_de[$wday] . " " . $mday . " " . $months_de[$mon] . " " . (1900 + $year)) ; }

  elsif ($language eq "fr")
  { return ($weekdays_fr[$wday] . " " . $mday . ", " . $months_fr[$mon] . " " . (1900 + $year)) ; }

  elsif ($language eq "eo")
  { return ($weekdays_eo[$wday] . " " . $mday . " " . $months_eo[$mon] . " " . (1900 + $year)) ; }

  else
  { return ($weekdays_en[$wday] . ", " . $months_en[$mon] . " " .  $mday . ", " . (1900 + $year)) ; }
}

sub GetDateEnglish
{
  my $time = shift ;
  $language_prev = $language ;
  $language = "en" ;
  my $date = &GetDate ($time) ;
  $language = $language_prev ;
  return ($date) ;
}

sub GetDateTimeEnglishShort
{
  my @weekdays_en = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
  my @months_en   = qw (January February March April May June July
                        August September October November December);
  my $time = shift ;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
  return (substr ($weekdays_en[$wday],0,3) . ", " .
          substr ($months_en[$mon],0,3) . " " .
          $mday . ", " .
          (1900 + $year) .
          " " . sprintf ("%2d:%02d", $hour, $min)) ;
}

sub GetDateTimeEnglishShorter
{
  my @weekdays_en = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
  my $time = shift ;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
  return (substr ($weekdays_en[$wday],0,3) . "-" .
          sprintf ("%02d\/%02d\/%04d", $mday, $mon+1, (1900 + $year)) .
          "-" . sprintf ("%02d:%02d", $hour, $min)) ;
}

1;
