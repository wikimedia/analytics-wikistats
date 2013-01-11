package PageViews::ParallelModel;
use base 'PageViews::Model';
use JSON::XS;
use File::Basename;

# add up all the counts from the workers
sub reduce {
  my ($self,$json_path) = @_;
  warn "DOING REDUCE";

  my $reduced_monthly_bots_count      = {};
  my $reduced_monthly_discarded_count = {};
  my $reduced_counts                  = {};

  # iterate over all children
  for my $child_output (<$json_path/*.json>) {
    my $c = decode_json(`cat $child_output`);
    # take all bot counts, add them up
    for my $month ( keys %{ $c->{monthly_bots_count} } ) {
      $reduced_monthly_bots_count->{$month} //= 0;
      $reduced_monthly_bots_count->{$month}  += $c->{monthly_bots_count}->{$month};
    };
    # take all discarded counts, add them up
    for my $month ( keys %{ $c->{monthly_discarded_count} } ) {
      $reduced_monthly_discarded_count->{$month} //= 0;
      $reduced_monthly_discarded_count->{$month}  += $c->{monthly_discarded_count}->{$month};
    };
    # take all monthly language counts, add them up
    for my $month ( keys %{ $c->{counts} } ) {
      $reduced_counts->{$month} //= {};
      for my $language ( keys %{ $c->{counts}->{$month} } ) {
        $reduced_counts->{$month}->{$language} //= 0;
        $reduced_counts->{$month}->{$language}  += $c->{counts}->{$month}->{$language};
      };
    };
  };

  # put the reduced values back in the model for further computation
  $self->{monthly_bots_count}       = $reduced_monthly_bots_count;
  $self->{monthly_discarded_count}  = $reduced_monthly_discarded_count;
  $self->{counts}                   = $reduced_counts;
};

sub map    {
  my ($self,$file) = @_;
  $self->process_file($file);
};


#
# This shouldn't really be necessary because we fork
# so each process gets the clean object
#
sub reset_for_new_child {
  $_[0]->{monthly_discarded_count} = {};
  $_[0]->{monthly_bots_count}      = {};
  $_[0]->{counts}                  = {};
  #$_[0]->{bdetector}               = undef;
};

#
# updates the active_children_pids and returns
# the number of free slots
#
sub update_child_slots {
  my ($self) = @_;
  my $max        = $self->{MAX_PARALLEL_CHILDREN};
  my $child_pids = $self->{active_children_pids} ;

  my $still_active = [];
  for my $idx_child ( 0..(-1+scalar(@$child_pids)) ) {
    my $child_pid = $child_pids->[$idx_child];
    if(kill(0,$child_pid)) {
      push @$still_active , $child_pid;
    };
  };

  $self->{active_children_pids} = $still_active;

  return $max - @$child_pids;
};


sub write_child_output_to_disk {
  my ($self,$output_path) = @_;
  open my $fh,">$output_path";
  my $json = encode_json({
    monthly_discarded_count => $self->{monthly_discarded_count},
    monthly_bots_count      => $self->{monthly_bots_count},
    counts                  => $self->{counts},
  });
  print $fh $json;
  close $fh;
};


sub process_files {
  my ($self,$params) = @_;

  $SIG{CHLD}="IGNORE";

  $self->{MAX_PARALLEL_CHILDREN} = 3;

  warn $params->{children_output_path};
  for my $gz_logfile ($self->get_files_in_interval($params)) {
    $self->reset_for_new_child();
    my $child_pid = fork();
    if($child_pid == 0) {
      my $gz_basename  = basename($gz_logfile);
      my $full_gz_path = $params->{children_output_path}."/$gz_basename";
      my $output_file  = $full_gz_path;
      my $stderr_file  = $full_gz_path;
      $stderr_file     =~ s/\.gz$/.err/;
      $output_file     =~ s/\.gz$/.json/;

      warn "ERR => $stderr_file";
      warn "OUT => $output_file";

      open STDERR, ">$stderr_file";
        $self->map($gz_logfile);
        $self->write_child_output_to_disk($output_file);
      close STDERR;

      print "CHILD EXITING !!!\n";
      #kill(TERM,$$);
      CORE::exit(-1);
    } else {
      warn "IN PARENT, pushing $child_pid on child list";
      push @{ $self->{active_children_pids} }, $child_pid;

      # wait for at least one child to finish
      # so we can make another iteration of the for loop
      # and fire up one more child
      while( 1 ) {
        warn "PARENT CHECKING LOOP STARTED";
        my $free_slots = $self->update_child_slots;
        warn "FREE SLOTS = $free_slots";
        last if $free_slots > 0;
        sleep 1;
        warn "PARENT CHECKING LOOP SLEPT";
      };
    };
  };

  while( 1 ) {
    sleep 4;
    $self->update_child_slots;
    last if @{ $self->{active_children_pids} } == 0;
  };

  $self->reduce($params->{children_output_path});
};


1;
