#!/usr/bin/env perl

package Devel::Project::Config::Tasks;

use strict;
use warnings;

sub new {
  my ($class, $basis) = @_;

  my $ref = $basis || {};

  bless $ref, $class;
}

# configuration for todo

1;
