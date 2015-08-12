package CDD::Play;
use CDD::SimpleGroup;
use List::MoreUtils qw/all/;
use Carp qw/confess/;
use Moo;
with 'CDD::Group';

has size  => ( is => 'ro');
has val   => ( is => 'ro');
has highest => ( is => 'ro' );
            
sub BUILDARGS {
    my ($class, @args) = @_;
    my $group = CDD::SimpleGroup->new(@args);
    my $cards = $class->_validate($group);
    my $val   = $class->_valuate($group);
    my $highest = $class->_highest($group);
    return { cards=>$cards, 
             val=>$val, 
             size=>scalar(@{$cards}), 
             highest=>$highest 
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
