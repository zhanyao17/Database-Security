USE msdb;
GO

/* Create new jobs */
-- Create a new job
EXEC sp_add_job
    @job_name = N'DatabaseBackupJob',
    @enabled = 1,
    @description = N'Job to backup database every 6 hours',
    @start_step_id = 1,
    @owner_login_name = N'sa';
GO

EXEC sp_add_jobstep
    @job_name = N'DatabaseBackupJob',
    @step_name = N'BackupDatabaseStep',
    @subsystem = N'TSQL',
    @command = N'
        BACKUP DATABASE MedicalInfoSystem
        TO DISK = N''/opt/mssql/backup/MedicalInfoSystem.bak''
        WITH  
          FORMAT,  -- This option will overwrite the existing backup file
          ENCRYPTION   
          (  
            ALGORITHM = AES_256,  
            SERVER CERTIFICATE = CertForTDE  
          );
    ',
    @retry_attempts = 0,
    @retry_interval = 0;
GO

EXEC sp_add_jobserver
    @job_name = N'DatabaseBackupJob';
GO

/* Drop */
-- EXEC sp_delete_job @job_name = N'DatabaseBackupJob';

/* Manual start job */
EXEC msdb.dbo.sp_start_job @job_name = N'DatabaseBackupJob';


/* View backup history */
SELECT instance_id, job_id, step_name, message,
    CONVERT(VARCHAR, 
        LEFT(CAST(run_date AS VARCHAR(8)), 4) + '-' +              
        SUBSTRING(CAST(run_date AS VARCHAR(8)), 5, 2) + '-' +      
        RIGHT(CAST(run_date AS VARCHAR(8)), 2)                     
    ) AS FormattedDate,
    RIGHT('0' + CAST(FLOOR(run_time / 10000) AS VARCHAR(2)), 2) + ':' +
    RIGHT('0' + CAST(FLOOR((run_time % 10000) / 100) AS VARCHAR(2)), 2) + ':' +
    RIGHT('0' + CAST(run_time % 100 AS VARCHAR(2)), 2) AS FormattedTime
FROM msdb.dbo.sysjobhistory 
WHERE job_id = (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'DatabaseBackupJob' and step_name = N'BackupDatabaseStep')
ORDER by instance_id DESC