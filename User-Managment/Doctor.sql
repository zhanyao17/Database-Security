/* 
This file consist all the permission granting and action can be perform by this roles
#TAKE NOTES
Sub-headings
1. Create new login (run using sa account)
2. Grant permission (run using sa account)
3. Action (run using D1)
*/

-- Doctor 1
CREATE Role Doctor; -- Create role
CREATE LOGIN D1 with PASSWORD ='DR1@1234'; -- creat new user
CREATE USER D1 for LOGIN D1;
ALTER role Doctor add member D1


-- Doctor 2
CREATE LOGIN D2 with PASSWORD ='DR2@1234'; -- creat new login
CREATE LOGIN D3 with PASSWORD ='DR3@1234'; -- creat new login
CREATE LOGIN D4 with PASSWORD ='DR4@1234'; -- creat new login
-- CREATE USER D2 for LOGIN D2;


/* Grant permission */
-- Doctor
GRANT select on View_Doctor_personal to Doctor -- views own pii

-- For symetric key and cert to access contact
GRANT VIEW DEFINITION ON SYMMETRIC KEY::SimKey_contact1 TO Doctor;
GRANT CONTROL ON SYMMETRIC KEY::SimKey_contact1 TO Doctor;
GRANT VIEW DEFINITION ON CERTIFICATE::CertForCLE TO Doctor;
GRANT CONTROL ON CERTIFICATE::CertForCLE TO Doctor;

-- Dianosis with patient view
GRANT SELECT on DR_View_Patient_Diagnosis to Doctor

-- Unmask
GRANT UNMASK TO Doctor;

-- Diagnosis
GRANT SELECT ON Diagnosis TO Doctor

GRANT SELECT ON OBJECT::cdc.dbo_Diagnosis_CT TO Doctor; -- select on cdc file

-- Exec
GRANT EXEC on dbo.DR_Add_Diagnosis to Doctor -- Add diagnosis
GRANT EXEC on dbo.DR_Udpate_Diagnosis to Doctor -- Update diagnosis
GRANT EXEC on dbo.DR_UndoDiagnosis to Doctor -- Undo diagnosis
GRANT EXECUTE on dbo.DR_ManageDoctorRecords to Doctor -- mode PII
GRANT EXECUTE on dbo.DR_UndoDoctorRecord to Doctor -- undo PII
GRANT EXECUTE on dbo.DR_View_Decrypted_Doctor_PII to Doctor -- view decrypted data


/* Action */
-- View personal information [symmetric]
EXEC DR_View_Decrypted_Doctor_PII

-- View diagnosis
Select * from DR_View_Patient_Diagnosis

-- Add diagnosis details
exec DR_Add_Diagnosis @PID = 'P1' 

-- Update diagnosis details
exec DR_Udpate_Diagnosis @DiagID = 18, @Diagnosis = 'Flu'

-- [TRY] update other doctor's diagnosis details
exec DR_Udpate_Diagnosis @DiagID = 2, @Diagnosis = 'Flu'

-- Perform undo on changes make in diagnosis table
exec DR_UndoDiagnosis

-- [TRY] Delete any records
delete from Diagnosis where DiagID = 17

-- Modify own details
-- EXEC DR_ManageDoctorRecords @DName = 'Dr. John Smith', @DPhone = '123-456-8888'

-- -- Undo own details
-- EXEC DR_UndoDoctorRecord