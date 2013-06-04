#!/usr/bin/env perl
use strict;
use warnings;
use lib "./lib";
use PageViews::Model::Sequential;
use PageViews::Model::Parallel;
use PageViews::Model::JSON;
use PageViews::View::WikiReport;
use PageViews::View::Web;
use PageViews::View::Limn;
use PageViews::View::JSON;
use Time::Piece;
use Data::Dumper;
use JSON::XS;
use Carp;

if(@ARGV < 1) {
  confess "[ERROR] you need to pass a config json as argument";
};

confess "[ERROR] config file does not exist"
  unless -f $ARGV[0];

my $config = decode_json(`cat $ARGV[0]`);

confess "[ERROR] invalid model"
  unless $config->{model} ~~ ["sequential","parallel","json"];

confess "[ERROR] output-formats key must be defined"
  unless defined($config->{"output-formats"});

confess "[ERROR] output-formats must contain at least one format"
  unless @{$config->{"output-formats"}} > 0;

confess "[ERROR] input-path argument is not a valid path"
  unless -d $config->{"input-path"};

confess "[ERROR] max-children argument is not a valid integer"
  unless $config->{"max-children"} =~ /^\d+$/;


if($config->{model} eq "parallel") {
  if(!$config->{"children-output-path"}) {
      confess "[ERROR] model set to parallel but children-output-path not present";
  };
  `
  mkdir -p $config->{"output-path"}/map
  rm    -f $config->{"output-path"}/map/*.json
  rm    -f $config->{"output-path"}/map/*.err
  `
};


`mkdir -p $config->{"output-path"}`;

my $model;
my $view ;

# If the $config->{end}->{custom} is "previous-month"
#
# then identify the get the current time, chop of days until the previous month is reached
#
# and then use that as end month for processing

if(defined($config->{end}->{custom}) && $config->{end}->{custom}eq "previous-month") {
  my $c = localtime;
  my $p = $c;
  while($c->mon == $p->mon){
    $p-=$PageViews::Model::Sequential::ONE_DAY;
  };
  delete $config->{end}->{custom};
  $config->{end}->{year}  = $p->year;
  $config->{end}->{month} = $p->mon;
};


confess "[ERROR] Start date invalid"
  unless $config->{start}->{year}  =~ /\d+/ &&
         $config->{start}->{month} =~ /\d+/ && 
        ($config->{start}->{month} >= 1 && $config->{start}->{month} <= 12)
        ;

confess "[ERROR] End date invalid"
  unless  $config->{end}->{year}  =~ /\d+/ &&
          $config->{end}->{month} =~ /\d+/ &&
         ($config->{end}->{month} >= 1 &&  $config->{end}->{month} <= 12)
         ;


if(     $config->{model} eq "sequential") {
  $model = PageViews::Model::Sequential->new();
} elsif($config->{model} eq "parallel") {
  $model = PageViews::Model::Parallel->new();
} elsif($config->{model} eq "json") {
  $model = PageViews::Model::JSON->new();
};

$model->process_files($config);

for my $format ( @{ $config->{"output-formats"} }) {

  if(      $format eq "web") {
    $view = PageViews::View::Web->new();
    $view->get_data_from_model($model);
    $view->render($config);
  } elsif( $format eq "wikireport") {
    $view = PageViews::View::WikiReport->new();
    $view->get_data_from_model($model);
    $view->render($config);
  } elsif( $format eq "limn") {
    $view = PageViews::View::Limn->new();
  } elsif( $format eq "json") {
    $view = PageViews::View::JSON->new();
    $view->get_data_from_model($model);
    $view->render($config);
  } else {
    confess "[ERROR] Something's wrong";
  };

};
