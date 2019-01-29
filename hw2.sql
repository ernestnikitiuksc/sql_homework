--1.1 SELECT, LIMIT - выбрать 10 записей из таблицы rating

SELECT * FROM ratings LIMIT 10;

--1.2 WHERE, LIKE - выбрать из таблицы links всё записи, у которых imdbid оканчивается на "42", а поле movieid между 100 и 1000
SELECT *
FROM links
WHERE
    imdbid like '%42' AND
    movieid > 100 AND
    movieid < 1000
LIMIT 10;

--второй способ с INTERSECT

(
	SELECT * 
	FROM links
	WHERE imdbid like '%42' AND movieid > 100
) INTERSECT (
	SELECT * 
	FROM links
	WHERE imdbid like '%42' AND movieid < 1000
)
LIMIT 10;	

--2.1 INNER JOIN выбрать из таблицы links все imdb_id, которым ставили рейтинг 5
SELECT *
FROM links
JOIN ratings
    ON links.movieid=ratings.movieid
WHERE ratings.rating = 5
LIMIT 10;	


--3.1 COUNT() Посчитать число фильмов без оценок
SELECT
COUNT(*)
FROM links
LEFT JOIN public.ratings
    ON links.movieid=ratings.movieid
WHERE ratings.movieid IS NULL;

--3.2 GROUP BY, HAVING вывести top-10 пользователей, у который средний рейтинг выше 3.5

SELECT
    userId,
    AVG(rating) as avg_rating
FROM ratings
GROUP BY userId
HAVING AVG(rating) > 3.5
ORDER BY avg_rating DESC
LIMIT 10;

--4.1 Подзапросы: достать 10 imdbid из links у которых средний рейтинг больше 3.5

SELECT 
     imdbid
FROM 
(
    SELECT * 
    FROM links
    JOIN ratings
    ON links.movieid=ratings.movieid
) AS new_table
WHERE rating > 3.5
LIMIT 10;

--4.2 Common Table Expressions: посчитать средний рейтинг по пользователям, у которых более 10 оценок

WITH tmp_table
AS (
    SELECT
    userid,
    rating,
    COUNT(rating) as activity
    FROM ratings
    GROUP BY userId, rating
    HAVING COUNT(rating) > 10
)
SELECT 
    userid,
    AVG (rating) as average_rating
FROM tmp_table
GROUP BY userId
LIMIT 10;