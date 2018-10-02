#!/usr/bin/env perl

package Devel::Project::Config;

use strict;
use warnings;

# imports
use YAML::XS qw/LoadFile DumpFile/;
use File::Spec::Functions qw/catfile/;
use File::Basename;
use Cwd;
use Carp;

use Devel::Project::Config::Delivery;
use Devel::Project::Config::Meta;
use Devel::Project::Config::Files;
use Devel::Project::Config::Tasks;
use Devel::Project::Config::Build;
use Devel::Project::Config::Properties;

# package variables
our $VERSION = '0.001000';

# subs
sub new {
  my ($self, $project) = @_;

  my $path = find_project_in_CWT($project);
  if (defined $project && $project ne '') {
    unless (defined $path) {
      my $registry = $ENV{PROJECT_REGISTRY}
        || catfile($ENV{HOME}, '.project_registry.yml');

      croak "registry required but not found at $registry"
        unless -f $registry;

      $path = $registry;
    }
  }

  croak "no project found" unless (defined $path);

  my $yaml = LoadFile($path);

  my $fields = {
    file     => $path,
    contents => $yaml,
    delivery => Devel::Project::Config::Delivery->new($yaml->{delivery}),
    meta     => Devel::Project::Config::Meta->new($yaml->{meta}),
    files    => Devel::Project::Config::Files->new($yaml->{files}),
    tasks    => Devel::Project::Config::Tasks->new($yaml->{tasks}),
    build    => Devel::Project::Config::Build->new($yaml->{build}),
    properties => Devel::Project::Config::Properties->new($yaml->{properties})
  };

  bless ($fields, $self);
}

sub file {
  return $_[0]->{file};
}

sub contents {
  return $_[0]->{contents};
}

sub delivery {
  return $_[0]->{delivery};
}

sub meta {
  return $_[0]->{meta};
}

sub files {
  return $_[0]->{files};
}

sub tasks {
  return $_[0]->{tasks};
}

sub build {
  return $_[0]->{build};
}

sub properties {
  return $_[0]->{properties};
}

sub store {
  my ($self, $file) = @_;

  if (defined $file) {
    DumpFile($file, $self->contents);
  }
  else {
    DumpFile($self->file, $self->contents);
  }
}

sub load {
  my ($self, $file) = @_;

  if (defined $file) {
    $self->contents(LoadFile($file));
  }
  else {
    $self->contents(LoadFile($self->file));
  }
}

sub find_project_in_CWT {
  my ($project) = @_;

  my $dir;
  my $cwd      = cwd;
  my $basename = '.';
  if (defined $project) {
    $basename .= $project . '.project.yml';
  }

  while ($cwd ne $ENV{HOME}) {
    if (defined $project) {
      $project = catfile($cwd, $basename);
      return $project if -f $project;
    }
    else {
      opendir $dir, $cwd;
      
      while ((my $filename = readdir $dir)) {
        if ($filename =~ /\.project\.yml$/) {
          closedir $dir;
          return $filename;
        }
      }

      closedir $dir;
    }

    $cwd = dirname $cwd;
    
    if ($cwd eq $ENV{HOME}) {
      if (defined $project) {
        $project = catfile($cwd, $basename);
        return $project if -f $project;
      }
      else {
        opendir $dir, $cwd;

        while ((my $filename = readdir $dir)) {
          if ($filename =~ /\.project\.yml$/) {
            closedir $dir;
            return $filename;
          }
        }

        closedir $dir;
      }
    }
  }

  return undef;
}

1;

__END__

=head1 Name

  Devel::Project::Config v0.001000 -- control and query project configuration

=head1 API

=over 4

=item * new ($self, $project)

create a Devel::Project::Config object based on $project

=item * file ($self, $file?)

return or set path to project configuration

=item * contents ($self, $yaml?)

return or set YAML spec

=item * build ($self)

return Devel::Project::Config::Build object

=item * tasks ($self)

return Devel::Project::Config::Tasks object

=item * files ($self)

return Devel::Project::Config::Files object

=item * meta ($self)

return Devel::Project::Config::Meta object

=item * delivery ($self)

return Devel::Project::Config::Delivery object

=item * properties ($self)

return Devel::Project::Config::Properties object

=item * store ($self, $file?)

write current state of YAML object to disk, using $self->file or $file if defined

=item * load ($self, $file?)

replace current state of YAML object with version on disk, using $self->file or $file
if defined

=back

=head1 License

Copyright (C) 2018 Adam Marshall.

This software is distributed under the MIT License.