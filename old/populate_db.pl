use warnings;
use strict;
use Data::Dumper;
$Data::Dumper::Sortkeys=1;
use DBI;

our @ranks = qw/3 4 5 6 7 8 9 10 J Q K A 2/;
our @suits = qw/D C H S/;

# each group of cards you can play has a unique id according to our db schema
# every time we generate a group this is incremented
our $GROUPID = 1; 

# each possible group for a given play type (singles, pairs, triples, fivers) has
# a value in the game. A given value may be assigned to many groups  
our $VALUE   = 0;

# lists of what we generated...not necessarily used
our @singles = ();
our @pairs = ();
our @triples = ();
our @straights = ();
our @flushes = ();
our @full_houses = ();
our @quads = ();
our @straight_flushes = ();

# SQLite stuff for creating database, tables, and populating everything
our $SQLITE_DB_FILE = "/home/karl/cdd/big2.db";
our $dbh = DBI->connect("dbi:SQLite:dbname=$SQLITE_DB_FILE", "", "", {RaiseError=>1, PrintError=>0});


# stuff for inserting into the card, grp, grpcard tables...
#our $dbh = DBI->connect("dbi:mysql:host=localhost;database=big2", "root", "");
our $sth_card = undef; # $dbh->prepare("insert into card (id, tag, rank,suit_id,value) values (?,?,?,?,?)");
our $sth_group = undef; # $dbh->prepare("insert into grp (id, numcards, grptype_id, value) values (?,?,?,?)");
our $sth_groupcard = undef; # $dbh->prepare("insert into grpcard (grp_id, card_id) values (?,?)");
our $sth_grpavail = undef;

main(); 
exit 0;

sub main {
    # ----------------------------------------------------------------------------------
	# create database schema
    # ----------------------------------------------------------------------------------
	create_sqlite_schema();
	$sth_card = $dbh->prepare("insert into card (id, rank,suit_id,value) values (?,?,?,?)");
	$sth_group = $dbh->prepare("insert into grp (id, numcards, grptype_id, value) values (?,?,?,?)");
	$sth_groupcard = $dbh->prepare("insert into grpcard (grp_id, card_id) values (?,?)");
	$sth_grpavail  = $dbh->prepare("insert into grpavail (grp_id, available) values (?,1)");

	$dbh->begin_work();
    # ----------------------------------------------------------------------------------
	# populate cards table
    # ----------------------------------------------------------------------------------
	gen_cards();   

    # ----------------------------------------------------------------------------------
	# populate grpcards and grps tables (the cards in a group, and the group info)
    # ----------------------------------------------------------------------------------

	# singles have their own values
	$VALUE=1;      
	gen_singles();

	# pairs have their own values
	$VALUE=1;
	gen_pairs();

	# triples have their own values
	$VALUE=1;
	gen_triples();

	# fivers have their own values, shared amongst straights, flushes,
	# full houses, quads, and straight flushes
	$VALUE=1;
	gen_straights();
	gen_flushes();
	gen_full_houses();
	gen_quads();
	gen_straight_flushes();

	$dbh->commit();
}

sub create_sqlite_schema {
	# queries...

	my $card = '
create table card (
  id       text not null primary key,
  rank     integer not null,
  suit_id  text not null,
  value    integer not null
)
';
	my $grp = '
create table grp (
  id           integer not null primary key,
  numcards     integer not null,
  grptype_id   integer not null,
  value        integer not null
)
';

	my $grpcard = '
create table grpcard (
  card_id       integer not null,
  grp_id        integer not null,
  primary key (card_id, grp_id)
)
';

	my $grptype = '
create table grptype (
  id     integer not null primary key,
  name   text not null
)
';

	my $suit = '
create table suit (
  id   text not null primary key,
  name text not null,
  rank integer not null
)
';

	my $grpavail = '
create table grpavail (
  grp_id integer not null primary key,
  available integer not null
)
';

	# drop tables if they exist already
	for my $table ( qw/card grp grpcard grptype suit grpavail/) {
		my $query = "drop table if exists $table";
		my $sth = $dbh->prepare($query);
		$sth->execute();
	}

	# create tables;
	for my $query  ( ($card, $grp, $grpcard, $grptype, $suit, $grpavail) ) {
		#print $query . "\n";
		my $sth = $dbh->prepare($query);
		$sth->execute();
	}

	# populate suit
	my @suit_data = (['D', 'diamonds', 1],
					 ['C', 'clubs', 2],
					 ['H', 'hearts', 3],
					 ['S', 'spades', 4],
					);

	my $sth_suit = $dbh->prepare("insert into suit (id, name, rank) values (?, ?, ?)");
	foreach my $x (@suit_data) {
		$sth_suit->execute($x->[0], $x->[1], $x->[2]);
	}

	# populate grptype
	my @grptype_data = ([1, 'single'],
						[2, 'pair'],
						[3, 'triple'],
						[4, 'straight'],
						[5, 'flush'],
						[6, 'full house'],
						[7, 'quad+1'],
						[8, 'straight flush'],
					   );
		
	my $sth_grptype = $dbh->prepare("insert into grptype (id, name) values (?, ?)");
	foreach my $x (@grptype_data) {
		$sth_grptype->execute($x->[0], $x->[1]);
	}						 

}


# populates card table
sub gen_cards {
	my $val=1;
	for my $r (@ranks) {
		for my $s (@suits) {
			# db insert
			$sth_card->execute("$r$s", $r, $s, $val);
			$val++;
		}
	}
}

# populates grp, grpcard tables with singles
sub gen_singles {
	my $type = "single";
	my $numcards = 1;
	my $grouptype = 1;
	for my $r (@ranks) {
		for my $s (@suits) {
			my $c = "$r$s";

			# db inserts
			$sth_group->execute($GROUPID, $numcards, $grouptype, $VALUE);
			$sth_grpavail->execute($GROUPID);
			$sth_groupcard->execute($GROUPID, $c);

			push @singles, [$c];
			print "$type: $c val:$VALUE, group: $GROUPID\n";
			$VALUE++;
			$GROUPID++;
		}
	}

	
}

# populates grp, grpcard tables with pairs
sub gen_pairs {
	my $type = "pair";
	my $numcards = 2;
	my $grouptype = 2;

	my $valsuits = { 0 => [[qw/D C/],], # club high
					 1 => [[qw/D H/], [qw/C H/]], # heart high
					 2 => [[qw/D S/], [qw/C S/], [qw/H S/]], #spade high
				   };
	my $newval=0;
	for my $r (@ranks) {
		foreach my $val (sort keys %{$valsuits}) {
			$newval = $val;
			for my $group (@{$valsuits->{$newval}}) {
				my $printval = $VALUE+$newval;
				my ($s1, $s2) = @{$group};
				my ($c1, $c2) = ("$r$s1", "$r$s2");

				# db inserts
				$sth_group->execute($GROUPID, $numcards, $grouptype, $VALUE);
				$sth_grpavail->execute($GROUPID);
				$sth_groupcard->execute($GROUPID, $c1);
				$sth_groupcard->execute($GROUPID, $c2);

				push @pairs, [$c1,$c2];
				print "$type: $c1,$c2 val:$printval, group:$GROUPID\n";
				$GROUPID++;
			}
		}
		$VALUE = $VALUE+$newval+1;
	}
}

# populates grp, grpcard tables with triples
sub gen_triples {
	my $type = "triple";
	my $numcards = 3;
	my $grouptype = 3;

	my $valsuits = { 0 => [[qw/D C H/], [qw/D C S/], [qw/D H S/], [qw/C H S/]],  
				   };
	my $newval = 0;
	for my $r (@ranks) {
		for my $val (sort keys %{$valsuits}) {
			$newval = $val;
			for my $group (@{$valsuits->{$newval}}) {
				my $printval = $VALUE+$newval;
				my ($s1, $s2, $s3) = @{$group};
				my ($c1,$c2,$c3) = ("$r$s1", "$r$s2", "$r$s3");
				push @triples, [$c1,$c2,$c3];
				print "$type: $c1,$c2,$c3 val:$printval, group:$GROUPID\n";

				# db inserts
				$sth_group->execute($GROUPID, $numcards, $grouptype, $VALUE);
				$sth_grpavail->execute($GROUPID);
				$sth_groupcard->execute($GROUPID, $c1);
				$sth_groupcard->execute($GROUPID, $c2);
				$sth_groupcard->execute($GROUPID, $c3);

				$GROUPID++;
			}
		}
		$VALUE = $VALUE+$newval+1;
	}
}

# populates grp, grpcard tables with straights
sub gen_straights {
	my $type = "straight";
	my $numcards = 5;
	my $grouptype = 4;
	
	for (my $i=4; $i<13; $i++) { # highcard rank index:  5's up to 2's 
		for my $s5 (@suits) {  # 5th in group, highest ranking card's suit
			for my $s4 (@suits) { 
				for my $s3 (@suits) { 
					for my $s2 (@suits) {
						for my $s1 (@suits) { # 1st in group, lowest ranking card's suit
							# ranks in group
							my $start=$i-4;
							my $stop =$i;
							my ($r1, $r2, $r3, $r4, $r5) = @ranks[$start..$stop];

							my ($c1,$c2,$c3,$c4,$c5) = ("$r1$s1", "$r2$s2", "$r3$s3", "$r4$s4", "$r5$s5");

							# straight flushes...
							if (($s1 eq $s2) and ($s2 eq $s3) and ($s3 eq $s4) and ($s4 eq $s5)) {
								push @straight_flushes, [$c1,$c2,$c3,$c4,$c5];
								next;
							}

							push @straights, [$c1,$c2,$c3,$c4,$c5];
							print "$type: $c1,$c2,$c3,$c4,$c5 val:$VALUE, group:$GROUPID\n";

							# db inserts
							$sth_group->execute($GROUPID, $numcards, $grouptype, $VALUE);
							$sth_grpavail->execute($GROUPID);
							$sth_groupcard->execute($GROUPID, $c1);
							$sth_groupcard->execute($GROUPID, $c2);
							$sth_groupcard->execute($GROUPID, $c3);
							$sth_groupcard->execute($GROUPID, $c4);
							$sth_groupcard->execute($GROUPID, $c5);

							$GROUPID++;
						}
					}
				}
			}
			# value increases when highcard suit changes
			$VALUE++;

		}
	}
	$VALUE--; # off by one otherwise...
}

# populates grp, grpcard tables with flushes
sub gen_flushes {
	my $type = "flush";
	my $numcards = 5;
	my $grouptype = 5;

	my %flush = ();
	my $valsuit = { D => 1,
					C => 9,
					H => 17,
					S => 25,
				  };
					
	my $flushes = {};
	my $start_value = $VALUE;

	foreach my $s (@suits) {
		for my $ri1 (0..12) { # lowest rank index
			for my $ri2 (0..12){ 
				for my $ri3 (0..12) {
					for my $ri4 (0..12) {
						for my $ri5 (0..12) { # highest rank index
							my @indices = sort {$a<=>$b} ($ri1, $ri2, $ri3, $ri4, $ri5);
							my ($i1,$i2,$i3,$i4,$i5) = @indices;
							if ($i1 == $i2 or $i2 == $i3 or $i3 == $i4 or $i4 == $i5) {
								next; # impossible combo
							}
							if ($i2 == $i1+1 and $i3 == $i2+1 and $i4 == $i3+1 and $i5 == $i4+1) {
								next; # straight flush
							}
							my $key = join("", @indices) . "$s";
							
							if ( exists $flush{$key} ) {
								next;
							}
							else {
								$flush{$key}++;
								my ($r1, $r2, $r3, $r4, $r5) = @ranks[@indices];

								# there are only 32 cdd values, based on the highest card in a group of each
								# suit. d,c,h,s; 8 to 2 (8 cards) for each of 4 suits (8*4=32)
								my $val = ($i5-5)+$valsuit->{$s};
								$VALUE = $start_value+$val;

								my ($c1, $c2, $c3, $c4, $c5) = ("$r1$s", "$r2$s", "$r3$s", "$r4$s", "$r5$s");
								push @{$flushes->{$val}}, [$c1,$c2,$c3,$c4,$c5];
								print "$type: $c1,$c2,$c3,$c4,$c5 val:$VALUE, group:$GROUPID\n";

								# db inserts
								$sth_group->execute($GROUPID, $numcards, $grouptype, $VALUE);
								$sth_grpavail->execute($GROUPID);
								$sth_groupcard->execute($GROUPID, $c1);
								$sth_groupcard->execute($GROUPID, $c2);
								$sth_groupcard->execute($GROUPID, $c3);
								$sth_groupcard->execute($GROUPID, $c4);
								$sth_groupcard->execute($GROUPID, $c5);

								$GROUPID++;

							} #else
						} #ri1
					} #ri2
				} #ri3
			} # ri4
		} #ri5
	} # suits
	for my $v (1..32) {
		foreach my $group (@{$flushes->{$v}}) {
			push @flushes, $group;
		}
	}
	#print Data::Dumper->Dump([$flushes], ["flushes"]);
}

# populates grp, grpcard tables with full houses
sub gen_full_houses {
	my $type = "full house";
	my $numcards = 5;
	my $grouptype = 6;

	my $x = 0;
	foreach my $triple (@triples) {
		my ($t1, $t2, $t3) = @{$triple};
		foreach my $pair (@pairs) {
			my ($p1, $p2) = @{$pair};
			my ($tr, $ts, $t_extra) = split //, $t1;
			my ($pr, $ps, $p_extra) = split //, $p1;

			#10 is special case since it has 3 chars...not a 2 char rank/suit
			if ($tr eq '1' and $ts eq '0') {
				$tr = 10;
				$ts = $t_extra;
			}
			if ($pr eq '1' and $ps eq '0') {
				$pr = 10;
				$ps = $p_extra;
			}

			next if $pr eq $tr;
			if ( $x ne $tr ) {
				$VALUE++; # value increases as triple changes, low to high
				$x = $tr;
			}
			my ($c1, $c2, $c3, $c4, $c5) = ($t1, $t2, $t3, $p1, $p2);
			push @full_houses, [$c1, $c2, $c3, $c4, $c5];
			print "$type: $c1,$c2,$c3,$c4,$c5 val:$VALUE, group:$GROUPID\n";

			# db inserts
			$sth_group->execute($GROUPID, $numcards, $grouptype, $VALUE);
			$sth_grpavail->execute($GROUPID);
			$sth_groupcard->execute($GROUPID, $c1);
			$sth_groupcard->execute($GROUPID, $c2);
			$sth_groupcard->execute($GROUPID, $c3);
			$sth_groupcard->execute($GROUPID, $c4);
			$sth_groupcard->execute($GROUPID, $c5);			

			$GROUPID++;
		}
	}
	
}
 
# populates grp, grpcard tables with quads
sub gen_quads {
	my $type = "quad";
	my $numcards = 5;
	my $grouptype = 7;

	my $x = 0;
	foreach my $r (@ranks) {
		foreach my $sa (@singles) {
			my $s = $sa->[0];
			my ($sr, $ss, $s_extra) = split //, $s;
			#10 is special case since it has 3 chars...not a 2 char rank/suit
			if ($sr eq '1' and $ss eq '0') {
				$sr = 10;
				$ss = $s_extra;
			}

			next if ($sr eq $r);

			my ($c1,$c2, $c3, $c4, $c5) = ("${r}D", "${r}C", "${r}H", "${r}S", $s);
			if ( $x ne $r ) {
				$VALUE++; # value goes up as rank changes 3 up to 2
				$x = $r;
			}
			push @quads, [$c1,$c2,$c3,$c4,$c5];
			print "$type: $c1,$c2,$c3,$c4,$c5 val:$VALUE, group:$GROUPID\n";

			# db inserts
			$sth_group->execute($GROUPID, $numcards, $grouptype, $VALUE);
			$sth_grpavail->execute($GROUPID);
			$sth_groupcard->execute($GROUPID, $c1);
			$sth_groupcard->execute($GROUPID, $c2);
			$sth_groupcard->execute($GROUPID, $c3);
			$sth_groupcard->execute($GROUPID, $c4);
			$sth_groupcard->execute($GROUPID, $c5);						

			$GROUPID++;
		}
	}

	$VALUE++; # off by one otherwise
}

# populates grp, grpcard tables with straight flushes
sub gen_straight_flushes {
	my $type = "straight flush";
	my $numcards = 5;
	my $grouptype = 8;


	foreach my $cards (@straight_flushes) {
		my ($c1,$c2,$c3,$c4,$c5) = @{$cards};
		print "$type: $c1,$c2,$c3,$c4,$c5 val:$VALUE, group:$GROUPID\n";

		# db inserts
		$sth_group->execute($GROUPID, $numcards, $grouptype, $VALUE);
		$sth_grpavail->execute($GROUPID);
		$sth_groupcard->execute($GROUPID, $c1);
		$sth_groupcard->execute($GROUPID, $c2);
		$sth_groupcard->execute($GROUPID, $c3);
		$sth_groupcard->execute($GROUPID, $c4);
		$sth_groupcard->execute($GROUPID, $c5);					

		$VALUE++;
		$GROUPID++;
	}
}
