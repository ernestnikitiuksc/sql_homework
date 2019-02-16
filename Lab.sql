
--1. Вывести список названий департаментов и количество главных врачей в каждом из этих департаментов

SELECT d_name, COUNT(DISTINCT chief_doc_id) as count_of_chief_docs 
FROM
(
	SELECT department_values.name AS d_name, chief_doc_id
	FROM department_values
	JOIN employee_values
    ON department_values.id=employee_values.department_id
) AS new_table
GROUP BY d_name;

--2.Вывести список департаментов, в которых работают 3 и более сотрудников (id и название департамента, количество сотрудников)


SELECT department_values.id AS dep_id, department_values.name AS dep_name, COUNT(employee_values.id) AS employee_count 
FROM department_values
JOIN employee_values
    ON department_values.id=employee_values.department_id
GROUP BY dep_id
HAVING COUNT(employee_values.id) >= 3;

--3.Вывести список департаментов с максимальным количеством публикаций  (id и название департамента, количество публикаций)

SELECT department_values.id AS d_id, department_values.name AS d_name, SUM(employee_values.num_public) AS number_of_publications
FROM department_values
JOIN employee_values
    ON department_values.id=employee_values.department_id
GROUP BY d_id
ORDER BY number_of_publications DESC
LIMIT 2;

--4. Вывести список сотрудников с минимальным количеством публикаций в своем департаменте (id и название департамента, имя сотрудника, количество публикаций)

SELECT d_id, d_name, e_name, num_public
FROM(
	SELECT department_values.id AS d_id, department_values.name AS d_name, employee_values.name as e_name, num_public, MIN(num_public) OVER (PARTITION BY department_values.id) as minValue
	FROM department_values
	JOIN employee_values
	ON department_values.id=employee_values.department_id
) as new_table
WHERE num_public = minValue;

--5. Вывести список департаментов и среднее количество публикаций для тех департаментов, в которых работает 
--более одного главного врача (id и название департамента, среднее количество публикаций)

WITH chosen_ones
AS(
	SELECT *
	FROM
	(
		SELECT d_id, d_name, COUNT(DISTINCT chief_doc_id) as count_of_chief_docs 
		FROM
		(
			SELECT department_values.id as d_id, department_values.name AS d_name, chief_doc_id
			FROM department_values
			JOIN employee_values
	    	ON department_values.id=employee_values.department_id
		) AS new_table
		GROUP BY d_name, d_id
	) AS new_table2
	WHERE count_of_chief_docs > 1
	)
SELECT DISTINCT department_id, d_name, AVG(num_public) OVER (PARTITION BY department_id) as average_pulications
FROM employee_values
INNER JOIN chosen_ones
ON employee_values.department_id = chosen_ones.d_id;
