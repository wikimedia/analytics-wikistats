#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
use lib "../squids/t/";
use PageViews::Model;
use PageViews::View;
use Generate::Squid;
use CommonConfig;
use Data::Dumper;
use Carp;

our $__CODE_BASE;
our $__DATA_BASE  = "$__CODE_BASE/../pageviews_reports/data";
my $LOG_PREFIX    = "sampled-1000.log-";

my @country_codes = qw/US GB CA FR DE/;


# overall_count_delta is the percentage by which counts increased/decreased
# over the previous month
my $config = [
  {
    month => "2012-10",
    explicit_country_counts => {
      "US" => 500,
      "GB" => 300 ,
      "CA" => 300 ,
      "FR" => 200 ,
      "DE" => 190 ,
    },
  },
  {
    month => "2012-11",
    overall_count_delta => 0.24,
  },
  {
    month => "2012-12",
    overall_count_delta => 0.30,
  },
  {
    month => "2013-01",
    overall_count_delta => -0.1,
  },
];

{ # Generate a test log file
  `
  rm -f $__DATA_BASE/*.gz;
  mkdir -p $__DATA_BASE;
  `;
  my $o = Generate::Squid->new({
      start_date => "2012-10-01"         ,
      prefix     => $LOG_PREFIX  ,
      output_dir => "$__DATA_BASE",
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
      for my $key (keys %$previous_month_counts ) {
        $current_month_counts->{$key} = 
          int( $mul * $previous_month_counts->{$key});
      };


      my $hcount = $current_month_counts;
      use Data::Dumper;
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

  system(qq{
  cd $__DATA_BASE;
  ls | xargs -I{} gzip {};
  });
};

my $m = PageViews::Model->new();
$m->process_files({
    logs_path => $__DATA_BASE,
});
my $d = $m->get_data();
warn "[DBG]".Dumper($d);
my $v = PageViews::View->new($d);

$v->render({ output_path => "/tmp/pageview_reports/" });

