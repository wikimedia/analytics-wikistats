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




# taken from tables_gfx branch
my @map=(
    sub{(       255     , (1-$_[0])*255 , 0 )} , #7
    sub{(       255     , 0             , 0 )} , #6
    sub{(       255     , ($_[0])*255   , 0 )} , #5
    sub{( (1-$_[0])*255 , 255           , 0 )} , #4
    sub{(         0     , 255           , 0 )} , #3
    sub{(         0     , (1-$_[0])*255 , 0 )} , #2
    sub{(         0     , 0             , 0 )} , #1
);

sub ramp {
    my( $v, $vmin, $vmax ) = @_;

    ## Peg $v to $vmax if it is greater than $vmax
    $v = $vmax if $v > $vmax;
    ## Or peg $v to $vmin if it is less tahn $vmin.
    $v = $vmin if $v < $vmin;
    ## Normalise $v relative to $vmax - $vmin
    $v = 
    ( $v    - $vmin ) /
    ( $vmax - $vmin ) ;
    ## Scale it to the range 0 .. 1784
    $v *= 1785;

    my @a = 
    map { int($_) } 
    $map[$v/255]->( ($v % 255) / 256 );

    # invert colors
    #@a = map { 255 - $_ } @a;

    return sprintf( ("%02X" x 3) , @a);
};


sub ramp_spectrum {
  my ($start,$end) = @_;
  my @colors = map {  ramp($_,-100,+100)  } ($start..$end);
  {
    colors => \@colors,
    title  => "1785-Color Ramp Spectrum",
    start  => $start,
    end    => $end,
  }
};



1;
