package CDD::Play::QuadPlusOne;
use Carp qw/confess/;
use CDD::Val;
use Moo;
extends 'CDD::Play::FiveCard';

sub _validate {
    my ($class, $group) = @_;
    $class->SUPER::_validate($group);
    return $group->cards if $group->is_quad_plus_one and exists $CDD::Val::QUAD_VAL->{$group->key};
    confess "Not a valid quad+1";
}

sub _valuate {
    my ($class, $group) = @_;
    return $CDD::Val::QUAD_VAL->{$group->key};
}

1;
