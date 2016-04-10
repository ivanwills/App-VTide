package App::VTide::Command::Refresh;

# Created on: 2016-03-22 15:42:06
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use warnings;
use version;
use Carp;
use English qw/ -no_match_vars /;
use YAML::Syck;

extends 'App::VTide::Command::Run';

our $VERSION = version->new('0.0.1');
our $NAME    = 'refresh';
our $OPTIONS = [
    'force|f',
    'test|T!',
    'verbose|v+',
];
sub _sub {( $NAME, $OPTIONS )};

sub run {
    my ($self) = @_;

    # re-read sub-comand configs
    $self->vtide->_generate_sub_command;

    # check that all the sessions still exist
    $self->clean_sessions();

    return;
}

sub clean_sessions {
    my ( $self) = @_;

    my $file     = $self->history;
    my $sessions = eval { LoadFile( $file ) } || {};

    for my $session (keys %{ $sessions->{sessions} }) {
        my $dir = $sessions->{sessions}{$session};
        if ( ! -d $dir || ! -f "$dir/.vtide.yml" ) {
            warn "$session ($dir) is missing\n";
            $self->hooks->run('refresh_session_missing', $session, $dir);
            delete $sessions->{sessions}{$session} if $self->defaults->{force};
        }
    }

    DumpFile( $file, $sessions );

    return;
}

1;

__END__

=head1 NAME

App::VTide::Command::Refresh - Refresh App::VTide configurations

=head1 VERSION

This documentation refers to App::VTide::Command::Refresh version 0.0.1

=head1 SYNOPSIS

   use App::VTide::Command::Refresh;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head3 C<run ()>

Run the command

=head2 C<clean_sessions ()>

Clean up sessions which no longer exist.

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
