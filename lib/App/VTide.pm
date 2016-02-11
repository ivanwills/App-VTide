package App::VTide;

# Created on: 2016-01-28 09:58:07
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use warnings;
use version;
use Carp;
use English qw/ -no_match_vars /;
use Getopt::Alt;
use App::VTide::Config;

our $VERSION = version->new('0.0.1');

has config => (
    is      => 'rw',
    default => sub { App::VTide::Config->new() },
);

sub run {
    my ($self) = @_;

    my ($options, $cmd, $opt) = get_options(
        {
            name        => 'vtide',
            conf_prefix => '.',
            helper      => 1,
            default     => {
                test => 0,
            },
            auto_complete => sub {
                my ($opt, $auto) = @_;
            },
            sub_command => {
                init  => [
                    'name|n=s',
                    'dir|d=s',
                    'windows|w=i',
                    'verbose|v+',
                ],
                start => [
                    'name|n=s',
                    'windows|w=i',
                    'test|T!',
                    'verbose|v+',
                ],
                run  => [
                    'test|T!',
                    'verbose|v+',
                ],
                edit => [
                    'test|T!',
                    'verbose|v+',
                ],
                save => [
                    'test|T!',
                    'verbose|v+',
                ],
                conf => [
                    'test|T!',
                    'verbose|v+',
                ],
            },
        },
        [
            'name|n=s',
            'test|T!',
        ],
    );

    my $file   = 'App/VTide/Command/' . ucfirst $opt->cmd . '.pm';
    my $module = 'App::VTide::Command::' . ucfirst $opt->cmd;

    require $file;

    return $module->new(
        defaults => $options,
        options  => $opt,
        vtide    => $self,
    )
    ->run;
}

1;

__END__

=head1 NAME

App::VTide - A vim/tmux IDE

=head1 VERSION

This documentation refers to App::VTide version 0.0.1

=head1 SYNOPSIS

    use App::VTide;

    App::VTide->run;

    # from the command line:
    # start a new vtide project
    vtide init

    # run an existing vtide project from the current directory
    vtide start

    # run a named vtide project
    vtide start myproj

=head1 DESCRIPTION

VTide is the programatic expression of my workflow. It uses the C<tmux>
terminal multiplexer to start multiple terminals and run vim (or other
editors/commands) in each.

=head1 SUBROUTINES/METHODS

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
