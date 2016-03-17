package App::VTide::Command::Save;

# Created on: 2016-01-30 20:38:50
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use warnings;
use version;
use Carp;
use List::MoreUtils qw/uniq/;
use English qw/ -no_match_vars /;
use YAML::Syck;

extends 'App::VTide::Command::Run';

our $VERSION = version->new('0.0.1');

has env_store => (
    is      => 'ro',
    default => '.current-env',
);

sub run {
    my ($self) = @_;

    if ( $self->defaults->{record_env} ) {
        $self->record_env();
    }
    elsif ( $self->defaults->{diff_env} ) {
        $self->defaults->{verbose} = 1;
        $self->diff_env();
    }
    elsif ( $self->defaults->{save_env} ) {
        $self->save_env( $self->diff_env() );
    }

}

sub record_env {
    my ($self) = @_;

    DumpFile($self->env_store, \%ENV);

    return;
}

sub diff_env {
    my ($self) = @_;

    my $old_env = LoadFile($self->env_store);
    my @keys = uniq sort keys %ENV, keys %$old_env;
    my %diff;

    for my $key (@keys) {
        next if ($ENV{$key} || '') eq ($old_env->{$key} || '');
        if ( $self->defaults->{verbose} ) {
            printf "%-15s %-45.45s %-45.45s\n", $key, $ENV{$key} || q{''}, $old_env->{$key} || q{''};
        }
        $diff{$key} = $ENV{$key};
    }

    return %diff;
}

sub save_env {
    my ($self, %env) = @_;

    my $file   = $ENV{VTIDE_CONFIG} || '.vtide.yml';
    my $config = LoadFile($file);

    if ( $self->defaults->{terminal} ) {
        my $term = $self->defaults->{terminal};
        $config->{terminals}{$term}{env} = {
            %{ $config->{terminals}{$term}{env} || {} },
            %env,
        };
    }
    else {
        $config->{default}{env} = {
            %{ $config->{default}{env} || {} },
            %env,
        };
    }

    DumpFile($file, $config);

    return;
}

1;

__END__

=head1 NAME

App::VTide::Command::Save - Save configuration changes

=head1 VERSION

This documentation refers to App::VTide::Command::Save version 0.0.1

=head1 SYNOPSIS

    vtide run
    vtide run [--help|--man]

  OPTIONS:
    -r --record-env Record the current environment (use before running commands
                    like nvm, rvm and perlbrew)
    -d --diff-env   Show the diff of the current environment and recorded
                    environment
    -s --save-env   Save the environment differences to .vtide.yml
   -v --verbose     Show more verbose output.
       --help       Show this help
       --man        Show full documentation

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<run ()>

Need to implement

=head2 C<record_env ()>

Save the current environment variables to a temporary file

=head2 C<diff_env ()>

Find the environment keys that differ in the current environment vs that stored
in the temporary file

=head2 C<save_env ()>

Save environment differences to the projects C<.vtide.yml> file

=head1 ATTRIBUTES

=head2 C<env_store>

The name of the temporary file for storing the environment variables

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2016 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
