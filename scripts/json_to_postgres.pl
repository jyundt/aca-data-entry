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

my $query = $dbh->prepare("SELECT * FROM race_class WHERE race_class_description=\'$race_hash->{'category'}\'");
if  ($query->execute <1){
	print "COMPLETE\n";
	print "Adding category \"$race_hash->{'category'}\" to DB...";
	#If our ID doesn't exist, we add it to "race_class" table
	if ($dbh->do("INSERT INTO race_class (race_class_description) VALUES (\'$race_hash->{'category'}\')")){
		print "COMPLETE\n";
	}else{
		print "FAILED!\n";
		exit 1;
	}
	
}else{
	print "COMPELTE\n";
}

#Query our category ID (race_class_id) from the DB
my $race_class_id = pop($dbh->selectcol_arrayref("SELECT race_class_id FROM race_class WHERE race_class_description=\'$race_hash->{'category'}\'"));

#Start building our insert string for adding a row to the "race" table
my $race_date = $race_hash->{'date'};
my $race_slow_lap = $race_hash->{'slow_lap'};
my $race_fast_lap = $race_hash->{'fast_lap'};
my $race_average_lap = $race_hash->{'avg_lap'};
my $race_weather = $race_hash->{'weather'};
my $race_laps = $race_hash->{'laps'};
my $race_usac_permit = $race_hash->{'usac_permit'};




print "Adding row to \"race\" table...";
#Insert our race information to "race" table
my $race_id = pop($dbh->selectcol_arrayref("INSERT INTO race (race_date, race_slow_lap, race_fast_lap, race_average_lap, race_weather, race_laps, race_usac_permit, race_class_id)
   VALUES (\'$race_date\', \'$race_slow_lap\', \'$race_fast_lap\', \'$race_average_lap\', \'$race_weather\', \'$race_laps\', 
   \'$race_usac_permit\', \'$race_class_id\') RETURNING race_id")) or print "FAILED!\n" and exit 1;
print "COMLETE\n";



#Now we have to unroll the riders/mar/primes arrays


foreach my $rider_hash (@{$race_hash->{'riders'}}){

	#Let's start by finding if we have a unique rider id for this rider
	#if not, we'll make one
	my $racer_name = $rider_hash->{'name'};
    my $racer_id;
	$query = $dbh->prepare("SELECT * FROM racer WHERE racer_name=\'$racer_name\'");
	if ($query->execute < 1){
		#It looks like we don't have a rider ID, let's update the "racer" table and grab one
		$racer_id = pop($dbh->selectcol_arrayref("INSERT INTO racer(racer_name) VALUES (\'$racer_name\') RETURNING racer_id"));	
	}else{
		#Cool, we have a unique racer_id, let's grab it
		$racer_id = pop($dbh->selectcol_arrayref("SELECT racer_id from racer where racer_name=\'$racer_name\'"));	
	}

	#Do the same for team id
	my $team_name= $rider_hash->{'team'};
    my $team_id;
	$query = $dbh->prepare("SELECT * FROM team WHERE team_name=\'$team_name\'");
	if ($query->execute < 1){
		#It looks like we don't have a team ID, let's update the "team" table and grab one
		$team_id = pop($dbh->selectcol_arrayref("INSERT INTO team(team_name) VALUES (\'$team_name\') RETURNING team_id"));	
	}else{
		#Cool, we have a unique team_id, let's grab it
		$team_id = pop($dbh->selectcol_arrayref("SELECT team_id from team where team_name=\'$team_name\'"));	
	}

	#With racer_id, team_id and race_id we can now update our join table
	my $participant_id = pop($dbh->selectcol_arrayref("INSERT INTO participant (racer_id, team_id, race_id) 
	VALUES (\'$racer_id\', \'$team_id\', \'$race_id\') RETURNING participant_id"));	
	
	print "$racer_name : $participant_id\n";

}

