USE msdb;
GO

-- -- Drop existing job if it exists
-- IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'DatabaseBackupJob')
-- BEGIN
--     EXEC sp_delete_job @job_name = N'DatabaseBackupJob';
-- END

/* Create job */
-- Create a new job
EXEC sp_add_job
    @job_name = N'DatabaseBackupJob',
    @enabled = 1,
    @description = N'Job to backup database every 6 hours',
    @start_step_id = 1,
    @owner_login_name = N'sa';
GO

-- Create a new job step to execute the backup script

EXEC sp_add_jobstep
    @job_name = N'DatabaseBackupJob',
    @step_name = N'BackupDatabaseStep',
    @subsystem = N'TSQL',
    -- @command = N'EXEC sp_executesql N'':r /opt/mssql/backup/test_backup.sql'';',
    -- @command = N'sqlcmd -S 127.0.0.1,1434 -U SA -P "zhanyao88" -i /opt/mssql/backup/test_backup.sql',
    @command = N'BACKUP DATABASE MedicalInfoSystem TO DISK = N''/opt/mssql/backup/MedicalInfoSystem.bak'' WITH NOFORMAT, NOINIT, NAME = N''MedicalInfoSystem-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD, STATS = 10;',
    @retry_attempts = 0,
    @retry_interval = 0;
GO

/* Create scheduler */
-- Create a new job schedule
-- Create a new job schedule to run every 6 hours
-- EXEC sp_add_schedule
--     @schedule_name = N'Every6HoursSchedule',
--     @freq_type = 8,  -- Frequency type is "hourly"
--     @freq_interval = 6,  -- Every 6 hours
--     @freq_recurrence_factor = 1,
--     @active_start_time = 000000;  -- Start at midnight
-- GO

EXEC sp_add_schedule
    @schedule_name = N'Every5MinutesSchedule',
    @freq_type = 1,  -- Frequency type is "daily"
    @freq_interval = 1,  -- Every day
    @freq_subday_type = 4,  -- Frequency type is "minutes"
    @freq_subday_interval = 5,  -- Every 5 minutes
    @active_start_time = 000000;  -- Start at midnight
GO

-- Attach the schedule to the job
EXEC sp_attach_schedule
    @job_name = N'DatabaseBackupJob',
    @schedule_name = N'Every5MinutesSchedule';
GO

-- Add the job to the SQL Server Agent
EXEC sp_add_jobserver
    @job_name = N'DatabaseBackupJob';
GO

