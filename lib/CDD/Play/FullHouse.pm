package CDD::Play::FullHouse;
use Carp qw/confess/;
use Moo;
extends 'CDD::Play::FiveCard';

sub _validate {
    my ($class, $group) = @_;
    $class->SUPER::_validate($group);
    if (my $triple_pair = $group->is_full_house) {
        return $triple_pair;
    }
    confess "Not a valid full house";
}

1;
