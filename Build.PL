use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'App::VTide',
    license           => 'perl',
    dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
    dist_version_from => 'lib/App/VTide.pm',
    requires          => {
        'perl'                => '5.014',
        'Array::Utils'        => 0,
        'File::chdir'         => '0.1008',
        'Getopt::Alt'         => '0.3.6',
        'Hash::Merge::Simple' => '0.051',
        'List::Util'          => '1.41',
        'List::MoreUtils'     => '0.413',
        'Module::Pluggable'   => 0,
        'Moo'                 => '2.000001',
        'Path::Tiny'          => '0.068',
        'Scalar::Util'        => '1.41',
        'Test::More'          => '1.001014',
        'Test::Warnings'      => '0.021',
        'YAML::Syck'          => '1.29',
        'version'             => '0.9909',
    },
    build_requires => {
        'Test::More'     => 0,
        'Test::Warnings' => 0,
    },
    add_to_cleanup     => [ 'App-VTide-*' ],
    create_license     => 1,
    meta_merge => {
        resources => {
            repository => 'git://github.com/ivanwills/App-VTide.git',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=App::VTide',
        },
    },
);

$builder->create_build_script();
