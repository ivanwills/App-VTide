package App::VTide::Command::Init;

# Created on: 2016-01-30 15:06:31
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
    my $dir    = path( $self->defaults->{dir} || '.' )->absolute;
    my $file   = $dir->path( '.vtide.yml' );
    my $count  = $self->defaults->{windows} || 4;
    my $name   = $self->defaults->{name} || $dir->basename;
    my $config = {
        name    => $name,
        count   => $count,
        default => {
            restart => 0,
            wait    => 0,
        },
        editor => {
            files => {
                eg => [qw/some-file.eg/],
            },
        },
        terminals => {
            map { $_ => [] } 2 .. $count
        },
    };

    DumpFile( $file, $config );

    $self->save_session( $name, $dir );

    return;
}

1;

__END__

=head1 NAME

App::VTide::Command::Init - Initialize an session configuration file

=head1 VERSION

This documentation refers to App::VTide::Command::Init version 0.0.1

=head1 SYNOPSIS

   use App::VTide::Command::Init;

   # Brief but working code example(s) here showing the most common usage(s)
   # This section will be as far as many users bother reading, so make it as
   # educational and exemplary as possible.


=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head3 C<run ()>

Initialize the configuration file

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
