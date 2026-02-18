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
	'''




-- QUESTION 2: HOW TO FIND DUPLICATES IN SQL EXPLAIN :

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




-- QUESTION 3: DELETING DUPLICATES FROM TABLE


CREATE TABLE emp_details (
    emp_id INT,
    emp_name VARCHAR(10),
    emp_salary INT,
    emptime_stamp TIMESTAMP
);

INSERT INTO emp_details VALUES
(1,'sai',100000,'2024-08-12 09:08:00'),
(2,'raghu',500000,'2025-01-08 12:08:00'),
(3,'balaji',700000,'2026-01-12 07:06:00'),
(4,'guru',70000,'2025-09-23 03:02:00'),
(1,'sai',100000,'2024-08-12 09:43:00');



drop table emp_details;

select * from emp_details;

-- LATEST RECORD & EARLIEST RECORD DELETION 

-- THE BELOW QUERY DELETES THE EARLIEST RECORD FROM THE TABLE

-- TO DELETE LATEST RECORD WE CAN USE MAX FUNCTION

DELETE FROM emp_details
WHERE (emp_id,emptime_stamp) IN(
SELECT emp_id,earliest_timestamp
FROM(
SELECT emp_id,min(emptime_stamp) as earliest_timestamp
FROM emp_details
GROUP BY emp_id
HAVING COUNT(1)>1
) as temp
)
;

-- DELETE DUPLICATES BASED ON emp_id & emp_salary



CREATE TABLE emp_info (
    emp_id INT,
    emp_name VARCHAR(10),
    emp_salary INT,
    emptime_stamp TIMESTAMP
);

INSERT INTO emp_info VALUES
(1,'sai',100000,'2024-08-12 09:08:00'),
(2,'raghu',500000,'2025-01-08 12:08:00'),
(3,'balaji',700000,'2026-01-12 07:06:00'),
(4,'guru',70000,'2025-09-23 03:02:00'),
(1,'sai',120000,'2024-08-12 09:43:00');


SELECT * from emp_info;


DELETE FROM emp_info
WHERE (emp_id,emp_name,emp_salary) IN (
SELECT emp_id,emp_name,min_salary
FROM(
SELECT emp_id,emp_name,min(emp_salary) as min_salary
FROM emp_info
GROUP BY emp_id,emp_name
HAVING COUNT(1)>1) as temp
)
;


-- SCENARIO 2: IF ALL THE ROWS ARE DUPLICATE 

 -- For example if we have (1,'sai',100000,'2024-08-12 09:08:00') record two times the query deletes the two occurences in the table. so the method doesn't work there
 
 -- PURE DUPLICATE ALL ROW VALUES ARE CONSIDERED
 
 
 -- THEN COMES TO THE PICTURE BACKUP TABLE METHOD:
 
 
 
CREATE TABLE emp_list (
    emp_id INT,
    emp_name VARCHAR(10),
    emp_salary INT,
    emptime_stamp TIMESTAMP
);

INSERT INTO emp_list VALUES
(1,'sai',120000,'2024-08-12 09:43:00'),
(2,'raghu',500000,'2025-01-08 12:08:00'),
(3,'balaji',700000,'2026-01-12 07:06:00'),
(4,'guru',70000,'2025-09-23 03:02:00'),
(1,'sai',120000,'2024-08-12 09:43:00'),
(1,'sai',120000,'2024-08-12 09:43:00');

drop table emp_list;

select * from emp_list;

-- APPROACH 1 : USING DISTINCT


-- step 1 : create a backup table


create table emp_list_backup as select * from emp_list;

select * from emp_list_backup;


-- step 2: delete the values from original table

delete from emp_list;

select * from emp_list;


-- step3: get unique values from backup table and place them in original table.

insert into emp_list select distinct * from emp_list_backup;

select * from emp_list;

-- step 4 : drop the backup table

drop table emp_list_backup;


-- APPROACH 2 : USING ROW_NUMBER


-- STEP 1: create a backup table 



create table  emp_list_backup2 as select * from emp_list;

-- step 2 : delete values from original table

delete from emp_list;

select * from emp_list;

-- STEP 3 : USING ROW NUMBER GENERATE RANKS ON YOUR REQUIRED PARTITIONING LEVEL AND FILTER THEM TO GET UNIQUE VALUES AND INSERT THEM INTO ORIGINAL TABLE


INSERT INTO emp_list
SELECT emp_id, emp_name,emp_salary,emptime_stamp
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY emp_id, emp_name, emptime_stamp
               ORDER BY emp_salary DESC
           ) AS ranking
    FROM emp_list_backup2
) a
WHERE a.ranking = 1;


-- STEP 4 : DROP THE BACK UP TABLE 

DROP TABLE emp_list_backup2;

select * from emp_list_backup2;


-- SCENARIO 3: WHAT IF WE HAVE DIFFERNT TIME STAMPS AND REMAINING COLUMN VALUES ARE DUPLICATE HOW CAN WE DELETE THE VALUES WITHOUT CREATING THE BACKUP :

delete from emp_list;

INSERT INTO emp_list VALUES
(1,'sai',120000,'2024-08-12 07:43:00'),
(2,'raghu',500000,'2025-01-08 08:08:00'),
(3,'balaji',700000,'2026-01-12 07:06:00'),
(4,'guru',70000,'2025-09-23 03:02:00'),
(1,'sai',120000,'2024-08-12 09:43:00'),
(1,'sai',120000,'2024-08-12 09:43:55');

-- THIS SHOULD WORK    


DELETE FROM emp_list
WHERE (emp_id, emp_name, emp_salary, emptime_stamp) NOT IN (
    SELECT emp_id, emp_name, emp_salary, latest_time
    FROM (
        SELECT emp_id,
               emp_name,
               emp_salary,
               MAX(emptime_stamp) AS latest_time
        FROM emp_list
        GROUP BY emp_id, emp_name, emp_salary
    ) AS temp
);


select * from emp_list;



-- QUESTION 4: SWAP GENDER FOR GIVEN TABLE


CREATE TABLE staff (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    gender VARCHAR(10),
    salary DECIMAL(10, 2),
    hire_date DATE
);

INSERT INTO staff (emp_id, emp_name, department, gender, salary, hire_date) VALUES
(1, 'John Smith', 'Engineering', 'M', 85000.00, '2020-01-15'),
(2, 'Sarah Johnson', 'Marketing', 'F', 72000.00, '2019-03-22'),
(3, 'Michael Brown', 'Engineering', 'M', 95000.00, '2018-07-10'),
(4, 'Emily Davis', 'Sales', 'F', 68000.00, '2021-02-28'),
(5, 'David Wilson', 'Engineering', 'M', 91000.00, '2019-11-05'),
(6, 'Jennifer Garcia', 'HR', 'F', 65000.00, '2020-06-17'),
(7, 'Robert Martinez', 'Finance', 'M', 78000.00, '2018-09-30'),
(8, 'Lisa Anderson', 'Marketing', 'F', 71000.00, '2021-01-12'),
(9, 'James Taylor', 'Sales', 'M', 69000.00, '2020-08-25'),
(10, 'Mary Thomas', 'Engineering', 'F', 88000.00, '2019-04-18'),
(11, 'Christopher Lee', 'Finance', 'M', 82000.00, '2021-03-07'),
(12, 'Patricia White', 'HR', 'F', 64000.00, '2020-10-22'),
(13, 'Daniel Harris', 'Engineering', 'M', 93000.00, '2018-12-14'),
(14, 'Linda Clark', 'Sales', 'F', 67000.00, '2019-07-29'),
(15, 'Matthew Lewis', 'Marketing', 'M', 73000.00, '2021-05-11');

drop table staff;

select * from staff;

-- QUESTION 1: WHEN THERE IS 'M' REPLACE WITH 'MALE' 'F' REPLACE WITH 'FEMALE'

UPDATE staff 
SET gender=
CASE WHEN gender='M' THEN 'MALE'
WHEN gender='F' THEN 'FEMALE'
ELSE gender
END;

-- QUESTION 2 : SWAP THE GENDER VALUE

-- Production-ready version with safety
START TRANSACTION;

-- Verify before
SELECT 
    gender,
    COUNT(*) as count_before
FROM Staff
GROUP BY gender;

-- Perform swap
UPDATE Staff
SET gender = 
    CASE 
        WHEN gender = 'MALE' THEN 'FEMALE'
        WHEN gender = 'FEMALE' THEN 'MALE'
        ELSE gender
    END;

-- Verify after
SELECT 
    gender,
    COUNT(*) as count_after
FROM Staff
GROUP BY gender;

-- If counts match (MALE before = FEMALE after), then:
COMMIT;




-- QUESTION 5 : SWAP EMP_DETAILS

CREATE TABLE employee_contacts (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    personal_email VARCHAR(100),
    work_email VARCHAR(100),
    personal_phone VARCHAR(15),
    work_phone VARCHAR(15),
    home_address VARCHAR(200),
    office_address VARCHAR(200)
);

INSERT INTO employee_contacts VALUES
(1, 'John Smith', 
    'john@work.com', 'john.smith@personal.com',  -- Emails swapped!
    '555-9999', '555-1234',                      -- Phones swapped!
    '100 Office Plaza', '50 Home Street'),       -- Addresses swapped!
    
(2, 'Sarah Johnson',
    'sarah@work.com', 'sarah.j@personal.com',    -- Emails swapped!
    '555-8888', '555-5678',                      -- Phones swapped!
    '200 Work Ave', '75 Residential Rd'),        -- Addresses swapped!
    
(3, 'Mike Davis',
    'mike.d@personal.com', 'mike@work.com',      -- Correct order!
    '555-1111', '555-9876',                      -- Correct order!
    '25 House Lane', '300 Corporate Blvd');      -- Correct order!
    
    
    
    
    -- Comprehensive employee data correction

START TRANSACTION;

-- 1. Verify data before swap
SELECT 
    emp_id,
    personal_email,
    work_email,
    CASE 
        WHEN personal_email LIKE '%@work.com%' THEN 'NEEDS SWAP'
        ELSE 'OK'
    END as status
FROM employee_contacts;

-- 2. Perform the swap
UPDATE employee_contacts
SET 
    personal_email = work_email,
    work_email = personal_email,
    personal_phone = work_phone,
    work_phone = personal_phone,
    home_address = office_address,
    office_address = home_address
WHERE personal_email LIKE '%@work.com%'  -- Only swap rows that need it
   OR work_email LIKE '%@personal.com%';

-- 3. Verify after swap
SELECT 
    emp_id,
    personal_email,
    work_email,
    CASE 
        WHEN personal_email LIKE '%@personal.com%' 
         AND work_email LIKE '%@work.com%' THEN 'FIXED'
        ELSE 'CHECK'
    END as status
FROM employee_contacts;

-- 4. Commit if everything looks good
COMMIT;
-- Or ROLLBACK if something went wrong


-- QUESTION 6 :  Find all employees who earn more than their managers

CREATE TABLE employees_simple (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    manager_id INT
);

INSERT INTO employees_simple VALUES
(1, 'Alice', 'Executive', 200000.00, NULL),   -- CEO (NULL manager)

(2, 'Bob', 'Engineering', 150000.00, 1),      -- Less than manager
(3, 'Charlie', 'Engineering', 160000.00, 2),  -- More than manager
(4, 'David', 'Sales', 150000.00, 2),          -- Equal to manager
(5, 'Eva', 'Sales', NULL, 4),                 -- NULL salary
(6, 'Frank', 'Marketing', 140000.00, NULL),   -- No manager (NULL)

(7, 'Grace', 'Marketing', 145000.00, 6),      -- More than manager
(8, 'Henry', 'Engineering', 120000.00, 2),    -- Less than manager
(9, 'Ivy', 'Sales', 150000.00, 4),            -- Equal to manager
(10, 'Jack', 'HR', NULL, 1);                  -- NULL salary

select * from employees_simple;




SELECT 
    e2.emp_name AS employee,
    e2.salary AS employee_salary,
    e1.emp_name AS manager,
    e1.salary AS manager_salary
FROM employees_simple e1
JOIN employees_simple e2
    ON e1.emp_id = e2.manager_id
WHERE e2.salary > e1.salary AND e2.salary IS NOT NULL AND e1.salary IS NOT NULL;


-- QUESTION 7 : Find employees who are not present in the department table


-- Clean slate
DROP TABLE IF EXISTS employees_list;
DROP TABLE IF EXISTS departments_list;

-- Departments table
CREATE TABLE departments_list (
    dept_id INT ,
    dept_name VARCHAR(50),
    location VARCHAR(50),
    manager_name VARCHAR(50)
);

-- Employees table
CREATE TABLE employees_list (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2),
    hire_date DATE
);

INSERT INTO departments_list (dept_id, dept_name, location, manager_name) VALUES
(10, 'Engineering', 'San Francisco', 'Sarah Chen'),
(20, 'Sales', 'New York', 'Michael Scott'),
(30, 'Marketing', 'Los Angeles', 'Jennifer Lopez'),
(NULL, 'Unassigned', 'Remote', 'TBD');  -- ⚠️ NULL dept_id (THE TRAP!)

INSERT INTO employees_list (emp_id, emp_name, dept_id, salary, hire_date) VALUES
-- ✅ CASE 1: Valid department (dept_id exists in departments)
(101, 'Alice Johnson', 10, 85000.00, '2020-01-15'),

-- ✅ CASE 2: Valid department (another valid one)
(102, 'Bob Smith', 20, 72000.00, '2019-03-22'),

-- ❌ CASE 3: Invalid department (dept_id = 60 doesn't exist)
(103, 'Carol White', 60, 78000.00, '2018-09-30'),

-- ❌ CASE 4: Invalid department (dept_id = 99 doesn't exist)
(104, 'David Brown', 99, 88000.00, '2021-01-12'),

-- ⚠️ CASE 5: NULL department (employee has no dept assigned)
(105, 'Emma Davis', NULL, 91000.00, '2019-04-18'),

-- ⚠️ CASE 6: NULL department (another NULL case)
(106, 'Frank Miller', NULL, 82000.00, '2021-03-07'),

-- ✅ CASE 7: Valid department (third valid one)
(107, 'Grace Lee', 30, 67000.00, '2020-10-22'),

-- ❌ CASE 8: Invalid department (dept_id = 80 doesn't exist)
(108, 'Henry Wilson', 80, 73000.00, '2021-05-11');


-- 

	
select * from employees_list;

select * from departments_list;

-- METHOD 1: NOT IN SUBQUERY

-- METHOD 1: NOT IN - Use when NULL employees should be EXCLUDED
-- Returns: Only employees with invalid dept_ids (ignores NULL)
SELECT emp_id, emp_name, dept_id
FROM employees_list
WHERE dept_id IS NOT NULL 
  AND dept_id NOT IN (
      SELECT dept_id 
      FROM departments_list 
      WHERE dept_id IS NOT NULL
  );

-- METHOD 2: NOT EXISTS - Use when NULL employees should be INCLUDED  
-- Returns: All orphaned employees (invalid IDs + NULLs)

SELECT e.emp_id, e.emp_name, e.dept_id
FROM employees_list e
WHERE NOT EXISTS (
    SELECT 1
    FROM departments_list d
    WHERE d.dept_id = e.dept_id
);

```

Let me break this down **step-by-step** with our 8-record dataset.

---

## 📚 How EXISTS Works (First Understanding EXISTS)

### **EXISTS returns TRUE or FALSE**

- **EXISTS** checks: "Does at least one row exist that matches the condition?"
- Returns **TRUE** if subquery returns 1+ rows
- Returns **FALSE** if subquery returns 0 rows
- **NOT EXISTS** simply reverses this (TRUE ↔ FALSE)

```

-- METHOD 3: USING JOINS



select * from employees_list;

-- SELECT EMPLOYEES WHO HAVE NO DEPARTMENT IN DEPARTMENT IN THE DEPARTMENTS TABLE AND AVOID NULL VALUES IN EMPLOYEE DEPARTMENT COLUMN

SELECT e1.emp_id,e1.emp_name,e1.dept_id
FROM employees_list e1
LEFT JOIN departments_list d
ON e1.dept_id=d.dept_id
WHERE d.dept_id is null  and e1.dept_id is not null

