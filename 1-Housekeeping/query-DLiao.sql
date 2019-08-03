# Use MySQL syntax
# 1. Find the elevation and population of a place.

SET NAMES utf8;
Select Elevation, Population 
From Place 
Where PlaceID='6301354';


# 11/28/2017 Andrew's test 
###########################
select * from place;
select * from Place group by PlaceID ;
select Type, count(type) from Place group by Type;
select count(*) from Place;

INSERT INTO Place 
(PlaceID, Latitude, Longitude, Elevation, Population, Type, Country)
VALUES (2, 29.53649, 118.11811, NULL, Default, 'populated place', 'China');

delete from Place where PlaceID=2;

desc Place;
show tables;
show databases;

# A Comprehensive Guide to Using MySQL ENUM Data Type
# http://www.mysqltutorial.org/mysql-enum/

CREATE TABLE tickets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    priority ENUM('Low', 'Medium', 'High') NOT NULL
);

select * from tickets;
select count(*) from tickets;
desc tickets;
delete from tickets;
 
INSERT INTO tickets(title, priority) VALUES('Scan virus for computer A', 'High');
INSERT INTO tickets(title, priority) VALUES('Upgrade Windows OS for all computers', 1);
INSERT INTO tickets(title, priority) VALUES('Install Google Chrome for Mr. John', 'Medium'),
      ('Create a new user for the new employee David', 'High');   


SELECT * FROM tickets WHERE priority = 'High';
SELECT * FROM tickets WHERE priority = 3;    
select title, priority from  tickets order by priority DESC;

SELECT column_type FROM information_schema.COLUMNS WHERE TABLE_NAME = 'tickets' AND COLUMN_NAME = 'priority';
        



#--------------------------------------------------------------------------------------
# 2. Find a place by a partial name.  

use ucsc_sql_hr;
SET NAMES utf8;
Select Name, Place.PlaceID, Latitude, Longitude, Elevation, Population, Type, Country
From SuppliedName join Place 
On SuppliedName.PlaceID=Place.PlaceID
and Name like '%jing%';

#--------------------------------------------------------------------------------------
# 3. Find a place in a latitude/longitude box (within a range of latitudes/longitudes).

SET NAMES utf8;
Select PlaceID, Latitude, Longitude, Elevation, Population, Type, Country 
From Place 
Where Latitude between 29 and 30 and Longitude between 117 and 119;

#---------------------------------------------------------------------------------------------
# 4. Find a place by any of its names, listing its type, latitude, longitude, country, 
#    population and elevation.

SET NAMES utf8;
Select Type, Latitude, Longitude, Country, Population, Elevation
From SuppliedName join Place
On SuppliedName.PlaceID= Place.PlaceID
and Name = 'Beijing';

#-----------------------------------------------------------------------------------------------
# 5. List all the alternate names of a place, along with language, type of name, and standard.

SET NAMES utf8;
Select Name, Language, Status, Standard 
From ucsc_sql_hr.SuppliedName 
Where PlaceID = 6301354 and Status<> 'official'
Order by Language;

#----------------------------------------------------------------------------------------
# 6. Find the supplier who supplied a particular name, along with other information about the
#    supplier. 

SET NAMES utf8;
Select Supplier.SupplierID, Supplier.Name 'Supplier Name', Country, 
ReliabilityScore, ContactInfo 
From SuppliedName join Supplier 
On SuppliedName.SupplierID = Supplier.SupplierID 
and SuppliedName.Name = '北京首都国际机场';

#-----------------------------------------------------------------------
# 7. Find how many more names are in each language this month.

SET NAMES utf8;
Select Language, count(Name) 'Name Increased (Oct)'
From SuppliedName 
Where DateSupplied between '2017-10-01' and '2017-10-31'
Group by Language
Order by Language;

#-----------------------------------------------------------------------
# 8. Find how much was paid out to suppliers this month, total.

SET NAMES utf8;
Select concat('$', format(sum(Amount), 2)) 'Total Payment to Suppliers (Oct)' 
from Payment 
Where Date between '2017-10-01' and '2017-10-31';

#--------------------------------------------------------------------------------
# 9. Find how much was paid out to suppliers this month, by supplier.

SET NAMES utf8;
Select Supplier.SupplierID, Name 'Supplier Name', 
concat('$', format(sum(Amount), 2)) 'Supplier Payment (Oct)'
From Supplier join Payment 
On Supplier.SupplierID = Payment.SupplierID
and Date between '2017-10-01' and '2017-10-31'
Group by Name 
Order by Supplier.SupplierID;

#-----------------------------------------------------------------------------------
#10. Show all employee information in a particular department.

SET NAMES utf8;
Select EmpID, Name, TaxID, Country, HireDate, BirthDate, 
concat('$', format(Salary, 2)) 'Salary' , concat('$', format(Bonus, 2)) 'Bonus', DeptID 
from Employee
Where DeptID = '50'
Order by Name;

#--------------------------------------------------------------------------------------------
# 11. Increase salary by 10% and set bonus to 0 for all employees in a particular department.

SET NAMES utf8;
Update Employee
Set salary = salary * 1.1, bonus = 0
Where deptID= '50';
commit;

#--------------------------------------------------------------------------------------
# 12. Show all current employee information sorted by manager name and employee name.


SET NAMES utf8;
Select emp.EmpID, emp.name 'Employee Name', boss.name 'Manager Name',
emp.TaxID, emp.Country, emp.HireDate, emp.BirthDate,
concat('$', format(emp.Salary, 2)) 'Salary', concat('$', format(emp.Bonus, 2)) 'Bonus', emp.DeptID
From Employee as emp JOIN Department
On emp.DeptID = Department.DeptID
Left join Employee as boss
On boss.EmpID= Department.DeptHeadID
Order by boss.name, emp.name ;

#-------------------------------------------------------------------------------------------------
# 13. Show all supplier information sorted by country, including number of names 
#	  supplied in current month and potential suppliers.

SET NAMES utf8;
Select Supplier.SupplierID , Supplier.Name 'Supplier Name', 
Count(SuppliedName.Name) 'Number of Name Supplied (Oct)', Country, 
ReliabilityScore, ContactInfo 
From Supplier left join SuppliedName
On Supplier.SupplierID = SuppliedName.SupplierID
And DateSupplied between '2017-10-01' and '2017-10-31'
Group by Supplier.SupplierID 
Order by Country;

#------------------------------------------------------------------------------------------------
#  14.  Describe how you implemented the access restrictions on the previous page.
#
#  	Step 1: Create DB user account for all the employees.
#  		   21 DB user accounts have been created for all the employees in 
#		   provision-DLiao.sql file.
#					
# 	create user 
#		Officer_mgr identified by 'Officer_secret1',
#		officer_staff1 identified by 'Officer_secret1',
#		Officer_staff2 identified by 'Officer_secret2',
#		HR_mgr identified by 'HR_secret1',
#		HR_aa identified by 'HR_secret2',
#		HR_staff1 identified by 'HR_secret3',
#		HR_admin identified by 'HR_secret4',
#		IT_mgr identified by 'IT_secret1',
#		IT_aa identified by 'IT_secret2',
#		IT_staff1 identified by 'IT_secret3',
#		IT_staff2 identified by 'IT_secret4',
#		Marketing_mgr identified by 'Marketing_secret1',
#		Marketing_aa identified by 'Marketing_secret2',
#		Marketing_staff1 identified by 'Marketing_secret3',
#		Marketing_staff2 identified by 'Marketing_secret4',
#		Eng_mgr identified by 'Eng_secret1',
#		Eng_aa identified by 'Eng_secret2',
#		Eng_staff1 identified by 'Eng_secret3',
#		Eng_staff2 identified by 'Eng_secret4',
#		Eng_staff3 identified by 'Eng_secret5',
#		Eng_staff4 identified by 'Eng_secret6';
#
#---------------------------------------------------------------------------------
# 	14-1:  All employees can see place and name information.
# 
# 	Step 2: Grant select on Place and SuppliedName tables to all 21 employees are 
#			performed in provision-DLiao.sql file.  
#			MySQL does not support public user, so I have to grant select privilege 
#			on place and suppliedname to all the employees.
#
#	Grant Select on Place to 
#	Officer_mgr,
#	Officer_staff1,
#	Officer_staff2,
#	HR_mgr,
#	HR_aa,
#	HR_staff1,
#	HR_admin,
#	IT_mgr,
#	IT_aa,
#	IT_staff1,
#	IT_staff2,
#	Marketing_mgr,
#	Marketing_aa,
#	Marketing_staff1,
#	Marketing_staff2,
#	Eng_mgr,
#	Eng_aa,
#	Eng_staff1,
#	Eng_staff2,
#	Eng_staff3,
#	Eng_staff4;
#
#
#	Grant Select on SuppliedName to 
#	Officer_mgr,
#	Officer_staff1,
#	Officer_staff2,
#	HR_mgr,
#	HR_aa,
#	HR_staff1,
#	HR_admin,
#	IT_mgr,
#	IT_aa,
#	IT_staff1,
#	IT_staff2,
#	Marketing_mgr,
#	Marketing_aa,
#	Marketing_staff1,
#	Marketing_staff2,
#	Eng_mgr,
#	Eng_aa,
#	Eng_staff1,
#	Eng_staff2,
#	Eng_staff3,
#	Eng_staff4;
#
#   
# 	Sample Answer-->
# 	Logon as 'Eng_staff1' password 'Eng_secret3'.
# 	The user can see Suppliedname and Place info using the following queries:
#
# 	Select * from SuppliedName;
# 	Select * from Place;
#
#----------------------------------------------------------------------------------------
# 	14-2. Only HR employees can access all HR info.
#
# 	Step 3: Grant select on Employee and department tables to HR employees are performed
# 			in provision-DLiao.sql file.
#
#
#	Grant Select on Employee to 
#	HR_mgr,
#	HR_aa,
#	HR_staff1,
#	HR_admin;
#
#
#	Grant Select on Department to 
#	HR_mgr,
#	HR_aa,
#	HR_staff1,
#	HR_admin;
#
#
#	Sample Answer-->
# 	Logon as 'HR_staff1' password 'HR_secret3'.
# 	The user can see Employee and department info using the following queries:
# 
# 	Select * from employee;
# 	Select * from department;

#-----------------------------------------------------------------------------------------
# 	14-3. Only some HR employees can change the information in the HR portion of the DB.
#                
# 	Step 4: Grant all privileges on Employee and department tables to HR_admin are 
#			performed in provision-DLiao.sql file.
#
#
#	Grant all privileges on Employee to HR_admin;
#
#	Grant all privileges on Department to HR_admin;
#
# 	Sample Answer-->
# 	Logon as 'HR_admin' password 'HR_secret4'.
# 	The user can update Employee's name using the following query:
#
# 	Update Employee
# 	Set Name = 'Diana Johnson'
# 	Where Name = 'Diana Loren' and EmpID= 116;
#
#	The user can add a new department using the following query:
#
# 	insert into Department
# 	(DeptID, DeptName)
# 	values(70,'Purchase');
#
#------------------------------------------------------------------------------------
# 	14-4. Managers can see their employee information
#
#  	Step 5: Create view for each manager based on DeptID are performed in 
#			provision-DLiao.sql file.
#
#
#	Create View Dept10
#	As Select * from employee
#	Where DeptID ='10';
#
#
#	Create View Dept20
#	As Select * from employee
#	Where DeptID ='20';
#
#
#	Create View Dept30
#	As Select * from employee
#	Where DeptID ='30';
#
#
#	Create View Dept40
#	As Select * from employee
#	Where DeptID ='40';
#
#
#	Create View Dept50
#	As Select * from employee
#	Where DeptID ='50';
# 	
#
# 	Step 6: Grant select privilege to each manager of the view are performed in 
#			provision-DLiao.sql file.  Each manager can only see his employee's information.
#
#
#	Grant Select on Dept10 to Officer_mgr;
#
#	Grant Select on Dept20 to HR_mgr;
#
#	Grant Select on Dept30 to IT_mgr;
#
#	Grant Select on Dept40 to Marketing_mgr;
#
#	Grant Select on Dept50 to Eng_mgr;
#
#	
#	Sample Answer-->
# 	Logon as 'Eng_mgr' password 'Eng_secret1'.  The user is the manager of Dept50.
# 	The user can see his employee's info using the following query:
#
# 	Select * from Dept50;
#
#------------------------------------------------------------------------------------------------
# 	14-5. Managers can update their employee compensation.
# 
#   Step 7: Grant update privilege on salary and bonus columns to each manager of the view 
#			are performed in provision-DLiao.sql file.
#   		Each manager can update his employee's compensation.
#
#
#	Grant Update (Salary, Bonus) on Dept10 to Officer_mgr;
#
#	Grant Update (Salary, Bonus) on Dept20 to HR_mgr;
#
#	Grant Update (Salary, Bonus) on Dept30 to IT_mgr;
#
#	Grant Update (Salary, Bonus) on Dept40 to Marketing_mgr;
#
#	Grant Update (Salary, Bonus) on Dept50 to Eng_mgr;
#
#	Sample Answer-->
#  	Logon as 'Marketing_mgr' password 'Marketing_secret1'.
# 	The user can update Marketing department Employee's info using the following query:
#
# 	update dept40
# 	set Salary = Salary *1.05, Bonus = 5000;
# 	commit;
#
#--------------------------------------------------------------------------------------------
# 	15. Describe how you implement the constraints shown in the ERD and on the employee info.
# 
# 	15-1:
#
#  CREATE TABLE Place
#  (
#  PlaceID int PRIMARY KEY,
#  Latitude decimal(10,7) NOT NULL,
#  Longitude decimal(10,7) NOT NULL,
#  Elevation int,
#  Population int Default 0,
#	 	Check (Population >= 0),
#  Type varchar(60) NOT NULL,
#  Country varchar (50) NOT NULL,
#  Index(Latitude) using Btree,
#  Index(Longitude) using Btree
#  )
#  CHARACTER SET utf8;
#
#
#	Design of Constraints consideration:
#   1. According to ERD, each place can have 0 to many suppliedname.
#   2. I allow elevation to be null.
#   3. I allow some places does not have a supplied name; i.e. some placeID does not
#      have an associated name entry in the suppliedname table.
#   4. The population is default to 0.
#
#
# 	Constraints of Place table:
# 	Not Null Constrain: Latitude, Longitude, Type, Country
# 	Unique Constrain: N/A
# 	Check Constrain: Check (Population >= 0)
# 	Primary Key Constrain: PlaceID
# 	Foreign Key Constrain: N/A
#
#---------------------------------------------------------------------------------------
# 	15-2:
#
#   CREATE TABLE SuppliedName
#	(
#	SnID int PRIMARY KEY,
#	Name varchar(100) NOT NULL,
#	Language varchar(30),
#	Status varchar(20),
#	Standard varchar(50),
#	PlaceID int NOT NULL,
#	SupplierID int,
#	DateSupplied date,
#	Index(Name) using Btree,
#	FOREIGN KEY(SupplierID) REFERENCES Supplier(SupplierID)
#		on delete set Null
#		on update cascade,
#	FOREIGN KEY(PlaceID) REFERENCES Place(PlaceID)
#		on update cascade,
#	)
#	CHARACTER SET utf8;
#
#
#	Design of Constraints consideration:
#   1. According to ERD, each suppliedname contains 1 place.
#	2. I allow Language, Status, Standard to be null.
#   3. According to ERD, each suppliedname can have 0 or 1 supplier.
#   4. I allow SupplierID, DateSupplied to be null.
#   
#
# 	Constraints of SuppliedName table:
# 	Not Null Constrain: Name, PlaceID
# 	Unique Constrain: N/A
# 	Check Constrain: N/A
# 	Primary Key Constrain: SnID
# 	Foreign Key Constrain: 
#		PlaceID REFERENCES Place(PlaceID) on update cascade, 
# 		SupplierID REFERENCES Supplier(SupplierID) on delete set Null on update cascade.
#
#---------------------------------------------------------------------------------------
# 	15-3:
#
#	CREATE TABLE Supplier
#	(
#	SupplierID int PRIMARY KEY,
#	Name varchar (50) NOT NULL,
#	Country varchar(20) NOT NULL,
#	ReliabilityScore int,
#	ContactInfo varchar(50),
#	Index(SupplierID) using Hash
#	)
#	CHARACTER SET utf8;
#
#
#	Design of Constraints consideration:
#   1. According to ERD, each supplier can have 0 to many payments.
#   2. I allow ReliabilityScore and ContactInfo to be null. When these two fields are
#      null, the supplier is a potential supplier.
#   3. According to ERD, each supplier can supply 0 to many suppliedname.
#   4. I allow some suppliers do not supply name and do not have a payment.
#
#
# 	Constraints of Supplier table:
# 	Not Null Constrain: Name, Country
# 	Unique Constrain: N/A
# 	Check Constrain: N/A
# 	Primary Key Constrain: SupplierID
# 	Foreign Key Constrain: N/A
#
#---------------------------------------------------------------------------------------
# 	15-4:
#
#	CREATE TABLE Payment
#	(
#	SupplierID int NOT NULL,
#	Date date NOT NULL,
#	Amount decimal(12,2) NOT NULL,
#		Check (Amount >= 0),
#	FOREIGN KEY(SupplierID) REFERENCES Supplier(SupplierID)
#		on update cascade
#	)
#	CHARACTER SET utf8;
#
#
#   Design of Constraints consideration:
#   1. According to ERD, each payment has 1 supplier.
#   2. I do not allow any attribute to be null.
#   3. There is no Primary key in this table.  
#      I tried to use the combination primary key of SupplierID, Date and Amount.
#      MySQL only allow me to use either Primary key or Foreign key but not both.
#
#
# 	Constraints of Payment table:
# 	Not Null Constrain: SupplierID, Date, Amount
# 	Unique Constrain: N/A
# 	Check Constrain: Check (Amount >= 0)
# 	Primary Key Constrain: N/A
# 	Foreign Key Constrain: 
#		SupplierID REFERENCES Supplier(SupplierID) on update cascade
#
#
#---------------------------------------------------------------------------------------
# 	15-5:
#
#	CREATE TABLE Department
#	(
#	DeptID int PRIMARY KEY,
#	DeptName varchar(20) NOT NULL UNIQUE,
#	DeptHeadID int UNIQUE,
#	DeptHeadUserID varchar(25) UNIQUE,
#	DeptAA int UNIQUE,
#	ParentDeptID int,
#	Index(DeptID) using Hash,
#	FOREIGN KEY(ParentDeptID) REFERENCES Department(DeptID)
#		on delete set Null
#		on update cascade
#	)
#	CHARACTER SET utf8;
#
#
#   Design of Constraints consideration:
#   1. According to ERD, each department has 0 to many employees, so I allow some
#      department does not have any employee.
#   2. I allow DeptHeadID, DeptHeadUserID, DeptAA to be null.
#   3. ParentDeptID can be null since CEO does not have any parent department.
#
#
# 	Constraints of Department table:
# 	Not Null Constrain: DeptName
# 	Unique Constrain: DeptName, DeptHeadID, DeptHeadUserID, DeptAA
# 	Check Constrain: N/A
# 	Primary Key Constrain: DeptID
# 	Foreign Key Constrain: 
#		ParentDeptID REFERENCES Department(DeptID) on delete set Null on update cascade
#	
#---------------------------------------------------------------------------------------
# 	15-6:
#
#	CREATE TABLE Employee
#	(
#	EmpID int PRIMARY KEY,
#	Name varchar(40) NOT NULL,
#	TaxID varchar(15) NOT NULL UNIQUE,
#	Country varchar(20) NOT NULL,
#	HireDate Date NOT NULL,
#	BirthDate Date,
#	Salary decimal(12,2) NOT NULL,
#	    CHECK (Salary > 0),
#	Bonus decimal(12,2) Default 0,
#	    CHECK (Bonus <= Salary),
#	DeptID int NOT NULL,
#	Index(EmpID) using Hash,
#	FOREIGN KEY(DeptID) REFERENCES Department(DeptID)
#		on update cascade
#	)
#	CHARACTER SET utf8;
#
#
#   Design of Constraints consideration:
#   1. According to ERD, each employee belongs to one department, so
#	   I set DeptID to not null.
#   2. I allow BirthDate to be null.
#   3. I set the default bonus to 0 because we cannot compare NULL to
#      any value.
#	  
#
# 	Constraints of Employee table:
# 	Not Null Constrain: Name, TaxID, Country, HireDate, Salary, DeptID
# 	Unique Constrain: TaxID
# 	Check Constrain: CHECK (Salary > 0), CHECK (Bonus <= Salary)
# 	Primary Key Constrain: EmpID
# 	Foreign Key Constrain: 
#		DeptID REFERENCES Department(DeptID) on update cascade
#