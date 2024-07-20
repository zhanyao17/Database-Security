/* Create table store audit detaisl */
CREATE TABLE.[AuditLog_Patient](
    [Log ID] [int] IDENTITY(1,1) NOT NULL primary key,
    [Log DateTime] [datetime] Default GETDATE(), 
    [User Name] [sysname] Default USER_NAME(), 
    UserAction varchar(20),
    PID VARCHAR (6),
    PName VARCHAR (100) NOT NULL,
    PPhone VARCHAR(20),
    PaymentCardNo VARBINARY(MAX),
    RowStatus INT
) ;
GO


/* Create DML after trigger */
CREATE OR ALTER TRIGGER [PatientDataChanges]
ON [Patient]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Insert records from the inserted pseudo-table
    INSERT INTO [AuditLog_Patient] (UserAction, PID, PName, PPhone, PaymentCardNo,RowStatus)
    SELECT 'INSERT', PID, PName, PPhone, PaymentCardNo,RowStatus
    FROM inserted;

    -- Insert records from the deleted pseudo-table
    INSERT INTO [AuditLog_Patient] (UserAction, PID, PName, PPhone, PaymentCardNo,RowStatus)
    SELECT 'DELETE', PID, PName, PPhone, PaymentCardNo,RowStatus
    FROM deleted;
END;
GO

/* Create DML instead trigger */
CREATE OR ALTER TRIGGER [ProtectPatientTable]
ON Patient
INSTEAD OF DELETE
AS
BEGIN
    -- Update the RowStatus to 0 (indicating soft delete) for the deleted records
    UPDATE Patient
    SET RowStatus = 0
    WHERE PID IN (SELECT PID FROM deleted);
END;
GO

/* Drop table */
-- drop TRIGGER [PatientDataChanges]
-- drop TABLE.[AuditLog_Patient]
-- drop TRIGGER [ProtectPatientTable]


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