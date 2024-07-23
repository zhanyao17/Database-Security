use master
Create Database MedicalInfoSystem;
Go
Use MedicalInfoSystem
Go
Create Table Doctor(
DrID varchar(6) primary key,
DName varchar(100) not null,
DPhone varchar(20)
)
Create Table Patient(
PID varchar(6) primary key,
PName varchar(100) not null,
PPhone varchar(20),
PaymentCardNo varchar(100)
)
Create Table Diagnosis(
DiagID int identity(1,1) primary key,
PatientID varchar(6) references Patient(PID) ,
DoctorID varchar(6) references Doctor(DrID) ,
DiagnosisDate datetime not null,
Diagnosis varchar(max)
)

/* format */
-- format the datatype for encryption
ALTER TABLE [dbo].[Doctor]
DROP COLUMN DPhone;

ALTER TABLE [dbo].[Doctor]
ADD DPhone VARBINARY(MAX);

ALTER TABLE [dbo].[Patient]
DROP COLUMN PaymentCardNo;

ALTER TABLE [dbo].[Patient]
ADD PaymentCardNo VARBINARY(MAX);

-- Adding new columns for achieve soft delete [NOTES: run one by one]
ALTER TABLE Patient
ADD RowStatus INT DEFAULT 1;
GO

UPDATE Patient
SET RowStatus = 1
WHERE RowStatus IS NULL;
GO

ALTER TABLE Doctor
ADD RowStatus INT DEFAULT 1;

UPDATE Doctor
SET RowStatus = 1
WHERE RowStatus IS NULL;

ALTER TABLE Diagnosis
ADD RowStatus INT DEFAULT 1;

UPDATE Diagnosis
SET RowStatus = 1
WHERE RowStatus IS NULL;

