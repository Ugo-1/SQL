--String Concatenation
Select FirstName + ' ' + LastName FullName
from SQLTUTORIAL

-- Aliasing
Select Avg(Age) Average_Age
From SQLTUTORIAL

-- Partitioning
Select FirstName, LastName, Gender, Salary, COUNT(Gender) OVER (PARTITION BY Gender) AS TotalGender
From SQLTUTORIAL as Demo
Join SQLTUTORIAL_Salary as Sal
ON Demo.Employee_id = Sal.Employee_id

Select FirstName, LastName, Gender, Salary, SUM(Salary) OVER (PARTITION BY Gender) AS TotalGenderSalary
From SQLTUTORIAL as Demo
Join SQLTUTORIAL_Salary as Sal
ON Demo.Employee_id = Sal.Employee_id

--Distinct Statement
Select Distinct(Demo.Employee_id)
From SQLTUTORIAL as Demo
join SQLTUTORIAL_Salary as Sal
on Demo.Employee_id = Sal.Employee_id

-- Join
Select *
From SQLTUTORIAL as Demo
right join SQLTUTORIAL_Employee as Emp
on Demo.Employee_id = Emp.Employee_id

-- Union, Intersect and Except Statements
Select *
from SQLTUTORIAL
Union --all --To show duplicates
Select *
from SQLTUTORIAL_Employee
Order by FirstName

Select Employee_id, FirstName, Age
from SQLTUTORIAL
Union
Select Employee_id, JobTitle, Salary
from SQLTUTORIAL_Salary
Order by FirstName

Select *
from SQLTUTORIAL
Intersect
Select *
from SQLTUTORIAL_Employee
Order by FirstName

Select *
from SQLTUTORIAL
Except
Select *
from SQLTUTORIAL_Employee

Select *
from SQLTUTORIAL_Employee
Except
Select *
from SQLTUTORIAL

-- Case Statements just like If Statements
Select FirstName, LastName, Age,
CASE
	WHEN Age > 21 THEN 'Old'
	when age = 21 then 'Semi-Old'
	ELSE 'Young'
END as Title
FROM SQLTUTORIAL
Where age is not null
order by age

Select FirstName, LastName, JobTitle, Salary,
convert(float,Case
	when JobTitle = 'Blogger' then Salary + (Salary * .10)
	when JobTitle like 'UI/%' then Salary + (Salary * .05)
	when JobTitle like 'Micr%' then Salary + (Salary * .0001)
	else Salary + (Salary * .03)
end) as SalaryAfterRaise
from SQLTUTORIAL Demo
join SQLTUTORIAL_Salary Sal
on Demo.Employee_id = Sal.Employee_id

-- CTE (Common Table Expression) / With Statements
With CTE_Employee as 
(
Select FirstName, LastName, Gender, Salary,
Count(Gender) over (Partition by Gender) as TotalGender,
Avg(Salary) over (Partition by Gender) as AvgSalary
From SQLTUTORIAL as Demo
join SQLTUTORIAL_Salary as Sal
on Demo.Employee_id = Sal.Employee_id
where Salary > 20500
)
Select FirstName, AvgSalary
From CTE_Employee

-- Temp Table 1
Create table #temp_Employee (
Employee_id INT,
JobTItle varchar(100),
Salary int
)

insert into #temp_Employee
Values
(1001, 'HR',45000)

Insert into #temp_Employee
select *
from SQLTUTORIAL_Salary
where Employee_id > 1001

Select *
from #temp_Employee

-- Temp Table 2
Create table #Temp_Employee2 (
JobTitle varchar(50),
EmployeesPerJob int,
AvgAge int,
AvgSalary int
)

insert into #Temp_Employee2
Select JobTitle, COUNT(JobTitle), Avg(Age), Avg(Salary)
From SQLTUTORIAL as Demo
join SQLTUTORIAL_Salary as Sal
on Demo.Employee_id = Sal.Employee_id
group by JobTitle

Select *
from #Temp_Employee2

--STRING FUNCTIONS
Select * 
from EmployeeErrors

-- Trim, Ltrim, Rtrim
Select EmployeeID, TRIM(EmployeeID) as IDTRIM
From EmployeeErrors

Select EmployeeID, LTRIM(EmployeeID) as IDTRIM
From EmployeeErrors

Select EmployeeID, RTRIM(EmployeeID) as IDTRIM
From EmployeeErrors

-- Replace Method
Select LastName, REPLACE(LastName, '- Fired', '') as LastNameFixed
From EmployeeErrors

-- Using Substring
Select SUBSTRING(FirstName, 1, 3)
from EmployeeErrors

Select err.FirstName, SUBSTRING(err.FirstName, 1, 3) SubFN, SUBSTRING(Demo.FirstName, 1, 3) SubFN, Demo.FirstName
from EmployeeErrors err
join SQLTUTORIAL as Demo
on SUBSTRING(err.FirstName, 1, 3) = SUBSTRING(Demo.FirstName, 1, 3)

-- Upper and Lower
Select FirstName, LOWER(FirstName) LowerFirstName
from EmployeeErrors

Select FirstName, UPPER(FirstName) UpperFirstName
From EmployeeErrors

-- SUBQUERIES
Select Employee_id, Salary, (Select Avg(Salary) from SQLTUTORIAL_Salary) as AllAvgSalary
From SQLTUTORIAL_Salary

--By Partition
Select Employee_id, Salary, Avg(Salary) Over() as AllAvgSalary
From SQLTUTORIAL_Salary

Select Employee_id, Salary, Avg(Salary) as AllAvgSalary
From SQLTUTORIAL_Salary
Group by Employee_id, Salary
Order by 1,2

--In From 
Select a.Employee_id, AllAvgSalary
From (Select Employee_id, Salary, Avg(Salary) over() as AllAvgSalary From SQLTUTORIAL_Salary) a

--In Where
Select Employee_id, JobTitle, Salary
From SQLTUTORIAL_Salary 
Where Employee_id in (
		Select Employee_id 
		from SQLTUTORIAL
		where Age > 20)