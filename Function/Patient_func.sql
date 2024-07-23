/*
This file consis all the procedure and view that had been precreated for Patient roles
*/

/* Manage own pii */
CREATE OR ALTER PROCEDURE P_Manage_PII 
@PName VARCHAR(100)=NULL,
@PPhone VARCHAR(20)=NULL,
@PaymentCardNo VARCHAR(100)=NULL
AS
BEGIN
    -- Get user patient id
    DECLARE @PID VARCHAR(6)
    SET @PID = ORIGINAL_LOGIN()
    BEGIN
        -- Esisting records
        PRINT 'Modifying existing record..'
        IF @PName IS NOT NULL
            UPDATE [dbo].[Patient]
            SET [PName] = @PName
            WHERE [PID] = @PID
        
        IF @PPhone IS NOT NULL
            UPDATE [dbo].[Patient]
            SET [PPhone] = @PPhone
            WHERE [PID] = @PID
        
        IF @PaymentCardNo IS NOT NULL
            UPDATE [dbo].[Patient]
            SET [PaymentCardNo] = EncryptByAsymKey(AsymKey_ID('AsymKey_paymentCarNo'),CONVERT(varbinary(MAX),@PaymentCardNo))
            WHERE [PID] = @PID
    END
END
GO

/* Create a view for patient table*/
CREATE OR ALTER VIEW P_View_personal AS
    SELECT PID, Pname, PPhone,
        CONVERT(varchar,DecryptByAsymkey(ASYMKEY_ID('AsymKey_paymentCarNo'),[PaymentCardNo])) as [PaymentCardNo] 
    FROM Patient
    WHERE PID = ORIGINAL_LOGIN();
GO


/* View diagnosis records */
CREATE OR ALTER VIEW P_View_diagnosis AS
    select a.DiagID, a.PatientID, a.DoctorID, b.DName as DoctorName,
        CONVERT(VARCHAR, DECRYPTBYKEY(b.DPhone)) AS DoctorPhone, a.DiagnosisDate,
        a.Diagnosis
    from Diagnosis a
    inner join Doctor b
    on a.DoctorID = b.DrID
    WHERE a.PatientID = ORIGINAL_LOGIN()
GO



/* Test exec */
-- EXEC P_Manage_PII @PID='P1', @PName='Ali'



select * from Diagnosis