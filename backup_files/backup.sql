
/* Backup database 
-> this is used for backup to execute the jobname
*/
EXEC msdb.dbo.sp_start_job @job_name = N'DatabaseBackupJob';