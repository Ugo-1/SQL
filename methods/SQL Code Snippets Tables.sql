DROP TABLE IF EXISTS SQLTUTORIAL_Salary
Create table SQLTUTORIAL_Salary (
Employee_id INT,
JobTitle VARCHAR(255),
Salary INT
)

INSERT INTO SQLTUTORIAL_Salary
VALUES
(1001, 'Banker', 20000),
(1002, 'UI/UX Designer', 30000),
(1003, 'Microbiologist', 22000),
(1004, 'Blogger', 21000),
(1005, 'Model', 21000),
(1006, 'Receptionist', 12000),
(1007, 'Regional Manager', 32000),
(1008, 'HR', 40000),
(1009, 'HR', 35000),
(1010, Null, 41000),
(Null, 'Banker', 25000)

DROP TABLE IF EXISTS SQLTUTORIAL
Create table SQLTUTORIAL (
Employee_id INT,
FirstName VARCHAR(255),
LastName VARCHAR(255),
Age INT,
Gender VARCHAR(255)
)

INSERT INTO SQLTUTORIAL (Employee_id, FirstName, LastName, Age, Gender)
VALUES
(1001, 'Jim', 'Kilani', 20, 'Male'),
(1002, 'Pam', 'Ajayi', 20, 'Male'),
(1003, 'Toby', 'Patrick', 22, 'Male'),
(1004, 'Chinenye', 'Ejike', 21, 'Female'),
(1005, 'Sydney', 'Ubah', 21, 'Male')

DROP TABLE IF EXISTS SQLTUTORIAL_Employee
Create table SQLTUTORIAL_Employee (
Employee_id INT,
FirstName VARCHAR(255),
LastName VARCHAR(255),
Age INT,
Gender VARCHAR(255)
)
INSERT INTO SQLTUTORIAL_Employee
VALUES
(1005, 'Sydney', 'Ubah', 21, 'Male'),
(1006, 'Solomon', 'Nyeche', 24, 'Male'),
(1007, 'Ugochukwu', 'Umeh', 21, 'Male'),
(1008, 'Jennifer', 'Ibrahim', 21, 'Female'),
(1009, 'Chioma', 'Makwe', 21, 'Male')

DROP TABLE IF EXISTS EmployeeErrors 
CREATE TABLE EmployeeErrors(
EmployeeID varchar(50),
FirstName varchar(50),
LastName varchar(50)
)

INSERT INTO EmployeeErrors
VALUES 
('1001    ', 'Jimbo', 'Halbert'),
('    1002', 'Pamela', 'Beasely'),
('1003', 'TOby', 'Flenderson - Fired')