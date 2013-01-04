package PageViews::Generate1;
use strict;
use warnings;
use Data::Dumper;
use Carp;


sub new {
  my ($class,$params) = @_;
  my $raw_obj = {
      config     => $params->{config},
    __DATA_BASE  => $params->{__DATA_BASE},
      LOG_PREFIX => $params->{LOG_PREFIX},
  };
  my $obj = bless $raw_obj,$class;

  return $obj;
};

sub clean_and_init_data_dir {
  my ($self) = @_;
  my $__DATA_BASE = $self->{__DATA_BASE};
  warn "[DBG] $__DATA_BASE";
  system(qq{
    rm -f $__DATA_BASE/*.gz;
    mkdir -p "$__DATA_BASE";
  });
};

sub gzip_generated_files {
  my ($self) = @_;
  my $__DATA_BASE = $self->{__DATA_BASE};

  system(qq{
  cd $__DATA_BASE;
  ls | xargs -I{} gzip {};
  });
};

sub generate {
  my ($self) = @_;

  $self->clean_and_init_data_dir;

  my $config      = $self->{config};
  my $LOG_PREFIX  = $self->{LOG_PREFIX};
  my $__DATA_BASE = $self->{__DATA_BASE};

  my $o = Generate::Squid->new({
      start_date => "2012-10-01"   ,
      prefix     => $LOG_PREFIX    ,
      output_dir => "$__DATA_BASE" ,
    });

  my $previous_month_counts = {};

  for my $month_data ( @$config ) {
    my $month_name = $month_data->{month};
    warn "[DBG] month_name = $month_name";

    $o->generate_line({ geocode=>"--"  });
    $o->__increase_day; 
    
    if( exists $month_data->{explicit_country_counts}) {
      my $hcount = $month_data->{explicit_country_counts};
      warn Dumper $hcount;
      while(my ($country,$count) = each %$hcount ) {
        $o->generate_line({ 
            geocode  => $country 
        }) for 1..$count;
      };
      $previous_month_counts = $hcount;
    } elsif ( exists $month_data->{overall_count_delta} ) {

      my $current_month_counts = { };

      my $mul = 1 + $month_data->{overall_count_delta};

      warn "[DBG] mul=$mul";
      for my $key (keys %$previous_month_counts ) {
        $current_month_counts->{$key} = 
          int( $mul * $previous_month_counts->{$key});
      };

      my $hcount = $current_month_counts;
      warn Dumper $hcount;

      while(my ($country,$count) = each %$hcount ) {
        $o->generate_line({ 
            geocode  => $country 
        }) for 1..$count;
      };
      $previous_month_counts = $hcount;
    } elsif( exists $month_data->{explicit_country_deltas} ) {

      my $current_month_counts = { };

      for my $key (keys %$previous_month_counts ) {
        if(exists $month_data->{explicit_country_deltas}->{$key}) {
          my $mul = 1 + $month_data->{explicit_country_deltas}->{$key};
          $current_month_counts->{$key} = int( $mul * $previous_month_counts->{$key} );
        } else {
          $current_month_counts->{$key} = $previous_month_counts->{$key};
        };
      };

      my $hcount = $current_month_counts;
      warn Dumper $hcount;

      while(my ($country,$count) = each %$hcount ) {
        $o->generate_line({ 
            geocode  => $country 
        }) for 1..$count;
      };
      $previous_month_counts = $hcount;

    } else {
      confess "[ERR] should never get here. You need to configure $month_name to have a count";
    };

    $o->__increase_day; 
    $o->generate_line({ geocode=>"--" });
    $o->dump_to_disk_and_increase_day;
    $o->__increase_month;
    warn "[DBG] time after month increase =>".$o->{current_datetime}; 
  };

  $self->gzip_generated_files;
};




1;
