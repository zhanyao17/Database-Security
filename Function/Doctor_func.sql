/*
This file consis all the procedure and view that had been precreated for doctor roles
*/


/* Modify doctor records*/
CREATE OR ALTER PROCEDURE DR_ManageDoctorRecords
@DName VARCHAR(100) = NULL,
@DPhone VARCHAR(20) = NULL
AS
BEGIN
    -- open encryption
    OPEN SYMMETRIC KEY SimKey_contact1
    DECRYPTION BY CERTIFICATE CertForCLE

    DECLARE @DrID VARCHAR(6)
    SET @DrID = ORIGINAL_LOGIN()
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
            SET [DPhone] =  EncryptByKey(Key_GUID('SimKey_contact1'), CONVERT(VARBINARY(MAX), @DPhone))
            WHERE [DrID] = @DrID
        END
    END
    -- Close the symmetric key
    CLOSE SYMMETRIC KEY SimKey_contact1;
END
GO

/* Create a view for doctor table*/
CREATE or ALTER PROCEDURE DR_View_Decrypted_Doctor_PII
as 
BEGIN
    OPEN SYMMETRIC KEY SimKey_contact1
    DECRYPTION BY CERTIFICATE CertForCLE;
    SELECT 
        DrID, 
        DName, 
        CONVERT(VARCHAR, DECRYPTBYKEY(DPhone)) AS DPhone  -- NOTE: perform decryption using symmetric
    FROM Doctor
    WHERE DrID = ORIGINAL_LOGIN(); 
    CLOSE SYMMETRIC KEY SimKey_contact1
END;
GO


/* Create a view for patient and diagnosis info*/
CREATE OR ALTER VIEW DR_View_Patient_Diagnosis AS
    SELECT a.DiagID, a.PatientID, b.PName as PatientName, a.DoctorID, a.DiagnosisDate, a.Diagnosis
    from Diagnosis a
    INNER JOIN
    Patient b on a.PatientID = b.PID
GO


/* Add new diagnosis records doctor */
CREATE OR ALTER PROCEDURE DR_Add_Diagnosis
    @PID VARCHAR(6) = NULL
AS
BEGIN
    DECLARE @CheckPiD INT;
    -- Get user id 
    DECLARE @DrID VARCHAR(6);
    SET @DrID = ORIGINAL_LOGIN();

    IF (@PID IS NULL)
    BEGIN
        PRINT 'Patient ID Column cannot be null !!';
        RETURN; -- Exit the procedure if Patient ID is NULL
    END
    ELSE
    BEGIN
        -- Check if the Patient ID exists in the Patient table
        SELECT @CheckPiD = COUNT(*)
        FROM Patient
        WHERE PID = @PID;

        IF @CheckPiD != 1
        BEGIN
            PRINT 'Patient records is not there yet !!';
            RETURN; -- Exit the procedure if Patient record is not found
        END
        ELSE
        BEGIN
            PRINT 'Creating new records for diagnosis...';

            -- Insert a new diagnosis record (identity column will auto-generate DiagID)
            INSERT INTO [dbo].[Diagnosis] 
                ([PatientID], [DoctorID], [DiagnosisDate], [Diagnosis])
            VALUES 
                (@PID, @DrID, GETDATE(), NULL);

            PRINT 'New Diagnosis record created.';
        END
    END
END
GO


/* Update diagnosis */
CREATE OR ALTER PROCEDURE DR_Udpate_Diagnosis
    @DiagID INT = NULL,
    @Diagnosis VARCHAR(MAX) = NULL
AS
BEGIN
    -- Get user id 
    DECLARE @DrID VARCHAR(6);
    SET @DrID = ORIGINAL_LOGIN();
    -- check status
    DECLARE @CheckPIC INT
    IF (@DiagID is NULL or @Diagnosis is NULL)
    BEGIN
        PRINT 'Diagnosis ID or Diagnosis content cannot be null !!'
    END
    ELSE
    BEGIN
        -- Check whether the patient is under the doctor anot
        SELECT @CheckPIC = COUNT(*)
        FROM Diagnosis
        WHERE DiagID = @DiagID AND DoctorID = @DrID
        IF @CheckPIC !=1
        BEGIN -- fail
            PRINT 'The diagnosis records is not under you, you cannot make changes on it !!'
        END
        ELSE
        BEGIN -- success
            UPDATE [dbo].[Diagnosis]
            SET [Diagnosis] = @Diagnosis
            WHERE [DiagID] = @DiagID
        END
    END
END
GO

/* Undo diagnosis */
CREATE OR ALTER PROCEDURE DR_UndoDiagnosis
as 
BEGIN
    DECLARE @DiagID INT, @PatientID varchar(6), @DoctorID VARCHAR(6), 
        @DiagnosisDate datetime, @Diagnosis VARCHAR(max)
    SELECT 
        @DiagID = DiagID,
        @PatientID = PatientID,
        @DoctorID = DoctorID,
        @DiagnosisDate = DiagnosisDate,
        @Diagnosis = Diagnosis
    FROM cdc.dbo_Diagnosis_CT
    WHERE DoctorID = ORIGINAL_LOGIN()
    ORDER BY __$start_lsn DESC
    OFFSET 1 ROWS
    FETCH NEXT 1 ROW ONLY;
    PRINT 'Record had been reverted !!' 
    UPDATE [dbo].[Diagnosis]
    SET [PatientID] = @PatientID,
        [DoctorID] = @DoctorID,
        [DiagnosisDate] = @DiagnosisDate,
        [Diagnosis] = @Diagnosis
    WHERE [DiagID] = @DiagID;
END
GO

/* Undo PII */
CREATE or ALTER PROCEDURE DR_UndoDoctorRecord
as 
BEGIN
    DECLARE @DrID VARCHAR(6), @DName VARCHAR (100), @DPhone VARBINARY(max), @RowStatus INT
    Select top 1
        @DrID = ORIGINAL_LOGIN(),
        @DName = DName,
        @DPhone = DPhone,
        @RowStatus = RowStatus
    from DoctorHistory
    WHERE DrID = ORIGINAL_LOGIN()
    order by ValidTo DESC
    PRINT 'Record had been reverted !!'
    update [dbo].[Doctor]
    set [DName] = @DName,
        [DPhone] = @DPhone,
        [RowStatus] = @RowStatus
    WHERE [DrID] = @DrID
END
go
