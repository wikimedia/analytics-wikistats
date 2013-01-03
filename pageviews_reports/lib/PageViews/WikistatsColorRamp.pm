package PageViews::WikistatsColorRamp;
use strict;
use warnings;

sub hue2rgb
{
  my ($v1, $v2, $vH) = @_;
  if ($vH < 0) { $vH += 1 ; }
  if ($vH > 1) { $vH -= 1 ; }
  if ((6 * $vH) < 1) { return ($v1 + ( $v2 - $v1 ) * 6 * $vH) ; }
  if ((2 * $vH) < 1) { return ($v2) ; }
  if ((3 * $vH) < 2) { return ($v1 + ( $v2 - $v1 ) * ( ( 2 / 3 ) - $vH ) * 6) ; }
  return ($v1)
}


sub hsl2rgb
{
  my ($h, $s, $l) = @_;
#print "h=$h, s=$s l=$l\n" ;
  my ($r,$g,$b, $var_2 , $var_1);
  if ($s == 0)           # HSL values = 0 ÷ 1
  {
     $r = $l * 255 ;      # RGB results = 0 ÷ 255
     $g = $l * 255 ;
     $b = $l * 255 ;
  }
  else
  {
     if ($l < 0.5)
     { $var_2 = $l * ( 1 + $s ) ; }
     else
     { $var_2 = ( $l + $s ) - ( $s * $l ) }

     $var_1 = 2 * $l - $var_2 ;

     $r = 255 * hue2rgb ($var_1, $var_2, $h + ( 1 / 3 )) ;
     $g = 255 * hue2rgb ($var_1, $var_2, $h) ;
     $b = 255 * hue2rgb ($var_1, $var_2, $h - ( 1 / 3 )) ;
  }
  my $color = "\#" . sprintf ("%02X", $r) . sprintf ("%02X", $g) . sprintf ("%02X", $b) ;
  return ($color) ;
}


sub BgColor
{
  my $colormode   = shift ;
  my $val    = shift ;
  my $column = shift ;
  my $trend ;
  my $color ;
  my $hue ;
  my $sat ;
  my $value ;

  if ($colormode eq 'A')
  {
    $trend  = $val ;
    $trend  =~ s/[\+\%]//g ;
    if (($trend < 0) || ($trend =~ /<\s0/))
    { $color = hsl2rgb (0.4,1,0.65) ; }
    elsif ($trend == 0)
    { $color = hsl2rgb (0.5,1,0.7) ; }
    else
    {
      $trend = log ($trend) / log (2) ;
      $trend = 0.5 + (($trend+1)/16) ; # trend + 1 to keep clear distinctin between 0 and 1
      if ($trend > 1) { $trend = 1 ;}
      $color = hsl2rgb ($trend,1,0.7) ;
    }
  };

  return ($color) ;
}


1;
