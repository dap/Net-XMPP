use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'      => 'Net::XMPP',
    'PREREQ_PM' => {
        'XML::Stream' => 1.17,
        'Digest::SHA1' => 1.02
    },
    'VERSION_FROM' => 'lib/Net/XMPP.pm',
    'dist' => {
        'COMPRESS' => 'gzip --best'
    }
);
