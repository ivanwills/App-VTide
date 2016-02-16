package App::VTide::Command::Run;

# Created on: 2016-01-30 15:06:40
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moo;
use warnings;
use version;
use Carp;
use English qw/ -no_match_vars /;
use Hash::Merge::Simple qw/ merge /;
use Path::Tiny;

extends 'App::VTide::Command';

our $VERSION = version->new('0.0.1');

sub run {
    my ($self) = @_;

    my ( $name ) = $self->session_dir($self->defaults->{name});
    my $cmd = $self->options->files->[0] || '';
    print "Running $name - $cmd\n";
    $ENV{VTIDE_TERM} = $cmd;

    my $params = $self->params( $cmd );
    my @cmd    = $self->command( $params );

    if ( $params->{wait} ) {
        print join ' ', @cmd, "\n";
        print "Press enter to start : ";
        my $ans = <STDIN>;
        if (!$ans || !ord $ans) {
            print "\n";
            return;
        }
    }

    if ( $params->{env} && ref $params->{env} eq 'HASH' ) {
        for my $env ( keys %{ $params->{env} } ) {
            my $orig = $ENV{$env};
            $ENV{$env} = $params->{env}{$env};
            $ENV{$env} =~ s/[\$]$env/$orig/;
        }
    }

    $self->runit( @cmd );

    if ( ! $self->defaults->{test} && $self->restart($cmd) ) {
        return $self->run;
    }

    return;
}

sub restart {
    my ($self, $cmd) = @_;

    my $params = $self->params( $cmd );

    return if ! $params->{restart};

    my %action = (
        q => {
            msg  => 'quit',
            exec => sub { 0; },
        },
        r => {
            msg  => 'restart',
            exec => sub { 1 },
        },
    );

    if ($params->{restart} ne 1) {
        my ($letter) = $params->{restart} =~ /^(.)/;
        $action{$letter} = {
            msg  => $params->{restart},
            exec => sub { exec $params->{restart}; },
        };
    }

    # show restart menu
    my $menu = "Options:\n";
    for my $letter (sort keys %action) {
        $menu .= "$letter - $action{$letter}{msg}\n";
    }
    print $menu;

    # get answer
    my $answer = <STDIN>;
    chomp $answer if $answer;
    $answer ||= $params->{default} || '';

    # ask the question
    while ( ! $action{$answer} ) {
        print $menu;
        print "Please choose one of " . (join ', ', sort keys %action) . "\n";
        $answer = <STDIN>;
        chomp $answer if $answer;
        $answer ||= $params->{default} || '';
    }

    return $action{$answer}{exec}->();
}

sub params {
    my ( $self, $cmd ) = @_;

    my $config = $self->config->get;
    my $params = $config->{terminals}{$cmd} || {};

    if ( ref $params eq 'ARRAY' ) {
        $params = { command => @{ $params } ? $params : '' };
    }

    if ( ! $params->{command} && ! $params->{edit} ) {
        $params->{command} = 'bash';
        $params->{wait} = 0;
    }

    return merge $config->{default} || {}, $params;
}

sub command {
    my ( $self, $params ) = @_;

    if ( ! $params->{edit} ) {
        return ref $params->{command}
            ? @{ $params->{command} }
            : ( $params->{command} );
    }

    my $editor = ref $params->{editor}{command} || $self->config->get->{editor}{command};

    my @files;
    my @globs  = ref $params->{edit} ? @{ $params->{edit} } : ( $params->{edit} );

    eval { require Term::Title; }
        and Term::Title::set_titlebar($globs[0]);

    my $groups = $self->config->get->{editor}{files};
    while ( my $glob = shift @globs ) {
        if ( $groups->{$glob} ) {
            push @globs, @{ $groups->{$glob} };
            next;
        }

        push @files, $self->_dglob($glob);
    }

    return ( @$editor, @files );
}

sub _shell_quote {
    my ($file) = @_;
    $file =~ s/([\s&;*'"])/\\$1/gxms;
    return $file;
}

sub _dglob {
    my ($self, $glob) = @_;

    # if the "glob" is actually a single file then just return it
    return ($glob) if -f $glob;

    my @files;
    for my $deep_glob ( $self->_globable($glob) ) {
        push @files, glob $deep_glob;
    }

    return @files;
}

sub _globable {
    my ($self, $glob) = @_;

    my ($base, $rest) = $glob =~ m{^(.*?) [*][*] /? (.*)$}xms;

    return ($glob) if !$rest;

    my @globs;
    for ( 0 .. 3 ) {
        push @globs, $self->_globable("$base$rest");
        $base .= '*/';
    }

    return @globs;
}

sub runit {
    my ( $self, @cmd ) = @_;

    print join ' ', @cmd, "\n" if $self->defaults->{test} || $self->defaults->{verbose};

    return if $self->defaults->{test};

    if ( @cmd > 1 ) {
        my $found = 0;
        for my $dir ( split /:/, $ENV{PATH} ) {
            if ( -d $dir && -x path $dir, $cmd[0] ) {
                $found = 1;
                last;
            }
        }

        if ( ! $found ) {
            @cmd = ( join ' ', @cmd );
        }
    }

    return system @cmd;
}

sub auto_complete {
    my ($self) = @_;

    my $env = $self->options->files->[-1];
    print join ' ', my @files = sort keys %{ $self->config->get->{termials} };

    print join ' ', grep { $env ne 'run' ? /$env/ : 1 } @files;

    return;
}

1;

__END__

=head1 NAME

App::VTide::Command::Run - Run a terminal command

=head1 VERSION

This documentation refers to App::VTide::Command::Run version 0.0.1

=head1 SYNOPSIS

   use App::VTide::Command::Run;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<run ()>

Runs the terminal command

=head2 C<restart ( $cmd )>

Checks if the terminal command should be restarted on exit (and asks if it should)

=head2 C<params ( $cmd )>

Gets the configuration for the command C<$cmd>

=head2 C<command ( $params )>

Gets the command to execute, either a simple command or an "editor" command
where the files are got from the groups

=head2 C<_shell_quote ( $file )>

Quote C<$file> for shell execution

=head2 C<_dglob ( $glob )>

Gets the files globs from $glob

=head2 C<_globable ( $glob )>

Converts a deep blog (e.g. **/*.js) to a series of perl globs
(e.g. ['*.js', '*/*.js', '*/*/*.js', '*/*/*/*.js'])

=head2 C<runit ( @cmd )>

Executes a command (with --test skipping)

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
