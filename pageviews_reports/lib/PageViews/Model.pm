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
  my $time    = $fields[2];
  my $url     = $fields[8];
  my $country = $fields[14];
  return if $country eq "--";

  #warn "[DBG] line = $line";
  #warn "[DBG] country = $country";
  #warn "[DBG] url     = $url    ";
  #warn "[DBG] time    = $time   ";

  my $tp    = Time::Piece->strptime($time,"%Y-%m-%dT%H:%M:%S.000");
  my $ymd = $tp->year."-".$tp->mon; # = ..

  $self->{counts}->{$ymd}->{$country}++;
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



#
# Format data in a nice way so we can pass it to the templating engine
#

sub get_data {
  my ($self) = @_;

  # origins are wikipedia languages present in data
  my $data = [];


  my $languages_present_uniq = {};
  my @months_present = 
    sort 
    { $a cmp $b }  
    keys %{ $self->{counts} };

  my $month_totals    = {};
  my $language_totals = {};

  # mark all languages present in a hash
  # calculate monthly  totals
  # calculate language totals
  for my $month ( @months_present ) {
    for my $language ( keys %{ $self->{counts}->{$month} } ) {
      $languages_present_uniq->{$language} = 1;
      $month_totals->{$month}             += $self->{counts}->{$month}->{$language};
      $language_totals->{$language}       += $self->{counts}->{$month}->{$language};
    };
  };

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
        #warn Dumper($data->[-1]->[$idx_language]);
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

      my $__monthly_delta               = $self->format_percent($monthly_delta);
      my $__percentage_of_monthly_total = "$percentage_of_monthly_total%";
      push @$new_row, {
        monthly_count               => $monthly_count,
        monthly_delta               => $__monthly_delta,
        percentage_of_monthly_total => $__percentage_of_monthly_total,
        place                       => "1st",
        color                       => PageViews::WikistatsColorRamp::BgColor("A",$percentage_of_monthly_total),
      };
    };
    push @$data , $new_row;
  };

  # reverse order of months
  @$data = reverse(@$data);
  # pre-pend headers
  unshift @$data, ['month' , 'total', @sorted_languages_present ];

  return {
    data => $data,
  };
};

1;
