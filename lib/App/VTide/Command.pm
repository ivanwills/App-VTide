package App::VTide::Command;

# Created on: 2016-01-30 15:06:14
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use warnings;
use version;
use Carp;
use English qw/ -no_match_vars /;
use File::chdir;
use Path::Tiny;
use YAML::Syck;

our $VERSION = version->new('0.0.1');

has [qw/ defaults options /] => (
    is => 'rw',
);

has vtide => (
    is      => 'rw',
    handles => [qw/ config /],
);

has history => (
    is      => 'rw',
    default => sub { path $ENV{HOME}, '.vtide/history.yml' },
);

sub save_session {
    my ( $self, $name, $dir ) = @_;

    my $file     = $self->history;
    my $sessions = eval { LoadFile( $file ) } || {};

    $sessions->{sessions}{$name} = "$dir" || $CWD;

    DumpFile( $file, $sessions );

    return;
}

sub session_dir {
    my ( $self, $name ) = @_;

    my $file     = $self->history;
    my $sessions = eval { LoadFile( $file ) } || {};

    my $dir = $sessions->{sessions}{$name || ''} || $ENV{VTIDE_DIR} || path('.')->absolute;

    $name ||= path($dir)->absolute->basename;

    my $config = path $dir, '.vtide.yml';

    $self->config->local_config( $config );
    $self->env( $name, $dir, $config );

    return ( $name, $dir );
}

sub env {
    my ( $self, $name, $dir, $config ) = @_;

    $dir    ||= path( $ENV{VTIDE_DIR} ) || path( $dir || '.' )->absolute;
    $config ||= $ENV{VTIDE_CONFIG} || $dir->path( '.vtide.yml' );
    $name   ||= $ENV{VTIDE_NAME}
        || $self->defaults->{name}
        || $self->config->get->{name}
        || $dir->basename;

    $ENV{VTIDE_NAME}   = "$name";
    $ENV{VTIDE_DIR}    = "$dir";
    $ENV{VTIDE_CONFIG} = "$config";

    return ( $name, $dir, $config );
}

sub auto_complete {
    my ($self) = @_;

    warn lc ( ref $self =~ /.*::/ ), " has no --auto-complete support\n";
    return;
}

1;

__END__

=head1 NAME

App::VTide::Command - Base class for sub commands

=head1 VERSION

This documentation refers to App::VTide::Command version 0.0.1

=head1 SYNOPSIS

   extends 'App::VTide::Command';

   # child class code

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head3 C<session_dir ( $name )>

Get the session directory for C<$name>.

=head3 C<save_session ( $name, $dir )>

Save the session and directory in the history file.

=head3 C<env ( $name, $dir, $config )>

Configure the environment variables based on C<$name>, C<$dir> and C<$config>

=head1 ATTRIBUTES

=head2 C<defaults>

Values from command line arguments

=head2 C<options>

Command line configuration

=head2 C<vtide>

Reference to parent command with configuration object.

=head2 C<history>

History configuration file

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
