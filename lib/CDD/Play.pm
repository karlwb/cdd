package CDD::Play;
use CDD::SimpleGroup;
use List::MoreUtils qw/all/;
use Carp qw/confess/;
use Moo;
with 'CDD::Group';

has size  => ( is => 'ro');
has val   => ( is => 'ro');
            
sub BUILDARGS {
    my ($class, @args) = @_;
    my $group = CDD::SimpleGroup->new(@args);
    my $cards = $class->validate($group);
    my $val   = $class->valuate($group);
    return { cards=>$cards, val=>$val, size=>scalar(@{$cards}) };
}

sub validate { confess "abstract" };
sub valudate { confess "abstract" };
sub _3way_compare { confess "abstract" };

1;
