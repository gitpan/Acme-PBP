use ExtUtils::MakeMaker;
use strict;

WriteMakefile (
    NAME            => 'Acme::PBP',
    VERSION_FROM    => 'lib/Acme/PBP.pm', # finds $VERSION
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    PREREQ_PM       => {    'Test::More'            => 0, 
                            'Module::Loaded'        => 0,
                            'Perl::Tidy'            => 0,
                            'PPI'                   => 0,
                            'Perl::Critic'          => 0,
                            'Smart::Comments'       => 0,
                            
                    },
    AUTHOR          => 'Jos Boumans <kane[at]cpan.org>',
	ABSTRACT        => 'Module to accompany the Perl Best Practices book'
);             
