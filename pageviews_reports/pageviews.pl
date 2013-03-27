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
