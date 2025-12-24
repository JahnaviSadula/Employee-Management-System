CREATE DATABASE EmployeeManagementSystem;
USE EmployeeManagementSystem;


-- Table 1: Job Department 
CREATE TABLE JobDepartment ( 
    Job_ID INT PRIMARY KEY, 
    jobdept VARCHAR(50), 
    name VARCHAR(100), 
    description TEXT, 
    salaryrange VARCHAR(50) 
);

-- Table 2: Salary/Bonus 
CREATE TABLE SalaryBonus ( 
    salary_ID INT PRIMARY KEY, 
    Job_ID INT, 
    amount DECIMAL(10,2), 
    annual DECIMAL(10,2), 
    bonus DECIMAL(10,2), 
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE 
);

 -- Table 3: Employee 
CREATE TABLE Employee ( 
    emp_ID INT PRIMARY KEY, 
    firstname VARCHAR(50), 
    lastname VARCHAR(50), 
    gender VARCHAR(10), 
    age INT, 
    contact_add VARCHAR(100), 
    emp_email VARCHAR(100) UNIQUE, 
    emp_pass VARCHAR(50), 
    Job_ID INT, 
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID) 
        REFERENCES JobDepartment(Job_ID) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE 
);

-- Table 4: Qualification 
CREATE TABLE Qualification ( 
    QualID INT PRIMARY KEY, 
    Emp_ID INT, 
    Position VARCHAR(50), 
    Requirements VARCHAR(255), 
    Date_In DATE, 
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID) 
        REFERENCES Employee(emp_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE 
); 

-- Table 5: Leaves 
CREATE TABLE Leaves ( 
    leave_ID INT PRIMARY KEY, 
    emp_ID INT, 
    date DATE, 
    reason TEXT, 
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE 
);

 -- Table 6: Payroll 
CREATE TABLE Payroll ( 
    payroll_ID INT PRIMARY KEY, 
    emp_ID INT, 
    job_ID INT, 
    salary_ID INT, 
    leave_ID INT, 
    date DATE, 
    report TEXT, 
    total_amount DECIMAL(10,2), 
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE, 
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE, 
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES 
SalaryBonus(salary_ID) 
        ON DELETE CASCADE ON UPDATE CASCADE, 
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID) 
        ON DELETE SET NULL ON UPDATE CASCADE 
);

SHOW TABLES;

SHOW DATABASES;

USE EmployeeManagementSystem;

SHOW TABLES;

DESC employee;

DESC jobdepartment;

DESC leaves;

DESC payroll;

DESC qualification;

DESC salarybonus;

select * from employee;

select * from jobdepartment;

select * from leaves;

select * from payroll;

select * from qualification;

select * from salarybonus;

# EMPLOYEE INSIGHTS

# How many unique employees are currently in the system?
SELECT COUNT(DISTINCT emp_ID) AS total_employees
FROM employee;

# Which departments have the highest number of employees?
SELECT j.jobdept AS department,
       COUNT(emp_ID) AS employee_count
FROM employee e
INNER JOIN 
        jobdepartment j
ON
  e.job_ID=j.JOB_id
GROUP BY
   j.jobdept
ORDER BY
     employee_count DESC
LIMIT 5;

# What is the average salary per department?
SELECT 
     j.jobdept AS department,
       ROUND(avg(s.amount),0) AS average_annual_salary
FROM 
    jobdepartment j
INNER JOIN 
        salarybonus s 
ON 
      s.Job_ID = j.Job_ID
GROUP BY  
       j.jobdept
ORDER BY
      average_annual_salary DESC;
      
# Who are the top 5 highest-paid employees?
SELECT Emp_id, FirstName, LastName, Salary FROM

(SELECT
		e.emp_ID AS Emp_ID,
		e.firstname AS FirstName,
        e.lastname AS LastName,
		s.amount AS Salary,
		DENSE_RANK() OVER(ORDER BY s.amount DESC) AS RNK
FROM
        employee e
INNER JOIN
        salarybonus s
ON
		e.Job_ID=s.Job_ID) SUB
WHERE
        RNK<=5;

# What is the total salary expenditure across the company?
SELECT ROUND(SUM(annual+bonus)) AS total_salary_expenditure
FROM salarybonus;





# 2. JOB ROLE AND DEPARTMENT ANALYSIS

# How many different job roles exist in each department?
SELECT
      jobdept AS Department,
      COUNT(DISTINCT name) No_of_Roles
FROM
      jobdepartment
GROUP BY
       Department
ORDER BY
       No_of_Roles DESC;

# What is the average salary range per department?
SELECT
      j.jobdept AS Department,
      ROUND(AVG(s.amount), 2) AVG_Salary
FROM
      jobdepartment j
INNER JOIN
      salarybonus s
ON
      j.Job_ID=s.Job_ID
GROUP BY
       Department
ORDER BY
       AVG_Salary;

# Which job roles offer the highest salary?
SELECT
       J.name AS Role_,
       s.amount AS Salary
FROM
       jobdepartment j
INNER JOIN
       salarybonus s
ON
       s.Job_ID=j.Job_ID
ORDER BY
      Salary DESC
LIMIT 5;

# Which departments have the highest total salary allocation?
SELECT
       j.jobdept AS Department,
       SUM(s.annual+s.bonus) Total_Salary
FROM
       jobdepartment j
INNER JOIN
       salarybonus s
ON
       j.Job_ID=s.Job_ID
GROUP BY
        Department
ORDER BY
       Total_Salary
LIMIT 5;




# 3. QUALIFICATION AND SKILLS ANALYSIS

# How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT emp_ID) AS employees_with_qualifications
FROM qualification;

# Which positions require the most qualifications?
SELECT position,
       COUNT(QualID) AS total_qualifications
FROM qualification
GROUP BY position
ORDER BY total_qualifications DESC
LIMIT 5;

# Which employees have the highest number of qualifications?
SELECT e.emp_ID,
       e.firstname,
       e.lastname,
       COUNT(q.QualID) AS qualification_count
FROM employee e
JOIN qualification q ON e.emp_ID = q.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY qualification_count DESC
LIMIT 5;




# 4. LEAVE AND ABSENCE PATTERNS

# Which year had the most employees taking leaves?
SELECT YEAR(date) AS leave_year,
       COUNT(DISTINCT emp_ID) AS employees_on_leave
FROM leaves
GROUP BY YEAR(date)
ORDER BY employees_on_leave DESC;

# What is the average number of leave days taken by employees per department?
SELECT
     j.jobdept Department,
     ROUND (COUNT(l.leave_ID)/COUNT(e.emp_ID), 0) AS AVG_no_of_Leaves
FROM
	 jobdepartment j
INNER JOIN
      employee e
INNER JOIN
       leaves l
ON
      e.emp_ID=l.emp_ID
AND
      j.Job_ID=e.Job_ID
GROUP BY
      Department;

# Which employees have taken the most leaves?
SELECT e.emp_ID,
       e.firstname,
       e.lastname,
       COUNT(l.leave_ID) AS total_leave_days
FROM employee e
JOIN leaves l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
ORDER BY total_leave_days DESC
LIMIT 5;

# What is the total number of leave days taken company-wide?
SELECT COUNT(leave_ID) AS total_company_leave_days
FROM leaves;

# How do leave days correlate with payroll amounts?
SELECT 
    p.LEAVE_ID,
    COUNT(l.DATE) AS leave_days,
    SUM(p.TOTAL_AMOUNT) AS total_payroll
FROM Payroll p
INNER JOIN Leaves l 
    ON p.LEAVE_ID = l.LEAVE_ID
GROUP BY p.LEAVE_ID;



# 5. PAYROLL AND COMPENSATION ANALYSIS

# What is the total monthly payroll processed?
SELECT YEAR(date) AS pay_year,
       MONTH(date) AS pay_month,
       SUM(total_amount) AS total_monthly_payroll
FROM payroll
GROUP BY YEAR(date), MONTH(date)
ORDER BY pay_year, pay_month;

# What is the average bonus given per department?
SELECT
      j.jobdept AS Department,
      ROUND(AVG(s.bonus), 2) AVG_Bonus
FROM
	  jobdepartment j
INNER JOIN
      salarybonus s
ON
      j.Job_ID=s.Job_ID
GROUP BY
      Department
ORDER BY
      AVG_Bonus DESC;

# Which department receives the highest total bonuses?
SELECT j.jobdept AS Department,
       SUM(s.bonus)  total_bonus
FROM jobdepartment j
INNER JOIN salarybonus s
 ON j.job_ID = s.job_ID
GROUP BY Department
ORDER BY total_bonus DESC
LIMIT 1;

# What is the average value of total_amount after considering leave deductions?
SELECT AVG(total_amount) AS avg_salary_after_deductions
FROM payroll;
