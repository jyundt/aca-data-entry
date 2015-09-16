CREATE DATABASE oval OWNER postgres;
\connect oval

CREATE TABLE race_class (
  race_class_id SERIAL PRIMARY KEY,
  race_class_description VARCHAR(200) NOT NULL
);

CREATE TABLE racer (
  racer_id SERIAL PRIMARY KEY,
  racer_name VARCHAR(200) NOT NULL,
  racer_usac_license INT,
  racer_birthdate DATE
);

CREATE TABLE team (
  team_id SERIAL PRIMARY KEY,
  team_name VARCHAR(200) NOT NULL
);

CREATE TABLE race (
  race_id SERIAL PRIMARY KEY,
  race_date DATE NOT NULL,
  race_class_id INT REFERENCES race_class,
  race_duration INTERVAL,
  race_slow_lap INTERVAL,
  race_fast_lap INTERVAL,
  race_average_lap INTERVAL,
  race_weather VARCHAR(200),
  race_laps INT
);

CREATE TABLE participant (
  participant_id SERIAL PRIMARY KEY,
  racer_id INT REFERENCES racer,
  team_id INT REFERENCES team,
  race_id INT REFERENCES race
);

CREATE TABLE prime (
  prime_id SERIAL PRIMARY KEY,
  participant_id INT REFERENCES participant,
  prime_description VARCHAR(200) NOT NULL
);

CREATE TABLE result (
  result_id SERIAL PRIMARY KEY,
  participant_id INT REFERENCES participant,
  result_place INT,
  result_points INT,
  result_mar_place INT,
  result_mar_points INT,
  result_point_prime BOOL,
  result_dnf BOOL,
  result_dns BOOL,
  results_relegated BOOL,
  results_disqualified BOOL
);

