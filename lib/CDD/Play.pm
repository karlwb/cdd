package CDD::Play;
use CDD::Group;
use Carp qw/confess/;
use CDD::DB;

use Moo;
with 'CDD::Role::Group';

has id    => ( is => 'ro');
has size  => ( is => 'ro');
has val   => ( is => 'ro');
has type  => ( is => 'ro');

sub BUILDARGS {
    my ($class, @args) = @_;
    my $group = CDD::Group->new(@args);
    my $res = _get_from_db($group);
    return { cards =>$group->cards, 
             id    =>$res->{id},
             val   => $res->{value}, 
             size  => $res->{numcards}, 
             type  => $res->{name},
           };
}

sub _get_from_db {
    my $group = shift;
    my $q = q~select grp.id, 
                     grp.value,
                     grp.numcards,
                     grptype.name
              from grp
              join grptype on grptype.id = grp.grptype_id
             ~;
    my $i = 0;
    my @cards = map {$q .= "join grpcard g$i on g$i.grp_id = grp.id and g$i.card_id = ?\n";
                     $i++;
                     $_->as_string;
                 } @{$group->cards};
    $q .= 'where grp.numcards = ?';
    
    my $res = CDD::DB->instance->sql->db->query($q, @cards, scalar(@cards))->hashes;
    confess "Not a valid play: @cards: too many results" unless @{$res//[]} == 1;
    return $res->[0];
}

sub _3way_compare {
    my ($a, $b) = @_;
    confess "Cannot compare plays with " . $a->size . " and " . $b->size . " cards"
        if ( $a->size != $b->size );
    return $a->val <=> $b->val
}

use overload '<=>' => '_3way_compare';
use overload 'cmp' => '_3way_compare';

1;
