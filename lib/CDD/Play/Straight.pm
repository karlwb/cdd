package CDD::Play::Straight;
use Carp qw/confess/;
use CDD::Val;
use Moo;
extends 'CDD::Play::FiveCard';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $class->SUPER::_validate($group);
    return $cards if $group->is_run and not $group->is_same_suit and exists $CDD::Val::STRAIGHT_VAL->{$group->key};
    confess "Not a valid straight";
}

sub _valuate {
    my ($class, $group) = @_;
    return $CDD::Val::STRAIGHT_VAL->{$group->key};
}

1;
