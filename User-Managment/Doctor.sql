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
CREATE LOGIN D2 with PASSWORD ='DR2@1234'; -- creat new user
-- CREATE USER D2 for LOGIN D2;


/* Grant permission */
GRANT EXECUTE on dbo.DR_ManageDoctorRecords to Doctor -- procedure

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
GRANT EXEC on dbo.DR_Add_Diagnosis to Doctor -- Add diagnosis
GRANT EXEC on dbo.DR_Udpate_Diagnosis to Doctor -- Update diagnosis
GRANT EXEC on dbo.DR_UndoDiagnosis to Doctor -- Undo diagnosis
GRANT SELECT ON OBJECT::cdc.dbo_Diagnosis_CT TO Doctor; -- select on cdc file

/* Action */
-- View personal information [NOTE: decryptoion action]
OPEN SYMMETRIC KEY SimKey_contact1
DECRYPTION BY CERTIFICATE CertForCLE;
SELECT * FROM View_Doctor_personal
CLOSE SYMMETRIC KEY SimKey_contact1

-- Modify own details
EXEC DA_ManageDoctorRecords @DName = 'Dr. John Smith'

-- update diagnosis details
exec DR_Udpate_Diagnosis @DiagID = 16, @Diagnosis = 'fever'

-- perform undo on changes make in diagnosis table
exec DR_UndoDiagnosis

-- View diagnosis
Select * from Diagnosis