-- /*
-- Take notes:
-- Since we are using docker env hence the cert will be copy to the local machine then only 
-- reupload back to another new sql instances (docker env)
-- FYI: backup files included all the backup files (.bak, .cert, .key)
-- */

-- USE master

/* Backup cert */
-- BACKUP CERTIFICATE CertForTDE 
-- TO FILE = N'/opt/mssql/backup/Cert_BackupSMS.cert'
-- WITH PRIVATE KEY (
--     FILE = N'/opt/mssql/backup/Cert_BackupSMS.key', 
-- ENCRYPTION BY PASSWORD = 'QWEqwe!@#123'
-- );
-- Go

-- /* Backup database */
-- BACKUP DATABASE MedicalInfoSystem
-- TO DISK = N'/opt/mssql/backup/MedicalInfoSystem.bak'  
-- WITH  
--   ENCRYPTION   
--    (  
--    ALGORITHM = AES_256,  
--    SERVER CERTIFICATE = CertForTDE  
--    )
-- GO


/* Backup certificate */
BACKUP CERTIFICATE CertForTDE 
TO FILE = N'/opt/mssql/backup/Cert_BackupSMS.cert'
WITH PRIVATE KEY (
    FILE = N'/opt/mssql/backup/Cert_BackupSMS.key', 
    ENCRYPTION BY PASSWORD = 'QWEqwe!@#123'
);
GO

/* Backup database with INIT option to overwrite the existing file */
BACKUP DATABASE MedicalInfoSystem
TO DISK = N'/opt/mssql/backup/MedicalInfoSystem.bak'
WITH  
  FORMAT,  -- This option will overwrite the existing backup file
  ENCRYPTION   
  (  
    ALGORITHM = AES_256,  
    SERVER CERTIFICATE = CertForTDE  
  );
GO
