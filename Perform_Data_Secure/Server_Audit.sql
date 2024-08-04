
-- /**************** Auditing DDL activities ****************/
-- Create a logging table for DDL activities
CREATE TABLE DDLLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EventDate DATETIME DEFAULT GETDATE(),
    UserName NVARCHAR(128),
    Command NVARCHAR(MAX),
    EventType NVARCHAR(50)
);
GO

-- Prevent drop and create action
CREATE OR ALTER TRIGGER PreventDrop
ON DATABASE
FOR DROP_TABLE, ALTER_TABLE, CREATE_TABLE
AS
DECLARE @cmd NVARCHAR(MAX);
DECLARE @eventType NVARCHAR(50);
DECLARE @userName NVARCHAR(128);

SELECT @cmd = EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)');
SELECT @eventType = EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(max)');
SELECT @userName = ORIGINAL_LOGIN();

IF @cmd LIKE '%DROP%' OR @cmd LIKE '%CREATE TABLE%'
BEGIN
    ROLLBACK
    PRINT 'You are not allowed to drop a table or create a tables';
    INSERT INTO DDLLog (UserName, Command, EventType) --NOTE: insert the log after the rollback
    VALUES (@userName, @cmd, @eventType);
END
GO

/* View logs of the DDL action */
select * from DDLLog; 
go

/* Disable or enable */
DISABLE TRIGGER PreventDrop ON DATABASE; 
GO
ENABLE TRIGGER PreventDrop ON DATABASE;
GO 




/**************** Auditing DML activities ****************/
-- capture DML action
USE master
CREATE SERVER AUDIT DMLAudit TO FILE ( FILEPATH = '/opt/mssql/audit' ); 
-- Enable the server audit.
ALTER SERVER AUDIT DMLAudit WITH (STATE = ON) ;

USE MedicalInfoSystem;
CREATE DATABASE AUDIT SPECIFICATION DMLAudit_Spec
FOR SERVER AUDIT DMLAudit
ADD ( INSERT , UPDATE, DELETE, SELECT
ON DATABASE::MedicalInfoSystem BY public) --NOTE: CHOIOCE
WITH (STATE = ON) ;
GO

-- Reading the audit file
DECLARE @AuditFilePath VARCHAR(8000);
Select @AuditFilePath = audit_file_path From sys.dm_server_audit_status
where name = 'DMLAudit'
select event_time as UTC_TimeZone, 
     DATEADD(HOUR, 8, event_time) AS MalaysiaTime,
    database_name, database_principal_name, object_name, statement
From sys.fn_get_audit_file(@AuditFilePath,default,default)
order by event_time DESC

/**************** Auditing DCL activities ****************/
-- capture dcl action for eg permission changes (grant, revoke, deny)
-- Create a server audit
USE master
CREATE SERVER AUDIT DCLAudit
TO FILE (FILEPATH = '/opt/mssql/audit')
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE);
GO

-- Enable the server audit
ALTER SERVER AUDIT DCLAudit WITH (STATE = on);
GO

-- Create a server audit specification for DCL commands
CREATE SERVER AUDIT SPECIFICATION DCLAuditSpec
FOR SERVER AUDIT DCLAudit
ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP); --NOTE: CHOIOCE

-- Enable the server audit specification
ALTER SERVER AUDIT SPECIFICATION DCLAuditSpec WITH (STATE = on);
GO

-- Reading the audit file
DECLARE @AuditFilePath VARCHAR(8000);
Select @AuditFilePath = audit_file_path From sys.dm_server_audit_status
where name = 'DCLAudit'
select event_time as UTC_TimeZone, 
     DATEADD(HOUR, 8, event_time) AS MalaysiaTime,
    database_name, database_principal_name, object_name, statement
From sys.fn_get_audit_file(@AuditFilePath,default,default)
order by event_time DESC


/********************** User logon *********************/
-- Capture all the logon logs on all the users

-- Create the server audit
USE master;
GO
CREATE SERVER AUDIT LogonAudit TO FILE (FILEPATH = '/opt/mssql/audit');
GO

-- Enable the server audit
ALTER SERVER AUDIT LogonAudit WITH (STATE = ON);
GO

-- Create the server audit specification
CREATE SERVER AUDIT SPECIFICATION LogonAuditSpecs
FOR SERVER AUDIT LogonAudit
ADD (SUCCESSFUL_LOGIN_GROUP), ADD (FAILED_LOGIN_GROUP) ,
ADD (LOGIN_CHANGE_PASSWORD_GROUP), ADD(LOGOUT_GROUP) WITH (STATE = ON); --NOTE: CHOIOCE
GO

-- View logon result
DECLARE @AuditFilePath VARCHAR(8000);
Select @AuditFilePath = audit_file_path From sys.dm_server_audit_status
where name = 'LogonAudit'
select event_time as UTC_TimeZone, 
     DATEADD(HOUR, 8, event_time) AS MalaysiaTime,
     server_principal_name,
     CASE 
        WHEN action_id = 'AUSC' THEN 'AUDIT SUCCESS' 
        WHEN action_id = 'LGO' THEN 'LOGIN OUT' 
        WHEN action_id = 'LGIS' THEN 'LOGIN SUCCESS'
        WHEN action_id = 'LGIF' THEN 'LOGIN FAILED'
    END AS Action_Status,statement
From sys.fn_get_audit_file(@AuditFilePath,default,default)
order by event_time DESC;
GO


-- DEMO
/*  
Login failed and successful on workbench
    mssql -u P1 -p zhanyao88
    mssql -u P1 -p P_1@1234
*/

-- DDL -> dropping tables
CREATE TABLE test_table (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EventDate DATETIME DEFAULT GETDATE(),
    UserName NVARCHAR(128),
    Command NVARCHAR(MAX),
    EventType NVARCHAR(50)
);

-- select * from test_table; GO
DROP table test_table;
go


/********************** view config *********************/
SELECT * FROM sys.server_audits;
SELECT * FROM sys.server_audit_specifications;
SELECT * FROM sys.server_audit_specification_details;

SELECT name FROM sys.triggers WHERE parent_class_desc = 'DATABASE' AND name = 'PreventDrop'; -- view triger