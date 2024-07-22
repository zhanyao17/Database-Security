
/* Backup database */
EXEC msdb.dbo.sp_start_job @job_name = N'DatabaseBackupJob';