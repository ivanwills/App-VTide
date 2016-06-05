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
use App::VTide::Hooks;
use Path::Tiny;
use YAML::Syck qw/ LoadFile DumpFile /;

our $VERSION = version->new('0.0.2');

has config => (
    is      => 'rw',
    lazy    => 1,
    default => sub { return App::VTide::Config->new() },
);
has hooks => (
    is      => 'rw',
    lazy    => 1,
    default => sub { return App::VTide::Hooks->new( vtide => $_[0] ) },
);
has sub_commands => (
    is      => 'rw',
    lazy    => 1,
    builder => '_sub_commands',
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
                my ($option, $auto, $errors) = @_;
                my $sub_command = $option->cmd;
                if ( $sub_command eq '--' ) {
                    print join ' ', sort keys %{ $self->sub_commands };
                    return;
                }
                eval {
                    $self->load_subcommand( $sub_command, $option )->auto_complete();
                    1;
                } or do {
                    print join ' ', grep {/$sub_command/xms} sort keys %{ $self->sub_commands };
                }
            },
            sub_command   => $self->sub_commands,
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
    if ( ! $subcommand ) {
        my $error = $@;
        warn $@ if $opt->opt->verbose;
        warn "Unknown command '$cmd'!\n",
            "Valid commands - ", ( join ', ', sort keys %{ $self->sub_commands } ),
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

sub _sub_commands {
    my ($self)   = @_;
    my $sub_file = path $ENV{HOME}, '.vtide', 'sub-commands.yml';

    mkdir $sub_file->parent if ! -d $sub_file->parent;

    return LoadFile("$sub_file") if -f $sub_file;

    return $self->_generate_sub_command();
}

sub _generate_sub_command {
    my ($self)   = @_;
    my $sub_file = path $ENV{HOME}, '.vtide', 'sub-commands.yml';

    require Module::Pluggable;
    Module::Pluggable->import( require => 1, search_path => ['App::VTide::Command'] );
    my @commands = __PACKAGE__->plugins;

    my $sub_commands = {};
    for my $command (reverse sort @commands) {
        my ($name, $conf) = $command->details_sub;
        $sub_commands->{$name} = $conf;
    }

    DumpFile($sub_file, $sub_commands);

    return $sub_commands;
}

1;

__END__

=head1 NAME

App::VTide - A vim/tmux baised IDE for the terminal

=head1 VERSION

This documentation refers to App::VTide version 0.0.2

=head1 SYNOPSIS

    vtide (init|start|refresh|run|edit|save|conf|help) [options]

  COMMANDS:
    conf    Show editor config settings
    edit    Run vim for a group of files
    help    Show help for vtide sub commands
    init    Initialise a new project
    refresh Refreshes the autocomplete cache
    run     Run a projects terminal command
    save    Make/Save changes to a projects config file
    start   Open a project in Tmux

  Examples:
    # start a new project, name taken from the directory name
    vtide init
    # start the project in the current directory
    vtide start
    # start the "my-project" project previously initialised
    vtide start my-project

=head1 DESCRIPTION

VTide provides a way to manage L<tmux> sessions. It allows for an easy way
to configure a session window and run programs or open files for editing
in them. The aim is to allow for easy project setup and management for
projects managed on the command line. L<App::VTide> also includes helpers
for loading files into editors (such as vim) in seperate tmux terminals.
This can help to open pre-defined groups of files.

=head2 Philosophy

One piece of work == one project == one terminal tab. In one terminal
tmux is run with tmux windows for editing different files, running commands
and version control work.

=head1 SUBROUTINES/METHODS

=head2 C<run ()>

Run the vtide commands

=head2 C<load_subcommand ( $cmd, $opt )>

Loads the sub-command module and creates a new instance of it to return
to the caller.

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

A full description of the configuration files can be found in
L<App::VTide::Configuration>.

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
