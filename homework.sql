--git@github.com:ernestnikitiuksc/sql_homework.git

CREATE TABLE
films (
	title VARCHAR (355) UNIQUE NOT NULL,
    id serial PRIMARY KEY,
    country VARCHAR (355) NOT NULL,
    box_office_year VARCHAR (355) NOT NULL,
    release_year VARCHAR (355) NOT NULL
);

INSERT INTO 
films 
VALUES
('Les visiteurs', 1 , 'France', '98 754 810', '1993'),
('Nothing to Lose', 2 , 'USA', '44 480 039', '1997'),
('Wild Hogs', 3 , 'USA', '253 625 427', '2007'),
('Godfather', 4 , 'USA', '245 066 411', '1972'),
('Grown Ups', 5 , 'USA', '271 430 189', '2010');

SELECT * FROM films;



CREATE TABLE
persons (
    id serial PRIMARY KEY,
    name VARCHAR (355) NOT NULL
);

INSERT INTO 
persons 
VALUES
(1 , 'Jan Reno'),
(2 , 'Martin Lawrence'),
(3 , 'Martin Lawrence'),
(4 , 'Francis Ford Kappola'),
(5 , 'Adam Sendler');


SELECT * FROM persons;



CREATE TABLE
persons_2_content (
    person_id serial PRIMARY KEY,
    film_id serial UNIQUE,
    person_type VARCHAR (355) NOT NULL
);

-- 2 раза PRIMARY KEY нельзя было ввести поэтому я использовал ограничение UNIQUE


INSERT INTO 
persons_2_content 
VALUES
(1 , 1,  'actor'),
(2 , 2,  'actor'),
(3 , 3,  'actor'),
(4 , 4,  'director'),
(5 , 5,  'scenarist');


SELECT * FROM persons_2_content;