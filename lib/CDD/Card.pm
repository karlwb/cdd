package CDD::Card;
use Moo;

has rank => (is => 'ro', 
             required => 1,
             isa => sub{ die unless $_[0] =~ m/^[2-9JQKA]|10$/i },
             coerce => sub { uc $_[0] },
            );
has suit => (is => 'ro', 
             required=>1,
             isa => sub{ die unless $_[0] =~ m/^[DCHS]$/i },
             coerce => sub { uc $_[0] },
            );
has val  => (is => 'ro', 
             required=>1,
             isa => sub { die if ($_[0] !~ m/^\d+$/ 
                                  or $_[0] < 1 
                                  or $_[0] > 52) 
                      },
            );

use overload '""' => \&as_string;

sub as_string{ 
    $_[0]->rank . $_[0]->suit 
};
    
1;

