#!/usr/bin/perl

# small html formatting functions

sub tr      { return "<tr>".&trim(shift)."</tr>\n\n" ; }
sub trc     { return "<tr>".&trim(shift)."</tr>\n" ; } # compact = one line break
sub trh     {
              if ($javascript)
              {
                return "\n<script language='javascript'>\n" .
                       "trc('#ffdead');\n" .
                       "<\/script>\n" .
                       &trim(shift)."</tr>\n\n" ;
              }
              else
              { return "<tr bgcolor=#ffdead>"       .&trim(shift)."</tr>\n\n" ; }
            }
sub trh2    { return "<tr bgcolor=#ffeecc>"         .&trim(shift)."</tr>\n\n" ; }
sub trh2c   { return "<tr bgcolor=#ffeecc class=c>" .&trim(shift)."</tr>\n\n" ; }
sub trh3    { return "<tr bgcolor=#fbfbd8>"         .&trim(shift)."</tr>\n\n" ; }
sub trhb    { return "<tr bgcolor=#ffdead class=cb>".&trim(shift)."</tr>\n\n" ; }
sub trh2b   { return "<tr bgcolor=#ffeecc class=cb>".&trim(shift)."</tr>\n\n" ; }
sub trh3b   { return "<tr bgcolor=#fbfbd8 class=cb>".&trim(shift)."</tr>\n\n" ; }
sub trh4b   { return "<tr bgcolor=#ffffdd class=cb>".&trim(shift)."</tr>\n\n" ; }
sub trh5b   { return "<tr bgcolor=#c0c0c0 class=cb>".&trim(shift)."</tr>\n\n" ; }

sub thrs    { return "<th colspan=" . (shift) . ">".&w(&trim(shift))."</th>" ; }
sub thcxnb  { return "<th class=cnb colspan='" . (shift) . "'>".&trim(shift)."</th>" ; }
sub thlxnb  { return "<th class=lnb colspan='" . (shift) . "'>".&trim(shift)."</th>" ; }
sub thcxb   { return "<th class=cb colspan='" . (shift) . "'>".&trim(shift)."</th>" ; }
sub thlnb   { return "<th class=lnb>"          .&trim(shift)."</th>" ; }
sub thlb    { return "<th class=lb>"           .&trim(shift)."</th>" ; }
sub thlb2   { return "<th class=lb colspan=2>" .&trim(shift)."</th>" ; }
sub thlb4   { return "<th class=lb colspan=4>" .&trim(shift)."</th>" ; }
sub thlb99  { return "<th class=lb colspan=99>" .&trim(shift)."</th>" ; }
sub thcnb   { return "<th class=cnb>"          .&trim(shift)."</th>" ; }
sub thrnb   { return "<th class=rnb>"          .&trim(shift)."</th>" ; }
sub thcb    { return "<th class=cb>"           .&trim(shift)."</th>" ; }
sub thcb2   { return "<th class=cb colspan=2>" .&trim(shift)."</th>" ; }
sub thcb3   { return "<th class=cb colspan=3>" .&trim(shift)."</th>" ; }
sub thcb4   { return "<th class=cb colspan=4>" .&trim(shift)."</th>" ; }
sub thcb5   { return "<th class=cb colspan=5>" .&trim(shift)."</th>" ; }
sub thcb6   { return "<th class=cb colspan=6>" .&trim(shift)."</th>" ; }
sub thcb7   { return "<th class=cb colspan=7>" .&trim(shift)."</th>" ; }
sub thcb8   { return "<th class=cb colspan=8>" .&trim(shift)."</th>" ; }
sub thcb9   { return "<th class=cb colspan=9>" .&trim(shift)."</th>" ; }
sub thcb10  { return "<th class=cb colspan=10>" .&trim(shift)."</th>" ; }
sub thcb11  { return "<th class=cb colspan=11>" .&trim(shift)."</th>" ; }
sub thcbr2  { return "<th class=cb rowspan=2>" .&trim(shift)."</th>" ; }

sub thimg   { return "<th class=img>"           .&trim(shift)."</th>" ; }
sub tdimg   { return "<td class=img>"           .&trim(shift)."</td>" ; }
sub tdimg2  { return "<td class=img rowspan=2>" .&trim(shift)."</td>" ; }
sub tdimg4  { return "<td class=img rowspan=4>" .&trim(shift)."</td>" ; }

sub the     { return "<th class=cb>&nbsp;</th>" ; }

sub tde     { return "<td class=cb>&nbsp;</td>" ; }

sub tdeb    { return "<td class=cb>&nbsp;</td>" ; }
sub tde2    { return "<td rowspan='2'>&nbsp;</td>" ; }
sub tde2b   { return "<td rowspan='2' class=cb>&nbsp;</td>" ; }
sub tde3    { return "<td colspan='3'>&nbsp;</td>" ; }
sub tde3b   { return "<td colspan='3' class=cb>&nbsp;</td>" ; }
sub tder2   { return "<td rowspan='2'>&nbsp;</td>" ; }

sub tdlxnb  { return "<td class=lb colspan='" . (shift) . "'>".&trim(shift)."</td>" ; }
sub tdrxnb  { return "<td class=rnb colspan='" . (shift) . "'>".&trim(shift)."</td>" ; }
sub tdcnb   { return "<td class=cnb>"          .&trim(shift)."</td>" ; }
sub tdlr2   { return "<td class=l rowspan='2' valign='top'>".&w(&trim(shift))."</td>" ; }
sub tdlr2b  { return "<td class=lb rowspan='2' valign='top'>".&w(&trim(shift))."</td>" ; }
sub tdlbrx  { return "<td class=lb rowspan='" . (shift) . "' valign='top'>" . &trim(shift) . "</td>" ; }
sub tdlx    { return "<td class=l colspan='" . (shift) . "'>".&w(&trim(shift))."</td>" ; }
sub tdcxnb  { return "<td class=cb colspan='" . (shift) . "'>".&trim(shift)."</td>" ; }
sub td      { return "<td>".&w(&trim(shift))."</td>" ; }
sub th      { return "<th>".&w(&trim(shift))."</th>" ; }
sub tdr     { return "<td>".&w(&trim(shift))."</td>" ; }
sub tdrb    { return "<td class=rb>".&w(&trim(shift))."</td>" ; }
sub tdrbc   { return "<td class=rb colspan=".(shift).">".&w(&trim(shift))."</td>" ; }
sub tdrs    { return "<td class=sigma>".&w(&trim(shift))."</td>" ; }
sub tdr4    { return "<td colspan='4'>".&w(&trim(shift))."</td>" ; }
sub tdl     { return "<td class=l>".&w(&trim(shift))."</td>" ; }
sub tdlb    { return "<td class=lb>".&w(&trim(shift))."</td>" ; }
sub thrb    { return "<th class=rb>".&w(&trim(shift))."</th>" ; }
sub tdl2    { return "<td class=l colspan='2'>" .&w(&trim(shift))."</td>" ; }
sub tdl2b   { return "<td class=lb colspan='2'>".&w(&trim(shift))."</td>" ; }
sub tdlb2   { return "<td class=l colspan='2'>" .&w(&trim(shift))."</td>" ; }
sub tdlb2b  { return "<td class=lb colspan='2'>".&w(&trim(shift))."</td>" ; }
sub tders   { return "<td rowspan=" . (shift) . ">&nbsp;</td>" ; }
sub tdersb  { return "<td class=cb rowspan=" . (shift) . ">&nbsp;</td>" ; }
sub tdecrsb  { return "<td class=cb colspan=" . (shift) . " rowspan=" . (shift) . ">&nbsp;</td>" ; }
sub tdc     { return "<td class=c>"            .&trim(shift)."</td>" ; }
sub tdcb    { return "<td class=cb>"           .&trim(shift)."</td>" ; }
sub tdcbr2  { return "<td class=cb rowspan='2'>".&trim(shift)."</td>" ; }
sub tdcbt   { return "<td class=cb valign=top>" .&trim(shift)."</td>" ; }
sub tdlbt   { return "<td class=lb valign=top>" .&trim(shift)."</td>" ; }
sub tdcbt2  { return "<td class=cb valign=top colspan='2'>" .&trim(shift)."</td>" ; }
sub tdcbt3  { return "<td class=cb valign=top colspan='3'>" .&trim(shift)."</td>" ; }
sub tdcbt4  { return "<td class=cb valign=top colspan='4'>" .&trim(shift)."</td>" ; }
sub tdc2    { return "<td class=c colspan=2>"  .&trim(shift)."</td>" ; }
sub tdc3    { return "<td class=c colspan=3>"  .&trim(shift)."</td>" ; }
sub tdc4    { return "<td class=c colspan=4>"  .&trim(shift)."</td>" ; }
sub tdc5    { return "<td class=c colspan=5>"  .&trim(shift)."</td>" ; }
sub tdc6    { return "<td class=c colspan=6>"  .&trim(shift)."</td>" ; }
sub tdc7    { return "<td class=c colspan=7>"  .&trim(shift)."</td>" ; }
sub tdc12   { return "<td class=cb colspan=12>".&trim(shift)."</td>" ; }
sub tdc2b   { return "<td class=cb colspan=2>" .&trim(shift)."</td>" ; }
sub tdc3b   { return "<td class=cb colspan=3>" .&trim(shift)."</td>" ; }
sub tdc4b   { return "<td class=cb colspan=4>" .&trim(shift)."</td>" ; }
sub tdc5b   { return "<td class=cb colspan=5>" .&trim(shift)."</td>" ; }
sub tdc6b   { return "<td class=cb colspan=6>" .&trim(shift)."</td>" ; }
sub tdc7b   { return "<td class=cb colspan=7>" .&trim(shift)."</td>" ; }
sub tdc8b   { return "<td class=cb colspan=8>" .&trim(shift)."</td>" ; }
sub tdc12b  { return "<td class=cb colspan=12>".&trim(shift)."</td>" ; }
sub tdc14b  { return "<td class=cb colspan=14>" .&trim(shift)."</td>" ; }
sub tdc99b  { return "<td class=cb colspan=99>".&trim(shift)."</td>" ; }
sub tdca    { return &tdc(&link(shift,shift)) ; }
sub tdcab   { return &tdcb(&link(shift,shift)) ; }
sub tdcr2a  { return "<td class=c valign=top rowspan=2>".&link(&trim(shift),&trim(shift))."</td>" ; }
sub tdcr2   { return "<td class=c colspan=2 rowspan=2 valign='top'>".&trim(shift)."</td>" ; }
#sub tdcr2ab { return "<td class=cb valign=top rowspan=2>".&link(&trim(shift),&trim(shift))."</td>" ; }
sub tdcr2ab { return "<td class=cb valign=top rowspan=2>".&link(&trim(shift),&trim(shift))."</td>" ; }
sub tdcr2b  { return "<td class=cb colspan=2 rowspan=2 valign='top'>".&trim(shift)."</td>" ; }
sub tdct    { return "<td class=c valign=top>".&trim(shift)."</td>" ; }
sub tdctb   { return "<td class=cb valign=top>".&trim(shift)."</td>" ; }
sub tdctr2  { return "<td class=c valign=top rowspan=2>".&trim(shift)."</td>" ; }
sub tdltr2  { return "<td class=l valign=top rowspan=2>".&trim(shift)."</td>" ; }
sub tdctr2b { return "<td class=cb valign=top rowspan=2>".&trim(shift)."</td>" ; }
sub tdltr2b { return "<td class=lb valign=top rowspan=2>".&trim(shift)."</td>" ; }
sub thebl   { return "<th style='border-left: 1px solid #606060'>&nbsp;</th>" ; }
sub thl2nb  { return "<th class=lb colspan=2 style='text-align:left'>".&trim(shift)."</th>" ; }
sub tr_hr   { return "<tr><td class='thin' colspan=999 height=4></td></tr>" ; }
sub tdlmr   { return "<td class=l valign=middle rowspan=".(shift).">".&trim(shift)."</td>" ; }
sub tdrmr   { return "<td class=r valign=middle rowspan=".(shift).">".&trim(shift)."</td>" ; }

sub sign
{
  my $val = shift ;
  my $val2 = $val ;
  $val2 =~ s/<[^\>]*>//g ; # <font ...>
  $val2 =~ s/[^\-\d]//g ;
#    if ($val2 >=75) { $val = "<font color=#808000>$val</font>" }
# elsif ($val2 >=25) { $val = "<font color=#007000>$val</font>" }
#    if ($val2 >=75) { $val = "<font color=#008000>$val</font>" }
# elsif ($val2 >=25) { $val = "<font color=#606000>$val</font>" }

#    if ($val2 >=75) { $val = "<font color=#00A050><u>$val</u></font>" }
# elsif ($val2 >=25) { $val = "<font color=#006000>$val</font>" }
     if ($val2 >=75) { $val = "<font color=#008000><u>$val</u></font>" }
  elsif ($val2 >=25) { $val = "<font color=#008000>$val</font>" }
  elsif ($val2 <  0) { $val = "<font color=#800000>$val</font>" } ;
  return ($val) ;
}

sub link
{
  my $ndx = shift ;
  my $text = shift ;
  if (($mode_wx) || $singlewiki)  # no point to link to 'comparison' reports on wikispecial
  { return ($text) ; }
  my $reportname = $report_names [$ndx] ;
  return "<a href='Tables" . $reportname . ".htm'>" . $text . "</a>" ;
}

sub b # make bold, except for iconic languages (to be generalized)
{
  if (($language eq "ja") || ($language eq "zh"))
  { return &trim(shift) ; }
  else
  {
    my $text = shift ;
    $text =~ s/<p>/<\/b><p><b>/g ;
    $text =~ s/<br>/<\/b><br><b>/g ;
    return "<b>".&trim($text)."</b>" ;
  }
}

sub w # make wider, for table cells (obsolete ?)
{
  my $s = shift ;
  if ($s eq "&nbsp;")
  { return ($s) ; }
  else
  { return (&trim($s)) ; }
# { return ("&nbsp;".&trim($s)."&nbsp;") ; } moved to CSS
}

sub ww # make wider, for table cells (obsolete ?)
{
  my $s = shift ;
  if ($s eq "&nbsp;")
  { return ($s) ; }
  else
  { return ("&nbsp;".&trim($s)."&nbsp;") ; }
}

sub trim
{
  my $s = shift ;
  $s =~ s/^\s+// ;
  $s =~ s/\s+$// ;
  if (($s eq "0") || ($s eq ""))
  { $s = "&nbsp;" ; }
  return ($s) ;
}

# invisible spacers to ensure minimum column width
sub tdcx  { return &tdc ("<font color=#ffeecc>__</font>".(shift).
                         "<font color=#ffeecc>__</font>\n") ; }
sub tdcxb { return &tdcb("<font color=#ffeecc>__</font>".(shift).
                         "<font color=#ffeecc>__</font>\n") ; }

sub btn
{
  return ("&nbsp;<input type='button' " .
          "value='" . (shift) . "' " .
          "onclick=\"gotoPage(\'" . (shift) . "\')\">") ;
}

sub opt
{ return ("<option value='" . (shift) . "'>" . (shift) . "\n") ; }

sub AlignPerLanguage
{
  my $html = shift ;
  if ($mirror)
  {
#   $html =~ s/(<body[^\>]*>)/$1<div dir=rtl align=right>/ ;
#   $html =~ s/(<\/body>)/<\/div>$1/ ;
    $html =~ s/(<html[^>]*)>/$1 dir=rtl>/gi ;
    $html =~ s/class=l/class=x/g ;
    $html =~ s/class=r/class=l/g ;
    $html =~ s/class=x/class=r/g ;
    $html =~ s/class='l'/class='x'/g ;
    $html =~ s/class='r'/class='l'/g ;
    $html =~ s/class='x'/class='r'/g ;
    $html =~ s/align='left'/align=x/g ;
    $html =~ s/align='right'/align='left'/g ;
    $html =~ s/align=x/align='right'/g ;
  }
  return ($html) ;
}

1;
