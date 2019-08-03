
# use utf8 character set for create table and load data
# use MySQL syntax
#-------------------------------------------------------
# create Place table



CREATE TABLE 1Payment
(
SupplierID int NOT NULL,
Date date NOT NULL,
Amount decimal(12,2) NOT NULL,
	Check (Amount >= 0),
FOREIGN KEY(SupplierID) REFERENCES Supplier(SupplierID)
	on update cascade
)



CREATE TABLE Place
(
PlaceID int PRIMARY KEY,
Latitude decimal(10,7) NOT NULL,
Longitude decimal(10,7) NOT NULL,
Elevation int,
Population int Default 0,
	Check (Population >= 0),
Type varchar(60) NOT NULL,
Country varchar (50) NOT NULL,
Index(Latitude) using Btree,
Index(Longitude) using Btree
)
CHARACTER SET utf8;

#---------------------------------------------------
# create Supplier table

CREATE TABLE Supplier
(
SupplierID int PRIMARY KEY,
Name varchar (50) NOT NULL,
Country varchar(20) NOT NULL,
ReliabilityScore int,
ContactInfo varchar(50),
Index(SupplierID) using Hash
)
CHARACTER SET utf8;

#----------------------------------------------------
# create SuppliedName table

CREATE TABLE SuppliedName
(
SnID int PRIMARY KEY,
Name varchar(100) NOT NULL,
Language varchar(30),
Status varchar(20),
Standard varchar(50),
PlaceID int NOT NULL,
SupplierID int,
DateSupplied date,
Index(Name) using Btree,
FOREIGN KEY(SupplierID) REFERENCES Supplier(SupplierID)
	on delete set Null
	on update cascade,
FOREIGN KEY(PlaceID) REFERENCES Place(PlaceID)
	on update cascade
)
CHARACTER SET utf8;

#-----------------------------------------------------
# create Payment table

CREATE TABLE Payment
(
SupplierID int NOT NULL,
Date date NOT NULL,
Amount decimal(12,2) NOT NULL,
	Check (Amount >= 0),
FOREIGN KEY(SupplierID) REFERENCES Supplier(SupplierID)
	on update cascade
)
CHARACTER SET utf8;

#-----------------------------------------------------
# create Department table

CREATE TABLE Department
(
DeptID int PRIMARY KEY,
DeptName varchar(20) NOT NULL UNIQUE,
DeptHeadID int UNIQUE,
DeptHeadUserID varchar(25) UNIQUE,
DeptAA int UNIQUE,
ParentDeptID int,
Index(DeptID) using Hash,
FOREIGN KEY(ParentDeptID) REFERENCES Department(DeptID)
	on delete set Null
	on update cascade
)
CHARACTER SET utf8;


#-----------------------------------------------------
# create Employee table

CREATE TABLE Employee
(
EmpID int PRIMARY KEY,
Name varchar(40) NOT NULL,
TaxID varchar(15) NOT NULL UNIQUE,
Country varchar(20) NOT NULL,
HireDate Date NOT NULL,
BirthDate Date,
Salary decimal(12,2) NOT NULL,
    CHECK (Salary > 0),
Bonus decimal(12,2) Default 0,
	CHECK (Bonus <= Salary),
DeptID int NOT NULL,
Index(EmpID) using Hash,
FOREIGN KEY(DeptID) REFERENCES Department(DeptID)
	on update cascade
)
CHARACTER SET utf8;


