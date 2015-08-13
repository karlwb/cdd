package CDD::Play::Straight;
use Carp qw/confess/;
use Moo;
extends 'CDD::Play::FiveCard';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $class->SUPER::_validate($group);
    return $cards if $group->is_run and not $group->is_same_suit;
    confess "Not a valid straight";
}

1;
