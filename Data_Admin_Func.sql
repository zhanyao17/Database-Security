-- Visualize
/*diagnosis, doctor, patient */
-- select * from patient;


/* Add and manage patient records */
CREATE OR ALTER PROCEDURE DA_ManagePatientRecords
@PID VARCHAR(6)=NULL,
@PName VARCHAR(100)=NULL

AS
BEGIN
    DECLARE @PPhone VARCHAR(20)
    Set @PPhone = NULL
    -- Set PII to null
    DECLARE @PaymentCardNo VARCHAR(100)
    SET @PaymentCardNo = NULL
    IF (@PID is NULL) -- IF no id means new records
    BEGIN 
        PRINT 'New Patient Record'
        IF @PName is NULL
        BEGIN 
	        PRINT 'Error Encountered !! Patient name is mandatory field !! '
        END
        ELSE
            PRINT 'Saving Record...'
            DECLARE @latestpid VARCHAR(6), @intId INT
            SELECT TOP 1 @latestpid=PID from Patient ORDER BY PID DESC
            SELECT @intId = Cast(RIGHT(@latestpid, Len(@latestpid)-1) as int)
            SET @PID = 'P'+Cast((@intId+1)as varchar(6))
            PRINT 'New Patient ID: '+@PID

            INSERT INTO [dbo].[Patient] ([PID],[PName],[PPhone],[PaymentCardNo])
            VALUES (@PID,@PName,@PPhone,EncryptByAsymKey(AsymKey_ID('AsymKey_paymentCarNo'),
                    CONVERT(varbinary(MAX),@PaymentCardNo)))
        END
    ELSE
    BEGIN
        -- Esisting records
        PRINT 'Modifying existing customer record..'
        IF @PName IS NOT NULL
            UPDATE [dbo].[Patient]
            SET [PName] = @PName
            WHERE [PID] = @PID
        
        IF @PaymentCardNo IS NOT NULL
            UPDATE [dbo].[Patient]
            SET [PaymentCardNo] = EncryptByAsymKey(AsymKey_ID('AsymKey_paymentCarNo'),
                    CONVERT(varbinary(MAX),@PaymentCardNo))
            WHERE [PID] = @PID
    END
        
END
GO

/* Modify doctor records*/
CREATE OR ALTER PROCEDURE DA_ManageDoctorRecords
@DrID VARCHAR(6) = NULL,
@DName VARCHAR(100) = NULL

AS
BEGIN
    -- Set PII to null
    DECLARE @DPhone VARCHAR(20)
    SET @DPhone = NULL
    
    IF (@DrID IS NULL) -- IF no id means new records
    BEGIN 
        PRINT 'New Doctor Record'
        IF @DName IS NULL
        BEGIN 
            PRINT 'Error Encountered !! Doctor name is a mandatory field !!'
        END
        ELSE
        BEGIN
            PRINT 'Saving Record...'
            DECLARE @latestdid VARCHAR(6), @intId INT
            SELECT TOP 1 @latestdid = DrID FROM Doctor ORDER BY DrID DESC
            SELECT @intId = CAST(RIGHT(@latestdid, LEN(@latestdid) - 1) AS INT)
            SET @DrID = 'D' + CAST((@intId + 1) AS VARCHAR(6)) 
            PRINT 'New Doctor ID: ' + @DrID

            INSERT INTO [dbo].[Doctor] ([DrID], [DName], [DPhone])
            VALUES (@DrID, @DName, EncryptByKey(Key_GUID('SimKey_contact1'),@DPhone))
        END
    END
    ELSE
    BEGIN
        -- Existing records
        PRINT 'Existing Doctor Record'
        IF @DName IS NOT NULL
        BEGIN
            UPDATE [dbo].[Doctor]
            SET [DName] = @DName
            WHERE [DrID] = @DrID
        END
        
        IF @DPhone IS NOT NULL
        BEGIN
            UPDATE [dbo].[Doctor]
            SET [DPhone] = EncryptByKey(Key_GUID('SimKey_contact1'),@DPhone)
            WHERE [DrID] = @DrID
        END
    END
END
GO


/* Delete patient records */
CREATE OR ALTER PROCEDURE DA_DeletePatientRecords
@PID VARCHAR(6)=NULL
AS 
BEGIN
    IF @PID = NULL
    BEGIN 
        PRINT 'Patient ID cannot be null !!'
    END
    ELSE
    BEGIN
        PRINT 'Records will be deleted in a while...'
        DELETE FROM Patient
        WHERE PID = @PID
    END
END
GO

CREATE OR ALTER PROCEDURE DA_DeleteDoctorRecords
@DrID VARCHAR(6)=NULL
AS 
BEGIN
    IF @DrID = NULL
    BEGIN 
        PRINT 'Doctor ID cannot be null !!'
    END
    ELSE
    BEGIN
        PRINT 'Records will be deleted in a while...'
        DELETE FROM Doctor
        WHERE DrID = @DrID
    END
END
GO



/* Example to exec the above procedures */
-- EXEC DA_ManagePatientRecords @PID='P8', @PaymentCardNo = '0000-1111-2222-3333';

-- EXEC DA_ManageDoctorRecords @DrID='D9', @DPhone='810-123-4567';
