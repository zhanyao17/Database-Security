
-- /**************** Auditing DDL activities ****************/
-- Prevent drop and create action
create or alter trigger PreventDrop
on DATABASE
for drop_table, alter_table, create_table
AS
declare @cmd varchar(max)
SELECT @CMD = EVENTDATA().value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)')
IF @cmd like '%drop%' or @cmd like '%CREATE TABLE%'
BEGIN
PRINT 'You are not allowed to drop a table or table column';
ROLLBACK;
end
Go

/* Disable or enable */
DISABLE TRIGGER PreventDrop ON DATABASE; GO
ENABLE TRIGGER PreventDrop ON DATABASE; GO

/**************** Auditing DML activities ****************/
-- capture dml action
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


/********************** view config *********************/
SELECT * FROM sys.server_audits;
SELECT * FROM sys.server_audit_specifications;
SELECT * FROM sys.server_audit_specification_details;
