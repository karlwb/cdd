package CDD::Play::StraightFlush;
use Carp qw/confess/;
use Moo;
use CDD::Card;
extends 'CDD::Play::FiveCard';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $class->SUPER::_validate($group);
    return $cards if $group->is_run and $group->is_same_suit;
    confess "Not a valid straight flush";
}

1;
