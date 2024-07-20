/* Create table store audit detaisl */
CREATE TABLE.[AuditLog_Doctor](
    [Log ID] [int] IDENTITY(1,1) NOT NULL primary key,
    [Log DateTime] [datetime] Default GETDATE(), 
    [User Name] [sysname] Default USER_NAME(), 
    UserAction varchar(20),
    DrID VARCHAR (6),
    DName VARCHAR (100) NOT NULL,
    DPhone VARBINARY(MAX),
    RowStatus INT
) ;
GO


/* Create DML after trigger */
CREATE OR ALTER TRIGGER [DoctorDataChanges]
ON [Doctor]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Insert records from the inserted pseudo-table
    INSERT INTO [AuditLog_Doctor] (UserAction, DrID, DName, DPhone,RowStatus)
    SELECT 'INSERT', DrID, DName, DPhone, RowStatus
    FROM inserted;

    -- Insert records from the deleted pseudo-table
    INSERT INTO [AuditLog_Doctor] (UserAction, DrID, DName, DPhone,RowStatus)
    SELECT 'DELETE', DrID, DName, DPhone,RowStatus
    FROM deleted;
END;
GO

/* Create DML instead trigger */
CREATE OR ALTER TRIGGER [DoctorPatientTable]
ON Doctor
INSTEAD OF DELETE
AS
BEGIN
    -- Update the RowStatus to 0 (indicating soft delete) for the deleted records
    UPDATE Doctor
    SET RowStatus = 0
    WHERE DrID IN (SELECT DrID FROM deleted);
END;
GO

/* Drop table */
-- drop TRIGGER [DoctorDataChanges]
-- drop TABLE.[AuditLog_Doctor]
-- drop TRIGGER [DoctorPatientTable]


-- from sources (https://www.scholarhat.com/tutorial/sqlserver/after-trigger-instead-of-trigger-example)
-- CREATE OR ALTER TRIGGER[PatientDataChanges] ON [Patient]
-- FOR INSERT
-- AS DECLARE
-- GO

-- CREATE or ALTER TRIGGER [CustomerDataChanges] ON [Customer]
-- AFTER INSERT, UPDATE, DELETE
-- AS
-- BEGIN
-- INSERT INTO [AuditLog_Customer] ('INSERT',ID, [Name], Phone, Email, Country, Qualification, Gender, Passport) FROM inserted
-- INSERT INTO [AuditLog_Customer]
-- ('INSERT',ID, [Name], Phone, Email, Country, Qualification, Gender, Passport)
-- FROM deleted END;



-- select * from AuditLog_Patient 
-- order by 'Log DateTime' DESC