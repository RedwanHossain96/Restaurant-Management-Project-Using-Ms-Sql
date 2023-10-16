Use master
go

DROP Database IF EXISTS Nagar_Gram_RestaurantsDB
go
DECLARE @data_path nvarchar(256);
SET @data_path = (SELECT SUBSTRING(physical_name,1,CHARINDEX(N'master.mdf', LOWER(physical_name))-1)
	FROM master.sys.master_files
	WHERE database_id=1 AND file_id=1
);

EXECUTE ('CREATE DATABASE Nagar_Gram_RestaurantsDB
ON PRIMARY (NAME=Nagar_Gram_RestaurantsDB_data, FILENAME='''+@data_path+'Nagar_Gram_RestaurantsDB_data.mdf'', SIZE=100MB, MAXSIZE=UNLIMITED, FILEGROWTH=5%)
LOG ON (NAME=Nagar_Gram_RestaurantsDB_log, FILENAME='''+@data_path+'Nagar_Gram_RestaurantsDB_log.ldf'', SIZE=50MB, MAXSIZE=200MB, FILEGROWTH=2%)
');
GO

Use Nagar_Gram_RestaurantsDB
GO

Create Schema ngr
GO

--						ngr.Coustomers TABLE_01

DROP TABLE IF EXISTS ngr.Coustomers
Create Table ngr.Coustomers
(
CoustomerID int Primary key identity(1,1),
[Name] varchar(50),
[Address] varchar(100) sparse,
MobileNo nvarchar(25) CHECK ((MobileNo Like '[0][1][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')),
Email varchar(50) CHECK (Email Like '%@%')
);
GO

--						ngr.Table_list TABLE_02

DROP TABLE IF EXISTS ngr.Table_list
Create Table ngr.Table_list
(
TableID int primary key identity(1,1),
TableNo int,
Catagory varchar(50) sparse,
pricePerHour Decimal (8,2)
);
GO

--						ngr.Chefs TABLE_03

DROP TABLE IF EXISTS ngr.Chefs
Create Table ngr.Chefs
(
ChefID int primary key identity(1,1),
ChefName varchar(40) not null,
[Fee Per Dish] money
);
GO

--						ngr.FoodMenu TABLE_04
DROP TABLE IF EXISTS ngr.FoodMenu
Create Table ngr.FoodMenu
(
MenuID int primary key identity(1,1),
MenuType varchar(100) not null,
Decription nvarchar(200) sparse,
Price money,
);
GO

--						ngr.AdditionalFoodMenu TABLE_05

DROP TABLE IF EXISTS ngr.AdditionalFoodMenu
Create Table ngr.AdditionalFoodMenu
(
AdMenuID int primary key identity(1,1),
[Add additional things to menu] nvarchar(100) sparse,
AdFoodPrice money
);
GO

--						ngr.Booking TABLE_06

DROP TABLE IF EXISTS ngr.Booking
Create Table ngr.Booking
(
BookingID int primary key identity(1,1),
CoustomerID int foreign key references ngr.Coustomers(CoustomerID) not null,
BookingDate datetime Not Null CONSTRAINT CN_BookingDate DEFAULT getdate(),
ReservationDate date not null,
ReservationTime time not null,
);
GO

--						ngr.Orders TABLE_07

DROP TABLE IF EXISTS ngr.Orders
Create Table ngr.Orders
(
OrderID int PRIMARY KEY identity(1,1),
BookingID int foreign key references ngr.Booking(BookingID) ON UPDATE CASCADE not null,
TableID int foreign key references ngr.Table_list(TableID) ON UPDATE CASCADE not null,
ChefID int foreign key references ngr.Coustomers(CoustomerID) ON DELETE CASCADE,
MenuID int foreign key references ngr.FoodMenu(MenuID) ON UPDATE CASCADE,
AdMenuID int foreign key references ngr.AdditionalFoodMenu(AdMenuID) ON UPDATE CASCADE
);
GO
--						ngr.Payment TABLE_08

DROP TABLE IF EXISTS ngr.Payment
Create Table ngr.Payment
(
paymentID int identity(1,1),
BookingID int foreign key references ngr.Booking(BookingID) not null,
AdvencePayment money,
Discount Decimal (10,2),
VAT Decimal (10,2),
PaidTime datetime Not Null CONSTRAINT CN_PaidTime DEFAULT getdate()
);
GO

--						ngr.Cancellations TABLE_09

DROP TABLE IF EXISTS ngr.Cancellations
Create Table ngr.Cancellations
(
CancellationID int Identity,
BookingID int Foreign Key References ngr.Booking(BookingID) ON UPDATE CASCADE,
CancellationTime datetime CONSTRAINT CN_CancelDate DEFAULT getdate(),
Reason varchar(25),
CancellationDuration nvarchar(20)
);
Go

--						ngr.Cancellations TABLE_10

DROP TABLE IF EXISTS ngr.Employees
Create Table ngr.Employees
(
EmployeeID int identity(1,1),
EmpName varchar(30) not null,
JoiningDate date,
Designation varchar(30),
[Address] varchar(50) sparse,
MobileNo nvarchar(25) CHECK ((MobileNo Like '[0][1][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')),
Email nvarchar(30)
);
GO

--=================================Alter Table(Add and Drop Column)=============================
Alter Table ngr.Employees
Add NID varchar(20)
Go

Alter Table ngr.Coustomers
Add NID varchar(20)
Go
-----========Drop COLUMN
Alter Table ngr.Coustomers
Drop Column NID
Go

-----========ALTER COLUMN ADD
ALTER table ngr.Coustomers
ADD image nvarchar (35)
GO

-----========ALTER DATA type change
ALTER table ngr.Coustomers
DROP column image 
GO

Select * From ngr.Coustomers
Select * From ngr.Table_list
Select * From ngr.Chefs
Select * From ngr.FoodMenu
Select * From ngr.AdditionalFoodMenu
Select * From ngr.Booking
Select * From ngr.Orders
Select * From ngr.Payment
Select * From ngr.Cancellations
Select * From ngr.Employees
Go

--=================================Create Index=============================

Create Clustered Index CI_CanID on ngr.Cancellations(CancellationID)
Go

Create NonClustered Index NCI_NID on ngr.Employees(EmpName)
Go



--									Create Sequence
--================================================================================================================
Use Nagar_Gram_RestaurantsDB
Create Sequence sq_Sequence
	As Bigint
	Start With 1
	Increment By 1
	Minvalue 1
	Maxvalue 99999
	No Cycle
	Cache 05;
	GO

Select Next value for sq_Sequence
GO

--								 View With Encryption
--================================================================================================================

CREATE View vw_CoustomerInfo
With Encryption
As
Select CoustomerID, MobileNo, [Address], Email
From ngr.Coustomers;
GO

Select * From vw_CoustomerInfo
GO

sp_helptext vw_CoustomerInfo
GO

--									View with Schemabinding
--==============================================================================================================
Create View vw_EmployeesInfo
With Schemabinding
As
Select EmployeeID, EmpName, JoiningDate, Designation, [Address], MobileNo, Email
From ngr.Employees
GO

Select * From vw_EmployeesInfo
GO

---								Procedure Create (Search By Name)
--=================================================================================================================
Create PROC sp_SearchName
@Name nvarchar(20)
AS
Select ChefName, [Fee Per Dish]
From  ngr.Chefs
Where ChefName like @Name +'%' 
GO

EXEC sp_SearchName 'Grant Achatz'

Select * From ngr.Chefs
GO

Drop proc sp_SearchName
GO


--							CrudOperation: Insert Update Delete By Store Procedure
--====================================================================================================================

Create Proc sp_Menus

	@MenuID int,
	@MenuType varchar(100),
	@Decription nvarchar(200),
	@Price money,
	
	@tablename varchar(25),
	@operationname varchar(30)
AS
Begin
	IF @tablename='ngr.FoodMenu' and @operationname='Insert'
		Begin
			Insert ngr.FoodMenu Values(@MenuID,@MenuType,@Decription,@Price)
		End
	IF @tablename='ngr.FoodMenu' and @operationname='Update'
		Begin
			Update ngr.FoodMenu Set MenuType=@MenuType, Decription=@Decription, Price=@Price Where MenuID=@MenuID
		End
	IF @tablename='ngr.FoodMenu' and @operationname='Delete'
		Begin
			Delete From ngr.FoodMenu Where MenuID=@MenuID 
		End
	IF @tablename='ngr.FoodMenu' and @operationname='Select'
		Begin
			Select * From ngr.FoodMenu
		End
End
GO

--											Function Create
--===============================================================================================================
create function ngr.fn_Payment
(
	@AdvencePayment Money,
	@Discount Money,
	@VAT Money,
	@MobileBill Money,
	@travelAllowance Money
	
)
returns money
as
begin
	declare @total money 
	set @total= (@AdvencePayment - @Discount) * @VAT
	return @total
end
GO

--										Create Trigger Table on Coustomers Table
--==============================================================================================================
USE Nagar_Gram_RestaurantsDB
GO
Create Table ngr.Coustomers_Audit
(
CoustomerID int,
[Name] varchar(20),
[Address] varchar(20),
MobileNo nvarchar(25),
Email varchar(50),                                                                     
 
Audit_Action varchar(100),
Audit_Timestamp datetime
);
GO


--										Create Trigger on Coustomers Table (After Insert Tr_1)
--==============================================================================================================
CREATE TRIGGER trg_AfterInsert 
on ngr.Coustomers
For Insert
AS
Declare @CoustomerID int, @Name varchar(20),@Address varchar(20),@MobileNo nvarchar(25),@Email varchar(50),@Audit_Action varchar(100),@Audit_Timestamp datetime
Select @CoustomerID =i.CoustomerID from inserted i;
Select @Name=i.[Name] from inserted i;
Select @Address=i.[Address] from inserted i;
Select @MobileNo=i.MobileNo from inserted i;
Select @Email=i.Email from inserted i;

Set @audit_action='Inserted Record -- After Insert Trigger.';

Insert Into ngr.Coustomers_Audit(CoustomerID,[Name],[Address],MobileNo,Email,Audit_Action,Audit_Timestamp)
Values(@CoustomerID,@Name,@Address,@MobileNo,@Email,@audit_action,GETDATE());

PRINT 'After Insert Trigger Fired.'
GO

Select * From ngr.Coustomers
Select * From ngr.Coustomers_Audit
GO


--										Create Trigger on Employee Table (After UPDATE Tr_1)
--==============================================================================================================
CREATE TRIGGER trg_AfterUpdate 
on ngr.Coustomers
For UPDATE
AS
	Declare @CoustomerID int, @Name varchar(20),@Address varchar(20),@MobileNo nvarchar(25),@Email varchar(50),@Audit_Action varchar(100),@Audit_Timestamp datetime
Select @CoustomerID =i.CoustomerID from inserted i;
Select @Name=i.[Name] from inserted i;
Select @Address=i.[Address] from inserted i;
Select @MobileNo=i.MobileNo from inserted i;
Select @Email=i.Email from inserted i;

Set @audit_action='Update Record -- After Update Trigger.';

	IF Update(Name)
		set @audit_action='Updated Record -- After Update Trigger.';
	IF Update(Address)
		set @audit_action='Updated Record -- After Update Trigger.';
	IF Update(MobileNo)
		set @audit_action='Updated Record -- After Update Trigger.';
	IF Update(Email)
		set @audit_action='Updated Record -- After Update Trigger.';
	
	Insert Into ngr.Coustomers_Audit(CoustomerID,[Name],[Address],MobileNo,Email,Audit_Action,Audit_Timestamp)
Values(@CoustomerID,@Name,@Address,@MobileNo,@Email,@audit_action,GETDATE());
	PRINT 'After Update Trigger Fired.'
GO


--										Create Trigger on Employee Table (After Delete Tr_1)
--==============================================================================================================
CREATE TRIGGER trg_AfterDelete 
on ngr.Coustomers
For Delete
AS
	Declare @CoustomerID int, @Name varchar(20),@Address varchar(20),@MobileNo nvarchar(25),@Email varchar(50),@Audit_Action varchar(100),@Audit_Timestamp datetime
Select @CoustomerID =i.CoustomerID from inserted i;
Select @Name=i.[Name] from inserted i;
Select @Address=i.[Address] from inserted i;
Select @MobileNo=i.MobileNo from inserted i;
Select @Email=i.Email from inserted i;

Set @audit_action='Inserted Record -- After Insert Trigger.';

Insert Into ngr.Coustomers_Audit(CoustomerID,[Name],[Address],MobileNo,Email,Audit_Action,Audit_Timestamp)
Values(@CoustomerID,@Name,@Address,@MobileNo,@Email,@audit_action,GETDATE());

PRINT 'After Delete Trigger Fired.'
Go

Drop Trigger trg_AfterInsert
Drop Trigger trg_AfterDelete
Drop Trigger trg_AfterUpdate


--							Instead of Trigger on Employee Table (insert, Update, Delete Tr_1)
--=================================================================================================================
USE Nagar_Gram_RestaurantsDB
GO

Create Trigger trg_InsertUpdateDelete on ngr.Coustomers
Instead of insert, Update, Delete
AS
Declare @rowcount int
Set @rowcount=@@ROWCOUNT
IF(@rowcount>1)
				BEGIN
				Raiserror('You cannot Update or Delete more than 1 Record',16,1)	
				END
Else 
	Print 'Insert, Update or Delete Successful'
GO

Insert into ngr.Coustomers([Address]) Values ('Ctg');

Delete From ngr.Coustomers Where CoustomerID=9;
GO
Select * From ngr.Coustomers
GO


--								Temporary Table(Local and Global)
--==================================================================================
CREATE TABLE #Tmp_NGR
(
ID int identity,
Address Varchar(30) CONSTRAINT CN_Defaultaddress DEFAULT ('UNKNOWN'),
Phone Char(15) Not Null  CHECK ((Phone Like '[0][1][1-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9]' )),
DateInSystem DATE Not Null CONSTRAINT CN_dateinsystem DEFAULT (GETDATE())
);
GO

CREATE TABLE ##Tmp_Resource
(
ID int identity ,
Address Varchar(30) CONSTRAINT CN_Dfltaddress DEFAULT ('UNKNOWN'),
Phone Char(15) Not Null  CHECK ((Phone Like '[0][1][1-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9]' )),
DateInSystem DATE Not Null CONSTRAINT CN_dateinmethod DEFAULT (GETDATE())
);
GO

Drop Table #Tmp_NGR
GO
Drop Table ##tmp_Resource
GO


--									Scalar Function to Get Total Recruitment 
--==================================================================================
Create Function ngr.fn_AdvencePayment()
Returns int 
AS
Begin
	Return(Select SUM(AdvencePayment) From ngr.Payment) 
End
GO

print ngr.fn_rec()
Go


--						                Tabular Function
--==================================================================================
Create Function ngr.fn_CancellationsHistory()
Returns table
As
Return
(
Select *
From ngr.Cancellations where CancellationID=1
)
GO

Select * From ngr.fn_CancellationsHistory()
GO

--=================================================================================================
--=================================================================================================
--=====================================DML PART====================================================
TRUNCATE TABLE ngr.Coustomers
TRUNCATE TABLE ngr.Table_list
TRUNCATE TABLE ngr.Chefs
TRUNCATE TABLE ngr.FoodMenu
TRUNCATE TABLE ngr.AdditionalFoodMenu
TRUNCATE TABLE ngr.Booking
TRUNCATE TABLE ngr.Orders
TRUNCATE TABLE ngr.Payment
TRUNCATE TABLE ngr.Cancellations
TRUNCATE TABLE ngr.Employees
Go

Select * From ngr.Coustomers
Select * From ngr.Table_list
Select * From ngr.Chefs
Select * From ngr.FoodMenu
Select * From ngr.AdditionalFoodMenu
Select * From ngr.Booking
Select * From ngr.Orders
Select * From ngr.Payment
Select * From ngr.Cancellations
Select * From ngr.Employees
Go


--				CROUD OPERATION IN ngr.Coustomers TABLE_01

Insert into ngr.Coustomers ([Name], [Address], MobileNo, Email) 
						Values ('Ms. Raihan', 'Madar Bari', '01658920541', 'ms.raihan@gmail.com'),
								('Ms. Giyas', 'Lohagora', '01658650541', 'ms.Gias@gmail.com'),
								('Sahajan', 'Feni', '01658920241', 'sahajan@gmail.com'),
								('Hasan', 'Comilla', '01588920541', 'hasan@gmail.com'),
								('Sifat', 'Noakhali', '01968920541', 'abc@gmail.com'),
								('Hossain', 'ctg', '01867920541', 'des@gmail.com'),
								('Alauddin', 'Ctg', '01935874541', 'fdr@gmail.com');
GO

---======UPDATE
UPDATE ngr.Coustomers
set [Name] = 'hafez'
WHERE CoustomerID = 2
GO

---======DELETE
DELETE FROM ngr.Coustomers
WHERE CoustomerID = 2
GO


--											INSERT INTO ngr.Table_list TABLE_02

Insert into ngr.Table_list Values (01, 'AC Singal Table', 200),
								  (02, 'AC Double Table', 400),
								  (03, 'NonAC Singal Table', 100),
								  (04, 'NonAC Double Table', 200),
								  (05, 'AC Singal Table', 200),
								  (06, 'AC Double Table', 400),
								  (07, 'NonAC Singal Table', 100),
								  (08, 'NonAC Double Table', 200);
GO

--									INSERT INTO ngr.Chefs TABLE_03

Insert into ngr.Chefs (ChefName, [Fee Per Dish]) Values ('Grant Achatz', 1000), 
												 ('Nicolas Appert', 2000),
												 ('Mario Batali', 2000),
												 ('James Beard', 4000),
												 ('Paul Bocuse', 5000),
												 ('Anthony Bourdain', 5000),
												 ('Robert Carrier', 3000),
												 ('Julia Child', 2500);
GO

--									INSERT INTO ngr.FoodMenu TABLE_04

Insert into ngr.FoodMenu (MenuType, Decription, Price) 
				Values ('Chicken pot pie', 'abc', 1000),
						('Mashed potatoes', 'abc', 500),
						('Fried chicken', 'abc', 800),
						('Chicken soup.', 'abc', 1000),
						('Meatloaf', 'abc', 500),
						('Lasagna', 'abc', 500);
GO

--									INSERT INTO ngr.AdditionalFoodMenu TABLE_05
Insert into ngr.AdditionalFoodMenu ([Add additional things to menu], AdFoodPrice)  
				Values ('things1', 50), ('things2', 30), ('thing3', 40);
GO

--									INSERT INTO ngr.Booking TABLE_06

Insert into ngr.Booking (CoustomerID, BookingDate, ReservationDate, ReservationTime) 
				Values (1,'', '10/12/2022', '12:00 am' ),
						(2,'', '12/12/2022', '08:00 am'),
						(3,'', '05/12/2022', '07:00 pm'),
						(4,'', '07/12/2022', '03:00 pm'),
						(5,'', '04/12/2022', '05:00 am');
GO

--									INSERT INTO ngr.Orders TABLE_07
Insert into ngr.Orders (BookingID, TableID, ChefID, MenuID, AdMenuID) 
				Values  (1, 1, 5, 3, 3),
						(2, 2, 1, 1, 2),
						(3, 4, 4, 4, 1),
						(4, 3, 2, 2, 2),
						(5, 1, 2, 3, 1);
GO

--									INSERT INTO ngr.Payment TABLE_08

Insert into ngr.Payment (BookingID, AdvencePayment, Discount, VAT, PaidTime) 
				Values (1, 1000, .02, .15, ''), (2, 2000, .3 , .15, ''),
						(3, 1000, .3 , .15, ''), (4, 1500, .2 , .15, ''),
						(5, 1000, .25 , .15, ''), (6, 1000, .15 , .15, '');
GO

--									INSERT INTO ngr.Cancellations TABLE_09

Insert into ngr.Cancellations (BookingID, CancellationTime, Reason, CancellationDuration) 
						Values (5,'','abc adb.........','Permanent');
GO

Select * From ngr.Coustomers
Select * From ngr.Table_list
Select * From ngr.Chefs
Select * From ngr.FoodMenu
Select * From ngr.AdditionalFoodMenu
Select * From ngr.Booking
Select * From ngr.Orders
Select * From ngr.Payment
Select * From ngr.Cancellations
Select * From ngr.Employees
Go

--=============================INNER JOIN

SELECT C.CoustomerID,[Name],[Address],MobileNo,Discount,AdvencePayment
FROM ngr.Coustomers C
JOIN ngr.Booking B ON C.CoustomerID = B.CoustomerID
JOIN ngr.Payment P ON P.paymentID = B.BookingID
GO

--============================= LEFT JOIN

SELECT C.CoustomerID,[Name],[Address],MobileNo,ReservationDate
FROM  ngr.Coustomers C
LEFT JOIN ngr.Booking B
ON C.CoustomerID=B.CoustomerID
GO

--Right Outer Join
SELECT C.CoustomerID,[Name],[Address],MobileNo,ReservationDate
FROM  ngr.Coustomers C
RIGHT JOIN ngr.Booking B
ON C.CoustomerID=B.CoustomerID
GO

--Full Outer Join
SELECT *
FROM ngr.Coustomers c
FULL JOIN ngr.Booking b ON c.CoustomerID = b.BookingID
FULL JOIN ngr.Orders o ON b.BookingID = o.BookingID
FULL JOIN ngr.Table_list t ON t.TableID = o.BookingID
FULL JOIN ngr.FoodMenu f ON f.MenuID = o.MenuID
FULL JOIN ngr.AdditionalFoodMenu af ON af.AdMenuID = o.AdMenuID
FULL JOIN ngr.Chefs ch ON ch.ChefID = o.ChefID
FULL JOIN ngr.Payment pay ON pay.BookingID = b.BookingID
GO

--Cross Join
SELECT *
FROM ngr.FoodMenu 
CROSS JOIN ngr.AdditionalFoodMenu

--Self join
SELECT *
FROM ngr.Cancellations c, ngr.Cancellations can
WHERE c.CancellationID<>can.CancellationID
GO

--Six Clauses
SELECT BookingID, count(OrderID)
FROM ngr.Orders
WHERE TableID>0 
GROUP BY BookingID
HAVING count(OrderID)>0

--Union 
SELECT paymentID 
FROM ngr.Payment
WHERE AdvencePayment>500
UNION
SELECT OrderID
FROM ngr.Orders


--Sub Query
SELECT paymentID 
FROM ngr.Payment
WHERE AdvencePayment>(SELECT AdvencePayment FROM ngr.Payment WHERE AdvencePayment>0)
GO

--CTE
WITH cte_Ade
AS
(SELECT AdvencePayment FROM ngr.Payment WHERE AdvencePayment>0)

SELECT paymentID FROM ngr.Payment
FULL JOIN cte_Ade ON ngr.Payment.paymentID = cte_Ade.AdvencePayment
GO

--Cube
SELECT BookingID, count(OrderID)
FROM ngr.Orders
WHERE TableID>0 
GROUP BY BookingID WITH CUBE
GO

--Rollup
SELECT BookingID, count(OrderID)
FROM ngr.Orders
GROUP BY BookingID WITH ROLLUP
GO

--Grouping sets
SELECT OrderID, BookingID, count(OrderID)
FROM ngr.Orders
GROUP BY GROUPING SETS (OrderID, BookingID)
GO

