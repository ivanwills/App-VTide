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

    DumpFile('.current-env', \%ENV);

    return;
}

sub diff_env {
    my ($self) = @_;

    my $old_env = LoadFile('.current-env');
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

   use App::VTide::Command::Save;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<run ()>

Need to implement

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
