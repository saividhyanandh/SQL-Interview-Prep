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



-- QUESTION 2: DIFFERENCE BETWEEN RANK(),DENSE_RANK(),ROW_NUMBER():


'''
1. ROW_NUMBER()

Assigns unique sequential integers (1, 2, 3, 4...)
Never repeats, even for duplicate values
Use case: Remove duplicates, pagination, assigning unique IDs

2. RANK()

Assigns same rank to duplicate values
Skips next rank(s) → creates gaps (3, 3, 5 not 3, 3, 4)
Use case: Competitive rankings (Olympics, leaderboards) where ties skip positions

3. DENSE_RANK()

Assigns same rank to duplicate values
NO gaps → consecutive ranking (3, 3, 4 not 3, 3, 5)
Use case: Finding Nth highest/lowest values, category tiers, no gaps needed

'''

	''' NOTE : RANKING FUNCTIONS ASSIGN RANK VALUES TO NULLS AS WELL BE CAREFUL WHILE YOU USE THEM'''

SELECT salary,
    RANK() OVER (ORDER BY salary DESC) as rank_val,
    DENSE_RANK() OVER (ORDER BY salary DESC) as dense_rank_val,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as row_num
FROM employees
WHERE salary IS NOT NULL;


## 🎯 Decision Tree: Which Function to Use?
```
Question: Do you need to handle duplicate values?
│
├─ NO → Use ROW_NUMBER()
│        (Every row needs unique number regardless of values)
│        Examples: Pagination, IDs, deduplication
│
└─ YES → Question: Should duplicates affect ranking of next items?
         │
         ├─ YES → Use RANK()
         │        (Ties create gaps - competition logic)
         │        Examples: Sports rankings, sales leaderboards
         │
         └─ NO → Use DENSE_RANK()
                  (No gaps - every level exists)




-- HOW TO FIND DUPLICATES IN SQL EXPLAIN :

 DROP TABLE CUSTOMERS;

CREATE TABLE customers (
    customer_id INT  PRIMARY KEY,
    email VARCHAR(100),
    phone VARCHAR(15),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    city VARCHAR(50),
    registration_date DATE
);


INSERT INTO customers (customer_id, email, phone, first_name, last_name, city, registration_date) VALUES
(1, 'john.doe@email.com', '555-0101', 'John', 'Doe', 'New York', '2024-01-15'),
(2, 'jane.smith@email.com', '555-0102', 'Jane', 'Smith', 'Los Angeles', '2024-01-16'),
(3, 'john.doe@email.com', '555-0103', 'John', 'Doe', 'New York', '2024-01-17'),      -- Duplicate email
(4, 'bob.wilson@email.com', '555-0104', 'Bob', 'Wilson', 'Chicago', '2024-01-18'),
(5, 'alice.brown@email.com', '555-0105', 'Alice', 'Brown', 'Houston', '2024-01-19'),
(6, 'jane.smith@email.com', '555-0106', 'Jane', 'Smith', 'Boston', '2024-01-20'),    -- Duplicate email
(7, 'charlie.davis@email.com', '555-0107', 'Charlie', 'Davis', 'Phoenix', '2024-01-21'),
(8, 'john.doe@email.com', '555-0108', 'John', 'Doe', 'Seattle', '2024-01-22'),       -- Duplicate email (3rd occurrence)
(9, 'emma.jones@email.com', '555-0104', 'Emma', 'Jones', 'Denver', '2024-01-23'),    -- Duplicate phone
(10, 'mike.taylor@email.com', '555-0110', 'Mike', 'Taylor', 'Atlanta', '2024-01-24'),
(11, 'sarah.white@email.com', NULL, 'Sarah', 'White', 'Miami', '2024-01-25'),        -- NULL phone
(12, 'david.lee@email.com', NULL, 'David', 'Lee', 'Dallas', '2024-01-26'),           -- NULL phone (duplicate NULL case)
(13, 'alice.brown@email.com', '555-0113', 'Alice', 'Brown', 'Houston', '2024-01-27'), -- Duplicate email
(14, 'lisa.anderson@email.com', '555-0114', 'Lisa', 'Anderson', 'San Diego', '2024-01-28'),
(15, 'john.doe@email.com', '555-0115', 'Johnny', 'Doe', 'Portland', '2024-01-29'),  -- Duplicate email (different first_name)
(16, 'john.doe@email.com', '555-0101', 'John', 'Doe', 'New York', '2024-01-15'), -- DUPLICATE RECORD
(17, 'john.doe@email.com', '555-0103', 'John', 'Doe', 'New York', '2024-01-17'),  -- DUPLICATE RECORD
(18, 'john.doe@email.com', '555-0108', 'John', 'Doe', 'Seattle', '2024-01-22');   -- DUPLICATE RECORD 


-- APPROACH 1: USING HAVING & GROUP BY :

-- FINDING DUPLICATE VALUES CONSIDERING ALL COLUMNS:

select email, phone, first_name, last_name, city, registration_date,count(*) as cnt
from customers
group by email, phone, first_name, last_name, city, registration_date
having count(*)>1;

-- FINDING DUPLICATE VALUES CONSIDERING MULTIPLE COLUMNS:

select email,phone,count(*) as cnt
from customers
group by 1,2
having cnt>1;


-- APPROACH -2 : USING ROW_NUMBER

 # FINDING DUPLICATE VALUES CONSIDERING ALL COLUMNS:
 
SELECT *
FROM(
SELECT *,row_number() over(partition by email, phone, first_name, last_name, city, registration_date) as rnk
FROM customers) a
WHERE a.rnk>1;


# FINDING DUPLICATE VALUES CONSIDERING MULTIPLE COULUMNS:

SELECT email,phone FROM (
SELECT *,row_number() OVER(partition by email, phone) as rnk
FROM customers) a
WHERE a.rnk>1;


-- APPROACH 3: FINDING DUPLICATES USING SELF JOIN

# FINDING DUPLICATE VALUES CONSIDERING ALL COLUMNS:

SELECT c1.*
FROM customers c1
join customers c2
ON c1.customer_id > c2.customer_id and c1.email=c2.email and c1.phone=c2.phone and c1.first_name=c2.first_name and c1.last_name=c2.last_name and c1.registration_date=c2.registration_date;

# FINDING DUPLICATE VALUES CONSIDERING MULTIPLE COULUMNS:

SELECT c1.customer_id,c1.email,c1.phone,c2.customer_id,c2.email,c2.phone
FROM customers c1
Join customers c2
on c1.customer_id>c2.customer_id and c1.email=c2.email and c1.phone=c2.phone;

-- APPROACH 4 : USING EXISTS 
-- 


SELECT c1.customer_id,c1.email,c1.phone
FROM customers c1
WHERE EXISTS (
			  SELECT 1
			  FROM customers c2
			  WHERE c1.email=c2.email AND c1.phone=c2.phone AND c1.customer_id!=c2.customer_id
              );

