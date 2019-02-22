CREATE TABLE
department (
    id serial PRIMARY KEY,
    title VARCHAR (355) UNIQUE NOT NULL,
    num_of_patients bigint NOT NULL,
    expenses bigint NOT NULL,
	total_revenue bigint NOT NULL
);

CREATE TABLE
family_status (
    id serial PRIMARY KEY,
	title VARCHAR (355) UNIQUE NOT NULL
);

CREATE TABLE
employees (
    id serial PRIMARY KEY,
    name VARCHAR (355)  NOT NULL,
    age bigint NOT NULL,
    family_status_id serial NOT NULL,
    experience_years bigint NOT NULL,
	num_of_children bigint NOT NULL,
	vac_days bigint NOT NULL,
	FOREIGN KEY (family_status_id) REFERENCES family_status (id)
);

CREATE TABLE
position (
    id serial PRIMARY KEY,
	title VARCHAR (355) UNIQUE NOT NULL
);

CREATE TABLE
employees_to_position (
    id serial PRIMARY KEY,
	employee_id serial NOT NULL,
	position_id serial NOT NULL,
	FOREIGN KEY (employee_id) REFERENCES employees (id),
	FOREIGN KEY (position_id) REFERENCES position (id)
);

CREATE TABLE
employees_to_department (
    id serial PRIMARY KEY,
	employee_id serial NOT NULL,
	department_id serial NOT NULL,
	FOREIGN KEY (employee_id) REFERENCES employees (id),
	FOREIGN KEY (department_id) REFERENCES department (id)
);

insert into department values
('1', 'Therapy', 902, 101932, 180321),
('2', 'Neurology', 1003, 2320921, 4026730),
('3', 'Cardiology', 301, 199210, 190232),
('4', 'Gastroenterology',902, 300212, 402984),
('5', 'Hematology',792, 84932, 140123),
('6', 'Oncology', 133, 3982923, 6002312);

insert into family_status values
('1', 'married'),
('2', 'not married'),
('3', 'divorced');

insert into employees values
('1', 'Kate',    28, '1', 	5,  	0,   4),
('2', 'Lidia',   45, '2', 	12, 	1,   2),
('3', 'Alexey',  40, '1', 	22, 	2,   1),
('4', 'Pier',    30, '3', 	20, 	1,   7),
('5', 'Aurel',   29, '1', 	3,  	2,   6),
('6', 'Klaudia', 30, '2', 	2,  	1,   1),
('7', 'Klaus',   28, '1', 	4,  	0,   12),
('8', 'Maria',   25, '2', 	3,  	2,   11),
('9', 'Kate',    55, '1', 	14, 	0,   10),
('10', 'Peter',  32, '3', 	9,  	1,   8),
('11', 'Sergey', 33, '2', 	8,  	2,   9),
('12', 'Olga',   43, '1', 	6,  	0,   12),
('13', 'Maria',  60, '3', 	6,  	2,   14),
('14', 'Irina',  43, '1', 	3,  	1,   2),
('15', 'Grit',   40, '2', 	7,  	3,   10),
('16', 'Vanessa',52, '2', 	9,  	0,   16),
('17', 'Sascha', 39, '1', 	12, 	1,   21),
('18', 'Ben',    52, '1', 	9,  	3,   22),
('19', 'Jessy',  42, '1', 	1,  	0,   19),
('20', 'Ann',    26, '1', 	2,  	1,   18);

insert into position values
('1', 'senior'),
('2', 'middle'),
('3', 'junior');


insert into employees_to_position values
('1',  '1',  '1'),
('2',  '2',  '2'),
('3',  '3',  '1'),
('4',  '4',  '3'),
('5',  '5',  '1'),
('6',  '6',  '2'),
('7',  '7',  '1'),
('8',  '8',  '2'),
('9',  '9',  '1'),
('10', '10', '3'),
('11', '11', '2'),
('12', '12', '1'),
('13', '13', '3'),
('14', '14', '1'),
('15', '15', '2'),
('16', '16', '2'),
('17', '17', '1'),
('18', '18', '1'),
('19', '19', '1'),
('20', '20', '1');

insert into employees_to_department values
('1',  '1',  '1'),
('2',  '2',  '1'),
('3',  '3',  '1'),
('4',  '4',  '1'),
('5',  '5',  '2'),
('6',  '6',  '2'),
('7',  '7',  '2'),
('8',  '8',  '2'),
('9',  '9',  '3'),
('10', '10', '3'),
('11', '11', '3'),
('12', '12', '4'),
('13', '13', '4'),
('14', '14', '4'),
('15', '15', '5'),
('16', '16', '5'),
('17', '17', '6'),
('18', '18', '6'),
('19', '19', '6'),
('20', '20', '6');

 
--1. Вывести количество детей всех сотрудников
SELECT SUM(num_of_children) AS number_of_employees_children
FROM employees;

--2. Вывести незамужних сотрудников младше 30 (id name age marriage status)
SELECT employees.id, name, age, title
FROM employees
JOIN family_status
ON  employees.family_status_id =  family_status.id
WHERE age < 30 AND title = 'not married';

--3. Вывести количество женатых сотрудников в каждом департаменте (dep_name, num_of_married_employees)
SELECT title, employee_count
FROM(
SELECT DISTINCT department_id, COUNT(married_id_employee) OVER (PARTITION BY department_id ) as employee_count
FROM(
	SELECT employees.id as married_id_employee
	FROM employees
	JOIN family_status
	ON  employees.family_status_id =  family_status.id
	WHERE title = 'married'
	)as temp 
JOIN employees_to_department
ON temp.married_id_employee = employees_to_department.employee_id
) as tmp_table2
JOIN department
ON department.id = tmp_table2.department_id;

--4. Вывести сотрудников с детьми у которых количество дней отпуска > 10 (name, days_of_vacations)
SELECT name, vac_days
FROM employees
WHERE num_of_children > 0 AND vac_days > 10;

--5. Вывести id департаментов и количество отпускных дней которые могут взять сотрудники в каждом из них
SELECT title, sum_of_vac_days
FROM(
	SELECT DISTINCT department_id, SUM(vac_days) OVER (PARTITION BY department_id) as sum_of_vac_days
	FROM employees
	JOIN employees_to_department
	ON employees_to_department.employee_id = employees.id
) as tmp
JOIN department
ON department.id = tmp.department_id
ORDER BY sum_of_vac_days;


--6. Вывести название департаментов которые работают в убыток
SELECT title as financially_worst_department
FROM departments
WHERE total_revenue - expenses < 0;

--7.Вывести департамент с максимальной чистой прибылью (name , net_profit)
SELECT title, total_revenue - expenses as net_profit
FROM departments
ORDER BY net_profit DESC
LIMIT 1;

--8. Вывести топ 3 департамента с максимальной чистой прибылью приходящуюся на одного пациента. (title, revenue_per_patient)
SELECT title, (total_revenue - expenses)/ num_of_patients as revenue_per_patient
FROM department
GROUP BY id
ORDER BY revenue_per_patient DESC
LIMIT 3;


--9. Вывести  департаменты где средние количество отпускных дней по сотрудникам > 10 (title, average_vacation_days)
SELECT title, average_vacation_days
FROM(
	SELECT DISTINCT department_id, AVG(vac_days) OVER (PARTITION BY department_id) as average_vacation_days
	FROM employees
	JOIN employees_to_department
	ON employees_to_department.employee_id = employees.id
) as tmp
JOIN department
ON department.id = tmp.department_id
WHERE average_vacation_days > 10
ORDER BY average_vacation_days;


--10. Вывести сотрудников которые работают в департаменте с максимальной выручкой (name, title, gross_profit)

WITH emp_table 
AS(
	SELECT employees.id, employees.name, employees_to_department.department_id
	FROM employees
	JOIN employees_to_department
	ON employees.id = employees_to_department.employee_id
), dep_table
AS (
	SELECT title, total_revenue, id
	FROM department
	ORDER BY total_revenue DESC
	LIMIT 1
)
SELECT name, title, total_revenue
FROM dep_table
JOIN emp_table
ON emp_table.department_id = dep_table.id;
