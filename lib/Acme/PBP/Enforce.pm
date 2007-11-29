package Acme::PBP::Enforce;

use Data::Dumper;
use overload;
use Carp;

my @Callers;
sub import {

    ### to check for prototypes later, during CHECK: {}
    push @Callers, [caller]->[0];
    
    overload::constant( 'q' => sub {  
        my($literal, $value) = @_;
        
        ### you've used tabs, but not \t to indicate them
        if( $value =~ /\t/ and $literal !~ /\\t/ ) {
            croak( "Illegal use of literal tab" );    
        }    
        
        return $value;
    } );       
}    

### bareword filehandles are bad
BEGIN { 
    *CORE::GLOBAL::open = sub (*;$@) { 
        croak( "Bareword filehandles not allowed. Use 'open my \$fh, $_[1]' instead" )
            if Internals::SvREADONLY( $_[0] );
        CORE::open( @_ );            
    };
}

sub _disallow_prototypes {
    my %use_proto;
    for my $pkg ( @_ ) {
        my $stash = $pkg . '::';

        no strict 'refs';
        for my $name (sort keys %$stash ) {
            my $sub     = $pkg->can($name)  or next;
            my $proto   = prototype $sub    or next;
            
            $use_proto{ "$pkg->$name" } = $proto;    
        }
    }

    if( keys %use_proto ) {
        croak(  "Use of prototypes not allowed in:\n" . 
                join '', map { "\t$_\n" } keys %use_proto );
    }
}

CHECK { __PACKAGE__->_disallow_prototypes( @Callers ) }

1;
