package CDD::Play;
use CDD::Group;
use List::MoreUtils qw/all/;
use Carp qw/confess/;
use CDD::DB;
use Data::Dump qw/pp/;

my %typename = (
    'CDD::Play::Single'        => 'single',
    'CDD::Play::Pair'          => 'pair',
    'CDD::Play::Triple'        => 'triple',
    'CDD::Play::Straight'      => 'straight',
    'CDD::Play::Flush'         => 'flush',
    'CDD::Play::FullHouse'     => 'full house',
    'CDD::Play::QuadPlusOne'   => 'quad+1',
    'CDD::Play::StraightFlush' => 'straight flush',
);

use Moo;
with 'CDD::Role::Group';

has id    => ( is => 'ro');
has size  => ( is => 'ro');
has val   => ( is => 'ro');
has type  => ( is => 'ro');
has highest => ( is => 'ro' );

sub BUILDARGS {
    my ($class, @args) = @_;
    my $group = CDD::Group->new(@args);
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
    
    my $res = CDD::DB->new->sql->db->query($q, @cards, scalar(@cards))->hashes;
    confess "Not a valid play: @cards: too many cards" unless @{$res//[]} == 1;
    confess "Not a valid play: @cards: type for $class wrong: " . pp($res->[0]{name}) 
        unless $typename{$class} eq $res->[0]{name};
    return { cards=>$group->cards, 
             id=>$res->[0]{id},
             val=>$res->[0]{value}, 
             size=>$res->[0]{numcards}, 
             type=>$res->[0]{name},
           };
}

sub _3way_compare {
    shift->val <=> shift->val
}

use overload '<=>' => '_3way_compare';
use overload 'cmp' => '_3way_compare';

1;
