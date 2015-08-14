package CDD::Play::Flush;
use Carp qw/confess/;
use CDD::Val;
use Moo;
extends 'CDD::Play::FiveCard';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $class->SUPER::_validate($group);
    return $cards if exists $CDD::Val::FLUSH_VAL->{$group->key};
    confess "Not a valid flush";
}

sub _valuate {
    my ($class, $group) = @_;
    return $CDD::Val::FLUSH_VAL->{$group->key};
}

1;
