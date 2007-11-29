use strict;
use Test::More 'no_plan';

for my $class ( qw[Acme::PBP Acme::PBP::Enforce Acme::PBP::Defeat] ) {
    local $^W;
    use_ok( $class );
}
