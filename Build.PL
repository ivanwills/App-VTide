use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name       => 'App::VTide',
	license           => 'perl',
	dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
	dist_version_from => 'lib/App/VTide.pm',
	requires          => {
		'perl'             => 5.008,
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
