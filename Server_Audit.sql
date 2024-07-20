
/**************** Auditing DDL activities ****************/
-- Create new server audti with specific file path
CREATE SERVER AUDIT DDLActivities_Audit TO FILE ( FILEPATH ='/opt/mssql/audit' );
-- Enable the server audit.
ALTER SERVER AUDIT DDLActivities_Audit WITH (STATE = ON)


CREATE SERVER AUDIT SPECIFICATION [DDLActivities_Audit_Specification ]
FOR SERVER AUDIT [DDLActivities_Audit]
ADD (DATABASE_OBJECT_CHANGE_GROUP),
ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP) WITH (STATE=ON)
Go

/* Reading audit files */
DECLARE @AuditFilePath VARCHAR(8000);
Select @AuditFilePath = audit_file_path From sys.dm_server_audit_status
where name = 'DDLActivities_Audit'
select event_time as UTC_TimeZone, 
     DATEADD(HOUR, 8, event_time) AS MalaysiaTime,
    database_name, database_principal_name, object_name, statement
From sys.fn_get_audit_file(@AuditFilePath,default,default)
WHERE database_name = 'MedicalInfoSystem'
order by event_time DESC

/**************** Auditing DML activities ****************/
USE master
CREATE SERVER AUDIT DMLAudit TO FILE ( FILEPATH = '/opt/mssql/audit' ); 
-- Enable the server audit.
ALTER SERVER AUDIT DMLAudit WITH (STATE = ON) ;

USE MedicalInfoSystem;
CREATE DATABASE AUDIT SPECIFICATION DMLAudit_Spec
FOR SERVER AUDIT DMLAudit
ADD ( INSERT , UPDATE, DELETE, SELECT
ON DATABASE::MedicalInfoSystem BY public)
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
/* DCL query auditing*/
-- Create a server audit
USE master
CREATE SERVER AUDIT DCLAudit
TO FILE (FILEPATH = '/opt/mssql/audit')
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE);
GO

-- Enable the server audit
ALTER SERVER AUDIT DCLAudit
WITH (STATE = ON);
GO



/********************** User logon *********************/
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
ADD (LOGIN_CHANGE_PASSWORD_GROUP), ADD(LOGOUT_GROUP) WITH (STATE = ON);
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
