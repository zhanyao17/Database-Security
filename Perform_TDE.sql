
-- Master key passwords: DEMOSU#12345&SAMI#SU
USE master;
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QWEqwe!@#123';
CREATE CERTIFICATE CertForTDE WITH SUBJECT = 'CertForTDE';



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
CREATE ASYMMETRIC KEY AsymKey_paymentCarNo WITH ALGORITHM = RSA_2048 -- asymmetric ke

-- contact column [Symetric key]
USE MedicalInfoSystem;
CREATE certificate CertForCLE with SUBJECT = 'CertForCLE'
CREATE SYMMETRIC KEY SimKey_contact1
WITH ALGORITHM = AES_256 ENCRYPTION BY CERTIFICATE CertForCLE


-- Demo on how to encrypt and decrypt
-- EncryptByAsymKey(AsymKey_ID('AsymKey_paymentCarNo'),'JohnPwd')


-- Draft
select * from Doctor

-- DECLARE @PaymentCardNo varchar(20) = 'alishdf';

-- DECLARE @EncryptedPaymentCardNo VARBINARY(MAX);

-- -- SET @EncryptedPaymentCardNo = EncryptByAsymKey(AsymKey_ID('AsymKey_paymentCarNo'), @PaymentCardNo);
-- SET @EncryptedPaymentCardNo = HASHBYTES('SHA2_256',CONVERT(VARBINARY, @EncryptedPaymentCardNo));

-- SELECT @EncryptedPaymentCardNo AS EncryptedPaymentCardNo;


DECLARE @PaymentCardNo varchar(20) = 'alishdf';
DECLARE @EncryptedPaymentCardNo VARBINARY(MAX);

SET @EncryptedPaymentCardNo = HASHBYTES('SHA2_256', CONVERT(VARBINARY, @PaymentCardNo));
SELECT @EncryptedPaymentCardNo AS EncryptedPaymentCardNo;

SELECT SQL_VARIANT_PROPERTY(PaymentCardNo, 'BaseType') AS DataType
FROM Patient;


-- delete and add new column
ALTER TABLE [dbo].[Doctor]
DROP COLUMN DPhone;

ALTER TABLE [dbo].[Doctor]
ADD DPhone VARBINARY(MAX);

select * from Doctor