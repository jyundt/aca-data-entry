CREATE DATABASE oval OWNER postgres;
\connect oval

CREATE TABLE official (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL UNIQUE
);

CREATE TABLE marshal (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL UNIQUE
);


CREATE TABLE race_class (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL UNIQUE
);

CREATE TABLE racer (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  usac_license INT UNIQUE,
  birthdate DATE
);


CREATE TABLE team (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL UNIQUE
);

CREATE TABLE race (
  id SERIAL PRIMARY KEY,
  date DATE NOT NULL,
  class_id INT REFERENCES race_class,
  starters INT,
  duration INTERVAL,
  slow_lap INTERVAL,
  fast_lap INTERVAL,
  average_lap INTERVAL,
  weather VARCHAR(200),
  usac_permit VARCHAR(200),
  laps INT
);

CREATE TABLE participant (
  id SERIAL PRIMARY KEY,
  racer_id INT REFERENCES racer,
  team_id INT REFERENCES team,
  race_id INT REFERENCES race,
  place INT,
  points INT,
  team_points INT,
  mar_place INT,
  mar_points INT,
  point_prime BOOL,
  dnf BOOL,
  dns BOOL,
  relegated BOOL,
  disqualified BOOL
);

CREATE TABLE race_official (
  id SERIAL PRIMARY KEY,
  official_id INT REFERENCES official,
  race_id INT REFERENCES race
);

CREATE TABLE race_marshal (
  id SERIAL PRIMARY KEY,
  marshal_id INT REFERENCES marshal ,
  race_id INT REFERENCES race
);

CREATE TABLE prime (
  id SERIAL PRIMARY KEY,
  participant_id INT REFERENCES participant,
  name VARCHAR(200) NOT NULL
);

CREATE TABLE admin (
  id SERIAL PRIMARY KEY,
  email VARCHAR(200) NOT NULL UNIQUE,
  username VARCHAR(200) NOT NULL UNIQUE,
  password_hash VARCHAR(128),
  confirmed BOOL DEFAULT FALSE,
  name VARCHAR(200)
);
