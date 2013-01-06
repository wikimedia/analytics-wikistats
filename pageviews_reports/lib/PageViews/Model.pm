package PageViews::Model;
use strict;
use warnings;
use Time::Piece;
use File::Basename;
use Data::Dumper;
use PageViews::WikistatsColorRamp;

our $ENTIRE_DAY    = 24 * 3600;
our $SAMPLE_FACTOR = 1000;

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

  # just get languages with at most 8 chars and only small chars
  # (TODO: need to find out what the actual restrictions are here)
  my $re_valid_language = "([a-z\-]{1,8})";


  # ignore lines which are not mobile and don't have a language in there
  return if( !(  ($language) = $url =~ m|^https?://$re_valid_language\.m\.wikipedia|  ));

  #discard anything else out of time field (we also have milliseconds here and we don't need that
  #because strptime can't parse it).
  $time =~ s/^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}).*$/$1/;
  my $tp    = Time::Piece->strptime($time,"%Y-%m-%dT%H:%M:%S");
  return if( !($tp >= $self->{tp_start} && $tp <  $self->{tp_end}) );

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

# adds zero padding for a 2 digit number
sub padding_2 { 
    $_[0]<10 ? "0$_[0]" : $_[0];
};

sub get_files_in_interval {
  my ($self,$params) = @_;
  my @retval = ();
  my $squid_logs_path   = $params->{logs_path};
  my $squid_logs_prefix = $params->{logs_prefix};

  $params->{start}->{month} = padding_2($params->{start}->{month});
  $params->{end}->{month}   = padding_2($params->{end}->{month});

  my $tp_start = Time::Piece->strptime(
                   sprintf("%s-%s-01T00:00:00",$params->{start}->{year},$params->{start}->{month}),
                   "%Y-%m-%dT%H:%M:%S"
                 );

  my $tp_end   = Time::Piece->strptime(
                   sprintf("%s-%s-01T00:00:00",$params->{end}->{year},$params->{end}->{month}),
                   "%Y-%m-%dT%H:%M:%S"
                 );
  # get the first day of the next month because that's where the data
  # will end
  while($tp_end->mon == $params->{end}->{month}) {
    $tp_end += $ENTIRE_DAY;
  };

  $self->{tp_start} = $tp_start;
  $self->{tp_end}   = $tp_end;

  my @all_squid_files = sort { $a cmp $b } <$squid_logs_path/$squid_logs_prefix*.gz>;
  for my $log_filename (@all_squid_files) {
    if(my ($y,$m,$d) = $log_filename =~ /(\d{4})(\d{2})(\d{2})\.gz$/) {
      my $tp_log = Time::Piece->strptime("$y-$m-$d","%Y-%m-%d");

      if( $tp_log >= $tp_start && 
          $tp_log <  $tp_end) {
        push @retval,$log_filename;
      };
    };
  };

  #warn Dumper \@retval;
  #exit 0;
  return @retval;
};

sub process_files  {
  my ($self, $params) = @_;
  for my $gz_logfile ($self->get_files_in_interval($params)) {
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


sub _simulate_big_numbers {
  my ($self) = @_;
  for my $month ( keys %{$self->{counts}} ) {
    for my $language ( keys %{ $self->{counts}->{$month} } ) {
      #$self->{counts}->{$month}->{$language} *= 1000;
      if($self->{counts}->{$month}->{$language} <= 300) {
         $self->{counts}->{$month}->{$language} *= 100;
      } else {
         $self->{counts}->{$month}->{$language} *= 1000;
      };
    };
  };
};

# gets languages sorted by absolute total
#
sub get_totals_sorted_months_present_in_data {
  my ($self,$languages_present_uniq,$language_totals) = @_;
  my @unsorted_languages_present = keys %$languages_present_uniq;
  my @sorted_languages_present = 
    sort { $language_totals->{$b} <=> $language_totals->{$a} }
    @unsorted_languages_present;

  return @sorted_languages_present;
};

# gets temporaly sorted months present in data
# 
sub get_time_sorted_months_present_in_data {
  my ($self) = @_;
  my @retval =
    sort 
      { 
        my ($Y_a,$m_a) = $a =~ /^(\d+)-(\d+)$/;
        my ($Y_b,$m_b) = $b =~ /^(\d+)-(\d+)$/;
        
        $Y_a <=> $Y_b ||
        $m_a <=> $m_b  ;
      }  
        keys %{ $self->{counts} };

  #warn Dumper \@retval;
  return @retval;
};



sub first_pass_languages_totals_rankings {
  my ($self) = @_;

  my @months_present = $self->get_time_sorted_months_present_in_data;

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
    my $month_languages_sorted = [];

    for my $language ( keys %{ $self->{counts}->{$month} } ) {
      $languages_present_uniq->{$language} = 1;

      $chart_data->{$language}->{counts} //= [];
      $chart_data->{$language}->{months} //= [];
      push @{ $chart_data->{$language}->{counts} } , $self->{counts}->{$month}->{$language};
      push @{ $chart_data->{$language}->{months} } , $month;


      $month_totals->{$month}              += $self->{counts}->{$month}->{$language}  ;
      $language_totals->{$language}        += $self->{counts}->{$month}->{$language}  ;
      push @$month_languages_sorted 
                              , [ $language , $self->{counts}->{$month}->{$language} ];
    };

    # compute rankings and store them in $month_rankings
    my $rankings = {};
    @$month_languages_sorted = sort { $b->[1] <=> $a->[1]  } @$month_languages_sorted;
    $rankings->{$month_languages_sorted->[$_]->[0]} = 1+$_
      for 0..(-1+@$month_languages_sorted);
    
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

  $self->_simulate_big_numbers();

  my $__first_pass_retval    = $self->first_pass_languages_totals_rankings;

  my @months_present         = @{ $__first_pass_retval->{months_present} };
  my $languages_present_uniq =    $__first_pass_retval->{languages_present_uniq};
  my $month_totals           =    $__first_pass_retval->{month_totals};
  my $month_rankings         =    $__first_pass_retval->{month_rankings};
  my $language_totals        =    $__first_pass_retval->{language_totals};
  my $chart_data             =    $__first_pass_retval->{chart_data};

  my $min_language_delta = +999_999;
  my $max_language_delta = -999_999;

  # TODO: call function here to produce the many hashes

  my $LANGUAGES_COLUMNS_SHIFT = 2;

  my @sorted_languages_present = 
    $self->get_totals_sorted_months_present_in_data(
      $languages_present_uniq,
      $language_totals
    );

  for my $month ( @months_present ) {

    warn "[DBG] Processing month => $month";
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
        #warn Dumper $data->[-1];
        $monthly_count_previous = $data->[-1]->[$idx_language + $LANGUAGES_COLUMNS_SHIFT]->{monthly_count} // 0;
      } else {
        $monthly_count_previous = 0;
      };
      $monthly_count               = $self->{counts}->{$month}->{$language} // 0;
      $percentage_of_monthly_total = $self->safe_division($monthly_count , $month_totals->{$month});

      # safety check
      # if we have at least one month to compare to
      # and the previous month has a non-zero count

      #warn "[DBG] monthly_count_previous = $monthly_count_previous";
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

      my $__monthly_delta               =  $self->format_percent($monthly_delta);
      my $rank                          =  $self->format_rank( $month_rankings->{$month}->{$language} );
      my $__percentage_of_monthly_total = "$percentage_of_monthly_total%";


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

  #exit -1;

  # reverse order of months
  @$data = reverse(@$data);

  # pre-pend headers
  unshift @$data, ['' , '&Sigma;', @sorted_languages_present ];

  warn "[DBG] data.length = ".~~(@$data);

  return {
    # actual data for each language for each month
    data               => $data,
    chart_data         => $chart_data,
    # the following values are used by the color ramps
    min_language_delta => $min_language_delta,
    mid_language_delta => ($min_language_delta + $max_language_delta)/2,
    max_language_delta => $max_language_delta,
    language_totals    => $language_totals,
  };
};

1;
