/* 
This files used to create a key for encryption 
will be used in the encrypting patient(paymentcardno) & doctor(contact)
*/
-- Master key passwords: DEMOSU#12345&SAMI#SU
USE master;
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QWEqwe!@#123'; -- master key
CREATE CERTIFICATE CertForTDE WITH SUBJECT = 'CertForTDE'; -- cert



-- DEK (target on the database was used)
USE MedicalInfoSystem;
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE CertForTDE

ALTER DATABASE MedicalInfoSystem SET ENCRYPTION ON


-- Check database was encrypted anot
SELECT db_name(a.database_id) AS DBName , a.encryption_state_desc, a.encryptor_type, b.name as 'DEK Encrypted By'
FROM sys.dm_database_encryption_keys a
INNER JOIN sys.certificates b ON a.encryptor_thumbprint = b.thumbprint


/* Create CLE */
-- payment card no column [Asymetric key]
USE MedicalInfoSystem;
Create master key encryption by password = 'QwErTy12345!@#$%' -- maaster key encryption key (DEK)
CREATE ASYMMETRIC KEY AsymKey_paymentCarNo WITH ALGORITHM = RSA_2048 --NOTE: asymmetric ke

-- contact column [Symetric key]
USE MedicalInfoSystem;
CREATE certificate CertForCLE with SUBJECT = 'CertForCLE'
CREATE SYMMETRIC KEY SimKey_contact1 -- NOTE: Symmetric key for doctor contact no 
WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE CertForCLE


/* Create a DDM on doctor name */ -- NOTE: DDM
ALTER TABLE Doctor
ALTER COLUMN DName ADD MASKED WITH (FUNCTION = 'partial(5," XXX ",2)');


-- view
select name, subject, start_date, expiry_date
from sys.certificates
where name = 'CertForCLE'


-- Draft
drop master key
DROP CERTIFICATE CertForTDE;
DROP DATABASE ENCRYPTION KEY;



