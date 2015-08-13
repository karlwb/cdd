package CDD::Play;
use CDD::SimpleGroup;
use List::MoreUtils qw/all/;
use Carp qw/confess/;
use Moo;
with 'CDD::Group';

has size  => ( is => 'ro');
has val   => ( is => 'ro');
has highest => ( is => 'ro' );
has subgroup => ( is => 'ro' );

sub BUILDARGS {
    my ($class, @args) = @_;
    my $group = CDD::SimpleGroup->new(@args);
    my $validate = $class->_validate($group);
    my $cards;
    my $subgroup;
    my $valuate;
    if ( ref($validate->[0]) eq 'CDD::Card') {
        # non fullhouse, non quad+1 case
        $cards = $validate;
        $valuate = $cards;
    }
    else {
        # full house
        if(@{$validate->[0]} == 3) {
            $subgroup = { triple => $validate->[0],
                          pair   => $validate->[1],
                         };
            $valuate = $subgroup->{triple};
        }
        # quad+1
        else {
            $subgroup = { quad => $validate->[0],
                          single => $validate->[1],
                       };
            $valuate = $subgroup->{quad};
        }
        $cards  = [@{$validate->[0]}, @{$validate->[1]}];
    }
    $valuate = CDD::SimpleGroup->new($valuate);
    my $val   = $class->_valuate($valuate);
    my $highest = $class->_highest($valuate);
    return { cards=>$cards, 
             val=>$val, 
             size=>scalar(@{$cards}), 
             highest=>$highest,
             subgroup=>$subgroup,
           };
}

sub _validate { 
    confess "abstract" 
};

sub _valuate { 
    my ($class, $group) = @_;
    return -1; # todo
}

sub _highest {
    my ($class, $group) = @_;
    return $group->sort_by('val', 'desc')->cards->[0];
}

sub _3way_compare {
    shift->highest->val <=> shift->highest->val
}

use overload '<=>' => '_3way_compare';
use overload 'cmp' => '_3way_compare';

1;
