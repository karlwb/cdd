package CDD::Play::Flush;
use Carp qw/confess/;
use Moo;
extends 'CDD::Play::FiveCard';

sub _validate {
    my ($class, $group) = @_;
    my $cards = $class->SUPER::_validate($group);
    return $cards if $group->is_same_suit and not $group->is_run;
    confess "Not a valid flush";
}

1;
