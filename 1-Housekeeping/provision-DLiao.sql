
# use utf8 character set for create table and load data
# use MySQL syntax
#-------------------------------------------------------
# create Place table


CREATE TABLE tab_uuid (
    uid char(36) NULL,
    `reference` varchar(100) NOT NULL
);

Create TABLE bank
(
uid uuid,
age int,
job varchar (50),
marital varchar (10),
education varchar (50),
default_1 varchar (3),
balance int,
housing varchar (10),
loan varchar (10),
contact varchar (10),
day 


) 
CHARACTER SET utf8;

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


#------------------------------
# Andrew: Test Index:
# Sample syntx: CREATE INDEX part_of_name ON customer (name(10));


CREATE INDEX Elevation_idx1 on Place (Elevation); 
select * from Place use index (Elevation_idx1) where Elevation=1;
# JaguarDB doesn't support use index; but it support:
# select from use index, which is not very useful as we can use: "select index1, index2 from table where ...."


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


#-------------------------------------------------------------

# data for Place table

SET NAMES utf8;

INSERT INTO Place 
(PlaceID, Latitude, Longitude, Elevation, Population, Type, Country)
VALUES
(1553271, 29.53649, 118.11811, NULL, Default, 'populated place', 'China'),
(1816670, 39.9075, 116.39723, NULL, 7480601, 'capital of a political entity', 'China'),
(2038349, 39.91691, 116.39706, NULL, 14933274, 'first-order administrative division', 'China'),
(6525097, 33, 104, NULL, Default, 'hotel', 'China'),
(6301354, 40.08011, 116.58456, 35, Default, 'airport', 'China'),

(1275339, 19.07283, 72.88261, NULL, 12691836, 'seat of a first-order administrative division', 'India'),
(6500547, 19.0765, 72.8491, NULL, Default, 'hotel', 'India'),
(6619198, 18.9341, 72.82365, NULL, Default, 'road', 'India'),
(6619701, 18.92988, 72.8332, NULL, Default, 'building', 'India'),
(8030132, 19.00725, 72.82012, NULL, Default, 'tower', 'India'),

(6058567, 47.5668, -81.54976, NULL, Default, 'lake', 'Canada'),
(6058568, 45.45963, -63.5715, NULL, Default, 'populated place', 'Canada'),
(6058575, 63.71737, -91.71662, NULL, Default, 'shoals', 'Canada'),
(6081605, 59.0327, -134.3704, NULL, Default, 'mountain', 'Canada'),
(6482025, 42.9433, -81.2257, NULL, Default, 'hotel', 'Canada'),

(5104348, 40.73066, -74.18487, 28, Default, 'school', 'USA'),
(5147134, 40.98172, -81.04204, 322, Default, 'airport', 'USA'),
(5147138, 41.04589, -81.00259, 295, Default, 'dam', 'USA'),
(5147143, 41.32505, -82.49295, 238, Default, 'post office', 'USA'),
(5147151, 41.32561, -82.49295, 237, Default, 'library', 'USA');

#---------------------------------------------------------------------------------------
# data for Supplier table 

SET NAMES utf8;

INSERT INTO Supplier
(SupplierID, Name, Country, ReliabilityScore, ContactInfo)
VALUES
(1001, 'Aaron Lambie Names Inc', 'Canada', 95,'aaron.lambie@spatialq.com'),
(1002, 'Christophe Boutreux Inc', 'France', 80,'christophe@geonames.org'),
(1003, 'Marc Wick Inc', 'Switzerland', 90,'marc@geonames.org'),
(1004, 'EuroSense Inc', 'Belgium', 70,'Phone: (+32)-2-460-70-00'),
(1005, 'Zenrin Co., Ltd.', 'Japan', 87,'Phone: (+81)-93-882-9050'),
(1006, 'Indiacom Ltd', 'India', 95,'Phone: (+91)-20-26603800'),
(1007, 'Infogroup Inc', 'USA', 80,'Phone: 1-402-836-5290'),
(1008, 'The Digital Globe Inc', 'USA', 90,'Phone: 1-800-655-7929'),
(1009, 'King Lee Inc', 'China', NULL, NULL),
(1010, 'Park Kim Inc', 'Korea', NULL, NULL);

#--------------------------------------------------------------------------------------------------

# data for SuppliedName table 

SET NAMES utf8;

INSERT INTO SuppliedName
(SnID, Name, Language, Status, Standard, PlaceID, SupplierID, DateSupplied)
VALUES

(10000, 'Beijingshan', 'English', 'official', 'U.S. Board on Geographic Names', '1553271', '1001', '2017-10-02'),
(10001, 'bei jing shan', 'English','historical', 'U.S. Board on Geographic Names', '1553271', '1007', '2017-10-02'),
(10002, '北京山', 'Chinese', 'current', 'U.S. Board on Geographic Names', '1553271', '1008', '2017-10-02'),

(10003, 'Beijing', 'English', 'official', 'U.S. Board on Geographic Names', '1816670', '1002', '2017-10-03'),
(10004, 'Bac Kinh', 'English', 'colloquial', 'U.S. Board on Geographic Names', '1816670', '1002', '2017-10-03'),
(10005, '北京', 'Chinese', 'current', 'U.S. Board on Geographic Names', '1816670', '1002', '2017-10-03'),
(10006, 'Пекин', 'Russian', 'current', 'U.S. Board on Geographic Names', '1816670', '1007', '2017-10-25'),
(10007, 'Пекинг', 'Russian', 'historical', 'U.S. Board on Geographic Names', '1816670', '1008', '2017-10-25'),
(10026, '베이징 시', 'Korean', 'current', 'U.S. Board on Geographic Names', '1816670', '1007', '2017-10-03'),
(10027, 'Peking', 'English', 'historical', 'U.S. Board on Geographic Names', '1816670', '1002', '2017-10-03'),

(10008, 'Beijing Shi','English', 'official', 'U.S. Board on Geographic Names', '2038349', '1006', '2017-10-05'),
(10009, 'Pei-p’ing Shih', 'English', 'historical', 'U.S. Board on Geographic Names', '2038349', '1002', '2017-10-05'),
(10010, '北京市', 'Chinese', 'current', 'U.S. Board on Geographic Names', '2038349', '1002', '2017-10-05'),

(10011, 'Beijing Capital International Airport', 'English', 'official', 'U.S. Board on Geographic Names', '6301354', '1002', '2017-10-07'),
(10012, '北京首都国際空港', 'Japanese', 'current', NULL, '6301354', '1002', '2017-10-07'),
(10013, '北京首都国际机场', 'Chinese', 'current', 'U.S. Board on Geographic Names', '6301354', '1002', '2017-10-07'),
(10014, '베이징 수도 국제공항', 'Korean', 'current', NULL, '6301354', '1002', '2017-10-07'),
(10028, 'Aeroport Internacional de Pequin', 'Catalan', 'current', NULL, '6301354', '1007', '2017-10-27'),
(10029, 'Aeroporto Internacional de Pequim', 'Portuguese', 'current', NULL, '6301354', '1007', '2017-10-27'),
(10030, 'Aeroporto Internazionale di Pechino', 'Italian', 'current', NULL, '6301354', '1007', '2017-10-27'),
(10031, 'Aeropuerto Internacional de Pekin', 'Spanish', 'current', NULL, '6301354', '1007', '2017-10-27'),
(10032, 'Aéroport international de Pékin', 'French', 'current', NULL, '6301354', '1007', '2017-10-27'),
(10033, 'Flughafen Peking', 'German', 'current', NULL, '6301354', '1007', '2017-10-27'),
(10034, 'Luchthaven Peking Capital', 'Dutch', 'current', NULL,'6301354','1007', '2017-10-27'),
(10035, 'San bay quoc te Thu GJo Bac Kinh', 'Vietnamese', 'current', NULL, '6301354', '1007', '2017-10-27'),
(10037, 'Beijing Shoudu Guoji Jichang', 'English', 'current', 'U.S. Board on Geographic Names', '6301354', '1002', '2017-10-30'),

(10015, 'Beijing Chateau De Luze', 'English', 'current', NULL, '6525097', '1002', '2017-10-08'),
(10036, '北京和乔丽致酒店', 'Chinese', 'current', NULL, '6525097', '1002', '2017-10-08'),
(10016, 'Londonderry Lake', 'English', 'current', NULL, '6058567', '1003', '2017-10-09'),
(10017, 'Londonderry Station', 'English', 'current', NULL, '6058568', '1003', '2017-10-10'),
(10018, 'London Rock', 'English', 'current', NULL, '6058575', '1003', '2017-10-11'),
(10019, 'Mount London', 'English', 'official', 'U.S. Board on Geographic Names', '6081605', '1003', '2017-10-12'),
(10020, 'Radisson Hotel & Suites London', 'English', 'current', NULL, '6482025', '1003', '2017-10-13'),
(10021, 'Samuel L Berliner School', 'English', 'official', 'The Geographic Names Information System', '5104348', '1004', '2017-10-15'),
(10022, 'Berlin Airpark', 'English', 'historical', 'The Geographic Names Information System', '5147134', '1004', '2017-10-15'),
(10023, 'Berlin Dam', 'English', 'official', 'The Geographic Names Information System', '5147138', '1005', '2017-10-15'),
(10024, 'Berlin Heights Post Office', 'English', 'official', 'The Geographic Names Information System', '5147143', '1005', '2017-10-15'),
(10025, 'Berlin Township Public Library', 'English', 'official', 'The Geographic Names Information System', '5147151', '1005', '2017-10-15');


#----------------------------------------------------------------------
# data for Payment table 

SET NAMES utf8;

INSERT INTO Payment
(SupplierID, Date, Amount)
VALUES
(1001, '2017-09-30', '1000.32'),
(1001, '2017-10-02', '500'),
(1001, '2017-10-07', '800.90'),
(1002, '2017-09-03', '200'),
(1002, '2017-10-03', '200'),
(1002, '2017-10-13', '500.50'),
(1003, '2017-09-06', '400'),
(1003, '2017-10-06', '900'),
(1003, '2017-10-16', '700'),
(1003, '2017-10-20', '600'),
(1004, '2017-10-07', '800.50'),
(1005, '2017-10-20', '700.67'),
(1005, '2017-10-25', '1000.87'),
(1006, '2017-10-08', '600.50'),
(1006, '2017-10-18', '200.67'),
(1006, '2017-10-21', '1000.87'),
(1007, '2017-10-23', '700.45'),
(1008, '2017-10-24', '900.78');


#-------------------------------------------------------------------
# data for Department table

SET NAMES utf8;

INSERT INTO Department
(DeptID, DeptName, DeptHeadID, DeptHeadUserID, DeptAA, ParentDeptID)
VALUES
(1, 'CEO', NULL, NULL, NULL, NULL ),
(10, 'Company Officer', 100, 'Officer_mgr', 105, 1 ),
(20, 'HR', 101, 'HR_mgr', 106, 10 ),
(30, 'IT', 102, 'IT_mgr', 107, 10 ),
(40, 'Marketing', 103, 'Marketing_mgr', 108, 10 ),
(50, 'Engineering', 104, 'Eng_mgr', 109, 10 ),
(60, 'Sales', NULL, NULL, NULL, 10 );


#-------------------------------------------------------------------
# data for Employee table

SET NAMES utf8;

INSERT INTO Employee
(EmpID, Name, TaxID, Country, HireDate, BirthDate, Salary, Bonus, DeptID)
VALUES
(100,'Ted Harrison', '123-45-0000','United States', '2016-06-17', '1960-12-03', 500000, 200000, 1 ),
(101,'Jack Hollman', '125-48-0070','United States', '2016-07-17', '1970-10-03', 110000, 10000, 10 ),
(102,'Raghuram Kochhar', '232-45-0023','United States', '2016-09-21', '1965-09-03', 120000, 10000, 10 ),
(103,'Lex De Haan', '456-75-3400','United States', '2016-11-13', '1963-08-20', 170000, 10000, 10 ),
(104,'Alexander Hunold', '799-45-0780','United States', '2016-09-03', '1960-12-03', 130000, 10000, 10 ),
(105,'Nancy Ernst', '189-98-0034','United States', '2016-06-21', '1980-07-03', 65000, 5000, 10 ),

(106,'Diana Lorentz', '987-45-7658','United States', '2017-02-07', '1980-05-03', 65000, 5000, 20 ),
(107,'Ruth Mourgos', '897-25-3546','United States', '2016-11-16', '1981-03-20', 65000, 5000, 30 ),
(108,'Tina Rajs', '785-79-3635','United States', '2016-10-17', '1981-07-20', 65000, 5000, 40 ),
(109,'Kathy Davis', '766-45-6893','United States', '2017-03-16', '1983-03-03', 65000, 5000, 50 ),

(110,'Steven King', '723-75-0007','United States', '2016-08-17', '1960-02-03', 64000, 7000, 20 ),
(111,'Mary Wang', '523-49-0045','United States', '2017-01-17', '1960-12-03', 68000, 7000, 20 ),

(112,'Maya Kochhar', '232-45-0343','United States', '2016-09-21', '1965-09-03', 90000, 5000, 30 ),
(113,'Appleby Haan', '456-75-7400','Canada', '2017-01-13', '1980-12-20', 87000, 5000, 30 ),

(114,'Alice Smith', '709-45-0750','United States', '2017-01-03', '1960-12-03', 90000, 8000, 40 ),
(115,'Bruce Brown', '189-95-0834','Canada', '2016-09-21', '1967-07-03', 90000, 8000, 40 ),

(116,'Diana Loren', '987-45-7008','United States', '2017-02-07', '1980-05-03', 10200, 5000, 50 ),
(117,'Kevin Moreen', '897-45-3546','United States', '2016-11-16', '1978-03-20', 98800, 5000, 50 ),
(118,'Trenna Roger', '785-79-7635','Canada', '2016-10-17', '1981-07-20', 12300, 5000, 50 ),
(119,'Curtis Davis', '776-45-6893','Canada', '2017-03-16', '1976-03-03', 98000, 5000, 50 ),

(120,'Steven Patterson', '723-45-0990','United States', '2016-06-17', '1960-12-03', 190000, 10000, 10 );


#-----------------------------------------------
# Create views for based on DeptID.

Create View Dept10
As Select * from Employee
Where DeptID ='10';


Create View Dept20 As Select * from Employee Where DeptID ='20';

Create View Dept30 As Select * from Employee Where DeptID ='30';

Create View Dept40 As Select * from Employee Where DeptID ='40';

Create View Dept50 As Select * from Employee Where DeptID ='50';

#-----------------------------------------------------
# create DB user account for all 21 employees.
# create DB account for Company Officers

create user Officer_mgr identified by 'Officer_secret1';

create user
	Officer_mgr identified by 'Officer_secret1',
	Officer_staff1 identified by 'Officer_secret1',
	Officer_staff2 identified by 'Officer_secret2',
	HR_mgr identified by 'HR_secret1',
	HR_aa identified by 'HR_secret2',
	HR_staff1 identified by 'HR_secret3',
	HR_admin identified by 'HR_secret4',
	IT_mgr identified by 'IT_secret1',
	IT_aa identified by 'IT_secret2',
	IT_staff1 identified by 'IT_secret3',
	IT_staff2 identified by 'IT_secret4',
	Marketing_mgr identified by 'Marketing_secret1',
	Marketing_aa identified by 'Marketing_secret2',
	Marketing_staff1 identified by 'Marketing_secret3',
	Marketing_staff2 identified by 'Marketing_secret4',
	Eng_mgr identified by 'Eng_secret1',
	Eng_aa identified by 'Eng_secret2',
	Eng_staff1 identified by 'Eng_secret3',
	Eng_staff2 identified by 'Eng_secret4',
	Eng_staff3 identified by 'Eng_secret5',
	Eng_staff4 identified by 'Eng_secret6';


#----------------------------------------------------
# Access Rights
# 14-1: All employees can see place and name information

# Grant select on Place to all 21 employees

Grant Select on Place to 
Officer_mgr,
Officer_staff1,
Officer_staff2,
HR_mgr,
HR_aa,
HR_staff1,
HR_admin,
IT_mgr,
IT_aa,
IT_staff1,
IT_staff2,
Marketing_mgr,
Marketing_aa,
Marketing_staff1,
Marketing_staff2,
Eng_mgr,
Eng_aa,
Eng_staff1,
Eng_staff2,
Eng_staff3,
Eng_staff4;


# Grant select on SuppliedName to all 21 employees

Grant Select on SuppliedName to 
Officer_mgr,
Officer_staff1,
Officer_staff2,
HR_mgr,
HR_aa,
HR_staff1,
HR_admin,
IT_mgr,
IT_aa,
IT_staff1,
IT_staff2,
Marketing_mgr,
Marketing_aa,
Marketing_staff1,
Marketing_staff2,
Eng_mgr,
Eng_aa,
Eng_staff1,
Eng_staff2,
Eng_staff3,
Eng_staff4;


#---------------------------------------------------------
# 14-2: Only HR employee can access all HR info.

Grant Select on Employee to 
HR_mgr,
HR_aa,
HR_staff1,
HR_admin;


Grant Select on Department to 
HR_mgr,
HR_aa,
HR_staff1,
HR_admin;

#-------------------------------------------------------------------
# 14-3: only some HR employees can change the information in the 
# HR portion of the DB


Grant all privileges on Employee to HR_admin;

Grant all privileges on Department to HR_admin;

#----------------------------------------------------------------------
# 14-4: Managers can see their employee information

Grant Select on Dept10 to Officer_mgr;

Grant Select on Dept20 to HR_mgr;

Grant Select on Dept30 to IT_mgr;

Grant Select on Dept40 to Marketing_mgr;

Grant Select on Dept50 to Eng_mgr;

#-----------------------------------------------------------------
# 14-5: Managers can update their employee compensation

Grant Update (Salary, Bonus) on Dept10 to Officer_mgr;

Grant Update (Salary, Bonus) on Dept20 to HR_mgr;

Grant Update (Salary, Bonus) on Dept30 to IT_mgr;

Grant Update (Salary, Bonus) on Dept40 to Marketing_mgr;

Grant Update (Salary, Bonus) on Dept50 to Eng_mgr;


