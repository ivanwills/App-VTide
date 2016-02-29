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
    lazy    => 1,
    default => sub { App::VTide::Config->new() },
);

sub run {
    my ($self) = @_;
    my %sub_commands = (
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
            'name|n=s',
            'test|T!',
            'verbose|v+',
        ],
        edit => [
            'test|T!',
            'verbose|v+',
        ],
        save => [
            'record_env|record-env|r',
            'diff_env|diff-env|d',
            'save_env|save-env|d',
            'test|T!',
            'verbose|v+',
        ],
        conf => [
            'env|e',
            'terms|t',
            'which|w=s',
            'test|T!',
            'verbose|v+',
        ],
    );

    my ($options, $cmd, $opt) = get_options(
        {
            name        => 'vtide',
            conf_prefix => '.',
            helper      => 1,
            default     => {
                test => 0,
            },
            auto_complete => sub {
                my ($opt, $auto, $errors) = @_;
                my $cmd = $opt->cmd;
                if ( $cmd eq '--' ) {
                    print join ' ', sort keys %sub_commands;
                    return;
                }
                eval {
                    $self->load_subcommand( $cmd, $opt )->auto_complete();
                };
                if ($@) {
                    print join ' ', grep {/$cmd/} sort keys %sub_commands;
                }
            },
            sub_command   => \%sub_commands,
            help_package  => __PACKAGE__,
            help_packages => {
                map {$_ => __PACKAGE__ . '::Command::' . ucfirst $_}
                qw/ init start run edit save conf /
            },
        },
        [
            'name|n=s',
            'test|T!',
        ],
    );

    my $subcommand = eval { $self->load_subcommand( $opt->cmd, $opt ) };
    if ($@) {
        warn "Unknown command '$cmd'!\n",
            "Valid commands - ", ( join ', ', sort keys %sub_commands ),
            "\n";
            require Pod::Usage;
            Pod::Usage::pod2usage(
                -verbose => 1,
                -input   => __FILE__,
            );
    }

    return $subcommand->run;
}

sub load_subcommand {
    my ( $self, $cmd, $opt ) = @_;

    my $file   = 'App/VTide/Command/' . ucfirst $cmd . '.pm';
    my $module = 'App::VTide::Command::' . ucfirst $cmd;

    require $file;

    return $module->new(
        defaults => $opt->opt,
        options  => $opt,
        vtide    => $self,
    );
}

1;

__END__

=head1 NAME

App::VTide - A vim/tmux IDE

=head1 VERSION

This documentation refers to App::VTide version 0.0.1

=head1 SYNOPSIS

    vtide (init|start|run|edit|save|conf) [options]

  COMMANDS:
    init    Initialise a new project
    start   Open a project in Tmux
    run     Run a projects terminal command
    edit    Run vim for a group of files
    save    Make/Save changes to a projects config file
    conf    Show editor config settings

  Examples:
    # start a new project, name taken from the directory name
    vtide init
    # start the project in the current directory
    vtide start
    # start the "my-project" project previously initialised
    vtide start my-project

=head1 DESCRIPTION

VTide is the programmatic expression of my workflow. It uses the C<tmux>
terminal multiplexer to start multiple terminals and run vim (or other
editors/commands) in each.

=head1 SUBROUTINES/METHODS

=head2 C<run ()>

Run the vtide commands

=head2 C<load_subcommand ( $cmd, $opt )>

Loads the sub-command module and creates a new instance of it to return
to the caller.

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
