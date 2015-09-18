#!/usr/bin/perl

use Data::Dumper;
use Date::Parse;
use JSON;
use YAML;
use strict;
use warnings;

binmode(STDOUT, ":utf8");
binmode(STDIN, ":utf8");

#This scipt will prompt users for data about an ACA race and convert it into 
#a JSON document

#This script is awful

#Define some variable
#my $weather;
#my $location;
#my $usac_permit;
#my @officials;
my @marshals;
#my @category;
#my @p_course;

#This hash map will contain several entries like scalars, arrays and other maps
my %race_data;
my $temp_time;
my %temp_hash;


#I discovered that it is pretty miserable to type team names
#Maybe we should a year -> rider -> hash table?
my %team_roster_hash = (
	"2015" => {
		"Aaron Bovalino" => "LaPrima Espresso",
		"Adam Cohen" => "East End Cycling Club",
		"Al Meder" => "East End Cycling Club",
		"Andrew Reay" => "Team Citius",
		"Andy Seitz" => "Kelly Benefit Strategies Elite",
		"AnnaLena Kemper" => "Dynamic Physical Therapy",
		"Austin Bradley" => "Pitt",
		"Bill Ehler" => "UPMC Cycling Performance",
		"Birk McGilvrey" => "LaPrima Espresso",
		"Brett Rothmeyer" => "GPOA",
		"Bryan Routledge" => "Sette Nove",
		"Caleb Smith" => "LaPrima Espresso",
		"Caleb Wakely" => "Team Citius",
		"Carl Hubel" => "East End Cycling Club",
		"Carl Lovejoy" => "East End Cycling Club",
		"Chas McFarland" => "Dynamic Physical Therapy",
		"Chris Butor" => "Top Gear Racing",
		"Chris Helbling" => "East End Cycling Club",
		"Christian Korey" => "UPMC Cycling Performance",
		"Chris Yanakos" => "LaPrima Espresso",
		"Colleen Grygier" => "East End Cycling Club",
		"Craig Merritts" => "CAT Racing",
		"Dan Greene" => "East End Cycling Club",
		"Danny Wilson" => "Freddie Fu Cycling",
		"Dan Rabe" => "Truefit Racing",
		"Dave Friedman" => "NovaCare",
		"Dave Galati" => "LaPrima Espresso",
		"Dave Roney" => "East End Cycling Club",
		"Dennis Patton" => "East End Cycling Club",
		"Devon Corboy" => "Dynamic Physical Therapy",
		"Don Splitstone" => "Truefit Racing",
		"Drew Dorko" => "East End Cycling Club",
		"Drew Smorul" => "East End Cycling Club",
		"Ed Krall" => "GPOA",
		"EJ Hubstenberger" => "Dynamic Physical Therapy",
		"Elise Rowe" => "LaPrima Espresso",
		"Eric Burnett" => "VOLT Multisport",
		"Eric Hodos" => "UPMC Cycling Performance",
		"Eric Lundgren" => "JBV Coaching",
		"Erin Yanacheck" => "UPMC Cycling Performance",
		"Florian Lungu" => "NovaCare",
		"Frankie Ross" => "Sette Nove",
		"Fred Gohh" => "Team Citius",
		"George Pompura" => "East End Cycling Club",
		"Greg Ellis" => "UPMC Cycling Performance",
		"Gunnar Shogren" => "Dynamic Physical Therapy",
		"Hasan Baydoun" => "East End Cycling Club",
		"Hassan Beydoun" => "East End Cycling Club",
		"Heather Slater" => "East End Cycling Club",
		"Hy Simhan" => "East End Cycling Club",
		"Ian Baun" => "UPMC Cycling Performance",
		"Jack Neyer" => "Freddie Fu Cycling",
		"Jacob Yundt" => "CAT Racing",
		"Jake Lifson" => "GPOA",
		"Jared Babik" => "GPOA",
		"Jason Bair" => "Truefit Racing",
		"Jason Hochreiter" => "Truefit Racing",
		"Jason Mount" => "Freddie Fu Cycling",
		"Jason Zimmerman" => "Freddie Fu Cycling",
		"Jeff Gernert" => "Dynamic Physical Therapy",
		"Jeff Griffin" => "Freddie Fu Cycling",
		"Jeff Grimm" => "LaPrima Espresso",
		"Jeff Koontz" => "UPMC Cycling Performance",
		"Jeff Paul" => "Rare Diseases",
		"Jim Doan" => "Bents Cycling",
		"Jim Mock" => "Dynamic Physical Therapy",
		"John Cotter" => "NovaCare",
		"John Heffner" => "CAT Racing",
		"John McLaughlin" => "NovaCare",
		"John Rowley" => "GPOA",
		"Jon Sheppard" => "East End Cycling Club",
		"Jon Williams" => "Freddie Fu Cycling",
		"Jordan Villella" => "NovaCare",
		"Josh Friedman" => "Greenline Velo d/b/ Zipcar",
		"Josh Lewis" => "East End Cycling Club",
		"JR Petsko" => "Dynamic Physical Therapy",
		"Justin Kanter" => "CAT Racing",
		"Keith Hower" => "Freddie Fu Cycling",
		"Ken Mowry" => "East End Cycling Club",
		"Kyle Mihalik" => "NovaCare",
		"Maarten deBoer" => "Team Citius",
		"Mark Bedel" => "Team Citius",
		"Mark Milojevic" => "NovaCare",
		"Mark Nicoll" => "GPOA",
		"Marko Milojevic" => "NovaCare",
		"Matt Brady" => "NovaCare",
		"Matt Dolfi" => "NovaCare",
		"Matt Guillon" => "East End Cycling Club",
		"Matt Serechin" => "East End Cycling Club",
		"Megan Sybeldon" => "Rare Diseases",
		"Melissa Hiller" => "QCW Breakaway Bikes",
		"Mike Appel" => "CAT Racing",
		"Mike Janeiro" => "LaPrima Espresso",
		"Mike Mihalik" => "NovaCare",
		"Mike Oltman" => "CAT Racing",
		"Mike Quigley" => "UPMC Cycling Performance",
		"Morgan Baker" => "NovaCare",
		"Nathan Clair" => "Dynamic Physical Therapy",
		"Patrick Beukema" => "East End Cycling Club",
		"Paul Carberry" => "East End Cycling Club",
		"Paul Carlson" => "Top Gear Racing",
		"Rachel Weaver" => "NovaCare",
		"Rick Holzworth" => "LaPrima Espresso",
		"Russel Boyd" => "NovaCare",
		"Shawn Geiger" => "Dynamic Physical Therapy",
		"Shawn Litster" => "NovaCare",
		"Shequaya Bailey" => "Rare Diseases",
		"Skip Rogers" => "UPMC Cycling Performance",
		"Stephanie Swan" => "Rare Diseases",
		"Steve Cummings" => "GPOA",
		"Steve Kurpiewski" => "GPOA",
		"Teddy Denman-Brice" => "LaPrima Espresso",
		"Ted McPherson" => "QCW Breakaway Bikes",
		"Tim Daigle" => "Team Citius",
		"Tom Borner" => "Truefit Racing",
		"Willem deBoer" => "UPMC Cycling Performance",
		"Xavier Szigethy" => "UPMC Cycling Performance"
	},
	"2014" => {
		"Aaron Bovalino" => "LaPrima Espresso",
		"Adam Cohen" => "East End Cycling Club",
		"Al Meder" => "East End Cycling Club",
		"Andrew Reay" => "Team Citius",
		"Andy Seitz" => "Kelly Benefit Strategies Elite",
		"AnnaLena Kemper" => "Dynamic Physical Therapy",
		"Austin Bradley" => "Pitt",
		"Bill Ehler" => "UPMC Cycling Performance",
		"Birk McGilvrey" => "LaPrima Espresso",
		"Brett Rothmeyer" => "GPOA",
		"Bryan Routledge" => "Sette Nove",
		"Caleb Smith" => "LaPrima Espresso",
		"Caleb Wakely" => "Team Citius",
		"Carl Hubel" => "East End Cycling Club",
		"Carl Lovejoy" => "East End Cycling Club",
		"Chas McFarland" => "Dynamic Physical Therapy",
		"Chris Butor" => "Top Gear Racing",
		"Chris Helbling" => "East End Cycling Club",
		"Christian Korey" => "UPMC Cycling Performance",
		"Chris Yanakos" => "LaPrima Espresso",
		"Colleen Grygier" => "East End Cycling Club",
		"Craig Merritts" => "CAT Racing",
		"Dan Greene" => "Iron City Bikes",
		"Danny Wilson" => "Freddie Fu Cycling",
		"Dan Rabe" => "Truefit Racing",
		"Dave Friedman" => "NovaCare",
		"Dave Galati" => "LaPrima Espresso",
		"Dave Roney" => "East End Cycling Club",
		"Dennis Patton" => "East End Cycling Club",
		"Devon Corboy" => "Dynamic Physical Therapy",
		"Don Splitstone" => "Truefit Racing",
		"Drew Dorko" => "East End Cycling Club",
		"Drew Smorul" => "East End Cycling Club",
		"Ed Krall" => "GPOA",
		"EJ Hubstenberger" => "Dynamic Physical Therapy",
		"Elise Rowe" => "LaPrima Espresso",
		"Eric Burnett" => "VOLT Multisport",
		"Eric Hodos" => "UPMC Cycling Performance",
		"Eric Lundgren" => "JBV Coaching",
		"Erin Yanacheck" => "UPMC Cycling Performance",
		"Florian Lungu" => "NovaCare",
		"Frankie Ross" => "Sette Nove",
		"Fred Gohh" => "Team Citius",
		"George Pompura" => "East End Cycling Club",
		"Greg Ellis" => "UPMC Cycling Performance",
		"Gunnar Shogren" => "Dynamic Physical Therapy",
		"Hasan Baydoun" => "East End Cycling Club",
		"Hassan Beydoun" => "East End Cycling Club",
		"Heather Slater" => "East End Cycling Club",
		"Hy Simhan" => "East End Cycling Club",
		"Ian Baun" => "UPMC Cycling Performance",
		"Jack Neyer" => "Freddie Fu Cycling",
		"Jacob Yundt" => "Iron City Bikes",
		"Jake Lifson" => "GPOA",
		"Jared Babik" => "GPOA",
		"Jason Bair" => "Truefit Racing",
		"Jason Hochreiter" => "NuGo/Koeles",
		"Jason Mount" => "Freddie Fu Cycling",
		"Jason Zimmerman" => "Freddie Fu Cycling",
		"Jeff Gernert" => "Dynamic Physical Therapy",
		"Jeff Griffin" => "Freddie Fu Cycling",
		"Jeff Grimm" => "LaPrima Espresso",
		"Jeff Koontz" => "UPMC Cycling Performance",
		"Jeff Paul" => "Rare Diseases",
		"Jim Doan" => "Bents Cycling",
		"Jim Mock" => "Dynamic Physical Therapy",
		"John Cotter" => "NovaCare",
		"John Heffner" => "CAT Racing",
		"John McLaughlin" => "NovaCare",
		"John Rowley" => "GPOA",
		"Jon Sheppard" => "East End Cycling Club",
		"Jon Williams" => "Freddie Fu Cycling",
		"Jordan Villella" => "NovaCare",
		"Josh Friedman" => "Greenline Velo d/b/ Zipcar",
		"Josh Lewis" => "East End Cycling Club",
		"JR Petsko" => "Dynamic Physical Therapy",
		"Justin Kanter" => "CAT Racing",
		"Keith Hower" => "Freddie Fu Cycling",
		"Ken Mowry" => "East End Cycling Club",
		"Kyle Mihalik" => "NovaCare",
		"Maarten deBoer" => "Team Citius",
		"Mark Bedel" => "Team Citius",
		"Mark Milojevic" => "NovaCare",
		"Mark Nicoll" => "GPOA",
		"Marko Milojevic" => "NovaCare",
		"Matt Brady" => "NovaCare",
		"Matt Dolfi" => "NovaCare",
		"Matt Guillon" => "East End Cycling Club",
		"Matt Serechin" => "East End Cycling Club",
		"Megan Sybeldon" => "Rare Diseases",
		"Melissa Hiller" => "QCW Breakaway Bikes",
		"Mike Appel" => "CAT Racing",
		"Mike Janeiro" => "Pro Mountain Outfitters",
		"Mike Mihalik" => "NovaCare",
		"Mike Oltman" => "CAT Racing",
		"Mike Quigley" => "UPMC Cycling Performance",
		"Morgan Baker" => "NovaCare",
		"Nathan Clair" => "Dynamic Physical Therapy",
		"Patrick Beukema" => "East End Cycling Club",
		"Paul Carberry" => "East End Cycling Club",
		"Paul Carlson" => "Top Gear Racing",
		"Rachel Weaver" => "NuGo/Koeles",
		"Rick Holzworth" => "LaPrima Espresso",
		"Russel Boyd" => "NovaCare",
		"Shawn Geiger" => "Dynamic Physical Therapy",
		"Shawn Litster" => "NuGo/Koeles",
		"Shequaya Bailey" => "Rare Diseases",
		"Skip Rogers" => "UPMC Cycling Performance",
		"Stephanie Swan" => "Rare Diseases",
		"Steve Cummings" => "GPOA",
		"Steve Kurpiewski" => "GPOA",
		"Teddy Denman-Brice" => "LaPrima Espresso",
		"Ted McPherson" => "QCW Breakaway Bikes",
		"Tim Daigle" => "Team Citius",
		"Tom Borner" => "Truefit Racing",
		"Willem deBoer" => "UPMC Cycling Performance",
		"Xavier Szigethy" => "UPMC Cycling Performance"
	}
);
	
#Let's just ask users for data (which sucks)
print "Date (YYYY-MM-DD): ";
chomp(my $date = <STDIN>);
until ($date  =~ /^\d{4}-\d\d-\d\d$/){
	print "Invalid entry!\n";
	print "Date (YYYY-MM-DD): ";
	chomp($date = <STDIN>);
}

my $year = substr($date,0,4);
my $month = substr($date,5,2);
my $day = substr(localtime(str2time($date)),0,3);

#Yes this could probably be an array or some other range thing
#But I just wanted to get this done...
my %location_hash = (
	"1996" => "Zoo",
	"1997" => "Zoo",
	"1998" => "Zoo",
	"1999" => "Washington Blvd Bicycle Oval",
	"2000" => "Washington Blvd Bicycle Oval",
	"2001" => "Washington Blvd Bicycle Oval",
	"2002" => "Washington Blvd Bicycle Oval",
	"2003" => "Washington Blvd Bicycle Oval",
	"2004" => "Washington Blvd Bicycle Oval",
	"2005" => "Washington Blvd Bicycle Oval",
	"2006" => "Washington Blvd Bicycle Oval",
	"2007" => "Washington Blvd Bicycle Oval",
	"2008" => "Washington Blvd Bicycle Oval",
	"2009" => "Washington Blvd Bicycle Oval",
	"2010" => "Washington Blvd Bicycle Oval",
	"2011" => "Washington Blvd Bicycle Oval",
	"2012" => "Bud Harris Bike Park",
	"2013" => "Bud Harris Bike Park",
	"2014" => "Bud Harris Bike Park",
	"2015" => "Bud Harris Bike Park",
);

if (exists $location_hash{$year}){
	print "Location [$location_hash{$year}]: ";
} else {
	print "Location: ";
}
chomp(my $location = <STDIN>);
if ($location eq ""){
	$location = $location_hash{$year};
}

print "Weather: ";
chomp(my $weather = <STDIN>);

print "P-course [no]: ";
chomp(my $p_course = <STDIN>);
if ($p_course eq ""){
	$p_course = "false";
} else {
	until ( $p_course =~ /^y(es)$/i || $p_course =~ /^n(o)$/i ){
		print "Invalid entry!\(\"yes\" or \"no\")\n";
		print "P-course: ";
		chomp($p_course = <STDIN>);
	}
	if ($p_course =~ /^y(es)$/i){
		$p_course = "true";
	} else {
		$p_course = "false";
	}
}

my %permit_hash = (
	"2015" => {
		"Tue" => "2015-617",
		"Wed" => "2015-618",
	},
	"2014" => {
		"Tue" => "2014-1359",
		"Wed" => "2014-1360",
	}
);


if (exists $permit_hash{$year}{$day}){
	print "USAC Permit [$permit_hash{$year}{$day}]: ";
}else{
	print "USAC Permit: ";
}

chomp(my $usac_permit = <STDIN>);
if (($usac_permit eq "") && (exists $permit_hash{$year}{$day})){
	$usac_permit = $permit_hash{$year}{$day};
}
until ($usac_permit =~ /\d+$/){
	print "Invalid entry!\n";
	print "USAC Permit: ";
	chomp($usac_permit = <STDIN>);
}


#Let's build a hash of officials to "guess"
my %officials_hash = (
	2015 => {
		Tue => ["Doug Riegner", "John Cotter"],
		Wed => ["Kurt Kearcher", "Nikki Berrian"],
	},
	2014 => {
		Tue => ["Doug Riegner", "John Cotter"],
		Wed => ["Rachel Weaver", "Stacie Truszkowski"],
	},
);


if (exists $officials_hash{$year}{$day}){
	print "Number of officials [" . @{$officials_hash{$year}{$day}} . "]: ";
} else{
	print "Number of officials: ";
}
chomp (my $num_officials = <STDIN>);
if ($num_officials eq ""){
	$num_officials = @{$officials_hash{$year}{$day}};
}
until ( $num_officials =~ /\d+$/){
	print "Invalid entry!\n";
	print "Number of officials: ";
	chomp ($num_officials = <STDIN>);
}
my @officials;
foreach my $official (1..$num_officials){
	if (exists $officials_hash{$year}{$day}[$official-1]){
		print "Official \#$official [$officials_hash{$year}{$day}[$official-1]]: ";
	} else{	
		print "Official \#$official: ";
	}
	chomp (my $official_name = <STDIN>);
	if ($official_name eq ""){
		$official_name = $officials_hash{$year}{$day}[$official-1];
	}
	push(@officials,$official_name);
	
}

if ($day eq "Tue"){
	print "Number of marshals: ";
	chomp (my $num_marshals = <STDIN>);
	until ($num_marshals =~ /\d+$/){
		print "Invalid entry!\n";
		print "Number of marshals: ";
		chomp ($num_marshals = <STDIN>);
	}
	#my @marshals;
	foreach our $marshal (1..$num_marshals){
		print "Marshal \#$marshal: ";
		chomp (my $marshal_name = <STDIN>);
		push(@marshals,$marshal_name);
	}
}

my %category_hash = (
	"2015" =>  {
		Tue => ["C", "Masters 40+/Women"],
		Wed => ["A", "B"],
	},
	"2014" =>  {
		Tue => ["C", "Masters 40+/Women"],
		Wed => ["A", "B"],
	},
	"2013" =>  {
		Tue => ["C", "W/Jr"],
		Wed => ["A", "B"],
	},
);
	
print "Number of categories/races [" . @{$category_hash{$year}{$day}} . "]: ";
chomp (my $num_categories= <STDIN>);
if ($num_categories eq ""){
	$num_categories = @{$category_hash{$year}{$day}};
}
until ( $num_categories =~ /\d+$/){
	print "Invalid entry!\n";
	print "Number of categories/races: ";
	chomp ($num_categories= <STDIN>);
}
		
foreach my $category_number (1..$num_categories){
	if (exists $category_hash{$year}{$day}[$category_number-1]){
		print "Category \#$category_number name [$category_hash{$year}{$day}[$category_number-1]]: ";
	}else{
		print "Category \#$category_number name: ";
	}
	chomp (my $category = <STDIN>);
	if ($category eq ""){
		$category = $category_hash{$year}{$day}[$category_number-1];
	}
	#Let's dump our global variables (date, weather, etc) to our temp hash
	my %temp_hash;
	$temp_hash{weather} = $weather;
	$temp_hash{usac_permit} = $usac_permit;
	$temp_hash{date} = $date;
	$temp_hash{location} = $location;
	$temp_hash{p_course} = $p_course;
	$temp_hash{category} = $category;
	@{$temp_hash{officials}} = @officials;
	if (@marshals > 0){
		@{$temp_hash{marshals}} = @marshals;
	}
	print "Category $category # of laps: ";
	chomp($temp_hash{laps} = <STDIN>);
	until ($temp_hash{laps} =~ /\d+$/){
		print "Invalid entry!\n";
		print "Category $category # of laps: ";
		chomp($temp_hash{laps} = <STDIN>);
	}
	print "Category $category # of starters: ";
	chomp($temp_hash{starters} = <STDIN>);
	until ($temp_hash{starters} =~ /\d+$/){
		print "Invalid entry!\n";
		print "Category $category # of starters: ";
		chomp($temp_hash{starters} = <STDIN>);
	}
	print "Category $category # of finishers: ";
	chomp(my $finishers = <STDIN>);
	until ($finishers =~ /\d+$/){
		print "Invalid entry!\n";
		print "Category $category # of finishers";
		chomp($finishers = <STDIN>);
	}


	#now we start building another temporary hash for our riders
	my %temp_rider_hash;
	foreach my $rider_number (1..$finishers){
		#I was originally going to manually enter places, because of things like JRs
		#however, now I'm just going to place them at the end. screw it.
		#chomp(my $place= <STDIN>);
		#if ($place eq ""){
		#	$place = $rider_number;
		#}
		my $place = $rider_number;

		print "Category $category rider \#$rider_number\'s name: ";
		chomp (my $name= <STDIN>);


		if (exists $team_roster_hash{$year}{$name}){
			print "Category $category rider \#$rider_number\'s team [$team_roster_hash{$year}{$name}]: ";
		}else{
			print "Category $category rider \#$rider_number\'s team: ";
		}
		chomp (my $team = <STDIN>);
		if ($team eq ""){
			$team = $team_roster_hash{$year}{$name};
		}			

		if ($rider_number > 1){
			print "Category $category rider \#$rider_number\'s time [$temp_hash{riders}[$rider_number-2]{time}]: ";
		} else { 
			print "Category $category rider \#$rider_number\'s time: ";
		}

		chomp (my $time = <STDIN>);
		if (($time eq "") && $rider_number>1){
			$time = $temp_hash{riders}[$rider_number-2]{time};
		}

		#Build a quick hash of places -> points to save time
		my %place_hash = (
			"1" => "10",
			"2" => "8",
			"3" => "6",
			"4" => "5",
			"5" => "4",
			"6" => "3",
			"7" => "2",
			"8" => "1",
		);
	
		#guess how many points we got
		my $points;
		my $team_points;
		if (($month >= 6) && ($month <=8)){
			my $points_guess;
			if (exists $place_hash{$rider_number}){
				$points_guess = $place_hash{$rider_number};		
			}else{
				$points_guess=0;
			}
		
			print "Category $category rider \#$rider_number\'s points [$points_guess]: ";
			chomp ($points = <STDIN>);
			if ($points eq ""){
				$points = $points_guess;
			}
			until ( $points =~ /\d+$/){
				print "Invalid entry!\n";	
				print "Category $category rider \#$rider_number\'s points [$points_guess]: ";
				chomp ($points = <STDIN>);
				if ($points eq ""){
					$points = $points_guess;
				}
			}
			print "Category $category rider \#$rider_number\'s team points [$points_guess]: ";
			chomp ($team_points = <STDIN>);
			if ($team_points eq ""){
				$team_points = $points_guess;
			}
			if ($team_points eq ""){
				$team_points = 0;
			}
			until ($team_points =~ /\d+$/){
				print "Invalid entry!\n";	
				print "Category $category rider \#$rider_number\'s team points [$points_guess]: ";
				chomp ($team_points = <STDIN>);
				if ($team_points eq ""){
					$team_points = $points_guess;
				}
			}
		}

		#We need this bullshit line for things like jr_place and women_place
		print "Enter additional values for $name (leave blank to end/skip): ";
		chomp (my $key = <STDIN>);
		until ($key eq ""){
			print "Enter value for $key: ";
			chomp(my $value = <STDIN>);
			$temp_rider_hash{$key} = $value;
			print "Enter additional values for $name (leave blank to end/skip): ";
			chomp ($key = <STDIN>);
		}

		#Build another temp hash and push it onto the rider array
		$temp_rider_hash{name}=$name;	
		$temp_rider_hash{place}=$place;	
		$temp_rider_hash{team}=$team;	
		$temp_rider_hash{time}=$time;	
		if (($month >= 6) && ($month <=8)){
			$temp_rider_hash{points}=$points;	
			$temp_rider_hash{team_points}=$team_points;	
		}

		push (@{$temp_hash{riders}},{%temp_rider_hash});

		undef %temp_rider_hash;
		
	}

	#Now we start gathering MAR information
	print "Category $category # of MAR places: ";
	chomp(my $mar_places= <STDIN>);
	until ($mar_places=~ /\d+$/){
		print "Invalid entry!\n";
		print "Category $category # of MAR places";
		chomp($mar_places= <STDIN>);
	}
	foreach my $mar_place (1..$mar_places){
		print "Category $category MAR rider \#$mar_place\'s name: ";
		chomp(my $name = <STDIN>);

		if (exists $team_roster_hash{$year}{$name}){
			print "Category $category MAR rider \#$mar_place\'s team [$team_roster_hash{$year}{$name}]: ";
		}else{
			print "Category $category MAR rider \#$mar_place\'s team: ";
		}
		chomp (my $team = <STDIN>);
		if ($team eq ""){
			$team = $team_roster_hash{$year}{$name};
		}			

		#Build a quick hash of places -> points to save time
		my %place_hash = (
			"1" => "3",
			"2" => "2",
			"3" => "1",
		);

		my $mar_points;
		if (($month >= 6) && ($month <=8)){
			my $points_guess = $place_hash{$mar_place};
			print "Category $category MAR rider \#$mar_place\'s points [$points_guess]: ";
			chomp ($mar_points = <STDIN>);
			if ($mar_points eq ""){
				$mar_points = $points_guess;
			}
			until ( $mar_points =~ /\d+$/){
				print "Invalid entry!\n";	
				print "Enter $mar_points\'s points [$points_guess]: ";
				chomp ($mar_points = <STDIN>);
				if ($mar_points eq ""){
					$mar_points = $points_guess;
				}
			}
			push(@{$temp_hash{mar}},{
				"name" => $name,
				"mar_place" => "$mar_place",
				"team" => $team,
				"mar_points" => $mar_points,
			});
		}else{
			push(@{$temp_hash{mar}},{
				"name" => $name,
				"mar_place" => "$mar_place",
				"team" => $team,
			});
		}

	}


	print "Number of primes: ";
	chomp (my $num_primes = <STDIN>);
	until ( $num_primes =~ /\d+$/){
		print "Invalid entry!\n";
		print "Number of primes: ";
		chomp ($num_primes = <STDIN>);
	}
	foreach my $prime_num (1..$num_primes){
		print "Prime \#$prime_num winner: ";
		chomp (my $name = <STDIN>);
		print "Prime \#$prime_num prize: ";
		chomp (my $prime = <STDIN>);
		push(@{$temp_hash{primes}},{
			"name" => $name,
			"prime" => $prime,
		});
	
	}	
	print "Fast lap: ";
	chomp(my $fast_lap = <STDIN>);
	$temp_hash{fast_lap} = $fast_lap;

	print "Slow lap: ";
	chomp(my $slow_lap = <STDIN>);
	$temp_hash{slow_lap} = $slow_lap;

	print "Avg lap: ";
	chomp(my $avg_lap = <STDIN>);
	$temp_hash{avg_lap} = $avg_lap;
	
        print "Writing output to $date\_$category_number.json...";
        my $json_text = to_json (\%temp_hash, {utf8 => 1, pretty => 1 });
	open (my $fh, '>', "$date\_$category_number.json") or die "Could not write to file $date\_$category_number.json";
	print $fh $json_text;
	close $fh;	
	print "COMPLETE!\n";
	
}	
		
