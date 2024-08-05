/* 
This file consist all the permission granting and action can be perform by this roles
#TAKE NOTES
Sub-headings
1. Create new login (run using sa account)
2. Grant permission (run using sa account)
3. Action (run using DA_1)
*/

/* Create new login */
use MedicalInfoSystem;
CREATE LOGIN DA_1 with PASSWORD ='DA1@1234';
CREATE Role Data_Admin;
CREATE USER DA_1 for LOGIN DA_1;
ALTER role Data_Admin add member DA_1


/* Grant permission run as SA */
-- Adding roles
GRANT ALTER ANY ROLE TO Data_Admin; -- Allow adding new role
GRANT VIEW DEFINITION TO Data_Admin; -- Allow viwew all roles
GRANT ALTER ANY USER TO Data_Admin;  -- Allow assigning role to new user

-- Perform permission management
GRANT CONTROL ON OBJECT::[dbo].[Doctor] to Data_Admin
GRANT CONTROL ON OBJECT::[dbo].[Patient] to Data_Admin

-- Patient table
GRANT SELECT, insert, update, delete on Patient to Data_Admin; 
DENY SELECT, update on Patient(PaymentCardNo) to Data_Admin CASCADE; 
GRANT select on DA_Active_Patient to Data_Admin -- view active patient
GRANT select on DA_Inactive_Patient to Data_Admin -- view in-active patient

-- Doctor table
GRANT SELECT, insert, update, delete on Doctor to Data_Admin; 
DENY SELECT, update on Doctor(DPhone) to Data_Admin; 
GRANT select on DA_Active_Doctor to Data_Admin -- view active doctor
GRANT select on DA_Inactive_Doctor to Data_Admin -- view in-active doctor

-- Diagnosis table
GRANT SELECT on Diagnosis to Data_Admin;
Deny Select on Diagnosis(Diagnosis) to Data_Admin

-- Diagnosis table
Grant SELECT on DA_Diagnosis to Data_Admin

-- Exec
GRANT EXECUTE on dbo.DA_ManagePatientRecords to Data_Admin; -- Manage patient records
GRANT EXECUTE on dbo.DA_DeletePatientRecords to Data_Admin; -- Delete patient records
GRANT EXECUTE on dbo.DA_ManageDoctorRecords to Data_Admin; -- Manage doctor records
GRANT EXECUTE on dbo.DA_DeleteDoctorRecords to Data_Admin; -- Delete doctor records
GRANT EXECUTE on dbo.DA_UndoPatient to Data_Admin; -- Perform undo on patient table
GRANT EXECUTE on dbo.DA_UndoDoctor to Data_Admin; -- Perform undo on doctor table

/* Action */
-- Create new fyi this part we assume that the login had been created 
CREATE USER D2 for LOGIN D2;
ALTER role Doctor add member D2 -- adding new doctor

-- Create new user for patient and assigning roles
CREATE USER P2 for LOGIN P2
ALTER role Patient add member P2 -- adding new patient

-- drop user P2
-- drop user D2

-- View active or in-active user [we perform soft delete function to resolve foreign key constraints issues]
select * from DA_Active_Doctor; -- active doctor
select * from DA_Inactive_Doctor; -- inactive doctor
select * from DA_Active_Patient; -- active patient
select * from DA_Inactive_Patient -- inactive patient

-- View dianosis
select * from DA_Diagnosis

-- -- Adding new patient records
-- EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- -- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- -- Deleting patient records
-- EXEC DA_DeletePatientRecords @PID = 'P9'

-- -- Adding new doctor records
-- EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- -- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- -- Deleting doctor records
-- EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- -- Undo patient
-- EXEC DA_UndoPatient

-- -- Undo doctor
-- EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO

-- Adding new patient records
EXEC DA_ManagePatientRecords @PName = 'TestNew2'
-- EXEC DA_ManagePatientRecords @PID = 'P9' ,@PName = 'Ah Meng'

-- Deleting patient records
EXEC DA_DeletePatientRecords @PID = 'P9'

-- Adding new doctor records
EXEC DA_ManageDoctorRecords @DName = 'Dr. testNew'
-- EXEC DA_ManageDoctorRecords @DrID = 'D1' ,@DName = 'Dr. Ali'

-- Deleting doctor records
EXEC DA_DeleteDoctorRecords @DrID = 'D9'

-- Undo patient
EXEC DA_UndoPatient

-- Undo doctor
EXEC DA_UndoDoctor

/* Role user mapping */
SELECT roles.[name] as role_name, members.[name] as user_name
FROM sys.database_role_members 
INNER JOIN sys.database_principals roles 
ON database_role_members.role_principal_id = roles.principal_id
INNER JOIN sys.database_principals members 
ON database_role_members.member_principal_id = members.principal_id
WHERE roles.name in ('Data_Admin','Doctor','Patient')
GO