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

sub _validate { confess "abstract" };
sub _valudate { confess "abstract" };
sub _highest  { confess "abstract" };
sub _3way_compare { confess "abstract" };

1;
