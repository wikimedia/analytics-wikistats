package PageViews::Model::Parallel;
use base 'PageViews::Model::Sequential';
use JSON::XS;
use File::Basename;
use Carp;

=head1 NAME
  
PageViews::Model::Parallel - Model for paralle processing of Squid logfiles.

=cut


=head1 DESCRIPTION

This module inherits from B<PageViews::Model::Sequential>.

The main difference is in the way it processes the files. While ::Sequential processes files one-by-one
::Parallel has a loop where it forks up to B<max-children> worker processes, each working on a different squid log file.

=cut



=head2 reduce($self,$json_path)

After all worker processes have finished, B<reduce> adds up all the counts from each worker process.

Because there are multiple structures, each different in terms of keys, these are separated into some categories,
to_reduce1, to_reduce2, and these are reduced separately.

Finally, the reduced counts are replaced inside the model.

=cut

sub reduce {
  my ($self,$json_path) = @_;
  warn "DOING REDUCE";

  # we have two classes of data that we want to reduce
  # HoH-es which are listed in @to_reduce1 (with 2 keys, month and language)
  # H-es   which are listed in @to_reduce2 (with 1 key , month)

  my @to_reduce1 = qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
  /;

  my @to_reduce2 = qw/
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
  /;

  my @to_reduce_custom = qw/
    counts_mimetype
  /;

  my $reduced = {};

  # iterate over all children output jsons (each child processes 1 day of data) 
  for my $child_output (<$json_path/*.json>) {
    my $c = decode_json(`cat $child_output`);
    for my $month ( keys %{ $c->{counts} } ) {
      # initialize month hash for this property
      for my $property ( @to_reduce1 , @to_reduce2 ) {
        if(     $property ~~ @to_reduce2) {
          # initialize
          $reduced->{$property}->{$month} //= 0;
          # reduce
          $reduced->{$property}->{$month}  += $c->{$property}->{$month} // 0;
        } elsif($property ~~ @to_reduce1) {
          # initialize
          $reduced->{$property}->{$month} //= {};
          # reduce
          for my $language ( keys %{ $c->{counts}->{$month} } ) {
            $reduced->{$property}->{$month}->{$language} //= 0;
            $reduced->{$property}->{$month}->{$language}  += $c->{$property}->{$month}->{$language} // 0;
          };
        };
      };


      for my $mimetype(keys %{ $c->{counts_mimetype}->{$month} }) {
        $reduced->{counts_mimetype}->{$month} //= {};
        $reduced->{counts_mimetype}->{$month}->{$mimetype} += $c->{counts_mimetype}->{$month}->{$mimetype};
      };

    };

  };

  # put the reduced values back in the model for further computation
  for my $property ( @to_reduce1, @to_reduce2 , @to_reduce_custom ) {
    $self->{$property} = $reduced->{$property};
  };
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
  my ($self) = @_;

  my @to_reset = qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
  /;

  $self->{$_} = {} for @to_reset;
};



=head2 update_child_slots()

This method checks to see which of the PIDs of the worker processes in the attribute B<active_children_pids>
are still active. It then updates the array.

This method returns the number of workers workers still allowed to be started(up to the max-children limit).

=cut
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


=head2 write_child_output_to_disk($output_path)

This method writes to disk the counts a worker has processed.

=cut

sub write_child_output_to_disk {
  my ($self,$output_path) = @_;

  my @to_serialize = qw/
    counts
    counts_wiki_basic
    counts_wiki_index
    counts_api
    counts_discarded_bots    
    counts_discarded_url     
    counts_discarded_time    
    counts_discarded_fields  
    counts_discarded_status  
    counts_discarded_mimetype
  /;

  open my $fh,">$output_path";

  my $data_to_serialize = {};
  $data_to_serialize->{$_} = $self->{$_}
    for @to_serialize;

  my $json = JSON::XS->new
                         ->pretty(1)
                         ->canonical(1)
                         ->encode($data_to_serialize);
  print $fh $json;
  close $fh;
};


=head2 process_files($params)

The B<process_files> method receives as parameter the config hash read from the configuration file.

It then forks up to B<max-children>. A check is made to see how many children are active, if there are
fewer than B<max-children> some more are started until the limit is reached.

The initial process that calls B<process_files> effectively waits for the children to finish. After they
have finished, it reduces(adds) all the counts and stores them inside the class.

=cut


sub process_files {
  my ($self,$params) = @_;

  confess "[ERROR] max_children param invalid"
    unless $params->{"max-children"} =~ /^\d+$/;

  $SIG{CHLD}="IGNORE";
  $self->{MAX_PARALLEL_CHILDREN} = $params->{"max-children"};

  warn $params->{"children-output-path"};
  for my $gz_logfile ($self->get_files_in_interval($params)) {
    next if ! -f $gz_logfile;
    $self->reset_for_new_child();
    my $child_pid = fork();
    if($child_pid == 0) {
      my $gz_basename  = basename($gz_logfile);
      my $full_gz_path = $params->{"children-output-path"}."/$gz_basename";
      my $output_file  = $full_gz_path;
      my $stderr_file  = $full_gz_path;
      $stderr_file     =~ s/\.gz$/.err/;
      $output_file     =~ s/\.gz$/.json/;

      #warn "ERR => $stderr_file";
      #warn "OUT => $output_file";

      open STDERR, ">$stderr_file";
        $self->map($gz_logfile);
        $self->write_child_output_to_disk($output_file);
      close STDERR;

      print "CHILD EXITING !!!\n";
      #kill(TERM,$$);
      CORE::exit(-1);
    } else {
      #warn "IN PARENT, pushing $child_pid on child list";
      push @{ $self->{active_children_pids} }, $child_pid;

      # wait for at least one child to finish
      # so we can make another iteration of the for loop
      # and fire up one more child
      while( 1 ) {
        #warn "PARENT CHECKING LOOP STARTED";
        my $free_slots = $self->update_child_slots;
        #warn "FREE SLOTS = $free_slots";
        last if $free_slots > 0;
        sleep 1;
        #warn "PARENT CHECKING LOOP SLEPT";
      };
    };
  };

  while( 1 ) {
    sleep 4;
    warn "CHECK";
    $self->update_child_slots;
    last if @{ $self->{active_children_pids} } == 0;
  };

  $self->reduce($params->{"children-output-path"});
};


1;
