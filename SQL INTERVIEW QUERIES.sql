-- QUESTION 1: How can you find the Nth highest salary from a table?

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);

INSERT INTO employees (employee_id, employee_name, department, salary) VALUES
(1, 'Alice Johnson', 'Engineering', 120000.00),
(2, 'Bob Smith', 'Engineering', 95000.00),
(3, 'Carol White', 'Marketing', 85000.00),
(4, 'David Brown', 'Engineering', 120000.00),  -- Duplicate salary (tie case)
(5, 'Eve Davis', 'Sales', 78000.00),
(6, 'Frank Miller', 'Marketing', 92000.00),
(7, 'Grace Lee', 'Engineering', 135000.00),
(8, 'Henry Wilson', 'Sales', 68000.00),
(9, 'Ivy Martinez', 'Engineering', 95000.00),  -- Duplicate salary
(10, 'Jack Taylor', 'Marketing', 88000.00),
(11, 'Karen Anderson', 'Sales', NULL),          -- NULL salary (edge case)
(12, 'Leo Thomas', 'Engineering', 150000.00);



select * from employees order by salary desc;

-- USING ORDER BY AND LIMIT 

SELECT * FROM 
Employees
WHERE salary=(
			   SELECT DISTINCT salary 
			   FROM employees
			   ORDER BY salary DESC
			   LIMIT 1 OFFSET 3     -- OFFSET (N-1) 'N' is rank
               );         

-- SECOND HIGHEST SALARY USING SUB-QUERY: 

SELECT MAX(salary)
FROM employees
where salary<(
			  SELECT MAX(salary) 
			  FROM employees
              );

-- USING CORELATED SUBQUERY:

SELECT * FROM employee e1
WHERE 2=(
		SELECT COUNT(distinct e2.salary)
        FROM employee e2
		WHERE e2.salary>e1.salary
        );

-- QUERY USING WINDOW FUNCTIONS:

-- LET's CONSIDER N=3,3rd highest salary

select * from 
(
SELECT *,dense_rank() over(order by salary desc) as salary_rank
from employees) a
where a.salary_rank=3;  -- GENERATE RANK AND FILTER THE RANK 
