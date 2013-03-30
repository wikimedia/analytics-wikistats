package PageViews::View::Web;
use strict;
use warnings;
use PageViews::Util;
use Template;
use List::Util qw/sum max/;
use Carp;


{
  no strict  'refs';
  *{__PACKAGE__."::how_many_days_month_has"} = \&PageViews::Util::how_many_days_month_has;
  *{__PACKAGE__."::compact_days_to_months" } = \&PageViews::Util::compact_days_to_months ;
  use strict 'refs';
};

sub new {
  my ($class) = @_;
  my $raw_obj = {};
  my $obj     = bless $raw_obj,$class;
  return $obj;
};

# safe division, truncate to 2 decimals
sub safe_division {
  my ($self,$numerator,$denominator) = @_;
  my $retval;

  if(defined($numerator) && defined($denominator)) {
    my $percent;
    if($denominator == 0) {
      if($numerator == 0) {
        $percent = 0;
      } else {
        $percent = 100;
      };
    } else {
      $percent = ($numerator / $denominator) * 100;
    };

    $retval = sprintf("%.2f", $percent);
  } else {
    $retval = 0;
  };

  return $retval;
};


sub format_delta {
  my ($self,$val) = @_;

  if(defined($val)) {
    my $sign;
    if(        $val > 0) {
      $sign = "+";
      $val = "$sign$val%";
    } elsif(   $val < 0) {
      $val = "$val%";
    };
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



sub third_pass_chart_data {
  my ($self,$languages,$months) = @_;

  my $chart_data             = {};
  for my $month ( @$months ) {
    for my $language ( keys %$languages ) {
      $chart_data->{$language}->{counts} //= [];
      $chart_data->{$language}->{months} //= [];
      push @{ $chart_data->{$language}->{counts} } , ($self->{counts}->{$month}->{$language} // 0);
      push @{ $chart_data->{$language}->{months} } , $month;
    };
  };

  return $chart_data;

};



sub first_pass_languages_totals {
  my ($self) = @_;

  my @months_present = $self->get_time_sorted_months_present_in_data;

  my $languages_present_uniq = {};
  my $month_totals           = {};
  my $month_rankings         = {};
  my $language_totals        = {};

  # mark all languages present in a hash
  # calculate monthly  totals
  # calculate monthly  rankings
  # calculate language totals
  for my $month ( @months_present ) {
    # languages sorted for this month

    for my $language ( keys %{ $self->{counts}->{$month} } ) {
      $languages_present_uniq->{$language}  = 1;
      $month_totals->{$month}              += $self->{counts}->{$month}->{$language}  ;
      $language_totals->{$language}        += $self->{counts}->{$month}->{$language}  ;
    };

  };

  return {
    months_present          => \@months_present       ,
    languages_present_uniq  => $languages_present_uniq,
    month_totals            => $month_totals          ,
    month_rankings          => $month_rankings        ,
    language_totals         => $language_totals       ,
  };
};

sub second_pass_rankings {
  my ($self,$languages,$months) = @_;

  my $month_rankings = {};
  for my $month ( @$months ) {
    # compute rankings and store them in $month_rankings
    my $rankings = {};

    my $month_languages_sorted = [];

    for my $language ( keys %$languages ) {
       push @$month_languages_sorted, 
              [ $language, ($self->{counts}->{$month}->{$language} // 0) ];
    };

    @$month_languages_sorted = 
      sort { $b->[1] <=> $a->[1]  } 
      @$month_languages_sorted;

    $rankings->{$month_languages_sorted->[$_]->[0]} = 1+$_
      for 0..(-1+@$month_languages_sorted);

    $month_rankings->{$month} = $rankings;
  };
  return $month_rankings;
};

sub scale_m_to_30 {
  my ($self,$month,$value) = @_;
  my $SCALE_FACTOR = 30;
  my $days_month_has = how_many_days_month_has(split(/-/,$month));
  my $scaled_value = int( ($value / $days_month_has) * $SCALE_FACTOR );
  return $scaled_value;
};

sub scale_months_to_30 {
  my ($self) = @_;

  my @to_scale1 = qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
  /;

  my @to_scale2 = qw/
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_referer     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
  /;

  my $scaled = {};

  # take all monthly language counts, add them up
  for my $month ( keys %{ $self->{counts} } ) {
    # initialized scale hash for this month
    for my $property ( @to_scale1, @to_scale2 ) {
      if($property ~~ @to_scale1) {
        $scaled->{$property}->{$month} //= {};
        for my $language ( keys %{ $self->{counts}->{$month} } ) {
          $self->{$property}->{$month}->{$language} //= 0;
          my $month_language_value = $self->{$property}->{$month}->{$language};
          $scaled->{$property}->{$month}->{$language} = $self->scale_m_to_30($month,$month_language_value);
        };
      } elsif($property ~~ @to_scale2) {
        $scaled->{$property}->{$month} //= 0;
        my $month_value = $self->{$property}->{$month} // 0;
        $scaled->{$property}->{$month} = $self->scale_m_to_30($month,$month_value);
      };
    };
  };

  # place scaled property hashes back into the current object

  for my $property ( @to_scale1, @to_scale2 ) {
    $self->{$property} = $scaled->{$property};
  };
};





#
# Format data in a nice way so we can pass it to the templating engine
# (for PageViews::View::Web
#

sub get_data_for_template {
  my ($self) = @_;

  $self->compact_days_to_months;
  $self->scale_months_to_30;

  my $data = [];

  #$self->_simulate_big_numbers();

  my $__first_pass_retval    = $self->first_pass_languages_totals;

  my @months_present         = @{ $__first_pass_retval->{months_present} };
  my $languages_present_uniq =    $__first_pass_retval->{languages_present_uniq};
  my $month_totals           =    $__first_pass_retval->{month_totals};
  my $language_totals        =    $__first_pass_retval->{language_totals};

  my $month_rankings         = $self->second_pass_rankings(  $languages_present_uniq , \@months_present );
  my $chart_data             = $self->third_pass_chart_data( $languages_present_uniq , \@months_present );

  my $min_language_delta = +999_999;
  my $max_language_delta = -999_999;

  # TODO: call function here to produce the many hashes

  my $LANGUAGES_COLUMNS_SHIFT = 2;

  my @sorted_languages_present = 
    $self->get_totals_sorted_months_present_in_data(
      $languages_present_uniq,
      $language_totals
    );

  for my $idx_month ( 0..$#months_present ) {
    my $month = $months_present[$idx_month];

    warn "[DBG] Processing month => $month";
    my   $new_row = [];
    push @$new_row, $month;
    push @$new_row, $month_totals->{$month};

    # idx_language is the index of the current language inside sorted_languages_present
    for my $idx_language ( 0..$#sorted_languages_present ) {
      my $language = $sorted_languages_present[$idx_language];
      #warn "language=$language";
      # hash containing actual count, percentage of monthly total, increase over past month
      my $percentage_of_monthly_total ;
      my $monthly_delta               ;
      my $monthly_count               ;
      my $monthly_count_previous      ;

      if(@$data > 0) {
        #warn "[DBG] idx_language = $idx_language";
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
                                        ($monthly_count_previous // 0) 
                                     );

      $min_language_delta = 
            $monthly_delta <= $min_language_delta 
             ? $monthly_delta 
             : $min_language_delta;

      $max_language_delta = 
            $monthly_delta >= $max_language_delta 
             ? $monthly_delta 
             : $max_language_delta;



      my $__monthly_delta               =  $self->format_delta($monthly_delta);
      my $rank                          =  $self->format_rank($month_rankings->{$month}->{$language} );
      my $__percentage_of_monthly_total = "$percentage_of_monthly_total%";


      push @$new_row, {
          language                      =>   $language,
          monthly_count                 =>   $monthly_count,

          breakdown_count_wiki_basic    =>   ($self->{counts_wiki_basic}->{$month}->{$language} // 0),
          breakdown_count_wiki_index    =>   ($self->{counts_wiki_index}->{$month}->{$language} // 0),
          breakdown_count_api           =>   ($self->{counts_api}->{ $month}->{$language}       // 0),

          monthly_count_wiki            =>   ( 
                                               ($self->{counts_wiki_basic}->{$month}->{$language} // 0) + 
                                               ($self->{counts_wiki_index}->{$month}->{$language} // 0)
                                             ),
          monthly_count_api             =>   ($self->{counts_api}->{ $month}->{$language} // 0),
          monthly_delta__               =>   ($idx_month == 0 ? "--" : $__monthly_delta),
          monthly_delta                 =>   ($idx_month == 0 ? 0 : $monthly_delta ),
          percentage_of_monthly_total__ =>   $__percentage_of_monthly_total,
          rank                          =>     $rank,
      };
    };
    push @$data , $new_row;
  };

  #exit -1;

  # reverse order of months
  @$data = reverse(@$data);

  # pre-pend headers
  unshift @$data, ['month' , '&Sigma;', @sorted_languages_present ];

  warn "[DBG] data.length = ".~~(@$data);
  my $big_total_processed = sum( values %$language_totals                  ) // 0;
  my $big_total_discarded = sum( values %{$self->{monthly_discarded_count}}) // 0;
  my $big_total_bots      = sum( values %{$self->{monthly_bots_count}}     ) // 0;

  my $retval = {
    # actual data for each language for each month
    data                     => $data                            ,
    # the chart data for each wikiproject
    chart_data               => $chart_data                      ,
    # the following values are used by the color ramps
    min_language_delta       => $min_language_delta              ,
    max_language_delta       => $max_language_delta              ,
    months_present           => \@months_present                 ,
    languages_present        => [ keys %$languages_present_uniq ],
    language_totals          => $language_totals                 ,
    big_total_processed      => $big_total_processed             ,
    big_total_discarded      => $big_total_discarded             ,
    big_total_bots           => $big_total_bots                  ,
  };

  $retval->{$_} = $self->{$_}
    for qw/
    counts_wiki_basic
    counts_wiki_index
    counts_api
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_referer     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
    /;

  return $retval;
};


sub get_data_from_model {
  my ($self,$model) = @_;

  $self->{$_} = $model->{$_}
  for 
    qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_referer     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
    /;

};

sub render {
  my ($self,$params) = @_;

  my $data = $self->get_data_for_template();

  confess "[ERR] expected param output-path"
    unless exists $params->{"output-path"};
  confess "[ERR] output-path doesn't exist on disk"
    unless     -d $params->{"output-path"};

  my $output_path = $params->{"output-path"};

  `mkdir -p $output_path`;
  my $tt = Template->new({
      INCLUDE_PATH => "./templates",
      OUTPUT_PATH  => $output_path,
      DEBUG        => 1,
  }); 
  $tt->process(
    "pageviews.tt",
    $data,
    "pageviews.html",
  ) || confess $tt->error();

  `cp -r static/ $output_path`;

};

1;
