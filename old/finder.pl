# find all the groups in a hand
use warnings;
use strict;
use Data::Dumper; $Data::Dumper::Sortkeys=1;

my $CARDS = gen_cards();
my ($singles, $pairs, $triples, $straights, $flushes, $full_houses, $quads, $straight_flushes) 
	= find_all_groups_in_hand( keys %$CARDS );
print "singles:          " . scalar @{$singles} . "\n";
print "pairs:            " . scalar @{$pairs} . "\n";
print "triples:          " . scalar @{$triples} . "\n";
print "straights:        " . scalar @{$straights} . "\n";
print "flushes:          " . scalar @{$flushes} . "\n";
print "full houses:      " . scalar @{$full_houses} . "\n";
print "quads+1:          " . scalar @{$quads} . "\n";
print "straight flushes: " . scalar @{$straight_flushes} . "\n";


sub gen_cards {
	my @suits = qw/D C H S/;
	my @ranks = qw/3 4 5 6 7 8 9 10 J Q K A 2/;
	my %numeric_rank = ( 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9, 10=>10, J=>11, Q=>12, K=>13, A=>14, 2=>15 );
	my %numeric_suit = ( D=>0, C=>1, H=>2, S=>3 );

	my $cards = {};
	my $value = 1;
	foreach my $rank (@ranks) {
		foreach my $suit (@suits) {
			my $key = "$rank$suit";
			$cards->{$key} = { rank => $rank,
							   suit => $suit,
							   value => $value,
							   numeric_rank => $numeric_rank{$rank},
							   numeric_suit => $numeric_suit{$suit},
							 };
			$value++;
		}
	}
	return $cards;
}

sub find_all_groups_in_hand {
	my @cards = @_;
	@cards = sort { $CARDS->{$a}{value} <=> $CARDS->{$b}{value} } @cards;

	my $singles = _find_singles(@cards); 
	my ($pairs, $triples, $quads)  = _find_pairs_triples_quads($singles, @cards);
	my ($straights, $straight_flushes) = _find_straights_straightflushes(@cards);
	my $flushes = _find_flushes(@cards);
	my $full_houses = _find_full_houses($triples, $pairs);

	return ($singles, $pairs, $triples, $straights, $flushes, $full_houses, $quads, $straight_flushes);
}


sub _find_singles {
	my @cards = @_;

	my $singles = [];
	for (my $i=0; $i<@cards; $i++) {
		push @{$singles}, $cards[$i];
	}
	return $singles;
}

sub _find_pairs_triples_quads {
	my ($singles, @cards) = @_;

	my $pairs = [];
	my $triples = [];
	my $tmpquads = [];
	my $quads = [];

	for (my $i=0; $i<@cards; ) {
		my $skip = 0;
		# 2 cards in a row of same rank: 1 pair
		if ($i+1 < @cards and $CARDS->{$cards[$i]}{rank} eq $CARDS->{$cards[$i+1]}{rank}) {
			push @{$pairs}, [$cards[$i], $cards[$i+1]];
			$skip = 1;
		}
		# 3 cards in a row of same rank: 2 more pairs, 1 triple
		if ($i+2 < @cards and $CARDS->{$cards[$i]}{rank} eq $CARDS->{$cards[$i+2]}{rank}) {
			push @{$pairs}, [$cards[$i], $cards[$i+2]];
			push @{$pairs}, [$cards[$i+1], $cards[$i+2]];
			push @{$triples}, [$cards[$i], $cards[$i+1], $cards[$i+2]];
			$skip = 2;
		}
		# 4 cards in a row of same rank: 3 more pairs, 3 more triples, 1 quad
		if ($i+3 < @cards and $CARDS->{$cards[$i]}{rank} eq $CARDS->{$cards[$i+3]}{rank}) {
			push @{$pairs}, [$cards[$i], $cards[$i+3]];
			push @{$pairs}, [$cards[$i+1], $cards[$i+3]];
			push @{$pairs}, [$cards[$i+2], $cards[$i+3]];
			push @{$triples}, [$cards[$i], $cards[$i+1], $cards[$i+3]];
			push @{$triples}, [$cards[$i], $cards[$i+2], $cards[$i+3]];
			push @{$triples}, [$cards[$i+1], $cards[$i+2], $cards[$i+3]];
			push @{$tmpquads}, [$cards[$i], $cards[$i+1], $cards[$i+2], $cards[$i+3]];
			$skip = 3;
		}
		# skip over same ranking cards
		$i = $i + $skip + 1;
	}
	
	# permute each 4 of a kind and single card to create quads+1
	foreach my $quad (@{$tmpquads}) {
		foreach my $single (@{$singles}) {
			next if $CARDS->{$quad->[0]}{rank} eq $CARDS->{$single}{rank};
			push @{$quads}, [@{$quad}, $single];
		}
	}

	return ($pairs, $triples, $quads);
}

sub _find_straights_straightflushes {
	my @cards = @_;

	# generate a list of lists (lol) of cards grouped together by ranks
	# e.g.: [[3d,3c,3s], [4h], [8c,8s], [Jd], [2d] ]
	my $lol = [];
	my $lastrank = 0;
	for (my $i=0, my $j=-1; $i<@cards; $i++) {
		my $rank = $CARDS->{$cards[$i]}{rank};
		if ($rank ne $lastrank) {
			push @{$lol}, [$cards[$i]];
			$lastrank = $rank;
			$j++;
		}
		else {
			push @{$lol->[$j]}, $cards[$i];
		}
	}

	my $straights = [];
	my $straight_flushes = [];

	for (my $i=0; $i<@{$lol}; $i++) {
		my $rank = $CARDS->{$lol->[$i][0]}{numeric_rank};

		# straight found...
		if ($i+4 < @{$lol} 
			and $rank == $CARDS->{$lol->[$i+1][0]}{numeric_rank}-1
			and $rank == $CARDS->{$lol->[$i+2][0]}{numeric_rank}-2
			and $rank == $CARDS->{$lol->[$i+3][0]}{numeric_rank}-3
			and $rank == $CARDS->{$lol->[$i+4][0]}{numeric_rank}-4
		   ) {
			# permute for each card of each rank in straight
			foreach my $c0 (@{$lol->[$i]}) {
				foreach my $c1 (@{$lol->[$i+1]}) {
					foreach my $c2 (@{$lol->[$i+2]}) {
						foreach my $c3 (@{$lol->[$i+3]}) {
							foreach my $c4 (@{$lol->[$i+4]}) {
								# straight flush if suits are same
								if ($CARDS->{$c0}{suit} eq $CARDS->{$c1}{suit}
									and $CARDS->{$c1}{suit} eq $CARDS->{$c2}{suit}
									and $CARDS->{$c2}{suit} eq $CARDS->{$c3}{suit}
									and $CARDS->{$c3}{suit} eq $CARDS->{$c4}{suit}
								   ) {
									push @{$straight_flushes}, [$c0, $c1, $c2, $c3, $c4];
								}
								else {
									# standard straight
									push @{$straights}, [$c0, $c1, $c2, $c3, $c4];
								}
							}
						}
					}
				}
			}
		}
	}

	#print Data::Dumper->Dump([$straights, $straight_flushes], ["straights", "straight flushes"]);
	return ($straights, $straight_flushes);
}

sub _find_flushes {
	my @cards = @_;
	my $flushes = [];

	# group cards by suit, then by rank. They are already ordered by rank.
	my $suitcards = { D=>[], C=>[], H=>[], S=>[] };
	foreach my $card (@cards) {
		my $suit = $CARDS->{$card}{suit};
		push @{$suitcards->{$suit}}, $card;
	}
	
	# find flush permutations for all suits with >= 5 cards
	foreach my $suit (qw/D C H S/) {
		my @c =@{$suitcards->{$suit}};
		my $len = scalar @c;
		next if $len < 5;
		for (my $i1 = 0; $i1 < $len - 4; $i1++) {
			for (my $i2 = $i1 + 1; $i2 < $len - 3; $i2++) {
				for (my $i3 = $i2 + 1; $i3 < $len - 2; $i3++) {
					for (my $i4 = $i3 + 1; $i4 < $len - 1; $i4++) {
						for (my $i5 = $i4 + 1; $i5 < $len; $i5++ ) {
							my ($c1, $c2, $c3, $c4, $c5) = ($c[$i1], $c[$i2], $c[$i3], $c[$i4], $c[$i5]);
							# check for straight flush
							my @ranks = map { $CARDS->{$_}{numeric_rank} } ($c1, $c2, $c3, $c4, $c5);
							if ($ranks[0] == $ranks[1]-1 and $ranks[0] == $ranks[2]-2 and
								$ranks[0] == $ranks[3]-3 and $ranks[0] == $ranks[4]-4 ) {
								next;
							}
							push @{$flushes}, [$c1, $c2, $c3, $c4, $c5];
						}
					}
				}
			}
		}
	}

	return $flushes;
}

sub _find_full_houses {
	my ($triples, $pairs) = @_;
	my $full_houses = [];
	
	# permute all triple and pair combos
	foreach my $triple (@{$triples}) {
		foreach my $pair (@{$pairs}) {
			next if $CARDS->{$pair->[0]}{rank} eq $CARDS->{$triple->[0]}{rank};
			push @{$full_houses}, [@{$triple}, @{$pair}];
		}
	}
	return $full_houses;
}
