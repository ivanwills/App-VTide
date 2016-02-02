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

has files => (
    is      => 'rw',
    default => sub {[]},
);

sub run {
    my ($self) = @_;

    my ( $name ) = $self->env;
    my $cmd = $self->defaults->{run} || $self->options->files->[0];
    print "Running $name - $cmd\n";

    my $params = $self->params( $cmd );
    my @cmd    = $self->command( $params );

    if ($params->{wait}) {
        print join ' ', @cmd, "\n";
        print "Press enter to start : ";
        my $ans = <STDIN>;
        if (!$ans || !ord $ans) {
            print "\n";
            return;
        }
    }

    print join ' ', @cmd, "\n";
    system @cmd if !$self->defaults->{test};

    return;
}

sub params {
    my ( $self, $cmd ) = @_;

    my $config = $self->config->get;
    my $params = $config->{terminals}{$cmd} || {};

    if ( ref $params eq 'ARRAY' ) {
        $params = { command => @{ $params } ? $params : 'bash' };
    }

    $params->{command} ||= 'bash';

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
    my @globs  = @{ $params->{edit} };
    my $groups = $self->config->get->{editor}{files};
    while ( my $glob = shift @globs ) {
        if ( $groups->{$glob} ) {
            push @globs, @{ $groups->{$glob} };
            next;
        }

        push @files, $self->_dglob($glob);
    }

    return ref $editor
        ? ( @$editor, @files )
        : ( "$editor " . join ' ', map {_shell_quote($_)} @files );
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
    for my $deep_glob ( $self->globable($glob) ) {
        push @files, glob $deep_glob;
    }

    return @files;
}

sub globable {
    my ($self, $glob) = @_;

    my ($base, $rest) = $glob =~ m{^(.*?) [*][*] /? (.*)$}xms;

    return ($glob) if !$rest;

    my @globs;
    for ( 0 .. 3 ) {
        push @globs, $self->globable("$base$rest");
        $base .= '*/';
    }

    return @globs;
}

1;

__END__

=head1 NAME

App::VTide::Command::Run - <One-line description of module's purpose>

=head1 VERSION

This documentation refers to App::VTide::Command::Run version 0.0.1


=head1 SYNOPSIS

   use App::VTide::Command::Run;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

A full description of the module and its features.

May include numerous subsections (i.e., =head2, =head3, etc.).


=head1 SUBROUTINES/METHODS

A separate section listing the public components of the module's interface.

These normally consist of either subroutines that may be exported, or methods
that may be called on objects belonging to the classes that the module
provides.

Name the section accordingly.

In an object-oriented module, this section should begin with a sentence (of the
form "An object of this class represents ...") to give the reader a high-level
context to help them understand the methods that are subsequently described.


=head3 C<new ( $search, )>

Param: C<$search> - type (detail) - description

Return: App::VTide::Command::Run -

Description:

=cut


=head1 DIAGNOSTICS

A list of every error and warning message that the module can generate (even
the ones that will "never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

=head1 CONFIGURATION AND ENVIRONMENT

A full explanation of any configuration system(s) used by the module, including
the names and locations of any configuration files, and the meaning of any
environment variables or properties that can be set. These descriptions must
also include details of any configuration language used.

=head1 DEPENDENCIES

A list of all of the other modules that this module relies upon, including any
restrictions on versions, and an indication of whether these required modules
are part of the standard Perl distribution, part of the module's distribution,
or must be installed separately.

=head1 INCOMPATIBILITIES

A list of any modules that this module cannot be used in conjunction with.
This may be due to name conflicts in the interface, or competition for system
or program resources, or due to internal limitations of Perl (for example, many
modules that use source code filters are mutually incompatible).

=head1 BUGS AND LIMITATIONS

A list of known problems with the module, together with some indication of
whether they are likely to be fixed in an upcoming release.

Also, a list of restrictions on the features the module does provide: data types
that cannot be handled, performance issues and the circumstances in which they
may arise, practical limitations on the size of data sets, special cases that
are not (yet) handled, etc.

The initial template usually just has:

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
