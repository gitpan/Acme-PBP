### have to use it, it overrides functions!
use Acme::PBP::Defeat;

use strict;
use Test::More      'no_plan';
use List::MoreUtils 'all';
use Scalar::Util    'blessed';
use Perl::Critic;
use Data::Dumper;

### overload doesn't propagate to eval, unless we include it like this
my $TestHeader  = "package Acme::PBP::Defeat::_test; use Acme::PBP::Defeat;";

my $Map = {
    q['1' !~ qr/1#/xms] => [ qw|RegularExpressions::RequireExtendedFormatting| ],
    q[1;          ]. $/ => [ qw|CodeLayout::ProhibitTrailingWhitespace| ],
    do { join $/.$/, '', '=head1 foo', '=cut', '1;' }
                        => [ qw|Documentation::RequirePodAtEnd| ],
    
};   

while( my( $code, $aref ) = each %$Map ) {
    my $policy  = join '|', @$aref;
    my %look_up = map { 'Perl::Critic::Policy::'.$_ => $_ } @$aref;

    ### encode newlines for pretty printing
    my $pp_code = $code;
    $pp_code =~ s/\n/\\n/g;

    ok( 1,                  "Testing code '$pp_code' against policies @$aref" );

    my $critic  = Perl::Critic->new( '-single-policy' => $policy );
    ok( $critic,            "   New critic object created" );

    my @violate = $critic->critique( \$code );
    my @pp_violate = map { $_->policy } @violate;
    ok( !scalar(@violate),  "   No violations detected! @pp_violate" );

    my $rv = eval $TestHeader . $code;
    ok( !$@,                "Code compiles properly $@" ),
    ok( $rv,                "   Code beat PBP!" );

}    

### disable source filters... violently
{   eval qq[
        use Smart::Comments '#####';

        ##### Triggering the module;
    ];

    ok( $@,                 "No source filters allowed ($@)" );
    like( $@, qr/Smart::Comments/,
                            "   Culprit caught!" );
}    
