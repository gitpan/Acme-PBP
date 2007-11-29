package Acme::PBP::Defeat;

use strict;
use overload;
use File::Spec;
use Data::Dumper;
use version;
use vars qw[$VERSION];
$VERSION = qv( 1.2.3 );

sub import {
    
    ### defeats RequireExtendedFormatting
    overload::constant( 'qr' => sub { "(?-xms:$_[1])" } );       
}    


### override PPI::Document->new to first be piped through perltidy
### also, put all the POD at the end of the document
{   use Perl::Tidy;
    use PPI::Document;

    my $rc = do{
        my $ext = '.pm';
        my $dir = join '/', split '::', __PACKAGE__;
        $dir    = File::Spec->rel2abs( $INC{$dir.$ext} ),
        $dir    =~ s/$ext$//;        
        File::Spec->catfile( $dir, 'PerlTidyRC'. $ext );     
    };

    my $org = PPI::Document->can('new');
    
    no warnings 'redefine';
    *_tidy = *PPI::Document::new = sub {
        my $self = shift;
        my $what = shift;

        my $sorted;
        if( $what ) {
            Perl::Tidy::perltidy(
                source          => $what,
                destination     => \my $out,
                perltidyrc      => $rc,
            );
            
            my( @top, @bottom );
            my $in_pod = 0;
            for (split $/, $out) {
                $in_pod = /^=/      ? 1 : $in_pod;            
                $in_pod ? do { push @bottom, $_ } : do { push @top, $_ };
                $in_pod = /^=cut/   ? 0 : $in_pod;
            }
        
            $sorted = join $/, @top, $/, '__END__', $/, @bottom;
        }

        ### use 'PPI::Document' if we're called via _tidy
        ### only pass args if we were passed args.
        return $org->( ref $self eq __PACKAGE__ ? 'PPI::Document'   : $self, 
                       $what                    ? \$sorted          : () 
        );
    }        
}

### Smart::Comments are evil, just like all source filters. So kill them.
BEGIN {
    use Module::Loaded qw[mark_as_loaded];
    mark_as_loaded('Filter::Simple');
    
    *Filter::Simple::import = sub {
        my $who = [caller]->[0];
        Carp::croak "Dear $who, source filters are _not_ a best practice!";
    }
}

### 3-part versions are evil
# CHECK {
#     for my $stash ( map { s|/|::|g; s/\.pm$//i; $_ } keys %INC ) {
# print "$stash -> " . $stash->VERSION . $/;
#     
#         
#         #my $version = *{"$stash->{VERSION}"}{'SCALAR'};
#         #warn "stash: $stash";
#         #my $version = *{"$stash"};
# 
#         #print "$pkg -> $$version\n";
#     }
# }    


1;
