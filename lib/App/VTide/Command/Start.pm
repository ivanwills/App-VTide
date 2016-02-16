package App::VTide::Command::Start;

# Created on: 2016-01-30 15:06:48
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

extends 'App::VTide::Command';

our $VERSION = version->new('0.0.1');

sub run {
    my ($self) = @_;

    my ( $name, $dir ) = $self->session_dir(
        $self->defaults->{name}
        || $self->options->files->[0]
    );

    local $CWD = $dir;

    $self->save_session( $name, $dir );

    return $self->tmux( $name );
}

sub tmux {
    my ( $self, $name ) = @_;

    my $v    = $self->defaults->{verbose} ? '--verbose' : '';
    $v .= " --name $name";
    my $tmux = "tmux -u2 new-session -s $name 'vtide run $v 1' \\; "
        . "split-window -h 'vtide run $v 1a' \\; "
        . "split-window -dv 'vtide run $v 1b' \\; ";
    my $count = $self->defaults->{windows} || $self->config->get->{count};

    for my $window ( 2 .. $count ) {
        $tmux .= "new-window 'vtide run $v $window' \\; ";
    }
    $tmux .= "select-window -t 1";

    eval { require Term::Title; }
        and Term::Title::set_titlebar($name);

    if ( $self->defaults->{test} ) {
        print "$tmux\n";
        return 1;
    }

    exec $tmux;
}

sub auto_complete {
    my ($self) = @_;

    my $file     = $self->history;
    my $sessions = eval { LoadFile( $file ) } || {};

    print join ' ', sort keys %{ $sessions->{sessions} };

    return;
}

1;

__END__

=head1 NAME

App::VTide::Command::Start - Start a session

=head1 VERSION

This documentation refers to App::VTide::Command::Start version 0.0.1

=head1 SYNOPSIS

   use App::VTide::Command::Start;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head3 C<run ()>

Starts the tmux session running a C<vtide run> command in each terminal

=head3 C<tmux ( $name )>

Run a tmux session with the name C<$name>

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
