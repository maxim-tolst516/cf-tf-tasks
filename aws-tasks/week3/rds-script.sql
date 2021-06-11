SELECT 'CREATE DATABASE mydb' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'mydb');

CREATE DATABASE mydb;
CREATE SCHEMA IF NOT EXISTS test;

create table test.films (title text, director text, release_time date);
insert into test.films(title, director, release_time) values ('Matrix', 'Cousines Vatchovsky', now());
insert into test.films(title, director, release_time) values ('Matrix 2', 'Cousines Vatchovsky', now());
insert into test.films(title, director, release_time) values ('Batmen 3', 'Michel Baine', now());
insert into test.films(title, director, release_time) values ('Batmen 4', 'Michel Baine', now());

select * from test.films;