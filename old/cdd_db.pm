use warnings;
use strict;
use DBI;
use Data::Dumper;
$Data::Dumper::Sortkeys=1;

our $dbh = DBI->connect("dbi:SQLite:dbname=big2.db", "", "", {RaiseError=>1, PrintError=>0, AutoCommit=>1});


#print find_grpid_for_cards( qw/5D 6D 7D/ ) . "\n";
find_number_of_available_groups_for_size_excluding_cards(2, qw/3D 3C 4H 5S JD 2S 2C/);


# this resets the availability of all groups of cards to 1, meaning 'available'
# think: end of a round 
sub reset_available {
	my $q = 'update grpavail set available=1';
	my $sth = $dbh->prepare($q);
	$sth->execute();
}

# this effectively "plays" 1 or more cards
# it updates the grpavail table and sets the availability of any groups the card is a member of to 0,
# meaning 'unavailable' 
sub update_available_for_cards {
	my @cards = @_;
	my $q = 'update grpavail set available=0 where grp_id in (select grp_id from grpcard gc where gc.card_id = ?)';
	my $sth = $dbh->prepare($q);
	$dbh->begin_work();
	foreach my $card (@cards) {
		$sth->execute($card);
	}
	$dbh->commit();
}

# determines if a group of cards is a valid play
# by checking to see if it can find a groupid it's in
# returns undef if it's invalid group of cards
# returns groupid (always >=1, so true) if it is valid group of cards
sub is_valid_group_of_cards {
	my $grpid = undef;
	eval {
		$grpid = find_grpid_for_cards(@_);
	};
		
	return $grpid;
}

# given a group of cards (list), returns the group id they are all in
# Dies if:
#    1. invalid card list size 
#    2. not a valid group of cards to play
sub find_grpid_for_cards {
	my @cards = @_;
	my $sizes = { 1=>1, 2=>1, 3=>1,  5=>1};
	my $size = scalar @cards;
	if (!exists $sizes->{$size}) {
		die "invalid number of cards in group ($size) for cards " . join(",", @cards);
	}
	my $q = "select grp.id from grp";
	my @where = ();
	for (my $i=0; $i<$size; $i++) {
		$q .= ", grpcard g$i"; 
		push @where, "g$i.grp_id = grp.id"; # same groupid
		push @where, "g$i.card_id = '$cards[$i]'"; # given card
	}
	$q .= " where " . join (" and ", @where) . " and grp.numcards = $size";
	#print $q;
	my $sth = $dbh->prepare($q);
	$sth->execute();
	my @row = $sth->fetchrow_array();
	my $ret = $row[0];
	if (!defined $ret) {
		die "couldn't find grpid for cards " . join(",", @cards) . "query: $q";
	}
	return $ret;
}

# given a groupid, return its value
sub find_group_value {
	my $groupid = shift;
	my $q = "select value from grp where id = $groupid";
	my $sth = $dbh->prepare($q);
	$sth->execute();
	my @row = $sth->fetchrow_array();
	my $ret = $row[0];
	if (!defined $ret) {
		die "couldn't find value for groupid $groupid. query: $q";
	}
	return $ret;
}

# given a size, returns the number of groups available
sub find_number_of_available_groups_for_size {
	my $size = shift;

	my $q = "select count(*) from grpavail, grp where grpavail.grp_id = grp.id and and grpavail.available=1 and grp.numcards = $size";
	my $sth = $dbh->prepare($q);
	$sth->execute();
	my @row = $sth->fetchrow_array();
	my $ret = $row[0];
	if (!defined $ret) {
		die "couldn't find number of $size sized groups. query: $q";
	}
	return $ret;
	
}

# given a size and a list of cards (say in your hand), returns the number of groups available, excluding those in cards
sub find_number_of_available_groups_for_size_excluding_cards {
	my $size = shift;
	my @cards = @_;

	my $cards = join(", ", map {"'$_'"} @cards);
	my $q = "select count(*) from grpavail, grp where grpavail.grp_id = grp.id and grpavail.available=1 and grp.numcards = $size and grp.id not in (select distinct grp_id from grpcard where card_id in ($cards))";
	#print $q;
	my $sth = $dbh->prepare($q);
	$sth->execute();
	my @row = $sth->fetchrow_array();
	my $ret = $row[0];
	if (!defined $ret) {
		die "couldn't find number of $size sized groups excluding cards $cards. query: $q";
	}
	return $ret;

}

# given the size of a play, and a group's value
# returns the number of available groups with an equal value to
# the given size and value
sub find_number_of_available_groups_with_equal_value {
	my ($size, $value) = @_;
	my $q = "select count(*) from grpavail, grp where grpavail.grp_id = grp.id and and grpavail.available=1 and grp.numcards = $size and grp.value = $value";
	my $sth = $dbh->prepare($q);
	$sth->execute();
	my @row = $sth->fetchrow_array();
	my $ret = $row[0];
	if (!defined $ret) {
		die "couldn't find number of $size sized groups = value $value. query: $q";
	}
	return $ret;
}

# given a size of a play, a group's value, and a list of cards (say in your hand)
# returns the number of available groups with an equal value to
# the given size and value, that do not have the given cards as members
sub find_number_of_available_groups_with_equal_value_excluding_cards {
	my ($size, $value, @cards) = @_;

	my $cards = join(", ", map {"'$_'"} @cards);
	my $q = "select count(*) from grpavail, grp where grpavail.grp_id = grp.id and and grpavail.available=1 and grp.numcards = $size and grp.value = $value and grp.id not in (select distinct grp_id from grpcard where card_id in ($cards))";
	my $sth = $dbh->prepare($q);
	$sth->execute();
	my @row = $sth->fetchrow_array();
	my $ret = $row[0];
	if (!defined $ret) {
		die "couldn't find number of $size sized groups > value $value excluding cards $cards. query: $q";
	}
	return $ret;
}


# given the size of a play, and a group's value
# returns the number of available groups with a higher value than
# the given size and value
sub find_number_of_available_groups_with_higher_value_than {
	my ($size, $value) = @_;
	my $q = "select count(*) from grpavail, grp where grpavail.grp_id = grp.id and and grpavail.available=1 and grp.numcards = $size and grp.value > $value";
	my $sth = $dbh->prepare($q);
	$sth->execute();
	my @row = $sth->fetchrow_array();
	my $ret = $row[0];
	if (!defined $ret) {
		die "couldn't find number of $size sized groups > value $value. query: $q";
	}
	return $ret;
}

# given a size of a play, a group's value, and a list of cards (say in your hand)
# returns the number of available groups with a higher value than
# the given size and value, that do not have the given cards as members
sub find_number_of_available_groups_with_higher_value_excluding_cards {
	my ($size, $value, @cards) = @_;

	my $cards = join(", ", map {"'$_'"} @cards);
	my $q = "select count(*) from grpavail, grp where grpavail.grp_id = grp.id and and grpavail.available=1 and grp.numcards = $size and grp.value > $value and grp.id not in (select distinct grp_id from grpcard where card_id in ($cards))";
	my $sth = $dbh->prepare($q);
	$sth->execute();
	my @row = $sth->fetchrow_array();
	my $ret = $row[0];
	if (!defined $ret) {
		die "couldn't find number of $size sized groups > value $value excluding cards $cards. query: $q";
	}
	return $ret;
}

# given the size of a play, and a value
# returns the number of available plays with a lower value
sub find_number_of_available_groups_with_lower_value_than {
	my ($size, $value) = @_;
	my $q = "select count(*) from grpavail, grp where grpavail.grp_id = grp.id and and grpavail.available=1 and grp.numcards = $size and grp.value < $value";

	my $sth = $dbh->prepare($q);
	$sth->execute();
	my @row = $sth->fetchrow_array();
	my $ret = $row[0];
	if (!defined $ret) {
		die "couldn't find number of $size sized groups > value $value. query: $q";
	}
	return $ret;
}

# given a size of a play, a group's value, and a list of cards (say in your hand)
# returns the number of available groups with a lower value than
# the given size and value, that do not have the given cards as members
sub find_number_of_available_groups_with_lower_value_excluding_cards {
	my ($size, $value, @cards) = @_;

	my $cards = join(", ", map {"'$_'"} @cards);
	my $q = "select count(*) from grpavail, grp where grpavail.grp_id = grp.id and and grpavail.available=1 and grp.numcards = $size and grp.value < $value and grp.id not in (select distinct grp_id from grpcard where card_id in ($cards))";
	my $sth = $dbh->prepare($q);
	$sth->execute();
	my @row = $sth->fetchrow_array();
	my $ret = $row[0];
	if (!defined $ret) {
		die "couldn't find number of $size sized groups < value $value excluding cards $cards. query: $q";
	}
	return $ret;
}
