use strict;
use Test::More      'no_plan';
use List::MoreUtils 'all';
use Scalar::Util    'blessed';
use Data::Dumper;
use Module::Loaded;  

my $Class       = 'Acme::PBP::Enforce';
my $TestClass   = $Class . '::_test';

### overload doesn't propagate to eval, unless we include it like this
### turn off warnings in the test cases, as we run dodgy code
my $TestHeader  = "package $TestClass; use $Class; " . 'local $^W; ';

my $Map = {
    ### good tab, should be fine
    qq["\t \\t"]            => sub { not $@ },
    ### bad tab, should die
    qq["	Literal tab"]   => sub { $@ =~ /Illegal use of literal tab/ },  

    ### open with variable is ok
    q[open my $fh, 1 ],     => sub { $! && not $@ },
    ### open with bareword filehandle is not
    q[open FILE, 1]         => sub { $@ =~ /Bareword filehandles not allowed/ },
    
    ### function with prototypes is not allowed
    qq[$Class->_disallow_prototypes( __PACKAGE__ ) ]
                            => sub { $@ },

};   

diag( "You may safely ignore 'Too late to run CHECK block' warnings" );

while( my( $code, $sub ) = each %$Map ) {
    ok( 1,                  "Testing code '$code'" );

    eval $TestHeader . $code;
    my $rv = $sub->( $code );
    
    chomp $@;
    my $err = $@ || 'No Error';
    ok( $rv,                "   Code tested as expected ($err)" );
}    

### for prototype check
sub Acme::PBP::Enforce::_test::z ($) { };
