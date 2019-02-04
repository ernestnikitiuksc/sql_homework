-- 1. Оконные функции

-- Столкнулся с возможной проблемой деления на ноль, которую
-- решил подзапросом. Были юзеры которые ставили одну и туже оценку
-- и (max - min) == 0.  Очень хотелось исключить деление на ноль
-- в Having, но не получалось. Как вариант думал добавить к тому что может
-- быть нулем какоето малое число, чтобы никогда не был 0 и чтобы на посчеты
-- normed rating это не практически не повлияло.Может Вы расскажете как это все решить
-- более оптимизировано?

SELECT 
userId,
movieId,
(rating - MIN(rating) OVER (PARTITION BY userId))/ 
(MAX(rating) OVER (PARTITION BY userId) - MIN(rating) OVER (PARTITION BY userId) ) as normed_rating,
AVG(rating) OVER (PARTITION BY userId) as average_rating
FROM (
	SELECT
	userId,
	movieId,
	rating,
	(MAX(rating) OVER (PARTITION BY userId) - MIN(rating) OVER (PARTITION BY userId) ) as difference_in_ratings
	FROM ratings
) as working_table_without_division_by_zero
WHERE difference_in_ratings <> 0
LIMIT 30;


-- Создаю таблицу
--keywords уже была поэтому сделал keywords1 

CREATE TABLE keywords1 (
id bigint,
tags text
);

-- копирую в таблицу данные из keywords.csv
\copy keywords1 FROM '/usr/local/share/netology/raw_data/keywords.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM keywords1 LIMIT 2;

SELECT  COUNT(*) FROM keywords1;

--выбираю строки только где количество оценок > 50 и считаю для них средний рейтинг
SELECT DISTINCT
movieId,
AVG(rating) OVER (PARTITION BY movieId) as average_rating
FROM(
SELECT
movieId,
rating
FROM ratings
GROUP BY movieId, rating
HAVING COUNT(rating) > 50
) as temp
ORDER BY average_rating DESC, movieId
LIMIT 150;



--Добавляю в таблицу информацию по тэгам
-- использовал right join чтоб не пропадали фильмы без тэгов 
--ато остается только 61

WITH top_rated 
AS(
	SELECT DISTINCT
	movieId,
	AVG(rating) OVER (PARTITION BY movieId) as average_rating
	FROM(
	SELECT
	movieId,
	rating
	FROM ratings
	GROUP BY movieId, rating
	HAVING COUNT(rating) > 50
	) as temp
	ORDER BY average_rating DESC, movieId
	LIMIT 150
)
SELECT *
FROM keywords1
RIGHT JOIN top_rated
ON top_rated.movieid = keywords1.id
ORDER BY average_rating DESC, movieId
LIMIT 150;
-- Вопрос: если поменять местами то что в FROM и то что в JOIN - что случится?
-- если сделать FROM top_rated и JOIN keywords1 - куда то пропадает movieid - поле просто 
--пустое. Почему?



-- копирую эту таблицу в новую таблицу my_new_table
WITH top_rated_2
AS ( WITH top_rated 
AS(
	SELECT DISTINCT
	movieId,
	AVG(rating) OVER (PARTITION BY movieId) as average_rating
	FROM(
	SELECT
	movieId,
	rating
	FROM ratings
	GROUP BY movieId, rating
	HAVING COUNT(rating) > 50
	) as temp
	ORDER BY average_rating DESC, movieId
	LIMIT 150
)
SELECT *
FROM keywords1
RIGHT JOIN top_rated
ON top_rated.movieid = keywords1.id
ORDER BY average_rating DESC, movieId
LIMIT 150 )  
SELECT movieId, tags INTO my_new_table FROM top_rated_2;


SELECT * FROM my_new_table;


-- выгражаю данные из таблицы в текстовый файл. Правильно ли я добавил условие про табуляцию?
\copy (SELECT * FROM my_new_table LIMIT 150) TO '/vagrant/my_new_table1.csv' WITH CSV HEADER DELIMITER E'\t' null as ',';


