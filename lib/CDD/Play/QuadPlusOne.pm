package CDD::Play::QuadPlusOne;
use Carp qw/confess/;
use Moo;
extends 'CDD::Play::FiveCard';

sub _validate {
    my ($class, $group) = @_;
    $class->SUPER::_validate($group);
    if (my $quad_one = $group->is_quad_plus_one) {
        return $quad_one;
    }
    confess "Not a valid quad+1";
}

1;
