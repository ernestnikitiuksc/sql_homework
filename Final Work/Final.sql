CREATE TABLE
departments (
    id serial PRIMARY KEY,
    title VARCHAR (355) UNIQUE NOT NULL
);

CREATE TABLE
employees (
    id serial PRIMARY KEY,
    departmentId serial NOT NULL,
   	chief_doc_id serial NOT NULL,
    name VARCHAR (355)  NOT NULL,
    num_of_public bigint NOT NULL
);

CREATE TABLE
employee_details (
    id serial NOT NULL,
    age bigint NOT NULL,
    marriageStatus VARCHAR (355) NOT NULL,
	years_of_work bigint NOT NULL,
	num_of_children bigint NOT NULL,
	vac_days bigint NOT NULL
);

CREATE TABLE
department_details (
    id serial NOT NULL,
    num_of_patients bigint NOT NULL,
	expenses bigint NOT NULL,
	gross_profit bigint NOT NULL
);


insert into departments values
('1', 'Therapy'),
('2', 'Neurology'),
('3', 'Cardiology'),
('4', 'Gastroenterology'),
('5', 'Hematology'),
('6', 'Oncology');
 
insert into employees values
('1', '1', '1', 'Kate', 4),
('2', '1', '1', 'Lidia', 2),
('3', '1', '1', 'Alexey', 1),
('4', '1', '2', 'Pier', 7),
('5', '1', '2', 'Aurel', 6),
('6', '1', '2', 'Klaudia', 1),
('7', '2', '3', 'Klaus', 12),
('8', '2', '3', 'Maria', 11),
('9', '2', '4', 'Kate', 10),
('10', '3', '5', 'Peter', 8),
('11', '3', '5', 'Sergey', 9),
('12', '3', '6', 'Olga', 12),
('13', '3', '6', 'Maria', 14),
('14', '4', '7', 'Irina', 2),
('15', '4', '7', 'Grit', 10),
('16', '4', '7', 'Vanessa', 16),
('17', '5', '8', 'Sascha', 21),
('18', '5', '8', 'Ben', 22),
('19', '6', '9', 'Jessy', 19),
('20', '6', '9', 'Ann', 18);


--id / age / marriageStatus / years of work / children / Remaining Vacation days

insert into employee_details values
('1', 28, 'no', 5, 0, 4),
('2', 45, 'no', 12, 1, 2),
('3', 40, 'yes', 22, 2, 1),
('4', 30, 'no', 20, 1, 7),
('5', 29, 'no', 3, 2, 6),
('6', 30, 'yes', 2, 1, 1),
('7', 28, 'no', 4, 0, 12),
('8', 25, 'yes', 3, 2, 11),
('9', 55, 'yes', 14, 0, 10),
('10', 32, 'yes', 9, 1, 8),
('11', 33, 'no', 8, 2, 9),
('12', 43, 'yes', 6, 0, 12),
('13', 60, 'no', 6, 2, 14),
('14', 43, 'yes', 3, 1, 2),
('15', 40, 'no', 7, 3, 10),
('16', 52, 'yes', 9, 0, 16),
('17', 39, 'yes', 12, 1, 21),
('18', 52, 'no', 9, 3, 22),
('19', 42, 'yes', 1, 0, 19),
('20', 26, 'no', 2, 1, 18);


--id #patients expenses grossProfit 

insert into department_details values
('1', 902, 101932, 180321 ),
('2', 1003, 2320921, 4026730 ),
('3', 301, 199210, 190232 ),
('4', 203, 320000, 402984 ),
('5', 792, 84932, 140123),
('6', 133, 3982923, 6002312);



--1. Вывести количество детей всех сотрудников
SELECT SUM(num_of_children) AS number_of_employees_children
FROM employee_details;

--2. Вывести незамужних сотрудников младше 30 (id name age marriage status)
SELECT employees.id, name, age, marriageStatus
FROM employees
JOIN employee_details
ON employees.id = employee_details.id
WHERE age < 30 AND marriageStatus = 'no';

--3. Вывести количество женатых сотрудников в каждом департаменте (dep_name, num_of_married_employees)
SELECT DISTINCT title, COUNT(emp_id) OVER (PARTITION BY dep_id) as married_employees_count
FROM(
	SELECT departments.id as dep_id, title, name, employees.id as emp_id
	FROM departments
	JOIN employees
	ON employees.departmentId = departments.id
)AS temp_table
JOIN employee_details
ON temp_table.emp_id = employee_details.id
WHERE marriageStatus = 'yes';


--4. Вывести сотрудников с детьми у которых количество дней отпуска > 10 (name, days_of_vacations)
SELECT name, vac_days
FROM employees
JOIN employee_details
ON employees.id = employee_details.id
WHERE vac_days > 10 and num_of_children > 0;

--5. Вывести название департамента и количество отпускных дней которые могут взять сотрудники
SELECT DISTINCT title, SUM(vac_days) OVER (PARTITION BY dep_id) AS vacation_days
FROM(
	SELECT departments.id as dep_id, title, name, employees.id as emp_id
	FROM departments
	JOIN employees
	ON employees.departmentId = departments.id
)AS temp_table
JOIN employee_details
ON temp_table.emp_id = employee_details.id;


--6. Вывести название департаментов которые работают в убыток
SELECT title as financially_worst_department
FROM departments
JOIN department_details
ON departments.id = department_details.id
WHERE gross_profit - expenses < 0;


--7. Вывести топ 3 департамента с максимальной чистой прибылью приходящуюся на одного сотрудника. (title, profit_per_employee )
WITH tmp_table
AS(
SELECT DISTINCT departments.id as dep_id, title, COUNT(employees.id) OVER (PARTITION BY departments.id) as number_of_employees
FROM departments
JOIN employees
ON departments.id = employees.departmentId
ORDER BY dep_id
),
tmp_table2 AS(
	SELECT (gross_profit - expenses) as net_profit, department_details.id as dep_id2
	FROM department_details
)
SELECT title, net_profit / number_of_employees as profit_per_employee
FROM tmp_table2
JOIN tmp_table
ON tmp_table2.dep_id2 = tmp_table.dep_id
ORDER BY profit_per_employee DESC
LIMIT 3;




--8. Вывести  департаменты где средние количество отпускных дней по сотрудникам > 10 (title, average_vacation_days)
WITH tmp_table
AS(
	SELECT  departmentId, AVG(vac_days) OVER (PARTITION BY departmentId) AS average_vacation_days
	FROM employees
	JOIN employee_details
	ON employees.id = employee_details.id
)
SELECT title, average_vacation_days
FROM tmp_table
JOIN departments
ON departments.id = tmp_table.departmentId
WHERE average_vacation_days > 10;


--9.Вывести департамент с максимальной чистой прибылью (name , net_profit)
SELECT title, gross_profit-expenses as net_profit
FROM departments
JOIN department_details
ON departments.id = department_details.id
ORDER BY net_profit DESC
LIMIT 1;

--10. Вывести сотрудников которые работают в департаменте с максимальной валовой прибылью(name, title, gross_profit)
WITH dep_table
AS(
	SELECT departments.id as dep_id, title, gross_profit
	FROM departments
	JOIN department_details
	ON departments.id = department_details.id
	ORDER BY gross_profit DESC
	LIMIT 1
),
emp_table
AS
(
	SELECT name, employees.departmentId as emp_dep_id
	FROM employees
	JOIN employee_details
	ON employees.id = employee_details.id
)
SELECT title, name, gross_profit
FROM dep_table
JOIN emp_table
ON dep_table.dep_id = emp_table.emp_dep_id;

