package CDD::Play::FullHouse;
use Carp qw/confess/;
use CDD::Val;
use Moo;
extends 'CDD::Play::FiveCard';

sub _validate {
    my ($class, $group) = @_;
    $class->SUPER::_validate($group);
    return $group->cards if $group->is_full_house and exists $CDD::Val::FULLHOUSE_VAL->{$group->key};
    confess "Not a valid full house";
}

sub _valuate {
    my ($class, $group) = @_;
    return $CDD::Val::FULLHOUSE_VAL->{$group->key};
}

1;
