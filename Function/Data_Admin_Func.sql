-- Visualize
/*diagnosis, doctor, patient */
-- select * from patient;

/* ------------------------- Exec ---------------------------- */

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
        BEGIN
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
    END
    ELSE
    BEGIN
        -- Check whether the user was active anot
        DECLARE @RowStatus INT, @Count INT
        select @RowStatus = RowStatus from Patient WHERE @PID = PID
        SELECT @Count = COUNT(*) FROM Patient WHERE PID = @PID
        IF @Count = 0 or @RowStatus = 0
        BEGIN 
            PRINT 'There is not any record for this ID or In-active patient cannot be modify !!'
        END
        ELSE
        BEGIN
            -- Esisting records
            PRINT 'Modifying existing customer record..'
            IF @PName IS NOT NULL
            BEGIN
                UPDATE [dbo].[Patient]
                SET [PName] = @PName
                WHERE [PID] = @PID
            END
            IF @PaymentCardNo IS NOT NULL
            BEGIN
                UPDATE [dbo].[Patient]
                SET [PaymentCardNo] = EncryptByAsymKey(AsymKey_ID('AsymKey_paymentCarNo'),
                        CONVERT(varbinary(MAX),@PaymentCardNo))
                WHERE [PID] = @PID
            END
        END
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
        DECLARE @RowStatus INT,  @Count INT
        select @RowStatus = RowStatus from Doctor WHERE DrID = @DrID
        select @Count =  COUNT(*) from Doctor WHERE DrID = @DrID
        IF @Count = 0 or @RowStatus = 0
        BEGIN 
            PRINT 'There is not any record for this ID or In-active doctor cannot be modify !!'
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
END
GO

/* Delete patient records */
CREATE OR ALTER PROCEDURE DA_DeletePatientRecords
@PID VARCHAR(6)=NULL
AS 
BEGIN
    -- Check whether the user was active anot
    DECLARE @RowStatus INT, @Count INT
    select @RowStatus = RowStatus from Patient WHERE @PID = PID
    SELECT @Count = COUNT(*) FROM Patient WHERE PID = @PID;

    IF @PID = NULL
    BEGIN 
        PRINT 'Patient ID cannot be null !!'
    END
    ELSE IF @Count = 0 or @RowStatus = 0
    BEGIN 
        PRINT 'There is not any record for this ID or In-active patient cannot be deleted again !!'
    END
    ELSE
    BEGIN
        PRINT 'Records will be deleted in a while...'
        DELETE FROM Patient
        WHERE PID = @PID
    END
END
GO

/* Delete doctor records */
CREATE OR ALTER PROCEDURE DA_DeleteDoctorRecords
@DrID VARCHAR(6)=NULL
AS 
BEGIN
    -- Check whether the user was active anot
    DECLARE @RowStatus INT,  @Count INT
    select @RowStatus = RowStatus from Doctor WHERE DrID = @DrID
    select @Count =  COUNT(*) from Doctor WHERE DrID = @DrID

    IF @DrID = NULL
    BEGIN 
        PRINT 'Doctor ID cannot be null !!'
    END
    ELSE IF @Count = 0 or @RowStatus = 0
    BEGIN 
        PRINT 'There is not any record for this ID or In-active doctor cannot be deleted again !!'
    END
    ELSE
    BEGIN
        PRINT 'Records will be deleted in a while...'
        DELETE FROM Doctor
        WHERE DrID = @DrID
    END
END
GO

/* Perform undo on Patient table */
CREATE OR ALTER PROCEDURE DA_UndoPatient
as 
BEGIN
    DECLARE @PID VARCHAR(6), @PName VARCHAR(100), @PPhone varchar(20), @PaymentCardNo VARBINARY(MAX),@RowStatus INT
    SELECT TOP 1 
        @PID = PID,
        @PName = PName,
        @PPhone = PPhone,
        @PaymentCardNo = PaymentCardNo,
        @RowStatus = RowStatus
    FROM AuditLog_Patient
    ORDER BY [Log ID] DESC
    PRINT 'Record had been reverted !!'
    UPDATE [dbo].[Patient]
    SET [PName] = @PName,
        [PPhone] = @PPhone,
        [PaymentCardNo] = @PaymentCardNo,
        [RowStatus] = @RowStatus
    WHERE [PID] = @PID;
END
GO

/* Perform undo on Doctor table */
CREATE OR ALTER PROCEDURE DA_UndoDoctor
as 
BEGIN
    DECLARE @DrID VARCHAR(6), @DName VARCHAR(100), @DPhone VARBINARY(MAX),@RowStatus INT
    SELECT TOP 1 
        @DrID = DrID,
        @DName = DName,
        @DPhone = DPhone,
        @RowStatus = RowStatus
    FROM AuditLog_Doctor
    ORDER BY [Log ID] DESC
    PRINT 'Record had been reverted !!'
    UPDATE [dbo].[Doctor]
    SET [DName] = @DName,
        [DPhone] = @DPhone,
        [RowStatus] = @RowStatus
    WHERE [DrID] = @DrID;
END
GO




/* ------------------------- Views ---------------------------- */
/* View for active doctor */
CREATE OR ALTER VIEW DA_Active_Doctor as 
    SELECT DrID, DName
    from Doctor
    WHERE RowStatus = 1
GO

/* View for in-active doctor */
CREATE OR ALTER VIEW DA_Inactive_Doctor as 
    SELECT DrID, DName
    from Doctor
    WHERE RowStatus = 0
GO

/* View for active patient */
CREATE OR ALTER VIEW DA_Active_Patient as 
    SELECT PID, PName, PPhone
    from Patient
    WHERE RowStatus = 1
GO

/* View for in-active patient */
CREATE OR ALTER VIEW DA_Inactive_Patient as 
    SELECT PID, PName, PPhone
    from Patient
    WHERE RowStatus = 0
GO



/* Example to exec the above procedures */
-- EXEC DA_ManagePatientRecords @PName = 'New';
-- EXEC DA_DeletePatientRecords @PID = 'P10'
-- EXEC DA_ManageDoctorRecords @DrID='D9', @DPhone='810-123-4567';


