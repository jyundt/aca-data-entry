#!/usr/bin/perl
#
# Quick and dirty script to ingest json documents
# and insert them into a postgres schema

use JSON;
use YAML;
use strict;
use warnings;
use DBI;
use utf8;
use Data::Dumper;

binmode(STDOUT, ":utf8");


#Establish our DB connection
my $dbh = DBI->connect("DBI:Pg:dbname=oval;host=localhost", "postgres", "", {'RaiseError' => 1});


#Sanity check our command line arguments

if ($#ARGV != 0) {
	print "Error, did not specify a JSON file.\n\n";
	print "Usage: $0 [json file]\n";
	exit 1;
}

#Read in a file
print "Reading json file...";
our $json_text;
{
  local $/; #Enable 'slurp' mode
  open my $fh, "<", "$ARGV[0]" or print "FAILED!\n" and exit 1;
  $json_text = <$fh>;
}
print "COMPLETE\n";
  

#Convert the file into a hash
my $race_hash = decode_json($json_text);


print "Checking to see if category \"$race_hash->{'category'}\" exists...";
#We want to start by verifying if our race category/ID exists

my $query = $dbh->prepare("SELECT * FROM race_class WHERE race_class_description='$race_hash->{'category'}'");
if  ($query->execute <1){
	print "COMPLETE\n";
	print "Adding category \"$race_hash->{'category'}\" to DB...";
	#If our ID doesn't exist, we add it to "race_class" table
	if ($dbh->do("INSERT INTO race_class (race_class_description) VALUES ('$race_hash->{'category'}')")){
		print "COMPLETE\n";
	}else{
		print "FAILED!\n";
		exit 1;
	}
	
}else{
	print "COMPELTE\n";
}

#Query our category ID (race_class_id) from the DB
my $race_class_id = pop($dbh->selectcol_arrayref("SELECT race_class_id FROM race_class WHERE race_class_description='$race_hash->{'category'}'"));

#Start building our insert string for adding a row to the "race" table
my $race_date = $race_hash->{'date'};



##Unfortunately our input data lacks some accuracy
##so there are some races where we don't have lap times, # of laps, etc.
##in these case, I'm going to get it to zero.
#
#sorry
#
my $race_slow_lap = $race_hash->{'slow_lap'};
if ($race_slow_lap eq ""){
	$race_slow_lap = "0:00";
}

my $race_fast_lap = $race_hash->{'fast_lap'};
if ($race_fast_lap eq ""){
	$race_fast_lap = "0:00";
}
my $race_average_lap = $race_hash->{'avg_lap'};
if ($race_average_lap eq ""){
	$race_average_lap = "0:00";
}
my $race_weather = $race_hash->{'weather'};
if ($race_weather eq ""){
	$race_weather= "unknown";
}
my $race_laps = $race_hash->{'laps'};
if ($race_laps eq ""){
	$race_laps = "0";
}
my $race_usac_permit = $race_hash->{'usac_permit'};



print "Adding row to \"race\" table...";
#Insert our race information to "race" table
my $race_id = pop($dbh->selectcol_arrayref("INSERT INTO race (race_date, race_slow_lap, race_fast_lap, race_average_lap, race_weather, race_laps, race_usac_permit, race_class_id)
   VALUES ('$race_date', '$race_slow_lap', '$race_fast_lap', '$race_average_lap', '$race_weather', '$race_laps', 
   '$race_usac_permit', '$race_class_id') RETURNING race_id")) or print "FAILED!\n" and exit 1;
print "COMLETE\n";

#Let's start with easy stuff and add marshals / officials (if any)
#adding officials
print "Adding officials to \"official\" and \"race_official\" tables...";
foreach my $official (@{$race_hash->{'officials'}}){
	#Have we seen this official before?
	$query = $dbh->prepare("SELECT * FROM official where official_name='$official'");
	my $official_id;
    if ($query->execute <1){
		$official_id = pop($dbh->selectcol_arrayref("INSERT INTO official(official_name) VALUES('$official') RETURNING official_id"))
		or print "FAILED!\n" and exit 1;
	}else{
		$official_id = pop($dbh->selectcol_arrayref("SELECT official_id from official where official_name='$official'"));
	}

	#Now we create a new race_official entry
	$dbh->do("INSERT INTO race_official(race_id, official_id) VALUES ('$race_id','$official_id')")
	or print "FAILED!\n" and exit 1;
}

print "COMPLETE!\n";
#adding marshals 
print "Adding marshals to \"marshals\" and \"race_marshal\" tables...";
foreach my $marshal(@{$race_hash->{'marshals'}}){
	#Have we seen this marshal before?
	$query = $dbh->prepare("SELECT * FROM marshal where marshal_name='$marshal'");
	my $marshal_id;
    if ($query->execute <1){
		$marshal_id = pop($dbh->selectcol_arrayref("INSERT INTO marshal(marshal_name) VALUES('$marshal') RETURNING marshal_id"))
		or print "FAILED!\n" and exit 1;
	}else{
		$marshal_id = pop($dbh->selectcol_arrayref("SELECT marshal_id from marshal where marshal_name='$marshal'"));
	}

	#Now we create a new race_marshal entry
	$dbh->do("INSERT INTO race_marshal(race_id, marshal_id) VALUES ('$race_id','$marshal_id')")
	or print "FAILED!\n" and exit 1;
}
print "COMPLETE!\n";

#Now we have to unroll the riders/mar/primes arrays


foreach my $rider_hash (@{$race_hash->{'riders'}}){


	#Let's start by finding if we have a unique rider id for this rider
	#if not, we'll make one
	my $racer_name = $rider_hash->{'name'};
	my $racer_id;
	$query = $dbh->prepare("SELECT * FROM racer WHERE racer_name='$racer_name'");
	if ($query->execute < 1){
		#It looks like we don't have a rider ID, let's update the "racer" table and grab one
		$racer_id = pop($dbh->selectcol_arrayref("INSERT INTO racer(racer_name) VALUES ('$racer_name') RETURNING racer_id"));	
	}else{
		#Cool, we have a unique racer_id, let's grab it
		$racer_id = pop($dbh->selectcol_arrayref("SELECT racer_id from racer where racer_name='$racer_name'"));	
	}

	#Do the same for team id
	my $team_name;
	my $team_id;
	my $participant_id;

	if (exists $rider_hash->{'team'}){
		$team_name = $rider_hash->{'team'};
	}else{
		$team_name = "";
	}
	
	if ($team_name ne ""){
		$query = $dbh->prepare("SELECT * FROM team WHERE team_name='$team_name'");
		if ($query->execute < 1){
			#It looks like we don't have a team ID, let's update the "team" table and grab one
			$team_id = pop($dbh->selectcol_arrayref("INSERT INTO team(team_name) VALUES ('$team_name') RETURNING team_id"));	
		}else{
			#Cool, we have a unique team_id, let's grab it
			$team_id = pop($dbh->selectcol_arrayref("SELECT team_id from team where team_name='$team_name'"));	
		}
	
		#With racer_id, team_id and race_id we can now update our join table
		$participant_id = pop($dbh->selectcol_arrayref("INSERT INTO participant (racer_id, team_id, race_id) 
		VALUES ('$racer_id', '$team_id', '$race_id') RETURNING participant_id"));	
	}else{
		$participant_id = pop($dbh->selectcol_arrayref("INSERT INTO participant (racer_id, race_id) 
		VALUES ('$racer_id', '$race_id') RETURNING participant_id"));	
	}


	#Once we have our participant_id, we can start to build our
	#result insert statement.
	#To make this easier, I'm going to use a hash
	
	my %result_hash;
	$result_hash{'participant_id'} = $participant_id;
	#Now we have to unwind the primes and see if this racer/rider won anything
	foreach my $prime_hash (@{$race_hash->{'primes'}}){
		if ($prime_hash->{'name'} eq $racer_name){
			if ($prime_hash->{'prime'} eq "Point Prime"){
				$result_hash{'result_point_prime'} = "True";
			}
			my $prime_description= $prime_hash->{'prime'};
			$dbh->do("INSERT into prime(participant_id, prime_description) VALUES ('$participant_id', '$prime_description')");
		}
	}


	#Start updating result table with actual point/team/mar information
	
	foreach my $mar_hash (@{$race_hash->{'mar'}}){
		if ($mar_hash->{'name'} eq $racer_name){
			$result_hash{'result_mar_place'} = $mar_hash->{'mar_place'};
			#There is a possibility that we didn't get MAR points
			if (exists $mar_hash->{'mar_points'}){
				$result_hash{'result_mar_points'}= $mar_hash->{'mar_points'};
			}
		}
	}


	foreach my $key (keys %$rider_hash){
		if (($key eq "time") or ($key eq "name") or ($key eq "team")){
			#We don't need this data
			next;
		}elsif ($key eq "place"){
			$result_hash{'result_place'} = $rider_hash->{$key};
		}elsif ($key eq "points"){
			$result_hash{'result_points'} = $rider_hash->{$key};
		}elsif ($key eq "team_points"){
			$result_hash{'result_team_points'} = $rider_hash->{$key};
		}
	}

	my @result_insert_keys;
	my @result_insert_values;
	foreach my $key (keys %result_hash){
		#print "$key: $result_hash{$key}\n";
		@result_insert_keys = (keys %result_hash);
		@result_insert_values = (values %result_hash);
	}

	#Try our insert?
	my $result_columns = join("," , @result_insert_keys);
	my $result_values= join("," , @result_insert_values);
	$dbh->do("INSERT INTO result ($result_columns) VALUES ($result_values)");
	
	#Make sure we don't carry over things to the next loop?
	undef %result_hash;
	undef $participant_id;
	undef @result_insert_keys;
	undef @result_insert_values;
	undef $result_columns;
	undef $result_values;
}

