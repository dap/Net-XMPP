use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name       => 'Net::XMPP',
	license           => 'lgpl',
	dist_author       => 'Darian Anthony Patrick',
	dist_abstract     => 'XMPP Support Library',
	dist_version_from => 'lib/Net/XMPP.pm',

	configure_requires => {
		'Module::Build' => '0.360300',
	},

	build_requires => {
		'YAML::Tiny'    => '1.41',
	},

	requires => {
		'Authen::SASL'  => '2.12',
		'XML::Stream'   => '1.23_02',
		'Digest::SHA1'  => '1.02',
	},

	create_license => 1,
	create_makefile_pl => 'passthrough',
);

$builder->create_build_script();
