package PageViews::Model;
use strict;
use warnings;
use Time::Piece;
use Data::Dumper;
use PageViews::WikistatsColorRamp;
sub new {
  my ($class) = @_;
  my $raw_obj = {
    counts => {},
  };
  my $obj     = bless $raw_obj,$class;
  return $obj;
};

sub process_line {
  my ($self,$line) = @_;
  my @fields = split(/\s/,$line);
  #use Data::Dumper;
  #warn Dumper \@fields;
  my $time     = $fields[2];
  my $url      = $fields[8];
  my $language ;

  # ignore lines which are not mobile and don't have a language in there
  if( !(  ($language) = $url =~ m|^http://(.+)\.m\.wikipedia\.|  )) {
    return;
  };

  #warn "[DBG] line = $line";
  #warn "[DBG] country = $country";
  #warn "[DBG] url     = $url    ";
  #warn "[DBG] time    = $time   ";

  my $tp    = Time::Piece->strptime($time,"%Y-%m-%dT%H:%M:%S.000");
  my $ymd = $tp->year."-".$tp->mon; # = ..

  $self->{counts}->{$ymd}->{$language}++;
};

sub process_file {
  my ($self,$filename) = @_;
  open IN, "-|", "gzip -dc $filename";
  while( my $line = <IN>) {
    $self->process_line($line);
  };
};

sub process_files  {
  my ($self, $params) = @_;
  for my $gz_logfile (split(/\n/,`ls $params->{logs_path}/*.gz`) ) {
    $self->process_file($gz_logfile);
  };
};


# safe division, truncate to 2 decimals
sub safe_division {
  my ($self,$numerator,$denominator) = @_;
  my $retval;

  if(defined($numerator) && defined($denominator)) {
    $retval = 
      $denominator 
        ? sprintf("%.2f",($numerator / $denominator)*100)
        : "--";
  } else {
    $retval = "--";
  };

  return $retval;
};


sub format_percent {
  my ($self,$val) = @_;
  if($val ne "--") {
    my $sign;
    if(       $val > 0) {
      $sign = "+";
    } else {
      $sign = "";
    };
    $val = "$sign$val%";
  };

  return $val;
};

sub format_rank {
  my ($self,$rank) = @_;
  if(     $rank == 1) {
    $rank  = "1st";
  } elsif($rank == 2) {
    $rank  = "2nd";
  } elsif($rank == 3) {
    $rank  = "3rd";
  } else {
    $rank .= "th";
  };
  return $rank;
};



sub first_pass_languages_totals_rankings {
  my ($self) = @_;


  my @months_present = 
    sort 
    { $a cmp $b }  
    keys %{ $self->{counts} };

  my $languages_present_uniq = {};
  my $month_totals           = {};
  my $month_rankings         = {};
  my $language_totals        = {};
  my $chart_data             = {};

  # mark all languages present in a hash
  # calculate monthly  totals
  # calculate monthly  rankings
  # calculate language totals
  for my $month ( @months_present ) {
    # languages sorted for this month
    my $sorted_languages = [];

    for my $language ( keys %{ $self->{counts}->{$month} } ) {
      $languages_present_uniq->{$language} = 1;

      $chart_data->{$language}->{counts} //= [];
      $chart_data->{$language}->{months} //= [];
      push @{ $chart_data->{$language}->{counts} } , $self->{counts}->{$month}->{$language};
      push @{ $chart_data->{$language}->{months} } , $month;


      $month_totals->{$month}              += $self->{counts}->{$month}->{$language}  ;
      $language_totals->{$language}        += $self->{counts}->{$month}->{$language}  ;
      push @$sorted_languages , [ $language , $self->{counts}->{$month}->{$language} ];
    };

    # compute rankings and store them in $month_rankings
    my $rankings = {};
    @$sorted_languages = sort { $b->[1] <=> $a->[1]  } @$sorted_languages;
    $rankings->{$sorted_languages->[$_]->[0]} = 1+$_
      for 0..(-1+@$sorted_languages);
    
    $month_rankings->{$month} = $rankings;
  };

  return {
    months_present          => \@months_present       ,
    languages_present_uniq  => $languages_present_uniq,
    month_totals            => $month_totals          ,
    month_rankings          => $month_rankings        ,
    language_totals         => $language_totals       ,
    chart_data              => $chart_data            ,
  };
};



#
# Format data in a nice way so we can pass it to the templating engine
#

sub get_data {
  my ($self) = @_;

  # origins are wikipedia languages present in data
  my $data = [];

  my $__first_pass_retval = $self->first_pass_languages_totals_rankings;

  my @months_present         = @{ $__first_pass_retval->{months_present} };
  my $languages_present_uniq =    $__first_pass_retval->{languages_present_uniq};
  my $month_totals           =    $__first_pass_retval->{month_totals};
  my $month_rankings         =    $__first_pass_retval->{month_rankings};
  my $language_totals        =    $__first_pass_retval->{language_totals};
  my $chart_data             =    $__first_pass_retval->{chart_data};

  my $min_language_delta = +999_999;
  my $max_language_delta = -999_999;

  # TODO: call function here to produce the many hashes

  my @unsorted_languages_present = keys %$languages_present_uniq;

  # the first columns of @{$data->[]} are not going to be for languages, they're gonna
  # be some other stuff like month name or monthly total
  my $LANGUAGES_COLUMNS_SHIFT = 2;
  # sort the order in which language columns are presented
  # based on the totals they have overall
  my @sorted_languages_present = 
    sort { $language_totals->{$b} <=> $language_totals->{$a} }
    @unsorted_languages_present;

  for my $month ( @months_present ) {
    my   $new_row = [];
    push @$new_row, $month;
    push @$new_row, $month_totals->{$month};

    # idx_language is the index of the current language inside sorted_languages_present
    for my $idx_language ( 0..$#sorted_languages_present ) {
      my $language = $sorted_languages_present[$idx_language];
      # hash containing actual count, percentage of monthly total, increase over past month
      my $percentage_of_monthly_total ;
      my $monthly_delta               ;
      my $monthly_count               ;
      my $monthly_count_previous      ;

      if(@$data > 0) {
        warn "[DBG] idx_language = $idx_language";
        warn Dumper $data->[-1];
        $monthly_count_previous = $data->[-1]->[$idx_language + $LANGUAGES_COLUMNS_SHIFT]->{monthly_count} // 0;
      } else {
        $monthly_count_previous = 0;
      };
      $monthly_count               = $self->{counts}->{$month}->{$language} // 0;
      $percentage_of_monthly_total = $self->safe_division($monthly_count , $month_totals->{$month});

      # safety check
      # if we have at least one month to compare to
      # and the previous month has a non-zero count

      warn "[DBG] monthly_count_previous = $monthly_count_previous";
      $monthly_delta               = $self->safe_division(
                                        $monthly_count - $monthly_count_previous,
                                        $monthly_count_previous 
                                     );

      $min_language_delta = 
            $monthly_delta <= $min_language_delta 
             ? $monthly_delta 
             : $min_language_delta;

      $max_language_delta = 
            $monthly_delta >= $max_language_delta 
             ? $monthly_delta 
             : $max_language_delta;

      my $__monthly_delta               = $self->format_percent($monthly_delta);
      my $__percentage_of_monthly_total = "$percentage_of_monthly_total%";
      my $rank                          = $self->format_rank( $month_rankings->{$month}->{$language} );
      push @$new_row, {
          monthly_count                 =>   $monthly_count,
          monthly_delta__               => $__monthly_delta,
          monthly_delta                 =>  ($monthly_delta eq '--' ? 0 : $monthly_delta),
          percentage_of_monthly_total__ => $__percentage_of_monthly_total,
          rank                          =>   $rank,
      };
    };
    push @$data , $new_row;
  };

  # reverse order of months
  @$data = reverse(@$data);
  # pre-pend headers
  unshift @$data, ['' , '&Sigma;', @sorted_languages_present ];

  return {
    # actual data for each language for each month
    data               => $data,
    chart_data         => $chart_data,
    # the following values are used by the color ramps
    min_language_delta => $min_language_delta,
    mid_language_delta => ($min_language_delta + $max_language_delta)/2,
    max_language_delta => $max_language_delta,
    # debug data
    dbg_ramp           => PageViews::WikistatsColorRamp::ramp_spectrum(-110,99),
  };
};

1;
